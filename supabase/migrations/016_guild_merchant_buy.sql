-- Project Grimoire — Guild Merchant purchase RPC (Migration 016)
-- Atomic buy: deduct buyer silver, pay seller (minus internal fee), credit the
-- guild bank the fee, remove the listing. SECURITY DEFINER so it can move another
-- player's balance (the seller is offline) while bypassing per-row RLS.
-- Internal fee = HALF the guild's voted tax rate (0% tax → 0% fee). Buyer is online
-- (they tapped Buy), so the item is delivered client-side from the returned payload.
-- Run AFTER 011 (guild_merchant_listings) and 002 (players/guilds).

create or replace function buy_guild_listing(p_listing_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_listing      guild_merchant_listings%rowtype;
    v_buyer        uuid := auth.uid();
    v_total        bigint;
    v_fee          bigint;
    v_rate         float;
    v_buyer_silver bigint;
begin
    select * into v_listing from guild_merchant_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_listing.listed_by = v_buyer then raise exception 'cannot_buy_own'; end if;

    -- Buyer must belong to the listing's guild (RLS is bypassed here, so check explicitly)
    if not exists (select 1 from guild_members
                   where guild_id = v_listing.guild_id and player_id = v_buyer) then
        raise exception 'not_a_member';
    end if;

    v_total := v_listing.quantity * v_listing.price_sm;

    select silver_marks into v_buyer_silver from players where id = v_buyer for update;
    if v_buyer_silver < v_total then raise exception 'insufficient_funds'; end if;

    select tax_rate into v_rate from guilds where id = v_listing.guild_id;
    v_fee := floor(v_total * (coalesce(v_rate, 0) / 2.0) / 100.0);   -- half tax %, as a fraction

    update players set silver_marks = silver_marks - v_total                where id = v_buyer;
    update players set silver_marks = silver_marks + (v_total - v_fee)       where id = v_listing.listed_by;
    update guilds  set bank_silver  = bank_silver  + v_fee                   where id = v_listing.guild_id;
    delete from guild_merchant_listings where id = p_listing_id;

    return json_build_object(
        'item_id',      v_listing.item_id,
        'quantity',     v_listing.quantity,
        'buyer_silver', v_buyer_silver - v_total
    );
end; $$;
