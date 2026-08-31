-- 0.1.4 Traveling Merchant + Gold-to-Silver conversion (traveling-merchant-spec.md v1.0).
-- Retires the recycle-to-Essence system. Client-authoritative selling (matches the existing
-- currency/inventory model); the server only holds the persisted daily-buyback cap counters.

-- Daily buyback cap tracking (spec 8): 500 SM/day, reset 00:00 UTC. Lives beside the wallet.
alter table player_currency add column if not exists merchant_sold_today int not null default 0;
alter table player_currency add column if not exists merchant_reset_at   timestamptz;

-- Retire Reclaimed Essence (spec 7.1): convert any outstanding balance to Silver at 2 SM each
-- (generous; the Reclamation UI was never baked so no meaningful balance can exist), then zero it.
-- Keep the column for one release before dropping it, so a missed code path is recoverable.
update player_currency
set    silver_marks      = silver_marks + (reclaimed_essence * 2),
       reclaimed_essence = 0
where  reclaimed_essence > 0;

-- The four migrated Reclamation items reuse existing player_settings columns rather than new ones:
--   auto_recycle_enabled     -> Auto-Sell enabled
--   auto_recycle_max_quality -> Auto-Sell max quality
--   salvager_satchel         -> Merchant's Favor (+10% merchant offers)
--   bulk_reclaim_filter      -> Bulk Sell Filter (category filters in bulk sell)
-- No settings-column migration needed; the client reinterprets them (see SettingsManager).
