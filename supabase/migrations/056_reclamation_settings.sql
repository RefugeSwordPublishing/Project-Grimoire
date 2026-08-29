-- Project Grimoire, Reclamation unlocks (Migration 056)
-- material-recycling-spec Stage 2. Permanent Essence-purchased unlocks from the Royal Merchant Reclamation
-- category, stored on player_settings (the SettingsManager home): the Salvager's Satchel (+15% recycle
-- essence yield) and the Bulk Reclaim Filter (unlocks auto-recycle category filters, Stage 4). Both are
-- owned/not-owned flags, so the flag itself provides purchase idempotency (no re-buy).
alter table player_settings add column if not exists salvager_satchel    boolean not null default false;
alter table player_settings add column if not exists bulk_reclaim_filter boolean not null default false;
