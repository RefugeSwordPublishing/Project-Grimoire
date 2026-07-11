-- Project Grimoire — Guild Merchant dual-currency price (Migration 018)
-- A listing can carry a combined price: some Silver Marks AND some Gold Marks
-- (either may be zero). Buying charges both currencies; the guild fee (half the
-- guild tax) is taken from each. Supersedes the single-currency model in 016/017;
-- the `currency` column is left in place but unused. Run AFTER 017.

alter table guild_merchant_listings
    add column if not exists price_gm bigint not null default 0;

create or replace function buy_guild_listing(p_listing_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_listing  guild_merchant_listings%rowtype;
    v_buyer    uuid := auth.uid();
    v_total_sm bigint;
    v_total_gm bigint;
    v_fee_sm   bigint;
    v_fee_gm   bigint;
    v_rate     float;
    v_silver   bigint;
    v_gold     bigint;
begin
    select * into v_listing from guild_merchant_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_listing.listed_by = v_buyer then raise exception 'cannot_buy_own'; end if;

    if not exists (select 1 from guild_members
                   where guild_id = v_listing.guild_id and player_id = v_buyer) then
        raise exception 'not_a_member';
    end if;

    v_total_sm := v_listing.quantity * v_listing.price_sm;
    v_total_gm := v_listing.quantity * v_listing.price_gm;

    select tax_rate into v_rate from guilds where id = v_listing.guild_id;
    v_fee_sm := floor(v_total_sm * (coalesce(v_rate, 0) / 2.0) / 100.0);
    v_fee_gm := floor(v_total_gm * (coalesce(v_rate, 0) / 2.0) / 100.0);

    select silver_marks, gold_marks into v_silver, v_gold
        from players where id = v_buyer for update;
    if v_silver < v_total_sm or v_gold < v_total_gm then
        raise exception 'insufficient_funds';
    end if;

    -- Buyer pays both currencies
    update players set silver_marks = silver_marks - v_total_sm,
                       gold_marks   = gold_marks   - v_total_gm
        where id = v_buyer;
    -- Seller receives both, minus the guild fee on each
    update players set silver_marks = silver_marks + (v_total_sm - v_fee_sm),
                       gold_marks   = gold_marks   + (v_total_gm - v_fee_gm)
        where id = v_listing.listed_by;
    -- Guild bank keeps the fee on each
    update guilds  set bank_silver  = bank_silver + v_fee_sm,
                       bank_gold    = bank_gold   + v_fee_gm
        where id = v_listing.guild_id;

    delete from guild_merchant_listings where id = p_listing_id;

    return json_build_object(
        'item_id',      v_listing.item_id,
        'quantity',     v_listing.quantity,
        'buyer_silver', v_silver - v_total_sm,
        'buyer_gold',   v_gold   - v_total_gm
    );
end; $$;
