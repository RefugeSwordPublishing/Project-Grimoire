-- Project Grimoire, Wayfarer's Exchange dual-currency store listings (Migration 020)
-- Modernizes the store-listing side of the Exchange to match the Guild Merchant:
-- dual Silver/Gold pricing, item quality on the listing, fee-on-SALE (not at listing
-- time), a server-authoritative purchase RPC, and a 30-day expiry sweep. Run AFTER 019.
--
-- Fee model (fee taken from the sale proceeds; seller receives total minus fee):
--   Solo seller  : 3% system tax, a pure sink (deducted, credited nowhere)
--   Guild member : the seller's full guild tax rate, credited to their guild bank
--   (Buy orders stay 0%, handled in a later migration.)
--
-- IMPORTANT: currency is written to player_currency, the table the Unity client reads
-- and writes (PlayerDataService.LoadCurrency/SaveCurrency). The guild RPCs (016-018) use
-- players.silver_marks/gold_marks instead; that split is a known separate bug tracked
-- outside this migration, do NOT copy the players.* pattern here.

-- price_per_unit stays the Silver Marks price (the client reads it as price_sm).

alter table exchange_store_listings
    add column if not exists price_gm bigint not null default 0;
alter table exchange_store_listings
    add column if not exists quality text;
alter table exchange_store_listings
    add column if not exists note text;
alter table exchange_store_listings
    alter column expires_at set default now() + interval '30 days';

-- ── Purchase a store listing (server-authoritative, dual currency, fee on sale) ─
create or replace function purchase_store_listing(p_listing_id uuid, p_quantity bigint)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_listing  exchange_store_listings%rowtype;
    v_buyer    uuid := auth.uid();
    v_total_sm bigint;
    v_total_gm bigint;
    v_fee_sm   bigint := 0;
    v_fee_gm   bigint := 0;
    v_guild_id uuid;
    v_rate     float;
    v_bsilver  bigint;
    v_bgold    bigint;
begin
    if p_quantity is null or p_quantity <= 0 then raise exception 'bad_quantity'; end if;

    select * into v_listing from exchange_store_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_listing.cancelled_at is not null then raise exception 'listing_inactive'; end if;
    if v_listing.expires_at is not null and v_listing.expires_at < now() then
        raise exception 'listing_expired'; end if;
    if v_listing.seller_id = v_buyer then raise exception 'cannot_buy_own'; end if;
    if v_listing.quantity < p_quantity then raise exception 'insufficient_quantity'; end if;

    v_total_sm := v_listing.price_per_unit * p_quantity;
    v_total_gm := v_listing.price_gm       * p_quantity;

    -- Fee on sale: the seller's guild tax if they are in a guild, else a 3% system sink.
    select guild_id into v_guild_id from guild_members where player_id = v_listing.seller_id limit 1;
    if v_guild_id is not null then
        select tax_rate into v_rate from guilds where id = v_guild_id;
        v_fee_sm := floor(v_total_sm * coalesce(v_rate, 0) / 100.0);
        v_fee_gm := floor(v_total_gm * coalesce(v_rate, 0) / 100.0);
    else
        v_fee_sm := floor(v_total_sm * 3.0 / 100.0);
        v_fee_gm := floor(v_total_gm * 3.0 / 100.0);
    end if;

    -- Buyer must afford both currencies (player_currency is the client-authoritative wallet).
    select silver_marks, gold_marks into v_bsilver, v_bgold
        from player_currency where player_id = v_buyer for update;
    if not found then raise exception 'buyer_no_wallet'; end if;
    if v_bsilver < v_total_sm or v_bgold < v_total_gm then
        raise exception 'insufficient_funds'; end if;

    -- Buyer pays both currencies.
    update player_currency
        set silver_marks = silver_marks - v_total_sm,
            gold_marks   = gold_marks   - v_total_gm,
            updated_at   = now()
        where player_id = v_buyer;

    -- Seller receives the sale minus fee (create the wallet row if it does not exist yet).
    insert into player_currency (player_id, silver_marks, gold_marks)
        values (v_listing.seller_id, v_total_sm - v_fee_sm, v_total_gm - v_fee_gm)
        on conflict (player_id) do update
            set silver_marks = player_currency.silver_marks + (v_total_sm - v_fee_sm),
                gold_marks   = player_currency.gold_marks   + (v_total_gm - v_fee_gm),
                updated_at   = now();

    -- Guild-member fee goes to the guild bank; the solo fee is a pure sink.
    if v_guild_id is not null and (v_fee_sm > 0 or v_fee_gm > 0) then
        update guilds set bank_silver = bank_silver + v_fee_sm,
                          bank_gold   = bank_gold   + v_fee_gm
            where id = v_guild_id;
    end if;

    -- Decrement the listing; delete it when fully bought.
    if v_listing.quantity - p_quantity <= 0 then
        delete from exchange_store_listings where id = p_listing_id;
    else
        update exchange_store_listings set quantity = quantity - p_quantity where id = p_listing_id;
    end if;

    -- Record the sale (Silver Marks unit price feeds the price-history view).
    insert into exchange_sale_history (item_id, price, quantity)
        values (v_listing.item_id, v_listing.price_per_unit, p_quantity);

    return json_build_object(
        'item_id',      v_listing.item_id,
        'quantity',     p_quantity,
        'quality',      v_listing.quality,
        'seller_id',    v_listing.seller_id,
        'total_sm',     v_total_sm,
        'total_gm',     v_total_gm,
        'buyer_silver', v_bsilver - v_total_sm,
        'buyer_gold',   v_bgold   - v_total_gm
    );
end; $$;

-- ── Expiry sweep: return escrowed items to sellers, deactivate expired listings ─
-- The item goes back to the seller's player_inventory (loaded on their next session).
create or replace function sweep_expired_exchange_listings()
returns integer language plpgsql security definer set search_path = public as $$
declare v_count integer := 0;
begin
    insert into player_inventory (player_id, item_id, quantity)
        select seller_id, item_id, quantity
        from exchange_store_listings
        where cancelled_at is null and quantity > 0
          and expires_at is not null and expires_at < now()
    on conflict (player_id, item_id)
        do update set quantity = player_inventory.quantity + excluded.quantity;

    with swept as (
        update exchange_store_listings set cancelled_at = now()
        where cancelled_at is null and quantity > 0
          and expires_at is not null and expires_at < now()
        returning 1)
    select count(*) into v_count from swept;

    return v_count;
end; $$;

-- Enable the pg_cron extension in the Supabase dashboard, then run this once:
-- select cron.schedule('sweep-expired-exchange-listings', '0 3 * * *',
--     $$ select sweep_expired_exchange_listings(); $$);
