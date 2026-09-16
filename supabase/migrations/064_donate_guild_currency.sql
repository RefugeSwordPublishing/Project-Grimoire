-- Project Grimoire, donate currency to the guild bank (Migration 064)
-- BUG-091. Members had no way to contribute their own Silver/Gold Marks to the guild treasury
-- (guilds.bank_silver / bank_gold), which otherwise only fills from the guild sales tax. This RPC lets
-- ANY guild member move their own currency into the treasury (donations, not a withdrawal, so it is not
-- officer-gated). SECURITY DEFINER to read guild_members + write guilds/player_currency past RLS; the
-- membership check is the gate.
create or replace function donate_to_guild(p_silver bigint, p_gold bigint)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid    uuid := auth.uid();
    v_guild  uuid;
    v_silver bigint;
    v_gold   bigint;
    v_bank_silver bigint;
    v_bank_gold   bigint;
begin
    if p_silver is null or p_silver < 0 or p_gold is null or p_gold < 0 then raise exception 'bad_amount'; end if;
    if p_silver = 0 and p_gold = 0 then raise exception 'nothing_to_donate'; end if;

    select guild_id into v_guild from guild_members where player_id = v_uid limit 1;
    if v_guild is null then raise exception 'not_in_guild'; end if;

    select silver_marks, gold_marks into v_silver, v_gold
      from player_currency where player_id = v_uid for update;
    if v_silver < p_silver then raise exception 'insufficient_silver'; end if;
    if v_gold   < p_gold   then raise exception 'insufficient_gold'; end if;

    update player_currency
       set silver_marks = silver_marks - p_silver,
           gold_marks   = gold_marks   - p_gold,
           updated_at   = now()
     where player_id = v_uid;

    update guilds
       set bank_silver = bank_silver + p_silver,
           bank_gold   = bank_gold   + p_gold
     where id = v_guild
     returning bank_silver, bank_gold into v_bank_silver, v_bank_gold;

    return json_build_object(
        'success', true,
        'buyer_silver', v_silver - p_silver,
        'buyer_gold',   v_gold   - p_gold,
        'bank_silver',  v_bank_silver,
        'bank_gold',    v_bank_gold);
end;
$$;

grant execute on function donate_to_guild(bigint, bigint) to authenticated;
