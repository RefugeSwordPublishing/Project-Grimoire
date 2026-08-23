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
- ui-kit-art-brief.md, UI chrome/component system (panels, buttons, tabs, cards, bars, chips): style DNA + palette anchors, component inventory, prompt template, generation order (~21 Layer generations), Unity 9-slice assembly. Fills the UI-chrome gap the art spec leaves open. Generated in Layer.ai's web UI (no MCP connection); Claude handles Unity assembly.
- hub-hud-station-brief.md, Main Hub HUD: 4 station props (Quest Board, Upgrade Terminal, Slayer Hub, Notice Board) + 5 ambient props, PixelLab prompts (ui_hub_stations / ui_hub_ambient), portrait placement + parallax depth spec, badge/notification behavior, and the Claude-Code dependency list to wire the hub scene
- enemy-sprite-prompts-backfill.md, PixelLab base-sprite prompts + weak-point notes for the 45 enemies that had no prompt (Cinderpeak T3B, Veilborn/Shattered T4, Ashenwold/Elder T5, and 8 dungeon bosses). Loaded into the tracker's asset_prompts; anim frames derive from the approved base
- phase1-sprite-prompts.md, Layer.ai prompt library (characters, enemies, items, UI)
- background-art-prompts.md, painterly parallax BACKGROUND prompt library (FLUX/Gemini): per-layer prompts for all 10 zones (far/mid/near) + 10 dungeon interiors, feeding the built Build3DCombatScene parallax layers. ~40 images for full coverage; Tier 1/2 mid layers are the MVP
- guild-hall-art-spec.md, Guild Hall background dimensions/safe-zones + 8 prestige-stage prompts
- stat-scaling-combat-formulas.md, combat math, stat formulas, hit/evasion/block
- talent-spec-sheets.md, all talents, level unlocks, XP curve
- combat-xp-curve.md, Grimoire combat XP curve + milestone bonuses
- combat-progression-reconcile.md, per-Grimoire combat XP routing, shared-talent retirement, Total Combat Level source, Combat Tab display (as-built)
- combat-balance-reconcile.md, bow active-shot multiplier model (crit 1.6, ability ring replaces crit, Armor Piercer additive, Long Shot 3.0, cap 2.5, DEX bug fix, zone-1 defense 10-18) (as-built)
- combat-balance-reconcile-REQUEST.md, the design ask (RESOLVED by combat-balance-reconcile.md; kept for history)
- combat-engagement-spec.md, zones/dungeons/raids engagement model
- combat-screen-clarity-spec.md, combat UI redesign (Chat): three states (Hub/In-Zone/Elsewhere), Combat Hub hierarchy with locked-tile arithmetic, in-zone disclosure tiers, 11 element tooltips, 6-step coach marks + milestone marks, collapse defaults, retire the resume pill. Fixes f9ffe182 clarity half. NOTE: sections 3.3 + 7 (dungeon collapse) amended by combat-navigation-flow-spec.md
- combat-navigation-flow-spec.md, combat nav IA (Chat): delete the section menu (Combat nav opens the encounter list directly), zone cards with inline dungeon sub-rows (no standalone Dungeons list), Continue row, Raids placeholder card, Slayer off the encounter path, back-vs-Leave semantics, post-encounter landing, scroll restoration. Companion to the clarity spec; amends its 3.3/7

## Systems
- guild-system.md, guild rules, tax, voting, merchant _(voting + merchant reconciled to as-built)_
- guild-hall-ui-spec.md, guild hall / bank UI spec
- wayferers-exchange-and-grimoire-system.md, economy, market listings, Grimoire binding
- exchange-unlock-flow.md, Exchange unlock gating
- inventory-character-system.md, inventory + character sheet
- equipment-tier-design.md, CANONICAL two-axis model: quality (instance flag + badge, raised at the bench) plus tier (crafted item ladder Bronze->Void); supersedes the old "quality tier" tables
- material-economy.md, CANONICAL material economy: Delving + Smelting talents, ore->bar->component pipeline, leather renames, acquisition per material
- material-economy-REQUEST.md, the design ask (RESOLVED by material-economy.md; kept for history)
- upgrade-component-economy.md, CANONICAL (Chat): fixes bug #41. Runesmithing crafts the 4 Fittings + Runic Cog; Inscription crafts the 4 Binding Sigils; Artificing bench recipe uses Apparatus in place of a Fitting; Gleaning sigil/cog rares re-roled to shortcuts. 9 new recipes + 1 AssemblyManager edit. Producer + bench tables in sections 8-9
- upgrade-component-economy-REQUEST.md, the design ask (RESOLVED by upgrade-component-economy.md; kept for history)
- tanning-hide-alignment.md, leather-chain drop fix (as-built): pelts come from Trapping, not kills; added Wolf Trap + re-leveled Direwolf, stripped stray/dead pelt drops from 10 enemies. Fixes bug 1c8db6e3

- assembly-materials-crafting-system.md, crafting + assembly (design; reconciled to the two-axis model)
- assembly-implementation-spec.md, STEP 8 assembly implementation spec (upgrade model, success rates, XP, tool tables)
- enemy-zone-tables.md / phase2-zone-tables.md, zones, enemies, drops, bosses
- daily-weekly-quest-system.md, settings-screen.md, onboarding-flow.md, while-you-were-away.md
- offline-combat-wywa.md, combat session summary on WYWA (Option A, summary only, no offline sim); running CombatSessionTally, persist-on-background, ShowCombatResult (as-built)
- offline-combat-wywa-REQUEST.md, the design ask (RESOLVED by offline-combat-wywa.md; kept for history)
- daily-weekly-quest-system-scaling.md, dynamic quest target/reward scaling by tier + talent level (addendum; as-built in QuestScaler)
- player-account-system.md, push-notification-triggers.md, monetization-scope.md, infrastructure-cost-planning.md
- royal-merchant-store-spec.md, full categorized Royal Merchant store (Chat v1.0): 5 tabs (Consumables/Inventory/Quests & Tasks/Cosmetics/Grimoires & DLC), GM-live rows + stubbed IAP, RoyalMerchantManager + purchase_merchant_item RPC + merchant_purchases column. Stays a top-level nav page (not an Exchange tab).
- royal-merchant-store-REQUEST.md, the design ask (RESOLVED by royal-merchant-store-spec.md; kept for history)
- multiplayer-chat-spec.md, DESIGN (not built): friend system + guild/lobby/DM/general chat. Locked decisions (realtime transport, general chat deferred, overlay-pill UI), new tables (chat_messages/read_state/friendships/blocks/presence) + per-channel RLS, the realtime de-risk task, moderation, and P0-P4 phasing. Reuses guild/lobby RLS + FCM.

## Phase 3 content
- dungeon-room-pools-brief.md, Mirefall Barrow + Warden's Folly (T2) room pools, bosses, puzzles, hazards
- dungeon-room-pools-t1-brief.md, Aldric's Warren + Crestfall Cove (T1) room pools, bosses, TidalSurge hazard (no puzzles)
- dungeon-room-pools-phase3-brief.md, Gravenspire + Ignarath's Maw room pools, bosses, puzzles, hazards
- dungeon-room-pools-t4t5-brief.md, T4/T5 dungeons (The Breach, Valdren's Keep, The Pale Vault, Firststone Sanctum): rooms, bosses, new hazards + puzzles. As-built via CreatePhase4Dungeons + VoidRiftSeal/RuneLock puzzle minigames in DungeonPuzzleUI.
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
