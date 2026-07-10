-- Project Grimoire — Guild Schema (Migration 003)
-- Run AFTER 002_auth_schema.sql.

-- ── Guilds ────────────────────────────────────────────────────────────────
create table if not exists guilds (
    id              uuid primary key default gen_random_uuid(),
    name            text unique not null,
    founder_id      uuid not null references players(id),
    prestige_level  integer not null default 0,
    roster_tier     integer not null default 0,
    member_count    integer not null default 1,
    tax_rate        float   not null default 2.0,   -- 0–5%
    bank_silver     bigint  not null default 0,
    bank_gold       bigint  not null default 0,
    join_policy     text    not null default 'apply', -- open/apply/invite_only
    created_at      timestamptz not null default now(),
    disbanded_at    timestamptz
);

alter table guilds enable row level security;
-- Anyone can read guild info (for search/browse); only members can see bank balance
create policy "guilds: public read"
    on guilds for select using (true);
create policy "guilds: founder can update"
    on guilds for update using (auth.uid() = founder_id);

-- ── Guild members ──────────────────────────────────────────────────────────
create table if not exists guild_members (
    guild_id            uuid not null references guilds(id) on delete cascade,
    player_id           uuid not null references players(id) on delete cascade,
    role                text not null default 'member', -- member/officer/guild_master
    contribution_total  bigint not null default 0,
    joined_at           timestamptz not null default now(),
    last_active         timestamptz,
    primary key (guild_id, player_id)
);

alter table guild_members enable row level security;
create policy "guild_members: members can read own guild"
    on guild_members for select
    using (
        guild_id in (
            select guild_id from guild_members where player_id = auth.uid()
        )
    );
create policy "guild_members: own row"
    on guild_members for all using (auth.uid() = player_id);

-- ── Guild bank slots ───────────────────────────────────────────────────────
create table if not exists guild_bank_slots (
    guild_id    uuid not null references guilds(id) on delete cascade,
    item_id     text not null,
    quantity    bigint not null default 0,
    primary key (guild_id, item_id)
);

alter table guild_bank_slots enable row level security;
create policy "guild_bank_slots: members can read"
    on guild_bank_slots for select
    using (
        guild_id in (
            select guild_id from guild_members where player_id = auth.uid()
        )
    );
create policy "guild_bank_slots: officers can write"
    on guild_bank_slots for all
    using (
        guild_id in (
            select guild_id from guild_members
            where player_id = auth.uid() and role in ('officer','guild_master')
        )
    );

-- ── Guild active buffs ─────────────────────────────────────────────────────
create table if not exists guild_active_buffs (
    id          uuid primary key default gen_random_uuid(),
    guild_id    uuid not null references guilds(id) on delete cascade,
    buff_name   text not null,
    cost_gm     bigint not null,
    activated_by uuid not null references players(id),
    activated_at timestamptz not null default now(),
    expires_at  timestamptz not null
);

alter table guild_active_buffs enable row level security;
create policy "guild_active_buffs: members can read"
    on guild_active_buffs for select
    using (
        guild_id in (
            select guild_id from guild_members where player_id = auth.uid()
        )
    );

-- ── Guild buff activations (trigger endpoint) ──────────────────────────────
-- Client POSTs here; Edge Function handles deducting gold + inserting active buff
create table if not exists guild_buff_activations (
    id          uuid primary key default gen_random_uuid(),
    guild_id    uuid not null references guilds(id),
    buff_name   text not null,
    cost_gm     bigint not null,
    requested_by uuid not null references players(id),
    created_at  timestamptz not null default now()
);

alter table guild_buff_activations enable row level security;
create policy "guild_buff_activations: officers can insert"
    on guild_buff_activations for insert
    with check (
        guild_id in (
            select guild_id from guild_members
            where player_id = auth.uid() and role in ('officer','guild_master')
        )
    );

-- ── Guild bounties ─────────────────────────────────────────────────────────
create table if not exists guild_bounties (
    id            uuid primary key default gen_random_uuid(),
    guild_id      uuid not null references guilds(id) on delete cascade,
    title         text not null,
    target_count  bigint not null,
    current_count bigint not null default 0,
    reward_desc   text not null,
    cost_gm       bigint not null,
    is_active     boolean not null default true,
    activated_by  uuid not null references players(id),
    activated_at  timestamptz not null default now(),
    deadline_at   timestamptz not null,
    completed_at  timestamptz
);

alter table guild_bounties enable row level security;
create policy "guild_bounties: members can read"
    on guild_bounties for select
    using (
        guild_id in (
            select guild_id from guild_members where player_id = auth.uid()
        )
    );

-- ── Helper: increment guild contribution ────────────────────────────────────
create or replace function increment_guild_contribution(
    p_guild_id  uuid,
    p_player_id uuid,
    p_amount    bigint
)
returns void language sql security definer as $$
    update guild_members
    set contribution_total = contribution_total + p_amount
    where guild_id = p_guild_id and player_id = p_player_id;
$$;

-- ── Helper: upsert guild bank slot ──────────────────────────────────────────
create or replace function upsert_guild_bank_slot(
    p_guild_id  uuid,
    p_item_id   text,
    p_quantity  bigint
)
returns void language sql security definer as $$
    insert into guild_bank_slots (guild_id, item_id, quantity)
    values (p_guild_id, p_item_id, p_quantity)
    on conflict (guild_id, item_id)
    do update set quantity = excluded.quantity;
$$;
