---
type: design-spec
version: 0.3
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Runic Constellation Mechanic
### Version 0.3

> **Changes from v0.2:** All references to "Spellcasting level" replaced with "Grimoire combat
> level" (Spellcasting is not a shared Talent — combat progression lives on each Arcanist
> Grimoire). Mana cost table now carries a Lifebinder carve-out. 4-rune library cross-checked
> against per-subclass node layouts — conflicts removed (see notes inline).

---

## Design Philosophy

The Runic Constellation is the Arcanist's active combat identity — skill expression through drawing
speed and combination knowledge. It must work comfortably with a mobile thumb, feel magical and
reactive, and never punish mistakes — only reward mastery.

**Core principles:**
- Draw lines between nodes by dragging — connect the dots
- Spell fires instantly on finger lift — no delay, immediate feedback
- Invalid combinations fire a weak default spell — never a wasted action
- Drawing speed directly affects spell power — active skill expression
- Idle fallback auto-casts the last used single-rune at 60% potency
- No crit system for any Arcanist subclass — skill expression is speed + counter knowledge

---

## The Rune Nodes

Eight runes exist; each Arcanist subclass uses 6. Positions 5–6 distinguish each subclass.

| Node | Element | Base Effect |
|------|---------|------------|
| **Ignis** | Fire | Burn damage over time |
| **Glacius** | Ice | Slow + frost damage |
| **Tempest** | Lightning | Chain damage, accuracy debuff |
| **Ventus** | Wind | Pushback, evasion boost |
| **Terra** | Earth | Stagger, armor break |
| **Vita** | Life | Healing, regeneration |
| **Umbra** | Shadow | Weaken, stealth proc |
| **Lux** | Light | Blind, damage amplify |

### Subclass-Specific 6-Rune Layouts

| Position | Runeweaver | Summoner | Lifebinder |
|----------|-----------|---------|-----------|
| 1 | Ignis | Ignis | Ignis |
| 2 | Glacius | Glacius | Glacius |
| 3 | Tempest | Tempest | Tempest |
| 4 | Ventus | Ventus | Ventus |
| 5 | **Umbra** | **Terra** | **Vita** |
| 6 | **Lux** | **Umbra** | **Lux** |

Inactive nodes (2 per subclass) are not rendered on screen.

**DLC placeholder layouts:**

| Position | Warlock | Bloodweaver |
|----------|---------|------------|
| 1 | Ignis | Ignis |
| 2 | Umbra | Umbra |
| 3 | Tempest | Vita |
| 4 | Lux | Glacius |
| 5 | Glacius | Ventus |
| 6 | Ventus | Terra |

---

## Screen Layout — Thumb-Reachable Arch

Semi-circular arch anchored at bottom of combat screen — all 6 active nodes within natural thumb
sweep range.

```
        Tempest    [pos5]
    Glacius            Ventus
  Ignis                  [pos6]
           [Player]
```

- Arch spans bottom 40% of screen
- Nodes: 64×64 minimum touch target regardless of visual sprite
- Enemy visible in upper 60% of screen at all times
- HP bars / combat log at very top — never overlap the arch
- PC/Steam: constellation panel at bottom-centre, mouse drag to connect

**Node glow behaviour:**
- Default: faint element-colour glow
- On touch: brightens + pulses (confirms contact)
- Valid connection: coloured line + brief spark between nodes
- Invalid connection: brief red flash, then disappears
- Full combination ready: all connected nodes pulse together before firing

---

## Drawing Mechanic

### Input Flow
1. Place finger on starting node — activates
2. Drag to next node — connection line draws in real time
3. Continue to additional nodes (up to 4)
4. Lift finger — spell fires instantly

### Connection Rules
- Must start on a node — empty-space drag does nothing
- Order-independent — Ignis→Glacius = Glacius→Ignis
- Cannot connect the same node twice
- Minimum 1 node (tap and release) — fires single-rune spell
- Maximum 4 nodes — hard cap

### Speed Bonus
Measured from first node contact to finger lift:

| Draw Time | Speed Tier | Damage Modifier |
|-----------|-----------|----------------|
| < 0.4s | Lightning | ×1.5 |
| 0.4–0.8s | Swift | ×1.25 |
| 0.8–1.5s | Standard | ×1.0 |
| > 1.5s | Slow | ×0.85 |

Speed bonus applies to damage spells only. Healing spells (Lifebinder) are unaffected.

### Invalid Combinations
- Fires weak default: single Ignis blast at 40% base Magic Attack
- Visual: brief "?" flash before default fires
- Resource cost: standard single-rune cost (never blocked entirely)

---

## Targeting — Draw Then Drag (Universal Arcanist)

After completing a combination, drag thumb to intended target before releasing:

1. Draw combination
2. Drag to target — golden tether line from last node to target
3. Target glows to confirm
4. Release — spell fires

| Subclass | Default if no drag | Drag target |
|----------|--------------------|-------------|
| Runeweaver | Nearest enemy | Any enemy (single target vs AoE) |
| Summoner | Most recently active construct | Specific construct (precise commands) |
| Lifebinder | Self | Ally or self |

---

## Combination Depth Unlocks

Unlocks are gated by **Grimoire combat level** (the per-Grimoire level in
`player_grimoire_levels`, managed by `CombatXPManager`).

| Grimoire Combat Level | Depth Unlocked |
|----------------------|---------------|
| 1 | Single rune (1 node) |
| 16 | 2-rune combinations |
| 42 | 3-rune combinations (Runeweaver: 35 instead) |
| 88 | 4-rune combinations |

---

## Combination Spell Library

### Single Rune (Combat Level 1+)

| Node | Spell | Effect |
|------|-------|--------|
| Ignis | Ember Shot | Fire damage + 2s burn |
| Glacius | Frost Bolt | Ice damage + minor slow |
| Tempest | Spark | Lightning damage |
| Terra | Stone Throw | Earth damage + minor stagger |
| Ventus | Gust | Wind damage + tiny pushback |
| Vita | Mend | Restore 8% max HP |
| Umbra | Shadow Dart | Shadow damage + 10% weaken |
| Lux | Flash | Light damage + 1s blind |

> Subclasses only render their 6 active nodes. The spells above exist as SpellData
> ScriptableObjects for all 8 runes; only the relevant 6 are loaded per subclass.

### 2-Rune Combinations (Combat Level 16+)

| Combination | Spell | Effect | Element |
|------------|-------|--------|---------|
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

> Each subclass only loads the 2-rune combos that use their 6 active runes. Combos using
> inactive nodes are simply absent from that subclass's lookup table.

### 3-Rune Combinations (Combat Level 42+; Runeweaver: 35+)

Examples establishing the pattern — full library to be expanded during Phase 2 implementation:

| Combination | Spell | Effect |
|------------|-------|--------|
| Ignis + Tempest + Ventus | Inferno Cyclone | Massive fire AoE + burn field |
| Glacius + Terra + Vita | Permafrost Ward | Freeze + stone skin + regeneration |
| Umbra + Lux + Tempest | Eclipse Storm | Counter-element chain lightning + weaken |
| Vita + Lux + Ventus | Ascendant Wind | Major heal + evasion + light shield |
| Ignis + Glacius + Tempest | Elemental Triad | Three-element burst, heavy damage |
| Terra + Ventus + Umbra | Phantom Earth | Trap + stealth + armor shred |

### 4-Rune Combinations (Combat Level 88+)

> Each spell below is cross-checked against the 6-node layout of its intended subclass.
> Spells are only available to subclasses that have all four required runes active.

| Combination | Spell | Effect | Available to |
|------------|-------|--------|-------------|
| Ignis + Tempest + Ventus + Lux | Sundering Nova | Massive AoE, all nearby enemies | Runeweaver only (has all 4) |
| Glacius + Vita + Lux + Ventus | Aegis of Dawn | Full heal + ice shield + defense | Lifebinder only (has all 4) |
| Umbra + Lux + Glacius + Tempest | Void Eclipse | Counter-element ×2, massive single target | Runeweaver only |
| Vita + Lux + Ventus + Ignis | Phoenix Wave | Revive from death if cast below 20% HP — once per dungeon | Lifebinder only |
| Terra + Umbra + Glacius + Tempest | Runic Collapse | Stagger + freeze + chain + weaken all | Summoner only (has all 4) |
| Ignis + Glacius + Tempest + Ventus | Tempest of Four | Four-element cycling damage | Runeweaver + Summoner (both have all 4) |

---

## Counter-Element System

Counter pairs are subclass-specific. Counter bonus stacks multiplicatively with speed bonus.

### Runeweaver
| Pair | Bonus |
|------|-------|
| Ignis ↔ Glacius | ×1.25 |
| Tempest ↔ Ventus | ×1.25 |
| Umbra ↔ Lux | ×1.5 (Runeweaver signature) |

Runeweaver counter bonus is elevated: all pairs ×1.5, Umbra↔Lux ×1.75.

### Summoner
| Pair | Bonus |
|------|-------|
| Ignis ↔ Glacius | ×1.25 |
| Tempest ↔ Terra | ×1.25 |
| Umbra ↔ Terra | ×1.4 |

### Lifebinder
| Pair | Bonus |
|------|-------|
| Ignis ↔ Glacius | ×1.25 |
| Tempest ↔ Ventus | ×1.25 |
| Vita + Lux | ×1.3 heal bonus (amplifier, not counter — both light-aspected) |

---

## Subclass Variations

### Runeweaver (Ignis, Glacius, Tempest, Ventus, Umbra, Lux)
- Full offensive set — all 6 deal damage or debuff
- Counter bonuses elevated (see above)
- 3-rune combos unlock at Grimoire combat level 35 (earlier than standard 42)
- Signature idle: auto-rotates through last 3 used single-rune spells

### Summoner (Ignis, Glacius, Tempest, Ventus, Terra, Umbra)
- Combinations issue commands to constructs — see `summoner-spec.md`
- No Vita or Lux — no direct healing or party buffs
- Signature idle: constructs auto-attack; user auto-issues single-rune commands

### Lifebinder (Ignis, Glacius, Tempest, Ventus, Vita, Lux)
- No Umbra — node does not appear; no blocking logic needed
- No Terra — no stagger or armor break
- Damage combos weakened by 40% — not a damage dealer
- HP is the casting resource (no mana) — see `lifebinder-spec.md`
- Signature idle: auto-casts single Vita self-heal when below 60% HP

---

## Attunement — Active Play Bonus

| Condition | Bonus |
|-----------|-------|
| Lightning speed draw (< 0.4s) | ×1.5 XP + speed damage modifier |
| Counter-element combination | ×1.25 damage + 6% loot bonus |
| 4-rune combination | ×2.0 XP (mastery reward — depth IS the bonus) |
| Umbra↔Lux counter (Runeweaver) | ×1.75 damage + 15% loot bonus |

No crit system. No weak points. Skill expression = speed + counter knowledge.

---

## Idle Behaviour

- Queued combination auto-casts at 60% potency
- Interval scales with Grimoire combat level:

| Grimoire Combat Level | Cast Interval |
|----------------------|--------------|
| 1–20 | 5.0s |
| 21–40 | 4.0s |
| 41–60 | 3.5s |
| 61–80 | 3.0s |
| 81–100 | 2.5s |

- Last manually drawn combination is what idles — updated whenever player draws a new one
- If no combination drawn yet: defaults to single Ignis auto-cast
- Speed bonus never fires during idle (can't measure draw time on automated cast)
- Counter bonus DOES apply during idle if the queued combination uses a counter pair

---

## Technical Notes

**Input handling:**
Use `IPointerDownHandler`, `IDragHandler`, `IPointerUpHandler`.
- PointerDown: check node collider overlap → register start node, record `drawStartTime`
- Drag: raycast each frame for node colliders → register newly entered nodes
- PointerUp: resolve sequence → lookup → fire → clear

**Combination lookup:**
```csharp
// Order-independent — sort before lookup
var key = new HashSet<RuneType>(sequence);
SpellData spell = subclassSpellTable.TryGetValue(key, out var s) ? s : defaultSpell;
```

**Speed multiplier:**
```csharp
float drawTime = Time.time - drawStartTime;
float speedMult = drawTime < 0.4f ? 1.5f
                : drawTime < 0.8f ? 1.25f
                : drawTime < 1.5f ? 1.0f : 0.85f;
```

**Mana / resource costs:**

| Depth | Cost | Notes |
|-------|------|-------|
| 1 rune | 5 mana | Lifebinder: 8 HP instead (no mana pool) |
| 2 rune | 10 mana | Lifebinder: 16 HP |
| 3 rune | 18 mana | Lifebinder: 28 HP |
| 4 rune | 28 mana | Lifebinder: see lifebinder-spec.md |
| Default weak spell | 2 mana | Lifebinder: 4 HP |

Lifebinder has `hasManaPool = false`; `GrimoireManager` routes resource deduction to HP.
Spell is blocked (default fires instead) if Lifebinder HP would fall to ≤ 1.

**Subclass lookup tables:**
`SpellcastingSubclass` enum on `GrimoireManager` → three lookup tables:
`RuneweaverSpells`, `SummonerSpells`, `LifebinderSpells`. Same input system, different output.

**No-crit enforcement:**
```csharp
if (currentGrimoire.path == GrimoirePath.Arcanist) {
    critChance = 0f;
    weakPointEnabled = false;
}
```

**PC/Steam:** Mouse drag replaces touch drag. Optional keyboard shortcuts 1–6 mapped to nodes.

---

*Path: `docs/runic-constellation-spec.md`*
