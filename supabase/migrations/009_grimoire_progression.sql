-- Project Grimoire — Grimoire Combat Progression (Migration 009)
-- Part A: per-Grimoire combat levels + permanent milestone stat bonuses.
-- Run AFTER 002_auth_schema.sql (needs players + auth.uid RLS model).

-- ── Per-Grimoire combat level / XP ──────────────────────────────────────────
-- One row per owned Grimoire. Total Combat Level = SUM(combat_level) for a player.
create table if not exists player_grimoire_levels (
    player_id    uuid not null references players(id) on delete cascade,
    grimoire_id  text not null,                 -- stable grimoire identifier (see GrimoireData)
    path         text not null,                 -- 'Warden' | 'Arcanist' | 'Vanguard'
    combat_level integer not null default 1,
    combat_xp    bigint  not null default 0,
    updated_at   timestamptz not null default now(),
    primary key (player_id, grimoire_id)
);

alter table player_grimoire_levels enable row level security;
drop policy if exists "grimoire_levels: own rows only" on player_grimoire_levels;
create policy "grimoire_levels: own rows only"
    on player_grimoire_levels for all
    using (auth.uid() = player_id)
    with check (auth.uid() = player_id);

-- ── Permanent stat bonuses from Warfare/Spellcasting milestones ──────────────
-- Milestone-keyed for idempotency: each milestone (grimoire + level) grants one
-- stat once. A Grimoire may grant the same stat at multiple levels, so total
-- bonus for a stat is SUM(amount) across rows. These persist regardless of which
-- Grimoire is currently equipped.
create table if not exists player_stat_bonuses (
    player_id       uuid not null references players(id) on delete cascade,
    grimoire_id     text not null,
    milestone_level integer not null,           -- Warfare/Spellcasting level that granted this
    stat_type       text not null,              -- 'STR' | 'DEX' | 'VIT' | 'INT' | 'WIL' | 'LCK'
    amount          integer not null,
    granted_at      timestamptz not null default now(),
    primary key (player_id, grimoire_id, milestone_level)
);

alter table player_stat_bonuses enable row level security;
drop policy if exists "stat_bonuses: own rows only" on player_stat_bonuses;
create policy "stat_bonuses: own rows only"
    on player_stat_bonuses for all
    using (auth.uid() = player_id)
    with check (auth.uid() = player_id);

-- ── Helper: total combat level for a player ─────────────────────────────────
create or replace function total_combat_level(p_player_id uuid)
returns integer language sql stable as $$
    select coalesce(sum(combat_level), 0)::int
    from player_grimoire_levels
    where player_id = p_player_id;
$$;
