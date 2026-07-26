-- Project Grimoire, Wayfarer's Exchange, cancel a store listing (Migration 023)
-- Run AFTER 022.
--
-- The client cancelled store listings with a direct PATCH of cancelled_at. That failed RLS
-- (42501: "new row violates row-level security policy") because the store_listings SELECT policy
-- requires cancelled_at IS NULL, so PostgREST could not return the just-cancelled row. It also never
-- returned the escrowed item to the seller. This RPC does both, server-authoritatively, and mirrors
-- cancel_buy_order (004): verify ownership, mark cancelled, hand the item back.

create or replace function cancel_store_listing(p_listing_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_l      exchange_store_listings%rowtype;
    v_seller uuid := auth.uid();
begin
    select * into v_l from exchange_store_listings where id = p_listing_id for update;
    if not found then raise exception 'listing_not_found'; end if;
    if v_l.seller_id <> v_seller then raise exception 'not_owner'; end if;
    if v_l.cancelled_at is not null then raise exception 'already_cancelled'; end if;

    update exchange_store_listings set cancelled_at = now() where id = p_listing_id;

    -- Hand the escrowed stock back to the seller's inventory (the seller is online, but write it
    -- server-side so it survives even if they aren't; the client also refreshes on next load).
    perform _exchange_deliver_item(v_seller, v_l.item_id,
        coalesce(_quality_text_to_int(v_l.quality), 0), v_l.quantity);

    return json_build_object('item_id', v_l.item_id, 'quantity', v_l.quantity, 'quality', v_l.quality);
end; $$;

-- Store listings carry quality as TEXT ("Crude".."Legendary"); player_inventory keys it as the
-- integer flag. Map one to the other for delivery.
create or replace function _quality_text_to_int(p_q text)
returns integer language sql immutable as $$
    select case lower(coalesce(p_q, ''))
        when 'crude' then 0 when 'rough' then 1 when 'refined' then 2
        when 'pristine' then 3 when 'masterwork' then 4 when 'legendary' then 5
        else 0 end;
$$;
