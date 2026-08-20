-- Guild Bank capacity purchased from the Royal Merchant. Unlike the per-player capacity unlocks
-- (migration 042, mirrored on player_settings), guild-bank expansion is guild-shared state, so it lives
-- on the guild and is bought through an officer-gated RPC that deducts the buyer's Gold Marks. Repeatable
-- (cumulative), no per-player idempotency: a guild can keep growing its bank.

alter table guilds
    add column if not exists bank_slot_bonus integer not null default 0; -- +slots bought via Royal Merchant

-- Buy p_slots of guild-bank capacity for p_gm_cost. Officer/guild_master only; charges the caller's GM
-- from player_currency and adds the slots to their guild's bank_slot_bonus. SECURITY DEFINER so it can
-- read guild_members + write guilds/player_currency past RLS; the role check is the gate.
create or replace function purchase_guild_bank_slots(p_slots int, p_gm_cost bigint)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid   uuid := auth.uid();
    v_guild uuid;
    v_role  text;
    v_gold  bigint;
    v_bonus int;
begin
    if v_uid is null then raise exception 'not_authenticated'; end if;
    if p_slots is null or p_slots <= 0 then raise exception 'bad_slots'; end if;
    if p_gm_cost is null or p_gm_cost < 0 then raise exception 'bad_cost'; end if;

    select guild_id, role into v_guild, v_role
      from guild_members where player_id = v_uid limit 1;
    if v_guild is null then raise exception 'not_in_guild'; end if;
    if v_role not in ('officer', 'guild_master') then raise exception 'not_officer'; end if;

    select gold_marks into v_gold from player_currency where player_id = v_uid for update;
    if v_gold is null then raise exception 'no_wallet'; end if;
    if v_gold < p_gm_cost then raise exception 'insufficient_gm'; end if;

    update player_currency set gold_marks = gold_marks - p_gm_cost, updated_at = now()
      where player_id = v_uid;

    update guilds set bank_slot_bonus = bank_slot_bonus + p_slots
      where id = v_guild
      returning bank_slot_bonus into v_bonus;

    return json_build_object('success', true, 'buyer_gold', v_gold - p_gm_cost, 'bank_slot_bonus', v_bonus);
end;
$$;

grant execute on function purchase_guild_bank_slots(int, bigint) to authenticated;
