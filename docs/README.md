# Project Grimoire, Docs Index

**Fetching note:** these are public raw files and Claude Chat (claude.ai) CAN fetch them directly via
the `raw.githubusercontent.com` links below, verified working. The only catch: a doc must be PUSHED
first, an unpushed/uncommitted file 404s. Handoff flow: push the docs, then paste Chat the raw links
for anything added or changed that session. Claude Code (local) reads them from disk. GitHub folder
pages (`/tree/main/docs`) are JS-rendered and fail, use the direct raw links.

**Read `implementation-status.md` FIRST.** It records what is actually built vs. design intent;
when a spec and the code conflict, it wins.

Raw base: `https://raw.githubusercontent.com/RefugeSwordPublishing/Project-Grimoire/main/docs/`

## Read-first
- **implementation-status.md**, as-built truth (source of truth for what exists)

## Core design
- game-design-doc.md, core philosophy, tech stack, art direction, combat perspective
- art-asset-requirements.md, HD-2D art direction, resolutions, sprite/atlas specs
- phase1-sprite-prompts.md, Layer.ai prompt library (characters, enemies, items, UI)
- guild-hall-art-spec.md, Guild Hall background dimensions/safe-zones + 8 prestige-stage prompts
- stat-scaling-combat-formulas.md, combat math, stat formulas, hit/evasion/block
- talent-spec-sheets.md, all talents, level unlocks, XP curve
- combat-xp-curve.md, Grimoire combat XP curve + milestone bonuses
- combat-progression-reconcile.md, per-Grimoire combat XP routing, shared-talent retirement, Total Combat Level source, Combat Tab display (as-built)
- combat-balance-reconcile.md, bow active-shot multiplier model (crit 1.6, ability ring replaces crit, Armor Piercer additive, Long Shot 3.0, cap 2.5, DEX bug fix, zone-1 defense 10-18) (as-built)
- combat-balance-reconcile-REQUEST.md, the design ask (RESOLVED by combat-balance-reconcile.md; kept for history)
- combat-engagement-spec.md, zones/dungeons/raids engagement model

## Systems
- guild-system.md, guild rules, tax, voting, merchant _(voting + merchant reconciled to as-built)_
- guild-hall-ui-spec.md, guild hall / bank UI spec
- wayferers-exchange-and-grimoire-system.md, economy, market listings, Grimoire binding
- exchange-unlock-flow.md, Exchange unlock gating
- inventory-character-system.md, inventory + character sheet
- equipment-tier-design.md, CANONICAL two-axis model: quality (instance flag + badge, raised at the bench) plus tier (crafted item ladder Bronze->Void); supersedes the old "quality tier" tables
- material-economy.md, CANONICAL material economy: Delving + Smelting talents, ore->bar->component pipeline, leather renames, acquisition per material
- material-economy-REQUEST.md, the design ask (RESOLVED by material-economy.md; kept for history)
- assembly-materials-crafting-system.md, crafting + assembly (design; reconciled to the two-axis model)
- assembly-implementation-spec.md, STEP 8 assembly implementation spec (upgrade model, success rates, XP, tool tables)
- enemy-zone-tables.md / phase2-zone-tables.md, zones, enemies, drops, bosses
- daily-weekly-quest-system.md, settings-screen.md, onboarding-flow.md, while-you-were-away.md
- offline-combat-wywa.md, combat session summary on WYWA (Option A, summary only, no offline sim); running CombatSessionTally, persist-on-background, ShowCombatResult (as-built)
- offline-combat-wywa-REQUEST.md, the design ask (RESOLVED by offline-combat-wywa.md; kept for history)
- daily-weekly-quest-system-scaling.md, dynamic quest target/reward scaling by tier + talent level (addendum; as-built in QuestScaler)
- player-account-system.md, push-notification-triggers.md, monetization-scope.md, infrastructure-cost-planning.md
- royal-merchant-store-REQUEST.md, OPEN: reconcile monetization-scope.md + consumables-spec.md + the as-built GM auto-eat store into one categorized Royal Merchant store page, for Chat

## Phase 3 content
- dungeon-room-pools-brief.md, Mirefall Barrow + Warden's Folly (T2) room pools, bosses, puzzles, hazards
- dungeon-room-pools-t1-brief.md, Aldric's Warren + Crestfall Cove (T1) room pools, bosses, TidalSurge hazard (no puzzles)
- dungeon-room-pools-phase3-brief.md, Gravenspire + Ignarath's Maw room pools, bosses, puzzles, hazards
- dungeon-room-pools-t4t5-brief.md, T4/T5 dungeons (The Breach, Valdren's Keep, The Pale Vault, Firststone Sanctum): rooms, bosses, new hazards + puzzles (enemies now authored; dungeons pending build)
- phase4-enemy-content-brief.md, all T4/T5 EnemyData (24 standard/elite + 4 zone bosses) + the four ZoneData + new material/trophy ItemData. As-built via CreatePhase4Enemies + CreatePhase4Items.
- phase4-enemy-content-REQUEST.md, the design ask (RESOLVED by phase4-enemy-content-brief.md; kept for history)
- dungeon-room-pools-t4t5-REQUEST.md, the design ask (RESOLVED by dungeon-room-pools-t4t5-brief.md; kept for history)
- grimoire-talent-reference.xlsx, talent reference workbook (per-talent activities, tiers, unlocks)
- phase3-attunement-data-spec.md, Tanning tiered attunement, Smelting HeatGauge attunement, combat zone events, Delving node placement
- phase3-enemy-content-brief.md, all T3 EnemyData (HP, damage, weak points, drops, new mechanics)

## Subclasses / combat specs
- subclass-trees-warden.md, subclass-trees-arcanist.md, subclass-trees-vanguard.md
- runic-constellation-spec.md, summoner-spec.md, lifebinder-spec.md
- vanguard-combo-system.md, warfare-spec.md, slaying-talent-spec.md
- slaying-content-spec.md, Slaying "extra content" (as-built foundation): full Lv1-100 unlock ladder, Hunted Variants (passive), Finishing Blow, Faction Mastery kill counters + titles, Lv100 capstone, Slaying page on the Combat Tab. Slayer Hunts + Bounty Board are specced but deferred (next content pass).
- slaying-content-REQUEST.md, the design ask (RESOLVED by slaying-content-spec.md; kept for history)
- attunement-data-spec.md, phase2-attunement-data-spec.md

## Constraints
- deferred-systems-dlc-notes.md, what NOT to build yet (DLC / post-launch)

> Note: the top-level `CLAUDE.md` briefing's "locked design decisions" section has known-stale lines
> (Unity version, zone-unlock rule, Exchange fees, Enchanting→Inscription, Constellation layout).
> Trust `implementation-status.md` and the individual specs over that section until it's rewritten.
