-- Project Grimoire — Guild Hall (Migration 007)
-- Adds create/join flows, material requests, and join requests.
-- Run AFTER 003_guild_schema.sql.

-- ── Missing INSERT policy on guilds ─────────────────────────────────────────
-- 003 only granted public read + founder update. Guild creation goes through the
-- security-definer create_guild() RPC below, but keep a direct-insert policy too
-- for founder-authored rows in case the RPC is bypassed.
drop policy if exists "guilds: founder can insert" on guilds;
create policy "guilds: founder can insert"
    on guilds for insert
    with check (auth.uid() = founder_id);

-- ── Guild creation RPC ──────────────────────────────────────────────────────
-- Inserts the guild AND the founder's guild_master member row atomically,
-- returning the new guild id. Security definer so it runs past RLS while still
-- keying every write to the caller's auth.uid().
create or replace function create_guild(p_name text, p_join_policy text)
returns uuid language plpgsql security definer as $$
declare
    new_id uuid;
begin
    if length(p_name) < 3 or length(p_name) > 30 then
        raise exception 'Guild name must be 3–30 characters';
    end if;

    insert into guilds (name, founder_id, join_policy, member_count)
    values (p_name, auth.uid(), coalesce(p_join_policy, 'apply'), 1)
    returning id into new_id;

    insert into guild_members (guild_id, player_id, role)
    values (new_id, auth.uid(), 'guild_master');

    return new_id;
end;
$$;

-- ── Guild join RPC (open guilds) ────────────────────────────────────────────
-- Direct join for 'open' guilds; increments member_count atomically.
create or replace function join_guild(p_guild_id uuid)
returns void language plpgsql security definer as $$
begin
    insert into guild_members (guild_id, player_id, role)
    values (p_guild_id, auth.uid(), 'member')
    on conflict (guild_id, player_id) do nothing;

    update guilds
    set member_count = member_count + 1
    where id = p_guild_id;
end;
$$;

-- ── Guild material requests ─────────────────────────────────────────────────
create table if not exists guild_material_requests (
    id                 uuid primary key default gen_random_uuid(),
    guild_id           uuid not null references guilds(id) on delete cascade,
    item_id            text not null,
    quantity_needed    bigint not null,
    quantity_fulfilled bigint not null default 0,
    purpose            text,
    posted_by          uuid not null references players(id),
    is_closed          boolean not null default false,
    created_at         timestamptz not null default now()
);

alter table guild_material_requests enable row level security;

create policy "guild_material_requests: members can read"
    on guild_material_requests for select
    using (
        guild_id in (
            select guild_id from guild_members where player_id = auth.uid()
        )
    );

-- Officers post requests
create policy "guild_material_requests: officers can insert"
    on guild_material_requests for insert
    with check (
        guild_id in (
            select guild_id from guild_members
            where player_id = auth.uid() and role in ('officer','guild_master')
        )
    );

-- Any member can update fulfillment progress by donating
create policy "guild_material_requests: members can update"
    on guild_material_requests for update
    using (
        guild_id in (
            select guild_id from guild_members where player_id = auth.uid()
        )
    );

-- ── Guild join requests (apply / invite-only guilds) ────────────────────────
create table if not exists guild_join_requests (
    guild_id      uuid not null references guilds(id) on delete cascade,
    player_id     uuid not null references players(id) on delete cascade,
    requested_at  timestamptz not null default now(),
    status        text not null default 'pending', -- pending/approved/declined
    primary key (guild_id, player_id)
);

alter table guild_join_requests enable row level security;

-- Applicant can create + see their own request
create policy "guild_join_requests: own row"
    on guild_join_requests for all
    using (auth.uid() = player_id)
    with check (auth.uid() = player_id);

-- Officers can read + resolve requests for their guild
create policy "guild_join_requests: officers can read"
    on guild_join_requests for select
    using (
        guild_id in (
            select guild_id from guild_members
            where player_id = auth.uid() and role in ('officer','guild_master')
        )
    );

create policy "guild_join_requests: officers can update"
    on guild_join_requests for update
    using (
        guild_id in (
            select guild_id from guild_members
            where player_id = auth.uid() and role in ('officer','guild_master')
        )
    );
