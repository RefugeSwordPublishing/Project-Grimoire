---
type: design-spec
version: 0.2
updated: 2026-07-11
---

# Project Grimoire, Consumables Spec
### Version 0.1

---

## Resource Model, Final Decision

This spec resolves the contradiction between the design doc (WIL → mana pool) and the
Lifebinder spec (HP is the casting resource, no mana).

### Resources in Combat

| Resource | Who has it | What depletes it | What restores it |
|----------|-----------|-----------------|-----------------|
| **HP** | All classes | Enemy damage; Lifebinder spell costs | Healing Draughts (combat hotbar), Cookery meals (stat regen), Lifebinder HOTs, idle auto-eat |
| **Mana** | Arcanist (Runeweaver, Summoner) only | Spell casts, construct summons | Mana Vials (combat hotbar), Cookery meals (mana regen) |
| **Stamina** | Vanguard only | 2-input and 3-input combos during active play | Passive regen always active; Endurance Draughts (hotbar); Cookery meals |

**Stamina is Vanguard-exclusive and idle-safe.** During idle auto-combat the system only
uses basic Strike (0 stamina cost), stamina is never depleted or managed during idle
sessions. It only becomes relevant during active play, acting as a burst resource that
limits how many high-cost combos can be chained before falling back to singles.

At 0 stamina the Vanguard falls back to single Strike, same behaviour as idle. Never
hard-locked, always degrading gracefully.

### Stamina Pool

```
Max Stamina = 30 + (VIT × 1.5)
Stamina Regen = 2/sec passive (always active in combat)
             + 4/sec bonus when no combo input for 3+ seconds
             + 4/sec additional out of combat entirely
```

| VIT | Max Stamina | Combat regen | Notes |
|-----|------------|-------------|-------|
| 10 | 45 | 2/sec | Early game, ~3 three-input combos |
| 30 | 75 | 2/sec | Mid game, ~4 three-input combos |
| 60 | 120 | 2/sec | Late game, ~6 three-input combos |
| 100 | 180 | 2/sec | Max VIT, sustained combo chains possible |

### Stamina Costs (Vanguard only)

| Combo depth | Stamina cost | Notes |
|------------|-------------|-------|
| 1-input (Strike/Guard/Surge alone) | 0 | Always free, idle fallback |
| 2-input | 8 | Standard combo cost |
| 3-input | 18 | Full combo, premium cost |

**Idle auto-combat:** Always uses 1-input Strike. Stamina never depletes during idle.
**Active play:** Player manages stamina as a burst resource, chain combos, let singles
regen, burst again. The natural rhythm of the 1.5s auto-fire timer aligns with this.

### Mana Pool, Arcanist (not Lifebinder)

```
Max Mana = 50 + (WIL × 2)
Mana Regen = 1.0/sec base (out of combat only, no in-combat mana regen)
```

Runeweaver and Summoner draw from this pool. Lifebinder has `hasManaPool = false`, 
no mana bar rendered, no mana costs applied, HP is the resource instead.

**[pending]** Mana pool not yet implemented. `ItemData` mana effect fields not yet added.

---

## Consumable Categories

Two buckets, each with different use rules:

| Category | Use location | When | Examples |
|----------|-------------|------|---------|
| **Instant-use** | Combat hotbar | Anytime, including active combat | Healing Draught, Mana Vial, Antidote |
| **Buff-use** | Inventory page only | Outside active combat | All Cookery meals and stews, Poison Coating |

This keeps the combat screen clean, only items with immediate single-use impact appear
in the hotbar. Buffs require a deliberate pause to apply, preventing mid-fight spam.

---

## Combat Hotbar

**[pending]** Not yet built. Sits at the bottom of the `ZoneCombatView` screen above the
class-specific input (Bowstring / Constellation / Combo buttons). 3 slots max.

Players assign hotbar slots from the inventory. Only instant-use consumables can be assigned.
Hotbar assignments persist across sessions (stored in `player_settings`).

| Slot | Accepts | Notes |
|------|---------|-------|
| 1 | HP instant-use only | Healing Draughts, Zone Maps (already implemented) |
| 2 | Class resource instant-use | Mana Vials (Arcanist); Endurance Draughts (Vanguard); second HP slot (Warden) |
| 3 | Status cure (Antidote) | Any class |

Non-Arcanist players see slot 2 as a second HP slot, Mana Vials simply don't appear in their
inventory picker for that slot.

---

## Item Definitions, Instant-Use (Combat Hotbar)

### Healing Draught (Alchemy)

Instant HP restore. Flat amount, not percentage, flat scales better with quality tiers and is
more readable to players ("this restores 80 HP" vs "this restores 15% HP").

| Quality | HP Restored | Cooldown |
|---------|------------|---------|
| Crude | 40 HP | 8s |
| Rough | 80 HP | 8s |
| Refined | 140 HP | 8s |
| Pristine | 220 HP | 8s |
| Masterwork | 320 HP | 6s |

Masterwork gets a slightly shorter cooldown as a mastery reward.

**`ItemData` fields needed:**
```
effectType = InstantHP
effectValue = 40 / 80 / 140 / 220 / 320  (by quality)
cooldownSeconds = 8 / 8 / 8 / 8 / 6
```

---

### Mana Vial (Alchemy, Arcanist only)

Instant mana restore. Only usable by Arcanist path; inventory picker filters by
`GrimoireManager.currentPath == Arcanist`. Lifebinder cannot use, no mana pool.

| Quality | Mana Restored | Cooldown |
|---------|--------------|---------|
| Crude | 20 mana | 10s |
| Rough | 40 mana | 10s |
| Refined | 70 mana | 10s |
| Pristine | 110 mana | 10s |
| Masterwork | 160 mana | 8s |

**`ItemData` fields needed:**
```
effectType = InstantMana
effectValue = 20 / 40 / 70 / 110 / 160
cooldownSeconds = 10 / 10 / 10 / 10 / 8
requiresPath = Arcanist
```

---

### Endurance Draught (Alchemy, Vanguard only)

Instant stamina restore. Only usable by Vanguard path; inventory picker filters by
`GrimoireManager.currentPath == Vanguard`. Arcanist and Warden cannot use, no stamina pool.

| Quality | Stamina Restored | Cooldown |
|---------|-----------------|---------|
| Crude | 25 stamina | 10s |
| Rough | 45 stamina | 10s |
| Refined | 75 stamina | 10s |
| Pristine | 110 stamina | 10s |
| Masterwork | 160 stamina | 8s |

**`ItemData` fields needed:**
```
effectType = InstantStamina
effectValue = 25 / 45 / 75 / 110 / 160
cooldownSeconds = 10 / 10 / 10 / 10 / 8
requiresPath = Vanguard
```

---

Cures status debuffs instantly. Applied from the hotbar mid-combat.

**Cures:**
- Poison (DoT damage over time)
- Bleed (DoT, applied by Shadowblade combos, some enemies)
- Weaken (damage reduction debuff)
- Accuracy Down (applied by Void Shade, some enemies)

Does NOT cure: Freeze, Stagger, Slow, these are short-duration control effects that expire
naturally and don't warrant an item slot.

| Quality | Debuffs cured | Cooldown |
|---------|--------------|---------|
| Crude | Poison only | 12s |
| Rough | Poison + Bleed | 12s |
| Refined | Poison + Bleed + Weaken | 10s |
| Pristine | All four | 10s |
| Masterwork | All four + 5s immunity window | 8s |

**`ItemData` fields needed:**
```
effectType = CureDebuff
curedDebuffs = [Poison] / [Poison, Bleed] / [Poison, Bleed, Weaken] / [all] / [all + immunity]
immunityDuration = 0 / 0 / 0 / 0 / 5
cooldownSeconds = 12 / 12 / 10 / 10 / 8
```

---

## Item Definitions, Buff-Use (Inventory Only, Outside Combat)

### Cookery Meals (Cookery Talent)

Meals apply **timed stat buffs**, not instant HP fills. The distinction between potions
(instant, emergency) and meals (planned, sustained) is intentional. Players eat a meal
before entering a zone, not mid-fight.

Meals can buff HP regen, stats, or drop rate, they do not instantly restore HP.

| Item | Buff | Duration | Quality scaling |
|------|------|---------|----------------|
| Roasted Rabbit | HP regen +3/sec | 15 min | Potency ×quality multiplier |
| Herb Broth | WIL +2 | 20 min | Duration ×quality multiplier |
| Venison Stew | STR +2, VIT +2 | 20 min | Potency ×quality multiplier |
| Hunter's Ration | No-penalty travel (no ATK penalty while moving zones) | 30 min | Duration ×quality multiplier |
| Warden's Focus Meal | DEX +3, LCK +1 | 20 min | Potency ×quality multiplier |
| **Warrior's Ration** | Max Stamina +30 (Vanguard only) | 20 min | Potency ×quality multiplier |
| **Hearty Stew** | Stamina regen +2/sec (Vanguard only) | 20 min | Potency ×quality multiplier |
| Masterwork Feast | All stats +5 | 60 min | Masterwork only, no scaling |

Warrior's Ration and Hearty Stew have `requiresPath = Vanguard`, they don't appear in other
classes' inventory meal picker. Stack with each other since they affect different stamina
properties (max vs regen), but still subject to the one-meal-at-a-time rule per category
(one HP/stat meal + one stamina meal can both be active simultaneously).

**Quality multiplier for meals:**

| Quality | Potency multiplier | Duration multiplier |
|---------|-------------------|-------------------|
| Crude | ×0.6 | ×0.7 |
| Rough | ×0.8 | ×0.85 |
| Refined | ×1.0 | ×1.0 (baseline) |
| Pristine | ×1.3 | ×1.2 |
| Masterwork | ×1.6 | ×1.5 |

Only one meal buff active at a time, eating a second meal replaces the first.

**`ItemData` fields needed:**
```
effectType = TimedBuff
buffStats = [STR, VIT, DEX, WIL, LCK, HPRegen] (one or more)
buffValues = float[] per stat
durationMinutes = float (before quality scaling)
inventoryOnly = true
```

---

### Poison Coating (Alchemy, Warden primary, any class)

Applied to the equipped weapon from inventory. Cannot be applied mid-combat.

Adds a **charge-based poison DoT** to the next N attacks. Each hit that consumes a charge
applies a bleed/poison DoT to the target for a fixed duration. Not a damage buff, a DoT
applicator. Runs out after N charges regardless of time elapsed.

| Quality | Charges | DoT damage/tick | DoT duration | Tick rate |
|---------|---------|----------------|-------------|----------|
| Crude | 5 | 4/sec | 6s | 1s |
| Rough | 8 | 7/sec | 8s | 1s |
| Refined | 12 | 12/sec | 10s | 1s |
| Pristine | 16 | 18/sec | 12s | 1s |
| Masterwork | 24 | 28/sec | 15s | 1s |

Multiple coatings cannot stack, applying a new coating while one is active replaces it.
Shadowblade's Hemorrhage Mastery (bleed DoTs stack twice) interacts with Poison Coating, 
if the equipped weapon has a coating active, Hemorrhage Mastery's stacking applies.

**`ItemData` fields needed:**
```
effectType = WeaponCoating
coatingCharges = 5 / 8 / 12 / 16 / 24
dotDamagePerTick = 4 / 7 / 12 / 18 / 28
dotDurationSeconds = 6 / 8 / 10 / 12 / 15
dotTickRate = 1.0
inventoryOnly = true
```

---

## Idle Auto-Eat System

During idle combat sessions, the player is not present to use the hotbar. Auto-eat
automatically consumes a Healing Draught (or designated hotbar item) when HP drops to a
threshold. Only applies to HP, auto-mana is not in scope.

### Free Tier [as-built: not yet built, pending]

| Property | Value |
|----------|-------|
| Trigger threshold | 25% HP |
| Item consumed | Lowest-quality Healing Draught in inventory |
| Response delay | 2.0 seconds after threshold crossed |
| Limit | 1 per combat encounter (one enemy) |

### Royal Merchant Upgrade Tiers [pending]

Purchased from the Royal Merchant with Gold Marks. Account-bound on purchase.
Each tier is additive, purchasing Tier 3 includes Tier 1 and 2 behavior.

| Tier | Upgrade | GM Cost | Real Money |
|------|---------|---------|-----------|
| **Free** | Auto-eat at 25% HP, lowest quality item, 2s delay, 1/encounter |, |, |
| **Tier 1** | Threshold raises to 40% HP | 200 GM | $0.99 |
| **Tier 2** | Auto-selects best available quality (not lowest) | 300 GM | $1.49 |
| **Tier 3** | Response delay reduced to 0.5s; limit raises to 3/encounter | 500 GM | $1.99 |
| **Tier 4** | Second resource covered: auto-mana at 30% mana (Arcanist only) | 400 GM | $1.99 |

**Design note:** Tier 1 and 2 together represent the biggest QoL upgrade, catching HP earlier
and using better items. Tier 3 is for high-difficulty idle sessions. Tier 4 is Arcanist-specific.
Total cost for all tiers: 1,400 GM or ~$6.46 real money, reasonable for a permanent QoL stack.

**Implementation, auto-eat logic:**
```csharp
void OnPlayerHPChanged(float currentHP, float maxHP) {
    float threshold = GetAutoEatThreshold(); // 0.25 free, 0.40 T1+
    if (currentHP / maxHP <= threshold && CanAutoEat()) {
        ItemData item = GetAutoEatItem(); // lowest quality free, best quality T2+
        float delay = GetAutoEatDelay();  // 2.0s free, 0.5s T3+
        StartCoroutine(AutoEatAfterDelay(item, delay));
    }
}
```

Auto-eat tier state stored in `player_settings.auto_eat_tier` (int 0-4).

---

## `ItemData`, New Fields Required

**[pending]**, `ItemData` currently has only `isConsumable bool`. Add:

```csharp
// Consumable effect fields (add to ItemData ScriptableObject)
public ConsumableEffectType effectType;   // enum below
public float effectValue;                  // HP/mana restored, buff value
public float[] buffValues;                 // for multi-stat buffs
public StatType[] buffStats;               // which stats are buffed
public float durationSeconds;              // for timed buffs (0 = instant)
public float cooldownSeconds;              // hotbar cooldown
public int coatingCharges;                 // for WeaponCoating type
public float dotDamagePerTick;
public float dotDurationSeconds;
public string[] curedDebuffs;              // for Antidote type
public float immunityDuration;
public GrimoirePath requiredPath;          // GrimoirePath.None = any
public bool inventoryOnly;                 // false = hotbar eligible

public enum ConsumableEffectType {
    None,
    InstantHP,
    InstantMana,
    InstantStamina,
    CureDebuff,
    TimedBuff,
    WeaponCoating,
    ZoneMap           // already implemented
}
```

---

## `InventoryManager.UseConsumable`, Updates Required

**[as-built]** Currently only handles `ZoneMap` effect type.

**[pending]** Extend the switch to handle all new effect types:

```csharp
void UseConsumable(ItemData item, GameObject target = null) {
    switch (item.effectType) {
        case ZoneMap:      // existing, keep
            ApplyZoneMap(item); break;
        case InstantHP:
            PlayerStats.RestoreHP(item.effectValue);
            StartCooldown(item, item.cooldownSeconds); break;
        case InstantMana:
            if (GrimoireManager.currentPath != Arcanist) return;
            PlayerStats.RestoreMana(item.effectValue);
            StartCooldown(item, item.cooldownSeconds); break;
        case CureDebuff:
            DebuffManager.CureDebuffs(item.curedDebuffs);
            if (item.immunityDuration > 0)
                DebuffManager.ApplyImmunity(item.immunityDuration);
            StartCooldown(item, item.cooldownSeconds); break;
        case TimedBuff:
            if (CombatManager.IsInActiveCombat) return; // inventory-only
            BuffManager.ApplyMealBuff(item); break;
        case WeaponCoating:
            if (CombatManager.IsInActiveCombat) return; // inventory-only
            WeaponManager.ApplyCoating(item); break;
    }
    InventoryManager.ConsumeOne(item);
}
```

---

## Quality Tier Summary

| Quality | Healing Draught | Mana Vial | Endurance Draught | Antidote | Meal potency |
|---------|----------------|-----------|------------------|---------|-------------|
| Crude | 40 HP | 20 mana | 25 stamina | Poison only | ×0.6 |
| Rough | 80 HP | 40 mana | 45 stamina | + Bleed | ×0.8 |
| Refined | 140 HP | 70 mana | 75 stamina | + Weaken | ×1.0 |
| Pristine | 220 HP | 110 mana | 110 stamina | + Acc Down | ×1.3 |
| Masterwork | 320 HP | 160 mana | 160 stamina | + immunity 5s | ×1.6 |

---

## What's Not In Scope

- **Stamina for non-Vanguard**, Warden and Arcanist have no stamina pool. Stamina items don't appear in their pickers.
- **Stamina depletion during idle**, idle auto-combat always uses 1-input Strike (0 cost). Stamina is an active-play resource only.
- **Combat stat buffs**, potions don't buff stats; only meals do, and only from inventory.
- **Mana potions for Lifebinder**, Lifebinder has no mana pool; Mana Vials don't appear in their hotbar picker.
- **Stacking same-category meal buffs**, one HP/stat meal and one stamina meal can both be active simultaneously, but two HP meals cannot stack.
- **Royal Merchant UI**, auto-eat tier purchases are blocked on Royal Merchant being built. The `auto_eat_tier` field can be added to `player_settings` now; purchase flow comes when Royal Merchant ships.

---

## Implementation Order (suggested)

1. Add new `ConsumableEffectType` enum and fields to `ItemData`
2. Update `InventoryManager.UseConsumable` switch for `InstantHP` and `CureDebuff` first
3. Add mana pool to `PlayerStats` (WIL-fed, Arcanist-only, Lifebinder excluded)
4. Add `InstantMana` handling + Arcanist path gate
5. Add stamina pool to `PlayerStats` (VIT-fed, Vanguard-only; never depletes during idle)
6. Add `InstantStamina` handling + Vanguard path gate
7. Build combat hotbar UI (3 slots, slot 2 shows class-appropriate item type)
8. Add `TimedBuff` and `WeaponCoating` handling (inventory-only gate)
9. Implement `BuffManager` for meal buff tracking (one HP/stat meal + one stamina meal simultaneously)
10. Add stamina depletion to combo system, 2-input costs 8, 3-input costs 18; idle auto-combat uses Strike only (0 cost)
11. Add auto-eat free tier to `CombatManager.OnPlayerHPChanged`
12. Add `auto_eat_tier` to `player_settings` Supabase table + sync
13. Royal Merchant auto-eat tier purchases (blocked on Royal Merchant UI)

---

*Path: `docs/consumables-spec.md`*
