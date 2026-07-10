-- Project Grimoire — Auth-Based Schema (Migration 002)
-- Replaces anonymous device_id schema with Supabase Auth user IDs.
-- Run AFTER 001_initial_schema.sql. Safe to run on a fresh project.
--
-- Prerequisites:
--   Enable Supabase Auth in your project dashboard (it's on by default).
--   players.id is the Supabase Auth user UUID — no separate player_id needed.

-- ── Drop old device_id tables ──────────────────────────────────────────────
-- (safe to skip if running on a fresh project)
drop table if exists idle_queue cascade;
drop table if exists talent_progress cascade;
drop table if exists inventory cascade;
drop table if exists players cascade;

-- ── Core player row ────────────────────────────────────────────────────────
create table if not exists players (
    id                   uuid primary key references auth.users(id) on delete cascade,
    username             text unique not null,
    username_changed_at  timestamptz,
    security_question_1  text,
    security_answer_1    text,   -- bcrypt hashed
    security_question_2  text,
    security_answer_2    text,   -- bcrypt hashed
    created_at           timestamptz not null default now(),
    last_active          timestamptz,
    onboarding_complete  boolean not null default false,
    onboarding_step      integer not null default 0,
    grimoire_equipped    text,
    grimoire_swapped_at  timestamptz,
    exchange_unlocked    boolean not null default false,
    exchange_first_visit boolean not null default true,
    deleted_at           timestamptz
);

alter table players enable row level security;
create policy "players: own row only"
    on players for all
    using (auth.uid() = id);

-- ── Stats ──────────────────────────────────────────────────────────────────
create table if not exists player_stats (
    player_id  uuid primary key references players(id) on delete cascade,
    str        integer not null default 1,
    dex        integer not null default 1,
    vit        integer not null default 1,
    int        integer not null default 1,
    wil        integer not null default 1,
    lck        integer not null default 1,
    cha        integer not null default 1,
    max_hp     integer not null default 54,
    current_hp integer not null default 54
);

alter table player_stats enable row level security;
create policy "player_stats: own row only"
    on player_stats for all
    using (auth.uid() = player_id);

-- ── Talents ────────────────────────────────────────────────────────────────
create table if not exists player_talents (
    player_id     uuid not null references players(id) on delete cascade,
    talent_id     text not null,   -- lowercase talent name, e.g. "foraging"
    level         integer not null default 1,
    current_xp    bigint  not null default 0,
    is_idle       boolean not null default false,
    idle_activity text,
    assigned_at   timestamptz,
    primary key (player_id, talent_id)
);

alter table player_talents enable row level security;
create policy "player_talents: own rows only"
    on player_talents for all
    using (auth.uid() = player_id);

-- ── Inventory ──────────────────────────────────────────────────────────────
create table if not exists player_inventory (
    player_id         uuid not null references players(id) on delete cascade,
    item_id           text not null,
    quantity          integer not null default 1,
    slot_position     integer,
    is_locked         boolean not null default false,
    placeholder_label text,
    primary key (player_id, item_id)
);

alter table player_inventory enable row level security;
create policy "player_inventory: own rows only"
    on player_inventory for all
    using (auth.uid() = player_id);

-- ── Currency ───────────────────────────────────────────────────────────────
create table if not exists player_currency (
    player_id    uuid primary key references players(id) on delete cascade,
    silver_marks bigint not null default 500,
    gold_marks   bigint not null default 0,
    updated_at   timestamptz not null default now()
);

alter table player_currency enable row level security;
create policy "player_currency: own row only"
    on player_currency for all
    using (auth.uid() = player_id);

-- ── Grimoires unlocked ─────────────────────────────────────────────────────
create table if not exists player_grimoires (
    player_id   uuid not null references players(id) on delete cascade,
    grimoire_id text not null,
    unlocked_at timestamptz not null default now(),
    primary key (player_id, grimoire_id)
);

alter table player_grimoires enable row level security;
create policy "player_grimoires: own rows only"
    on player_grimoires for all
    using (auth.uid() = player_id);

-- ── Active buffs ───────────────────────────────────────────────────────────
create table if not exists player_active_buffs (
    id         uuid primary key default gen_random_uuid(),
    player_id  uuid not null references players(id) on delete cascade,
    buff_id    text not null,
    buff_type  text not null,
    value      float not null default 0,
    expires_at timestamptz not null,
    source     text
);

alter table player_active_buffs enable row level security;
create policy "player_active_buffs: own rows only"
    on player_active_buffs for all
    using (auth.uid() = player_id);

-- ── Settings ───────────────────────────────────────────────────────────────
create table if not exists player_settings (
    player_id                  uuid primary key references players(id) on delete cascade,
    -- Audio
    master_volume              float not null default 0.8,
    music_volume               float not null default 0.8,
    sfx_volume                 float not null default 0.8,
    ui_volume                  float not null default 0.7,
    music_enabled              boolean not null default true,
    sfx_enabled                boolean not null default true,
    ui_sounds_enabled          boolean not null default true,
    victory_stings_enabled     boolean not null default true,
    audio_in_background        boolean not null default false,
    -- Notifications
    notifications_enabled      boolean not null default true,
    notification_levelup       boolean not null default true,
    notification_raredrop      boolean not null default true,
    notification_boss          boolean not null default true,
    notification_quest         boolean not null default true,
    notification_exchange_sale boolean not null default true,
    notification_exchange_buy  boolean not null default true,
    notification_grimoire_cd   boolean not null default true,
    notification_guild         boolean not null default true,
    notification_dungeon       boolean not null default true,
    notification_raid          boolean not null default true,
    notification_daily_reset   boolean not null default false,
    fcm_token                  text,
    -- Display
    ui_scale                   text not null default 'medium',   -- small/medium/large
    show_damage_numbers        boolean not null default true,
    show_xp_notifications      boolean not null default true,
    show_loot_toasts           boolean not null default true,
    reduce_motion              boolean not null default false,
    show_fps_counter           boolean not null default false,
    brightness_lock            boolean not null default false,
    color_theme                text not null default 'dark',     -- dark/sepia/high_contrast
    -- Accessibility
    large_text                 boolean not null default false,
    bold_text                  boolean not null default false,
    reduce_transparency        boolean not null default false,
    colorblind_mode            text not null default 'off',      -- off/deuteranopia/protanopia/tritanopia
    attunement_window_size     text not null default 'medium',   -- small/medium/large
    haptic_feedback            boolean not null default true,
    screen_reader              boolean not null default false,
    -- Privacy
    analytics_enabled          boolean not null default true,
    crash_reporting_enabled    boolean not null default true,
    personalized_merchant      boolean not null default true,
    show_online_status         boolean not null default true,
    allow_friend_requests      boolean not null default true,
    allow_item_sends           boolean not null default true
);

alter table player_settings enable row level security;
create policy "player_settings: own row only"
    on player_settings for all
    using (auth.uid() = player_id);

-- ── Slaying tasks ──────────────────────────────────────────────────────────
create table if not exists player_slaying_tasks (
    id               uuid primary key default gen_random_uuid(),
    player_id        uuid not null references players(id) on delete cascade,
    task_id          text not null,
    task_type        text not null,
    description      text not null,
    target_count     integer not null default 1,
    current_count    integer not null default 0,
    tier             integer not null default 1,
    accepted_at      timestamptz not null default now(),
    completed_at     timestamptz,
    reward_marks     integer not null default 0,
    reward_material  text
);

alter table player_slaying_tasks enable row level security;
create policy "player_slaying_tasks: own rows only"
    on player_slaying_tasks for all
    using (auth.uid() = player_id);

-- ── Idle XP rates (global, server-tunable) ────────────────────────────────
-- Re-seed with correct values from attunement-data-spec.md
create table if not exists talent_idle_rates (
    talent_name      text primary key,
    base_xp_per_hour float not null default 100.0,
    cycle_seconds    float not null default 6.0,
    updated_at       timestamptz not null default now()
);
-- Add cycle_seconds if table already existed from migration 001
alter table talent_idle_rates
    add column if not exists cycle_seconds float not null default 6.0;

insert into talent_idle_rates (talent_name, base_xp_per_hour, cycle_seconds) values
    ('Foraging',     3600, 6),
    ('Trapping',     3200, 8),
    ('Dredging',     3000, 7),
    ('Cookery',      2800, 9),
    ('Alchemy',      2800, 8),
    ('Marksmanship', 3200, 6),
    ('Slaying',      3200, 6),
    ('Tanning',      2600, 6),
    ('Artificing',   2600, 8),
    ('Inscription',  2400, 7)
on conflict (talent_name) do update set
    base_xp_per_hour = excluded.base_xp_per_hour,
    cycle_seconds    = excluded.cycle_seconds,
    updated_at       = now();

-- ── Pending transfers (inventory Send to Player) ──────────────────────────
create table if not exists pending_transfers (
    id            uuid primary key default gen_random_uuid(),
    from_player   uuid not null references players(id),
    to_player     uuid not null references players(id),
    item_id       text not null,
    quantity      integer not null default 1,
    message       text,
    created_at    timestamptz not null default now(),
    accepted_at   timestamptz,
    declined_at   timestamptz
);

alter table pending_transfers enable row level security;
-- Sender can insert; recipient can read and update (accept/decline)
create policy "transfers: sender can insert"
    on pending_transfers for insert
    with check (auth.uid() = from_player);
create policy "transfers: parties can read"
    on pending_transfers for select
    using (auth.uid() = from_player or auth.uid() = to_player);
create policy "transfers: recipient can update"
    on pending_transfers for update
    using (auth.uid() = to_player);

-- ── Helper: increment silver safely ───────────────────────────────────────
create or replace function increment_silver(p_player_id uuid, p_amount bigint)
returns void language sql security definer as $$
    update player_currency
    set silver_marks = silver_marks + p_amount,
        updated_at   = now()
    where player_id = p_player_id;
$$;
