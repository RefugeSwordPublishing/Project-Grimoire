-- Project Grimoire — Guild Merchant currency support (Migration 017)
-- Listings can now be priced in Silver Marks (sm) or Gold Marks (gm). The amount
-- lives in price_sm regardless (kept for compatibility); `currency` tells the buy
-- RPC which player/guild balance to move. Fee = half the guild tax, same currency.
-- Run AFTER 016.

alter table guild_merchant_listings
    add column if not exists currency text not null default 'sm';

do $$ begin
    alter table guild_merchant_listings
        add constraint gml_currency_chk check (currency in ('sm', 'gm'));
exception when duplicate_object then null; end $$;

create or replace function buy_guild_listing(p_listing_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_listing guild_merchant_listings%rowtype;
    v_buyer   uuid := auth.uid();
    v_total   bigint;
    v_fee     bigint;
    v_rate    float;
    v_bal     bigint;
    v_is_gm   boolean;
begin
    select * into v_listing from guild_merchant_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_listing.listed_by = v_buyer then raise exception 'cannot_buy_own'; end if;

    if not exists (select 1 from guild_members
                   where guild_id = v_listing.guild_id and player_id = v_buyer) then
        raise exception 'not_a_member';
    end if;

    v_is_gm := (v_listing.currency = 'gm');
    v_total := v_listing.quantity * v_listing.price_sm;  -- price_sm holds the amount in the chosen currency
    select tax_rate into v_rate from guilds where id = v_listing.guild_id;
    v_fee := floor(v_total * (coalesce(v_rate, 0) / 2.0) / 100.0);

    if v_is_gm then
        select gold_marks into v_bal from players where id = v_buyer for update;
        if v_bal < v_total then raise exception 'insufficient_funds'; end if;
        update players set gold_marks = gold_marks - v_total          where id = v_buyer;
        update players set gold_marks = gold_marks + (v_total - v_fee) where id = v_listing.listed_by;
        update guilds  set bank_gold  = bank_gold  + v_fee            where id = v_listing.guild_id;
    else
        select silver_marks into v_bal from players where id = v_buyer for update;
        if v_bal < v_total then raise exception 'insufficient_funds'; end if;
        update players set silver_marks = silver_marks - v_total          where id = v_buyer;
        update players set silver_marks = silver_marks + (v_total - v_fee) where id = v_listing.listed_by;
        update guilds  set bank_silver  = bank_silver  + v_fee            where id = v_listing.guild_id;
    end if;

    delete from guild_merchant_listings where id = p_listing_id;

    return json_build_object(
        'item_id',       v_listing.item_id,
        'quantity',      v_listing.quantity,
        'currency',      v_listing.currency,
        'buyer_balance', v_bal - v_total
    );
end; $$;
