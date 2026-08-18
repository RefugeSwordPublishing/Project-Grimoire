-- Project Grimoire, persist inventory slot-expansion purchases (Migration 033). Run AFTER 032.
--
-- The Royal-Merchant-style "expand inventory slots" purchase was in-memory only: neither the deducted
-- silver nor the expansion count was saved, so on reload the bag reset to 70 slots and the next cost
-- reset to 500 SM (the "it forgot I bought the upgrade" bug). This column stores how many +10-slot
-- expansions the player owns; the client restores it before building the bag and writes it (alongside
-- the currency deduction) on each purchase.
alter table player_currency
    add column if not exists inventory_expansions int not null default 0;
