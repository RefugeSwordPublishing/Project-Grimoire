# Pending Unity Editor Steps

Running checklist of Unity editor actions to run when back at the machine (things Claude Code
can't do remotely). Check off as done; Claude keeps this updated.

Menu items are under **Tools > Grimoire > Build > ...** unless noted. After running bakers,
recompile/redeploy to the phone to test.

## To run (newest first)

- [ ] **Build Chat Pill** — adds the top-right "Messages" unread pill (DM unread badge). New this session.
- [ ] **Content > Add Alchemy Potion Recipes** — adds Craft recipes for the three Healing Draughts to
  the Alchemy talent (Crude @L1 / Refined @L35 / Masterwork @L70). Run once; verify they show in the
  Alchemy crafting list.
- [ ] **Build Buff Bar** — adds a persistent top-center buff bar showing active meal/timed buffs with
  their remaining time (reposition/skin as needed).
- [ ] **Build Hub Stations** — adds 5 placeholder station buttons (Quest Board, Notice Board, Slayer
  Hub, Upgrade Terminal = equipment upgrade, Guild), wired to their destinations. Reposition/resize to
  match the layout, then swap each button's Image for the station art as it lands. This restores Guild
  and equipment-upgrade access.
- [ ] **Build Eat Quantity UI** — REQUIRED for bulk consume to work at all (without it, Use just
  consumes one). Adds the quantity popup: drag slider (1..held) + a live preview that shows the
  resulting stacked buff duration (food) or amount restored (potions) as you scroll, + Eat/Cancel.
- [ ] **Content > Create Economy Talents** — re-run to apply the reworked Gleaning: common rune
  materials guaranteed, all upgrade sigils (Rough/Refined/Pristine/Masterwork + Runic Cog + Ancient) as
  tiered RARE bonus drops (7% -> 2% by tier). All sigils obtainable, and scarce.
- [ ] **Content > Audit Item Sources** — run and read the Console: lists items with no source, recipe
  inputs that block crafting, and dangling references. Use it to find remaining obtainability gaps.

_(P2 lobby chat needs no baker: the pre-boss lobby is runtime-built, so its new "Chat" button lands automatically on recompile.)_

## Already run this session (no action needed, listed for reference)

- Build Friend Panel, Build Chat Panel, Build Temp Guild Button — done during testing.

## Backlog raised 2026-08-17 (Claude will build; some need an editor run/test after)

- **Hub rework placeholders** — temporary nav entries for the new stations (Quest Board, Upgrade
  Terminal, Slayer Hub, Notice Board) + restore **Guild** to the nav (GuildBankUI is installed;
  Nav_Guild fell out of the reorganized drawer). Collaborative session when back at the machine.
  See docs/hub-hud-station-brief.md.
- **Equipment upgrade access** — the upgrade path IS the Assembly system (AssemblyManager,
  AssemblyStationView, BuildAssemblyStation = "Upgrade Terminal"); its nav entry vanished in the
  hub rework. Restoring it is part of the hub nav placeholders above.
- **Alchemy health-potion recipes** — DONE (code). `AddAlchemyRecipes` editor script authored; run
  **Content > Add Alchemy Potion Recipes** (see checklist above) to generate them, then verify.
- **Eat-quantity for stackable consumables** — DONE (backend + popup UI with live buff/restore
  preview). Just needs the Build Eat Quantity UI baker run (see checklist). Open q: keep it as a popup
  or move the slider inline under Use in the context menu (would re-bake the context menu).
- **Sprite atlas (draw-call batching)** — tooling built. Flow: (1) place sheets flat in
  Assets/Sprites/icons (done, named `*_icon_atlas.png`); (2) **Art > Slice Icon Atlases** grid-slices
  them 64x64 into `<sheet>_<index>` sub-sprites; (3) **Art > Build Icon Sprite Atlas** creates the
  packing SpriteAtlas (enable Sprite Packing in Project Settings > Editor). STILL TODO (Claude):
  the reassign step, point ItemData.icon at the sliced sub-sprites (adapt ImportGeneratedIcons to load
  `<sheet>_<cellIndex>` from the sheet instead of individual PNGs, reusing its sheet/cell->item map).
- **Import hub station sprites** — the ui_hub_stations sprites are approved in the tracker but NOT yet
  downloaded to Assets/Art/GeneratedIcons/ui_hub_stations/. Pull them in (download script), then swap
  each HubStations placeholder button's Image for the sprite.
- **Hub station positions per guild-background tier** — station placements must change with the
  prestige-driven guild background. TODO: HubSceneUI holds per-prestige-tier position sets and
  repositions the stations when the background/prestige tier changes.
- **Tap an ingredient -> see its source** — runtime source lookup (Gleaning rare drop Lv X, drops from
  enemy Y, Craft on talent Z) + a small popup, shown when tapping a recipe ingredient. Reuses the
  audit's source-index logic. NEXT build.
