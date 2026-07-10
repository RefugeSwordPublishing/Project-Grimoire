# ⚔️ Project Grimoire — Lifebinder Subclass Spec
### Version 0.1

---

## 📐 Design Philosophy

The Lifebinder is a healer unlike any other — they spend their own HP to cast healing spells, sustained by passive regen and self-applied Heals over Time. This creates a genuinely unique risk/reward loop: a Lifebinder who heals too aggressively depletes their own HP and dies. One who plays too conservatively lets allies fall. Active management of your own HP while keeping others alive is the skill expression.

**Core principles:**
- No mana pool — HP is the casting resource
- Spell cost scales with power (stronger heals cost more HP) reduced by WIL stat
- Passive HP regen always active in combat — base sustain floor
- HOTs (Heals over Time) self-applied to boost regen above the passive floor — earned, not free
- Largest HP pool of any Arcanist subclass — VIT investment critical
- Very low personal damage — designed for group content, uniquely durable solo through regen
- Umbra node NOT in Lifebinder constellation — position 5 is Vita, position 6 is Lux. Umbra is fully absent, not just blocked
- Targeting mechanic: draw constellation combination → drag thumb to target (self or ally)

---

## 💚 HP as Casting Resource

### HP Pool
```
Lifebinder HP = Normal Arcanist HP × 1.6
```
Lifebinder has the largest HP pool of any Arcanist subclass — necessary to sustain spell costs. VIT investment amplifies this further.

### Spell Cost Formula
```
Spell HP Cost = Base Cost × Power Multiplier × (1 - WIL Reduction)
WIL Reduction = WIL × 0.003 (max 30% reduction at WIL 100)
```

This means:
- High WIL Lifebinder pays significantly less HP per cast
- Low WIL Lifebinder must manage HP more carefully
- Natural build tension: VIT for larger HP pool vs WIL for cheaper casts

### Spell Cannot Kill
A spell that would reduce Lifebinder HP to 0 is blocked — minimum 1 HP remains after any cast. The Lifebinder cannot accidentally kill themselves through healing. They CAN be killed by enemy damage while at low HP.

### Base HP Costs by Combination Depth
| Combination | Base HP Cost | At WIL 50 (-15%) | At WIL 100 (-30%) |
|------------|-------------|-----------------|------------------|
| 1-rune | 8 HP | 6.8 HP | 5.6 HP |
| 2-rune | 16 HP | 13.6 HP | 11.2 HP |
| 3-rune | 28 HP | 23.8 HP | 19.6 HP |
| HOT self-apply | 12 HP | 10.2 HP | 8.4 HP |

---

## 💫 HP Regen System

### Passive Base Regen
Always active during combat — the Lifebinder's sustain floor:
```
Passive Regen = 3 HP/sec + (VIT × 0.08) + (WIL × 0.05)
```

| VIT 30, WIL 20 | VIT 50, WIL 40 | VIT 75, WIL 60 |
|----------------|----------------|----------------|
| ~6.4 HP/sec | ~9.0 HP/sec | ~11.0 HP/sec |

This base regen allows a Lifebinder to cast basic heals indefinitely without depleting — the floor is designed so casual play is always sustainable.

### HOT (Heal over Time) — Boosted Regen
Self-applied HOTs stack on top of passive regen, creating a boosted window:

```
Total Regen During HOT = Passive Regen + HOT Regen Rate
```

HOTs must be actively drawn and cast on self (drag thumb to own character). They are not passive — the Lifebinder earns their boosted sustain through active self-care.

| HOT Type | Regen Rate Added | Duration | HP Cost to Apply |
|----------|-----------------|---------|-----------------|
| Mending Touch (Vita) | +5 HP/sec | 8s | 8 HP |
| Rejuvenation (Vita + Ventus) | +10 HP/sec | 12s | 14 HP |
| Lifebloom (Vita + Lux) | +18 HP/sec | 10s | 20 HP |
| Sacred Renewal (Vita + Lux + Ventus) | +30 HP/sec | 15s | 28 HP |

**HOT stacking:** Multiple HOTs stack additively. A Lifebinder with Rejuvenation + Lifebloom active regens at:
```
Passive (9.0) + Rejuvenation (10) + Lifebloom (18) = 37 HP/sec
```
At 37 HP/sec they can sustain aggressive 2-rune healing (16 HP cost) on a 2-second rotation indefinitely — the peak of an optimized active Lifebinder loop.

---

## 🎮 Targeting System — Draw Then Drag

The Lifebinder uses the universal Arcanist targeting mechanic:

1. Draw the constellation combination as normal
2. **Drag thumb to the intended target** before releasing
3. Spell fires at that target on release

**Valid targets:**
- Self — self-heals, HOT application, defensive buffs
- Ally (party member) — heals, HOTs, shields, buffs
- Enemy — offensive spells only (very limited for Lifebinder)

**Target indicator:**
- As thumb drags toward a target, a golden tether line connects from the last rune to the target
- Target glows briefly — confirms selection before release
- Releasing without dragging to a target defaults to self

This targeting system applies universally to all Arcanist subclasses — Runeweaver drags to enemies for single target vs AoE, Summoner drags to specific constructs for precise commands.

---

## ✨ Spell Library — Lifebinder

### 1-Rune Spells (Spellcasting 1+)

| Node | Spell | Effect | Target | HP Cost |
|------|-------|--------|--------|---------|
| Vita | Mend | Restore 12% max HP | Self or ally | 8 HP |
| Lux | Radiance | Remove one debuff | Self or ally | 8 HP |
| Ventus | Tailwind | +15% evasion for 5s | Self or ally | 8 HP |
| Terra | Earthen Skin | +10% defense for 6s | Self or ally | 8 HP |
| Glacius | Frost Ward | Reduce next hit by 20% | Self or ally | 8 HP |
| Tempest | Static Field | Minor damage + ally evasion +5% | Enemy | 8 HP |
| Umbra | *(Not in Lifebinder constellation — Vita occupies position 5 instead)* | — | — | — |
| Ignis | Cauterize | Stop bleed/burn DoT immediately | Self or ally | 8 HP |

### 2-Rune Spells (Spellcasting 16+)

| Combination | Spell | Effect | Target | HP Cost |
|------------|-------|--------|--------|---------|
| Vita + Vita | Greater Mend | Restore 25% max HP | Self or ally | 16 HP |
| Vita + Lux | Radiant Heal | Restore 20% HP + remove all debuffs | Self or ally | 18 HP |
| Vita + Ventus | Mending Wind | Apply Rejuvenation HOT (+10 HP/sec, 12s) | Self or ally | 14 HP |
| Vita + Terra | Stone Mend | Restore 15% HP + +15% defense 8s | Self or ally | 16 HP |
| Vita + Glacius | Glacial Shield | 15% HP restore + absorb next 2 hits | Self or ally | 18 HP |
| Lux + Lux | Holy Light | Remove all debuffs + minor heal | Self or ally | 16 HP |
| Lux + Ventus | Divine Wind | AoE debuff cleanse — all party members | All allies | 22 HP |
| Lux + Terra | Sacred Ground | +20% defense for all nearby allies, 6s | All allies | 24 HP |
| Ventus + Vita | Lifebloom | Apply Lifebloom HOT (+18 HP/sec, 10s) | Self | 20 HP |
| Terra + Vita | Fortify | +25% max HP temporarily for 10s | Self or ally | 18 HP |
| Glacius + Vita | Ice Cocoon | Target takes 0 damage for 3s (cocoon) | Ally | 20 HP |
| Ignis + Vita | Cauterizing Wave | Heal + remove all burn/bleed DoTs | Self or ally | 16 HP |
| Tempest + Lux | Holy Storm | Minor damage all enemies + party evasion +10% | Enemies/allies | 20 HP |

### 3-Rune Spells (Spellcasting 42+)

| Combination | Spell | Effect | Target | HP Cost |
|------------|-------|--------|--------|---------|
| Vita + Lux + Ventus | Sacred Renewal | Apply Sacred Renewal HOT (+30 HP/sec, 15s) | Self | 28 HP |
| Vita + Vita + Lux | Mass Restoration | Restore 20% HP to ALL party members | All allies | 35 HP |
| Vita + Lux + Terra | Sanctuary | +30% defense + heal 15% HP + remove debuffs | Single ally | 30 HP |
| Lux + Lux + Vita | Holy Aegis | Party-wide shield absorbing 20% max HP damage | All allies | 38 HP |
| Vita + Ventus + Lux | Ascendant Heal | Restore 35% HP + HOT + evasion buff | Single ally | 32 HP |
| Vita + Terra + Glacius | Bulwark of Life | +40% defense + 0 damage for 4s + heal | Single ally | 34 HP |
| Vita + Vita + Vita | Life Surge | Restore 50% max HP — Lifebinder's biggest single heal | Single ally | 40 HP |
| Lux + Ventus + Terra | Divine Formation | Party-wide +20% defense + evasion + debuff immunity 8s | All allies | 42 HP |

### 4-Rune Signature Spells (Spellcasting 88+)

| Combination | Spell | Effect | HP Cost |
|------------|-------|--------|---------|
| Vita + Lux + Ventus + Terra | Phoenix Embrace | Fully restore one ally's HP + apply all HOTs + 10s immunity | 55 HP |
| Vita + Vita + Lux + Lux | Mass Miracle | Restore 40% HP to ALL party members + remove all debuffs | 65 HP |
| Vita + Lux + Terra + Glacius | Eternal Ward | One ally takes 0 damage for 8s + HOT | 50 HP |
| Vita + Ventus + Lux + Ignis | Cleansing Fire | All DoTs removed from all allies + party regen +15 HP/sec for 10s | 58 HP |

---

## 🧘 Solo Survivability

Despite low damage, the Lifebinder is uniquely durable in solo content through regen:

**Solo combat loop:**
1. Apply Sacred Renewal HOT to self (28 HP cost → +30 HP/sec for 15s)
2. Cast Terra on self for defense buff
3. Auto-attack enemies minimally — damage output is low but steady
4. HOT regens HP back faster than enemies deal damage at appropriate zone tier
5. Re-apply HOT before it expires — the rhythm of solo Lifebinder play

**Zone tier recommendation for solo:**
Lifebinder should stay one tier below their combat level — they can technically survive higher zones but kills are slow. In a raid or dungeon context they're invaluable. Solo farming is best at comfortable zones where regen outpaces damage.

**Self-heal ceiling:**
A fully optimized solo Lifebinder with Sacred Renewal + passive regen:
```
Max regen = 11 HP/sec (passive at VIT 75, WIL 60) + 30 HP/sec (Sacred Renewal) = 41 HP/sec
```
Against a Tier 3 enemy dealing 20 damage/hit every 2 seconds (10 damage/sec average) — the Lifebinder regens faster than they take damage. Effectively unkillable at appropriate tier.

---

## 👥 Group Role

In dungeons and raids the Lifebinder is the backbone — without them parties rely on Cookery meals for limited healing. With a Lifebinder active, parties can push higher tier content than they could solo.

**Raid healing priority:**
1. Monitor party HP via the party frame
2. Apply HOTs to the tank (Warlord/Bulwark) proactively
3. Emergency heals (Vita + Vita) to whoever drops below 30% HP
4. Mass Restoration (Vita + Vita + Lux) when multiple allies are low
5. Holy Aegis (Lux + Lux + Vita) before a known boss phase transition

**Managing own HP during group healing:**
The Lifebinder's biggest skill challenge in raids — balancing aggressive healing against own HP depletion:
- Apply Sacred Renewal to self at raid start — covers most of the session
- If HP drops below 40%: prioritize self-HOT before continuing party heals
- Emergency: Vita + Vita on self at 20% HP to recover before resuming
- A Lifebinder who dies cannot heal — self-preservation is part of the skill

---

## 📊 Aggro Generation

| Action | Aggro Generated |
|--------|----------------|
| Healing an ally | Low — ×0.4 of heal amount |
| HOT tick (per tick) | Very Low — ×0.2 per tick |
| Offensive spell (Tempest, Ignis) | Standard — ×0.8 |
| Mass heal (all allies) | Moderate — ×0.6 of total heal |
| Lifebinder personal aggro rate | ×0.3 passive |

Healing generates less aggro than damage in standard MMO convention — Lifebinder rarely pulls enemies off the tank unless healing extremely aggressively.

---

## 💤 Idle Behavior

| Activity | Idle Action |
|----------|------------|
| Solo combat | Auto-applies Mending Touch HOT to self every 8s, auto-casts Mend on self when below 50% HP |
| Group combat | Auto-casts Mend on lowest HP ally every 4s |
| Both | Passive regen always active — base sustain maintained |
| Special | No HOTs applied to others during idle — only manual targeting applies HOTs to allies |

Idle Lifebinder in a group provides basic triage healing — enough to prevent party wipes from routine damage. Active Lifebinder provides proactive HOTs, shields, and mass heals that dramatically increase party survivability.

---

## 🔧 Technical Notes for Implementation

**HP as resource:**
```csharp
bool CanCast(float hpCost) {
    return currentHP > hpCost + 1f; // Always leave 1 HP
}

void CastSpell(SpellData spell, GameObject target) {
    float cost = spell.baseHPCost * spell.powerMultiplier * 
                 (1f - Mathf.Min(willpower * 0.003f, 0.30f));
    if (!CanCast(cost)) return;
    currentHP -= cost;
    ApplySpellEffect(spell, target);
}
```

**Regen system:**
```csharp
float GetCombatRegen() {
    float passive = 3f + (vitality * 0.08f) + (willpower * 0.05f);
    float hotBonus = activeHOTs.Sum(h => h.regenRate);
    return passive + hotBonus;
}

void Update() {
    if (inCombat) {
        currentHP = Mathf.Min(maxHP, currentHP + GetCombatRegen() * Time.deltaTime);
    }
}
```

**HOT management:**
```csharp
class HOTEffect {
    string hotId;
    float regenRate;
    float duration;
    float elapsed;
    bool IsActive => elapsed < duration;
}

List<HOTEffect> activeHOTs = new List<HOTEffect>();
// Multiple HOTs stack additively — no cap
```

**Targeting system (universal Arcanist):**
```csharp
// After constellation draw completes:
void OnConstellationComplete(List<RuneNode> sequence) {
    SpellData spell = LookupSpell(sequence);
    StartTargetingMode(spell); // Show tether line
}

void OnTargetSelected(GameObject target) {
    if (IsValidTarget(currentSpell, target)) {
        CastSpell(currentSpell, target);
    }
}
// No target drag = default to self for Lifebinder
```

**Subclass HP pool:**
```csharp
// In GrimoireManager when Lifebinder equipped:
maxHP = baseHP * 1.6f;
hasManaPool = false;
hasLifebinderRegen = true;
```

**Umbra not present:**
Umbra is not an active node in the Lifebinder constellation — position 5 is Vita, position 6 is Lux. The node does not appear on screen at all for Lifebinder players. No blocking logic needed — the node simply does not exist in the Lifebinder layout.

```csharp
// In GrimoireManager when Lifebinder equipped:
// activeNodes = new[] { Ignis, Glacius, Tempest, Ventus, Vita, Lux };
// Umbra node hidden from constellation UI entirely
```

---

*Document version 0.1 — Lifebinder Subclass Spec*
*Next: Phase 2 zone design · Runic Constellation attunement data · Phase 2 handoff*
