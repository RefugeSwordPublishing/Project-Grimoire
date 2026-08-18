-- Project Grimoire, atomic inventory replace (Migration 034). Run AFTER 033.
--
-- The client saved inventory with a client-side DELETE-then-INSERT (InventorySyncService). If the
-- INSERT failed after the DELETE succeeded (a bad row, a transient error), the player's whole
-- inventory was left wiped on the server, the "inventory empty after loading the new version" bug.
-- This does the replace in ONE transaction: on any error the INSERT rolls back the DELETE, so the
-- inventory can never be left empty by a failed write. Called via rpc/replace_inventory.
--
-- The client still guards against sending an EMPTY set (it early-returns instead), so a bag that
-- looks empty from a failed load never reaches here to clear the server.
create or replace function replace_inventory(p_rows jsonb)
returns void language plpgsql security definer set search_path = public as $$
declare
    v_player uuid := auth.uid();
begin
    if v_player is null then raise exception 'not_authenticated'; end if;

    delete from player_inventory where player_id = v_player;

    if jsonb_array_length(coalesce(p_rows, '[]'::jsonb)) > 0 then
        insert into player_inventory
            (player_id, item_id, quantity, quality, slot_position, is_locked, placeholder_label)
        select v_player,
               r->>'item_id',
               (r->>'quantity')::bigint,
               (r->>'quality')::int,
               (r->>'slot_position')::int,
               (r->>'is_locked')::boolean,
               nullif(r->>'placeholder_label', '')
        from jsonb_array_elements(p_rows) r;
    end if;
end;
$$;
