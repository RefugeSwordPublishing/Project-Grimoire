-- Royal Merchant capacity unlocks (GM purchases). The purchase itself is charged + recorded for
-- idempotency by purchase_merchant_item (migration 031, appends to player_currency.merchant_purchases).
-- The live effect is mirrored on player_settings, alongside auto_eat_tier, so the client loads it with
-- the rest of its settings and each consuming system reads its cap bonus. Additive, safe defaults.

alter table player_settings
    add column if not exists auto_drink_mana          boolean not null default false, -- Arcanist idle auto-drink mana
    add column if not exists bonus_inventory_slots    integer not null default 0,     -- inventory packs (+10 / +25)
    add column if not exists bonus_exchange_slots     integer not null default 0,     -- extra active exchange listings (+1 / +3)
    add column if not exists bonus_daily_quest_slots  integer not null default 0,     -- extra daily quest slots (+1 / +2)
    add column if not exists bonus_weekly_quest_slots integer not null default 0,     -- extra weekly quest slot (+1)
    add column if not exists bonus_slaying_slots      integer not null default 0;     -- extra Slaying task slots (5 / 6 / 7)
