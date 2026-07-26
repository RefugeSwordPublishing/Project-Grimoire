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
- player-account-system.md, push-notification-triggers.md, monetization-scope.md, infrastructure-cost-planning.md

## Phase 3 content
- dungeon-room-pools-phase3-brief.md, Gravenspire + Ignarath's Maw room pools, bosses, puzzles, hazards
- phase3-attunement-data-spec.md, Tanning tiered attunement, Smelting HeatGauge attunement, combat zone events, Delving node placement
- phase3-enemy-content-brief.md, all T3 EnemyData (HP, damage, weak points, drops, new mechanics)

## Subclasses / combat specs
- subclass-trees-warden.md, subclass-trees-arcanist.md, subclass-trees-vanguard.md
- runic-constellation-spec.md, summoner-spec.md, lifebinder-spec.md
- vanguard-combo-system.md, warfare-spec.md, slaying-talent-spec.md
- attunement-data-spec.md, phase2-attunement-data-spec.md

## Constraints
- deferred-systems-dlc-notes.md, what NOT to build yet (DLC / post-launch)

> Note: the top-level `CLAUDE.md` briefing's "locked design decisions" section has known-stale lines
> (Unity version, zone-unlock rule, Exchange fees, Enchanting→Inscription, Constellation layout).
> Trust `implementation-status.md` and the individual specs over that section until it's rewritten.
