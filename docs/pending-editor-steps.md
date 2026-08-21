# Pending Unity Editor Steps

Running checklist of Unity editor actions to run when back at the machine (things Claude Code
can't do remotely). Check off as done; Claude keeps this updated.

Menu items are under **Tools > Grimoire > Build > ...** unless noted. After running bakers,
recompile/redeploy to the phone to test.

## To run (newest first)

- [ ] **Content > Create Grimoires** — re-bake the 7 Grimoire assets to pull in the authored **lore**
  (already written in CreateGrimoires.cs, but the live .asset files predate it and show empty lore, the
  cause of the "sparse Grimoire descriptions", BUG-009). After running, the onboarding Grimoire preview
  shows tagline + lore + passive + idle. The preview panel was also widened + auto-sizes (code, no baker).

- [ ] **Royal Merchant capacity, TEST (no baker; works on recompile, migration 042 applied live).** New GM
  categories are live: Inventory Pack +10/+25 (bag grows), Exchange Slot +1/+3 (active-listing cap 10 +
  bonus, blocks create past it), Daily/Weekly quest slots (extra quests at next reset), Slaying Task Slot
  5/6/7 (extra Bounty Board slots; level-gated at purchase), Auto-Drink Mana (Arcanist drinks a mana
  consumable under 30% in combat). Buy each with GM, confirm the effect, and that it persists across a
  relaunch. GUILD BANK +5/+15 is now live too (migration 043, officer-gated): as an officer/guild_master
  buy it, the guild bank grows for all members and persists; non-officers get a rejection.

- [ ] **Art > Skin Hub Bars** — reskins the hub HP bar and the active idle-task bar with the UISkin
  frame + fills (same look as the combat bars: fillHP on HP, fillTimer on idle, barFrame on both
  tracks). Edit-time + re-runnable; positions stay yours. Run Refresh UISkin first if the skin is
  unbound.
- [ ] **Art > Add Currency Icons** — drops the Silver/Gold Mark coin icons (ui_currency A1/A2) next to
  the SM/GM currency labels on the top bar. Already-built tool; just run it, then nudge size/position
  in the Inspector.
- [ ] **Build > Toggle Resume Bar (Editor)** — reveals the resume/minimized-combat bar
  (MinimizedCombatBar/Content) in the editor so you can reposition/reskin it by hand, then run again to
  hide it. Runtime visibility is still owned by MinimizedCombatBarUI; re-hide before committing.
- [ ] **Build Chat Pill** — adds the top-right "Messages" unread pill (DM unread badge). New this session.
- [ ] **Content > Add Alchemy Potion Recipes** — adds Craft recipes for the three Healing Draughts to
  the Alchemy talent (Crude @L1 / Refined @L35 / Masterwork @L70). Run once; verify they show in the
  Alchemy crafting list.
- [ ] **Build Buff Bar** — adds a persistent top-center buff bar showing active meal/timed buffs with
  their remaining time (reposition/skin as needed).
- [ ] **Build Hub Stations** — bakes the base `HubStationSet` prefab (5 station buttons: Quest Board,
  Notice Board, Slayer Hub, Upgrade Terminal = equipment upgrade, Guild) + a HubStationsRoot with
  HubSceneUI (stage 0 wired). Per-prestige-stage layouts: **duplicate the prefab per stage, reposition
  the stations to fit that stage's background, then assign each to HubSceneUI's Stage Sets array**
  (index 0..7; null slots fall back). It swaps live with prestige. Restores Guild + equipment upgrade.
- [ ] **Build Eat Quantity UI** — REQUIRED for bulk consume to work at all (without it, Use just
  consumes one). Adds the quantity popup: drag slider (1..held) + a live preview that shows the
  resulting stacked buff duration (food) or amount restored (potions) as you scroll, + Eat/Cancel.
- [ ] **Content > Create Economy Talents** — re-run to apply the reworked Gleaning: common rune
  materials guaranteed, all upgrade sigils (Rough/Refined/Pristine/Masterwork + Runic Cog + Ancient) as
  tiered RARE bonus drops (7% -> 2% by tier). All sigils obtainable, and scarce.
- [ ] **Content > Audit Item Sources** — run and read the Console: lists items with no source, recipe
  inputs that block crafting, and dangling references. Use it to find remaining obtainability gaps.
- [ ] **Content > Build Item Source Index** — generates Resources/item_sources.json for the
  tap-an-ingredient popup. Re-run when content changes. (Then tap an ingredient name in any recipe to
  see where it comes from.)
- [ ] **Icon atlas re-batch (now SAFE, corrected by the compositor).** `tools/build_atlases.py` was
  re-run: it pulls each material sheet's Approved/Imported per-cell art from the tracker and stitches
  it so the physical layout matches `sheets.js` cell->name, then rewrites `icon_atlas_manifest.json`.
  The atlases are verified name-under-art (contact sheets). To batch these 13 material sheets, run in
  order: **1) Art > Slice Icon Atlases** (re-slices for the new per-sheet heights), **2) Art > Reassign
  Icon Atlas Sprites** (now maps correctly). Verify a few item icons in-game. If anything looks off,
  the item icons are individual PNGs until step 2, so it is reversible. (Weapons/armor + cultivation/
  delving_special/tailoring_* stay on individual PNGs; not yet atlased.)

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
