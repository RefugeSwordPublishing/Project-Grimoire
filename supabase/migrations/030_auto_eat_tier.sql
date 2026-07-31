-- Project Grimoire, Royal Merchant auto-eat tier (Migration 030)
-- consumables-spec.md: the idle auto-eat upgrade tier bought from the Royal Merchant. 0 = Free
-- (25% HP, lowest quality, 2s, 1/encounter); 1-4 are the paid upgrades. Read by CombatManager.
alter table player_settings add column if not exists auto_eat_tier int not null default 0;
