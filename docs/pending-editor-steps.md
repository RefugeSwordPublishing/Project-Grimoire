# Pending Unity Editor Steps

Running checklist of Unity editor actions to run when back at the machine (things Claude Code
can't do remotely). Check off as done; Claude keeps this updated.

Menu items are under **Tools > Grimoire > Build > ...** unless noted. After running bakers,
recompile/redeploy to the phone to test.

## To run (newest first)

- [ ] **Build Chat Pill** — adds the top-right "Messages" unread pill (DM unread badge). New this session.

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
- **Alchemy health-potion recipes** — health potions exist as items but Alchemy has no recipe to
  craft them. Author alchemy recipes (editor Create/Add-recipes script, then run it) producing the
  existing potion items, gated by Alchemy tier. Recipe pattern: Editor/AddGearRecipes.cs.
- **Eat-quantity for stackable consumables** — InventoryManager.UseConsumable consumes exactly 1.
  Add bulk-consume (eat N up to the stack) with a quantity slider/drag bar showing the full stacked
  amount. Manager method is pure code; the slider UI needs a small baker. Design Qs: HP overheal cap,
  whether food TimedBuffs stack duration or refresh.
