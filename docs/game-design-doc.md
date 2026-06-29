# ⚔️ Project Grimoire — Semi-Idle RPG Game Design Document
### Version 0.2 — Architecture & Systems Overview

---

## 🎯 Core Design Philosophy

**Semi-Idle Loop:** Tasks run automatically when offline (idle), but active play triggers **Attunement Bonuses** — multipliers on XP, resource yield, or rare drop rates for players who engage directly. This rewards both playstyles without punishing either.

**Attunement Bonus:** The working name for the active-play multiplier. When a player manually triggers or interacts with a task (tapping a node, timing a strike, solving a mini-challenge), they receive an **Attunement Surge** that boosts XP gain by 1.5x–3x for that action window.

---

## 📊 Core Character Stats (D&D-Inspired)

| Stat | Abbreviation | Role in Game |
|------|-------------|--------------|
| **Strength** | STR | Melee damage, carry weight, mining/chopping efficiency |
| **Dexterity** | DEX | Attack speed, dodge chance, ranged accuracy, lockpicking |
| **Vitality** | VIT | Max HP, poison/disease resistance, stamina pool |
| **Intelligence** | INT | Spell power, enchanting potency, alchemy effectiveness |
| **Willpower** | WIL | Mana pool, idle task persistence, resistance to debuffs |
| **Luck** | LCK | Rare drop rate, critical hits, treasure find chance |
| **Charisma** | CHA | (Multiplayer/Economy) Trade prices, NPC quest rewards, faction reputation |

**Stat Growth:** Stats grow both via direct training AND as secondary gains from Talent use. E.g., drawing a bow repeatedly passively grows DEX; brewing potions grows INT.

---

## 🧙 Class Archetypes & Subclasses

> **Monetization Note:** Base classes are free. Subclasses (except one starter subclass per path) are **premium unlocks**. Subclasses add value far beyond combat style — they open exclusive Talent branches, economy access, and multiplayer roles.

### 🏹 The Warden Path *(Archer/Hunter)* — **PHASE 1 LAUNCH CLASS**
Primary stats: DEX, LCK

**Base Warden:** Ranged combat, basic trapping, animal tracking. Access to the Bowstring active combat mechanic.

| Subclass | Unlock | Focus | Non-Combat Value |
|----------|--------|-------|-----------------|
| **Sharpshot** | Free (starter) | Precision, long range, trap craft | Crafted traps run idle; Attunement crits give bonus XP |
| **Beastbond** | Premium 💰 | Taming, pets, creature mastery | Tamed familiars assist Foraging, Trapping, Cultivation; Familiar Exchange access |
| **Lone Wanderer** | Premium 💰 | Solo survivability, stealth, scouting | Bonus XP/drops solo; reveals hidden resource nodes; access to Gleaning deep tree |

### 🔮 The Arcanist Path *(Magic/Sorcery)* — Phase 2
Primary stats: INT, WIL

**Base Arcanist:** Elemental spellcasting, basic enchanting, reagent sensitivity (better Foraging quality baseline).

| Subclass | Unlock | Focus | Non-Combat Value |
|----------|--------|-------|-----------------|
| **Runeweaver** | Free (starter) | Elemental magic, AoE | Unlocks Runeforging on weapons/armor; Runelore deep tree |
| **Warlock** | Premium 💰 | Dark pacts, curses, soul harvest | Soulbinding idle loop; binds slain enemies for passive soul resources |
| **Summoner** | Premium 💰 | Minion control, familiars | Summons assist idle tasks (imp mines, sprite forages); stacks with economy |
| **Lifebinder** | Premium 💰 *(Multiplayer unlock)* | Healing, auras, group support | Party idle rate buffs; enables raid healer role; Aura Inscription branch |

### ⚔️ The Vanguard Path *(Melee Fighter)* — Phase 2
Primary stats: STR, VIT

**Base Vanguard:** Heavy melee, defensive stances, resource carry bonus.

| Subclass | Unlock | Focus | Non-Combat Value |
|----------|--------|-------|-----------------|
| **Warlord** | Free (starter) | Commanding, AoE, tanking | Zone conquest for guild resource priority; Guild Hall bonuses |
| **Shadowblade** | Premium 💰 | Rogue, poison, ambush | Shadowcraft deep tree; steal resources from hostile zones; Gleaning bonus |
| **Kensei** | Premium 💰 | Samurai discipline, precision | Focus mechanic — idle streaks build up burst; Wardancing ritual weapons |

---

## 🛠️ Talents System

> Talents are grouped into **Gathering**, **Processing**, **Combat**, and **Arcane** trees. Talents heavily influence combat — your proficiency in Cookery affects how long you last in a dungeon; Alchemy determines your potion belt; Tanning/Runesmithing determine the gear you can equip. Combat and Talent progression are deeply interwoven.

---

### 🌿 Gathering Talents

| Talent Name | Description | Primary Stat | Yields |
|-------------|-------------|--------------|--------|
| **Foraging** | Collect herbs, fungi, berries, roots in the wild | DEX, LCK | Reagents, food ingredients, rare botanicals |
| **Felling** | Chop trees; different biomes yield different wood types | STR | Timber, bark, sap, nesting materials |
| **Delving** | Mine ores, gems, fossils underground | STR, VIT | Ores, gems, fossils, rare earth minerals |
| **Trapping** | Set snares and cages for animals and creatures | DEX, INT | Pelts, creature parts, live animals (Beastbond) |
| **Dredging** | Fish, net, and dive in water zones | DEX, LCK | Fish, pearls, sunken items, aquatic reagents |
| **Gleaning** | Scavenge battlefields, ruins, dungeons for loot | LCK | Salvage, broken gear, rare finds, old coins |
| **Cultivation** | Farm crops, grow reagent plants, tend orchards | WIL | Crops, fiber, paper plants, rare herbs, alchemical plants |
| **Tracking** | Read terrain to locate rare creatures and hidden nodes | DEX, INT | Reveals rare spawn locations; feeds Trapping and Beastmastery |

---

### ⚙️ Processing Talents

| Talent Name | Description | Primary Stat | Requires |
|-------------|-------------|--------------|----------|
| **Tanning** | Process hides into leather goods | DEX, INT | Trapping output |
| **Smelting** | Refine raw ores into metal bars | STR, INT | Delving output |
| **Timber Shaping** | Mill and shape logs into planks, beams, components | STR, DEX | Felling output |
| **Runesmithing** | Forge weapons and armor from refined materials | STR, INT | Smelting + Timber Shaping output |
| **Arcane Weaving** | Craft magical items, staves, wands, foci | INT, WIL | Foraging + Smelting/Tanning output |
| **Alchemy** | Brew potions, poisons, and elixirs | INT, LCK | Foraging + Cultivation output |
| **Cookery** | Prepare food for stat buffs, HP recovery, and dungeon provisioning | VIT, INT | Cultivation + Dredging + Trapping output |
| **Tailoring** | Craft cloth armor, cloaks, bags, quivers | DEX | Cultivation (fiber) + Tanning |
| **Artificing** | Build mechanical devices, traps, contraptions | INT, DEX | Smelting + Timber Shaping + Gleaning |
| **Inscription** | Create scrolls, spellbooks, maps, contracts, diplomacy texts | INT, WIL | Cultivation (paper plants) + Foraging (inks) |

> **Cookery note:** Cookery is its own full Processing Talent, not part of Cultivation. Cultivation grows the ingredients; Cookery transforms them. A high Cookery level is essential for dungeon/raid survivability — prepared meals grant timed stat buffs that potions cannot replicate.

---

### ⚔️ Combat Talents

> Combat Talents are where Talent investment visibly shapes your combat identity. Your gear (from Processing Talents), your consumables (Alchemy + Cookery), and your subclass all feed into how these play out.

| Talent Name | Description | Primary Stat | Notes |
|-------------|-------------|--------------|-------|
| **Marksmanship** | Ranged combat proficiency — accuracy, draw speed, crit chance | DEX, LCK | Warden primary; governs Bowstring mechanic depth |
| **Slaying** | General monster combat for XP and drops | STR or DEX or INT | Scales with class path; idle auto-combat available |
| **Beastmastery** | Tame, train, and command creatures | CHA, DEX | Beastbond subclass unlocks advanced trees; Tracking feeds this |
| **Wardancing** | Ritual combat forms that grant combat buffs | STR, DEX, WIL | Kensei focus mechanic; requires Runesmithing (ritual weapons) |
| **Shadowcraft** | Stealth, ambush, poison application | DEX, LCK | Shadowblade exclusive deep tree; Alchemy feeds poison branch |
| **Dueling** | PvP and arena combat | All combat stats | Phase 4 unlock; competitive ranking system |
| **Vanguarding** | Heavy defense, shield wall, aggro control | STR, VIT | Warlord primary; key tank role in multiplayer dungeons/raids |

---

### 🔮 Arcane Talents

| Talent Name | Description | Primary Stat | Notes |
|-------------|-------------|--------------|-------|
| **Spellcasting** | Direct offensive/defensive magic | INT, WIL | Arcanist primary; limited access for other classes |
| **Enchanting** | Imbue gear with stat bonuses | INT, LCK | Requires Inscription + Runesmithing output |
| **Soulbinding** | Bind spirits, harvest souls from defeated enemies | WIL, LCK | Warlock exclusive; feeds passive soul resource idle loop |
| **Divination** | Predict resource node locations, reveal hidden drops | INT, LCK | Passive bonus to Foraging, Gleaning, Dredging |
| **Runelore** | Study and decode ancient runes for passive bonuses | INT | Unlocks Runeweaver depth; Inscription feeds this |

---

## 🔗 Talent Cross-Dependency Map

```
GATHERING ──────────────────────────────────────────────────
Foraging ──────┬──► Alchemy
               ├──► Cookery (herbs/ingredients)
               └──► Inscription (inks)

Felling ───────┬──► Timber Shaping
               └──► Artificing (components)

Delving ───────┬──► Smelting
               └──► Runelore (fossil study)

Trapping ──────┬──► Tanning
               ├──► Cookery (meat)
               └──► Beastmastery (live captures)

Dredging ──────┬──► Cookery (fish)
               ├──► Alchemy (aquatic reagents)
               └──► Arcane Weaving (pearls/scales)

Cultivation ───┬──► Cookery (crops, fruit, grain)
               ├──► Alchemy (grown reagents)
               ├──► Inscription (paper plants)
               └──► Tailoring (fiber crops)

Gleaning ──────┬──► Smelting (salvage metal)
               ├──► Artificing (parts)
               └──► Inscription (old texts → Runelore)

Tracking ──────┬──► Trapping (node location)
               ├──► Beastmastery (creature intel)
               └──► Gleaning (battlefield locations)

PROCESSING ─────────────────────────────────────────────────
Smelting ──────┬──► Runesmithing
               ├──► Artificing
               └──► Enchanting (metal foci)

Timber Shaping ┬──► Runesmithing (hafts/handles)
               └──► Artificing (frames)

Tanning ───────┬──► Tailoring
               └──► Arcane Weaving (leather components)

Runesmithing ──┬──► Enchanting (base gear)
               └──► Wardancing (ritual weapons)

Arcane Weaving ┬──► Spellcasting (foci required)
               └──► Soulbinding (ritual components)

Alchemy ───────┬──► Slaying/Marksmanship (combat potions)
               ├──► Beastmastery (taming lures)
               └──► Shadowcraft (poisons)

Cookery ───────┬──► Slaying (dungeon provisions)
               ├──► Marksmanship (focus meals → crit bonus)
               └──► Vanguarding (endurance meals → HP regen)

Inscription ───┬──► Enchanting (scrolls)
               ├──► Divination (maps/charts)
               └──► Runelore (texts)

ARCANE ──────────────────────────────────────────────────────
Runelore ──────► Runeweaving ──► Runesmithing (bonus tier)
Divination ────► Foraging/Dredging/Gleaning (node reveal)
Enchanting ────► All gear slots (stat bonuses)
Soulbinding ───► Warlock idle loop (soul resource generation)

COMBAT ──────────────────────────────────────────────────────
Marksmanship ──► DEX growth ──► Trapping/Dredging efficiency
Beastmastery ──► Familiar slots ──► Idle task assistance
Slaying ───────► LCK/STR growth ──► Better Gleaning yields
Vanguarding ───► STR/VIT growth ──► Delving efficiency boost
```

---

## 🏹 Active Combat: The Bowstring Mechanic (Warden — Phase 1)

The Warden's combat is the flagship of the active play system and sets the tone for how other class mechanics will be designed later.

### How It Works
- **Enemies spawn** in your current zone as you traverse or idle
- When combat triggers, a **Bowstring UI** appears — a circular arc around your character
- **Draw:** Press and hold your thumb anywhere on screen; the string pulls back with visual/haptic tension feedback
- **Aim:** The direction your thumb draws back determines shot angle — pull left to aim right, pull up-left to aim up-right (mirrored slingshot logic, intuitive after 30 seconds)
- **Release:** Lift thumb to fire; a trajectory arc shows briefly before release for skill expression
- **Power:** Hold duration determines draw power — affects damage and range
- **Idle fallback:** When not actively playing, the Warden auto-fires at base accuracy with no Attunement bonus

### Attunement Bonuses in Combat
| Action | Bonus |
|--------|-------|
| **Critical Hit** (precise aim on highlighted zone) | +150% XP for that kill, rare drop roll |
| **Headshot** (small target zone, active only) | Instant kill on normal enemies; stagger on elites |
| **Rapid Fire** (3 shots in quick succession) | Marksmanship XP burst |
| **Trick Shot** (bank off terrain, Sharpshot subclass) | Bonus loot from enemy |

### Combat Talent Feed-Through
- **Alchemy** → Poison-tipped arrows, fire arrows, frost bolts
- **Tailoring** → Quiver upgrades (more arrow slots, draw speed bonus)
- **Runesmithing** → Runed bows (stat bonuses, elemental damage)
- **Cookery** → Pre-combat meals (focus meal = +crit chance for X minutes)
- **Beastmastery** → Familiar assists during combat (Beastbond subclass)
- **Tracking** → Enemy weak points revealed before combat begins

---

## 🔄 The Semi-Idle Loop Explained

### Idle Mode (Offline / Background)
- Tasks assigned to a **Grimoire Queue** run continuously
- Base XP and resource rates apply
- Returns calculated on session return ("While You Were Away" screen)

### Active Mode (Attunement System)
| Talent | Active Interaction | Attunement Bonus |
|--------|-------------------|-----------------|
| Felling | Tap at the right rhythm (bark crack visual cue) | +50% timber, rare wood chance |
| Delving | Tap glowing ore veins before they fade | +75% XP, gem drop chance up |
| Marksmanship / Slaying | Bowstring mechanic, ability rotations | +100% XP, rare drop rate, crit bonuses |
| Alchemy | Stir timing mini-game | +1 extra potion per batch |
| Foraging | Choose which plant to pick when multiples appear | Better reagent quality tier |
| Dredging | Cast timing / line tension management | Bigger/rarer fish |
| Cookery | Recipe timing (heat management mini-game) | Extra portion, higher quality buff meal |

### Stamina & Willpower
- **Stamina Pool** (VIT): limits how long active bursts can sustain Attunement Surges
- **Willpower** (WIL): governs idle task persistence — higher WIL = queue runs longer before efficiency decay

---

## 🌍 Economy & World Systems (Roadmap)

| System | Description | Talent Dependencies |
|--------|-------------|-------------------|
| **Grand Exchange** | Unified player-driven market for resources, crafted goods, AND familiars/creatures | CHA affects margins; Beastmastery unlocks creature listings |
| **Guild Halls** | Shared resource pools, group tasks, raid staging | Warlord unlocks zone conquest |
| **Faction Reputation** | NPCs offer quests, unlock zones, special recipes, exclusive subclass gear | CHA, Inscription (diplomacy scrolls); needs full design pass |
| **Skirmish Board** | Daily PvE challenges — timed runs, bounties, zone events | All combat Talents; solo and group variants |

> **Black Market removed.** Shadowblade's economy value now lives in the Gleaning deep tree (battlefield scavenging) and hostile zone resource theft, which feeds into the Grand Exchange as rare/untraceable goods — no separate system needed.

> **Faction Reputation** is noted as a high-value system but needs a dedicated design pass to determine: how factions intersect with subclasses, whether faction standing affects multiplayer access, and how Inscription (diplomacy) feeds into standing gains.

---

## 🤝 Multiplayer Systems (Phase 4+)

Combat needs to feel like a **team effort**, not solo combat in proximity. Design pillars:

- **Dungeons:** 3–5 player instanced runs. Roles matter — tank (Vanguard/Warlord), healer (Lifebinder), DPS (all paths). Cookery provisions are shared from a party larder. Alchemy potions are personal.
- **Raids:** 10+ player events. Scheduled or world-triggered. Guild Halls serve as staging. Warlord zone conquest unlocks raid-tier resource zones.
- **Daily Skirmishes:** Solo or duo timed combat challenges on the Skirmish Board. Rewards rare materials and faction standing. Accessible at low-mid progression.
- **Team Synergies:** Class combos should feel meaningful — Beastbond familiars can scout ahead; Shadowblade can disable enemy patrols; Lifebinder auras buff idle task rates for the full party between pulls.

---

## 📱 Mobile-First UX Considerations

- **Grimoire Queue UI:** Drag-and-drop task prioritization
- **Attunement Alerts:** Push notifications on rare events (rare node, boss spawn, discovery)
- **One-Thumb Navigation:** Core loop works without precision; Attunement bonuses optional but rewarding
- **Session Summary:** "While You Were Away" scroll on app open
- **Steam Crossplay:** Shared progress; Steam gets enhanced UI + mouse/keyboard Attunement mechanics (click timing, precision aiming)

---

## 🗺️ Development Phase Roadmap

| Phase | Scope |
|-------|-------|
| **Phase 1** | Warden class + Sharpshot subclass, Bowstring combat mechanic, core idle loop, Foraging + Trapping + Dredging + Cookery + Alchemy Talents |
| **Phase 2** | All Gathering/Processing Talents, Arcanist + Vanguard paths, Grand Exchange, premium subclass unlocks |
| **Phase 3** | Arcane Talents, Faction Reputation system, Beastbond + Warlock + Kensei subclasses |
| **Phase 4** | Multiplayer, Dungeons, Raids, Daily Skirmishes, Guild Halls, Lifebinder subclass |
| **Phase 5** | Steam release, crossplay, enhanced PC UI, keyboard/mouse Attunement mechanics |

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
- **Grand Exchange** (not "Auction House") *(Note: confirm no trademark conflict with RuneScape's Grand Exchange — may need alternate name)*
- **Marksmanship** (not "Ranged")
- **Vanguarding** (not "Defence/Defense")
- **Bowstring** (not "Slingshot" — avoids Pokémon GO comparison in marketing)

---

---

## 🛠️ Confirmed Tech Stack

| Layer | Tool | Role |
|-------|------|------|
| **Engine** | Unity (2022.3 LTS or Unity 6) | Game client, iOS/Android/Steam builds |
| **Language** | C# | All game logic and systems |
| **Version Control** | GitHub | Single source of truth for code and design docs |
| **AI Dev** | Claude Code + Unity MCP | C# implementation, scene manipulation, debugging |
| **Backend** | Supabase | Player data, idle calculations, economy, auth |
| **Notifications** | Firebase Cloud Messaging | Push alerts for Attunement events, rare drops |
| **Monetization** | Unity IAP | Handles App Store, Google Play, and Steam purchases |
| **Analytics** | GameAnalytics | Player behavior, retention, economy balance |

### Development Workflow
```
Mobile (this chat) ──► Design decisions & doc updates
         │
         ▼
      GitHub ◄──────────────────────────────────────┐
         │                                           │
         ▼                                           │
Claude Code (desktop)                                │
  + Unity MCP connector  ──► Unity Editor ──► Pushes code
         │
         ▼
    Supabase backend
```

### Notes
- Design doc lives in GitHub repo under `/docs/design-doc.md`
- Claude Code reads the design doc directly to inform implementation
- Unity MCP allows Claude Code to manipulate scenes, create assets, and run tests without manual copy-paste
- Supabase handles all idle calculations server-side to prevent cheating

---

## 🎨 Art Direction — 2D Style

Project Grimoire launches as a **2D art style** game. All character, enemy, environment, and UI design decisions should be made with this constraint in mind. A 3D upgrade path can be evaluated post-launch.

### Visual Style Goals
- Rich, stylized 2D sprites — not pixel art, not hyper-realistic — think illustrated RPG style (similar to Darkest Dungeon, Hollow Knight, or Raid: Shadow Legends card art)
- Equipment and subclass visually reflected on character sprites (armor sets, weapons change sprite appearance)
- Biome-distinct environments for different resource zones (forest, cave, coastal, ruins, etc.)
- Animated sprite sheets for combat, Attunement actions, and idle states

### Combat & Raid Perspective

**Solo Combat (Warden Phase 1)**
- Top-down traversal view during exploration
- When combat triggers, perspective shifts to **over-the-shoulder / third-person behind your character only**
- Enemies are ahead, world recedes behind them
- **Bowstring mechanic** operates front-to-back: draw back toward the player, aim left-to-right across the screen — natural and intuitive in this perspective
- Critical hit zones visible on enemies as highlighted weak points

**Dungeons & Raids (Multiplayer)**
- Party is **locked to the bottom of the screen** in a horizontal formation
- The **world scrolls upward** toward the party — camera is fixed, environment moves, giving the feel of advancing without disorienting camera rotation
- Tank holds center, ranged holds flanks, healer positions based on party needs
- When an enemy encounter triggers, each player's screen **independently shifts to their own over-the-shoulder perspective** — you fight your targets, your party fights theirs simultaneously
- After the encounter clears, world scrolling resumes automatically
- **Boss encounters:** world stops scrolling, boss enters from top of screen, full party engages from their individual over-the-shoulder perspectives

**Idle/Talent Screens**
- Stylized UI panels with looping animated talent scenes in the background (e.g., axe-swing animation behind Felling queue, fish jumping behind Dredging)

### Sprite & Item Art Tool Stack

| Tool | Role | Why |
|------|------|-----|
| **Leonardo.ai** | Character concepts, enemies, environments | Built for game dev, sprite-focused models, strong quality |
| **Scenario.gg** | Item icons, talent assets, consistency layer | Trains on YOUR approved art — generates new assets that match your locked style |
| **Adobe Firefly** | UI elements, icons, polish | Clean commercial-safe output, good for interface art |
| **Stable Diffusion** (optional) | Bulk generation, experimentation | Free, full control, higher skill floor |

**Workflow:**
1. Use **Leonardo.ai** to generate and approve initial character/enemy/environment concepts
2. Lock art style from approved set
3. Train **Scenario.gg** on approved art → use for all ongoing item, talent, and asset generation
4. Export transparent PNGs → import into Unity as sprite sheets

### Unity 2D Considerations
- Use **Unity's 2D Sprite Renderer** and **2D Animation package** for character rigs
- **Spine** (third-party) is worth evaluating for fluid 2D character animation if budget allows
- UI built with **Unity UI Toolkit** for scalability across mobile and Steam screen sizes
- Particle effects for Attunement surges, spell impacts, and combat crits handled via **Unity Particle System** (2D mode)

---

*Document version 0.5 — Project Grimoire*
*Next: Individual Talent spec sheets · Stat scaling formulas · Bowstring mechanic detail · Faction Reputation design pass · Grand Exchange name confirmation*
