# Art Pass, Needed and Blocking

What art is outstanding, sorted by how much it blocks. "Blocking" means a feature is built and shipped
in code but shows a placeholder / fallback until the art lands. Generated in Layer.ai / PixelLab, dropped
into the asset tracker, then imported to Unity (see the sprite-pass workflow).

---

## Blocking (built feature is incomplete without this art)

- [ ] **Debuff status icons** (Poison, Barbed Bleed, Hemorrhage). Generated at 16x16 in the tracker but
  NOT imported to Unity (`ui_debuff_icons`). Blocks: upgrading the combat buff bar from text chips to
  icon + radial timer, and the enemy/player debuff pips. The status-effect system and buff bar are built;
  they render as text until the icons import.
- [ ] **Hub station sprites** (`ui_hub_stations`). Approved in the tracker, not yet downloaded to
  `Assets/Art/GeneratedIcons/ui_hub_stations/`. Blocks: the hub station buttons (Quest Board, Notice
  Board, Slayer Hub, Upgrade Terminal, Guild) show flat placeholders instead of art. The per-prestige
  hub-station system is built; drop each sprite onto its button.
- [ ] **Guild-hall prestige backgrounds** (per prestige stage, at least stages 1 / 5 / 8). Blocks: the
  hub background + the per-stage station layouts (`PrestigeHubBackground` + `HubStationSet` prefabs). The
  swap-on-prestige system is built; it needs the stage backgrounds to position stations against.
- [ ] **Refined Endurance Draught icon** (BUG-002, missing sprite in inventory). Part of your sprite pass.
- [ ] **Material icon "Needs Regen" cells** (~92 across the item sheets). The 13 material atlas sheets are
  composited + corrected, but any cell still flagged Needs Regen renders as a white box until regenerated
  and re-approved in the tracker, then re-run the atlas compositor + Slice/Reassign.

## Nice to have (feature works with a fallback; art improves it)

- [ ] **Onboarding backgrounds** (`Resources/Onboarding/`: `title`, `intro1`, `intro2`, `intro3`,
  `grimoire_choice`). The onboarding uses a dark fallback when absent, so it works; per-step art makes the
  opening land. New this session (title screen added for BUG-007).
- [ ] **Quest-type leading icons** (one per QuestType, for the quest-board rows). Deferred; rows read fine
  without them. Would add the Idle-Clans-style at-a-glance icon per quest.
- [ ] **Weapon / armor item icons in the atlas.** The 13 material sheets are atlased; weapons, armor, and
  `cultivation` / `delving_special` / `tailoring_*` stay on individual PNGs (not batched). They have
  icons, so this is a draw-call optimization, not a visual gap.

## Bigger art passes (tracked on the board, not this session)

- [ ] **Phase 2 enemy sprites** + per-enemy weak-point masks (place on Z10 quads). See
  phase2-enemy-content-brief.
- [ ] **Dungeon art**: 4 boss sprites + weak-point masks (Aldric, Mirra Vane, Aldrath, Valdris), puzzle
  visuals (Pyre / Valve / Glyph / Weight pads), 6 backdrops (T1-T3), 7 room-type icons, boss-drop icons.
- [ ] **Spatial Guild Hall UI** art (painterly prestige-band background + tappable props).

---

## How art unblocks the code (already built, waiting on art)

| Art | Unblocks |
|---|---|
| Debuff icons | Buff-bar icon+radial upgrade, debuff pips |
| Hub station sprites | Hub station button art (system done) |
| Prestige backgrounds | Per-stage hub layouts (system done) |
| Enemy sprites + masks | Weak-point combat, Valdris shifting weak point |
| Dungeon art | Dungeon visuals (T1-T5 dungeons built) |
