-- Project Grimoire, Wayfarer's Exchange, cancel an auction (Migration 024)
-- Run AFTER 023.
--
-- Auctions had no cancel path at all: the My Listings cancel button did nothing. This adds a
-- server-authoritative RPC mirroring cancel_store_listing (023): verify ownership, refund the
-- standing high bidder their escrowed bid, mark the auction cancelled, and hand the item back to
-- the seller. Auction quality is the integer flag (migration 022), so no text mapping is needed.

create or replace function cancel_auction(p_auction_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare
    v_a      exchange_auctions%rowtype;
    v_seller uuid := auth.uid();
begin
    select * into v_a from exchange_auctions where id = p_auction_id for update;
    if not found then raise exception 'auction_not_found'; end if;
    if v_a.seller_id <> v_seller then raise exception 'not_owner'; end if;
    if v_a.cancelled_at is not null or v_a.completed_at is not null then raise exception 'auction_inactive'; end if;

    -- Refund the current high bidder their escrowed bid, if any.
    if v_a.current_bidder is not null then
        perform _exchange_credit_sm(v_a.current_bidder, v_a.current_bid);
    end if;

    update exchange_auctions set cancelled_at = now() where id = p_auction_id;

    -- Return the escrowed item to the seller (server-side; the client also re-adds for immediacy).
    perform _exchange_deliver_item(v_seller, v_a.item_id, v_a.quality, v_a.quantity);

    return json_build_object('item_id', v_a.item_id, 'quantity', v_a.quantity, 'quality', v_a.quality);
end; $$;
