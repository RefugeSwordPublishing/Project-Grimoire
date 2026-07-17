---
type: implementation-brief
spec: consumables-spec.md (v0.2)
updated: 2026-07-11
purpose: Add StatType regen members and wire regen-type meals into BuffManager.
         Unblocks Roasted Rabbit (HP regen) and Hearty Stew (stamina regen)
         which were skipped with a warning during Consumables Part A.
---

# Regen-Type Meals — Implementation Brief

## The Gap

From `implementation-status.md` (Consumables Part A):
> "Deferred: regen-type meals need a `StatType` HP/stamina-regen member
> (skipped with a warning for now)"

`BuffManager` currently handles stat bonuses (`STR +2`, `WIL +2` etc.) but
has no concept of per-second regen bonuses. Two meals need this:

| Meal | Effect | Blocked on |
|------|--------|-----------|
| Roasted Rabbit | HP regen +3/sec for 15 min | `StatType.HPRegen` missing |
| Hearty Stew | Stamina regen +2/sec for 20 min | `StatType.StaminaRegen` missing |

---

## Step 1 — Add Regen Members to StatType Enum

```csharp
public enum StatType {
    // Existing stat members — do not change
    STR, VIT, DEX, INT, WIL, LCK, CHA,

    // Add these:
    HPRegen,      // HP restored per second during combat
    ManaRegen,    // Mana restored per second (out of combat only)
    StaminaRegen, // Stamina restored per second during combat
}
```

---

## Step 2 — BuffManager Handles Regen Stats

`BuffManager` currently applies flat stat bonuses via `PlayerData.*Bonus`.
Regen buffs need to feed into `CombatManager.TickResources` instead.

```csharp
// In BuffManager — extend ApplyBuff to handle regen types:
void ApplyBuff(TimedBuff buff) {
    for (int i = 0; i < buff.buffStats.Length; i++) {
        float value = buff.buffValues[i];

        switch (buff.buffStats[i]) {
            // Existing flat stat bonuses — unchanged
            case StatType.STR: PlayerData.STRBonus += value; break;
            case StatType.VIT: PlayerData.VITBonus += value; break;
            case StatType.WIL: PlayerData.WILBonus += value; break;
            // ... other flat stats

            // New regen bonuses — stored separately
            case StatType.HPRegen:
                PlayerData.BonusHPRegen += value; break;
            case StatType.StaminaRegen:
                PlayerData.BonusStaminaRegen += value; break;
            case StatType.ManaRegen:
                PlayerData.BonusManaRegen += value; break;
        }
    }
}

// On buff expiry — reverse regen bonuses same as flat stats:
void RemoveBuff(TimedBuff buff) {
    for (int i = 0; i < buff.buffStats.Length; i++) {
        float value = buff.buffValues[i];
        switch (buff.buffStats[i]) {
            case StatType.HPRegen:
                PlayerData.BonusHPRegen -= value; break;
            case StatType.StaminaRegen:
                PlayerData.BonusStaminaRegen -= value; break;
            case StatType.ManaRegen:
                PlayerData.BonusManaRegen -= value; break;
            // ... other flat stats reversed
        }
    }
}
```

---

## Step 3 — Add Bonus Regen Fields to PlayerData

```csharp
// In PlayerData — add alongside existing resource pools:
public float BonusHPRegen      = 0f; // from meals, cleared on buff expiry
public float BonusStaminaRegen = 0f;
public float BonusManaRegen    = 0f;
```

---

## Step 4 — Wire Into CombatManager.TickResources

`TickResources` already handles mana and stamina regen. Extend it:

```csharp
void TickResources(float deltaTime) {
    // Existing mana regen (Arcanist, out of combat only):
    if (IsArcanist && !IsInActiveFight)
        PlayerData.CurrentMana = Mathf.Min(
            PlayerData.GetMaxMana(),
            PlayerData.CurrentMana
            + (1.0f + PlayerData.BonusManaRegen) * deltaTime);

    // Existing stamina regen (Vanguard):
    if (IsVanguard)
        PlayerData.CurrentStamina = Mathf.Min(
            PlayerData.GetMaxStamina(),
            PlayerData.CurrentStamina
            + (2.0f + PlayerData.BonusStaminaRegen) * deltaTime);

    // NEW — HP regen from meals (all classes, in combat):
    if (PlayerData.BonusHPRegen > 0)
        PlayerData.CurrentHP = Mathf.Min(
            PlayerData.GetMaxHP(),
            PlayerData.CurrentHP
            + PlayerData.BonusHPRegen * deltaTime);

    // Note: Lifebinder passive HP regen is handled separately
    // in LifebinderCombat — not here. BonusHPRegen is meal bonus only.
}
```

**Lifebinder note:** Lifebinder has its own passive regen (`3 HP/sec + VIT×0.08
+ WIL×0.05`) handled in `LifebinderCombat`. `BonusHPRegen` from Roasted Rabbit
stacks ON TOP of that — they are additive. Lifebinder eating a Roasted Rabbit
gets both their passive regen AND the meal's +3/sec.

---

## Step 5 — Author the Regen Meal ItemData Assets

Update `CreateConsumables` editor tool to include regen meals:

```csharp
// Roasted Rabbit
var roastedRabbit = CreateItem("Roasted Rabbit");
roastedRabbit.effectType = ConsumableEffectType.TimedBuff;
roastedRabbit.buffStats = new[] { StatType.HPRegen };
roastedRabbit.buffValues = new[] { 3.0f };     // +3 HP/sec (Refined baseline)
roastedRabbit.durationSeconds = 900f;           // 15 minutes
roastedRabbit.inventoryOnly = true;
roastedRabbit.quality = ItemQuality.Refined;    // baseline — scale by quality

// Hearty Stew (Vanguard only)
var heartyStew = CreateItem("Hearty Stew");
heartyStew.effectType = ConsumableEffectType.TimedBuff;
heartyStew.buffStats = new[] { StatType.StaminaRegen };
heartyStew.buffValues = new[] { 2.0f };        // +2 stamina/sec (Refined baseline)
heartyStew.durationSeconds = 1200f;            // 20 minutes
heartyStew.inventoryOnly = true;
heartyStew.requiredPath = GrimoirePath.Vanguard;
heartyStew.quality = ItemQuality.Refined;
```

**Quality scaling for regen meals** — same multiplier table as other meals:

| Quality | HPRegen potency | Duration multiplier |
|---------|----------------|-------------------|
| Crude | +1.8/sec | ×0.7 (10.5 min) |
| Rough | +2.4/sec | ×0.85 (12.75 min) |
| Refined | +3.0/sec | ×1.0 (15 min) |
| Pristine | +3.9/sec | ×1.2 (18 min) |
| Masterwork | +4.8/sec | ×1.5 (22.5 min) |

Same pattern applies to Hearty Stew stamina regen values.

---

## What Changes in UseConsumable

Nothing — `TimedBuff` path in `UseConsumable` already calls
`BuffManager.ApplyMealBuff(item)`. Once `BuffManager` handles
`StatType.HPRegen` and `StatType.StaminaRegen`, regen meals
flow through automatically.

---

## Summary — Files to Touch

| File | Change |
|------|--------|
| `StatType.cs` (or wherever enum lives) | Add `HPRegen`, `ManaRegen`, `StaminaRegen` |
| `PlayerData.cs` | Add `BonusHPRegen`, `BonusStaminaRegen`, `BonusManaRegen` |
| `BuffManager.cs` | Handle regen StatTypes in Apply/Remove |
| `CombatManager.cs` | Wire `BonusHPRegen` into `TickResources` |
| `CreateConsumables.cs` | Author Roasted Rabbit + Hearty Stew assets |

Five files, all small changes. No new systems — purely extending what's built.

---

*Path: `docs/regen-meals-brief.md`*
