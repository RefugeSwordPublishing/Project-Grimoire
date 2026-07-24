---
type: implementation-brief
version: 0.2
updated: 2026-07-19
purpose: Full progression rebalance, XP curve, per-item idle times, tool quality
         modifiers, processing ratios, upgrade assembly model, station-as-tool system,
         and processing resource check. Based on playtesting feedback.
---

# Progression Rebalance, Implementation Brief
### Version 0.2

---

## 1. Combat XP, Damage-Based Model

Replace the fixed XP-per-kill with damage-proportional XP.

```csharp
// In CombatManager, on every hit that deals damage:
void OnDamageDealt(float damage, bool isPlayerAttack) {
    if (!isPlayerAttack) return;
    float xp = damage * 0.3f; // 0.3 XP per damage point
    CombatXPManager.AwardXP(equippedGrimoire, xp);
}
```

**Why 0.3:**
```
Idle avg damage: 5/hit × 0.3 = 1.5 XP/hit
2s attack interval → 1,800 hits/hr × 1.5 = 2,700 XP/hr idle
8hrs/day idle × 5 months × 30 days = 1,200 hrs
1,200 × 2,700 = 3,240,000 XP ≈ level 100 (target: 3,478,000)
```

Active players dealing 20-50 damage/hit earn 6-15 XP/hit, meaningfully
faster than idle without being extreme.

---

## 2. XP Required Per Level (Updated Curve)

Total to level 100: **3,478,000 XP**

| Level Range | XP per level | Cumulative |
|------------|-------------|-----------|
| 1-5 | 300 | 1,500 |
| 6-10 | 600 | 4,500 |
| 11-15 | 1,100 | 10,000 |
| 16-20 | 1,800 | 19,000 |
| 21-25 | 2,800 | 33,000 |
| 26-30 | 4,000 | 53,000 |
| 31-35 | 5,500 | 80,500 |
| 36-40 | 7,500 | 118,000 |
| 41-45 | 10,500 | 170,500 |
| 46-50 | 14,000 | 240,500 |
| 51-55 | 18,500 | 333,000 |
| 56-60 | 24,000 | 453,000 |
| 61-65 | 31,000 | 608,000 |
| 66-70 | 39,000 | 803,000 |
| 71-75 | 49,000 | 1,048,000 |
| 76-80 | 61,000 | 1,353,000 |
| 81-85 | 76,000 | 1,733,000 |
| 86-90 | 94,000 | 2,203,000 |
| 91-95 | 115,000 | 2,778,000 |
| 96-100 | 140,000 | 3,478,000 |

---

## 3. Tool Quality, Idle Time Modifier

Equipped tool quality reduces idle action duration for gathering, processing,
and crafting (see Section 5 for which tool applies to which talent).

| Tool Quality | Duration Multiplier |
|-------------|-------------------|
| None (no tool) | ×1.0 (base) |
| Crude | ×1.0 (base) |
| Rough | ×0.85 |
| Refined | ×0.70 |
| Pristine | ×0.55 |
| Masterwork | ×0.40 |

```csharp
float GetIdleDuration(float baseDuration, ItemQuality toolQuality) {
    float mult = toolQuality switch {
        ItemQuality.Crude      => 1.00f,
        ItemQuality.Rough      => 0.85f,
        ItemQuality.Refined    => 0.70f,
        ItemQuality.Pristine   => 0.55f,
        ItemQuality.Masterwork => 0.40f,
        _ => 1.00f
    };
    return baseDuration * mult;
}
```

---

## 4. Tool Equipment Panel (All Tools Equipped Simultaneously)

Tools move out of the main inventory into a dedicated **Tool Panel** in the
equipment screen. All tools are equipped simultaneously, no swapping needed.
One slot per tool type.

```
EQUIPMENT PANEL
───────────────────────────────────────────────────────
COMBAT GEAR (swappable, one active at a time)
  [ Weapon ] [ Helm ] [ Chest ] [ Legs ] [ Boots ] [ Gloves ]

TOOLS (all active simultaneously, passive bonuses always on)
  [ Axe ]          [ Pickaxe ]       [ Trapper's Kit ] [ Fishing Rod ]
  [ Smith's Hammer ] [ Carpenter's Kit ] [ Alchemy Kit ]
  [ Cookery Set ]  [ Inscription Set ] [ Weaving Loom ] [ Tailoring Kit ]
  [ Quiver ]
───────────────────────────────────────────────────────
```

Tools never appear in the main inventory. They are assembled and placed
directly into the tool panel. Only one quality per tool type equipped at a time
(the best one the player has).

**To upgrade:** Player unequips the tool (moves it to a temp inventory slot),
trades it to an assembler, assembler performs upgrade, returns it.
While unequipped: idle times revert to Crude tier until re-equipped.

---

## 5. Tool → Talent Mapping

Each tool reduces idle times for its primary and secondary talent.

| Tool | Primary Talent | Secondary Talent | Notes |
|------|---------------|-----------------|-------|
| Axe | Felling (gather) | Timber Shaping (processing) | Same material chain |
| Pickaxe | Delving (gather) | Smelting (processing) | Same material chain |
| Trapper's Kit | Trapping (gather) | Tanning (processing) | Same material chain |
| Fishing Rod | Dredging (gather) |, | Dredging only |
| Smith's Hammer | Runesmithing (crafting) |, | Component forging |
| Carpenter's Kit | Timber Shaping (crafting) |, | Component milling |
| Alchemy Kit | Alchemy (crafting) |, | Brewing times |
| Cookery Set | Cookery (crafting) |, | Cooking times |
| Inscription Set | Inscription (crafting) |, | Scribing times |
| Weaving Loom | Arcane Weaving (crafting) |, | Weaving times |
| Tailoring Kit | Tailoring (crafting) |, | Sewing times |
| Quiver | Combat (arrow capacity) |, | No idle time effect |

---

## 6. Gathering Idle Times, Per Item

Base duration assumes Crude tool (or no tool). Apply tool quality modifier on top.

### 🪓 Felling

| Item | Unlock Level | Base Duration | XP per action |
|------|-------------|--------------|--------------|
| Pine | 1 | 15s | 5 |
| Birch | 1 | 18s | 5 |
| Oak | 14 | 25s | 8 |
| Elm | 14 | 28s | 8 |
| Ironbark | 33 | 40s | 12 |
| Ashwood | 33 | 45s | 12 |
| Magicwood | 52 | 65s | 18 |
| Ironbark Heartwood | 71 | 85s | 24 |
| Voidtimber | 84 | 110s | 32 |
| Worldtree Shard | 89 | 150s | 45 |

### ⛏️ Delving

| Item | Unlock Level | Base Duration | XP per action |
|------|-------------|--------------|--------------|
| Copper Ore | 1 | 15s | 5 |
| Tin Ore | 1 | 15s | 5 |
| Flint Fragment | 8 | 18s | 5 |
| Iron Ore | 14 | 25s | 8 |
| Quartz / Jasper | 21 | 30s | 8 |
| Silver Ore | 33 | 40s | 12 |
| Coal | 37 | 35s | 10 |
| Fossil Shard | 44 | 45s | 12 |
| Gold Ore | 49 | 55s | 16 |
| Ruby / Sapphire | 53 | 60s | 18 |
| Mithril Ore | 64 | 75s | 22 |
| Adamantine Ore | 76 | 95s | 28 |
| Diamond / Voidstone | 81 | 100s | 30 |
| Starstone Ore | 86 | 115s | 34 |
| Soulite Ore | 92 | 140s | 42 |

### 🪤 Trapping

| Trap / Creature | Unlock Level | Base Duration | XP per action |
|----------------|-------------|--------------|--------------|
| Rabbit Snare | 1 | 20s | 5 |
| Fox Trap | 9 | 30s | 8 |
| Reinforced Snare | 16 | 35s | 10 |
| Deer Cage Trap | 22 | 45s | 12 |
| Scent Lure (rare) | 34 | 50s | 14 |
| Wild Boar Trap | 39 | 60s | 16 |
| Beast Cage | 53 | 75s | 20 |
| Wolf Trap | 61 | 85s | 24 |
| Shadow Snare | 67 | 95s | 28 |
| Runed Trap | 73 | 110s | 32 |
| Drake Trap | 82 | 130s | 38 |
| Void Snare | 89 | 150s | 45 |

### 🎣 Dredging

| Item | Unlock Level | Base Duration | XP per action |
|------|-------------|--------------|--------------|
| Freshwater Fish (Perch, Carp) | 1 | 20s | 5 |
| Saltwater Fish | 11 | 30s | 8 |
| Pearl | 17 | 40s | 10 |
| Deep Net catch | 31 | 35s | 10 |
| Aquatic Reagents | 38 | 50s | 14 |
| Abyssal Fish | 47 | 65s | 18 |
| Dragon Eel | 73 | 100s | 30 |
| Void Kraken Ink | 84 | 130s | 38 |

### 🔍 Gleaning

| Activity | Unlock Level | Base Duration | XP per action |
|---------|-------------|--------------|--------------|
| Crude Salvage | 1 | 25s | 5 |
| Ruin Search | 12 | 35s | 8 |
| Old Coin | 31 | 40s | 10 |
| Ancient Text Fragment | 38 | 50s | 12 |
| Dungeon Gleaning | 47 | 60s | 16 |
| Battlefield Gleaning | 54 | 70s | 20 |
| Lost Schematic | 63 | 80s | 24 |
| Vault Cache | 86 | 110s | 32 |
| Assembly Rare Material | 79 | 100s | 30 |
| Pristine Assembly Material | 92 | 140s | 42 |

### 🌾 Cultivation

| Crop | Unlock Level | Base Duration (growth cycle) | XP per action |
|------|-------------|---------------------------|--------------|
| Wheat / Potato | 1 | 30s | 5 |
| Herbs | 8 | 40s | 8 |
| Flax / Cotton | 13 | 45s | 8 |
| Paper Plants | 24 | 50s | 10 |
| Orchard Fruit | 32 | 60s | 14 |
| Alchemical Garden | 44 | 75s | 18 |
| Enchanted Soil plants | 53 | 85s | 22 |
| Moonflower | 61 | 100s | 28 |
| Void Bloom | 76 | 120s | 35 |
| Worldseed | 84 | 150s | 45 |

### 🐾 Tracking

Tracking idle reveals nodes rather than producing items directly.
Idle duration = time between node reveals.

| Activity | Unlock Level | Base Duration | XP per action |
|---------|-------------|--------------|--------------|
| Basic Animal Tracks | 1 | 30s | 5 |
| Terrain Reading | 11 | 35s | 6 |
| Rare Creature Trails | 22 | 50s | 10 |
| Monster Sign | 33 | 65s | 15 |
| Ancient Trail | 53 | 80s | 20 |
| Void Creature Tracks | 63 | 95s | 26 |
| Legendary Spoor | 74 | 120s | 35 |

---

## 7. Processing Idle Times and Ratios

Processing uses the same gathering tool as the raw material (Axe for Timber
Shaping, Pickaxe for Smelting, Trapper's Kit for Tanning). Tool quality
reduces processing idle time using the same multiplier table.

### Input:Output Ratios by Material Tier

| Tier | Examples | Ratio | Reasoning |
|------|---------|-------|----------|
| Material Tier 1 | Pine→Plank, Copper→Bronze Bar, Rabbit Hide→Basic Leather | 2:1 | Accessible early game |
| Material Tier 2 | Oak→Plank, Iron→Iron Bar, Fox Hide→Cured Leather | 3:1 | Meaningful cost |
| Material Tier 3 | Ironbark→Plank, Silver→Bar, Deer Hide→Fine Leather | 4:1 | Rare material feels precious |
| Material Tier 4 | Mithril→Bar, Wolf Hide→Wolf Leather | 6:1 | Real commitment per bar |
| Tier 5 (Legendary) | Adamantine→Bar, Drake Scale processing | 8:1 | Endgame scarcity |
| Tier 6 (Mythic) | Soulite→Bar, Voidtimber→Plank | 10:1 | Maximum rarity feel |

### 🔥 Smelting

| Ore → Output | Tier | Input:Output | Base Duration | XP per action |
|-------------|------|-------------|--------------|--------------|
| Copper+Tin → Bronze Bar | 1 | 2:1 each | 20s | 6 |
| Iron → Iron Bar | 2 | 3:1 | 30s | 9 |
| Silver → Silver Bar | 3 | 4:1 | 45s | 14 |
| Coal → Fuel (processing input) | 2 | 2:1 | 25s | 7 |
| Gold → Gold Bar | 3 | 4:1 | 50s | 15 |
| Mithril → Mithril Bar | 4 | 6:1 | 70s | 22 |
| Adamantine → Adamantine Bar | 5 | 8:1 | 90s | 28 |
| Starstone → Starstone Bar | 5 | 8:1 | 95s | 30 |
| Soulite → Soulite Bar | 6 | 10:1 | 130s | 40 |
| Starstone+Soulite → Void Alloy | 6 | 6+4:1 | 150s | 45 |
| Multi-ore → Grimoire Steel | 6 | Recipe-based | 150s | 48 |

### 🪵 Timber Shaping

| Log → Output | Tier | Input:Output | Base Duration | XP per action |
|-------------|------|-------------|--------------|--------------|
| Pine → Pine Plank | 1 | 2:1 | 15s | 5 |
| Birch → Birch Plank | 1 | 2:1 | 15s | 5 |
| Oak → Oak Plank | 2 | 3:1 | 25s | 8 |
| Elm → Elm Plank | 2 | 3:1 | 25s | 8 |
| Ironbark → Ironbark Plank | 3 | 4:1 | 40s | 12 |
| Ashwood → Ashwood Plank | 3 | 4:1 | 40s | 12 |
| Magicwood → Magicwood Plank | 4 | 6:1 | 60s | 18 |
| Ironbark Heartwood → Premium Plank | 5 | 8:1 | 80s | 25 |
| Voidtimber → Voidtimber Plank | 6 | 10:1 | 110s | 34 |
| Worldtree Shard → (direct use) | 6 | No processing |, |, |

### 🦴 Tanning

| Hide → Output | Tier | Input:Output | Base Duration | XP per action |
|--------------|------|-------------|--------------|--------------|
| Rabbit Hide → Basic Leather | 1 | 2:1 | 20s | 5 |
| Fox Pelt → Rough Leather | 1 | 2:1 | 22s | 6 |
| Deer Hide → Cured Leather | 2 | 3:1 | 32s | 9 |
| Boar Hide → Hardened Leather | 3 | 4:1 | 45s | 13 |
| Wolf Pelt → Wolf Leather | 4 | 6:1 | 65s | 20 |
| Drake Scale → Drake Leather | 5 | 8:1 | 90s | 28 |
| Phantom Pelt → Masterwork Leather | 5 | 8:1 | 95s | 30 |

---

## 8. Crafting Idle Times

Crafting (Alchemy, Cookery, Runesmithing, Timber Shaping components,
Tailoring, Arcane Weaving, Inscription) uses the relevant tool to reduce time.
Duration is per recipe batch (typically 1 output unless Alchemy mastery applies).

### 🧪 Alchemy

| Formulae | Unlock | Base Duration | XP per batch |
|---------|--------|--------------|-------------|
| Minor Healing Draught | 1 | 20s | 6 |
| Antidote Vial | 7 | 28s | 8 |
| Minor Stamina Elixir | 13 | 35s | 10 |
| Poison Coating | 19 | 40s | 12 |
| Taming Lure | 32 | 50s | 15 |
| Fire Coating | 38 | 55s | 16 |
| Major Healing Draught | 44 | 65s | 20 |
| Strength Elixir | 51 | 70s | 22 |
| Frost Coating | 63 | 80s | 26 |
| Shadow Blend | 68 | 85s | 28 |
| Leviathan Lure | 74 | 90s | 30 |
| Fortify Elixir | 79 | 100s | 32 |
| Void Coating | 86 | 115s | 36 |
| Master Healing Draught | 91 | 130s | 42 |

### 🍖 Cookery

| Recipe | Unlock (approx) | Base Duration | XP per batch |
|--------|----------------|--------------|-------------|
| Roasted Rabbit | 1 | 20s | 6 |
| Herb Broth | 8 | 25s | 7 |
| Venison Stew | 22 | 35s | 10 |
| Hunter's Ration | 34 | 45s | 13 |
| Warden's Focus Meal | 46 | 55s | 16 |
| Warrior's Ration | 55 | 60s | 18 |
| Hearty Stew | 60 | 65s | 20 |
| Masterwork Feast | 85 | 110s | 35 |

### ⚒️ Runesmithing Components

| Component | Unlock | Base Duration | XP per action |
|-----------|--------|--------------|--------------|
| Bronze Blade/Limbs | 1 | 20s | 6 |
| Iron Blade/Tips | 13 | 30s | 9 |
| Steel Blade/Limbs | 27 | 40s | 12 |
| Silver Tip | 41 | 50s | 15 |
| Runed Blade | 48 | 60s | 18 |
| Mithril Limbs | 56 | 70s | 22 |
| Adamantine components | 67 | 85s | 26 |
| Starstone Tip/Core | 73 | 95s | 30 |
| Void Blade/Limbs | 84 | 115s | 36 |
| Grimoire Steel components | 93 | 140s | 44 |

### 🪵 Timber Shaping Components

| Component | Unlock | Base Duration | XP per action |
|-----------|--------|--------------|--------------|
| Pine Grip | 1 | 15s | 5 |
| Softwood Haft | 9 | 18s | 5 |
| Hardwood Grip | 16 | 25s | 8 |
| Hardwood Shaft | 23 | 28s | 8 |
| Ashwood Pole | 37 | 40s | 12 |
| Ironbark Grip | 44 | 50s | 15 |
| Magicwood Shaft | 52 | 60s | 18 |
| Ironbark Heartwood Grip | 66 | 80s | 24 |
| Voidtimber Shaft | 74 | 95s | 30 |
| Worldtree Grip | 89 | 130s | 40 |

---

## 9. Tool Upgrade Assembly, Revised Model

**Model: Upgrade existing tool. Old tool consumed on SUCCESS only. Fail = keep existing tool, components consumed.**

Every tool quality level above Crude requires the previous tier tool as an
input ingredient. Crude tools are built fresh from components.

### Example, Felling Axe

| Target Quality | Previous Tool Required | Additional Components | Rare Material | Success Rate (base) |
|---------------|----------------------|----------------------|---------------|-------------------|
| Crude | None | Pine Handle + Bronze Head | None | 100% |
| Rough | Crude Axe | Hardwood Handle + Iron Head | Crude Gemstone | 70% |
| Refined | Rough Axe | Ashwood Handle + Steel Head | Rough Gemstone | 55% |
| Pristine | Refined Axe | Ironbark Handle + Mithril Head | Refined Gemstone | 35% |
| Masterwork | Pristine Axe | Voidtimber Handle + Void Head | Pristine Gemstone | 20% |

Base success rate improved by assembler talent level and attunement bonus
during assembly (per `assembly-materials-crafting-system.md`).

**On fail:**
- Old tool returned unchanged
- Additional components consumed
- Rare material consumed
- No downgrade, ever

**On success:**
- Old tool is transformed (same item ID, quality updated)
- Additional components consumed
- Rare material consumed

Apply this upgrade pattern to EVERY tool and weapon in `assembly-materials-crafting-system.md`.
The pattern is identical for all, previous tier tool + tier-appropriate components + rare material.

---

## 10. Processing Resource Check

Processing idles must verify input materials before starting and pause
when materials run out.

```csharp
bool CanStartProcessing(ProcessingAction action) {
    int required = action.inputQuantity; // e.g. 3 for Iron Ore → Iron Bar
    int held = InventoryManager.GetQuantity(action.requiredInputItemId);
    if (held < required) {
        IdleUI.ShowBlockedMessage(
            $"Need {required}× {action.requiredInputItem}, have {held}");
        return false;
    }
    return true;
}

void OnProcessingActionComplete(ProcessingAction action) {
    InventoryManager.RemoveItem(action.requiredInputItemId, action.inputQuantity);
    InventoryManager.AddItem(action.outputItemId, action.outputQuantity);
    TalentManager.AwardXP(action.talentId, action.xpPerAction);

    if (CanStartProcessing(action)) {
        StartNextAction(action);
    } else {
        StopIdle();
        NotificationManager.Send(
            title: "Processing paused",
            body: $"Out of {action.requiredInputItem}",
            priority: NotificationPriority.P4);
    }
}
```

Same logic applies to crafting (Alchemy, Cookery etc.), check ingredient
quantities before each batch, pause and notify when empty.

---

## 11. Assembly XP, Confirmed

Assembly DOES award XP, to the assembler's talent specifically.
Per `assembly-materials-crafting-system.md`:
- Component crafting XP → component crafter's talent
- Assembly XP → assembler's talent (Runesmithing, Timber Shaping, etc.)

Assembly is a single discrete action (not an idle loop) so it awards
a flat XP amount on completion rather than time-based ticks.

Suggested flat XP per assembly by quality target:

| Quality Assembled | Assembly XP |
|------------------|------------|
| Crude | 15 |
| Rough | 35 |
| Refined | 70 |
| Pristine | 130 |
| Masterwork | 250 |

---

## Files to Update

| File | Change |
|------|--------|
| `CombatManager.cs` | Damage-based XP: `damage × 0.3f` per hit |
| `combat-xp-curve.md` | New XP table (already updated) |
| `IdleManager.cs` | Per-item base duration lookup |
| `GatheringManager.cs` | Per-item durations + tool quality modifier |
| `ProcessingManager.cs` | Ratios + resource check + pause on empty |
| `CraftingManager.cs` | Per-recipe durations + resource check |
| `EquipmentPanel.cs` | Add tool panel (all tools simultaneously) |
| `InventoryUI.cs` | Remove tools from main inventory view |
| `assembly-materials-crafting-system.md` | Add "previous tier tool" as required input for all upgrade attempts |

---

*Path: `docs/progression-rebalance-brief.md`*
