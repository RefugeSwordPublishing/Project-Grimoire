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
- [ ] **Build Eat Quantity UI** — adds the bulk-eat quantity popup (drag slider + Eat/Cancel). The
  inventory Use action opens it for stacks > 1. Run once; skin the card/slider as desired.
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
- **Eat-quantity for stackable consumables** — backend DONE: `InventoryManager.UseConsumable(item, n)`
  bulk-consumes up to n (capped at held, applies the per-unit effect each time). Still TODO: the
  quantity slider/drag-bar UI wired into the consume flow (InventoryUI / InventoryContextMenuUI) with
  a small baker. Design Qs remain: HP overheal cap, whether food TimedBuffs stack duration or refresh.
