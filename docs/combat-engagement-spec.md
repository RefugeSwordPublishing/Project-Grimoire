# ⚔️ Project Grimoire — Combat Engagement Spec
### Version 0.1

---

## 📐 Design Philosophy

Combat in Project Grimoire scales in complexity and involvement from zone grinding (mostly idle, active for bonuses) through dungeons (structured encounters with room progression) to raids (fully active, multi-phase experiences requiring strategy, coordination, and player decision-making). The visual language is consistent — over-the-shoulder throughout — but the scope, stakes, and mechanical depth increase dramatically at each tier.

---

## 🌿 Zone Combat

### Visual — Over-the-Shoulder
All classes use the same over-the-shoulder perspective established for the Warden:
- Player character silhouette visible from behind in foreground
- Enemy visible ahead in the mid-ground
- Zone environment fills the background
- Combat UI (HP bars, input buttons, combo queue) overlays bottom of screen

**Class-specific elements visible on screen:**
| Class | Unique UI element |
|-------|-----------------|
| Warden | Bowstring draw bar, aim arc, weak point glow |
| Arcanist | Runic Constellation arch at bottom |
| Vanguard | Strike/Guard/Surge buttons, combo queue row |

### Zone Combat Flow
```
Player assigns zone + enemy type in Grimoire Queue
         ↓
Idle auto-combat runs — enemy spawns, combat resolves automatically
         ↓
Player opens app → active play available
         ↓
Active: Warden draws bow, Arcanist draws runes, Vanguard taps combos
         ↓
Enemy defeated → loot drops → next enemy spawns
         ↓
Zone boss spawn (~1 in 20 encounters) → active play only
```

### Enemy Engagement Rules
- One enemy at a time in zone combat — not packs
- Enemy HP and damage scale to zone tier
- Player can switch target enemy type anytime from zone selection
- Elites spawn rarely (~5–8% base, scales with Grimoire combat level)
- Zone boss spawns randomly, despawns after 10 minutes if not engaged

### Shadow Step — Shadowblade Zone Combat
Without physical positioning in 2D, Shadow Step works as a **combat state mechanic**:

```
Player taps Shadow Step (U→U combo)
         ↓
Shadowblade enters "Shroud" state — visually fades/dims on screen
         ↓
Next enemy attack misses entirely (one turn hidden)
         ↓
Shadowblade "reappears" with next Strike input
         ↓
That Strike deals +80% damage — the unseen approach
```

Visually: the player character dims to near-invisible, enemy attack animation plays but hits empty space, then a "reappear" flash as the counter-strike fires. Works cleanly in 2D without needing physical positioning.

---

## 🏰 Dungeon Combat

### Visual Structure — Two Phases

**Phase 1: Approach (Top-to-Bottom Scrolling)**
The dungeon scrolls downward — players always viewed from behind or 3/4 view, with enemies and events approaching from the top of the screen:
- Player character(s) remain centered or near-bottom of screen
- Dungeon tileset scrolls downward toward the player
- Enemies, hazards, and events appear at the top and scroll down toward the party
- Natural transition into over-the-shoulder combat when an enemy reaches engagement range
- The scrolling direction means players always face "into" the dungeon — consistent with over-the-shoulder combat perspective

```
┌─────────────────────────────┐
│  [Enemy approaching] ▼      │  ← Enemies/events enter from top
│                             │
│  [Corridor scrolling] ▼     │  ← Tileset scrolls downward
│                             │
│  [Player character]         │  ← Player stays near bottom
└─────────────────────────────┘
```

**Transition to combat:** When an enemy scrolls down to engagement range, the view seamlessly shifts to over-the-shoulder — no jarring scene change needed since the perspective is already correct.

**Phase 2: Room Encounter (Over-the-Shoulder)**
When the party reaches an enemy group or boss room the scrolling stops and combat begins:
- Same over-the-shoulder view — already established from the scrolling approach
- Multiple enemies in a room queue — one engages at a time, others visible in background
- Room cleared → scrolling resumes, corridor continues downward
- Boss room: scrolling stops, boss sprite fills screen from top

---

### Dungeon Randomization System

Every dungeon run is procedurally assembled from a themed pool of rooms, hazards, and events. Players can run the same dungeon countless times and encounter different layouts, event sequences, and challenges each time.

**Randomization rules:**
- Room order is randomized within structural constraints (safe room always before boss, entrance always first)
- Room contents drawn from the dungeon's themed pool — not all rooms appear every run
- Hazard types are dungeon-specific — different dungeons have different hazard identities
- Certain puzzle types are exclusive to specific dungeons — creates dungeon personality

**Fixed structure (every run):**
```
Entrance Room (always first)
     ↓
3–5 randomized rooms from themed pool
     ↓
Safe Room (always before boss)
     ↓
Boss Room (always last)
```

**Dungeon-specific themed pools:**

| Dungeon | Zone | Exclusive puzzle/hazard | Room pool themes |
|---------|------|------------------------|-----------------|
| Aldric's Warren | Grimwood Fringe | **Forge Puzzle** — identify correct material combinations | Bandit camp rooms, weapon caches, prisoner cells |
| Crestfall Cove | Saltmarsh Shore | **Flood Trap** — rising water hazard, find drain fast | Smuggler holds, sea cave chambers, hidden dock |
| Mirefall Barrow | Ashfen Mire | **Glyph Puzzle** — ancient undead rune sequences | Burial chambers, crypt corridors, ritual rooms |
| Warden's Folly | Ironspine Reaches | **Weight/Scale Puzzle** — counterbalance mechanisms | Guard barracks, armory, command rooms, torture chamber |

**Room pool example — Mirefall Barrow:**
| Room type | Chance of appearing per run |
|-----------|--------------------------|
| Crypt corridor (standard enemies) | Always — 2–3 per run |
| Burial chamber (elite room) | 60% chance per run |
| Glyph puzzle chamber | 70% chance per run — Mirefall exclusive |
| Bone trap corridor (trap room) | 50% chance |
| Treasure vault | 30% chance |
| Lost adventurer safe room (bonus supplies) | 20% chance |
| Ritual circle (buff/debuff choice) | 40% chance |

This means no two Mirefall Barrow runs feel identical — the glyph puzzle might appear or might not, the elite room might show up, the treasure vault is a rare bonus. High replayability naturally.

### Dungeon Hazards (Approach Phase)
Hazards appear during corridor travel and require active player response:

| Hazard | Visual | Player Action | Failure Result |
|--------|--------|--------------|----------------|
| **Floor Trap** | Glowing trigger plates visible on floor | Tap to avoid — timing window | Party takes damage |
| **Falling Debris** | Shadow indicator on floor showing impact zone | Dodge tap | Party takes damage |
| **Ambush** | Enemy silhouettes rushing from side corridors | Prepare stance — tap Guard | First enemy hit bypasses block |
| **Locked Door** | Door with glyph puzzle | Match glyph pattern (Inscription players get bonus hint) | Find key in backtrack room |
| **Poison Gas** | Green mist visible ahead | Tap to hold breath — brief duration | DoT applied to party |
| **Treasure Room** | Glinting light off to side corridor | Optional detour — tap to enter | Miss bonus loot (no penalty) |

Hazards are the primary reason dungeons can't be fully idled — they require active player input during the approach phase.

### Dungeon Room Types

| Room Type | Contents | Notes |
|-----------|---------|-------|
| **Standard room** | 2–4 standard enemies | Core encounter |
| **Elite room** | 1–2 elite enemies | Higher loot, harder fight |
| **Trap room** | No enemies, multiple hazards | Pure navigation challenge |
| **Puzzle room** | Environmental puzzle | See Puzzle section below |
| **Treasure room** | No enemies, loot chest | Optional detour |
| **Boss room** | Dungeon boss | Final encounter, full screen |
| **Safe room** | No enemies, HP regen | Midpoint rest before boss |

### Dungeon Puzzles
Puzzles gate progression through certain rooms — party must solve to advance:

| Puzzle Type | Mechanic | Class hint |
|------------|---------|-----------|
| **Glyph Sequence** | Runes appear in sequence, recreate the pattern | Arcanist — recognizes runes faster |
| **Weight Scales** | Place items on scales to balance — use inventory items | Any class |
| **Shadow Path** | Navigate through a dark room using light sources | Shadowblade — sees further in dark |
| **Rune Lock** | Draw a specific rune combination to unlock a door | Arcanist — Runeweaver gets bonus hint |
| **Pressure Plates** | Step on plates in correct order shown briefly | All classes equal |
| **Forge Puzzle** | Identify the correct material combination | Crafting Talent players get hint |

**Puzzle failure:** Party takes a damage penalty and puzzle resets — never hard-blocked.
**Class hints:** Certain classes get a visual highlight or shortened sequence — not required to solve, just faster. Rewards class knowledge without gating content.

### Dungeon Boss Encounter
Boss rooms trigger a special encounter mode:
- Boss sprite fills most of the screen — oversized, imposing
- Over-the-shoulder view maintained but camera pulls back slightly to show more of the boss
- Boss has multiple HP bars showing phases
- Phase transitions trigger visual changes — environment shifts, boss gains new abilities
- Party HP frames visible at screen top
- Active play required — no idle during boss fight

---

## ⚔️ Raid Combat

### Overview
Raids are the most complex content in Project Grimoire — fully active, multi-phase experiences that require coordination, strategy, and genuine decision-making. They cannot be idled at any stage. Recommended party: 4–6 players, Slaying 45+ required.

### Raid Visual Structure — Three Modes

**Mode 1: Exploration Map (Top-down Grid — Turn-Based)**
Used for navigating the raid environment between encounters:
- Top-down pixel art map view showing the current raid floor as a **grid**
- Each player occupies one grid tile — movement is tile-by-tile
- **Turn-based movement:** All players choose their move simultaneously, then the map updates every 5 seconds advancing everyone one tile
- Chosen move highlighted on map before the turn resolves — players see where teammates intend to move
- Enemy patrols move on the same turn timer — predictable, strategic
- Traps, doors, objectives, and points of interest shown on grid tiles

**Turn structure:**
```
Turn opens (5 second timer starts)
         ↓
Each player taps their intended destination tile
Their highlighted path appears on the map
         ↓
Timer expires (or all players have chosen)
         ↓
All players advance one tile toward their destination
Enemy patrols advance one tile along their route
         ↓
Next turn opens
```

**Supabase write pattern:**
```
6 players × 1 move choice per turn = 6 writes per turn
At 1 turn per 5 seconds = 1.2 writes/sec per raid
25 simultaneous raids = 30 writes/sec total — well within Supabase Small compute
```

**Mode 2: Dynamic Encounter (Over-the-Shoulder — Rush joinable)**
When any player encounters an enemy group:
- That player immediately enters over-the-shoulder combat — standard combat view
- **All party members see a notification** on their screen
- On the top-down map: exclamation point (!) appears over the combat tile
- Other players can move toward the (!) tile normally OR use **Rush** to move 2 tiles per turn toward combat
- When a player reaches the combat tile on any turn, they join the active combat at its current state
- Quick-Comm available: "Need help!" or "I'm fine!" signals to party

**Rush mechanic:**
- Triggered by tapping "Go Help" on the encounter notification
- Moves player 2 tiles toward combat per turn instead of 1
- Only available when moving toward an active combat tile
- Cannot be used for normal exploration movement — encounter-specific only
- Rush is a single-turn action — player chooses rush or normal move each turn

**Mode 3: Boss Fight (Full screen — over-the-shoulder)**
When any player enters the boss room tile on the grid:
- ALL party members are pulled to the boss fight simultaneously — no turn delay
- Boss room is the one exception to turn-based movement — entry is instant for all
- Boss fills most of the screen, over-the-shoulder perspective
- Phase transitions marked by dramatic visual and audio shift
- All party member HP frames visible at top of screen

---

### Raid Grid Design

**Grid tile types:**

| Tile | Visual | Function |
|------|--------|---------|
| Floor | Standard dungeon floor | Passable |
| Wall | Solid block | Impassable |
| Corridor | Narrow passage | Passable, single file |
| Enemy patrol | Moving enemy icon | Triggers combat on same tile |
| Objective | Star/flag icon | Interact to progress floor objective |
| Door (locked) | Lock icon | Requires key or puzzle to pass |
| Trap | Subtle indicator (visible to Gleaning 47+) | Triggers hazard if stepped on |
| Treasure | Chest icon | Optional loot — interact to collect |
| Safe tile | Shield icon | No encounters, brief HP regen |
| Boss room | Skull icon | Final tile — pulls all players on entry |
| Stairs/Exit | Arrow icon | Floor cleared — advance to next floor |

**Enemy patrol behavior on grid:**
- Patrols follow fixed waypoint routes — same turn timer as players
- Patrol path visible on map — players can see where they'll be next turn
- If player and patrol share a tile at turn end → encounter triggers
- Players can predict and avoid patrols with smart movement
- Alerting a patrol (getting within 2 tiles) causes it to move toward player next turn

---

### Dynamic Encounter System — Grid Version

```
Player A moves onto enemy patrol tile
         ↓
Combat triggers immediately for Player A (over-the-shoulder)
Turn timer pauses for Player A — they are in combat
         ↓
All party members notified:
"⚠ [PlayerA] is in combat — Grid F4"
(!) marker appears on F4 on all party maps
         ↓
Other players continue turn-based movement normally
         ↓
Players who want to help can:
  RUSH: move 2 tiles/turn toward F4
  NORMAL: move 1 tile/turn (stay on current objective)
  STAY: "I'm fine!" comm — don't come
         ↓
Player B reaches F4 on turn 3 → joins combat at current state
Player B seamlessly added to the over-the-shoulder encounter
         ↓
Combat resolves → both players return to grid map
Turn timer resumes for previously engaged player
```

**Notification display:**
```
┌─────────────────────────────────┐
│ ⚠ DUSTIN_SW is in combat       │
│   Grid position F4              │
│   [ Rush Over ] [ Stay Course ] │
│   [ I'm fine! — send comm ]     │
└─────────────────────────────────┘
```

**Turn timer during combat:**
- Players in active combat: turn timer paused for them — they're occupied
- Players not in combat: turn timer continues normally
- This means a player in a long combat encounter doesn't block their teammates from advancing the floor objective — exploration continues in parallel

**Multiple simultaneous encounters:**
Multiple (!) markers can appear on the map simultaneously. Free players choose which to help, or continue floor objective. Common in raids — two groups fight on opposite sides while one player pushes to the objective tile.

---

### Floor Objective System

Each floor has one primary objective required to unlock the stairs. Objectives are drawn from a randomized themed pool:

| Objective Type | Grid implementation | Coordination |
|---------------|-------------------|-------------|
| **Clear all patrol groups** | Defeat X patrol tiles | Split up — parallel clearing |
| **Activate switches** | Step on X specific tiles in sequence | Communication — who goes where |
| **Hold positions** | Multiple players must be on specific tiles simultaneously | Split — one player per tile |
| **Find the key** | Key tile hidden somewhere on grid | Explore independently |
| **Escort NPC** | NPC follows one player, moves on same turn | One escort, others clear path |
| **Destroy seals** | Multiple seal tiles across grid | Split up — simultaneous destruction |

**Floor cleared notification:**
When objective completes, all players see:
```
✓ FLOOR CLEARED — Stairs unlocked at tile J8
```
Stairs tile highlighted on all maps. Players converge and advance together.

---

---

### Raid Hazards & Strategic Elements

**Traps (exploration phase)**
Visible on the top-down map at certain Gleaning levels. Can be:
- Avoided by routing around them
- Disarmed by a Shadowblade (Gleaning 54+) for bonus loot
- Triggered intentionally to damage enemy patrols

**Enemy Patrols**
Patrol routes visible on top-down map. Strategic choices:
- Avoid: safer, faster, miss their loot
- Ambush: engage from unexpected angle, first hit bonus damage
- Alert: if patrol spots party, calls reinforcements — harder encounter

**Environmental Choices**
At certain points the party faces a fork — each path has different risks and rewards:

```
CHOICE POINT — The Sunken Hall
┌─────────────────────────────────┐
│ Path A: The Guard Room          │
│ Harder enemies, better loot     │
│ [Take Path A]                   │
├─────────────────────────────────┤
│ Path B: The Side Passage        │
│ Weaker enemies, faster route    │
│ [Take Path B]                   │
└─────────────────────────────────┘
```

Choices are voted on by party — majority decides. Adds genuine tension and discussion.

**Raid Puzzles**
More complex than dungeon puzzles — require party coordination:

| Puzzle | Mechanic | Coordination needed |
|--------|---------|-------------------|
| **Split Gate** | Two pressure plates must be held simultaneously | Two players split up |
| **Rune Ritual** | Three specific rune combinations drawn simultaneously | Three Arcanists ideal, others can guess |
| **Weight Distribution** | Each player contributes a specific material type | Party inventory coordination |
| **Timing Sequence** | Abilities must be activated in sequence within 5 seconds | Communication essential |
| **Reflection Maze** | Light beam redirected to hit multiple targets | Spatial reasoning |

Puzzle failure in a raid: party takes significant damage — raises stakes considerably compared to dungeon puzzles.

**Shrines (pre-boss antechamber)**
Optional buffs that cost materials from inventory:

| Shrine | Material Cost | Buff |
|--------|-------------|------|
| Warrior's Shrine | 5x Rough Gemstone | Party +15% damage for boss fight |
| Guardian's Shrine | 5x Rough Amber | Party +20% defense for boss fight |
| Scavenger's Shrine | 5x Rough Runic Cog | Loot quality +1 tier for boss drops |
| Healer's Shrine | 5x Rough Void Spore | Lifebinder spell cost reduced 30% for boss |

Only one shrine can be activated per raid run — creates a meaningful party decision.

---

### Raid Boss Design Principles

**Three-phase structure:**
Every raid boss has three distinct phases — visual and mechanical changes at 66% and 33% HP:

| Phase | HP Range | Tone | Mechanic shift |
|-------|---------|------|---------------|
| Phase 1 | 100–66% | Controlled — boss testing the party | Standard abilities, learnable patterns |
| Phase 2 | 66–33% | Escalating — boss takes the party seriously | New abilities added, existing ones speed up |
| Phase 3 | 33–0% | Enrage — boss at full power | All abilities active, environmental hazard added |

**Boss ability telegraphing:**
All boss abilities are visually telegraphed 2–3 seconds before they fire:
- Ground indicators show AoE zones
- Boss windup animations signal incoming attacks
- Color coding: red = damage, blue = debuff, yellow = environmental

**Party roles during boss fight:**
| Role | Job | Class best suited |
|------|-----|-----------------|
| Tank | Hold boss aggro, position boss | Warlord, Bulwark |
| Healer | Keep party alive, manage own HP resource | Lifebinder |
| DPS | Maximize damage output | Runeweaver, Sharpshot, Shadowblade |
| Utility | Summon constructs, debuff boss | Summoner, Lone Wanderer |

No hard role requirements — smaller parties adapt. But a party with no tank will find Phase 3 very difficult.

---

### Quick-Comm System (Raids)

Simple preset communication for mobile play — no text chat needed during combat:

| Comm | Trigger | Display |
|------|---------|---------|
| **Heal me** | Tap own HP bar | Red pulse on that player's party frame |
| **Target this** | Tap enemy | Yellow marker on enemy, all party sees |
| **Ready** | Tap ready icon | Green checkmark on party frame |
| **Danger** | Tap warning icon | Orange flash for all party members |
| **Follow me** | Tap movement icon | Dotted path indicator on top-down map |
| **Activate** | Tap interact icon | Highlights nearest interactable object |

Quick-comms visible during both top-down exploration and combat — simple enough for mobile, meaningful enough to coordinate a raid.

---

### Raid Loot Distribution

Boss loot dropped into a shared pool:
- All party members see the loot pool
- Each item can be: **Take** (add to your inventory) or **Pass**
- If multiple players Take the same item: random roll among those who took
- Items not taken by anyone go to the party leader's inventory
- Masterwork tier materials guaranteed from raid boss — primary source in game

---

## 🔧 Technical Notes for Implementation

**Raid grid turn-based movement:**
- Grid stored as 2D array in `RaidFloorData` ScriptableObject — tile types per cell
- Turn timer: `RaidTurnManager.cs` broadcasts turn start/end to all connected players via Supabase real-time
- Player move choice: written to `raid_player_moves` table on choice — `{raid_id, player_id, turn_number, target_tile}`
- Turn resolution: when timer expires OR all players submitted moves, `RaidTurnManager` reads all moves and updates `raid_player_positions` table — one batch write per turn
- Enemy patrol movement: server-side calculation — patrol positions updated in same batch write as players
- Map sync: all players subscribe to `raid_player_positions` via Supabase real-time — updates render on map after turn resolves

**Supabase write load:**
```
Per turn: 6 player moves + 1 batch position update = 7 writes per turn
Per second: 7 / 5 = 1.4 writes/sec per raid
At 25 simultaneous raids: 35 writes/sec — well within Supabase Small compute
```

**Rush mechanic:**
```csharp
void OnRushSelected(Player player, Vector2Int combatTile) {
    player.isRushing = true;
    player.rushTarget = combatTile;
}

Vector2Int GetPlayerMove(Player player) {
    if (player.isRushing) {
        // Move 2 tiles toward rush target instead of 1
        Vector2Int dir = GetDirectionTo(player.position, player.rushTarget);
        Vector2Int step1 = player.position + dir;
        Vector2Int step2 = IsPassable(step1 + dir) ? step1 + dir : step1;
        return step2;
    }
    return player.selectedMove; // Normal 1-tile move
}
```

**Dynamic encounter join — grid version:**
```csharp
void OnPlayerReachesCombatTile(Player joiningPlayer, ActiveCombat combat) {
    if (combat.isActive) {
        // Seamlessly add to existing combat — no reset
        combat.AddParticipant(joiningPlayer);
        joiningPlayer.EnterCombatMode(combat);
        joiningPlayer.turnTimerPaused = true;
    }
}

void OnCombatEnds(ActiveCombat combat) {
    foreach (var p in combat.participants) {
        p.ReturnToGrid();
        p.turnTimerPaused = false; // Resume turn participation
    }
    RaidMapUI.ClearCombatMarker(combat.gridPosition);
}
```

**Turn timer during combat:**
- Players in combat: `turnTimerPaused = true` — they don't submit moves
- Turn resolves for all non-combat players normally
- Combat players rejoin turn cycle when combat ends
- Floor objective progress unaffected by individual players being in combat

**Shadow Step implementation:**
```csharp
void ActivateShadowStep() {
    playerState = CombatState.Shroud;
    playerRenderer.color = new Color(1f, 1f, 1f, 0.2f); // Fade visual
    nextEnemyAttackMissed = true; // One attack passes through
    onNextStrikeInput += ApplyShadowStepBonus; // +80% on next hit
}

void ApplyShadowStepBonus(float baseDamage) {
    return baseDamage * 1.8f;
    onNextStrikeInput -= ApplyShadowStepBonus; // Remove after one use
    playerRenderer.color = Color.white; // Restore visual
    playerState = CombatState.Active;
}
```

---

*Document version 0.1 — Combat Engagement Spec*
*Next: Shadowblade full spec update (Black Ledger removed, Shadow Step updated) · Phase 2 handoff*
