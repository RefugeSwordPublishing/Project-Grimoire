# Mobile Playtest Checklist, 0.1.3 "Tempered"

What to verify on the 0.1.3 phone build. Grouped by the release notes. Check items off as you confirm
them on device. Earlier-build checks (hub reskin, quest board, summoner combos, BUG-001..009) passed in
prior builds and are dropped here; pull them from git history if you need to re-run one.

---

## Step 0, Unity editor (done this build)

All run and the scene saved before the build:

- [x] **Build > Bake Combat Hub** (hub redesign templates + mobile fixes)
- [x] **Art > Import Generated Icons** (27 item icons)
- [x] **Art > Import Spell Projectiles**
- [x] **Art > Import Debuff Icons**
- [x] **Art > Import Inventory Tab Icons**
- [x] **Art > Import Hazard Icons**
- [ ] **STILL PENDING (manual, inspector):** assign `CombatHubUI._roomTypeIcons` (7 sprites: Standard, Elite, Safe, Boss, Puzzle, Treasure, Trap) and a dungeon glyph on the Dungeon button / popup Icon. Until then, the dungeon popup's room-type chips show no icon and the Dungeon button/popup icon is blank. Not a blocker for testing the rest.

---

## 1. Fixes (retest)

- [ ] **Data safe on restart.** Force-close and relaunch a few times, including a cold start. Your account loads from the server; you never see an old local copy that looks like a reset.
- [ ] **Combat XP saves.** Fight, leave, relaunch: XP is intact (not reset to zero). A dungeon run awards XP like a zone fight.
- [ ] **Guild bank deposit.** Add an item to the guild bank: you get a quantity picker, and the item appears in the bank.
- [ ] **Send to a friend, repeated.** Send an item, then send another. The send button stays usable after the first.
- [ ] **Auto-Eat: Quick purchase.** Buy it from the Royal Merchant; Confirm completes instead of doing nothing.
- [ ] **Zone boss Ready.** Spawn a zone boss and open its lobby; the Ready control is reachable and the fight starts.
- [ ] **Dungeon screen.** Entering a dungeon shows the dungeon + room name; a safe room reads as a safe room, not a blank screen.
- [ ] **Quest honesty.** A combat-XP quest pays out; the weekly talent-XP quest shows the real target number.

## 2. Combat menu hub (new)

- [ ] The Combat menu reads as a **hub**: zones are **tiles grouped by tier**, not one long list.
- [ ] Tapping a tile's **Enter** button enters the zone directly (two taps from the bottom nav).
- [ ] Tapping the tile **body** opens the zone's own page (a separate screen, not an expanding row).
- [ ] Zone page shows enemies as **chips grouped Standard / Elite / Boss** (spawn % on standard; a marker on elites/bosses), with **Enter Zone** and a **Dungeon** button at the bottom.
- [ ] The **Dungeon button is hidden until you have entered a zone at least once**, and shows disabled with a reason when the dungeon is not reachable yet.
- [ ] Nothing runs off the **right edge** on the phone (zone tiles, enemy chips, and dungeon room chips all fit two columns).

## 3. Dungeon info popup + co-op (new; co-op is early, needs a second device)

- [ ] The Dungeon button opens an **info popup**: name, tier + recommended level, room count, boss, first-clear reward, and the room-type mix, with **Enter Lobby** and **Cancel**.
- [ ] **Solo:** Enter Lobby, then Enter Dungeon (party of one), drops you into the run.
- [ ] **Co-op:** invite a guildmate into a lobby slot; they see the lobby within a few seconds. Both Ready, host taps **Enter Dungeon**.
- [ ] Both players land in the **same dungeon layout** (same rooms in the same order).
- [ ] **Shared enemy health:** a mob fought by both dies faster than solo, and both players advance together.
- [ ] Leaving / a knockout: the other player keeps going (co-op is a first pass, note anything that soft-locks).

## 4. Combat feel + effects

- [ ] **Element spells.** An Arcanist cast fires the **element you drew** (Ignis reads as fire, Glacius as ice, and so on), not a plain yellow box.
- [ ] **Enemy debuffs.** Poison and bleed effects show as **icons above the enemy**.
- [ ] **Dungeon hazards.** A hazardous room shows a **chip naming the danger** on the dungeon banner. (Icon appears once the hazard art is assigned; the name shows regardless.)

## 5. New systems

- [ ] **Editable hotbar.** Set the three combat consumable slots from the combat screen and from the character page; the loadout persists across relaunch. Only combat instants are eligible.
- [ ] **Thematic upgrades.** Leather and cloth gear upgrade with **sinew cord / spun thread**, not a metal fitting. The two new component lines are craftable.

## 6. Balance + feel

- [ ] **Rising XP.** Higher-tier gathering and cooking earns **more XP per second**; moving to a new tier is never a step backward.
- [ ] **Tier raises stats.** A fresh higher-tier weapon or armor beats a once-upgraded lower-tier piece (a new Ash staff over an upgraded Pine one).
- [ ] **Meals.** Every cooked dish grants a **timed buff**, and the item card names it.

## 7. Art

- [ ] **Inventory tabs** show icons for All, Materials, Consumables, Equipment, and Quests.
- [ ] **Item icons** are correct (check the new arcanist / vanguard crafting materials, plus the earlier batch).
- [ ] The **app icon** is the new one on the home screen.

---

## Known-early / deferred (do not expect these yet)

- **Co-op dungeons** are a first pass and untested on two devices. In co-op, puzzles and hazards are handled per-player, "Run Again" from the result screen re-runs solo, and an ended lobby is not swept.
- **Dungeon popup room-type icons + the dungeon glyph** are blank until `CombatHubUI._roomTypeIcons` and the dungeon icon are assigned in the editor (Step 0 pending item).
- Backgrounds, guild emblems, hub-station props, and the guild banner kit are approved but not yet imported.
