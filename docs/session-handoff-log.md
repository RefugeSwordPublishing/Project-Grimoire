# ⚔️ Project Grimoire — Session Handoff Log
### Living document — updated at end of every design session

---

## 📋 Session Trigger Protocol

**When Dustin says "at my desktop" or "ready for handoff":**
Claude.ai looks back through the current session to the previous handoff bookmark, identifies all new or updated files, presents them for download, and generates the Claude Code handoff prompt.

This is the bookmark system — "at my desktop" = handoff point.

---

## 📋 Handoff Procedure

At the end of every design session in Claude.ai chat:

1. **Claude.ai chat** generates updated or new design docs
2. **Download** all changed files from the chat
3. **Place files** in the correct repo location:
   - Design docs → `/docs/`
   - Claude Code briefing → `/CLAUDE.md` (root)
   - Unity scripts → `/ProjectGrimoire/Assets/Scripts/`
4. **Commit to GitHub:**
   ```bash
   git add .
   git commit -m "Design update: [brief description]"
   git push
   ```
5. **Open Claude Code** in the repo directory and paste the handoff prompt

---

## 📋 Standard Handoff Prompt Template

```
Read CLAUDE.md and the following updated docs before doing anything:
- docs/[changed doc 1]
- docs/[changed doc 2]

Summary of what changed this session:
- [decision 1]
- [decision 2]

What to implement now (in priority order):
1. [task 1]
2. [task 2]

Do not implement yet:
- [deferred item 1]
- [deferred item 2]

Taskboard updates — read the current TaskBoard first, then add 
these tasks and mark any completed items done:
- [new task 1]
- [new task 2]

TaskBoard: https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard
GET ?id=eq.1&select=data to read current state
PATCH with full { "data": <JSON> } body to write
Use anon JWT as apikey and Authorization: Bearer headers
Always read before writing — never overwrite blindly

Confirm you have read all docs and understood the changes 
before writing any code.
```

### TaskBoard Rules
- Claude Code reads current board before every patch — never overwrites blindly
- New tasks from design sessions added at end of each handoff
- Tasks completed during implementation marked done in same session
- Notable design items flagged in this chat get added to the board via handoff prompt

---

## 📋 File Location Reference

| File | Repo Location |
|------|--------------|
| CLAUDE.md | `/CLAUDE.md` (root) |
| Main design doc | `/docs/design-doc.md` |
| Talent spec sheets | `/docs/talent-spec-sheets.md` |
| Assembly materials | `/docs/assembly-materials-crafting-system.md` |
| Enemy zone tables | `/docs/enemy-zone-tables.md` |
| Warden subclass trees | `/docs/subclass-trees-warden.md` |
| Arcanist subclass trees | `/docs/subclass-trees-arcanist.md` |
| Vanguard subclass trees | `/docs/subclass-trees-vanguard.md` |
| Stat scaling formulas | `/docs/stat-scaling-combat-formulas.md` |
| Wayfarer's Exchange | `/docs/wayferers-exchange-and-grimoire-system.md` |
| Deferred systems | `/docs/deferred-systems-dlc-notes.md` |
| Handoff log | `/docs/session-handoff-log.md` |

---

## 📋 Session Log

---

### Session 1 — Design Foundation (Complete)
**Date:** June 28–30, 2026
**Chat:** Claude.ai (this session)
**Status:** Full design complete, ready for first Claude Code implementation session

**What was designed:**
- Core game concept — semi-idle RPG, Attunement Surge mechanic
- 7 character stats (STR, DEX, VIT, INT, WIL, LCK, CHA)
- 3 class paths — Warden, Arcanist, Vanguard
- 7 base game Grimoires + 4 DLC Grimoires (Beastbond, Warlock, Kensei, Bard/Minstrel)
- Grimoire binding system — ~24hr cooldown, any base game Grimoire free at start, others 500 GM
- 20+ Talents with full spec sheets, level unlocks, XP curve, organic (non-multiple-of-5) unlock levels
- Unlock terminology — Field Notes, Schematics, Formulae, Patterns, Techniques, Codex Entries
- Weapon/tool assembly — 2 components + rare material at Workbench; armor — 3 components + rare material
- Fail cascade — Masterwork→Refined→Rough→Crude floor, all components consumed regardless of outcome
- 8 cross-Talent rare material types (gathering tools need combat materials and vice versa)
- Quality tiers — Crude/Rough/Refined/Pristine/Masterwork/Legendary(DLC only)
- Wayfarer's Exchange — auction, store listings, buy orders, listing fees, Black Ledger (Shadowblade)
- Currency — Silver Marks and Gold Marks only, no Copper
- 10 combat zones across 5 tiers, branching structure, zone+enemy targeting with spawn weighting
- Zone bosses — active play only, random spawn, 10 min despawn
- Monthly dungeon rotation (2 active), quarterly raids (25–45 min, 3-phase, Masterwork material source)
- Full subclass trees — Sharpshot, Lone Wanderer, Runeweaver, Summoner, Lifebinder, Warlord, Shadowblade
- Bulwark renamed from Vanguarding (avoids redundancy with class name)
- DLC subclasses fully scoped — Beastbond (DEX+CHA), Warlock, Kensei, Bard/Minstrel (WIL+CHA)
- Stat scaling formulas — hybrid gain, diminishing returns past 50, full hit/evasion/block/damage/LCK-wildcard/debuff combat resolution loop
- CHA progression roadmap across DLC tiers (base economy → Beastbond taming → Bard combat → Faction standing)
- Bowstring mechanic — over-the-shoulder, accuracy-based crits, weak point subtle pixel glow, idle mid-draw baseline (prevents spam-tap exploitation)
- Runic Constellation — 8 runes, draw combinations, subclass alters behavior not layout
- 2D pixel art style — Kingdom Two Crowns inspired (pivoted from earlier illustrated style)
- UI mockup built twice — first illustrated/emoji version, then rebuilt fully in pixel art style with working Bowstring prototype
- Daily/Weekly Quest System — player-chosen board (5 of 10 daily, 2 of 6 weekly), midnight UTC refresh, difficulty scales with highest Talent level
- Onboarding Flow — tutorial-first, fully skippable except Grimoire choice, ~4 min guided time
- While You Were Away screen — auto-collected, highlights-first, 24hr idle cap
- Guild System — full design: creation, roster tiers, tax governance, Guild Bounties, infinite Prestige (draws from current balance as genuine tradeoff), Guild Hub visual progression (campfire → stronghold), Guest/Alliance cross-guild access
- Guild–Faction DLC integration plan documented
- Monetization Scope — nothing exclusively pay-walled, no XP boosts ever, no guild power for sale, Early Supporter Badge (binary, non-tiered)
- Art Asset Requirements — full phase-by-phase breakdown of every sprite/environment/UI asset needed
- Phase 1 Sprite Prompt Library — ready-to-use prompts for every Phase 1 asset
- Sprite AI MCP connector identified and configured for direct Claude Code art generation
- Tech stack confirmed — Unity 6, C#, Supabase, Firebase, Unity IAP, GameAnalytics
- Session Handoff Log system established — this document

**All files ready for handoff (place in repo as indicated):**

| File | Repo Location | Status |
|------|---------------|--------|
| CLAUDE.md | `/CLAUDE.md` | New — includes Sprite AI MCP workflow instructions |
| game-design-doc.md | `/docs/design-doc.md` | v1.0 — full rewrite, now an index pointing to detail docs |
| talent-spec-sheets.md | `/docs/talent-spec-sheets.md` | v0.2 |
| assembly-materials-crafting-system.md | `/docs/assembly-materials-crafting-system.md` | v0.3 |
| enemy-zone-tables.md | `/docs/enemy-zone-tables.md` | v0.2 |
| subclass-trees-warden.md | `/docs/subclass-trees-warden.md` | v0.1 |
| subclass-trees-arcanist.md | `/docs/subclass-trees-arcanist.md` | v0.1 |
| subclass-trees-vanguard.md | `/docs/subclass-trees-vanguard.md` | v0.1 |
| stat-scaling-combat-formulas.md | `/docs/stat-scaling-combat-formulas.md` | v0.2 |
| wayferers-exchange-and-grimoire-system.md | `/docs/wayferers-exchange-and-grimoire-system.md` | v0.1 |
| deferred-systems-dlc-notes.md | `/docs/deferred-systems-dlc-notes.md` | v0.3 |
| daily-weekly-quest-system.md | `/docs/daily-weekly-quest-system.md` | New |
| onboarding-flow.md | `/docs/onboarding-flow.md` | New |
| while-you-were-away.md | `/docs/while-you-were-away.md` | New |
| guild-system.md | `/docs/guild-system.md` | v0.2 |
| monetization-scope.md | `/docs/monetization-scope.md` | New |
| art-asset-requirements.md | `/docs/art-asset-requirements.md` | New |
| phase1-sprite-prompts.md | `/docs/phase1-sprite-prompts.md` | New |
| session-handoff-log.md | `/docs/session-handoff-log.md` | This document |
| grimoire-ui-mockup.jsx | `/docs/reference/grimoire-ui-mockup.jsx` | Reference only — not production code, shows pixel art UI direction and working Bowstring prototype logic |

**Before opening Claude Code:**
1. Set up Sprite AI MCP connector (one-time terminal command, see docs/phase1-sprite-prompts.md header for context):
   ```bash
   claude mcp add --transport http sprite-ai https://www.sprite-ai.art/api/mcp --header "Authorization: Bearer YOUR_KEY"
   ```
2. Commit all files above to the repo in their indicated locations
3. Push to GitHub

**Handoff to Claude Code — Session 1:**
```
Read CLAUDE.md and ALL files in /docs before doing anything. This is the 
first Claude Code session for Project Grimoire — no code exists yet.

Confirm you have full context by summarizing:
1. What Project Grimoire is and its core semi-idle philosophy
2. What Phase 1 scope includes (class, talents, zones)
3. What the Bowstring mechanic does and why idle uses mid-draw baseline
4. What the Grimoire system does and the universal vs Grimoire-locked Talent split
5. What NOT to implement yet (check docs/deferred-systems-dlc-notes.md)
6. Confirm the Sprite AI MCP connector is available to you

Once confirmed, do the following in order:

PART A — Project Scaffolding
1. Create folder structure under Assets/:
   - Scripts/Core/, Scripts/Talents/, Scripts/Combat/, Scripts/Market/, 
     Scripts/Grimoire/, Scripts/UI/, Scripts/Backend/
   - ScriptableObjects/Talents/, ScriptableObjects/Enemies/, ScriptableObjects/Items/
   - Scenes/, Prefabs/, Sprites/Characters/, Sprites/Enemies/, Sprites/Items/, 
     Sprites/Environments/, Sprites/UI/

2. Create core manager scripts (proper structure, can be mostly stubs):
   - GameManager.cs, TalentManager.cs, CombatManager.cs, MarketManager.cs, 
     GrimoireManager.cs, BackendManager.cs (Supabase connection stub)

3. Create TalentData ScriptableObject with fields matching the structure in 
   docs/talent-spec-sheets.md — level, XP, unlock list, primary/secondary stat, 
   unlock term type, idle status

4. Create the Foraging talent as the first TalentData instance using exact 
   unlock data from docs/talent-spec-sheets.md

PART B — Art Generation (using Sprite AI MCP)
Follow the generation order in docs/phase1-sprite-prompts.md:
1. Generate the Warden base body + standard animation set first
2. Use it as a style reference for all subsequent generations
3. Generate bow + quiver as separate equipment layers — verify layering 
   approach works before proceeding
4. Generate the 13 Tier 1 enemies (Grimwood Fringe + Saltmarsh Shore rosters)
5. Generate Phase 1 gathering/processing item icons
6. Save all generated assets to the appropriate Sprites/ subfolder

Do not implement combat logic, market logic, or grimoire switching logic 
yet — scaffolding and art generation only this session.
Do not implement anything in docs/deferred-systems-dlc-notes.md.

TASKBOARD UPDATES — read current board first, then add:
- Scaffold Unity project folder structure
- Create core manager scripts (list above)
- Create TalentData ScriptableObject
- Implement Foraging talent as first instance
- Stub Supabase connection in BackendManager
- Set up Sprite AI MCP art generation pipeline
- Generate Warden base body + animations
- Generate bow + quiver equipment layers (test layering)
- Generate 13 Tier 1 enemy sprites
- Generate Phase 1 item icons
- Note: onboarding tutorial scenes need art stubs — do not block on final art
- Note: CHA stat formula slots must remain open — do not hardcode as economy-only
- Note: guild data model needs nullable primary_faction_id field for future DLC
- Note: enemy faction tags ([Outlaw], [Beast], [Undead], [Arcane], [Void], 
  [Nature], [Elite], [Boss], [Legendary]) must be applied to every enemy from 
  the start for DLC faction bonus compatibility

TaskBoard: https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard
GET ?id=eq.1&select=data to read, PATCH with full { "data": <JSON> } body to write
Use anon JWT as apikey and Authorization: Bearer headers — always read before writing

Confirm you have read all docs and understood the changes before writing any code.
```

---

### Session 2 — Phase 1 Implementation Begins
**Date:** 2026-07-03
**Implementation:** Claude Code
**Status:** Active implementation — core systems being built

**What was implemented:**
- Unity Tools menu confirmed working (Supabase Config, Build Scene, Phase 1 Data Assets)
- **Inventory UI** — complete redesign via CanvasBuilder:
  - Category tabs: 2-row × 5-column grid at bottom (better mobile tap targets)
  - Search bar above tab bar for mobile ergonomics
  - Slot grid: 5 columns, 133px cells
  - Header: SM/GM currency display with live labels
  - Slot colors runtime-driven (empty/filled/locked states)
  - RectMask2D used throughout (DX12 stencil fix — Mask breaks on DX12)
- **Active Attunement System** — built from scratch:
  - TalentActivity fields: hasAttunement, attunementCueLabel, attunementWindowAt, attunementWindowDuration, attunementXPBonus, attunementLootBonus
  - IdleManager: OnAttunementWindowOpen/Close events, TapAttunement() method, XP multiplier and loot bonus on success
  - AttunementUI.cs: pulsing tap button, success/miss feedback animations
  - AttunementCompanionUI.cs: cycle bar fill, talent/activity labels, attunement description
- **Desktop Split-View** — DesktopLayoutManager.cs:
  - Landscape: inventory right half, AttunementCompanion left half
  - Portrait/mobile: untouched single column
  - Canvas RectTransform detection (not Screen.width) — avoids false portrait in editor
  - ForceDesktopLayout flag + context menu for editor testing
- LootToastUI updated for split-view positioning

**Decisions made during implementation:**
- Attunement system opt-in per activity (hasAttunement = false by default)
- Slot colors runtime-driven not prefab default — allows dynamic locked state changes
- AttunementCompanionPanel is dedicated panel (not resized CategoryTalentPanel)

**Currently blocking / in progress:**
- Attunement data empty — hasAttunement + cue labels need setting on TalentActivity ScriptableObjects per activity type
- WYWA applies XP but not items — needs ItemData ScriptableObject assets + AddItemByName on InventoryManager
- Guild bank UI not started
- Bowstring combat not started
- Firebase not started

**Top 3 for next Claude Code session:**
1. Wire attunement into TalentActivity ScriptableObjects (hasAttunement, cue labels, attunementWindowAt timing per activity)
2. Guild bank UI
3. WYWA item application (ItemData assets + InventoryManager.AddItemByName)

---

### Session 3 — Design Continuation (Complete)
**Date:** 2026-07-04
**Chat:** Claude.ai
**Status:** Phase 1 design complete — ready for Claude Code handoff

**What was designed this session:**
- Slaying Talent full spec — dungeon mastery model, task board, XP sources (dungeon/elite/boss/task), level unlocks, spawn rate bonuses, raid access at Slaying 45, task slot milestones at level 25/50, Royal Merchant slots 6/7/8
- Attunement window data spec v0.2 — all Phase 1 talents with tighter window durations (0.6–1.5s), assembly success % bonus for crafting talents (Runesmithing 25%, Tailoring/Arcane Weaving 20%, Artificing 15%)
- Assembly ownership reworked — Timber Shaping (bow/tools), Runesmithing (metal weapons/armor), Tailoring (leather/vestments/quiver), Arcane Weaving (wand/staff), Artificing (tools/kits), Tanning (supplier only)
- Bow component update — Timber limbs + Tanning leather handle guard + Runesmithing tips + Gemstone rare material
- Trapping confirmed as primary non-combat hide/meat source for pure crafters
- Enchanting merged into Inscription — gear enchanting gates on equipment tier ownership
- Zone Maps reworked — consumable 1hr zone-specific buffs, 4 quality tiers by Inscription level
- Summoner's Tome moved to dungeon/raid rare drop (Tier 3+)
- Royal Merchant — premium store lives inside Wayfarer's Exchange as vendor tab
- Tradeable ticket model — replaces direct Gold Mark purchases, tickets tradeable on Exchange
- Player Account System — email + password, username moderation (3-layer), security questions, soft delete (30-day grace), full Supabase data schema
- Inventory & Character Panel — 70 slots, 9 categories, custom sort, placeholders, item locking, guild bank (50 slots), buff HUD row
- Audio direction — Moonlit Caravan, Battle, Silent Save Point confirmed. SNES chiptune. Notice Board replaces push for raid advance notice
- Settings screen — Audio, Notifications, Account, Display, Accessibility, Privacy. Attunement window duration modifier removed. Guild chat deferred to Phase 4 chat UI
- Push notification triggers — P1–P4 priority system, 3-notification/4hr cap, 30-min cooldown, FCM payload structure, deep links, Android channels, Notice Board spec
- Exchange unlock flow — Talent level 10 gate, banner slide-in, one-time welcome panel, starter tooltip
- Infrastructure & cost planning — Supabase ~$50–60/mo, Firebase FCM $0, RevenueCat added to stack
- Revenue projections — 2–5% conversion, $2,720–$13,600/mo net at 20K MAU
- RevenueCat confirmed — cross-platform purchase validation, conversion reporting, A/B testing
- Admin/moderation backend — Retool at admin.refugeswordpublishing.com, free under 5 users

**All files for this handoff:**

| File | Repo Location | Status |
|------|---------------|--------|
| CLAUDE.md | `/CLAUDE.md` | Updated — RevenueCat added |
| game-design-doc.md | `/docs/design-doc.md` | v1.0 |
| talent-spec-sheets.md | `/docs/talent-spec-sheets.md` | v0.3 |
| assembly-materials-crafting-system.md | `/docs/assembly-materials-crafting-system.md` | v0.4 |
| subclass-trees-warden.md | `/docs/subclass-trees-warden.md` | v0.2 |
| subclass-trees-arcanist.md | `/docs/subclass-trees-arcanist.md` | v0.2 |
| subclass-trees-vanguard.md | `/docs/subclass-trees-vanguard.md` | v0.2 |
| deferred-systems-dlc-notes.md | `/docs/deferred-systems-dlc-notes.md` | v0.3 |
| monetization-scope.md | `/docs/monetization-scope.md` | v0.3 |
| slaying-talent-spec.md | `/docs/slaying-talent-spec.md` | NEW |
| attunement-data-spec.md | `/docs/attunement-data-spec.md` | NEW v0.2 |
| inventory-character-system.md | `/docs/inventory-character-system.md` | NEW |
| audio-sfx-direction.md | `/docs/audio-sfx-direction.md` | NEW |
| player-account-system.md | `/docs/player-account-system.md` | NEW v0.2 |
| settings-screen.md | `/docs/settings-screen.md` | NEW |
| push-notification-triggers.md | `/docs/push-notification-triggers.md` | NEW |
| exchange-unlock-flow.md | `/docs/exchange-unlock-flow.md` | NEW |
| infrastructure-cost-planning.md | `/docs/infrastructure-cost-planning.md` | NEW |
| session-handoff-log.md | `/docs/session-handoff-log.md` | This document |

---

### Session 4 — Phase 2 Design (Complete — Ready for Handoff)
**Date:** 2026-07-10
**Chat:** Claude.ai
**Status:** Phase 2 design complete — ready for Claude Code handoff

**What was designed this session:**
- Runic Constellation full spec (v0.2) — 6-rune subclass layouts, targeting drag mechanic, counter pairs per subclass
- Vanguard Melee Combo System — Strike/Guard/Surge, 1.5s auto-fire, combo streak, subclass libraries
- Warfare spec — Vanguard Grimoire combat progression, permanent stat milestones, attunement data
- Summoner spec — construct HP pool mechanic, 6 construct types, active engagement (specials + synergies), 50% idle vs 100% active gap
- Lifebinder spec — HP as casting resource, HOT system, passive regen, no Umbra node
- Bloodweaver added to deferred DLC — dark mirror of Lifebinder
- Guild Hall UI full spec — discovery screen, Home (signpost MOTD, quest board, Guild Merchant), Roster, Bank, Upgrades, Settings tabs
- Exchange fee restructure — solo players 3% system tax, guild members 0–3% guild tax replacing it, Guild Merchant at half guild tax rate
- Phase 2 zone tables — Ashfen Mire [Undead][Nature] + Ironspine Reaches [Outlaw][Beast], full enemy rosters, elites, bosses, Mirefall Barrow + Warden's Folly dungeons
- Spellcasting attunement data — speed + counter independent checks, no crit system for Arcanist
- Grimoire Combat Progression (MAJOR PIVOT) — combat Talents removed from shared system, each Grimoire has own combat level 1–100
- Total Combat Level = sum of all owned Grimoire levels — zone gate + prestige stat on character screen
- Combat Tab on Character Panel — shows equipped Grimoire progression, unlocked techniques, all owned Grimoires
- 6-rune subclass layouts — positions 1–4 shared, 5–6 unique (Runeweaver: Umbra/Lux, Summoner: Terra/Umbra, Lifebinder: Vita/Lux)
- Targeting drag mechanic — universal Arcanist, draw then drag to target
- Aggro hybrid model — passive rate + damage multiplier + taunt combos
- Combat Engagement spec — zone (over-the-shoulder all classes), dungeon (top-to-bottom scrolling, randomized room pools), raid (grid turn-based map, dynamic encounter joining, Rush mechanic, floor objectives)
- Shadowblade updated — Black Ledger removed, Shadow Step as Shroud state, Hemorrhage Mastery
- Permanent stat bonuses from Grimoire milestones — cross-path accumulation (Warden=DEX/LCK, Arcanist=INT/WIL, Vanguard=STR/VIT)
- Phase 2 attunement data — Gleaning contexts, Cultivation tiered windows, Tracking queue system (Monster Sign), Warfare attunement
- Combat XP curve — accelerating, ~6 months to level 100 first Grimoire, ~3 years full mastery
- Guild Bounties deferred to post-launch
- Divination Talent removed and deferred
- Beastmastery DLC stubs in Trapping/Tracking

**Consistency sweep completed:**
- Shadow's Edge etc: crit visual kept, backend is +150% damage multiplier
- Shadowcraft → Warfare throughout all docs
- Black Ledger fully removed from base game
- 8-node → 6 active nodes in constellation spec
- Enchanting → Inscription enchanting throughout talent spec
- Foci Orb description updated
- Divination removed and deferred
- Beastmastery stubs added for DLC
- Cross-path unlock requirements updated (Shadowcraft 1 → Shadowblade Grimoire owned)
- Revive Pulse on Lifebinder Tempest corrected to Static Field
- Dodge clarification note added to combo system
- Runeweaver/Lifebinder/Summoner unlock table headers updated to Grimoire combat level

**All files updated this session:**

| File | Status |
|------|--------|
| runic-constellation-spec.md | NEW v0.2 |
| vanguard-combo-system.md | NEW v0.1 |
| warfare-spec.md | NEW v0.1 |
| summoner-spec.md | NEW v0.1 |
| lifebinder-spec.md | NEW v0.1 |
| combat-engagement-spec.md | NEW v0.1 |
| phase2-zone-tables.md | NEW v0.1 |
| phase2-attunement-data-spec.md | NEW v0.4 |
| combat-xp-curve.md | NEW v0.1 |
| guild-hall-ui-spec.md | NEW v0.1 |
| game-design-doc.md | Updated — combat talents removed, Black Ledger removed |
| talent-spec-sheets.md | v0.5 — Divination deferred, Enchanting→Inscription, Beastmastery stubs |
| subclass-trees-warden.md | v0.4 — Grimoire combat level language, Vanishing Act fixed |
| subclass-trees-arcanist.md | v0.4 — Black Ledger removed, Spellcasting→Grimoire level, Tempest fixed |
| subclass-trees-vanguard.md | v0.4 — Crit→damage multiplier, Shadowcraft→Warfare |
| wayferers-exchange-and-grimoire-system.md | Updated — Grimoire Combat Progression, fee restructure |
| stat-scaling-combat-formulas.md | v0.3 — Aggro system, Summoner HP, Lifebinder HP |
| attunement-data-spec.md | v0.3 — Grimoire combat level references |
| slaying-talent-spec.md | Updated — zone gating removed, task board only |
| enemy-zone-tables.md | Updated — Total Combat Level thresholds added |
| inventory-character-system.md | Updated — Combat Tab added |
| guild-system.md | v0.3 — 30-day tax cooldown |
| deferred-systems-dlc-notes.md | Updated — Bloodweaver, Guild Bounties, Black Ledger notes |
| art-asset-requirements.md | v0.2 — 256x256 sprites, Unity import settings |
| CLAUDE.md | Updated — Grimoire Combat Progression, no combat talents |
| infrastructure-cost-planning.md | Updated — revenue projections, RevenueCat |
| session-handoff-log.md | This document v0.5 |

---

*Document version 0.5 — Session Handoff Log*



---

### Session N — Phase 3 Content, Material Economy, Quest System (Complete)
**Date:** 2026-07-25
**Chat:** Claude.ai
**Status:** Design complete, ready for Claude Code implementation

---

**What was designed this session:**

1. Material Economy (docs/material-economy.md — NEW)
   - Delving as a proper standalone gathering talent (ores, gems, amber, cave drops)
   - Smelting as a proper standalone processing talent (ore to bars, alloy recipes)
   - Forge as a new tool type (assembled by Runesmithing, Runic Cog as rare mat)
   - Full pipeline: Delving -> Smelting -> Runesmithing for all metal
   - Leather grade renames: Rough/Cured/Fine/Masterwork Leather -> Rabbit Hide / Fox Leather / Wolf Leather / Direwolf Leather
   - Reconciled leather chain: pelt -> leather grade -> armour tier, one consistent table
   - Drake Scale drops as Drake Leather directly (no Tanning recipe)
   - Shadow Pelt -> Shadow Essence via Alchemy 60 (3x Shadow Pelt)
   - Arcane apparatus acquisition paths (Iron/Steel/Steel Clockwork/Mithril/Adamantine Apparatus, Void Foci)
   - Pine Haft recipe (Timber Shaping 1, 2x Pine Log)
   - Full zone alignment table for every material

2. Equipment Tier Design (docs/equipment-tier-design.md — UPDATED)
   - Two-axis model confirmed: quality = instance flag via bench, tier = crafted item ladder
   - Formula: FinalStat = QualityValue(quality) + TierBonus(tier) — additive, not multiplicative
   - Five tiers: Bronze/Iron/Steel/Mithril/Void, matching zone bands T1-T5
   - tierWeaponBonus[] = {0, 0, 20, 45, 80, 125}
   - tierPlateBonus[] = {0, 0, 8, 18, 32, 50}; tierLeatherBonus[] = {0, 0, 5, 12, 22, 35}; tierVestmentBonus[] = {0, 0, 3, 8, 14, 22}
   - Stat bonuses and evasion: quality-only, no tier component
   - Tools: quality-only, no material tiers
   - All existing T1 items produce identical output (materialTier defaults to 1)

3. Stat Scaling (docs/stat-scaling-combat-formulas.md — UPDATED to v0.4)
   - Weapon damage and armour rating tables updated to reflect tier+quality additive model
   - Balance checkpoints relabelled from quality names to zone/material tier names

4. Assembly Materials (docs/assembly-materials-crafting-system.md — UPDATED to v0.6)
   - Header note added: Bronze/Iron/Steel/Mithril/Void are material tiers now, not quality steps
   - As-built bench components documented (shared-by-band, not per-item)

5. Phase 3 Dungeon Room Pools (docs/dungeon-room-pools-phase3-brief.md — NEW)
   - Gravenspire (Dreadhollow): 8-room pool, boss The Hollow Archbishop (9,200 HP, 3 phases)
   - Ignarath's Maw (Cinderpeak): 8-room pool, boss Ignarath's Broodmother (7,800 HP)
   - New puzzle types: PyrePuzzle (Gravenspire), PressureValvePuzzle (Ignarath's Maw)
   - New hazards: Void Seep, Void Seep Cascade, Lava Vent, Collapsing Masonry, Hatching Egg
   - First clear bonus: 2,000 Combat XP for T3 dungeons

6. Phase 3 Sprite Prompts (docs/phase1-sprite-prompts.md — UPDATED to v0.5)
   - Dreadhollow enemies: 4 standard, 2 elite, 1 zone boss (all prompts written)
   - Cinderpeak enemies: 4 standard, 2 elite, 1 zone boss, 1 dungeon boss (all prompts written)
   - Dreadhollow combat backdrop (1920x1080) + Gravenspire parallax (3 layers)
   - Cinderpeak combat backdrop (1920x1080) + Ignarath's Maw parallax (3 layers)
   - Generation order and style anchor notes for each zone

7. Asset Tracker Seed (asset-prompts-seed.json — UPDATED, now 116 records)
   - New sheets: enemies_dreadhollow, enemies_cinderpeak, enemies_dungeons_p3
   - New sheets: bg_dreadhollow, bg_cinderpeak
   - 26 new records total

8. Phase 3 Attunement Data (docs/phase3-attunement-data-spec.md — NEW)
   - Tanning: first-ever tiered attunement (5 hide grades, Pulse cue, 12-40s cycles)
   - Smelting: full attunement design (HeatGauge cue type — new, vertical fill bar)
   - Forge quality affects gauge variance (Crude unpredictable, Masterwork nearly clockwork)
   - Voidtimber Felling: irregular cycle context in Dreadhollow
   - Delving T3 node placement table (zone-by-zone ore assignment)
   - Combat zone events: Void Pulse (Dreadhollow, +20% dmg, +10% idle), Thermal Vent Burst (Cinderpeak, +15% dmg, +8% idle)
   - Dragon Eel Dredging context (cycle 20s, window 0.35, 0.8s duration)
   - Gleaning T3 dungeon cache confirmation

9. Phase 3 Enemy Content Brief (docs/phase3-enemy-content-brief.md — NEW)
   - All EnemyData fields for 4 standard + 2 elite + 1 zone boss per zone
   - All EnemyData for both dungeon bosses (Archbishop and Broodmother)
   - New enemy mechanics: Void Shade phase-out, Lava Construct WP retaliation, Drake channel-dependent WP tier, Broodmother Protective Surge
   - Full drop tables with quality ranges
   - Spawn weight tables

10. Daily/Weekly Quest System (docs/daily-weekly-quest-system.md — NEW)
    - New GamePanel.Quests entry (between Guild and Settings)
    - QuestDefinition ScriptableObject with full field set including factionId and factionReputationAward (DLC hook, zero in base game)
    - 10 QuestType values: GatherItem, ProcessItem, CraftItem, DefeatEnemies, DefeatElites, DefeatBoss, CompleteDungeon, EarnTalentXP, ReachZone, SellOnExchange
    - Supabase player_quests table + RLS
    - collect_quest_reward RPC — currency granted server-side additively (never client write)
    - assign_quests Edge Function — server-authoritative resets (daily 00:00 UTC, weekly Monday 00:00 UTC)
    - QuestProgressTracker subscribes to existing manager events; idle play counts
    - Zone-tier gating via minZoneTier/maxZoneTier on QuestDefinition
    - 15 daily + 10 weekly launch quest definitions (authored as ScriptableObjects)
    - Pool draw: 3 daily, 2 weekly; type mix constraint (max 2 same type per daily set)

---

**Files to commit to repo:**

| File | Path | Status |
|------|------|--------|
| material-economy.md | docs/material-economy.md | NEW |
| equipment-tier-design.md | docs/equipment-tier-design.md | UPDATED |
| stat-scaling-combat-formulas.md | docs/stat-scaling-combat-formulas.md | UPDATED v0.4 |
| assembly-materials-crafting-system.md | docs/assembly-materials-crafting-system.md | UPDATED v0.6 |
| dungeon-room-pools-phase3-brief.md | docs/dungeon-room-pools-phase3-brief.md | NEW |
| phase1-sprite-prompts.md | docs/phase1-sprite-prompts.md | UPDATED v0.5 |
| phase3-attunement-data-spec.md | docs/phase3-attunement-data-spec.md | NEW |
| phase3-enemy-content-brief.md | docs/phase3-enemy-content-brief.md | NEW |
| daily-weekly-quest-system.md | docs/daily-weekly-quest-system.md | NEW |
| asset-prompts-seed.json | (asset tracker DB seed, upsert on conflict) | UPDATED 116 records |

---

**Handoff prompt for Claude Code:**

```
Read implementation-status.md first, then these updated and new docs before doing anything:

UPDATED:
- docs/material-economy.md (NEW — Delving and Smelting as proper talents, leather renames, full acquisition paths)
- docs/equipment-tier-design.md (UPDATED — two-axis model, additive tier bonus arrays, ItemData.materialTier field contract)
- docs/stat-scaling-combat-formulas.md (UPDATED v0.4 — weapon/armour tables updated for tier+quality additive model)
- docs/assembly-materials-crafting-system.md (UPDATED v0.6 — Bronze/Iron/Steel/Mithril/Void are now material tiers, not quality steps; as-built bench components documented)

NEW (Phase 3 content):
- docs/dungeon-room-pools-phase3-brief.md (Gravenspire + Ignarath's Maw room pools, bosses, puzzles, hazards)
- docs/phase3-attunement-data-spec.md (Tanning tiered attunement, Smelting HeatGauge attunement, combat zone events, Delving node placement)
- docs/phase3-enemy-content-brief.md (all T3 EnemyData: HP, damage, weak points, drop tables, new mechanics)
- docs/daily-weekly-quest-system.md (full quest system: new nav panel, data model, 10 quest types, reward RPC, Edge Function, progress tracker, 25 launch quest definitions)

Summary of what changed:

MATERIAL ECONOMY AND TALENT PIPELINE:
- Delving is a new standalone gathering talent (ore, gems, amber, cave drops). Pickaxe as tool.
- Smelting is a new standalone processing talent (ore to bar, alloy recipes). Forge is a new tool type assembled by Runesmithing.
- Pipeline: Delving -> Smelting -> Runesmithing for all metal. All "Smelting X" level gates in equipment-tier-design.md are Smelting talent levels, not Runesmithing.
- Leather renames (apply everywhere): Rough Leather -> Rabbit Hide, Cured Leather -> Fox Leather, Fine Leather -> Wolf Leather, Masterwork Leather -> Direwolf Leather
- Drake Scale drops as Drake Leather directly — no Tanning recipe needed
- Shadow Pelt -> Shadow Essence via Alchemy 60 (3x Shadow Pelt)
- Pine Haft: Timber Shaping 1, 2x Pine Log -> 1x Pine Haft, 20s

EQUIPMENT TWO-AXIS MODEL:
- ItemData gains int materialTier = 1 (default, preserves all existing items)
- Weapon damage: finalDmg = qualityDamageMin[quality] + tierWeaponBonus[materialTier]
  tierWeaponBonus = {0, 0, 20, 45, 80, 125}
- Armour rating: finalArmour = qualityArmourRating[quality][type] + tierArmourBonus[materialTier][type]
  tierPlateBonus = {0, 0, 8, 18, 32, 50}
  tierLeatherBonus = {0, 0, 5, 12, 22, 35}
  tierVestmentBonus = {0, 0, 3, 8, 14, 22}
- Evasion, stat bonuses, tool idle multiplier: quality-only, no tier component

PHASE 3 CONTENT:
- Zone 3A Dreadhollow [Undead][Void]: 4 standard, 2 elite, zone boss Hollow Archbishop, dungeon Gravenspire
- Zone 3B Cinderpeak [Beast][Arcane]: 4 standard, 2 elite, zone boss Ignarath, dungeon Ignarath's Maw + boss Broodmother
- New enemy mechanics: Void Shade phases out 1.5s every 8s; Lava Construct retaliates on WP hit (20%); Drake throat WP Subtle normally / Obvious during Fire Breath only; Broodmother Protective Surge amplifies WP to 2.5x in Phase 2
- New hazards: Void Seep, Lava Vent, Collapsing Masonry, Hatching Egg
- New puzzle types: PyrePuzzle (Gravenspire), PressureValvePuzzle (Ignarath's Maw)

ATTUNEMENT:
- Tanning: new tiered attunement, 5 hide grades, Pulse cue, 12-40s cycles
- Smelting: new HeatGauge cue type (vertical fill bar, tap when in target band). Forge quality affects fill variance.
- Combat zone events: VoidPulse (Dreadhollow) and ThermalVentBurst (Cinderpeak) — passive idle bonus + active tap bonus

QUEST SYSTEM:
- New GamePanel.Quests between Guild and Settings
- New Supabase table: player_quests
- New Edge Function: assign_quests (daily 00:00 UTC, weekly Monday 00:00 UTC)
- New RPC: collect_quest_reward — grants currency server-side additively (never client write — avoids SaveCurrency clobber bug)
- QuestDefinition ScriptableObject with factionId + factionReputationAward fields at 0/empty (DLC hook)
- 25 launch quest definitions (15 daily, 10 weekly) — author as ScriptableObjects
- QuestProgressTracker subscribes to existing manager events; idle play counts toward all applicable quest types

What to implement now (priority order):
1. Leather material renames — apply old->new mapping to all ItemData, Tanning recipes, assembly component references
2. ItemData.materialTier field — default 1, wire into stat derivation with the tier bonus arrays above
3. Delving talent — new gathering talent, ore/gem/amber nodes per zone per zone alignment table in material-economy.md, Pickaxe as tool
4. Smelting talent — new processing talent, all bar and alloy recipes from material-economy.md, Forge as new tool (assembly table in phase3-attunement-data-spec.md)
5. Pine Haft recipe — Timber Shaping 1, 2x Pine Log, 20s
6. Arcane apparatus recipes — all five in material-economy.md Section 6
7. Drake Leather — direct enemy drop from Drake enemies (T4-T5), no Tanning
8. Shadow Essence — Alchemy recipe: 3x Shadow Pelt, Alchemy 60
9. Phase 3 enemy EnemyData ScriptableObjects — all 12 enemies per phase3-enemy-content-brief.md
10. Phase 3 dungeon DungeonData ScriptableObjects — per dungeon-room-pools-phase3-brief.md
11. Tanning tiered attunement — 5 new TalentActivity entries per phase3-attunement-data-spec.md
12. Smelting HeatGauge attunement — new cue type + 7 bar recipes per phase3-attunement-data-spec.md
13. Combat zone events — VoidPulse (Dreadhollow) and ThermalVentBurst (Cinderpeak)
14. Quest system — GamePanel, player_quests table, assign_quests Edge Function, collect_quest_reward RPC, QuestProgressTracker, Quest Board UI, 25 QuestDefinition ScriptableObjects

Do not implement yet:
- T4/T5 zone content (no dungeon briefs, sprite prompts, or attunement written)
- Lifebinder support kit (shields, cleanse, revive — deferred)
- Enchanting system (stubbed at 0, no design)
- Onboarding flow (no UX spec)
- Faction reputation system (DLC)
- Guild Bounties (post-launch)

Taskboard: https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard
GET ?id=eq.1&select=data to read current state
PATCH with full {"data": <JSON>} body to write
Always read before writing — never overwrite blindly

Add these tasks (read board first):
- Leather material renames (all assets + assembly tables)
- ItemData.materialTier field + stat formula update
- Delving talent implementation (gathering talent, nodes per zone)
- Smelting talent implementation (processing talent, Forge tool)
- Pine Haft recipe
- Arcane apparatus recipes (5 Artificing recipes)
- Drake Leather direct drop
- Shadow Essence Alchemy recipe
- Phase 3 enemy EnemyData ScriptableObjects (12 enemies)
- Phase 3 dungeon DungeonData ScriptableObjects (Gravenspire + Ignarath's Maw)
- Tanning tiered attunement (5 TalentActivity entries)
- Smelting HeatGauge attunement (new cue type + 7 entries)
- Combat zone events (VoidPulse, ThermalVentBurst)
- Quest system (GamePanel, DB, Edge Function, RPC, tracker, UI, 25 ScriptableObjects)
- Upsert asset-prompts-seed.json into asset_prompts table (116 records, on conflict update)
```


---

### Session N+1 — Assembly Reconciliation, T1 Dungeons, Material Economy Corrections, Quest System, Talent Reference Spreadsheet
**Date:** 2026-07-27
**Chat:** Claude.ai
**Status:** Design complete, ready for Claude Code implementation

---

**What was designed or corrected this session:**

1. Assembly Implementation Spec v2.0 (docs/assembly-implementation-spec.md — UPDATED, now canonical)
   - Reconciled against material-economy.md, assembly-materials-crafting-system.md v0.6, and post-Processing-merge talent structure
   - Canonical tool list corrected to 9 tools (Smith's Hammer and Carpenter's Kit removed, Forge and Foraging Sickle added, Tanning Knife replaces Tanning Frame)
   - Arcane Weaving dissolved into Artificing throughout all tables
   - Leather component names updated: Rabbit Hide / Fox Leather / Wolf Leather / Direwolf Leather / Drake Leather
   - Rare material substitutions: Abyssal Pearl -> Phantom Pelt, Aetheric Filament -> Ancient Sigil, Prismatic Seed -> Runic Cog
   - Pickaxe rare material: Runic Cog (confirmed this session)
   - assembly-materials-crafting-system.md demoted to design reference only; assembly-implementation-spec.md v2.0 is what code builds from

2. T1 Dungeon Design (docs/dungeon-room-pools-t1-brief.md — NEW)
   - Aldric's Warren (Grimwood Fringe, recommended level 8): 2-3 rooms, 2 enemies per room, no puzzle, no hazards, boss Aldric the Wolf (1,800 HP, 2 phases)
   - Crestfall Cove (Saltmarsh Shore, recommended level 12): 2-3 rooms, one optional mild hazard (Tidal Surge, movement penalty only, no damage), boss Captain Mirra Vane (2,100 HP, 2 phases)
   - New hazard: Tidal Surge (HazardType enum addition, movement -15% for 8s, no DoT)
   - First-clear XP: 500 (vs 1,000 T2, 2,000 T3)
   - Wire to existing placeholder dungeon tiles in Grimwood and Saltmarsh zone UI

3. Material Economy Corrections (docs/material-economy.md — corrections noted, doc needs update)
   - Amber moved from Delving to Felling: amber is hardened tree resin, drops from felling nodes
   - Inscription now uses Vellum (from Tanning) as base material, not papyrus. Pipeline: Trapping -> Tanning (vellum) -> Inscription
   - Tanning produces: Rabbit Hide, Fox Leather, Wolf Leather, Direwolf Leather, Drake Leather, Shadow Leather, Vellum, Fine Vellum, Runed Vellum
   - Tanning has no Assembly bench rare material (no rarity tiers on hides or vellum)
   - Reagent pipeline is Foraging -> Alchemy -> Alchemy output. Artificing is NOT the reagent pipeline owner.
   - Rare Spice: Foraging rare drop, T2+ zones (same pattern as Moonbloom Petal at T3). Feeds Cookery.
   - Cultivation: deferred DLC. Do not build for base game. Add to deferred-systems-dlc-notes.md.

4. Art Tracker Files (phase3-art-skeleton.json, dungeon-art-skeleton.json filled)
   - 30 dungeon art prompts filled: 2 boss sprites, 6 dungeon parallax layers, 4 puzzle props, 6 hazard telegraphs, 12 boss-drop item icons
   - 37 Phase 3 art prompts filled: T3 item drops, inscription scrolls/vellum, room type icons, puzzle props, hazard telegraphs, locked zone overlay
   - art-asset-requirements.md updated to v0.7 with full dungeon system art section (Tiers 1-3)

5. Talent Reference Spreadsheet (grimoire-talent-reference.xlsx — NEW)
   - 4 sheets: Talent Overview, Talent Detail (with dropdowns), Material Pipeline, Assembly Bench
   - 16 active talents + Cultivation (DLC deferred, purple)
   - Dropdowns on Talent Detail sheet show each talent's full item list
   - Pipeline sheet shows all 10 material families including Amber (Felling) and Rare Spice (Foraging)

---

**Open design questions answered this session:**

| Question | Answer |
|----------|--------|
| Pickaxe rare material | Runic Cog (Gleaning) |
| Rare Spice acquisition | Foraging rare drop, T2+ zones |
| Cultivation talent scope | Deferred DLC, farming loop for Cookery/Alchemy |
| Amber source | Felling (tree resin), not Delving |
| Inscription base material | Vellum from Tanning, not papyrus |
| Tanning rare material | None — no rarity tiers on hides or vellum |
| Reagent pipeline owner | Alchemy, not Artificing |

---

**Files to commit to repo:**

| File | Path | Status |
|------|------|--------|
| assembly-implementation-spec.md | docs/assembly-implementation-spec.md | UPDATED v2.0, now canonical |
| dungeon-room-pools-t1-brief.md | docs/dungeon-room-pools-t1-brief.md | NEW |
| art-asset-requirements.md | docs/art-asset-requirements.md | UPDATED v0.7 |
| grimoire-talent-reference.xlsx | (reference only, not a doc) | NEW |

**Doc updates needed (not yet committed as separate files this session):**

- docs/material-economy.md: update Amber source (Felling not Delving), add Inscription/Vellum pipeline note, add Rare Spice as Foraging drop, note Tanning has no bench rare material
- docs/deferred-systems-dlc-notes.md: add Cultivation to the deferred list

---

**Handoff prompt for Claude Code:**

```
Read implementation-status.md first, then these docs:

CANONICAL CHANGE:
- docs/assembly-implementation-spec.md (UPDATED v2.0 — this is now canonical for assembly;
  assembly-materials-crafting-system.md is design reference only, do not build from it)

NEW:
- docs/dungeon-room-pools-t1-brief.md (T1 dungeon brief for Aldric's Warren and Crestfall Cove)
- docs/art-asset-requirements.md (UPDATED v0.7 — full dungeon art section added)

MATERIAL ECONOMY CORRECTIONS (apply these, then update material-economy.md):
1. Amber source: Felling (tree resin from felling nodes), NOT Delving. Remove amber from Delving
   drop tables. Add Crude/Rough/Refined/Pristine Amber to Felling idle gather per zone.
2. Inscription base material: Vellum (from Tanning), not papyrus. Pipeline:
   Trapping -> Tanning (produces vellum grades) -> Inscription (consumes vellum).
   Tanning recipes to add: Rabbit Pelt -> Vellum, Fox Fur -> Fine Vellum,
   Wolf Pelt -> Runed Vellum (exact ratios TBD, suggest 2x pelt -> 1x vellum).
3. Tanning produces: Rabbit Hide, Fox Leather, Wolf Leather, Direwolf Leather,
   Drake Leather, Shadow Leather, Vellum, Fine Vellum, Runed Vellum.
   Tanning has NO Assembly bench rare material — no rarity tiers on hides or vellum.
4. Reagent pipeline: Foraging -> Alchemy -> output. Artificing is NOT the reagent owner.
   Remove any reagent pipeline references from Artificing.
5. Rare Spice: Foraging rare drop, T2+ zones (same pattern as Moonbloom Petal).
   Add to Foraging drop table at same rarity tier as Moonbloom. Feeds Cookery.
6. Cultivation: add to deferred-systems-dlc-notes.md. Do not build for base game.

ASSEMBLY SPEC v2.0 KEY CHANGES (read the full spec, but highlights):
- Canonical tool list is 9: Axe, Pickaxe, Trapper's Kit, Fishing Rod, Foraging Sickle,
  Tanning Knife, Alchemy Kit, Cookery Set, Forge.
  Do NOT build: Smith's Hammer, Carpenter's Kit, Weaving Loom.
- Pickaxe rare material: Runic Cog (was Amber in v1.0).
- Alchemy Kit rare material: Ancient Sigil (was Aetheric Filament).
- Cookery Set rare material: Runic Cog (was Prismatic Seed).
- All leather component names use new grades (Rabbit Hide Wrap, Fox Leather Pouch, etc.)
- Arcane Weaving is dissolved into Artificing everywhere.
- As-built bench uses shared components per quality band (see Section 6 of spec).

T1 DUNGEONS:
- Wire Aldric's Warren placeholder tile (Grimwood Fringe) to DungeonData ScriptableObject.
- Wire Crestfall Cove placeholder tile (Saltmarsh Shore) to DungeonData ScriptableObject.
- Author EnemyData for Aldric the Wolf and Captain Mirra Vane (full specs in brief).
- Add HazardType.TidalSurge: movement -15% for 8s, no damage, drains after 8s.
- First-clear XP: 500 for T1 dungeons.
- Puzzle do-not-build flag is still in force. T1 dungeons have no puzzles (unaffected).
  Confirm flag status before building T2 dungeons (Mirefall Barrow, Warden's Folly).

TASKBOARD: https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard
GET ?id=eq.1&select=data to read. PATCH with full {"data": <JSON>} to write.
Always read before writing.

Add these tasks:
- Assembly spec v2.0: update tool ItemData for all 9 tools (remove Smith's Hammer,
  Carpenter's Kit; add Forge and Foraging Sickle)
- Amber: move from Delving to Felling drop tables
- Inscription: wire to Vellum input from Tanning
- Tanning: add Vellum/Fine Vellum/Runed Vellum recipes
- Tanning: remove Assembly bench rare material slot
- Rare Spice: add to Foraging drop table (T2+, rare)
- Cultivation: add to deferred-systems-dlc-notes.md
- material-economy.md: apply all six corrections above
- T1 dungeons: Aldric's Warren and Crestfall Cove DungeonData + EnemyData
- HazardType.TidalSurge implementation
- art-asset-requirements.md: commit v0.7
```
