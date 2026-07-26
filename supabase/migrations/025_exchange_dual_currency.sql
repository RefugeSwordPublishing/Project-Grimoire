-- Project Grimoire, Wayfarer's Exchange dual-currency buy orders + single-currency auctions (025)
-- Run AFTER 024.
--
-- Model (per design): sell orders already dual (SM+GM). This makes BUY ORDERS dual as well, and
-- gives each AUCTION a single chosen currency (SM or GM) so bids stay rankable. All RPCs return both
-- wallet balances so the client can adopt whichever moved.

-- ── Schema ──────────────────────────────────────────────────────────────────────
alter table exchange_buy_orders add column if not exists offer_gm  bigint not null default 0;
alter table exchange_buy_orders add column if not exists escrow_gm bigint not null default 0;
alter table exchange_auctions   add column if not exists currency  text   not null default 'SM';

-- Credit a wallet in a given currency (SM/GM), creating the row if needed.
create or replace function _wallet_credit(p_player uuid, p_cur text, p_amt bigint)
returns void language plpgsql security definer set search_path = public as $$
begin
    if p_amt <= 0 then return; end if;
    if p_cur = 'GM' then
        insert into player_currency (player_id, gold_marks) values (p_player, p_amt)
            on conflict (player_id) do update set gold_marks = player_currency.gold_marks + p_amt, updated_at = now();
    else
        insert into player_currency (player_id, silver_marks) values (p_player, p_amt)
            on conflict (player_id) do update set silver_marks = player_currency.silver_marks + p_amt, updated_at = now();
    end if;
end; $$;

-- ── Buy orders (dual currency) ───────────────────────────────────────────────────
create or replace function place_buy_order(p_item_id text, p_quality integer,
                                            p_price_sm bigint, p_price_gm bigint, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_buyer  uuid := auth.uid();
    v_esm    bigint; v_egm bigint;
    v_sm     bigint; v_gm  bigint;
    v_id     uuid;
begin
    if p_quantity <= 0 or (coalesce(p_price_sm,0) <= 0 and coalesce(p_price_gm,0) <= 0) then
        raise exception 'bad_order'; end if;
    v_esm := coalesce(p_price_sm,0) * p_quantity;
    v_egm := coalesce(p_price_gm,0) * p_quantity;

    select silver_marks, gold_marks into v_sm, v_gm from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    if v_sm < v_esm or v_gm < v_egm then raise exception 'insufficient_funds'; end if;

    update player_currency set silver_marks = silver_marks - v_esm, gold_marks = gold_marks - v_egm,
                               updated_at = now() where player_id = v_buyer;

    insert into exchange_buy_orders
        (buyer_id, item_id, quality, quantity, remaining_qty, price_per_unit, offer_gm, escrow_amount, escrow_gm)
        values (v_buyer, p_item_id, coalesce(p_quality,0), p_quantity, p_quantity,
                coalesce(p_price_sm,0), coalesce(p_price_gm,0), v_esm, v_egm)
        returning id into v_id;

    return json_build_object('order_id', v_id, 'buyer_silver', v_sm - v_esm, 'buyer_gold', v_gm - v_egm);
end; $$;

create or replace function fulfill_buy_order(p_order_id uuid, p_seller_id uuid, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_o exchange_buy_orders%rowtype; v_seller uuid := auth.uid();
    v_psm bigint; v_pgm bigint; v_sm bigint; v_gm bigint;
begin
    if p_quantity <= 0 then raise exception 'bad_quantity'; end if;
    select * into v_o from exchange_buy_orders where id = p_order_id for update;
    if not found then raise exception 'order_not_found'; end if;
    if v_o.cancelled_at is not null then raise exception 'order_inactive'; end if;
    if v_o.buyer_id = v_seller then raise exception 'cannot_fill_own'; end if;
    if v_o.remaining_qty < p_quantity then raise exception 'insufficient_remaining'; end if;

    v_psm := v_o.price_per_unit * p_quantity;   -- 0% fee on buy orders
    v_pgm := v_o.offer_gm       * p_quantity;
    perform _wallet_credit(v_seller, 'SM', v_psm);
    perform _wallet_credit(v_seller, 'GM', v_pgm);
    perform _exchange_deliver_item(v_o.buyer_id, v_o.item_id, v_o.quality, p_quantity);

    if v_o.remaining_qty - p_quantity <= 0 then
        update exchange_buy_orders set remaining_qty = 0, escrow_amount = 0, escrow_gm = 0, cancelled_at = now()
            where id = p_order_id;
    else
        update exchange_buy_orders set remaining_qty = remaining_qty - p_quantity,
            escrow_amount = escrow_amount - v_psm, escrow_gm = escrow_gm - v_pgm where id = p_order_id;
    end if;

    insert into exchange_sale_history (item_id, price, quantity) values (v_o.item_id, v_o.price_per_unit, p_quantity);
    select silver_marks, gold_marks into v_sm, v_gm from player_currency where player_id = v_seller;
    return json_build_object('item_id', v_o.item_id, 'quantity', p_quantity,
        'seller_silver', coalesce(v_sm,0), 'seller_gold', coalesce(v_gm,0),
        'remaining', greatest(v_o.remaining_qty - p_quantity, 0));
end; $$;

-- Refund BOTH escrows on cancel (supersedes the SM-only 004 version).
create or replace function cancel_buy_order(p_order_id uuid, p_player_id uuid)
returns bigint language plpgsql security definer set search_path = public as $$
declare v_o exchange_buy_orders%rowtype;
begin
    select * into v_o from exchange_buy_orders where id = p_order_id and buyer_id = p_player_id
        and cancelled_at is null for update;
    if not found then return 0; end if;
    update exchange_buy_orders set cancelled_at = now(), escrow_amount = 0, escrow_gm = 0 where id = p_order_id;
    perform _wallet_credit(p_player_id, 'SM', v_o.escrow_amount);
    perform _wallet_credit(p_player_id, 'GM', v_o.escrow_gm);
    return v_o.escrow_amount;
end; $$;

create or replace function sweep_expired_buy_orders()
returns integer language plpgsql security definer set search_path = public as $$
declare v_o exchange_buy_orders%rowtype; v_count integer := 0;
begin
    for v_o in select * from exchange_buy_orders
        where cancelled_at is null and remaining_qty > 0 and expires_at is not null and expires_at < now()
        for update
    loop
        perform _wallet_credit(v_o.buyer_id, 'SM', v_o.escrow_amount);
        perform _wallet_credit(v_o.buyer_id, 'GM', v_o.escrow_gm);
        update exchange_buy_orders set cancelled_at = now(), escrow_amount = 0, escrow_gm = 0 where id = v_o.id;
        v_count := v_count + 1;
    end loop;
    return v_count;
end; $$;

-- ── Auctions (single currency, chosen per auction) ───────────────────────────────
create or replace function place_auction_bid(p_auction_id uuid, p_bid bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_a exchange_auctions%rowtype; v_bidder uuid := auth.uid();
    v_min bigint; v_sm bigint; v_gm bigint; v_bal bigint;
begin
    select * into v_a from exchange_auctions where id = p_auction_id for update;
    if not found then raise exception 'auction_not_found'; end if;
    if v_a.cancelled_at is not null or v_a.completed_at is not null then raise exception 'auction_inactive'; end if;
    if v_a.ends_at < now() then raise exception 'auction_ended'; end if;
    if v_a.seller_id = v_bidder then raise exception 'cannot_bid_own'; end if;

    if v_a.current_bid > 0 then v_min := ceil(v_a.current_bid * 1.05); else v_min := v_a.starting_bid; end if;
    if p_bid < v_min then raise exception 'bid_too_low:%', v_min; end if;

    select silver_marks, gold_marks into v_sm, v_gm from player_currency where player_id = v_bidder for update;
    if not found then raise exception 'bidder_no_wallet'; end if;
    v_bal := case when v_a.currency = 'GM' then v_gm else v_sm end;
    if v_bal < p_bid then raise exception 'insufficient_funds'; end if;
    if v_a.currency = 'GM' then
        update player_currency set gold_marks = gold_marks - p_bid, updated_at = now() where player_id = v_bidder;
    else
        update player_currency set silver_marks = silver_marks - p_bid, updated_at = now() where player_id = v_bidder;
    end if;

    if v_a.current_bidder is not null then
        perform _wallet_credit(v_a.current_bidder, v_a.currency, v_a.current_bid);  -- refund prior (or own) escrow
    end if;

    update exchange_auctions set current_bid = p_bid, current_bidder = v_bidder, ending_soon_notified = false
        where id = p_auction_id;

    return json_build_object('current_bid', p_bid, 'currency', v_a.currency,
        'bidder_silver', case when v_a.currency = 'GM' then v_sm else v_sm - p_bid end,
        'bidder_gold',   case when v_a.currency = 'GM' then v_gm - p_bid else v_gm end);
end; $$;

create or replace function buy_auction_buyout(p_auction_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare v_a exchange_auctions%rowtype; v_buyer uuid := auth.uid(); v_fee bigint; v_sm bigint; v_gm bigint; v_bal bigint;
begin
    select * into v_a from exchange_auctions where id = p_auction_id for update;
    if not found then raise exception 'auction_not_found'; end if;
    if v_a.cancelled_at is not null or v_a.completed_at is not null then raise exception 'auction_inactive'; end if;
    if v_a.ends_at < now() then raise exception 'auction_ended'; end if;
    if v_a.buyout_price is null or v_a.buyout_price <= 0 then raise exception 'no_buyout'; end if;
    if v_a.seller_id = v_buyer then raise exception 'cannot_buy_own'; end if;

    select silver_marks, gold_marks into v_sm, v_gm from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    v_bal := case when v_a.currency = 'GM' then v_gm else v_sm end;
    if v_bal < v_a.buyout_price then raise exception 'insufficient_funds'; end if;
    if v_a.currency = 'GM' then
        update player_currency set gold_marks = gold_marks - v_a.buyout_price, updated_at = now() where player_id = v_buyer;
    else
        update player_currency set silver_marks = silver_marks - v_a.buyout_price, updated_at = now() where player_id = v_buyer;
    end if;

    if v_a.current_bidder is not null then perform _wallet_credit(v_a.current_bidder, v_a.currency, v_a.current_bid); end if;

    v_fee := _exchange_sale_fee(v_a.seller_id, v_a.buyout_price);  -- fee is in the auction's currency units
    perform _wallet_credit(v_a.seller_id, v_a.currency, v_a.buyout_price - v_fee);
    perform _exchange_deliver_item(v_buyer, v_a.item_id, v_a.quality, v_a.quantity);

    update exchange_auctions set completed_at = now(), current_bid = v_a.buyout_price, current_bidder = v_buyer
        where id = p_auction_id;
    insert into exchange_sale_history (item_id, price, quantity) values (v_a.item_id, v_a.buyout_price, v_a.quantity);

    return json_build_object('item_id', v_a.item_id, 'quantity', v_a.quantity, 'currency', v_a.currency,
        'buyer_silver', case when v_a.currency = 'GM' then v_sm else v_sm - v_a.buyout_price end,
        'buyer_gold',   case when v_a.currency = 'GM' then v_gm - v_a.buyout_price else v_gm end);
end; $$;

create or replace function close_ended_auctions()
returns integer language plpgsql security definer set search_path = public as $$
declare v_a exchange_auctions%rowtype; v_fee bigint; v_count integer := 0;
begin
    for v_a in select * from exchange_auctions
        where completed_at is null and cancelled_at is null and ends_at < now() for update
    loop
        if v_a.current_bidder is not null then
            v_fee := _exchange_sale_fee(v_a.seller_id, v_a.current_bid);
            perform _wallet_credit(v_a.seller_id, v_a.currency, v_a.current_bid - v_fee);
            perform _exchange_deliver_item(v_a.current_bidder, v_a.item_id, v_a.quality, v_a.quantity);
            insert into exchange_sale_history (item_id, price, quantity) values (v_a.item_id, v_a.current_bid, v_a.quantity);
        else
            perform _exchange_deliver_item(v_a.seller_id, v_a.item_id, v_a.quality, v_a.quantity);
        end if;
        update exchange_auctions set completed_at = now() where id = v_a.id;
        v_count := v_count + 1;
    end loop;
    return v_count;
end; $$;

create or replace function cancel_auction(p_auction_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare v_a exchange_auctions%rowtype; v_seller uuid := auth.uid();
begin
    select * into v_a from exchange_auctions where id = p_auction_id for update;
    if not found then raise exception 'auction_not_found'; end if;
    if v_a.seller_id <> v_seller then raise exception 'not_owner'; end if;
    if v_a.cancelled_at is not null or v_a.completed_at is not null then raise exception 'auction_inactive'; end if;
    if v_a.current_bidder is not null then perform _wallet_credit(v_a.current_bidder, v_a.currency, v_a.current_bid); end if;
    update exchange_auctions set cancelled_at = now() where id = p_auction_id;
    perform _exchange_deliver_item(v_seller, v_a.item_id, v_a.quality, v_a.quantity);
    return json_build_object('item_id', v_a.item_id, 'quantity', v_a.quantity, 'quality', v_a.quality);
end; $$;
