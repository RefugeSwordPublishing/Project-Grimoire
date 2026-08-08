-- Project Grimoire, Royal Merchant server-authoritative GM purchases (Migration 031)
-- Adds the purchase RPC + the one-time-unlock idempotency ledger for the Royal Merchant store
-- (royal-merchant-store-spec.md S9). Run AFTER 030.
--
-- CURRENCY SPLIT, read before editing: the game has TWO gold_marks columns, players.gold_marks
-- (migration 001) and player_currency.gold_marks (migration 002). The Unity client reads and writes
-- player_currency (PlayerDataService.LoadCurrency/SaveCurrency), and every exchange RPC (020, 025)
-- deducts from player_currency. players.gold_marks is the stale side of a known split bug. The store
-- spec's example RPC (S9.1) deducted from players.gold_marks, which would charge the WRONG wallet, the
-- client would never see the deduction and the GM would reappear on next login. This RPC therefore
-- deducts from player_currency, exactly like the exchange RPCs. Do NOT copy the players.* pattern here.

-- Idempotency ledger for one-time unlocks (auto-eat/drink tiers, slot packs, quest/task slots).
-- Attempting to buy an item already in this array raises 'already_purchased', so no double-charge.
alter table players
    add column if not exists merchant_purchases text[] not null default '{}';

-- ── Purchase a Royal Merchant GM item (server-authoritative, deducts player_currency) ─
create or replace function purchase_merchant_item(p_item_id text, p_gm_cost bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_player  uuid := auth.uid();
    v_gold    bigint;
    v_already boolean;
begin
    if v_player is null then raise exception 'not_authenticated'; end if;
    if p_item_id is null or length(p_item_id) = 0 then raise exception 'bad_item'; end if;
    if p_gm_cost is null or p_gm_cost < 0 then raise exception 'bad_cost'; end if;

    -- One-time unlocks cannot be re-bought.
    select p_item_id = any(coalesce(merchant_purchases, '{}')) into v_already
        from players where id = v_player;
    if not found then raise exception 'no_player'; end if;
    if v_already then raise exception 'already_purchased'; end if;

    -- Deduct from the client-authoritative wallet (player_currency), NOT players.gold_marks.
    select gold_marks into v_gold from player_currency where player_id = v_player for update;
    if not found then raise exception 'no_wallet'; end if;
    if v_gold < p_gm_cost then raise exception 'insufficient_gm'; end if;

    update player_currency
        set gold_marks = gold_marks - p_gm_cost,
            updated_at = now()
        where player_id = v_player;

    update players
        set merchant_purchases = array_append(merchant_purchases, p_item_id)
        where id = v_player;

    return json_build_object(
        'success',    true,
        'item_id',    p_item_id,
        'buyer_gold', v_gold - p_gm_cost
    );
end;
$$;
