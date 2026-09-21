---
type: game-state-briefing
updated: 2026-09-20
purpose: A single as-built picture of Project Grimoire for a design collaborator who cannot read the private Unity code, written to support designing a player-retention / "reason to advance" mechanic.
audience: Chat (claude.ai) design collaborator.
sources: implementation-status.md (as-built source of truth, code wins over specs), both CLAUDE.md files, and the specs indexed in docs/README.md.
---

# Project Grimoire, Game State Briefing (as-built)

Project Grimoire is a Unity 6 / C# mobile idle RPG. This document describes what is actually
built, so a retention mechanic can be designed on the real systems rather than the original
design intent. Where a spec and the code disagreed, the code (as recorded in
`implementation-status.md`) wins here. Open disagreements and uncertainties are listed in the
final section so they can be verified.

A note on scale: the game is deep and content-complete across five tiers, but most combat is
idle auto-resolution and boss/elite special abilities are still reference text. The current
reasons to keep advancing are zone gating, gear tiers, permanent stat milestones, Slaying
titles, and guild prestige. There is no individual prestige or rebirth loop today. That gap is
the design space this briefing is meant to serve.

---

## 1. Core gameplay loop and session shape

The player equips one Grimoire (a subclass identity) and progresses on two interleaved tracks:

1. **Idle production.** Gathering and crafting Talents run as timed cycles. One action runs at a
   time. Progress accrues while the app is foregrounded, and a While You Were Away (WYWA) summary
   credits offline time on return.
2. **Combat.** Entering a zone opens a real time combat view. Player and enemy attack on
   independent timers. Combat is largely automatic (idle auto-fire), with an optional active
   mechanic per path that a foreground player can drive for more damage.

**Idle and combat are mutually exclusive today.** Entering a zone stops any gathering or crafting
action, and only one WYWA summary fires. Letting production run concurrently with combat at full
rate is designed (`concurrent-idle-progression-spec.md` v1.2) but NOT built. Dustin has flagged
concurrency as a retention play.

**Session shape.** Short foreground bursts (queue an idle action, or fight actively for a stretch)
plus passive accrual between sessions. The WYWA screen on return is the main re-engagement surface.
Offline combat is summary-only: a running tally of combat rewards is shown on return, there is no
offline combat simulation.

**Foreground-only progression.** Idle production and combat only advance while the app is
foregrounded. Offline is reconstructed at resume from elapsed time (WYWA), not simulated live.

---

## 2. Combat

### Grimoire combat levels (the spine)

Combat progression is per-Grimoire, not a shared combat Talent. Each owned Grimoire has its own
combat level 1 to 100, stored in `player_grimoire_levels` (level plus XP, own-row RLS).

```
Total Combat Level = SUM of every owned Grimoire's combat level
```

Total Combat Level does two jobs: it gates zone access, and it is the character's prestige stat
(the single number that represents overall power). The old shared combat Talents (Marksmanship,
Spellcasting, Warfare) were retired and surface in no UI. Damage XP and a kill bonus route to the
equipped Grimoire.

### The three paths and their subclasses

Combat identity comes from the equipped Grimoire's path and subclass. Seven Grimoires are free
starters, chosen at onboarding.

| Path | Attack type / stat | Subclasses (starters) | Active mechanic |
|------|--------------------|-----------------------|-----------------|
| Warden | Ranged / DEX | Sharpshot, Lone Wanderer | Bowstring archery |
| Arcanist | Magic / INT | Runeweaver, Summoner, Lifebinder | Runic Constellation |
| Vanguard | Melee / STR | Warlord, Shadowblade | Combo system |

`Bulwark` (a Vanguard tank) exists in the balance tables (HP pool multiplier 1.40, aggro
20/sec x1.2) but is not among the seven authored starter Grimoires. Treat it as a defined-but-not-
shipped subclass. All three active mechanics (Bowstring, Constellation, Combo) are built and wired
through a shared `ActiveCombatMechanic` seam. When a path has no active mechanic engaged, combat
falls back to idle auto-fire.

### Aggro model (hybrid, mostly dormant)

```
Total Aggro = PassiveRate/sec + (DamageDealt x ClassMultiplier) + TauntComboValue
```

Warlord 15/sec x1.5, Bulwark 20/sec x1.2, Shadowblade 0/sec x0.3. Decays 5%/sec (2%/sec for tanks).
Summoner constructs generate independent aggro and are targeted by highest aggro. Aggro is inert in
solo, single-enemy zone combat and only matters in Summoner construct play and multiplayer parties.

### Archery and aim (Warden Bowstring)

The bow is a real skill mechanic, redesigned in-engine from playtesting:

- Aim is a horizontal drag around a fixed screen-center reference. Draw is a vertical pull that
  lofts the arc (more draw equals higher arch). The arrow arc is Linecast-traced against the
  enemy collider, so draw is effectively vertical aim. There is no draw-power damage term.
- **Weak point** is a hit UV test against `EnemyData.weakPointMask` (x2.0), optionally per idle
  frame. A landed active shot then rolls accuracy against Evasion/Block (outcomes Hit / Miss /
  Evaded / Blocked). Idle auto-attacks keep full RNG accuracy.
- Ability rings are hold-duration tiers: the highest fully-charged, unlocked, off-cooldown tier
  fires on release. Sharpshot has five (Full Draw, Aimed, Barbed, Pierce, Long Shot); Lone
  Wanderer has four (Full Draw, Twin, Rapid, Volley).
- **Active-shot multiplier model (as-built):** weak-point/bullseye crit is 1.6, a charged ability
  ring REPLACES the crit rather than stacking, Armor Piercer is additive (+0.15), Long Shot 3.0,
  and any single active shot is hard-capped at 2.5.

### No-crit rules

```
if (path == Arcanist || path == Vanguard) { critChance = 0; weakPointEnabled = false; }
```

Only the Warden (Bowstring) has weak points and crits. Shadowblade's "Shadow's Edge" shows a
"Critical!" flourish visually, but the backend is a flat +150% damage multiplier, not a crit roll.

### Resource models

- **Most casters and Warden:** mana or stamina bar (mana for Arcanist casters, stamina for
  Vanguard). Warden and Lifebinder hide the resource bar because HP is effectively their resource.
- **Summoner HP pool:** `effectiveHP = (baseHP * 0.25) + activeConstructs.Sum(currentHP)`. Constructs
  are the primary HP pool. Constructs auto-summon at combat start; single-rune draws command them
  (summon / focus / recall). Active-cap 1, then 2 at Lv25, 3 at Lv50.
- **Lifebinder HP-as-resource:** no mana. `SpellCost = Base x PowerMultiplier x (1 - WIL*0.003,
  capped 30% reduction)`. Always-on combat regen (3 + VIT*0.08 + WIL*0.05), HOTs stack additively
  on top, and a spell can never drop the caster below 1 HP. Shields (Holy Aegis) grant a real
  absorb buffer. Cleanse and revive exist but cleanse stays dormant (nothing applies a player
  debuff in zone content by design; debuffs are dungeon/raid-scoped).

### Weapons, handedness, and shields (as-built final, v2.0)

- **One-handed (shield-capable):** Sword, Dagger, Axe, Wand, Crossbow.
- **Two-handed:** Staff, Shortbow, Longbow, Greataxe.
- Weapons are NOT path-gated in this codebase. The off-hand (shield) is gated by weapon handedness,
  not by class.
- **Shield block** is a third defensive channel resolving evade, then block, then mitigate. Block
  is a chance to REDUCE a hit, never negate it: chance scales with quality (20 to 34%), reduction
  with tier (50 to 58%), for roughly 16 to 25% effective HP.
- **Attack speed:** weapon type sets an interval (Dagger about 1.40s fast, Crossbow 2.90s slowest).
  The crossbow can never weak-point (it forces auto-fire), trading the Warden crit for the shield.
  The weapon-speed core is built; proc-per-swing normalization, a 250ms evaluation tick, enemy
  attack-cadence data, and boss cadence multipliers are still remaining.

---

## 3. Progression

### Total Combat Level gating

`ZoneAccess.cs` is the single source of truth for tier thresholds by Total Combat Level:

```
Tier 1: 1 to 20     Tier 2: 21 to 50     Tier 3: 51 to 90
Tier 4: 91 to 140   Tier 5: 141+
```

Per-zone overrides exist (`combatTalentLevelRequired`). Locked zones refuse entry and show the
arithmetic ("you need X more combat level").

### Permanent stat milestones

Grimoire milestones grant permanent stat bonuses that persist regardless of which Grimoire is
equipped and accumulate across paths (a player who levels multiple Grimoires banks all their
milestones).

| Path | Lv 23 | Lv 38/47 | Lv 63 | Lv 81 |
|------|-------|----------|-------|-------|
| Warden | DEX +1 | LCK +1 (38) | DEX +2 | LCK +2 |
| Arcanist | INT +1 | WIL +1 (38) | INT +2 | WIL +2 |
| Vanguard | STR +1 | VIT +1 (47) | STR +2 | VIT +2 |

The HP progression pass added VIT milestone ladders to every path (Vanguard +8 total, Warden +4,
Arcanist +3) so all paths gain some permanent HP. Max HP is now
`round((50 + TotalCombatLevel*2.5 + totalVIT*6) * HPPoolMultiplier)`, coupling survivability to the
content gate. `HPPoolMultiplier` is per-subclass (Runeweaver/Summoner 0.90, Sharpshot 1.00, Warlord
1.25, Bulwark 1.40, Lifebinder 1.60).

### Prestige (guild-scoped) and the guild prestige hub

There is no individual prestige or rebirth reset. "Prestige" in the shipped game is a GUILD system:
guilds spend at milestones (1/5/10/20/35/50/75/100) to advance an 8-stage visual hub
(Campfire Gathering, Tent Camp, Encampment, Army Encampment, Fortress, Castle, Castle with Village,
Stronghold Capital). The hub art swaps per stage (`PrestigeStages` / `PrestigeHubBackground`, driven
by the Guild Bank). The individual "prestige stat" is Total Combat Level.

---

## 4. Idle actions

- **Gathering (6 Talents):** Delving, Felling, Gleaning, Foraging, Trapping, Dredging.
- **Crafting (9 Talents):** Smelting, Tanning, Cookery, Alchemy, Artificing, Inscription,
  Runesmithing, Timber Shaping, Tailoring. (Processing was merged into Crafting; the split is now
  just gather-from-the-world vs consume-materials.)
- Each Talent runs timed cycles with rising XP per second across tiers (a monotonic curve fix
  removed the "stay at tier 1" trap). Tools are equipped into a per-Talent slot (out of the bag)
  and drive the idle-time multiplier.
- **Attunement** is a real active mechanic: a tap-cue window during an idle cycle grants a yield,
  XP, and rare-loot bonus. Idle always earns the base; tapping earns the full bonus. Per-cue-type
  visuals (Smelting HeatGauge, Tanning Pulse) are mostly a shared tap button today.
- **Concurrency:** one action at a time; combat and idle stop each other. Concurrent-at-full-rate
  is designed but NOT built.
- **Server-side idle resolution:** the stated architecture principle is server-side idle math via
  Edge Functions ("never trust client time"). As-built, idle cycle progress and offline WYWA
  accrual are computed CLIENT-side (`IdleManager`, PlayerPrefs / save gates). See the disagreements
  section.

---

## 5. Economy

### Currencies

- **Silver Mark (SM):** the common currency, primary through Tier 1 to 2.
- **Gold Mark (GM):** premium currency, the primary drop from Tier 3+ zones (silver is zeroed at
  T3+), and the IAP currency.

### Wayfarer's Exchange

A full player marketplace: store listings (sell orders, dual currency SM+GM either may be 0),
auctions (single currency chosen at creation so bids stay rankable), buy orders (dual-currency
escrow, 0% fee always), a live typeahead search, a watchlist, and collapsible per-item market
sections. Sale proceeds accrue to a server-side pending bucket per marketplace; the seller taps
**Collect** at the merchant to move pending funds to their wallet (this fixed a lost-earnings bug
and made collecting a rewarding beat).

### Exchange fees and sinks (as-built)

- Solo sale: 3% system tax (an economy sink).
- Guild member sale: 0 to 3% guild tax REPLACES the system tax and goes to the guild bank.
- Guild Merchant internal listings: half the guild tax rate.
- Buy Orders: always 0%.
- Other sinks: guild creation (2,000 GM), guild roster-tier and prestige upgrades, Royal Merchant
  purchases.

### Royal Merchant

A 5-tab GM store as a top-level nav page (Consumables, Inventory, Quests & Tasks, Cosmetics,
Grimoires & DLC). Live rows include the idle auto-eat upgrade tiers (server-authoritative GM
purchase via `purchase_merchant_item`). Many rows are honest stubs or IAP placeholders. CLAUDE.md
also references Royal Merchant subscription tiers as a monetization axis.

### Traveling Merchant (0.1.4 pivot, DESIGN not built)

The intended economy pivot: a Traveling Merchant that buys scrap for SM at a low fixed floor
(seeding the economy below Exchange value) with a daily cap and rotating interest categories, plus
a GM-to-SM only converter at 100:1 (no SM-to-GM, to prevent premium farming). This supersedes the
Material Recycling / Reclaimed Essence system. Recycling Stage 1 (Reclaimed Essence, a bound
per-player token) shipped but is slated for retirement by this pivot. Neither the Traveling Merchant
nor the pivot's retirement of Essence is built yet.

---

## 6. Guilds and co-op

### Guild governance and taxes

- **Voting:** 2/3 approval of the FULL roster (`ceil(2/3 x member_count)`), applied server-side. A
  vote passes and applies IMMEDIATELY on reaching threshold (no delay). Open until threshold, all
  voted, or 7 days (auto-closed hourly by pg_cron).
- **Tax:** default 2%, changed by vote. Guild tax replaces the system tax on member Exchange sales
  and funds the guild bank.
- Guild Hall tabs: Home, Roster, Bank, Upgrades, Prestige, Merchant, Settings. Bank has donate /
  withdraw / expand / material requests / bounties (bounty activation is a reserved placeholder).

### No-websocket polling model

The codebase has NO Supabase realtime / websocket transport. Every multiplayer feature syncs by
polling: boss lobby about every 2s, chat 3s expanded, member-state as fast as 300ms during active
combat. Design any new multiplayer or co-op feature around polling and RPC round trips, not push.

### Co-op combat and ally cards

- **Boss lobbies** (party of up to 3, with slots plumbed raid-ready to 5) and **co-op dungeons**
  (a shared run seed produces an identical room layout on every client, plus a shared
  server-authoritative enemy HP pool that scales with party size).
- **Ally cards / member-state sync (built):** `lobby_member_state` table plus a single
  `sync_member_state` RPC that writes the caller's own state and returns every other member's state
  in one round trip (the halving that makes a fast cadence affordable). Four cadence tiers
  (stopped / 3s / 1s / 300ms). Ally cards show name, class, live HP, and debuff chips, up to 4 in a
  raid or 2 in a dungeon, with downed / left / stale states, plus a gated tap-to-inspect modal.
  Feature-complete pending a live 2-account verification.

### Social

Friend system (requests, presence, block) and a docked multi-channel chat panel (World, Guild,
Private, Lobby filters, @mentions), all over RPC polling. Live push delivery (a websocket
RealtimeManager, and FCM for backgrounded mentions) is not built.

---

## 7. Quests

Reworked into themed named-NPC bounties (14 givers) with an accept-to-pin model:

- The board shows OFFERS (6 daily / 4 weekly). The player accepts up to a cap (3 daily / 2 weekly,
  plus Royal Merchant bonus slots) to pin a quest as active. Progress only tracks accepted quests.
- **Fulfillment is one of two kinds.** Delivery quests (gather / process / craft) are not
  event-counted; progress is the live inventory balance, and a client-authoritative Turn-In consumes
  the items lowest-quality-first (skipping locked/protected) on the merchant rails. Track quests
  (kills / dungeons / zone entry / exchange sales) are event-counted and claimed through the server.
- Gear delivery quests match by weapon or armor CATEGORY with a quality cap.
- **Pool:** 85 definitions (55 daily + 30 weekly) covering all 15 non-combat Talents and all 6
  factions. Rewards lead with SM plus a themed bonus item ("taste, not farm") plus a small XP side
  bonus. GM appears only on weekly capstones.
- A separate Slaying **Bounty Board** (3 weekly named-enemy bounties, PlayerPrefs-backed) exists
  under the Slaying page.

---

## 8. Crafting and Talents

### Talent set

- **Gathering (6):** Delving, Felling, Gleaning, Foraging, Trapping, Dredging.
- **Crafting (9):** Smelting, Tanning, Cookery, Alchemy, Artificing, Inscription, Runesmithing,
  Timber Shaping, Tailoring.
- **Combat-adjacent:** Slaying (a full Lv1-100 ladder: elite spawn bonus, Hunted Variants,
  Finishing Blow, Faction Mastery kill counters and titles, a Lv100 capstone, Slayer Hunts, and the
  Bounty Board). Marksmanship / Spellcasting / Warfare are retired (replaced by per-Grimoire combat
  levels).

### Equipment tiers (the power axis)

Two ladders exist, expressed by `ItemData.materialTier` (1 to 5) and level-gated crafting recipes:

- **Metal (weapons + Plate armor):** Bronze, Iron, Steel, Mithril, Void.
- **Wood (staff / wand):** Pine up through Heartwood.
- **Leather:** Rabbit Hide up through Drake Scale.
- **Cloth (Vestments):** up through Void vestments.
- A new two-handed Greataxe and shields (metal, OffHand slot) were added in the weapon revision.

Tier crafting recipes craft tier N from the tier N-1 item plus a tier material, on the owning smith
Talent, gated at levels 1 / 21 / 42 / 65 / 88. Tier raises both the physical band (weapon damage,
armor rating) AND, since the bug-54 fix, the primary/secondary stat bonus (one material tier equals
two quality steps of stat). Upgrade component recipes are themed to the item's material class (metal
Fitting, Sinew Cord for leather, Spun Thread for vestments).

### Assembly bench (quality)

Quality is an instance flag on the inventory stack, not a separate asset. The Assembly bench raises
an item's quality one step in place (Crude, Rough, Refined, Pristine, Masterwork; Legendary is
authored but unused), consuming the item, shared band components, and a rare material. Success rates
scale with the assembler Talent level; failure returns the item without downgrading it.

### What is craftable

Full gear ladders (weapons, five armor slots per class of Plate/Leather/Vestments, shields, tools),
consumables (Healing Draughts, mana/stamina restores, antidotes, weapon coatings that apply enemy
DoTs, meals with timed stat buffs), and Inscription scrolls/codices (timed buffs). The material
economy (ore to bar to component, leather chain, apparatus/limb producers) is fully sourced and
deadlock-audited.

---

## 9. Zones, tiers, and the Quality vs Tier distinction

**Quality and Tier are different axes. Do not conflate them.**

- **Quality** is the rarity of an individual item instance (Crude to Masterwork/Legendary). It
  drives idle-action times, damage/HP bonuses, and the quality badge. It is an instance flag.
- **Tier** is level-gated progression: material tiers (Bronze to Void), zone tier bands, recipe
  unlock levels, and Royal Merchant subscription tiers. Tier is never a rarity enum.

**Zones.** Ten zones across five tiers (two per tier), each with a standard/elite enemy pool and a
zone boss, plus a dungeon per zone. Content spans Tier 1 (Grimwood Fringe, Saltmarsh Shore) up
through Tier 5 (Ashenwold, Elder Reaches). Dungeons are linear crawls (entrance, weighted room pool,
safe room, boss) with puzzles (T2 onward) and simplified hazard ticks. Painterly parallax
backgrounds (far/mid/near) and enemy idle/attack/death animations are now wired for all ten zones.

---

## 10. Monetization

- **Unity IAP + RevenueCat.** Do NOT build custom receipt validation (a hard CLAUDE.md rule). IAP
  rows in the Royal Merchant are stubbed pending that integration.
- **Gold Marks** are the premium currency. GM enters via IAP and (in the unbuilt Traveling Merchant
  design) via a one-way GM-to-SM converter. There is deliberately no SM-to-GM path.
- **Royal Merchant** is the GM storefront, with subscription tiers referenced as a monetization axis
  and the auto-eat convenience upgrades already live.
- Analytics via GameAnalytics; push via Firebase Cloud Messaging.

---

## 11. What is NOT built, deferred, and honest retention gaps

### Hard do-not-build (design decision)

- **Raids:** Phase 4. Lobby slots are plumbed to 5, but raid COMBAT is deferred.
- **Faction system, Faction Wars, Guild Bounties:** DLC / post-launch. (Enemies are already
  faction-tagged from day one to leave room for this.)
- **DLC subclasses:** Bloodweaver, Warlock, Kensei, Beastbond, Bard/Minstrel.
- **Divination Talent:** show a "???" placeholder only.
- **Black Ledger:** removed from the base game.
- **Enchanting:** removed. Inscription remains only as a scroll/codex crafting Talent; the
  `enchantBonus` channel and enchant gates were deleted.
- **Legendary quality items:** the `ItemQuality.Legendary` value exists for future content, but no
  base-game item is authored at that quality.

### Designed but not built

- **Concurrent idle at full rate** (the retention play Dustin wants). Combat and idle still stop
  each other.
- **Traveling Merchant** economy pivot and the retirement of Reclaimed Essence.
- **HP progression Stage 4:** mitigation cap at 75%, revive buff (10% to 25% plus immunity), and
  percentage-based healing consumables.
- **Offline combat simulation:** only a summary tally is shown on return (no offline kills).
- **Server-authoritative currency:** currency is client-authoritative today (absolute-value PATCH),
  a known lost-earnings edge case remains.

### Built but shallow (the core of the retention problem)

- **Boss and elite special abilities are reference text only.** Behaviour is deferred across every
  tier. Higher zones differ from lower ones mostly by stat inflation, not by mechanics, so advancing
  does not yet change how combat plays.
- **Zone combat is auto-resolution.** The active mechanics (Bowstring, Constellation, Combo) reward
  a foreground player, but a player can idle through most content. There is little pull to engage
  actively at higher tiers.
- **No individual prestige, rebirth, or endgame loop past Tier 5 (141+).** Beyond the top gate,
  advancement is stat inflation with no cap-expansion content. Prestige as a system is guild-only.
- **Spawn rate is deliberately not buffable** (a locked combat-spec decision), so "faster farming"
  is not a lever the design currently offers.

The current reasons to advance are: unlocking the next zone tier (Total Combat Level), chasing gear
tiers and quality, banking cross-path permanent stat milestones, earning Slaying titles and Faction
Mastery, and contributing to guild prestige. A new retention mechanic would sit on top of these.

---

## 12. Where code and specs disagreed, or where I was uncertain (verify these)

1. **Lifebinder status.** `deferred-systems-dlc-notes.md` still lists Lifebinder as a Phase 4
   deferred subclass, but `implementation-status.md` states Lifebinder is BUILT (HP-as-resource,
   regen, HOTs, shields; cleanse/revive partially). Code wins: Lifebinder is a shipped starter. The
   deferred note is stale.

2. **Server-side idle resolution.** CLAUDE.md's architecture guidelines say idle math must run
   server-side via Edge Functions ("never trust client-reported time"). As-built, idle cycle
   progress and offline WYWA accrual are CLIENT-computed (`IdleManager`, save-gated). The task brief
   assumed server-side idle resolution; the code does not match the principle. Worth confirming
   whether any server idle math exists that I did not find (I found none).

3. **Bulwark subclass.** Bulwark appears in balance tables (HP pool 1.40, aggro 20/sec x1.2) as a
   Vanguard tank, but `CreateGrimoires` authors only 7 starters (Sharpshot, Lone Wanderer,
   Runeweaver, Summoner, Lifebinder, Warlord, Shadowblade). I could not confirm Bulwark is an
   equippable Grimoire; treat it as defined-but-not-shipped until verified.

4. **CLAUDE.md "locked design decisions" are known-stale.** The docs README explicitly warns that
   the root CLAUDE.md's locked-decisions section has stale lines (Unity version, zone-unlock rule,
   Exchange fees, Enchanting to Inscription, Constellation layout). I trusted
   `implementation-status.md` and the individual specs over that section throughout. The zone bands,
   fee model, and Constellation layout in this briefing come from the as-built record.

5. **Concurrent idle and Traveling Merchant.** Both are the current design direction (v1.2 / v1.0
   specs) but explicitly NOT built. I described the intent, not shipped behaviour. Confirm their
   status has not changed since 2026-09-20 before designing against them.

6. **Attack-speed and boss cadence.** The weapon-speed core is built, but proc normalization, the
   250ms tick, enemy cadence data, and boss cadence multipliers are listed as remaining. Enemy
   attack timing at higher tiers may not behave as the spec describes yet.
