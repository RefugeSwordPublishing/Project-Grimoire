-- Project Grimoire — Guild name change vote (Migration 014)
-- Guild names can be changed via an officer vote, at most once every 3 months.

alter table guilds add column if not exists name_changed_at timestamptz;

create table if not exists guild_name_votes (
    id            uuid primary key default gen_random_uuid(),
    guild_id      uuid not null references guilds(id) on delete cascade,
    proposed_name text not null,
    initiated_by  uuid not null references players(id),
    initiated_at  timestamptz not null default now(),
    votes_for     integer not null default 0,
    votes_against integer not null default 0,
    status        text not null default 'open',
    closes_at     timestamptz not null default now() + interval '48 hours'
);

alter table guild_name_votes enable row level security;
drop policy if exists "name_votes: members read" on guild_name_votes;
create policy "name_votes: members read" on guild_name_votes for select
    using (guild_id in (select auth_guild_ids()));
drop policy if exists "name_votes: officers write" on guild_name_votes;
create policy "name_votes: officers write" on guild_name_votes for all
    using (guild_id in (select auth_officer_guild_ids()))
    with check (guild_id in (select auth_officer_guild_ids()));
