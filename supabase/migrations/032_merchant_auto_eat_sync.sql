-- Project Grimoire, Royal Merchant auto-eat tier sync + backfill (Migration 032). Run AFTER 031.
--
-- Fixes a two-sources-of-truth desync. purchase_merchant_item (031) records the unlock in
-- players.merchant_purchases (server-authoritative, reliable), but the auto-eat TIER that BOTH the
-- store's "Owned" state AND the idle auto-eat effect read lives in player_settings.auto_eat_tier,
-- which the client wrote separately via a PATCH that silently no-ops when no player_settings row
-- exists. Result: the ledger says owned (rebuy -> already_purchased) while the tier stays 0, so the
-- item shows "Buy" and buying fails. This makes the RPC the single authority: it sets the tier
-- atomically with the purchase (upsert, so a missing row is created), and we backfill any row that
-- already drifted.

-- ── 1) Backfill existing purchases into the tier column (repairs already-stuck rows) ──
-- Only auto_eat_t1..t3 are auto-eat tiers; auto_eat_t4 is the separate Auto-Drink (not this column).
insert into player_settings (player_id, auto_eat_tier)
select p.id,
       greatest(
         case when 'auto_eat_t1' = any(p.merchant_purchases) then 1 else 0 end,
         case when 'auto_eat_t2' = any(p.merchant_purchases) then 2 else 0 end,
         case when 'auto_eat_t3' = any(p.merchant_purchases) then 3 else 0 end
       )
from players p
where p.merchant_purchases && array['auto_eat_t1','auto_eat_t2','auto_eat_t3']
on conflict (player_id) do update
    set auto_eat_tier = greatest(player_settings.auto_eat_tier, excluded.auto_eat_tier);

-- ── 2) Purchase RPC now sets the tier server-side, atomically with the ledger write ──
create or replace function purchase_merchant_item(p_item_id text, p_gm_cost bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_player  uuid := auth.uid();
    v_gold    bigint;
    v_already boolean;
    v_tier    int;
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

    -- If this is an auto-eat tier (auto_eat_t1..t3), advance player_settings.auto_eat_tier to it.
    -- Upsert so the row is created when missing; greatest() so a re-applied lower tier can't regress it.
    if p_item_id ~ '^auto_eat_t[1-3]$' then
        v_tier := substring(p_item_id from '([0-9]+)$')::int;
        insert into player_settings (player_id, auto_eat_tier)
        values (v_player, v_tier)
        on conflict (player_id) do update
            set auto_eat_tier = greatest(player_settings.auto_eat_tier, excluded.auto_eat_tier);
    end if;

    return json_build_object(
        'success',    true,
        'item_id',    p_item_id,
        'buyer_gold', v_gold - p_gm_cost
    );
end;
$$;
