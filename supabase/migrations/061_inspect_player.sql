-- 061_inspect_player.sql
-- Party ally cards, slice 3: tap a card to inspect a partner's gear + stats (docs/party-ally-cards-spec.md
-- section 6). Gated on sharing a lobby with the caller, mirroring sync_member_state. Read-only.
--
-- Column names are reconciled to the real schema (the spec's draft referenced fields that do not exist):
-- player_stats is str/dex/vit/int/wil/lck/cha/max_hp/current_hp ("int" is quoted, it is a reserved word) and
-- carries NO derived stats (armour/evasion/block are computed client-side, not stored); player_equipment's
-- blob column is `data`; total combat level is the SUM of player_grimoire_levels.combat_level; the class is
-- players.grimoire_equipped. The INT stat is emitted under the key "intl" so the Unity client (JsonUtility)
-- can bind it to a field, since "int" is not a legal C# identifier.

create or replace function inspect_player(p_target uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_out jsonb;
begin
  -- Gate: caller and target must share a lobby. A stranger gets an error, never another player's data.
  if not exists (
    select 1 from lobby_member_state m1
    join lobby_member_state m2 on m2.lobby_id = m1.lobby_id
    where m1.player_id = auth.uid() and m2.player_id = p_target
  ) then
    raise exception 'Not in your party';
  end if;

  select jsonb_build_object(
    'username',           p.username,
    'grimoire',           p.grimoire_equipped,
    'combat_level',       coalesce(p.combat_level, 1),
    'total_combat_level', coalesce((select sum(combat_level) from player_grimoire_levels where player_id = p.id), 0),
    'hp',                 coalesce(st.current_hp, 0),
    'max_hp',             coalesce(st.max_hp, 1),
    'stats', jsonb_build_object(
      'str', coalesce(st.str,0), 'dex', coalesce(st.dex,0), 'vit', coalesce(st.vit,0),
      'intl', coalesce(st."int",0), 'wil', coalesce(st.wil,0), 'lck', coalesce(st.lck,0),
      'cha', coalesce(st.cha,0)),
    -- equipment blob is the stored object {gear:[{slot,item,q}], tools:[...]}
    'equipment',          coalesce(pe.data, '{}'::jsonb)
  ) into v_out
  from players p
  left join player_stats st      on st.player_id = p.id
  left join player_equipment pe  on pe.player_id = p.id
  where p.id = p_target;

  return coalesce(v_out, '{}'::jsonb);
end; $$;

grant execute on function inspect_player(uuid) to authenticated;
