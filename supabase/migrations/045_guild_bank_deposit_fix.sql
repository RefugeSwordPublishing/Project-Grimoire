-- Project Grimoire, Migration 045: guild bank deposit persistence fix
--
-- The guild bank persisted deposits with a direct INSERT into guild_bank_slots, but that table's
-- write policy is officers-only, so a regular MEMBER's donation was silently rejected by RLS and
-- lost (the bank appeared empty even after depositing). This hardens the existing SECURITY DEFINER
-- upsert helper so members can deposit through it (bypassing the officers-only RLS) while still
-- requiring guild membership, and handles quantity <= 0 as a delete. The client now calls this RPC
-- for both deposit and withdraw instead of a direct POST/DELETE.

create or replace function upsert_guild_bank_slot(p_guild_id uuid, p_item_id text, p_quantity bigint)
returns void language plpgsql security definer set search_path = public as $$
begin
    -- Caller must be a member of the guild (deposit is a member action; RLS alone is officers-only).
    if not exists (select 1 from guild_members where guild_id = p_guild_id and player_id = auth.uid()) then
        raise exception 'not a guild member';
    end if;

    if p_quantity <= 0 then
        delete from guild_bank_slots where guild_id = p_guild_id and item_id = p_item_id;
    else
        insert into guild_bank_slots (guild_id, item_id, quantity)
        values (p_guild_id, p_item_id, p_quantity)
        on conflict (guild_id, item_id) do update set quantity = excluded.quantity;
    end if;
end; $$;

grant execute on function upsert_guild_bank_slot(uuid, text, bigint) to anon, authenticated;
