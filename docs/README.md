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
- upgrade-component-economy.md, CANONICAL v3.0 (Chat, thematic recipe pass, IMPLEMENTED): upgrade materials now match the item's material class. Metal Fitting removed from wood/leather/cloth. Tailoring splits on armorType: Leather (hide + Sinew Cord + Amber), Vestments (Spun Thread + botanical + Binding Sigil). Two new component families: Sinew Cord (Tanning, 4 grades) + Spun Thread (Tailoring, 4 grades), 8 new items total. Resolver keys on (assemblerTalent, armorType); Generic fallback now logs a warning. v2.0 supply decisions (Fittings from Runesmithing, Sigils as Gleaning drops) carry forward unchanged
- upgrade-component-economy-REQUEST.md, the design ask (RESOLVED by upgrade-component-economy.md; kept for history)
- upgrade-recipe-thematic-REQUEST.md, the design ask (RESOLVED by upgrade-component-economy.md v3.0; kept for history)
- tier-quality-stat-curve.md, CANONICAL v1.0 (Chat, IMPLEMENTED): fixes bug #54. Tier now also raises a
  piece's STAT bonus, not just the physical band. Rule: one material tier = two quality steps of stat.
  Four flat tables in EquipmentStats: TierWeaponPrimary/Secondary {7,15,24,34}/{5,11,18,26} and the gentler
  TierArmorPrimary/Secondary {4,9,14,20}/{3,7,11,16} (armour split avoids compounding across 5 slots).
  OPEN follow-ups Chat flagged (not applied): TierWeaponBonus accelerates past the quality span at T5
  (section 4.2 suggests {20,42,68,98}); and Chat wants the armour-rating quality table to verify the
  armour tier bonuses.
- hp-progression-spec.md, CANONICAL v1.0 (Chat, DESIGN not built): fixes the squishy-scaling gap. Stage 1 adds a baseline HP term to GetMaxHP driven by Total Combat Level (raw = 50 + TCL*2.5 + totalVIT*6) and NORMALIZES VIT to a flat 6 HP/point (kills the 4-vs-7 double-count). Stage 2 makes HPPoolMultiplier a per-Grimoire table (0.90 Runeweaver/Summoner .. 1.25 Warlord, 1.40 Bulwark, 1.60 Lifebinder). Stage 3 grants VIT milestones to ALL three paths (Warden/Arcanist had none). Stage 4 (adjacent, flagged): CAP mitigation at 75% (finalDamage floor), revive 10%->25% + 2s immunity, rescale healing consumables to % of max HP. Numbers pass keeps raw-hits-to-die in a 17-34 band across T1/T3/T5. Open: needs the armour-rating quality table to verify mitigation; confirm the evasion double-roll; Summoner effectiveHP decision.
- hp-progression-REQUEST.md, the design ask (RESOLVED by hp-progression-spec.md v1.0; kept for history)
- combat-menu-hub-spec.md, CANONICAL v1.0 (Chat, IMPLEMENTING): reshapes the combat menu from a scrolling list into a hub. Stage 1 banner + tier-grouped two-column zone TILE grid + Continue strip + Raids. Stage 2 a separate ZoneDetailPanel surface (not in-place expansion) with enemies as grouped chips (Standard/Elite/Boss), Enter Zone + Dungeon buttons at the bottom. Stage 3 DungeonInfoPopup (name/tier/rooms/boss/first-clear + Enter Lobby/Cancel). Stage 4 dungeon lobby reusing PreBossLobbyUI/BossLobbyManager via a LobbyContext generalization, with tappable empty-slot invites. Nine new baked templates; amends combat-navigation-flow-spec.md section 5.
- combat-menu-hub-REQUEST.md, the design ask (RESOLVED by combat-menu-hub-spec.md v1.0; kept for history)
- tier-quality-stat-curve-REQUEST.md, the design ask (RESOLVED by tier-quality-stat-curve.md v1.0; kept for history)
- tanning-hide-alignment.md, leather-chain drop fix (as-built): pelts come from Trapping, not kills; added Wolf Trap + re-leveled Direwolf, stripped stray/dead pelt drops from 10 enemies. Fixes bug 1c8db6e3

- assembly-materials-crafting-system.md, crafting + assembly (design; reconciled to the two-axis model)
- assembly-implementation-spec.md, STEP 8 assembly implementation spec (upgrade model, success rates, XP, tool tables)
- enemy-zone-tables.md / phase2-zone-tables.md, zones, enemies, drops, bosses
- daily-weekly-quest-system.md, settings-screen.md, onboarding-flow.md, while-you-were-away.md
- offline-combat-wywa.md, combat session summary on WYWA (Option A, summary only, no offline sim); running CombatSessionTally, persist-on-background, ShowCombatResult (as-built)
- offline-combat-wywa-REQUEST.md, the design ask (RESOLVED by offline-combat-wywa.md; kept for history)
- daily-weekly-quest-system-scaling.md, dynamic quest target/reward scaling by tier + talent level (addendum; as-built in QuestScaler)
- player-account-system.md, push-notification-triggers.md, monetization-scope.md, infrastructure-cost-planning.md
- traveling-merchant-REQUEST.md, 0.1.4 ECONOMY PIVOT (design ask, awaiting Chat): RETIRE the recycle-to-Essence system (shipped in 0.1.3c but UI never baked, so testers never saw it) in favour of a Traveling Merchant that buys scrap for SM at a low fixed FLOOR price (below Exchange value, seeds the economy) + a GM->SM only "make change" converter at checkout (GM is premium/IAP; no SM->GM to prevent premium-farming). Retire Reclaimed Essence; migrate the 4 Reclamation-tab items to SM/GM (Auto-Recycle -> Auto-Sell). Uses the existing dead `ItemData.baseSellValue`. Supersedes material-recycling-spec.md.
- material-recycling-spec.md, SUPERSEDED by traveling-merchant-REQUEST.md (pivot, 0.1.4). Was CANONICAL v1.0 (Chat, DESIGN not built): recycling outputs Reclaimed Essence (a bound, non-tradable per-player counter, NOT SM/GM) plus Talent XP for CRAFTED items only (gathered = essence only). ZERO material return + zero currency conversion by design (no perpetual motion). Stage 1 inventory bulk recycle action + essence value table (by quality x tier; Legendary blocked, Masterwork/Pristine guarded). Stage 2 Royal Merchant 'Reclamation' category (convenience/insurance sinks only, never power; flagship Reclamation Charge protects upgrade rares). Stage 3 XP return with a 15%/talent/day cap (anti craft-then-scrap exploit). Stage 4 auto-recycle setting + WYWA report. Flags: rename Sell->List on Exchange, retire Discard, baseSellValue is a dead field, recycling ungated from Lv1. 2 baked templates, 1 player column + settings columns.
- material-recycling-REQUEST.md, the design ask (RESOLVED by material-recycling-spec.md v1.0; kept for history)
- royal-merchant-store-spec.md, full categorized Royal Merchant store (Chat v1.0): 5 tabs (Consumables/Inventory/Quests & Tasks/Cosmetics/Grimoires & DLC), GM-live rows + stubbed IAP, RoyalMerchantManager + purchase_merchant_item RPC + merchant_purchases column. Stays a top-level nav page (not an Exchange tab).
- royal-merchant-store-REQUEST.md, the design ask (RESOLVED by royal-merchant-store-spec.md; kept for history)
- chat-dock-panel-spec.md, CANONICAL v1.0 (Chat, DESIGN not built): ONE docked multi-channel chat panel above the idle bar, minimize-to-one-line / expand-upward, a merged feed with World/Guild/Private/Lobby filter chips + per-group unread, inline PMs with a reply pill (compose from friends list), a full-server World channel (general RLS + rate limit), and @username pings. 4 stages, 4 new baked templates (ChatDockRoot/ChatGroupChip/ChatFeedRow/ChatMentionToast), main code change is ChatManager holding multiple channels behind one fetch_chat_feed. AMENDS multiplayer-chat-spec.md (UI, realtime->polling, general un-deferred).
- chat-dock-panel-REQUEST.md, the design ask (RESOLVED by chat-dock-panel-spec.md v1.0; kept for history)
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
- grimoire-book-spec.md, CANONICAL v1.0 (Chat, DESIGN not built): resolves bug #64. Rebuilds the Grimoire inspection view as a single-page book (frame + parchment + bookmark rail + footer), 3 fixed pages (Frontispiece / The Binding / The Casting) plus one ability page per depth group plus The Unwritten (unlock schedule). Page 3 surfaces the previously-invisible speed-tier + counter-pair tables (the real bug). Every ability entry gets an InputDiagram (rune path / combo glyphs / draw arc). 12 baked prefabs (populate-only runtime). PREREQUISITE (12.1): build a WardenTechniqueLibrary from subclass-trees-warden.md so Warden isn't one page.
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
