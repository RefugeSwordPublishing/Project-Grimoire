-- Project Grimoire, Royal Merchant daily sell-cap expansion (Migration 063)
-- BUG-089. A per-player tier that raises the SOFT daily buyback cap on the Traveling Merchant:
-- 0 = 500 SM/day (base), 1 = 1,000, 2 = 2,000. Over-cap sales still pay the reduced OverCapRate;
-- this only lifts the amount you can sell at full rate before the soft cap kicks in.
-- Stored on player_settings (the SettingsManager home) alongside the other Royal Merchant capacity
-- unlocks. The purchase itself is recorded in merchant_purchases via the existing
-- purchase_merchant_item RPC (item ids daily_cap_1000 / daily_cap_2000), so no RPC change is needed.
alter table player_settings add column if not exists merchant_daily_cap_tier int not null default 0;
