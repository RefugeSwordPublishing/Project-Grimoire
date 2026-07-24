# Project Grimoire, Session Handoff Log
### Living document, updated at end of every design session

---

## Session Trigger Protocol

**When Dustin says "at my desktop" or "ready for handoff":**
Claude.ai looks back through the current session to the previous handoff bookmark, identifies all new or updated files, presents them for download, and generates the Claude Code handoff prompt.

This is the bookmark system, "at my desktop" = handoff point.

---

## Handoff Procedure

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

## Standard Handoff Prompt Template

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

Taskboard updates, read the current TaskBoard first, then add 
these tasks and mark any completed items done:
- [new task 1]
- [new task 2]

TaskBoard: https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard
GET ?id=eq.1&select=data to read current state
PATCH with full { "data": <JSON> } body to write
Use anon JWT as apikey and Authorization: Bearer headers
Always read before writing, never overwrite blindly

Confirm you have read all docs and understood the changes 
before writing any code.
```

### TaskBoard Rules
- Claude Code reads current board before every patch, never overwrites blindly
- New tasks from design sessions added at end of each handoff
- Tasks completed during implementation marked done in same session
- Notable design items flagged in this chat get added to the board via handoff prompt

---

## File Location Reference

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

## Session Log

---

### Session 1, Design Foundation (Complete)
**Date:** June 28-30, 2026
**Chat:** Claude.ai (this session)
**Status:** Full design complete, ready for first Claude Code implementation session

**What was designed:**
- Core game concept, semi-idle RPG, Attunement Surge mechanic
- 7 character stats (STR, DEX, VIT, INT, WIL, LCK, CHA)
- 3 class paths, Warden, Arcanist, Vanguard
- 7 base game Grimoires + 4 DLC Grimoires (Beastbond, Warlock, Kensei, Bard/Minstrel)
- Grimoire binding system, ~24hr cooldown, any base game Grimoire free at start, others 500 GM
- 20+ Talents with full spec sheets, level unlocks, XP curve, organic (non-multiple-of-5) unlock levels
- Unlock terminology, Field Notes, Schematics, Formulae, Patterns, Techniques, Codex Entries
- Weapon/tool assembly, 2 components + rare material at Workbench; armor, 3 components + rare material
- Fail cascade, Masterwork→Refined→Rough→Crude floor, all components consumed regardless of outcome
- 8 cross-Talent rare material types (gathering tools need combat materials and vice versa)
- Quality tiers, Crude/Rough/Refined/Pristine/Masterwork/Legendary(DLC only)
- Wayfarer's Exchange, auction, store listings, buy orders, listing fees, Black Ledger (Shadowblade)
- Currency, Silver Marks and Gold Marks only, no Copper
- 10 combat zones across 5 tiers, branching structure, zone+enemy targeting with spawn weighting
- Zone bosses, active play only, random spawn, 10 min despawn
- Monthly dungeon rotation (2 active), quarterly raids (25-45 min, 3-phase, Masterwork material source)
- Full subclass trees, Sharpshot, Lone Wanderer, Runeweaver, Summoner, Lifebinder, Warlord, Shadowblade
- Bulwark renamed from Vanguarding (avoids redundancy with class name)
- DLC subclasses fully scoped, Beastbond (DEX+CHA), Warlock, Kensei, Bard/Minstrel (WIL+CHA)
- Stat scaling formulas, hybrid gain, diminishing returns past 50, full hit/evasion/block/damage/LCK-wildcard/debuff combat resolution loop
- CHA progression roadmap across DLC tiers (base economy → Beastbond taming → Bard combat → Faction standing)
- Bowstring mechanic, over-the-shoulder, accuracy-based crits, weak point subtle pixel glow, idle mid-draw baseline (prevents spam-tap exploitation)
- Runic Constellation, 8 runes, draw combinations, subclass alters behavior not layout
- 2D pixel art style, Kingdom Two Crowns inspired (pivoted from earlier illustrated style)
- UI mockup built twice, first illustrated/emoji version, then rebuilt fully in pixel art style with working Bowstring prototype
- Daily/Weekly Quest System, player-chosen board (5 of 10 daily, 2 of 6 weekly), midnight UTC refresh, difficulty scales with highest Talent level
- Onboarding Flow, tutorial-first, fully skippable except Grimoire choice, ~4 min guided time
- While You Were Away screen, auto-collected, highlights-first, 24hr idle cap
- Guild System, full design: creation, roster tiers, tax governance, Guild Bounties, infinite Prestige (draws from current balance as genuine tradeoff), Guild Hub visual progression (campfire → stronghold), Guest/Alliance cross-guild access
- Guild-Faction DLC integration plan documented
- Monetization Scope, nothing exclusively pay-walled, no XP boosts ever, no guild power for sale, Early Supporter Badge (binary, non-tiered)
- Art Asset Requirements, full phase-by-phase breakdown of every sprite/environment/UI asset needed
- Phase 1 Sprite Prompt Library, ready-to-use prompts for every Phase 1 asset
- Sprite AI MCP connector identified and configured for direct Claude Code art generation
- Tech stack confirmed, Unity 6, C#, Supabase, Firebase, Unity IAP, GameAnalytics
- Session Handoff Log system established, this document

**All files ready for handoff (place in repo as indicated):**

| File | Repo Location | Status |
|------|---------------|--------|
| CLAUDE.md | `/CLAUDE.md` | New, includes Sprite AI MCP workflow instructions |
| game-design-doc.md | `/docs/design-doc.md` | v1.0, full rewrite, now an index pointing to detail docs |
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
| grimoire-ui-mockup.jsx | `/docs/reference/grimoire-ui-mockup.jsx` | Reference only, not production code, shows pixel art UI direction and working Bowstring prototype logic |

**Before opening Claude Code:**
1. Set up Sprite AI MCP connector (one-time terminal command, see docs/phase1-sprite-prompts.md header for context):
   ```bash
   claude mcp add --transport http sprite-ai https://www.sprite-ai.art/api/mcp --header "Authorization: Bearer YOUR_KEY"
   ```
2. Commit all files above to the repo in their indicated locations
3. Push to GitHub

**Handoff to Claude Code, Session 1:**
```
Read CLAUDE.md and ALL files in /docs before doing anything. This is the 
first Claude Code session for Project Grimoire, no code exists yet.

Confirm you have full context by summarizing:
1. What Project Grimoire is and its core semi-idle philosophy
2. What Phase 1 scope includes (class, talents, zones)
3. What the Bowstring mechanic does and why idle uses mid-draw baseline
4. What the Grimoire system does and the universal vs Grimoire-locked Talent split
5. What NOT to implement yet (check docs/deferred-systems-dlc-notes.md)
6. Confirm the Sprite AI MCP connector is available to you

Once confirmed, do the following in order:

PART A, Project Scaffolding
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
   docs/talent-spec-sheets.md, level, XP, unlock list, primary/secondary stat, 
   unlock term type, idle status

4. Create the Foraging talent as the first TalentData instance using exact 
   unlock data from docs/talent-spec-sheets.md

PART B, Art Generation (using Sprite AI MCP)
Follow the generation order in docs/phase1-sprite-prompts.md:
1. Generate the Warden base body + standard animation set first
2. Use it as a style reference for all subsequent generations
3. Generate bow + quiver as separate equipment layers, verify layering 
   approach works before proceeding
4. Generate the 13 Tier 1 enemies (Grimwood Fringe + Saltmarsh Shore rosters)
5. Generate Phase 1 gathering/processing item icons
6. Save all generated assets to the appropriate Sprites/ subfolder

Do not implement combat logic, market logic, or grimoire switching logic 
yet, scaffolding and art generation only this session.
Do not implement anything in docs/deferred-systems-dlc-notes.md.

TASKBOARD UPDATES, read current board first, then add:
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
- Note: onboarding tutorial scenes need art stubs, do not block on final art
- Note: CHA stat formula slots must remain open, do not hardcode as economy-only
- Note: guild data model needs nullable primary_faction_id field for future DLC
- Note: enemy faction tags ([Outlaw], [Beast], [Undead], [Arcane], [Void], 
  [Nature], [Elite], [Boss], [Legendary]) must be applied to every enemy from 
  the start for DLC faction bonus compatibility

TaskBoard: https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard
GET ?id=eq.1&select=data to read, PATCH with full { "data": <JSON> } body to write
Use anon JWT as apikey and Authorization: Bearer headers, always read before writing

Confirm you have read all docs and understood the changes before writing any code.
```

---

### Session 2, Phase 1 Implementation Begins
**Date:** 2026-07-03
**Implementation:** Claude Code
**Status:** Active implementation, core systems being built

**What was implemented:**
- Unity Tools menu confirmed working (Supabase Config, Build Scene, Phase 1 Data Assets)
- **Inventory UI**, complete redesign via CanvasBuilder:
  - Category tabs: 2-row × 5-column grid at bottom (better mobile tap targets)
  - Search bar above tab bar for mobile ergonomics
  - Slot grid: 5 columns, 133px cells
  - Header: SM/GM currency display with live labels
  - Slot colors runtime-driven (empty/filled/locked states)
  - RectMask2D used throughout (DX12 stencil fix, Mask breaks on DX12)
- **Active Attunement System**, built from scratch:
  - TalentActivity fields: hasAttunement, attunementCueLabel, attunementWindowAt, attunementWindowDuration, attunementXPBonus, attunementLootBonus
  - IdleManager: OnAttunementWindowOpen/Close events, TapAttunement() method, XP multiplier and loot bonus on success
  - AttunementUI.cs: pulsing tap button, success/miss feedback animations
  - AttunementCompanionUI.cs: cycle bar fill, talent/activity labels, attunement description
- **Desktop Split-View**, DesktopLayoutManager.cs:
  - Landscape: inventory right half, AttunementCompanion left half
  - Portrait/mobile: untouched single column
  - Canvas RectTransform detection (not Screen.width), avoids false portrait in editor
  - ForceDesktopLayout flag + context menu for editor testing
- LootToastUI updated for split-view positioning

**Decisions made during implementation:**
- Attunement system opt-in per activity (hasAttunement = false by default)
- Slot colors runtime-driven not prefab default, allows dynamic locked state changes
- AttunementCompanionPanel is dedicated panel (not resized CategoryTalentPanel)

**Currently blocking / in progress:**
- Attunement data empty, hasAttunement + cue labels need setting on TalentActivity ScriptableObjects per activity type
- WYWA applies XP but not items, needs ItemData ScriptableObject assets + AddItemByName on InventoryManager
- Guild bank UI not started
- Bowstring combat not started
- Firebase not started

**Top 3 for next Claude Code session:**
1. Wire attunement into TalentActivity ScriptableObjects (hasAttunement, cue labels, attunementWindowAt timing per activity)
2. Guild bank UI
3. WYWA item application (ItemData assets + InventoryManager.AddItemByName)

---

### Session 3, Design Continuation (Complete)
**Date:** 2026-07-04
**Chat:** Claude.ai
**Status:** Phase 1 design complete, ready for Claude Code handoff

**What was designed this session:**
- Slaying Talent full spec, dungeon mastery model, task board, XP sources (dungeon/elite/boss/task), level unlocks, spawn rate bonuses, raid access at Slaying 45, task slot milestones at level 25/50, Royal Merchant slots 6/7/8
- Attunement window data spec v0.2, all Phase 1 talents with tighter window durations (0.6-1.5s), assembly success % bonus for crafting talents (Runesmithing 25%, Tailoring/Arcane Weaving 20%, Artificing 15%)
- Assembly ownership reworked, Timber Shaping (bow/tools), Runesmithing (metal weapons/armor), Tailoring (leather/vestments/quiver), Arcane Weaving (wand/staff), Artificing (tools/kits), Tanning (supplier only)
- Bow component update, Timber limbs + Tanning leather handle guard + Runesmithing tips + Gemstone rare material
- Trapping confirmed as primary non-combat hide/meat source for pure crafters
- Enchanting merged into Inscription, gear enchanting gates on equipment tier ownership
- Zone Maps reworked, consumable 1hr zone-specific buffs, 4 quality tiers by Inscription level
- Summoner's Tome moved to dungeon/raid rare drop (Tier 3+)
- Royal Merchant, premium store lives inside Wayfarer's Exchange as vendor tab
- Tradeable ticket model, replaces direct Gold Mark purchases, tickets tradeable on Exchange
- Player Account System, email + password, username moderation (3-layer), security questions, soft delete (30-day grace), full Supabase data schema
- Inventory & Character Panel, 70 slots, 9 categories, custom sort, placeholders, item locking, guild bank (50 slots), buff HUD row
- Audio direction, Moonlit Caravan, Battle, Silent Save Point confirmed. SNES chiptune. Notice Board replaces push for raid advance notice
- Settings screen, Audio, Notifications, Account, Display, Accessibility, Privacy. Attunement window duration modifier removed. Guild chat deferred to Phase 4 chat UI
- Push notification triggers, P1-P4 priority system, 3-notification/4hr cap, 30-min cooldown, FCM payload structure, deep links, Android channels, Notice Board spec
- Exchange unlock flow, Talent level 10 gate, banner slide-in, one-time welcome panel, starter tooltip
- Infrastructure & cost planning, Supabase ~$50-60/mo, Firebase FCM $0, RevenueCat added to stack
- Revenue projections, 2-5% conversion, $2,720-$13,600/mo net at 20K MAU
- RevenueCat confirmed, cross-platform purchase validation, conversion reporting, A/B testing
- Admin/moderation backend, Retool at admin.refugeswordpublishing.com, free under 5 users

**All files for this handoff:**

| File | Repo Location | Status |
|------|---------------|--------|
| CLAUDE.md | `/CLAUDE.md` | Updated, RevenueCat added |
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

### Session 4, Phase 2 Design (Complete, Ready for Handoff)
**Date:** 2026-07-10
**Chat:** Claude.ai
**Status:** Phase 2 design complete, ready for Claude Code handoff

**What was designed this session:**
- Runic Constellation full spec (v0.2), 6-rune subclass layouts, targeting drag mechanic, counter pairs per subclass
- Vanguard Melee Combo System, Strike/Guard/Surge, 1.5s auto-fire, combo streak, subclass libraries
- Warfare spec, Vanguard Grimoire combat progression, permanent stat milestones, attunement data
- Summoner spec, construct HP pool mechanic, 6 construct types, active engagement (specials + synergies), 50% idle vs 100% active gap
- Lifebinder spec, HP as casting resource, HOT system, passive regen, no Umbra node
- Bloodweaver added to deferred DLC, dark mirror of Lifebinder
- Guild Hall UI full spec, discovery screen, Home (signpost MOTD, quest board, Guild Merchant), Roster, Bank, Upgrades, Settings tabs
- Exchange fee restructure, solo players 3% system tax, guild members 0-3% guild tax replacing it, Guild Merchant at half guild tax rate
- Phase 2 zone tables, Ashfen Mire [Undead][Nature] + Ironspine Reaches [Outlaw][Beast], full enemy rosters, elites, bosses, Mirefall Barrow + Warden's Folly dungeons
- Spellcasting attunement data, speed + counter independent checks, no crit system for Arcanist
- Grimoire Combat Progression (MAJOR PIVOT), combat Talents removed from shared system, each Grimoire has own combat level 1-100
- Total Combat Level = sum of all owned Grimoire levels, zone gate + prestige stat on character screen
- Combat Tab on Character Panel, shows equipped Grimoire progression, unlocked techniques, all owned Grimoires
- 6-rune subclass layouts, positions 1-4 shared, 5-6 unique (Runeweaver: Umbra/Lux, Summoner: Terra/Umbra, Lifebinder: Vita/Lux)
- Targeting drag mechanic, universal Arcanist, draw then drag to target
- Aggro hybrid model, passive rate + damage multiplier + taunt combos
- Combat Engagement spec, zone (over-the-shoulder all classes), dungeon (top-to-bottom scrolling, randomized room pools), raid (grid turn-based map, dynamic encounter joining, Rush mechanic, floor objectives)
- Shadowblade updated, Black Ledger removed, Shadow Step as Shroud state, Hemorrhage Mastery
- Permanent stat bonuses from Grimoire milestones, cross-path accumulation (Warden=DEX/LCK, Arcanist=INT/WIL, Vanguard=STR/VIT)
- Phase 2 attunement data, Gleaning contexts, Cultivation tiered windows, Tracking queue system (Monster Sign), Warfare attunement
- Combat XP curve, accelerating, ~6 months to level 100 first Grimoire, ~3 years full mastery
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
| game-design-doc.md | Updated, combat talents removed, Black Ledger removed |
| talent-spec-sheets.md | v0.5, Divination deferred, Enchanting→Inscription, Beastmastery stubs |
| subclass-trees-warden.md | v0.4, Grimoire combat level language, Vanishing Act fixed |
| subclass-trees-arcanist.md | v0.4, Black Ledger removed, Spellcasting→Grimoire level, Tempest fixed |
| subclass-trees-vanguard.md | v0.4, Crit→damage multiplier, Shadowcraft→Warfare |
| wayferers-exchange-and-grimoire-system.md | Updated, Grimoire Combat Progression, fee restructure |
| stat-scaling-combat-formulas.md | v0.3, Aggro system, Summoner HP, Lifebinder HP |
| attunement-data-spec.md | v0.3, Grimoire combat level references |
| slaying-talent-spec.md | Updated, zone gating removed, task board only |
| enemy-zone-tables.md | Updated, Total Combat Level thresholds added |
| inventory-character-system.md | Updated, Combat Tab added |
| guild-system.md | v0.3, 30-day tax cooldown |
| deferred-systems-dlc-notes.md | Updated, Bloodweaver, Guild Bounties, Black Ledger notes |
| art-asset-requirements.md | v0.2, 256x256 sprites, Unity import settings |
| CLAUDE.md | Updated, Grimoire Combat Progression, no combat talents |
| infrastructure-cost-planning.md | Updated, revenue projections, RevenueCat |
| session-handoff-log.md | This document v0.5 |

---

*Document version 0.5, Session Handoff Log*


