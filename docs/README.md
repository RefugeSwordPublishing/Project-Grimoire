# Project Grimoire — Docs Index

**For Claude (Chat or Code): fetch files by the raw URLs below.** GitHub's folder pages
(`/tree/main/docs`) are JavaScript-rendered and usually fail to fetch — use these direct
`raw.githubusercontent.com` links instead, one file at a time.

**Read `implementation-status.md` FIRST.** It records what is actually built vs. design intent;
when a spec and the code conflict, it wins.

Raw base: `https://raw.githubusercontent.com/RefugeSwordPublishing/Project-Grimoire/main/docs/`

## Read-first
- **implementation-status.md** — as-built truth (source of truth for what exists)

## Core design
- game-design-doc.md — core philosophy, tech stack, art direction, combat perspective
- art-asset-requirements.md — HD-2D art direction, resolutions, sprite/atlas specs
- stat-scaling-combat-formulas.md — combat math, stat formulas, hit/evasion/block
- talent-spec-sheets.md — all talents, level unlocks, XP curve
- combat-xp-curve.md — Grimoire combat XP curve + milestone bonuses
- combat-engagement-spec.md — zones/dungeons/raids engagement model

## Systems
- guild-system.md — guild rules, tax, voting, merchant _(voting + merchant reconciled to as-built)_
- guild-hall-ui-spec.md — guild hall / bank UI spec
- wayferers-exchange-and-grimoire-system.md — economy, market listings, Grimoire binding
- exchange-unlock-flow.md — Exchange unlock gating
- inventory-character-system.md — inventory + character sheet
- assembly-materials-crafting-system.md — crafting, quality tiers, assembly
- enemy-zone-tables.md / phase2-zone-tables.md — zones, enemies, drops, bosses
- daily-weekly-quest-system.md, settings-screen.md, onboarding-flow.md, while-you-were-away.md
- player-account-system.md, push-notification-triggers.md, monetization-scope.md, infrastructure-cost-planning.md

## Subclasses / combat specs
- subclass-trees-warden.md, subclass-trees-arcanist.md, subclass-trees-vanguard.md
- runic-constellation-spec.md, summoner-spec.md, lifebinder-spec.md
- vanguard-combo-system.md, warfare-spec.md, slaying-talent-spec.md
- attunement-data-spec.md, phase2-attunement-data-spec.md

## Constraints
- deferred-systems-dlc-notes.md — what NOT to build yet (DLC / post-launch)

> Note: the top-level `CLAUDE.md` briefing's "locked design decisions" section has known-stale lines
> (Unity version, zone-unlock rule, Exchange fees, Enchanting→Inscription, Constellation layout).
> Trust `implementation-status.md` and the individual specs over that section until it's rewritten.
