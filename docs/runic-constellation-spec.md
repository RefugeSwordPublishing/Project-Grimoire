# ⚔️ Project Grimoire — Runic Constellation Mechanic
### Version 0.1

---

## 📐 Design Philosophy

The Runic Constellation is the Arcanist's active combat identity — a skill-based spell casting system that rewards both knowledge (knowing which combinations do what) and execution (drawing quickly and accurately). It must work comfortably with a mobile thumb, feel magical and reactive, and never punish players who make mistakes — only reward those who play well.

**Core principles:**
- Draw lines between nodes by dragging — connect the dots
- Spell fires instantly on finger lift — no delay, immediate feedback
- Incorrect or incomplete combinations fire a weak default spell — never a wasted action
- Drawing speed directly affects spell power — active skill expression
- Idle fallback auto-casts the last used single-rune spell at 60% potency
- Subclass alters what each rune does — not the layout

---

## 🌟 The Rune Nodes

Eight runes exist in the world of Project Grimoire, but each Arcanist subclass uses only 6 — their specific constellation layout. This means switching Grimoires requires relearning the constellation, adding genuine mastery depth to each subclass. Positions 5 and 6 are what distinguish each subclass's layout.

| Node | Element | Base Effect |
|------|---------|------------|
| **Ignis** | Fire | Burn damage over time |
| **Glacius** | Ice | Slow + frost damage |
| **Tempest** | Lightning | Chain damage, accuracy debuff |
| **Ventus** | Wind | Push back, evasion boost |
| **Terra** | Earth | Stagger, armor break |
| **Vita** | Life | Healing, regeneration |
| **Umbra** | Shadow | Weaken, stealth proc |
| **Lux** | Light | Blind, damage amplify |

### Subclass-Specific 6-Rune Layouts

Each subclass has 6 active nodes from the 8 available. Same physical positions on screen — different runes active per subclass.

| Position | Runeweaver | Summoner | Lifebinder |
|----------|-----------|---------|-----------|
| 1 | Ignis | Ignis | Ignis |
| 2 | Glacius | Glacius | Glacius |
| 3 | Tempest | Tempest | Tempest |
| 4 | Ventus | Ventus | Ventus |
| 5 | **Umbra** | **Terra** | **Vita** |
| 6 | **Lux** | **Umbra** | **Lux** |

Inactive nodes are visually dimmed on the constellation — players naturally learn which nodes belong to their subclass.

**DLC subclass layouts (placeholder — full design at DLC phase):**

| Position | Warlock | Bloodweaver |
|----------|---------|------------|
| 1 | Ignis | Ignis |
| 2 | Umbra | Umbra |
| 3 | Tempest | Vita |
| 4 | Lux | Glacius |
| 5 | Glacius | Ventus |
| 6 | Ventus | Terra |

---

## 📱 Screen Layout — Thumb-Reachable Arch

The constellation appears as a **semi-circular arch** anchored at the bottom of the combat screen, curving upward around the player character. Designed for one-thumb mobile play — all 6 active nodes within natural thumb sweep range. (8 runes exist in the world but each subclass uses 6 — see layout table above.)

```
        Tempest    Terra
    Glacius            Ventus
  Ignis                  Umbra
      Vita          Lux
           [Player]
```

**Layout specifics:**
- Arch spans the bottom 40% of the screen
- Nodes are large tap targets — 64x64 minimum touch area regardless of visual size
- Center bottom anchored behind/around the player character silhouette
- Enemy visible in the upper 60% of screen — player can see target while drawing
- Combat log and HP bars sit at very top — never overlap the arch
- On desktop (PC/Steam): constellation appears as a panel in the bottom-center, mouse drag to connect

**Node glow behavior:**
- Default: nodes glow faintly in their element color
- On touch: node brightens and pulses — confirms contact
- On valid connection: line draws between nodes in element color with a brief spark
- On invalid connection: line briefly flashes red then disappears — soft error feedback
- Full combination ready: all connected nodes pulse together before firing

---

## ✏️ Drawing Mechanic

### Input Flow
1. Player places finger/mouse on a starting node — node activates
2. Drag to next node — connection line draws in real-time
3. Continue dragging to additional nodes (up to 4 total)
4. Lift finger/release mouse — spell fires instantly based on combination drawn

### Connection Rules
- Must start on a node — dragging from empty space does nothing
- Nodes can be connected in any order — Ignis→Glacius is the same combination as Glacius→Ignis
- Cannot connect the same node twice in one combination
- Minimum 1 node (tap and release) — fires single-rune spell
- Maximum 4 nodes — hard cap

### Speed Bonus
Drawing speed is measured as time from first node contact to finger lift:

| Draw Time | Speed Tier | Damage Modifier |
|-----------|-----------|----------------|
| Under 0.4s | Lightning | ×1.5 |
| 0.4s – 0.8s | Swift | ×1.25 |
| 0.8s – 1.5s | Standard | ×1.0 |
| Over 1.5s | Slow | ×0.85 |

Speed bonus applies to all damage-dealing spells. Healing spells are not affected by speed — a hurried heal is the same as a careful one.

### Invalid/Incomplete Combinations
If the player draws a combination that doesn't match any known spell (wrong node order, unsupported combination for their subclass, or a combination not yet unlocked):
- **Weak default spell fires** — single Ignis blast at 40% of base Magic Attack
- No mana penalty beyond standard single-cast cost
- Visual: brief "?" flash over the combination before the default fires
- Player is never punished for trying — only rewarded for succeeding

---

### Targeting — Draw Then Drag (Universal Arcanist Mechanic)

After completing a constellation combination, the player drags their thumb to the intended target before releasing:

1. Draw combination between nodes as normal
2. **Drag to target** — golden tether line connects from last node to target
3. Target glows to confirm selection
4. Release — spell fires at that target

| Subclass | Drag target | Effect |
|----------|------------|--------|
| **Runeweaver** | Enemy | Single target vs choosing not to drag (AoE) |
| **Summoner** | Specific construct | Issue command to that construct precisely |
| **Lifebinder** | Ally or self | Heal/HOT/buff that specific party member |

Releasing without dragging to a target defaults to: nearest enemy (Runeweaver), most recently summoned construct (Summoner), self (Lifebinder).

---

| Spellcasting Level | Combination Depth Unlocked |
|-------------------|--------------------------|
| 1 | Single rune (1 node) |
| 16 | 2-rune combinations |
| 42 | 3-rune combinations |
| 88 | 4-rune combinations (full constellation) |

Each depth unlock is a significant milestone — reaching Spellcasting 88 and being able to draw 4-node combinations is a mastery moment.

---

## 🔮 Combination Spell Library

### Single Rune Spells (Spellcasting 1+)
| Node | Spell Name | Effect |
|------|-----------|--------|
| Ignis | Ember Shot | Small fire damage + 2s burn |
| Glacius | Frost Bolt | Ice damage + minor slow |
| Tempest | Spark | Lightning damage |
| Terra | Stone Throw | Earth damage + minor stagger |
| Ventus | Gust | Wind damage + tiny pushback |
| Vita | Mend | Restore 8% max HP |
| Umbra | Shadow Dart | Shadow damage + 10% weaken |
| Lux | Flash | Light damage + 1s blind |

### 2-Rune Combinations (Spellcasting 16+)
| Combination | Spell Name | Effect | Element |
|------------|-----------|--------|---------|
| Ignis + Glacius | Steam Burst | AoE damage + blind | Fire/Ice |
| Ignis + Tempest | Firestorm | Burn + chain lightning | Fire/Lightning |
| Ignis + Terra | Magma Surge | Heavy damage + armor break | Fire/Earth |
| Ignis + Ventus | Flame Vortex | Spin damage + burn spread | Fire/Wind |
| Ignis + Umbra | Soulfire | Magic damage + life drain | Fire/Shadow |
| Ignis + Lux | Solar Flare | Massive damage + blind | Fire/Light |
| Glacius + Tempest | Blizzard Strike | Ice + shock, accuracy down | Ice/Lightning |
| Glacius + Terra | Permafrost | Freeze + defense shred | Ice/Earth |
| Glacius + Ventus | Hailstorm | AoE ice + slow field | Ice/Wind |
| Glacius + Vita | Glacial Mend | Heal + ice shield | Ice/Life |
| Glacius + Umbra | Hypothermia | Freeze + weaken | Ice/Shadow |
| Glacius + Lux | Prism Ice | Refract damage to nearby enemies | Ice/Light |
| Tempest + Terra | Thunderclap | Stun + armor break | Lightning/Earth |
| Tempest + Ventus | Cyclone | Chain lightning + pushback | Lightning/Wind |
| Tempest + Vita | Static Pulse | Heal + shock aura | Lightning/Life |
| Tempest + Umbra | Shadow Bolt | Heavy damage + accuracy down | Lightning/Shadow |
| Tempest + Lux | Holy Storm | Light + lightning, massive damage | Lightning/Light |
| Terra + Ventus | Sandstorm | AoE blind + evasion buff | Earth/Wind |
| Terra + Vita | Stone Skin | Defense buff + minor heal | Earth/Life |
| Terra + Umbra | Earthen Grave | Trap enemy, reduce speed | Earth/Shadow |
| Terra + Lux | Sacred Ground | AoE light damage + defense | Earth/Light |
| Ventus + Vita | Tailwind | Self evasion + regen | Wind/Life |
| Ventus + Umbra | Phantom Gust | Invisible + dodge buff | Wind/Shadow |
| Ventus + Lux | Divine Wind | Pushback + light damage AoE | Wind/Light |
| Vita + Umbra | Blood Pact | Drain life, sacrifice HP for power | Life/Shadow |
| Vita + Lux | Radiant Heal | Major heal + remove debuffs | Life/Light |
| Umbra + Lux | Twilight Surge | Counter-element burst — highest 2-rune damage | Shadow/Light |

### 3-Rune Combinations (Spellcasting 42+) — Selected Examples
| Combination | Spell Name | Effect |
|------------|-----------|--------|
| Ignis + Tempest + Ventus | Inferno Cyclone | Massive fire AoE + burn field |
| Glacius + Terra + Vita | Permafrost Ward | Freeze + stone skin + regeneration |
| Umbra + Lux + Tempest | Eclipse Storm | Counter-element chain lightning + weaken |
| Vita + Lux + Ventus | Ascendant Wind | Major heal + evasion + light shield |
| Ignis + Glacius + Tempest | Elemental Triad | Three-element burst, heavy damage |
| Terra + Ventus + Umbra | Phantom Earth | Trap + stealth + armor shred |

> Full 3-rune library to be expanded during Phase 2 implementation — these are examples establishing the pattern.

### 4-Rune Combinations (Spellcasting 88+) — Signature Spells
| Combination | Spell Name | Effect | Notes |
|------------|-----------|--------|-------|
| Ignis + Tempest + Ventus + Lux | Sundering Nova | Massive AoE, all nearby enemies | Highest damage combination in base game |
| Glacius + Terra + Vita + Lux | Aegis of Dawn | Full heal + ice shield + defense | Premier survival combination |
| Umbra + Lux + Glacius + Tempest | Void Eclipse | Counter-element ×2, massive single target | Shadowblade's peak combination |
| Vita + Lux + Ventus + Ignis | Phoenix Wave | Revive from death if cast below 20% HP | Lifebinder signature — once per dungeon |
| Terra + Umbra + Glacius + Tempest | Runic Collapse | Stagger + freeze + chain + weaken all | Runeweaver control signature |
| Ignis + Glacius + Tempest + Ventus | Tempest of Four | Four-element cycling damage | Runeweaver endgame rotation |

---

## 🔄 Counter-Element System

Counter pairs are subclass-specific — each subclass has their own opposing rune relationships based on their 6-node layout. Counter bonus stacks with speed bonus.

### Runeweaver Counter Pairs
| Counter Pair | Bonus | Lore |
|-------------|-------|------|
| Ignis ↔ Glacius | ×1.25 | Fire vs Ice |
| Tempest ↔ Ventus | ×1.25 | Lightning vs Wind |
| Umbra ↔ Lux | ×1.5 | Shadow vs Light — strongest, Runeweaver signature |

### Summoner Counter Pairs
| Counter Pair | Bonus | Notes |
|-------------|-------|-------|
| Ignis ↔ Glacius | ×1.25 | Fire vs Ice construct coordination |
| Tempest ↔ Terra | ×1.25 | Storm Wisp vs Stone Golem — opposing constructs |
| Umbra ↔ Terra | ×1.4 | Void Shade vs Golem — shadow vs earth |

### Lifebinder Counter Pairs
| Counter Pair | Bonus | Notes |
|-------------|-------|-------|
| Ignis ↔ Glacius | ×1.25 | Cauterize vs Ice Ward — opposing healing tools |
| Tempest ↔ Ventus | ×1.25 | Disruption vs Evasion |
| Vita + Lux | ×1.3 heal bonus | Not a counter — an amplifier. Both light-aspected, combining them enhances healing rather than creating tension |

Counter bonus stacks with speed bonus — a fast counter-element combination is the highest damage output in active play.

---

## 🎭 Subclass Variations

Each subclass has a unique 6-node constellation layout — same physical positions, different active runes. Subclass also alters what each shared rune does.

### Runeweaver (Ignis, Glacius, Tempest, Ventus, Umbra, Lux)
Primary identity: elemental combinations, counter bonuses, AoE control
- Full offensive rune set — all 6 runes deal damage or debuff
- Counter bonus increased to ×1.5 on all counter pairs (×1.75 on Umbra↔Lux)
- 3-rune combinations unlock at Spellcasting 35 (earlier than standard 42)
- Signature idle: auto-rotates through last 3 used single-rune spells
- Vita and Terra not available — pure offense, no healing

### Summoner (Ignis, Glacius, Tempest, Ventus, Terra, Umbra)
Primary identity: backline tactician, constructs fight, user commands
- Ignis = Ember Sprite command, Terra = Stone Golem command
- Glacius = Frost Shard command, Tempest = Storm Wisp command
- Umbra = Void Shade command, Ventus = recall all constructs
- Combinations coordinate constructs rather than direct damage
- No Vita (no healing) and no Lux (no party buffs) — pure construct control
- Signature idle: constructs auto-attack, user auto-issues single-rune commands

### Lifebinder (Ignis, Glacius, Tempest, Ventus, Vita, Lux)
Primary identity: healer, self-sustaining solo, group support
- Vita = primary heal resource, Lux = debuff cleanse and shield
- No Umbra — blocked entirely, reserved for Bloodweaver DLC
- No Terra — no stagger or armor break
- Vita + Lux = amplifier not counter — ×1.3 heal bonus
- Damage combinations weakened by 40% — Lifebinder is not a damage dealer
- Signature idle: auto-cycles Vita single-rune self-heal when below 60% HP

---

## 💡 Attunement — Active Play Bonus

The Runic Constellation's attunement moment:

| Condition | Attunement Type | Bonus |
|-----------|----------------|-------|
| Draw at Lightning speed (under 0.4s) | Speed attunement | ×1.5 XP + speed damage bonus |
| Use counter-element combination | Counter attunement | ×1.25 damage + 10% loot bonus |
| Land a 4-rune combination | Mastery attunement | ×2.0 XP + 20% loot bonus |
| Land Umbra↔Lux counter | Peak attunement | ×1.75 damage + 15% loot bonus |

Idle fallback attunement: auto-cast last single-rune at 60% potency — no speed bonus, no counter bonus possible.

---

## 🎮 Idle Behavior

When Marksmanship idle combat is active (Warden) the game auto-fires. Arcanist idle works similarly:

- Player queues a spell combination in the Grimoire Queue UI
- Idle auto-casts that combination at 60% potency on a fixed interval
- Last manually drawn combination is what auto-casts — the game remembers it
- Player can update the idle combination anytime by drawing a new one during active play
- If no combination has been drawn yet: defaults to single Ignis auto-cast

**Idle cast interval by Spellcasting level:**
| Level | Cast Interval |
|-------|-------------|
| 1–20 | Every 5.0s |
| 21–40 | Every 4.0s |
| 41–60 | Every 3.5s |
| 61–80 | Every 3.0s |
| 81–100 | Every 2.5s |

---

## 🔧 Technical Notes for Implementation

**Input handling:**
- Use Unity's `IPointerDownHandler`, `IDragHandler`, `IPointerUpHandler` interfaces
- On PointerDown: check if touch position overlaps a node collider — register as start node
- On Drag: raycast each frame for node colliders — register new nodes as line is drawn
- On PointerUp: fire spell based on registered node sequence, clear line
- Track draw start time on PointerDown, calculate elapsed on PointerUp for speed tier

**Node layout:**
- 6 active nodes positioned on a semi-circle arc, radius ~35% of screen width
- Inactive nodes (2 per subclass) not rendered — only the 6 subclass-specific nodes appear
- Arc center at bottom-center of combat area
- Store node positions as normalized screen coordinates — scale correctly on all devices
- Minimum 64px touch target per node regardless of visual sprite size

**Combination lookup:**
- Store all valid combinations as a Dictionary<HashSet<RuneType>, SpellData>
- Order-independent lookup — sort the node set before lookup so Ignis+Glacius = Glacius+Ignis
- If combination not found in dictionary → fire default weak spell
- SpellData ScriptableObject per spell — name, description, damage formula, effect, mana cost, animation

**Speed calculation:**
```csharp
float drawTime = Time.time - drawStartTime;
float speedMultiplier = drawTime < 0.4f ? 1.5f :
                        drawTime < 0.8f ? 1.25f :
                        drawTime < 1.5f ? 1.0f : 0.85f;
```

**Mana costs:**
| Combination depth | Mana cost |
|------------------|-----------|
| 1 rune | 5 mana |
| 2 rune | 10 mana |
| 3 rune | 18 mana |
| 4 rune | 28 mana |
| Default weak spell | 5 mana |

If player has insufficient mana: default weak spell fires at reduced cost (2 mana). Never blocked entirely.

**Subclass behavior:**
- `SpellcastingSubclass` enum on GrimoireManager drives which SpellData lookup table is used
- Same combination string, different SpellData ScriptableObject per subclass
- Three lookup tables: RuneweaverSpells, SummonerSpells, LifebinderSpells
- All use same node layout and input system — only output differs

**PC/Steam input:**
- Mouse drag replaces touch drag — identical logic
- Optional keyboard shortcuts for single-rune casts (1–8 keys mapped to nodes) — quality of life for PC players
- Mouse hover highlights node before click — visual affordance

---

*Document version 0.2 — Runic Constellation Mechanic*
*Key change: 8 runes compacted to 6 per subclass with unique layouts. Counter pairs now subclass-specific.*
*Next: Melee combo system (Vanguard) · Summoner construct system · Lifebinder healing design · Guild Hall UI*
