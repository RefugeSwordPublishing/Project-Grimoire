-- Inventory quality flag
--
-- Quality became an INSTANCE flag on each inventory stack (a Crude and a Rough Longsword can coexist
-- in the bag), so the inventory key must include quality. Previously the primary key was
-- (player_id, item_id), which could only hold one row per item and would silently collapse
-- different-quality stacks into one on save.
--
-- This adds a quality column (0 = Crude, 1 = Rough, 2 = Refined, 3 = Pristine, 4 = Masterwork,
-- 5 = Legendary) and widens the primary key to (player_id, item_id, quality). RLS is unchanged
-- (still "own rows only", auth.uid() = player_id).

alter table player_inventory
    add column if not exists quality integer not null default 0;

alter table player_inventory drop constraint if exists player_inventory_pkey;
alter table player_inventory add primary key (player_id, item_id, quality);
