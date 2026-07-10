-- game_notices: system-generated notices (idle rewards, guild events, unlock announcements, etc.)
create table if not exists public.game_notices (
    id          uuid primary key default gen_random_uuid(),
    notice_type text        not null,  -- 'idle_reward' | 'guild_event' | 'unlock' | 'system'
    title       text        not null,
    body        text        not null,
    icon_key    text,                  -- optional: maps to a sprite name client-side
    expires_at  timestamptz,           -- null = never expires
    created_at  timestamptz not null default now()
);

-- player_notice_state: tracks read/dismissed per player
create table if not exists public.player_notice_state (
    id          uuid primary key default gen_random_uuid(),
    player_id   uuid        not null references auth.users(id) on delete cascade,
    notice_id   uuid        not null references public.game_notices(id) on delete cascade,
    read_at     timestamptz,
    dismissed   boolean     not null default false,
    created_at  timestamptz not null default now(),
    unique(player_id, notice_id)
);

-- RLS
alter table public.game_notices        enable row level security;
alter table public.player_notice_state enable row level security;

-- Anyone authenticated can read notices
create policy "notices_read" on public.game_notices
    for select using (auth.role() = 'authenticated');

-- Players manage their own state
create policy "notice_state_own" on public.player_notice_state
    for all using (player_id = auth.uid());

-- Indexes
create index if not exists idx_notice_state_player on public.player_notice_state(player_id);
create index if not exists idx_notice_state_unread  on public.player_notice_state(player_id, dismissed) where dismissed = false;
