---
type: implementation-status
updated: 2026-07-11
purpose: Single source of truth for WHAT IS ACTUALLY BUILT vs. design intent in the specs.
audience: Claude (Chat or Code) starting a session. Read this FIRST, then the relevant spec.
---

# Project Grimoire — Implementation Status (as-built)

The spec files in `docs/` describe **design intent**. This file records **what is actually
implemented in code** where the two diverge. When they conflict, the code (and this file) win.
Claude Code updates this file as features land; Claude Chat should read it before any design work
so it builds on the current state rather than the original design.

## Repo layout
- `Project-Grimoire` (public) — this repo: design docs (`docs/`), Supabase SQL (`supabase/migrations/`), and the Unity project as a **git submodule** at `ProjectGrimoire/`.
- `ProjectGrimoire` (private) — the Unity/C# game. Chat cannot read it (private → 404); design docs + SQL here are public and readable.

## Phase status
- **Phase 1:** complete (managers, ScriptableObjects, Bowstring mechanic, idle loop, Supabase + FCM).
- **Phase 2:** guild system + Guild Merchant complete (below). Remaining Phase 2: Runic Constellation, Summoner, Lifebinder, Vanguard combo, aggro, zone content, Exchange fees, sprite pass.

## Combat vertical slice + Warden bow — AS-BUILT (2026-07-11)
The Warden Bowstring was **redesigned in-engine from playtesting** and **diverges from
`warden-combat-spec` v0.1**. Full detail + open questions for re-spec: **`warden-archery-asbuilt.md`**.
Summary of what actually ships:
- **3D combat scene:** perspective camera (tilted ~10° down) → RenderTexture → full-screen RawImage
  backdrop on the combat panel (overlay canvas draws HUD on top). World quads: player (launch), enemy
  (SpriteRenderer + invisible MeshCollider sized to sprite), parallax bg. `CombatSceneController` owns it;
  `Tools > Grimoire > Convert Combat Scene to 3D` builds/wires it (idempotent, dedupes).
- **Bow mechanic:** aim = horizontal drag around a fixed screen-centre ref (`Aim Center X`); draw =
  vertical pull → arc **loft** (more draw = higher arch). Arrow arc is **Linecast-traced vs the enemy
  collider** → hit = arc passes through the body; **draw is effectively the vertical aim**. No draw-power
  damage, no draw-%% bar; a live trajectory line previews the arc (`_trajectoryReveal` hides the end).
- **Weak point** = hit UV vs `EnemyData.weakPointMask` (×2.0) with optional per-idle-frame `idleMasks[]`.
  A landed active shot then rolls **accuracy vs Evasion/Block** (Evaded/Blocked); no RNG miss on a good
  shot. Idle auto-attack keeps full-RNG accuracy. `AttackOutcome` = Hit/Miss/Evaded/Blocked.
- **Enemy depth:** `EnemyData.combatRange` (Close/Medium/Far/VeryFar) → fixed world Z (constant per enemy).
- **HP:** persists between fights; death = retreat to hub (no free heal); out-of-battle HP regen
  (`_hpRegenFraction`); in combat recover via food / idle auto-eat.
- **Enemy animation:** `EnemyData` idle/attack/death `Sprite[]` + `animFPS`, static `icon` fallback
  (idle loops, attack once→idle, death once→hide).
- **NOT built (Warden remainder):** the ability ring (Barbed Shot / Long Shot / Model C: Fade + Armor
  Piercer), reveal talents, per-subclass tuning — pending Chat re-spec on top of the arc mechanic.

## Persistence — Supabase wired behind login (2026-07-11)
`GameManager` routes inventory/talents/currency **load+save to Supabase when signed in** (`ServerAuthed`),
with the local JSON save as the offline fallback. Added `SupabaseManager.Upsert` (Prefer merge-duplicates)
and `PlayerDataService.LoadTalents`/`SaveAllTalents` (upsert on PK player_id,talent_id). Combat XP
self-persists server-side; **equipped Grimoire server-save is still a follow-on**. Auth session persists
in PlayerPrefs (auto-refresh) so testing doesn't re-prompt login.

## Session 2026-07-11 — persistence, consumables Part A, fixes
- **Idle gathering fixed.** Root cause: category-panel Sheet background is a raycast target with no click handler, so taps on talent/activity tiles bubbled up to the full-screen panel-root Close button — the panel opened the detail view then instantly closed. Fix: new `ClickSwallow` (Assets/Scripts/UI/ClickSwallow.cs) on the Sheet consumes clicks; taps outside still close. Applies to Gathering/Processing/Crafting.
- **Inventory fixes.** Grid now populates on open (`InventoryUI.OnEnable` refreshes — nav drawer shows via SetActive, not Open()). Quality border no longer renders as a white box behind transparent icons (item backdrop inset + opaque). Enemy sprite red tint fixed earlier (ZoneCombatView resets colour to white with a real icon).
- **Inventory tabs consolidated 10 → 5:** All / Materials (Raw+Rare+Craftables) / Consumables (+Scrolls) / Equipment (+Grimoires) / Quests. Currency items surface under All only. `InventoryUI` uses a CategoryFilter group model; single width-independent row. `Tools > Grimoire > Rebuild Inventory Tabs` rebuilds in-scene without a full canvas rebuild.
- **Enemy asset cleanup:** deleted 14 orphaned root `Data/Enemies/*.asset` duplicates (zones reference the `GrimwoodFringe/` + `SaltmarshShore/` subfolder copies).
- **Local persistence (dev testing) — BUILT.** `Assets/Scripts/Core/LocalSave.cs` writes JSON to `persistentDataPath/grimoire_save.json`: currency, talent progress, inventory (exact slot layout), equipped Grimoire, per-Grimoire combat XP/levels. Loaded on boot in `GameManager.InitGame` before idle resume; throttled autosave (~4s) on inventory/talent/combat change; flushed on pause/quit (synchronous write, so editor Stop persists). Milestone stat bonuses replayed on load (talents + combat). `Tools > Grimoire > Delete Local Save` resets. **At alpha:** swap for the Supabase services (`InventorySyncService`, `PlayerDataService` — needs an upsert path for talents) behind the same call sites; server saves require login.
- **Consumables Part A COMPLETE.** `BuffManager` (Assets/Scripts/Core/BuffManager.cs): `TimedBuff` meals apply buffStats/buffValues to `PlayerData.*Bonus` for `buffDurationSeconds`, reverse on expiry; one general + one Vanguard-stamina meal coexist, new meal replaces old in-category. `WeaponManager` (Assets/Scripts/Core/WeaponManager.cs): `WeaponCoating` stores charges; each landed hit spends a charge and applies a DoT (damage/tick × duration) to the enemy, ticked by `CombatManager.TickEnemyDot` (1s ticks, can land the kill, cleared on spawn). Both auto-created by GameManager (`.Buffs` / `.Weapon`); `UseConsumable` wires both branches. **Deferred:** regen-type meals need a `StatType` HP/stamina-regen member (skipped with a warning for now); manual hotbar slot assignment still pending.

## Guild system — DONE (2026-07-10)
Unity: `Assets/Scripts/UI/GuildBankUI.cs` (+ `Editor/BuildGuildBankUI.cs`). SQL: migrations 002, 010–018.
Tabs: **Home / Roster / Bank / Upgrades / Prestige / Merchant / Settings**.
- Discovery + create (`create_guild` RPC) + join (`join_guild` RPC / apply for invite-only).
- Bank: responsive tile grid, donate/withdraw, expand slots, material requests, bounties.
- Upgrades: roster-tier purchase, consumable guild buffs.
- Prestige: milestone spend, hub stages.
- Roster shows username + equipped Grimoire + combat level (PostgREST embed).
- Settings: tax vote, join-policy toggle (Open/Invite-Only), name-change vote (3-month cooldown), announcement, disband.

### Voting (as-built) — differs from spec
- **2/3 approval of the full roster** (`ceil(2/3 × member_count)`), not "majority of GM + Officers".
- Applied server-side by `cast_guild_vote` RPC (migration 015); one ballot per member.
- Passes and applies **immediately** on reaching threshold (no 48-hour delay). Open until threshold / all voted / 7 days.
- **Auto-close (built, migration 019):** `close_expired_guild_votes()` SQL function, run hourly by pg_cron, closes open votes once 7 days elapse OR all members have voted.

### Guild Merchant — as-built
- Members-only listings; fee = **half the guild tax**, credited to the guild bank on sale.
- **Dual-currency price:** a listing carries both `price_sm` AND `price_gm` (either may be 0) — a combined-marks price, e.g. "3 GM 500 SM". (Superseded the original single-SM design, then a brief SM/GM toggle.)
- Buying goes through the atomic `buy_guild_listing` RPC (migrations 016→018): charges the buyer both currencies, pays the seller minus the per-currency fee, credits the guild bank the fee, deletes the listing. Items escrow out of inventory on post, return on cancel.
- **Expiry sweep (built, migration 019):** `sweep_expired_merchant_listings()` SQL function, run hourly by pg_cron, returns escrowed items from listings past `expires_at` (7 days) into the seller's `player_inventory` (loaded on next session) and deletes the listing.

### Scheduled jobs (migration 019)
Implemented as SECURITY DEFINER SQL functions run by **pg_cron** (hourly), not Deno Edge Functions — both are pure DB ops. Requires enabling the `pg_cron` extension in the Supabase dashboard. Jobs: `close-expired-guild-votes`, `sweep-expired-merchant-listings`.

### Guild constants (as-built — do not re-derive from memory)
- **Create cost:** 2,000 GM. Name 3–30 chars. Join policies: `open`, `invite_only` only (no "Closed" yet). Default tax 2%.
- **Roster tiers** (cap → GM cost): 10→start, 20→5k, 30→15k, 45→35k, 60→75k, 80→150k, 100→300k (7 tiers).
- **Prestige milestones:** 1/5/10/20/35/50/75/100 → hub stages Campfire Gathering → Tent Camp → Encampment → Army Encampment → Fortress → Castle → Castle with Village → Stronghold Capital.
- **Consumable buffs** (5): Prospector's Fortune 3,000 (+15% rare, 24h) · Merchant's Window 2,000 (guild tax 0%, 24h) · Bountiful Harvest 2,500 (+20% gathering, 24h) · Hunter's Providence 3,500 (+25% SM/GM drops, 24h) · Lucky Charm 4,000 (+10% LCK, 12h).
- **Bank:** 50 slots base; Officers/GM expand +10 at a time from the bank.

### Reusable ItemListingComposer
`Assets/Scripts/UI/ItemListingComposer.cs` — a shared, domain-agnostic composer: searchable item
picker (live-filter over the ItemRegistry, held-qty per row) + quantity + optional dual SM/GM price +
optional note. Driven via `Open(title, confirmText, requireOwnership, showPrice, showNote, callback)`.
Currently backs guild merchant listings and material requests. **Intended reuse:** Wayfarer's Exchange
buy orders / sell orders / auctions (buy orders → `requireOwnership:false`, escrow currency instead of item).

## Combat progression — foundation BUILT (migration 009 + CombatXPManager)
- Tables `player_grimoire_levels` (per-Grimoire combat_level + combat_xp) and `player_stat_bonuses` (milestone-keyed permanent stat grants), both RLS-owner-only. Helper `total_combat_level(player_id)` sums per-Grimoire levels. `players.combat_level` (migration 013) caches the total for other players to read (guild roster).
- `CombatXPManager.cs`: loads both tables, creates rows for owned Grimoires, PATCHes level/XP on level-up, posts milestone stat bonuses, caches Total Combat Level, exposes `TotalCombatLevel`. `CombatTabUI` displays it.
- **Zone gating logic BUILT:** `ZoneAccess.cs` is the single source of truth for the tier→level thresholds (T1≥1 · T2≥21 · T3≥51 · T4≥91 · T5≥141), with a per-zone `combatTalentLevelRequired` override. `CombatManager.EnterZone(zone)` now returns `bool` and refuses locked zones. `ZoneData` carries `tier` + `combatTalentLevelRequired`.
- **Combat hub BUILT (`CombatHubUI.cs`):** nav → Combat shows large Zone/Dungeon **tiles** — art placeholder (`ZoneData.icon`, null → colour box), title + tier, lock state via `ZoneAccess`, and per-zone **enemy roster with spawn rate** (`EnemyData.spawnWeight` share; elites/boss tagged). Tapping an unlocked tile calls `CombatManager.EnterZone`. Raids = Phase-4 placeholder. `BuildCombatTabUI` auto-fills tiles from every `ZoneData` asset.
- **Combat loop — BUILT (real-time idle, in `CombatManager`):** `EnterZone` stops any idle gather/craft (`Idle.StopAction` — one activity at a time), then runs a real-time loop: player and enemy each attack on **independent timers** (`_playerAttackInterval` 2s, `_enemyAttackInterval` 2.8s); on kill → roll `dropTable` + Silver Marks + `CombatXP.AwardKill` to the equipped Grimoire → brief respawn delay → next enemy (weighted spawn, elite roll 6%+0.1%/level cap +9%). Exposes `PlayerAttackProgress`/`EnemyAttackProgress`, HP, and events `OnEnemyChanged`/`OnPlayerAttack`/`OnEnemyAttack`/`OnCombatLog`.
- **Combat view — BUILT (placeholder art, `ZoneCombatView.cs`):** entering a zone opens an over-the-shoulder screen — background/enemy/player **placeholder boxes**, enemy + player **HP bars**, and **attack-cadence bars** (fill = timer; idle auto-fires at full, active-play tap window later). Back stops combat → hub. `EnemyData.icon`/animations plug into the existing hooks during the sprite pass.
- **Active-play seam BUILT (`ActiveCombatMechanic`):** the abstraction each Grimoire path implements — `Configure(subclass)`, `SetEngaged(bool)`, `OnAttackFired(multiplier)`. `CombatManager.SetActiveMechanic` registers it; the player's strike is driven by the mechanic (when the attack bar is full) instead of the idle auto-fire, with a fallback auto-shot if the player idles.
- **Warden Bowstring integrated (`WardenBowstringMechanic`):** wraps the existing `BowstringMechanic`; the combat view's full-screen input surface turns press/drag/release into a bow draw, and the shot's damage multiplier (draw power × weak-point crit) scales the strike. Engaged automatically when the equipped Grimoire is Warden (Sharpshot/Lone Wanderer); other paths fall back to idle auto-attack. **Template for the remaining mechanics** — Arcanist (Constellation) and Vanguard (Combo) implement the same seam.
- **Not yet:** Constellation + Combo mechanics, zone-boss spawns (active-only), Slaying-talent elite bonus, sprites/animations (`OnPlayerAttack`/`OnEnemyAttack` hooks + weak-point glow).
- **Spawn-rate buff bonus — DECIDED: none.** Per the combat spec, no buff modifies enemy spawn rate (buffs affect drops/yield/marks/LCK only). `CombatHubUI.SpawnBonusPercent()` and the "(+X%)" slot were removed.
- `ZoneData.icon` / `EnemyData.icon` are placeholder slots for the later sprite pass.

## Zone enemy content — Tier 1 authored (Grimwood Fringe + Saltmarsh Shore)
- `Editor/CreateZoneEnemies.cs` (menu: Tools > Grimoire > Create Zone Enemies) authors `EnemyData` for both Tier-1 zones and wires `ZoneData.enemies` + `zoneBoss`. Stats from `enemy-zone-tables.md` (names/levels/drops) + `stat-scaling-combat-formulas.md` (Tier-1 damage 4–12). 6 standard/elite + 1 boss per zone; `spawnWeight` set (common high, elite=1); loot via `dropTable` + Silver Marks + Slaying XP.
- **First-pass balance — tune later.** Icons null (sprite pass). Remaining zones (Ashfen Mire, Ironspine Reaches) + dungeon randomization still to author.

## Grimoires — assets + equip UI BUILT
- `Editor/CreateGrimoires.cs` (Tools > Grimoire > Create Grimoires) authors the **7 free-starter `GrimoireData`** (Warden: Sharpshot, Lone Wanderer · Arcanist: Runeweaver, Summoner, Lifebinder · Vanguard: Warlord, Shadowblade) and wires the scene `GrimoireManager` (owned list + default equipped **Sharpshot**). `subclassName` matches the combat-progression id convention.
- `GrimoireEquipUI.cs` + `Editor/BuildGrimoireEquipUI.cs`: a **Grimoires** button on the Character page opens an equip picker listing owned Grimoires; Equip calls `GrimoireManager.EquipGrimoire` (24h swap cooldown enforced/shown). `GrimoireManager.Owned` now exposes the list. Equipped path drives combat (Warden → Bowstring active mechanic).

## Other notable as-built facts
- Inventory, gathering→live-inventory, talent tiles with live XP, Combat Tab under Character, Exchange lock gate: built.
- Auth: Supabase Auth (JWT) wired into the core loop; RLS on all tables; guild RLS recursion avoided via SECURITY DEFINER helpers `auth_guild_ids()` / `auth_officer_guild_ids()`.

## Combat feel — as-built (2026-07-11)
- Real-time loop with a **live combat view** (`ZoneCombatView`): enemy/player HP bars, dual attack-cadence bars, hit/miss marker over the enemy (`OnPlayerHit`), and the Bowstring draw visuals (charge meter, DRAW %, rotating aim arrow).
- **Idle vs active arbitration:** idle auto-attacks fire **instantly** when the cadence bar fills, but only while the player isn't drawing (or within a 1.5s grace after). Drawing hides the idle bar and takes over; active shots fire on **release**, instantly, with a 0.5s anti-spam cooldown. `CombatManager.IdleAttackActive` drives the bar's visibility.
- **Player HP persists between fights** (no heal-on-kill). Defeat (HP→0) triggers a full-heal "retreat". Recovery is meant to come from consumables (active) / idle auto-eat (idle) — neither built (see below).
- 7 starter Grimoires equippable from the Character page; equipped path selects the active mechanic (Warden Bowstring live; Arcanist/Vanguard fall back to idle).

## Consumables — Part A foundation BUILT (2026-07-11)
Per `consumables-spec.md`. Done so far:
- **`ItemData`:** `ConsumableEffectType` enum (None/InstantHP/InstantMana/InstantStamina/CureDebuff/TimedBuff/WeaponCoating/ZoneMap) + effect fields (effectValue, cooldownSeconds, inventoryOnly, requiredPath, buffStats/Values, duration, curedDebuffs, coatingCharges, dot*).
- **`PlayerData` resources:** `CurrentHP/Mana/Stamina` pools with `GetMaxMana()` (50+WIL×2), `GetMaxStamina()` (30+VIT×1.5), `EnsureResourcesInit`, `RestoreHP/Mana/Stamina`, `DamageHP`, `FullHeal`. `GrimoirePath.None` added (path gate).
- **Combat HP moved to `PlayerData.CurrentHP`** — persists between fights; consumables can heal it. `CombatManager.PlayerHP` reads it.
- **`InventoryManager.UseConsumable`** now switches on `effectType`: InstantHP/Mana/Stamina (path-gated), ZoneMap; CureDebuff no-ops (no debuff system yet); TimedBuff/WeaponCoating gated + return false (pending BuffManager/WeaponManager); inventory-only items blocked during active combat.
- **Combat hotbar BUILT (`CombatHotbarUI`):** 3 slots at the bottom of the combat view — slot 1 best Healing Draught, slot 2 class resource (Mana Vial/Endurance Draught, else 2nd HP), slot 3 Antidote. Auto-fills from inventory (highest quality held), tap → `UseConsumable`, per-slot cooldown (button disables + countdown). Manual assignment + `player_settings` persistence still pending.
- **Consumable items authored (`CreateConsumables` tool):** Healing Draughts (Crude/Refined/Masterwork), Refined Mana Vial (Arcanist), Refined Endurance Draught (Vanguard), Refined Antidote — registered in the ItemRegistry. Dev **+Consumables** button on the Combat Progression panel grants a test stock.
- **Regen BUILT:** `CombatManager.TickResources` — mana 1/sec out of combat (Arcanist), stamina 2/sec in combat (Vanguard); HP has no passive regen.
- **Idle auto-eat BUILT (free tier):** at 25% HP, after a 2s delay, once per encounter, `CombatManager` auto-consumes the lowest-quality Healing Draught in stock. Royal-Merchant upgrade tiers + `player_settings.auto_eat_tier` still pending.
- **Safe area:** `Editor/ApplySafeArea.cs` (Tools > Grimoire > Apply Safe Area To Panels) wraps every panel's HUD in the existing `SafeAreaFitter` so close buttons/headers clear the notch (background stays full-bleed). Idempotent.
- **Part A COMPLETE (2026-07-11):** `BuffManager` (meals) + `WeaponManager` (poison coating + enemy DoT) built — see Session 2026-07-11 above. Still pending: regen-type meals (need StatType HP/stamina-regen member), manual hotbar slot assignment + `player_settings` persistence.

## Consumables / resources — original design notes
The combat hotbar + auto-eat the user wants are **blocked on design**:
- **Resources:** only **HP** exists in code. Game-design doc says WIL → "mana pool" (intended, unbuilt); **Lifebinder uses HP as its resource, no mana** (contradiction to resolve). **Stamina** isn't a real concept anywhere. → a combat hotbar today is HP-only.
- **`ItemData`** has only a bare `isConsumable` bool — no heal amount / buff / duration / effect-type. **`InventoryManager.UseConsumable` only routes zone maps**; food/potions/poisons have **no effect implementation**.
- Docs name the item *types* (Healing Draught, Antidote, Poison Coating, meals/stews) but not their *effects*. **Royal Merchant** (for the upgradeable auto-eat tiers) is **not built**.
- **Rules set by the user:** stat **buffs → inventory-use only, never in active combat**; **instant fills (HP) → combat hotbar**; **idle auto-eat** free at 25% HP, higher thresholds upgraded via Royal Merchant.
- **Next:** Chat writes `consumables-spec.md` (effects per item, food-vs-buff ruling, combat-hotbar list, poison model, Royal Merchant auto-eat tiers); then Code adds `ItemData` effect fields → real `UseConsumable` → combat hotbar (HP fills) → idle auto-eat.

## Do-not-build (still in force)
Raids, dungeon room puzzles, faction system, Bloodweaver/Warlock/Kensei/Beastbond (DLC), guild bounties (post-launch), Divination talent, Legendary tier, Black Ledger.
