# Project Grimoire — Claude Code Briefing

## What this project is
A semi-idle RPG mobile game with a planned Steam release.
Built in Unity (2022.3 LTS or Unity 6) with C#.
Supabase backend, Firebase Cloud Messaging, Unity IAP, GameAnalytics.
GitHub: https://github.com/RefugeSwordPublishing/Project-Grimoire

## Design docs location
All design documentation lives in /docs — read these before implementing anything:

| File | Contents |
|------|----------|
| docs/design-doc.md | Core philosophy, tech stack, art direction, combat perspective |
| docs/talent-spec-sheets.md | All 20+ talents with level unlocks, XP curve, cross-dependencies |
| docs/assembly-materials-crafting-system.md | Crafting rules, quality tiers, weapon/armor assembly |
| docs/enemy-zone-tables.md | 10 zones, enemies, drop tables, bosses, dungeons, raids |
| docs/subclass-trees-warden.md | Sharpshot and Lone Wanderer full trees |
| docs/subclass-trees-arcanist.md | Runeweaver, Summoner, Lifebinder full trees |
| docs/subclass-trees-vanguard.md | Warlord and Shadowblade full trees |
| docs/stat-scaling-combat-formulas.md | All combat math, stat formulas, hit/evasion/block system |
| docs/wayferers-exchange-and-grimoire-system.md | Economy, currency, market listings, Grimoire binding |
| docs/deferred-systems-dlc-notes.md | What NOT to build yet — DLC content and constraints |

## Tech stack
- Engine: Unity (2022.3 LTS or Unity 6)
- Language: C#
- Backend: Supabase (REST API + Edge Functions for idle calculations)
- Notifications: Firebase Cloud Messaging
- Monetization: Unity IAP (App Store + Google Play + Steam)
- Analytics: GameAnalytics
- Art: Pixel art style — Sprite AI generated assets via MCP connector (connected directly to Claude Code)
- Version control: GitHub

## Core design decisions (locked)
- **Semi-idle loop** — tasks run idle, active play triggers Attunement Surge (1.5x–3x XP/drops)
- **Bowstring mechanic** — Warden combat: over-the-shoulder view, press/drag to aim, accuracy-based crits, weak points glow subtly per enemy type, idle = mid-draw baseline damage
- **Runic Constellation** — Arcanist combat: draw lines between rune nodes on screen, combination determines spell, subclass alters rune behavior not layout
- **Grimoire system** — class switching via equipped Grimoire, ~24hr cooldown, any of 7 base game Grimoires free at start, additional 500 GM or premium
- **Wayfarer's Exchange** — unified market: auction listings, store listings, buy orders, 2–3% listing fees, Silver and Gold Marks only
- **Currency** — Silver Marks (SM) and Gold Marks (GM) only. 1,000 SM = 1 GM
- **Quality tiers** — Crude / Rough / Refined / Pristine / Masterwork / Legendary (DLC only)
- **Assembly** — 2 components for weapons/tools, 3 for armor, rare material added at Workbench. All components consumed on fail. Fail cascade: Legendary→Epic→Rare→Uncommon→Common floor
- **Zone unlock** — highest single combat Talent across ALL equipped Grimoires
- **Combat resolution** — Hit Roll → Evasion → Block → Damage → LCK Wild Card → Debuff
- **Stat gain** — hybrid: Talent milestone passives + equipment bonuses + Enchanting
- **Tools** — permanent, no degradation. Upgrade motivation only
- **Zone bosses** — active play only, random spawn chance, 10 min despawn timer
- **Dungeons** — 2 active per month, rotate on 1st, not idle-able
- **Raids** — 1 active per quarter, 25–45 min, 3-phase, active only, Masterwork material source

## Phase 1 scope (build this first)
- Warden class with Sharpshot subclass
- Bowstring combat mechanic (over-the-shoulder, accuracy-based)
- Core idle loop with Grimoire Queue UI
- Talents: Foraging, Trapping, Dredging, Cookery, Alchemy, Marksmanship, Slaying
- Zones: Grimwood Fringe (1A) and Saltmarsh Shore (1B)
- Basic Wayfarer's Exchange (store listings + buy orders)
- Supabase backend — player data, idle calculations server-side
- "While You Were Away" session return screen
- Silver and Gold Mark currency system

## Art generation workflow
Sprite AI is connected via MCP — use it directly for Phase 1 sprite generation rather than asking Dustin to generate art manually in browser.
- Prompt library lives at docs/phase1-sprite-prompts.md — use these prompts as-is or adapt them
- Generate the Warden base body first, then use it as a style reference for all subsequent generations (enemies, items) to keep visual consistency
- Standard style suffix to append to every prompt: "limited palette, dark pixel outline, Kingdom Two Crowns pixel art style, transparent background"
- Save generated sprites to Assets/Sprites/ in the appropriate subfolder (Characters/, Enemies/, Items/, Environments/, UI/)
- Layered equipment approach: generate base character body separate from equipment (bow, quiver, armor, cloak) as individual layers so gear can be swapped in Unity without regenerating the whole character
- Follow the generation order in docs/phase1-sprite-prompts.md: Warden base + animations → bow/quiver layers (test layering works) → 13 Tier 1 enemies → item icons → environments → UI elements → onboarding panels

## Architecture guidelines
- Keep idle calculations server-side via Supabase Edge Functions — prevents cheating
- All Talent data should be data-driven via ScriptableObjects — never hardcode level unlocks
- Separate managers: GameManager, TalentManager, CombatManager, MarketManager, GrimoireManager
- Design for mobile first — touch input, battery efficiency, background processing
- Follow Unity C# naming conventions — PascalCase classes, camelCase private fields, _prefix for serialized fields
- Faction enemy tags ([Outlaw], [Beast], [Undead], [Arcane], [Void], [Nature]) must be on all enemies from day one — DLC faction bonuses will read these tags
- CHA and WIL stat formula slots must remain open for DLC Bard/Minstrel subclass
- Zone system must support faction ownership layers even if unused in base game

## Do NOT implement yet
Everything in docs/deferred-systems-dlc-notes.md:
- Faction system and faction wars
- Beastbond (Warden DLC), Warlock (Arcanist DLC), Kensei (Vanguard DLC)
- Bard/Minstrel subclass
- Lifebinder multiplayer healing features
- Hard mode dungeons (New Game Plus)
- Legendary quality tier items
- Mythic quality tier
- PvP / Dueling system
- Guild Hall zone conquest
