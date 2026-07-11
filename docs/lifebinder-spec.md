---
type: design-spec
version: 0.2
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Lifebinder Subclass Spec
### Version 0.2

> **Changes from v0.1:** All "Spellcasting level" references replaced with "Grimoire combat level".
> 4-rune spell table cross-checked against Lifebinder's 6-node layout
> (Ignis, Glacius, Tempest, Ventus, Vita, Lux):
> • Aegis of Dawn was `Glacius+Terra+Vita+Lux` — Terra is NOT in Lifebinder's constellation.
>   Replaced with `Glacius+Vita+Lux+Ventus` (Glacial Aegis — ice shield + heal + evasion).
> • Eternal Ward was `Vita+Lux+Terra+Glacius` — Terra again not in constellation.
>   Replaced with `Vita+Lux+Glacius+Ventus` (Frost Sanctuary — 0 damage 8s + HOT + evasion).

---

## Design Philosophy

The Lifebinder spends their own HP to heal — a genuine risk/reward loop. Too aggressive and they
die; too conservative and allies fall. Active management of own HP while keeping others alive is
the skill expression.

**Core principles:**
- No mana pool — HP is the casting resource
- Spell cost = Base × PowerMultiplier × (1 − WIL×0.003, max 30% reduction)
- Passive HP regen always active in combat
- HOTs self-applied to boost regen — earned, not free
- Spell cannot reduce Lifebinder HP below 1
- Largest HP pool of any Arcanist subclass (×1.6)
- 6 active nodes: Ignis, Glacius, Tempest, Ventus, Vita, Lux (no Umbra, no Terra)
- No crit system — skill expression is draw speed + counter knowledge

---

## HP as Casting Resource

```
Lifebinder HP = baseHP × 1.6
Spell HP Cost = baseCost × powerMultiplier × (1 − Mathf.Min(WIL × 0.003f, 0.30f))
```

Spell blocked (default fires instead) if cost would reduce HP to ≤ 1.

### Base HP Costs by Combination Depth

| Depth | Base cost | At WIL 50 (−15%) | At WIL 100 (−30%) |
|-------|-----------|-----------------|-------------------|
| 1 rune | 8 HP | 6.8 HP | 5.6 HP |
| 2 rune | 16 HP | 13.6 HP | 11.2 HP |
| 3 rune | 28 HP | 23.8 HP | 19.6 HP |
| HOT self-apply | 12 HP | 10.2 HP | 8.4 HP |

---

## HP Regen System

### Passive Base Regen (always active in combat)

```
Passive Regen = 3 HP/sec + (VIT × 0.08) + (WIL × 0.05)
```

| VIT 30, WIL 20 | VIT 50, WIL 40 | VIT 75, WIL 60 |
|----------------|----------------|----------------|
| ~6.4 HP/sec | ~9.0 HP/sec | ~11.0 HP/sec |

### HOTs — Boosted Regen

Self-applied only (drag thumb to self). Stack additively, no cap.

| HOT | Regen added | Duration | HP cost |
|-----|------------|---------|---------|
| Mending Touch (Vita) | +5 HP/sec | 8s | 8 HP |
| Rejuvenation (Vita + Ventus) | +10 HP/sec | 12s | 14 HP |
| Lifebloom (Vita + Lux) | +18 HP/sec | 10s | 20 HP |
| Sacred Renewal (Vita + Lux + Ventus) | +30 HP/sec | 15s | 28 HP |

```
Total Regen = Passive Regen + Sum(activeHOTs[i].regenRate)
```

Peak example: Passive 9.0 + Rejuvenation 10 + Lifebloom 18 = 37 HP/sec. Sustains aggressive
2-rune healing (16 HP cost) every 2s indefinitely.

---

## Targeting System

Draw constellation combination → drag thumb to target → release to fire.

| Target | Available spells |
|--------|----------------|
| Self | Self-heals, HOTs, defensive buffs |
| Ally | Heals, HOTs, shields, buffs |
| Enemy | Offensive only (very limited for Lifebinder) |

Releasing without dragging defaults to self.

---

## Constellation — Lifebinder Nodes

**Ignis, Glacius, Tempest, Ventus, Vita, Lux**

Umbra is absent — the node does not appear on screen. No blocking logic needed.
Terra is absent — no stagger, no armor break.

---

## Spell Library

### 1-Rune (Combat Level 1+)

| Node | Spell | Effect | Target | HP Cost |
|------|-------|--------|--------|---------|
| Vita | Mend | Restore 12% max HP | Self/ally | 8 |
| Lux | Radiance | Remove one debuff | Self/ally | 8 |
| Ventus | Tailwind | +15% evasion 5s | Self/ally | 8 |
| Glacius | Frost Ward | Reduce next hit by 20% | Self/ally | 8 |
| Tempest | Static Field | Minor damage + party evasion +5% | Enemy | 8 |
| Ignis | Cauterize | Remove bleed/burn DoT immediately | Self/ally | 8 |

### 2-Rune (Combat Level 16+)

| Combination | Spell | Effect | Target | HP Cost |
|------------|-------|--------|--------|---------|
| Vita + Vita | Greater Mend | Restore 25% max HP | Self/ally | 16 |
| Vita + Lux | Radiant Heal | Restore 20% HP + remove all debuffs | Self/ally | 18 |
| Vita + Ventus | Mending Wind | Apply Rejuvenation HOT (+10/sec, 12s) | Self/ally | 14 |
| Vita + Glacius | Glacial Shield | 15% HP restore + absorb next 2 hits | Self/ally | 18 |
| Lux + Lux | Holy Light | Remove all debuffs + minor heal | Self/ally | 16 |
| Lux + Ventus | Divine Wind | AoE debuff cleanse — all party | All allies | 22 |
| Ventus + Vita | Lifebloom | Apply Lifebloom HOT (+18/sec, 10s) | Self | 20 |
| Glacius + Vita | Ice Cocoon | Target takes 0 damage 3s | Ally | 20 |
| Ignis + Vita | Cauterizing Wave | Heal + remove all burn/bleed DoTs | Self/ally | 16 |
| Tempest + Lux | Holy Storm | Minor damage all enemies + party evasion +10% | Enemies/all | 20 |
| Vita + Ignis | (same as Ignis + Vita — order-independent) | — | — | — |

### 3-Rune (Combat Level 42+)

| Combination | Spell | Effect | Target | HP Cost |
|------------|-------|--------|--------|---------|
| Vita + Lux + Ventus | Sacred Renewal | Apply Sacred Renewal HOT (+30/sec, 15s) | Self | 28 |
| Vita + Vita + Lux | Mass Restoration | Restore 20% HP to ALL party | All allies | 35 |
| Lux + Lux + Vita | Holy Aegis | Party-wide shield absorbing 20% max HP | All allies | 38 |
| Vita + Ventus + Lux | Ascendant Heal | Restore 35% HP + HOT + evasion | Single ally | 32 |
| Vita + Vita + Vita | Life Surge | Restore 50% max HP — biggest single heal | Single ally | 40 |
| Lux + Ventus + Glacius | Frost Aegis | +20% defense all allies + evasion + slow nearby | All allies | 36 |
| Vita + Glacius + Lux | Sanctuary | +30% defense + 15% HP + remove debuffs | Single ally | 30 |
| Lux + Ventus + Ignis | Cleansing Flame | Remove all DoTs all allies + party regen +15/sec 10s | All allies | 42 |

### 4-Rune (Combat Level 88+)

> All four runes in each combo verified against Lifebinder's 6-node layout
> (Ignis, Glacius, Tempest, Ventus, Vita, Lux).

| Combination | Spell | Effect | HP Cost |
|------------|-------|--------|---------|
| Vita + Lux + Ventus + Ignis | Phoenix Wave | Revive from death if cast below 20% HP — once per dungeon | 58 |
| Vita + Vita + Lux + Lux | Mass Miracle | Restore 40% HP all party + remove all debuffs | 65 |
| Vita + Lux + Ventus + Glacius | Glacial Aegis | Full heal one ally + ice cocoon 8s + HOT + evasion | 50 |
| Vita + Lux + Glacius + Ventus | Frost Sanctuary | One ally takes 0 damage 8s + HOT + evasion buff | 52 |

---

## Counter Pairs (Lifebinder)

| Pair | Bonus |
|------|-------|
| Ignis ↔ Glacius | ×1.25 damage |
| Tempest ↔ Ventus | ×1.25 damage |
| Vita + Lux | ×1.3 heal bonus (amplifier, not counter) |

---

## Solo Survivability

Lifebinder is slow to kill enemies but nearly unkillable at appropriate zone tier through regen:

```
Max regen = 11 HP/sec (VIT 75, WIL 60 passive) + 30 HP/sec (Sacred Renewal) = 41 HP/sec
```

Against Tier 3 enemy: ~10 damage/sec average → Lifebinder net-positive 31 HP/sec.
Solo recommendation: stay one zone tier below combat level for comfortable farming.

---

## Group Role

Without a Lifebinder, parties rely on Cookery meals (limited). With one, parties can push higher
tiers than they could solo.

**Raid healing priority:**
1. HOTs on tank proactively
2. Emergency heal when any ally drops below 30% HP
3. Mass Restoration when multiple allies low
4. Holy Aegis before boss phase transition
5. Self-HOT if own HP drops below 40% — dead Lifebinder heals nobody

---

## Aggro Generation

| Action | Aggro multiplier |
|--------|----------------|
| Healing an ally | ×0.4 of heal amount |
| HOT tick | ×0.2 per tick |
| Offensive spell | ×0.8 |
| Mass heal | ×0.6 of total |
| Lifebinder passive | ×0.3/sec |

---

## Idle Behaviour

| Situation | Idle action |
|-----------|------------|
| Solo | Auto-applies Mending Touch HOT to self every 8s; auto-casts Mend when below 50% HP |
| Group | Auto-casts Mend on lowest-HP ally every 4s |
| All | Passive regen always active |
| Note | HOTs are NOT auto-applied to allies — only manual targeting does that |

---

## Technical Notes

**HP as resource:**
```csharp
bool CanCast(float hpCost) => currentHP > hpCost + 1f;

void CastSpell(SpellData spell, GameObject target) {
    float cost = spell.baseHPCost * spell.powerMultiplier
                 * (1f - Mathf.Min(willpower * 0.003f, 0.30f));
    if (!CanCast(cost)) { FireDefaultSpell(); return; }
    currentHP -= cost;
    ApplySpellEffect(spell, target);
}
```

**Regen:**
```csharp
float GetCombatRegen() =>
    3f + (vitality * 0.08f) + (willpower * 0.05f)
    + activeHOTs.Where(h => h.IsActive).Sum(h => h.regenRate);

void Update() {
    if (inCombat)
        currentHP = Mathf.Min(maxHP, currentHP + GetCombatRegen() * Time.deltaTime);
}
```

**GrimoireManager setup:**
```csharp
// When Lifebinder equipped:
maxHP = baseHP * 1.6f;
hasManaPool = false;
hasLifebinderRegen = true;
activeNodes = new[] { Ignis, Glacius, Tempest, Ventus, Vita, Lux };
// Umbra node NOT rendered — not in this subclass's constellation
```

**No crit:**
```csharp
if (currentGrimoire.path == GrimoirePath.Arcanist) { critChance = 0f; weakPointEnabled = false; }
```

---

*Path: `docs/lifebinder-spec.md`*
