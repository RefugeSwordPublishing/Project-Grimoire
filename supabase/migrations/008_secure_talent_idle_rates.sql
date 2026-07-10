-- Project Grimoire — Secure talent_idle_rates + legacy cleanup (Migration 008)
-- Run AFTER 002_auth_schema.sql. Closes gaps left by the 001→002 transition:
--   • 002 recreates talent_idle_rates but never enables RLS on it.
--   • 001's increment_silver_marks() references players.silver_marks, a column
--     that no longer exists after 002 (currency moved to player_currency).

-- ── talent_idle_rates: global read-only reference data ──────────────────────
-- Non-sensitive server-tuned idle rates. Everyone may read; only the service
-- role (Edge Functions) may write, since no write policy is granted.
alter table talent_idle_rates enable row level security;

drop policy if exists "talent_idle_rates: public read" on talent_idle_rates;
create policy "talent_idle_rates: public read"
    on talent_idle_rates for select
    using (true);

-- ── Drop orphaned legacy function ───────────────────────────────────────────
drop function if exists increment_silver_marks(uuid, bigint);
