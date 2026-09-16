# Mobile Playtest Checklist, 0.1.4

What to verify on the 0.1.4 phone build, grouped by the release notes. Check items off as you confirm
them on device. Passed 0.1.3 checks (data safety, combat hub redesign, dungeon popup, hotbar, thematic
upgrades, XP curve) are dropped here; pull them from git history if you need to re-run one.

---

## Step 0, Unity editor (run + save the scene before building)

- [ ] **Content > Create Equipment** and **Content > Add Gear Crafting Recipes** (new bows, greataxe, shields + recipes)
- [ ] **Art > Import Generated Icons** (assigns the bow / shield / greataxe icons)
- [ ] **Build > Bake Merchant Sell UI**, **Build Eat Quantity UI**, **Bake Send To Player Panel**, **Build Guild Bank UI** (shared quantity picker)
- [ ] **Fix > Add Friends Button To Chat Dock** (Friends button on the dock)
- [ ] **Fix > Upgrade Zone HeroArt to Cover** (zone banner fills without stretching)
- [ ] **Fix > Dedup Combat Hub Panels** (one ZoneDetailPanel / DungeonInfoPopup)
- [ ] **Build > Bake Pre-Boss Lobby** (NEW, the lobby is now baked; placeholder-skinned for this build)
- [ ] **STILL PENDING (inspector):** assign `CombatHubUI._roomTypeIcons` (7: Standard, Elite, Safe, Boss, Puzzle, Treasure, Trap) + a dungeon glyph. Not a blocker.

---

## 1. Weapons, shields, handedness (new)

- [ ] Craft and equip a **shortbow, longbow, and crossbow**; each equips and shows its own speed on the item card.
- [ ] Equip a **greataxe** (two-handed) and a one-handed weapon; the two-handed weapon stows any shield.
- [ ] Equip a **shield** in the off-hand with a one-handed weapon (sword, dagger, axe, wand, crossbow). It grants a block chance / defense on the character sheet.
- [ ] Equipping a two-handed weapon (staff, shortbow, longbow, greataxe) **blocks the off-hand** and stows the shield; re-equipping a one-hander frees it.
- [ ] In combat, a shielded loadout **blocks some hits** (reduced damage), and the two-handed sets hit harder.

## 2. Combat feel

- [ ] **Attack speed varies by weapon.** A dagger swings noticeably faster than a greataxe; procs and auto-eat keep pace on the tick.
- [ ] **Parallax.** Combat backgrounds have a gentle sway / depth, no visible seams or jitter.

## 3. Co-op ally cards (needs a second device)

- [ ] In a party fight, teammates show **ally cards** with live HP.
- [ ] Status effects on a partner show as **chips** on their card; a downed or left partner reads as such.
- [ ] **Tap an ally card** to inspect that partner's gear and stats.

## 4. Concurrent idle (new)

- [ ] Start a **gather / craft / cook** action, then enter a zone or dungeon. The idle bar **keeps ticking** during combat (it used to stop).
- [ ] No production tap target pops over the combat screen; leaving combat, the action is still running.
- [ ] Reverse order works: start a production action **while already in a fight**, combat is not interrupted.
- [ ] Starting a new production action still **replaces** the running one.

## 5. While You Were Away

- [ ] Return from an idle session that leveled a talent: the level-ups **float up as toasts** over the away screen (the XP and item totals still list on the summary).

## 6. Selling + quantity control (new)

- [ ] **Sell to the Traveling Merchant**, single item and a bulk selection, both pay out Silver Marks.
- [ ] The quantity control is the **same everywhere**, Merchant sell, Eat, Send to Player, and Guild Bank deposit + withdraw: **type a number**, **drag the slider**, and **Max** all agree and cap at what you hold.

## 7. Friends from the chat dock (new)

- [ ] Expand the chat dock and tap **Friends**, the Friends panel opens (previously only reachable through chat).

## 8. Art

- [ ] The **shortbow, crossbow, greataxe, and shield** show their new icons in inventory / crafting.
- [ ] A zone's **hero banner** on the zone detail page fills cleanly (cropped, not stretched).

## 9. Fixes (retest)

- [ ] **Navigation.** Every bottom-nav / drawer button opens its panel (no dead menu).
- [ ] **Combat hub.** Only one zone-detail panel and one dungeon popup; opening a zone detail shows the skinned version.
- [ ] **XP bar.** The combat-hub Grimoire XP bar fills to the real fraction (not always full, not stretched).
- [ ] **Auto-eat.** Only eats from draughts you carry (potion-gated); runs out when the draughts do.

---

## Known-early / deferred (do not expect these yet)

- **Pre-boss / dungeon lobby** is now baked but **not skinned** for 0.1.4, it uses placeholder art. Function should be intact (open, ready, invite, start).
- **Co-op** (ally cards, shared dungeons) is a first pass; note anything that soft-locks with two devices.
- **Room-type icons + dungeon glyph** are blank until assigned in the editor (Step 0 pending item).
- Backgrounds, guild emblems, hub-station props, and the guild banner kit are approved but not all imported.

---

## 10. Current build, playtester bug fixes + session changes (retest)

**Character page**
- [ ] Both the **primary weapon slot** and the **off-hand slot** are visible (no overlap), the **Grimoire slot** is back in place, and the **Quiver slot is gone** (BUG-092).

**Combat**
- [ ] **Warden**: the ability-ring stack shows more than just Full Draw at your level (rings unlock by level again).
- [ ] **Warlord**: Surge combos resolve (Savage Strike / Power Blow / Warcry, etc.); the combo queue shows tapped buttons + previews the ability name.
- [ ] **Zone boss**: beat one, keep fighting, it does NOT reappear within seconds (180s cooldown, BUG-088).

**Economy / items**
- [ ] Tap an inventory item, the detail popup **grows to fit** its text and shows a **flavor line** on every item, materials included (BUG-093).
- [ ] **Royal Merchant > Merchant tab**: buy Daily Sell Cap 1,000 (400 GM) / 2,000 (900 GM); the merchant sell cap bar shows the new limit (BUG-089).
- [ ] **Bronze bars** are cheaper to smelt (BUG-090); **bows** craft from thread, **crossbows** from limbs (BUG-094).

**Guild**
- [ ] Tap the treasury **SM/GM balance** ("tap to donate") to move your own Marks into the guild bank (BUG-091).

**Other**
- [ ] **Quest board** does not flicker on expand / minimize / accept, or during idle gathering.
- [ ] **Exchange Browse**: the Store / Auction / Buy Order filter switches the Fresh Market feed.
- [ ] **Offline combat, cold launch**: enter a zone fight, background, force-stop the app, relaunch, the While-You-Were-Away screen shows the away combat.
