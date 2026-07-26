-- Project Grimoire, pending earnings + collect-at-merchant (Migration 026)
-- Run AFTER 025.
--
-- Sale proceeds no longer credit the seller's wallet directly (which the client-authoritative
-- currency could overwrite, so sellers "lost" earnings). Instead a sale accrues to a server-side
-- pending bucket per marketplace ('exchange' | 'guild'); the seller COLLECTS at that merchant, a
-- client-initiated action that safely moves pending -> player_currency and returns the amount. This
-- also fixes the guild merchant, whose buy RPC wrote players.* (a different table than the client's
-- player_currency): the buyer now pays from player_currency and the seller's proceeds go to pending.

create table if not exists exchange_pending_earnings (
    player_id    uuid not null references players(id) on delete cascade,
    source       text not null,             -- 'exchange' | 'guild'
    silver_marks bigint not null default 0,
    gold_marks   bigint not null default 0,
    updated_at   timestamptz not null default now(),
    primary key (player_id, source)
);
alter table exchange_pending_earnings enable row level security;
create policy "pending: own read" on exchange_pending_earnings for select using (auth.uid() = player_id);

-- Accrue a seller's proceeds to their pending bucket.
create or replace function _add_pending(p_player uuid, p_source text, p_sm bigint, p_gm bigint)
returns void language plpgsql security definer set search_path = public as $$
begin
    if coalesce(p_sm,0) <= 0 and coalesce(p_gm,0) <= 0 then return; end if;
    insert into exchange_pending_earnings (player_id, source, silver_marks, gold_marks)
        values (p_player, p_source, greatest(coalesce(p_sm,0),0), greatest(coalesce(p_gm,0),0))
        on conflict (player_id, source) do update
            set silver_marks = exchange_pending_earnings.silver_marks + greatest(coalesce(p_sm,0),0),
                gold_marks   = exchange_pending_earnings.gold_marks   + greatest(coalesce(p_gm,0),0),
                updated_at = now();
end; $$;

-- Collect: move pending[source] into the wallet, clear it, return the collected amount + new balance.
create or replace function collect_earnings(p_source text)
returns json language plpgsql security definer set search_path = public as $$
declare v_p uuid := auth.uid(); v_sm bigint := 0; v_gm bigint := 0; v_bs bigint; v_bg bigint;
begin
    select silver_marks, gold_marks into v_sm, v_gm from exchange_pending_earnings
        where player_id = v_p and source = p_source for update;
    if not found or (coalesce(v_sm,0) <= 0 and coalesce(v_gm,0) <= 0) then
        return json_build_object('collected_sm', 0, 'collected_gm', 0);
    end if;

    update exchange_pending_earnings set silver_marks = 0, gold_marks = 0, updated_at = now()
        where player_id = v_p and source = p_source;
    insert into player_currency (player_id, silver_marks, gold_marks) values (v_p, v_sm, v_gm)
        on conflict (player_id) do update
            set silver_marks = player_currency.silver_marks + v_sm,
                gold_marks   = player_currency.gold_marks   + v_gm, updated_at = now();
    select silver_marks, gold_marks into v_bs, v_bg from player_currency where player_id = v_p;
    return json_build_object('collected_sm', v_sm, 'collected_gm', v_gm, 'silver', v_bs, 'gold', v_bg);
end; $$;

-- ── Route every sale's SELLER proceeds to pending ────────────────────────────────

-- Store purchase (was: direct credit to seller player_currency).
create or replace function purchase_store_listing(p_listing_id uuid, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_listing exchange_store_listings%rowtype; v_buyer uuid := auth.uid();
    v_total_sm bigint; v_total_gm bigint; v_fee_sm bigint := 0; v_fee_gm bigint := 0;
    v_guild_id uuid; v_rate float; v_bsilver bigint; v_bgold bigint;
begin
    if p_quantity is null or p_quantity <= 0 then raise exception 'bad_quantity'; end if;
    select * into v_listing from exchange_store_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_listing.cancelled_at is not null then raise exception 'listing_inactive'; end if;
    if v_listing.expires_at is not null and v_listing.expires_at < now() then raise exception 'listing_expired'; end if;
    if v_listing.seller_id = v_buyer then raise exception 'cannot_buy_own'; end if;
    if v_listing.quantity < p_quantity then raise exception 'insufficient_quantity'; end if;

    v_total_sm := v_listing.price_per_unit * p_quantity;
    v_total_gm := v_listing.price_gm       * p_quantity;

    select guild_id into v_guild_id from guild_members where player_id = v_listing.seller_id limit 1;
    if v_guild_id is not null then
        select tax_rate into v_rate from guilds where id = v_guild_id;
        v_fee_sm := floor(v_total_sm * coalesce(v_rate,0) / 100.0);
        v_fee_gm := floor(v_total_gm * coalesce(v_rate,0) / 100.0);
    else
        v_fee_sm := floor(v_total_sm * 3.0 / 100.0);
        v_fee_gm := floor(v_total_gm * 3.0 / 100.0);
    end if;

    select silver_marks, gold_marks into v_bsilver, v_bgold from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    if v_bsilver < v_total_sm or v_bgold < v_total_gm then raise exception 'insufficient_funds'; end if;

    update player_currency set silver_marks = silver_marks - v_total_sm, gold_marks = gold_marks - v_total_gm,
                               updated_at = now() where player_id = v_buyer;

    -- Seller proceeds accrue to pending (collected at the Exchange), not straight to the wallet.
    perform _add_pending(v_listing.seller_id, 'exchange', v_total_sm - v_fee_sm, v_total_gm - v_fee_gm);
    if v_guild_id is not null and (v_fee_sm > 0 or v_fee_gm > 0) then
        update guilds set bank_silver = bank_silver + v_fee_sm, bank_gold = bank_gold + v_fee_gm where id = v_guild_id;
    end if;

    if v_listing.quantity - p_quantity <= 0 then delete from exchange_store_listings where id = p_listing_id;
    else update exchange_store_listings set quantity = quantity - p_quantity where id = p_listing_id; end if;

    insert into exchange_sale_history (item_id, price, quantity) values (v_listing.item_id, v_listing.price_per_unit, p_quantity);
    return json_build_object('item_id', v_listing.item_id, 'quantity', p_quantity, 'quality', v_listing.quality,
        'buyer_silver', v_bsilver - v_total_sm, 'buyer_gold', v_bgold - v_total_gm);
end; $$;

-- Buy order fill: seller's proceeds -> pending (the seller collects later).
create or replace function fulfill_buy_order(p_order_id uuid, p_seller_id uuid, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare v_o exchange_buy_orders%rowtype; v_seller uuid := auth.uid(); v_psm bigint; v_pgm bigint; v_sm bigint; v_gm bigint;
begin
    if p_quantity <= 0 then raise exception 'bad_quantity'; end if;
    select * into v_o from exchange_buy_orders where id = p_order_id for update;
    if not found then raise exception 'order_not_found'; end if;
    if v_o.cancelled_at is not null then raise exception 'order_inactive'; end if;
    if v_o.buyer_id = v_seller then raise exception 'cannot_fill_own'; end if;
    if v_o.remaining_qty < p_quantity then raise exception 'insufficient_remaining'; end if;

    v_psm := v_o.price_per_unit * p_quantity; v_pgm := v_o.offer_gm * p_quantity;
    perform _add_pending(v_seller, 'exchange', v_psm, v_pgm);
    perform _exchange_deliver_item(v_o.buyer_id, v_o.item_id, v_o.quality, p_quantity);

    if v_o.remaining_qty - p_quantity <= 0 then
        update exchange_buy_orders set remaining_qty = 0, escrow_amount = 0, escrow_gm = 0, cancelled_at = now() where id = p_order_id;
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

-- Auction buyout: seller proceeds -> pending (buyer still pays + adopts + gets the item).
create or replace function buy_auction_buyout(p_auction_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare v_a exchange_auctions%rowtype; v_buyer uuid := auth.uid(); v_fee bigint; v_sm bigint; v_gm bigint; v_bal bigint; v_net bigint;
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
    if v_a.currency = 'GM' then update player_currency set gold_marks = gold_marks - v_a.buyout_price, updated_at = now() where player_id = v_buyer;
    else update player_currency set silver_marks = silver_marks - v_a.buyout_price, updated_at = now() where player_id = v_buyer; end if;

    if v_a.current_bidder is not null then perform _wallet_credit(v_a.current_bidder, v_a.currency, v_a.current_bid); end if;

    v_fee := _exchange_sale_fee(v_a.seller_id, v_a.buyout_price);
    v_net := v_a.buyout_price - v_fee;
    if v_a.currency = 'GM' then perform _add_pending(v_a.seller_id, 'exchange', 0, v_net);
    else perform _add_pending(v_a.seller_id, 'exchange', v_net, 0); end if;
    perform _exchange_deliver_item(v_buyer, v_a.item_id, v_a.quality, v_a.quantity);

    update exchange_auctions set completed_at = now(), current_bid = v_a.buyout_price, current_bidder = v_buyer where id = p_auction_id;
    insert into exchange_sale_history (item_id, price, quantity) values (v_a.item_id, v_a.buyout_price, v_a.quantity);
    return json_build_object('item_id', v_a.item_id, 'quantity', v_a.quantity, 'currency', v_a.currency,
        'buyer_silver', case when v_a.currency = 'GM' then v_sm else v_sm - v_a.buyout_price end,
        'buyer_gold',   case when v_a.currency = 'GM' then v_gm - v_a.buyout_price else v_gm end);
end; $$;

-- Auction close (cron): winner's payment -> seller pending.
create or replace function close_ended_auctions()
returns integer language plpgsql security definer set search_path = public as $$
declare v_a exchange_auctions%rowtype; v_fee bigint; v_net bigint; v_count integer := 0;
begin
    for v_a in select * from exchange_auctions where completed_at is null and cancelled_at is null and ends_at < now() for update loop
        if v_a.current_bidder is not null then
            v_fee := _exchange_sale_fee(v_a.seller_id, v_a.current_bid);
            v_net := v_a.current_bid - v_fee;
            if v_a.currency = 'GM' then perform _add_pending(v_a.seller_id, 'exchange', 0, v_net);
            else perform _add_pending(v_a.seller_id, 'exchange', v_net, 0); end if;
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

-- Guild merchant buy: buyer now pays from player_currency (was players.*); seller -> pending('guild').
create or replace function buy_guild_listing(p_listing_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_listing guild_merchant_listings%rowtype; v_buyer uuid := auth.uid();
    v_total_sm bigint; v_total_gm bigint; v_fee_sm bigint; v_fee_gm bigint; v_rate float; v_silver bigint; v_gold bigint;
begin
    select * into v_listing from guild_merchant_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_listing.listed_by = v_buyer then raise exception 'cannot_buy_own'; end if;
    if not exists (select 1 from guild_members where guild_id = v_listing.guild_id and player_id = v_buyer) then
        raise exception 'not_a_member'; end if;

    v_total_sm := v_listing.quantity * v_listing.price_sm;
    v_total_gm := v_listing.quantity * v_listing.price_gm;
    select tax_rate into v_rate from guilds where id = v_listing.guild_id;
    v_fee_sm := floor(v_total_sm * (coalesce(v_rate,0) / 2.0) / 100.0);
    v_fee_gm := floor(v_total_gm * (coalesce(v_rate,0) / 2.0) / 100.0);

    select silver_marks, gold_marks into v_silver, v_gold from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    if v_silver < v_total_sm or v_gold < v_total_gm then raise exception 'insufficient_funds'; end if;

    update player_currency set silver_marks = silver_marks - v_total_sm, gold_marks = gold_marks - v_total_gm,
                               updated_at = now() where player_id = v_buyer;
    perform _add_pending(v_listing.listed_by, 'guild', v_total_sm - v_fee_sm, v_total_gm - v_fee_gm);
    update guilds set bank_silver = bank_silver + v_fee_sm, bank_gold = bank_gold + v_fee_gm where id = v_listing.guild_id;

    delete from guild_merchant_listings where id = p_listing_id;
    return json_build_object('item_id', v_listing.item_id, 'quantity', v_listing.quantity,
        'buyer_silver', v_silver - v_total_sm, 'buyer_gold', v_gold - v_total_gm);
end; $$;
