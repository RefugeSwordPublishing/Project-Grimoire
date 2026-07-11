-- Project Grimoire — Guild vote ballots + atomic cast/tally/apply (Migration 015)
-- 2/3 approval votes for tax rate and guild name. One ballot per member per vote.
-- cast_guild_vote() is SECURITY DEFINER: it records the ballot, updates the tally,
-- and — if For-votes reach ceil(2/3 * member_count) — applies the change and closes
-- the vote. The 7-day timed close is a scheduled Edge Function (not included here).

create table if not exists guild_vote_ballots (
    vote_id    uuid not null,
    vote_type  text not null,          -- 'tax' | 'name'
    guild_id   uuid not null references guilds(id) on delete cascade,
    player_id  uuid not null references players(id) on delete cascade,
    choice     text not null,          -- 'for' | 'against'
    created_at timestamptz not null default now(),
    primary key (vote_id, player_id)
);
alter table guild_vote_ballots enable row level security;
drop policy if exists "ballots: members read" on guild_vote_ballots;
create policy "ballots: members read" on guild_vote_ballots for select
    using (guild_id in (select auth_guild_ids()));
drop policy if exists "ballots: own insert" on guild_vote_ballots;
create policy "ballots: own insert" on guild_vote_ballots for insert
    with check (player_id = auth.uid() and guild_id in (select auth_guild_ids()));

alter table guild_tax_votes  alter column closes_at set default now() + interval '7 days';
alter table guild_name_votes alter column closes_at set default now() + interval '7 days';

create or replace function cast_guild_vote(p_vote_id uuid, p_vote_type text, p_guild_id uuid, p_choice text)
returns text language plpgsql security definer set search_path = public as $$
declare v_for int; v_against int; v_members int; v_threshold int;
begin
    insert into guild_vote_ballots (vote_id, vote_type, guild_id, player_id, choice)
    values (p_vote_id, p_vote_type, p_guild_id, auth.uid(), p_choice);  -- PK blocks double-vote

    if p_vote_type = 'tax' then
        update guild_tax_votes set
            votes_for     = votes_for     + (case when p_choice='for'     then 1 else 0 end),
            votes_against = votes_against + (case when p_choice='against' then 1 else 0 end)
        where id = p_vote_id and status = 'open'
        returning votes_for, votes_against into v_for, v_against;
    else
        update guild_name_votes set
            votes_for     = votes_for     + (case when p_choice='for'     then 1 else 0 end),
            votes_against = votes_against + (case when p_choice='against' then 1 else 0 end)
        where id = p_vote_id and status = 'open'
        returning votes_for, votes_against into v_for, v_against;
    end if;

    select member_count into v_members from guilds where id = p_guild_id;
    v_threshold := ceil(v_members * 2.0 / 3.0);

    if v_for >= v_threshold then
        if p_vote_type = 'tax' then
            update guilds set tax_rate = (select proposed_rate from guild_tax_votes where id = p_vote_id) where id = p_guild_id;
            update guild_tax_votes set status = 'passed' where id = p_vote_id;
        else
            update guilds set name = (select proposed_name from guild_name_votes where id = p_vote_id),
                              name_changed_at = now() where id = p_guild_id;
            update guild_name_votes set status = 'passed' where id = p_vote_id;
        end if;
        return 'passed';
    end if;
    return 'voted';
end; $$;
