-- Project Grimoire, Wayfarer's Exchange buy-order + auction transactions (Migration 022)
-- Run AFTER 021. The base tables exist since 004; 020 modernised the store side. This adds the
-- TRANSACTION RPCs that were never built: placing/filling buy orders with real escrow, and
-- bidding / buying out / closing auctions. All are server-authoritative and SECURITY DEFINER,
-- mirroring purchase_store_listing (020): they mutate player_currency / player_inventory and
-- return the caller's new balance for the client to adopt.
--
-- Currency: buy orders + auctions are Silver-Marks only (matching the as-built columns; the store
-- side is dual-currency). Wallet is player_currency, the table the Unity client reads/writes.
-- Inventory delivery targets player_inventory keyed (player_id, item_id, quality) per migration 021,
-- where quality is the integer flag (0=Crude .. 5=Legendary).
--
-- Fee model (unchanged): auction SALE takes the seller's guild tax (to the guild bank) or a 3%
-- system sink for solo sellers. BUY ORDERS are always 0% (the buyer already set the price).

-- ── Schema: quality on auctions/buy orders, buy-order expiry, auction ending-soon flag ─
alter table exchange_auctions   add column if not exists quality integer not null default 0;
alter table exchange_buy_orders  add column if not exists quality integer not null default 0;
alter table exchange_buy_orders  add column if not exists expires_at timestamptz default now() + interval '30 days';
alter table exchange_auctions    add column if not exists ending_soon_notified boolean not null default false;

-- ── Internal helpers ──────────────────────────────────────────────────────────
-- Credit Silver Marks to a wallet, creating the row if the player has none yet.
create or replace function _exchange_credit_sm(p_player uuid, p_amount bigint)
returns void language plpgsql security definer set search_path = public as $$
begin
    if p_amount <= 0 then return; end if;
    insert into player_currency (player_id, silver_marks)
        values (p_player, p_amount)
        on conflict (player_id) do update
            set silver_marks = player_currency.silver_marks + p_amount, updated_at = now();
end; $$;

-- Deliver items to a player's inventory (quality-aware key from migration 021).
create or replace function _exchange_deliver_item(p_player uuid, p_item text, p_quality integer, p_qty bigint)
returns void language plpgsql security definer set search_path = public as $$
begin
    if p_qty <= 0 then return; end if;
    insert into player_inventory (player_id, item_id, quality, quantity)
        values (p_player, p_item, coalesce(p_quality, 0), p_qty)
        on conflict (player_id, item_id, quality)
            do update set quantity = player_inventory.quantity + excluded.quantity;
end; $$;

-- The seller's sale fee: guild tax to their guild bank, else a 3% solo sink. Returns the fee.
create or replace function _exchange_sale_fee(p_seller uuid, p_total bigint)
returns bigint language plpgsql security definer set search_path = public as $$
declare v_guild uuid; v_rate float; v_fee bigint;
begin
    select guild_id into v_guild from guild_members where player_id = p_seller limit 1;
    if v_guild is not null then
        select tax_rate into v_rate from guilds where id = v_guild;
        v_fee := floor(p_total * coalesce(v_rate, 0) / 100.0);
        if v_fee > 0 then
            update guilds set bank_silver = bank_silver + v_fee where id = v_guild;
        end if;
    else
        v_fee := floor(p_total * 3.0 / 100.0);  -- solo system sink (credited nowhere)
    end if;
    return v_fee;
end; $$;

-- ── Buy orders ─────────────────────────────────────────────────────────────────
-- Place a buy order: escrow (price × qty) out of the buyer's wallet atomically, then insert.
-- Returns the order id and the buyer's new balance.
create or replace function place_buy_order(p_item_id text, p_quality integer, p_price bigint, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_buyer  uuid := auth.uid();
    v_escrow bigint;
    v_bal    bigint;
    v_id     uuid;
begin
    if p_price <= 0 or p_quantity <= 0 then raise exception 'bad_order'; end if;
    v_escrow := p_price * p_quantity;

    select silver_marks into v_bal from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    if v_bal < v_escrow then raise exception 'insufficient_funds'; end if;

    update player_currency set silver_marks = silver_marks - v_escrow, updated_at = now()
        where player_id = v_buyer;

    insert into exchange_buy_orders
        (buyer_id, item_id, quality, quantity, remaining_qty, price_per_unit, escrow_amount)
        values (v_buyer, p_item_id, coalesce(p_quality, 0), p_quantity, p_quantity, p_price, v_escrow)
        returning id into v_id;

    return json_build_object('order_id', v_id, 'buyer_silver', v_bal - v_escrow, 'escrow', v_escrow);
end; $$;

-- Fill a buy order: seller supplies p_quantity units. Releases escrow (0% fee) to the seller and
-- delivers the item to the BUYER's inventory (the buyer may be offline). The seller's own item is
-- removed client-side (inventory is client-authoritative), consistent with the store buy flow.
-- Returns the seller's proceeds + new balance and the order's remaining quantity.
create or replace function fulfill_buy_order(p_order_id uuid, p_seller_id uuid, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_order   exchange_buy_orders%rowtype;
    v_seller  uuid := auth.uid();
    v_pay     bigint;
    v_bal     bigint;
begin
    if p_quantity <= 0 then raise exception 'bad_quantity'; end if;

    select * into v_order from exchange_buy_orders where id = p_order_id for update;
    if not found then raise exception 'order_not_found'; end if;
    if v_order.cancelled_at is not null then raise exception 'order_inactive'; end if;
    if v_order.buyer_id = v_seller then raise exception 'cannot_fill_own'; end if;
    if v_order.remaining_qty < p_quantity then raise exception 'insufficient_remaining'; end if;

    v_pay := v_order.price_per_unit * p_quantity;  -- buy orders are always 0% fee

    -- Pay the seller from escrow; deliver the item to the buyer.
    perform _exchange_credit_sm(v_seller, v_pay);
    perform _exchange_deliver_item(v_order.buyer_id, v_order.item_id, v_order.quality, p_quantity);

    -- Draw down the order's remaining quantity + escrow; close it when fully filled.
    if v_order.remaining_qty - p_quantity <= 0 then
        update exchange_buy_orders
            set remaining_qty = 0, escrow_amount = 0, cancelled_at = now()
            where id = p_order_id;
    else
        update exchange_buy_orders
            set remaining_qty = remaining_qty - p_quantity,
                escrow_amount = escrow_amount - v_pay
            where id = p_order_id;
    end if;

    insert into exchange_sale_history (item_id, price, quantity)
        values (v_order.item_id, v_order.price_per_unit, p_quantity);

    select silver_marks into v_bal from player_currency where player_id = v_seller;
    return json_build_object(
        'item_id',       v_order.item_id,
        'quantity',      p_quantity,
        'proceeds',      v_pay,
        'seller_silver', coalesce(v_bal, v_pay),
        'remaining',     greatest(v_order.remaining_qty - p_quantity, 0)
    );
end; $$;

-- ── Auctions ─────────────────────────────────────────────────────────────────
-- Place a bid: escrow the bid out of the bidder's wallet, refund the previous high bidder their
-- escrow, and record the new high bid. Enforces the 5% minimum increment above the current bid
-- (or the starting bid for the first bid). Returns the new high bid + the bidder's balance.
create or replace function place_auction_bid(p_auction_id uuid, p_bid bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_a       exchange_auctions%rowtype;
    v_bidder  uuid := auth.uid();
    v_min     bigint;
    v_bal     bigint;
begin
    select * into v_a from exchange_auctions where id = p_auction_id for update;
    if not found then raise exception 'auction_not_found'; end if;
    if v_a.cancelled_at is not null or v_a.completed_at is not null then raise exception 'auction_inactive'; end if;
    if v_a.ends_at < now() then raise exception 'auction_ended'; end if;
    if v_a.seller_id = v_bidder then raise exception 'cannot_bid_own'; end if;

    -- Minimum acceptable bid: 5% over the current bid, or the starting bid if no bids yet.
    if v_a.current_bid > 0 then v_min := ceil(v_a.current_bid * 1.05); else v_min := v_a.starting_bid; end if;
    if p_bid < v_min then raise exception 'bid_too_low:%', v_min; end if;

    -- Escrow the new bid from the bidder.
    select silver_marks into v_bal from player_currency where player_id = v_bidder for update;
    if not found then raise exception 'bidder_no_wallet'; end if;
    if v_bal < p_bid then raise exception 'insufficient_funds'; end if;
    update player_currency set silver_marks = silver_marks - p_bid, updated_at = now()
        where player_id = v_bidder;

    -- Refund the previous high bidder (if any and different).
    if v_a.current_bidder is not null and v_a.current_bidder <> v_bidder then
        perform _exchange_credit_sm(v_a.current_bidder, v_a.current_bid);
    elsif v_a.current_bidder = v_bidder then
        perform _exchange_credit_sm(v_bidder, v_a.current_bid);  -- raising own bid: return the old escrow
    end if;

    update exchange_auctions
        set current_bid = p_bid, current_bidder = v_bidder, ending_soon_notified = false
        where id = p_auction_id;

    return json_build_object('current_bid', p_bid, 'bidder_silver', v_bal - p_bid);
end; $$;

-- Buy out an auction: pay the buyout price, refund any standing bidder, take the sale fee, pay the
-- seller, deliver the item to the buyer, and complete the auction. Returns the buyer's new balance.
create or replace function buy_auction_buyout(p_auction_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_a      exchange_auctions%rowtype;
    v_buyer  uuid := auth.uid();
    v_fee    bigint;
    v_bal    bigint;
begin
    select * into v_a from exchange_auctions where id = p_auction_id for update;
    if not found then raise exception 'auction_not_found'; end if;
    if v_a.cancelled_at is not null or v_a.completed_at is not null then raise exception 'auction_inactive'; end if;
    if v_a.ends_at < now() then raise exception 'auction_ended'; end if;
    if v_a.buyout_price is null or v_a.buyout_price <= 0 then raise exception 'no_buyout'; end if;
    if v_a.seller_id = v_buyer then raise exception 'cannot_buy_own'; end if;

    select silver_marks into v_bal from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    if v_bal < v_a.buyout_price then raise exception 'insufficient_funds'; end if;

    update player_currency set silver_marks = silver_marks - v_a.buyout_price, updated_at = now()
        where player_id = v_buyer;

    if v_a.current_bidder is not null then
        perform _exchange_credit_sm(v_a.current_bidder, v_a.current_bid);  -- return the outbid escrow
    end if;

    v_fee := _exchange_sale_fee(v_a.seller_id, v_a.buyout_price);
    perform _exchange_credit_sm(v_a.seller_id, v_a.buyout_price - v_fee);
    perform _exchange_deliver_item(v_buyer, v_a.item_id, v_a.quality, v_a.quantity);

    update exchange_auctions set completed_at = now(), current_bid = v_a.buyout_price,
                                 current_bidder = v_buyer where id = p_auction_id;
    insert into exchange_sale_history (item_id, price, quantity)
        values (v_a.item_id, v_a.buyout_price, v_a.quantity);

    return json_build_object(
        'item_id', v_a.item_id, 'quantity', v_a.quantity,
        'total', v_a.buyout_price, 'buyer_silver', v_bal - v_a.buyout_price
    );
end; $$;

-- ── Scheduled settlement ────────────────────────────────────────────────────────
-- Close every auction past ends_at: a bidder wins (pay seller minus fee, deliver to winner), or the
-- item returns to the seller if there were no bids. Run hourly by pg_cron. Returns rows settled.
create or replace function close_ended_auctions()
returns integer language plpgsql security definer set search_path = public as $$
declare v_a exchange_auctions%rowtype; v_fee bigint; v_count integer := 0;
begin
    for v_a in
        select * from exchange_auctions
        where completed_at is null and cancelled_at is null and ends_at < now()
        for update
    loop
        if v_a.current_bidder is not null then
            v_fee := _exchange_sale_fee(v_a.seller_id, v_a.current_bid);
            perform _exchange_credit_sm(v_a.seller_id, v_a.current_bid - v_fee);
            perform _exchange_deliver_item(v_a.current_bidder, v_a.item_id, v_a.quality, v_a.quantity);
            insert into exchange_sale_history (item_id, price, quantity)
                values (v_a.item_id, v_a.current_bid, v_a.quantity);
        else
            perform _exchange_deliver_item(v_a.seller_id, v_a.item_id, v_a.quality, v_a.quantity);
        end if;
        update exchange_auctions set completed_at = now() where id = v_a.id;
        v_count := v_count + 1;
    end loop;
    return v_count;
end; $$;

-- Sweep expired buy orders: refund the remaining escrow to the buyer, then cancel. Run daily.
create or replace function sweep_expired_buy_orders()
returns integer language plpgsql security definer set search_path = public as $$
declare v_o exchange_buy_orders%rowtype; v_count integer := 0;
begin
    for v_o in
        select * from exchange_buy_orders
        where cancelled_at is null and remaining_qty > 0
          and expires_at is not null and expires_at < now()
        for update
    loop
        perform _exchange_credit_sm(v_o.buyer_id, v_o.escrow_amount);
        update exchange_buy_orders set cancelled_at = now(), escrow_amount = 0 where id = v_o.id;
        v_count := v_count + 1;
    end loop;
    return v_count;
end; $$;

-- Enable pg_cron in the Supabase dashboard, then schedule once:
--   select cron.schedule('close-ended-auctions',    '0 * * * *', $$ select close_ended_auctions();    $$);
--   select cron.schedule('sweep-expired-buy-orders', '0 3 * * *', $$ select sweep_expired_buy_orders(); $$);
