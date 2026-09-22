-- Guild Bounties v2: async guild-wide collective objective. Design (2026-09-22):
--   * ONE active bounty per guild at a time (no reward inflation; one rallying point).
--   * MULTI-TRACK so it never locks anyone out: any of kills / gathers / dungeon clears feed ONE shared bar,
--     weighted per bounty (tracks jsonb). Rotating flavor varies the weighting each cycle.
--   * Progress accrues from normal play, active OR idle (idle actions resolve client-side and fire the same
--     events), server-authoritative via contribute_guild_bounty.
--   * Officer/GM funds activation from personal Gold Marks (guild features have no pooled GM).
--   * Reward: a temporary guild-wide buff (guild_active_buffs) for everyone, plus a bonus item to the top 3
--     contributors (pending_transfers). Per-member contribution is tracked privately (no live leaderboard,
--     to avoid infighting); the top 3 are revealed only at completion.

alter table guild_bounties
    add column if not exists tracks             jsonb  not null default '{}'::jsonb, -- action_type -> weight
    add column if not exists reward_buff_name   text,
    add column if not exists reward_buff_hours  int    not null default 24,
    add column if not exists reward_top3_item   text,
    add column if not exists reward_top3_qty    int    not null default 0;

-- Private per-member contribution (drives the top-3 reveal at completion).
create table if not exists guild_bounty_contributions (
    bounty_id  uuid   not null references guild_bounties(id) on delete cascade,
    player_id  uuid   not null references players(id) on delete cascade,
    amount     bigint not null default 0,
    updated_at timestamptz not null default now(),
    primary key (bounty_id, player_id)
);
alter table guild_bounty_contributions enable row level security;
create policy "gbc: members read own guild"
    on guild_bounty_contributions for select
    using (bounty_id in (
        select id from guild_bounties
        where guild_id in (select guild_id from guild_members where player_id = auth.uid())
    ));

-- ACTIVATE: officer/GM funds a bounty from personal Gold Marks; enforces one-active-per-guild.
create or replace function activate_guild_bounty(
    p_guild_id uuid, p_title text, p_tracks jsonb, p_target bigint, p_cost_gm bigint,
    p_deadline timestamptz, p_reward_desc text, p_buff_name text, p_buff_hours int,
    p_top3_item text, p_top3_qty int)
returns uuid language plpgsql security definer as $$
declare v_bal bigint; v_id uuid;
begin
    if not exists (select 1 from guild_members
                   where guild_id = p_guild_id and player_id = auth.uid()
                     and role in ('officer','guild_master')) then
        raise exception 'not an officer of this guild';
    end if;
    if exists (select 1 from guild_bounties
               where guild_id = p_guild_id and is_active and completed_at is null) then
        raise exception 'a bounty is already active';
    end if;
    select gold_marks into v_bal from players where id = auth.uid() for update;
    if coalesce(v_bal,0) < p_cost_gm then raise exception 'insufficient gold marks'; end if;
    update players set gold_marks = gold_marks - p_cost_gm where id = auth.uid();
    insert into guild_bounties(guild_id, title, target_count, current_count, reward_desc, cost_gm,
        is_active, activated_by, deadline_at, tracks, reward_buff_name, reward_buff_hours,
        reward_top3_item, reward_top3_qty)
    values (p_guild_id, p_title, p_target, 0, p_reward_desc, p_cost_gm, true, auth.uid(), p_deadline,
        coalesce(p_tracks,'{}'::jsonb), p_buff_name, coalesce(p_buff_hours,24),
        p_top3_item, coalesce(p_top3_qty,0))
    returning id into v_id;
    return v_id;
end $$;

-- CONTRIBUTE: called on a qualifying action (kill/gather/dungeon), active or idle. Weighted by tracks.
-- Atomically bumps the collective bar + the caller's contribution; on reaching target, completes + rewards.
create or replace function contribute_guild_bounty(p_action text, p_amount bigint)
returns void language plpgsql security definer as $$
declare v_b guild_bounties; v_w numeric; v_add bigint; v_gid uuid; r record;
begin
    select guild_id into v_gid from guild_members where player_id = auth.uid();
    if v_gid is null then return; end if;
    select * into v_b from guild_bounties
        where guild_id = v_gid and is_active and completed_at is null and deadline_at > now()
        for update;
    if not found then return; end if;
    v_w := coalesce((v_b.tracks->>p_action)::numeric, 0);
    if v_w <= 0 then return; end if;                         -- action isn't a track for the current bounty
    v_add := floor(greatest(p_amount,0) * v_w)::bigint;
    if v_add <= 0 then return; end if;
    update guild_bounties set current_count = least(target_count, current_count + v_add) where id = v_b.id;
    insert into guild_bounty_contributions(bounty_id, player_id, amount)
        values (v_b.id, auth.uid(), v_add)
        on conflict (bounty_id, player_id)
        do update set amount = guild_bounty_contributions.amount + v_add, updated_at = now();
    select * into v_b from guild_bounties where id = v_b.id;
    if v_b.current_count >= v_b.target_count and v_b.completed_at is null then
        update guild_bounties set completed_at = now(), is_active = false where id = v_b.id;
        if v_b.reward_buff_name is not null then
            insert into guild_active_buffs(guild_id, buff_name, cost_gm, activated_by, expires_at)
            values (v_b.guild_id, v_b.reward_buff_name, 0, v_b.activated_by,
                    now() + (v_b.reward_buff_hours || ' hours')::interval);
        end if;
        if v_b.reward_top3_item is not null and v_b.reward_top3_qty > 0 then
            for r in select player_id from guild_bounty_contributions
                     where bounty_id = v_b.id order by amount desc limit 3 loop
                insert into pending_transfers(from_player, to_player, item_id, quantity, message)
                values (v_b.activated_by, r.player_id, v_b.reward_top3_item, v_b.reward_top3_qty,
                        'Guild bounty top contributor: ' || v_b.title);
            end loop;
        end if;
    end if;
end $$;

-- CRON sweep: close bounties whose deadline passed without completion (mirrors the other guild sweeps).
create or replace function close_expired_guild_bounties()
returns void language sql security definer as $$
    update guild_bounties set is_active = false
    where is_active and completed_at is null and deadline_at < now();
$$;

grant execute on function activate_guild_bounty(uuid,text,jsonb,bigint,bigint,timestamptz,text,text,int,text,int) to authenticated;
grant execute on function contribute_guild_bounty(text,bigint) to authenticated;

select cron.schedule('close-expired-guild-bounties', '*/30 * * * *', 'select close_expired_guild_bounties()');
