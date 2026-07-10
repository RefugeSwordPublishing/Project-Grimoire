# ⚔️ Project Grimoire — Master Design Document
### Version 1.0 — Architecture & Systems Overview

> This is the master overview document. Detailed specs for each system live in their own dedicated docs within `/docs`. This document exists to give a single accurate picture of the whole game and link out to detail where needed.

---

## 🎯 Core Design Philosophy

**Semi-Idle Loop:** Tasks run automatically when offline (idle), but active play triggers an **Attunement Surge** — a multiplier on XP, resource yield, or rare drop rates for players who engage directly. This rewards both playstyles without punishing either.

**Attunement Surge:** When a player manually triggers or interacts with a task (tapping a node, drawing a bow, drawing a rune combination), they receive a boost to XP and quality/drop chance for that action. Full mechanic detail per Talent lives in `docs/talent-spec-sheets.md`.

---

## 📊 Core Character Stats

| Stat | Abbreviation | Role |
|------|-------------|------|
| **Strength** | STR | Melee damage, carry weight |
| **Dexterity** | DEX | Universal accuracy stat across all Grimoires, evasion contribution |
| **Vitality** | VIT | Max HP, stamina pool |
| **Intelligence** | INT | Spell damage, Enchanting potency, Alchemy effectiveness |
| **Willpower** | WIL | Mana pool, healing boost, debuff resistance, idle persistence |
| **Luck** | LCK | Rare drop rate, passive combat wild-card effects |
| **Charisma** | CHA | Exchange margins (base game); Beastbond taming, Bard combat, Faction standing (DLC roadmap) |

Full combat math, derived stats, and the hit/evasion/block resolution loop live in `docs/stat-scaling-combat-formulas.md`.

**Stat Growth:** Hybrid model — Talent level milestones grant small permanent stat passives, equipment provides the largest bonuses, Enchanting stacks on top. No separate stat XP grind.

---

## 🧙 Class Archetypes & Subclasses

Full subclass trees with every unlock, hybrid gate, and build identity live in:
- `docs/subclass-trees-warden.md`
- `docs/subclass-trees-arcanist.md`
- `docs/subclass-trees-vanguard.md`

### 🏹 The Warden Path — **PHASE 1 LAUNCH CLASS**
Primary stats: DEX, LCK · Combat: Bowstring mechanic

| Subclass | Status | Identity |
|----------|--------|----------|
| **Sharpshot** | Base game | Precision archer — slow, deliberate, massive single hits |
| **Lone Wanderer** | Base game | Rapid fire, poison stacking, solo specialist |
| Beastbond | DLC | Tames real creatures, user is primary damage, creatures buff/debuff |

### 🔮 The Arcanist Path
Primary stats: INT, WIL · Combat: Runic Constellation mechanic

| Subclass | Status | Identity |
|----------|--------|----------|
| **Runeweaver** | Base game | Elemental battlemage, counter-combinations, AoE control |
| **Summoner** | Base game | Backline tactician — conjured constructs fight, user buffs/debuffs them |
| **Lifebinder** | Base game | Essential raid healer, self-sustaining solo |
| Warlock | DLC | Soul harvesting, Soulbinding exclusive |

### ⚔️ The Vanguard Path
Primary stats: STR, VIT · Combat: Melee combo system

| Subclass | Status | Identity |
|----------|--------|----------|
| **Warlord** | Base game | Immovable tank, Zone Conquest, essential raid role |
| **Shadowblade** | Base game | Burst assassin, heaviest Gleaning dependency, Shadow Step + Hemorrhage Mastery |
| Kensei | DLC | Samurai discipline, Focus mechanic, Wardancing |

### Future Path (DLC, path TBD)
| Subclass | Status | Identity |
|----------|--------|----------|
| Bard/Minstrel | DLC | WIL + CHA performance support — debuffs enemies, buffs party |

**All 7 base game Grimoires are available as the starting choice** — no forced "free tier." Additional Grimoires cost 500 GM or real money. DLC Grimoires cost more (2,500 GM or real money) — see `docs/monetization-scope.md`.

---

## 📖 The Grimoire Binding System

Class identity is determined by which Grimoire is equipped — no separate character creation needed. One character can experience every path by switching Grimoires.

- **Swap cooldown:** ~24 hours
- **Stats and inventory:** Shared across all Grimoires (full character sheet)
- **Universal Talents** (carry across all Grimoires): all Gathering, all Processing, Slaying, Runelore, Enchanting, Inscription
- **Grimoire Combat Progression**: Each Grimoire has its own independent combat level (1–100). Warden Grimoires use Bowstring/Marksmanship mechanics, Arcanist Grimoires use the Runic Constellation, Vanguard Grimoires use the Strike/Guard/Surge Warfare system. These are NOT shared Talents — they live on the Grimoire itself.

Full economy, listing types, and Grimoire pricing live in `docs/wayferers-exchange-and-grimoire-system.md`.

**Grimoire Combat Progression:**
Each Grimoire houses its own combat level (1–100) that tracks separately from other Grimoires. Switching Grimoires starts fresh on that Grimoire's combat progression. Universal Talents (gathering, processing) remain shared across all Grimoires.

**Total Combat Level = Sum of all owned Grimoire combat levels**
This is the zone unlock gate and a character-wide prestige stat displayed on the character page.

| Total Combat Level | Zone Tier Unlocked |
|------------------|-------------------|
| 1–20 | Tier 1 |
| 21–50 | Tier 2 |
| 51–90 | Tier 3 |
| 91–140 | Tier 4 |
| 141+ | Tier 5 |

---

## 🛠️ Talents System

20+ Talents across four trees — Gathering, Processing, Combat, Arcane. Full spec sheets with every level unlock, XP curve, and cross-Talent dependency live in `docs/talent-spec-sheets.md`.

### Unlock Terminology by Category
| Category | Term |
|----------|------|
| Runesmithing, Smelting, Artificing, Tanning, Timber Shaping | **Schematic** |
| Tailoring, Arcane Weaving | **Pattern** |
| Alchemy, Cookery | **Formulae** |
| Combat Talents | **Technique** |
| All Gathering Talents | **Field Notes** |
| Inscription, Enchanting, Runelore, Divination, Soulbinding | **Codex Entry** |

### Talent List
**Gathering:** Foraging, Felling, Delving, Trapping, Dredging, Gleaning, Cultivation, Tracking
**Processing:** Tanning, Smelting, Timber Shaping, Runesmithing, Arcane Weaving, Alchemy, Cookery, Tailoring, Artificing, Inscription
**Combat (via Slaying Talent):** Slaying

> Note: Marksmanship, Spellcasting, Warfare, Shadowcraft, Bulwark, Wardancing have been removed from the Talent system. Combat progression lives on each Grimoire independently. See Grimoire Combat Progression section.
**Arcane:** Divination, Runelore, Soulbinding
*(Enchanting merged into Inscription — no longer a separate Talent)*

**Level cap:** 100 base, expandable to 120 then 150 via DLC Tome of Mastery purchases. Level 100 capstones are designed around **mastery and consistency, not power spikes** — rare materials and powerful unlocks live at levels 82–92, preserving expansion headroom.

---

## ⚒️ Assembly & Crafting

Full material tables, cross-Talent requirements, and weapon/armor component breakdowns live in `docs/assembly-materials-crafting-system.md`.

**Core rules:**
- Weapons/Tools/Quivers: 2 components (one per contributing Talent) + 1 rare material at Assembly
- Armor: 3 components + 1 rare material at Assembly
- Rare materials added at the **Workbench during Assembly**, not during component crafting
- All components AND rare materials consumed regardless of success or failure
- **Fail cascade:** Masterwork fail → Refined attempt → Rough attempt → Crude floor (never a total loss)
- Tools are **permanent** — no degradation, upgrade motivation only
- Rare materials follow a cross-Talent pattern — gathering tools require combat-sourced materials and vice versa, driving guild interdependence

### Quality Tiers
| Tier | Color | Source |
|------|-------|--------|
| Crude | Grey | Base game |
| Rough | White | Base game |
| Refined | Green | Base game |
| Pristine | Blue | Base game |
| Masterwork | Purple | Base game — primarily raids |
| Legendary | Gold | DLC / Events only |

---

## ⚔️ Combat Systems

### Bowstring Mechanic (Warden)
Over-the-shoulder perspective. Press and drag to draw the bowstring — the further back, the more power. A fading aim arc shows rough trajectory. Enemy weak points glow with a subtle pixel highlight for a brief window when draw begins — fast, accurate players land crits. Draw distance affects damage slightly; **accuracy is the primary skill**. Idle auto-combat fires at a mid-draw damage baseline — this prevents players from gaining an advantage by spam-tapping instead of committing to full draws.

### Runic Constellation (Arcanist)
A fixed layout of 8 rune nodes (Ignis, Glacius, Tempest, Terra, Ventus, Vita, Umbra, Lux). Players draw lines connecting runes to cast combination spells — same gesture, but **subclass alters what each rune does**, not the layout. Combination depth unlocks with Spellcasting level, from single runes up to full constellation casts at level 88+.

### Combat Resolution Loop
```
Hit Roll → Evasion Check → Block Check → Damage Roll → LCK Wild Card → Debuff Application
```
Evasion comes from armor type + DEX. Block is a separate roll determined by armor tier — Plate has low evasion/high block, Leather is balanced, Vestments lean evasion. Full formulas in `docs/stat-scaling-combat-formulas.md`.

---

## 🗺️ World & Zones

Full zone tables, enemy rosters, drop tables, and bosses live in `docs/enemy-zone-tables.md`.

- **10 zones across 5 tiers**, 2 branching options per tier — players choose biome/enemy focus
- **Zone unlock** — Total Combat Level (sum of all owned Grimoire combat levels). See threshold table in Grimoire System section.
- **Combat targeting** — players select both zone AND specific enemy type, each enemy has a spawn weight (common enemies spawn more, elites rarer)
- **Zone bosses** — active play only, random spawn chance (~1 in 20 encounters), 10 minute despawn timer
- **Enemy faction tags** (`[Outlaw]`, `[Beast]`, `[Undead]`, `[Arcane]`, `[Void]`, `[Nature]`, `[Elite]`, `[Boss]`, `[Legendary]`) applied to every enemy from day one for DLC faction bonus compatibility

### Zone List
| Tier | Zones |
|------|-------|
| 1 | Grimwood Fringe, Saltmarsh Shore |
| 2 | Ashfen Mire, Ironspine Reaches |
| 3 | Dreadhollow, Cinderpeak |
| 4 | Veilborn Wastes, Shattered Citadel |
| 5 | Ashenwold, Elder Reaches |

### Dungeons & Raids
- **Dungeons:** 2 active per month, rotate on the 1st, not idle-able, active play required
- **Raids:** 1 active per quarter, 25–45 minutes, 3-phase structure (approach → boss → aftermath), active only, only source of Masterwork tier materials in base game

---

## 🌍 Economy

Full market mechanics live in `docs/wayferers-exchange-and-grimoire-system.md`.

### Currency
**Silver Marks (SM)** and **Gold Marks (GM)** only. 1,000 SM = 1 GM (informal reference).

### The Wayfarer's Exchange
Unified marketplace — minimum any Talent level 10 to access, no guild requirement. Three listing types:
- **Auction** — starting bid, optional buyout, 1/7/15 day duration, all-or-nothing
- **Store Listing** — fixed price, partial fills allowed
- **Buy Order** — buyer fronts Marks in escrow, no fee ever
- **Fee:** Solo players pay 3% system tax (economy sink). Guild members pay 0–3% guild tax (goes to guild bank) replacing the system tax. Guild Merchant internal sales at half guild tax rate

**Shadowblade** — pure combat specialist. No exclusive Exchange access — economy served by standard Exchange and Guild Merchant. *(Black Ledger concept deferred to post-launch — may return as DLC content if warranted)*

---

## 🏰 Guilds

Full guild system lives in `docs/guild-system.md`.

- **Creation:** 2,000 GM, starts at 10 member roster
- **Roster growth:** Permanent upgrades funded by guild bank, up to Tier 6 (100 members)
- **Funding:** Automatic tax (0–5%, leadership vote + 48hr delay) on member Exchange sales + voluntary donations
- **Spending categories:** Permanent roster upgrades, consumable economy/drop-rate buffs (never XP), Guild Bounties, infinite Guild Prestige (draws from current balance — genuine trade-off against other spending)
- **Guild Hub** — visual backdrop that evolves with Prestige level, from a campfire gathering up to a Stronghold Capital
- **Cross-guild access** — Guest system (no upgrade required) for raids/dungeons, Alliance system (Tier 6) for formal cooperation, sets foundation for DLC Faction Wars

---

## 📋 Daily & Weekly Quests

Full quest system lives in `docs/daily-weekly-quest-system.md`.

- **Board-based, player chosen** — not auto-assigned
- **5 of 10 daily quests, 2 of 6 weekly quests** acceptable at once
- **Refreshes midnight UTC** for all players simultaneously
- **Difficulty scales with highest Talent level** (Novice through Master), harder quests pay better
- **Categories:** Gathering, Processing, Combat, Crafting, Market, Challenge
- **Rewards:** Hybrid of Marks, rare materials, and temporary Talent XP boosts (quest rewards only — never sold for real money)

---

## 🎬 Onboarding

Full flow lives in `docs/onboarding-flow.md`.

Tutorial-first structure: brief world intro → first Talent (Foraging) → first combat (Bowstring) → Grimoire selection → free play. Fully skippable except the Grimoire choice itself. Total guided time under 5 minutes. Natural contextual tooltips take over after onboarding rather than a feature dump.

---

## 📱 While You Were Away

Full screen spec lives in `docs/while-you-were-away.md`.

Auto-collected gains, highlights-first presentation (level ups, rare drops, missed boss spawns), common resources summarized by Talent rather than itemized. 24-hour idle accumulation cap.

---

## 💰 Monetization

Full scope lives in `docs/monetization-scope.md`.

**Core promise:** Nothing is exclusively pay-walled. Real money buys convenience and cosmetics only — never power. No XP boosts, no stat-affecting exclusives, no guild power, no loot boxes, ever.

---

## 📋 Deferred Systems & DLC Roadmap

Full notes and base-game architectural constraints live in `docs/deferred-systems-dlc-notes.md`.

| System | Target |
|--------|--------|
| Faction System + Faction Wars | Level 120 cap DLC |
| Beastbond, Warlock, Kensei subclasses | DLC |
| Bard/Minstrel subclass | DLC |
| Dueling/PvP Arena | Phase 4 |
| Hard mode dungeons / New Game Plus | DLC |
| Mythic quality tier | DLC events only |

---

## 🎨 Art Direction — 2D Pixel Art Style

Project Grimoire uses a **2D pixel art style** inspired by Kingdom Two Crowns — clean limited palettes, strong readable silhouettes, hard pixel edges, dark fantasy medieval tone with candlelight amber accents. This applies to characters, enemies, items, and UI alike — the interface itself uses pixel-drawn icons and panel borders rather than illustrated or emoji-based elements, keeping the whole experience tonally consistent.

### Combat & Raid Perspective
- **Solo combat (Warden):** Over-the-shoulder view, archer visible from behind in foreground, enemy ahead
- **Dungeons & Raids:** Party locked to bottom of screen, world scrolls toward them; on enemy encounter each player's screen independently shifts to their own over-the-shoulder view
- **Boss encounters:** World stops scrolling, boss enters from top of screen

### Sprite & Art Tool Stack
| Tool | Role |
|------|------|
| **Sprite AI** | Primary sprite generation — exports at game-ready pixel dimensions, built-in animator and pixel editor |
| **Leonardo.ai** | Concept exploration, reference generation |
| **Aseprite** | Manual pixel-level refinement |

### Unity 2D Considerations
- Unity 2D Sprite Renderer + 2D Animation package for character rigs
- Spine worth evaluating for fluid animation if budget allows
- UI built with Unity UI Toolkit for cross-platform scaling
- Particle effects for Attunement surges and combat crits via Unity Particle System (2D mode)

---

## 🛠️ Confirmed Tech Stack

| Layer | Tool |
|-------|------|
| **Engine** | Unity (2022.3 LTS or Unity 6) |
| **Language** | C# |
| **Version Control** | GitHub |
| **AI Dev** | Claude Code + Unity MCP |
| **Backend** | Supabase — player data, idle calculations (server-side via Edge Functions), economy, auth |
| **Notifications** | Firebase Cloud Messaging |
| **Monetization** | Unity IAP (App Store, Google Play, Steam) |
| **Analytics** | GameAnalytics |
| **Task Management** | Supabase-backed TaskBoard with Vercel frontend |

### Development Workflow
```
Claude.ai chat ──► Design decisions & doc updates
       │
       ▼
   GitHub ◄─────────────────────────────────┐
       │                                     │
       ▼                                     │
Claude Code (desktop) + Unity MCP ──► Unity Editor ──► Pushes code
       │
       ▼
  Supabase backend
```

Full handoff procedure and session log live in `docs/session-handoff-log.md` — every design session ends with updated docs pushed to GitHub and a structured handoff prompt for Claude Code, which also updates the TaskBoard.

---

## 🗺️ Development Phase Roadmap

| Phase | Scope |
|-------|-------|
| **Phase 1** | Warden (Sharpshot), Bowstring mechanic, core idle loop, Foraging/Trapping/Dredging/Cookery/Alchemy/Slaying, Grimwood Fringe + Saltmarsh Shore zones, basic Wayfarer's Exchange |
| **Phase 2** | Remaining base game Talents, Arcanist + Vanguard paths, full Wayfarer's Exchange, all base game subclasses |
| **Phase 3** | Remaining Arcane Talents, full zone rollout, dungeon/raid systems |
| **Phase 4** | Multiplayer — guilds, dungeons, raids, daily skirmishes, full subclass roster including Lifebinder group features |
| **Phase 5** | Steam release, crossplay, enhanced PC UI, keyboard/mouse Attunement input |
| **DLC** | Faction system + wars (level 120 cap), Beastbond, Warlock, Kensei, Bard/Minstrel, hard mode dungeons |

---

## 🏷️ Naming Conventions (Trademark-Safe)

- **Attunement** (not "Mastery")
- **Grimoire Queue** (not "Action Queue")
- **Talents** (not "Skills")
- **Gleaning** (not "Thieving")
- **Delving** (not "Mining")
- **Felling** (not "Woodcutting")
- **Runesmithing** (not "Smithing")
- **Soulbinding** (not "Prayer/Devotion")
- **Wayfarer's Exchange** (not "Grand Exchange" — avoids RuneScape conflict)
- **Warfare** (Vanguard combat system — not "Melee" or "Combat")
- **Grimoire Combat Level** (not "Marksmanship level" or "Spellcasting level")
- **Bulwark** (not "Defence/Defense" or "Vanguarding" — avoids redundancy with class name)
- **Bowstring** (not "Slingshot" — avoids Pokémon GO comparison in marketing)

---

*Document version 1.0 — Project Grimoire Master Design Document*
*This document is a summary and index. For implementation detail always defer to the dedicated doc referenced in each section.*
