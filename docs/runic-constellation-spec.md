---
type: design-spec
version: 0.3
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Runic Constellation Mechanic
### Version 0.4

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
1. Place finger on starting node — activates, records as first in sequence
2. Drag to next node — connection line draws in real time, node added to sequence
3. Continue to additional nodes (up to 4) — nodes can be revisited for Technique sequences
4. Lift finger — spell fires instantly based on exact draw order

### Order-Dependent — All Spells

Every spell and Technique has one canonical draw pattern. Order matters for all combinations — `Ignis→Glacius` and `Glacius→Ignis` are two different spells. Players learn specific patterns; muscle memory and speed bonuses reward mastery.

**Why order-dependent:**
- Consistent rules — one system applies everywhere, no "it depends"
- Doubles the spell library — same rune pair drawn in opposite directions produces different effects
- Enables Technique sequences that revisit nodes (e.g. Storm Caller: Tempest→Ventus→Tempest→Ignis)
- Speed bonuses reward players who have internalized patterns

### Connection Rules
- Must start on a node — empty-space drag does nothing
- Drag must reach a node to register it — hover doesn't count
- Nodes CAN be revisited — drag back through a previously connected node to add it again
- Minimum 1 node (tap and release) — fires single-rune spell
- Maximum 4 nodes — hard cap
- Lifting finger at any point fires whatever sequence has been built

### Canonical Draw Patterns

Each spell has one correct draw order. Spells are defined as ordered sequences in `SpellData`:

```csharp
public class SpellData : ScriptableObject {
    public RuneType[] sequence;  // ordered — [Ignis, Glacius] ≠ [Glacius, Ignis]
    public string lookupKey;     // "IGN-GLA" — generated from sequence on import
}
```

**Lookup key generation:**
```csharp
string GetLookupKey(List<RuneType> sequence) =>
    string.Join("-", sequence.Select(r => r.ToString().Substring(0, 3).ToUpper()));
// [Ignis, Glacius]         → "IGN-GLA"
// [Glacius, Ignis]         → "GLA-IGN"  (different spell)
// [Tempest, Ventus, Tempest, Ignis] → "TMP-VNT-TMP-IGN"  (Storm Caller)
```

**Lookup on finger lift:**
```csharp
void OnFingerLifted() {
    string key = GetLookupKey(currentSequence);
    SpellData spell = subclassSpellTable.TryGetValue(key, out var s)
                    ? s
                    : defaultWeakSpell; // unknown pattern → weak Ignis blast
    FireSpell(spell);
    lastUsedSequence = new List<RuneType>(currentSequence);
    currentSequence.Clear();
}
```

### Invalid Patterns
- Unrecognised draw order → fires default weak spell (40% potency Ignis blast)
- Visual: brief "?" flash before default fires
- Resource cost: standard single-rune cost — never hard-blocked

### Speed Bonus
Measured from first node contact to finger lift:

| Draw Time | Speed Tier | Damage Modifier |
|-----------|-----------|----------------|
| < 0.4s | Lightning | ×1.5 |
| 0.4–0.8s | Swift | ×1.25 |
| 0.8–1.5s | Standard | ×1.0 |
| > 1.5s | Slow | ×0.85 |

Speed bonus applies to damage spells only. Healing spells (Lifebinder) unaffected.
Knowing the canonical order lets players draw faster — order-dependency directly
rewards pattern mastery through the speed bonus system.

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

> **Order matters for all spells.** Every entry has one canonical draw pattern.
> The same runes drawn in a different order are a different spell.
> Target: ~20–24 spells per subclass — learnable, not encyclopedic.

---

### Design Model — Shared + Subclass-Specific

All Arcanist subclasses share a **common spell foundation** — spells unlocked at
the same Grimoire combat levels regardless of subclass. On top of that foundation,
each subclass has **4–6 unique spells** that unlock at key levels and reflect
that subclass's identity.

```
Shared foundation (all subclasses):
  - All 8 single-rune spells
  - 5 shared 2-rune spells
  - 4 shared 3-rune spells

Subclass-specific (replaces/supplements at key levels):
  - 3 subclass 2-rune spells
  - 4 subclass 3-rune spells
  - 4-rune mastery spells (subclass-only)

Total per subclass: ~24 spells
```

---

### Single Rune (Grimoire Combat Level 1 — all subclasses)

Every Arcanist subclass gets all 8 single-rune spells from day one.
Only the 6 nodes active in that subclass render — the other 2 simply don't appear.

| Draw | Spell | Effect |
|------|-------|--------|
| Ignis | Ember Shot | Fire damage + 2s burn DoT |
| Glacius | Frost Bolt | Ice damage + minor slow |
| Tempest | Spark | Lightning damage |
| Terra | Stone Throw | Earth damage + minor stagger |
| Ventus | Gust | Wind damage + small pushback |
| Vita | Mend | Restore 8% max HP |
| Umbra | Shadow Dart | Shadow damage + 10% weaken |
| Lux | Flash | Light damage + 1s blind |

---

### 2-Rune Combinations

#### Shared 2-Rune Spells (all subclasses, Grimoire Combat Level 16)

Five spells every Arcanist subclass learns at level 16 — the core toolkit.

| Draw Order | Spell | Effect | Notes |
|-----------|-------|--------|-------|
| Ignis → Glacius | Steam Burst | AoE fire+ice damage + blind | Introduces counter system |
| Umbra → Lux | Twilight Surge | Counter-element burst — highest base 2-rune damage | Runeweaver ×1.75 bonus |
| Tempest → Ventus | Cyclone | Chain lightning + pushback | Crowd control |
| Glacius → Tempest | Blizzard Strike | Ice + shock + accuracy down | Debuff tool |
| Ignis → Ventus | Flame Vortex | Spin damage + burn spread | DoT tool |

#### Runeweaver 2-Rune Spells

| Draw Order | Spell | Unlocks | Effect |
|-----------|-------|---------|--------|
| Glacius → Ignis | Frostfire | Level 16 | Single target — heavy damage + burn + chill simultaneously |
| Tempest → Umbra | Shadow Bolt | Level 24 | Heavy damage + accuracy down |
| Lux → Umbra | Eclipse Strike | Level 44 | Counter-element — blind + massive weaken (reverse Twilight Surge) |

#### Summoner 2-Rune Spells (command-based)

| Draw Order | Spell | Unlocks | Effect |
|-----------|-------|---------|--------|
| Terra → Ignis | Siege Formation | Level 16 | Golem advances + Sprite follows — focused assault command |
| Umbra → Tempest | Void Chain | Level 24 | Void Shade + Storm Wisp — debuff + chain all targets |
| Terra → Glacius | Frozen Vanguard | Level 44 | Golem taunts + Frost Shard slows all targeting it |

#### Lifebinder 2-Rune Spells (healing-based)

| Draw Order | Spell | Unlocks | Effect | HP Cost |
|-----------|-------|---------|--------|---------|
| Vita → Lux | Radiant Heal | Level 16 | Restore 20% HP + remove all debuffs | 18 HP |
| Vita → Ventus | Mending Wind | Level 24 | Apply Rejuvenation HOT (+10 HP/sec, 12s) | 14 HP |
| Glacius → Vita | Glacial Shield | Level 44 | 15% HP restore + absorb next 2 hits | 18 HP |

---

### 3-Rune Combinations

**Runeweaver:** unlocks at Grimoire combat level 35 (earlier than standard 42)
**Summoner + Lifebinder:** unlocks at Grimoire combat level 42

#### Shared 3-Rune Spells (all subclasses, Combat Level 42; Runeweaver: 35)

Four spells every Arcanist subclass learns — the foundation of 3-rune mastery.

| Draw Order | Spell | Effect |
|-----------|-------|--------|
| Ignis → Tempest → Ventus | Inferno Cyclone | Massive fire AoE + burn field 8s |
| Umbra → Lux → Tempest | Eclipse Storm | Counter-element chain — Umbra↔Lux bonus + chain lightning |
| Glacius → Tempest → Lux | Frozen Arc | Freeze + chain + blind — triple control |
| Tempest → Ventus → Ignis | Storm Surge | Pushback all enemies + ignites them on landing |

#### Runeweaver 3-Rune Spells

| Draw Order | Spell | Unlocks | Effect |
|-----------|-------|---------|--------|
| Ignis → Glacius → Tempest | Elemental Triad | Level 35 | Three-element burst — heavy single-target + all three DoTs |
| Glacius → Ignis → Lux | Frostfire Nova | Level 55 | Counter-element burst — fire/ice + light explosion, peak damage |
| Umbra → Ignis → Ventus | Darkfire Gale | Level 70 | Shadow DoT + burn + scatter — weaken, burn, push all at once |
| Lux → Umbra → Tempest | Twilight Thunder | Level 85 | Counter-element into chain — eclipse then chain all targets |

#### Summoner 3-Rune Spells (construct commands)

| Draw Order | Spell | Unlocks | Effect |
|-----------|-------|---------|--------|
| Ignis → Tempest → Terra | Trinity Assault | Level 42 | Sprite + Wisp + Golem burst single target simultaneously |
| Umbra → Glacius → Tempest | Total Debilitation | Level 55 | Accuracy down + slow + chain — maximum control command |
| Terra → Ignis → Umbra | Siege of Shadows | Level 70 | Golem tanks, Sprite damages, Shade debuffs — full synergy |
| Ignis → Tempest → Glacius | Elemental Triad | Level 85 | Three-element construct burst command |

#### Lifebinder 3-Rune Spells

| Draw Order | Spell | Unlocks | Effect | HP Cost |
|-----------|-------|---------|--------|---------|
| Vita → Lux → Ventus | Sacred Renewal | Level 42 | HOT +30 HP/sec for 15s — peak self-sustain | 28 HP |
| Lux → Lux → Vita | Holy Aegis | Level 55 | Party-wide shield absorbing 20% max HP each | 38 HP |
| Vita → Vita → Vita | Life Surge | Level 70 | Restore 50% max HP to single target | 40 HP |
| Lux → Ventus → Ignis | Cleansing Flame | Level 85 | Remove all DoTs all allies + party regen +15/sec 10s | 42 HP |

---

### 4-Rune Combinations (Grimoire Combat Level 88 — all subclasses)

The mastery tier. All four runes must be drawn manually in sequence.
Each subclass has 1–2 unique 4-rune spells.

| Draw Order | Spell | Subclass | Effect |
|-----------|-------|---------|--------|
| Tempest → Ventus → Tempest → Ignis | Storm Caller | Runeweaver | Sustained storm field 15s — AoE damage all enemies |
| Ignis → Glacius → Umbra → Lux | Void Sundering | Runeweaver | Counter-chain — fire/ice into shadow/light, peak single-target |
| Terra → Umbra → Glacius → Tempest | Runic Collapse | Summoner | Stagger + freeze + chain + weaken all — construct AoE command |
| Ignis → Tempest → Ventus → Umbra | Phantom Inferno | Summoner | Fire + chain + scatter + void — all constructs AoE burst |
| Vita → Lux → Ventus → Ignis | Phoenix Wave | Lifebinder | Revive from defeat if cast below 20% HP — once per dungeon |
| Vita → Vita → Lux → Lux | Mass Miracle | Lifebinder | 40% HP all party + remove all debuffs — 10min cooldown |

---

### Spell Count Summary

| Depth | Shared | Runeweaver | Summoner | Lifebinder |
|-------|--------|-----------|---------|-----------|
| 1-rune | 8 | 8 | 8 | 8 |
| 2-rune | 5 | 5+3=8 | 5+3=8 | 5+3=8 |
| 3-rune | 4 | 4+4=8 | 4+4=8 | 4+4=8 |
| 4-rune | 0 | 2 | 2 | 2 |
| **Total** | — | **26** | **26** | **26** |

26 spells per subclass — all learnable, all meaningful, no filler.

---

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

**Combination lookup — order-dependent string key:**
```csharp
// Build key from ordered sequence
string key = string.Join("-",
    currentSequence.Select(r => r.ToString().Substring(0, 3).ToUpper()));
// [Ignis, Glacius]                    → "IGN-GLA"
// [Glacius, Ignis]                    → "GLA-IGN"  (different spell)
// [Tempest, Ventus, Tempest, Ignis]  → "TMP-VNT-TMP-IGN"  (Storm Caller)

SpellData spell = subclassSpellTable.TryGetValue(key, out var s)
                ? s : defaultWeakSpell;
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
