-- Tracks every notification dispatched per player.
-- Used by the Edge Function to enforce:
--   - 30-minute cooldown between any two notifications per player
--   - Hard cap: max 3 notifications per 4-hour window per player

create table if not exists public.notification_log (
    id          uuid        primary key default gen_random_uuid(),
    player_id   uuid        not null references auth.users(id) on delete cascade,
    priority    smallint    not null,   -- 1=P1 2=P2 3=P3 4=P4
    title       text        not null,
    body        text        not null,
    sent_at     timestamptz not null default now()
);

alter table public.notification_log enable row level security;

-- Players can read their own log (useful for client-side dedup if needed)
create policy "notif_log_own_read" on public.notification_log
    for select using (player_id = auth.uid());

-- Only service role can insert (Edge Function uses service key)
-- No insert policy needed for anon/authenticated — Edge Function bypasses RLS

create index if not exists idx_notif_log_player_sent
    on public.notification_log(player_id, sent_at desc);
