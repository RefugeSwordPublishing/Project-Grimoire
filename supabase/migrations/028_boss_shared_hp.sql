-- Project Grimoire, Zone boss shared HP (Migration 028)
-- STEP 10 Phase C: the co-op boss fight shares one server-authoritative HP pool (boss_lobby.
-- boss_current_hp, set at start by migration 027's flow). Each participant batches its damage and
-- calls boss_take_damage; the server decrements the pool atomically and flips status to 'complete'
-- when it hits 0, so every client resolves the kill from the same source of truth. Passing p_amount = 0
-- is a cheap read (poll the current HP without changing it).

create or replace function boss_take_damage(p_lobby uuid, p_amount int)
returns table (boss_current_hp int, status text)
language plpgsql
security definer
set search_path = public
as $$
declare
    l boss_lobby;
begin
    select * into l from boss_lobby where id = p_lobby for update;
    if not found then raise exception 'lobby not found'; end if;
    if auth.uid() not in (l.host_id, l.player_2_id, l.player_3_id) then
        raise exception 'not a participant';
    end if;

    -- Only an active fight takes damage; otherwise just report the current state.
    if l.status = 'active' and p_amount > 0 then
        update boss_lobby
           set boss_current_hp = greatest(0, coalesce(boss_current_hp, 0) - p_amount)
         where id = p_lobby
        returning * into l;

        if l.boss_current_hp <= 0 then
            update boss_lobby set status = 'complete' where id = p_lobby returning * into l;
        end if;
    end if;

    return query select l.boss_current_hp, l.status;
end;
$$;
