---
type: implementation-brief
spec: enemy-zone-tables.md (v0.2), dungeon-room-pools-t4t5-brief.md (v1.0)
updated: 2026-07-31
path: docs/phase4-enemy-content-brief.md
purpose: Author all T4 and T5 EnemyData ScriptableObjects and ZoneData.
         Mirrors phase3-enemy-content-brief.md exactly. Read that doc first
         for shared EnemyData field definitions and weak-point implementation.
         The four dungeon bosses (Veil Harbinger, Valdren the Unfinished,
         Pale Vault Warden, Firststone Warden) are already fully specced in
         dungeon-room-pools-t4t5-brief.md, do NOT re-author those here.
---

# Phase 4/5 Enemy Content, Implementation Brief

---

## Stat Scaling Reference

T3 anchors and T4/T5 scaling factors used to derive all values below:

| Metric | T3 Standard | T4 Standard | T5 Standard |
|--------|------------|------------|------------|
| HP | 145-250 | 420-720 | 670-1,150 |
| Damage min | 18-22 | 25-31 | 33-40 |
| Damage max | 28-35 | 39-49 | 51-64 |
| Defense | 10-18 | 22-27 | 31-38 |
| Slaying XP | 18 | 30 | 50 |

| Metric | T3 Elite | T4 Elite | T5 Elite |
|--------|---------|---------|---------|
| HP | 680-820 | 1,150-1,400 | 1,850-2,250 |
| Slaying XP | 90 | 150 | 240 |

| Metric | T3 Zone Boss | T4 Zone Boss | T5 Zone Boss |
|--------|-------------|-------------|-------------|
| HP (solo) | 9,200-10,400 | 15,600-17,600 | 25,000-28,000 |
| HP scaling | ×1.6 (2p), ×2.2 (3p) | same | same |
| Slaying XP | 2,800-3,000 | ~4,900 | ~7,800 |

All defense values follow the combat-balance-reconcile.md model (defense applied
before multiplier, zone-1 defense 10-18 as baseline, scaling upward per tier).

---

## Zone Data (CreatePhase4Enemies should also author these)

The four zone IDs referenced in dungeon-room-pools-t4t5-brief.md need ZoneData
ScriptableObjects if they do not already exist. Author them as part of this pass.

| Zone ID | Display Name | Tier | Combat Level Gate | Primary Faction | Secondary Faction |
|---------|-------------|------|------------------|----------------|------------------|
| veilborn_wastes | Veilborn Wastes | 4 | Total Combat Level 91 | [Void] | [Undead] |
| shattered_citadel | Shattered Citadel | 4 | Total Combat Level 91 | [Arcane] | [Outlaw] |
| ashenwold | Ashenwold | 5 | Total Combat Level 141 | [Void] | [Undead] |
| elder_reaches | Elder Reaches | 5 | Total Combat Level 141 | [Arcane] | [Beast] |

---

## Zone 4A, Veilborn Wastes

**Primary faction:** `[Void]`
**Secondary faction:** `[Undead]`
**Slaying XP (standard):** 30 per kill
**Slaying XP (elite):** 150 per kill

---

### Standard Enemies

---

#### Void Crawler

```
EnemyData {
    enemyName:           "Void Crawler"
    factionTags:         ["Void"]
    combatLevelMin:      61
    combatLevelMax:      67
    maxHP:               420
    damageMin:           25
    damageMax:           40
    attackCadence:       2.0s
    defense:             22
    baseAccuracy:        75
    evasionRating:       12
    blockChance:         0.02
    weakPointDesc:       "Void Core, UNDERBELLY (glowing purple node, Hidden tier)"
    weakPointTier:       Hidden
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     8
    goldMarkDropMax:     18
    dropTable: [
        { item: "Pristine Void Spore",   chance: 0.40, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Void Ichor",            chance: 0.50, qualityMin: Crude,    qualityMax: Rough    },
        { item: "Gold Mark",             chance: 0.50, amount: "8-18"                             },
        { item: "Soul Residue",          chance: 0.25, qualityMin: Crude,    qualityMax: Refined  }
    ]
    specialAbility:      "Void Phase, briefly phases into void for 1.5s every 10s (untargetable,
                          same mechanic as T3 Void Shade). Underbelly weak point invisible during phase."
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/void_crawler.png"
}
```

---

#### Veilborn Wraith

```
EnemyData {
    enemyName:           "Veilborn Wraith"
    factionTags:         ["Undead"]
    combatLevelMin:      63
    combatLevelMax:      69
    maxHP:               480
    damageMin:           26
    damageMax:           42
    attackCadence:       2.2s
    defense:             20
    baseAccuracy:        72
    evasionRating:       18
    blockChance:         0.0
    weakPointDesc:       "Soul Core, CHEST (pale glowing orb, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     8
    goldMarkDropMax:     20
    dropTable: [
        { item: "Pristine Phantom Pelt", chance: 0.45, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Soul Residue",          chance: 0.40, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.50, amount: "8-20"                             },
        { item: "Grave Cloth",           chance: 0.20, qualityMin: Crude,    qualityMax: Rough    }
    ]
    specialAbility:      "Life Drain, on hit 15% chance, drains 8 HP from player and restores
                          to Wraith. Telegraphed by a pale glow on the Wraith's hands (0.5s)."
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/veilborn_wraith.png"
}
```

---

#### Reality Shade

```
EnemyData {
    enemyName:           "Reality Shade"
    factionTags:         ["Void"]
    combatLevelMin:      66
    combatLevelMax:      72
    maxHP:               510
    damageMin:           28
    damageMax:           45
    attackCadence:       1.8s
    defense:             18
    baseAccuracy:        78
    evasionRating:       22
    blockChance:         0.0
    weakPointDesc:       "Void Crystal, CHEST (always visible, large, Obvious tier)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     10
    goldMarkDropMax:     22
    dropTable: [
        { item: "Void Crystal",          chance: 0.55, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Pristine Ancient Sigil",chance: 0.30, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Gold Mark",             chance: 0.45, amount: "10-22"                            },
        { item: "Pristine Void Spore",   chance: 0.12, qualityMin: Pristine, qualityMax: Pristine }
    ]
    specialAbility:      "Void Merge, if two Reality Shades are in the same room, they briefly
                          merge into a single entity at 1.6x combined HP once per encounter.
                          Merged form is Obvious tier on both weak points simultaneously.
                          Separated again when merged HP drops below 30%."
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/reality_shade.png"
}
```

---

#### Corruption Titan

```
EnemyData {
    enemyName:           "Corruption Titan"
    factionTags:         ["Void"]
    combatLevelMin:      68
    combatLevelMax:      74
    maxHP:               720
    damageMin:           30
    damageMax:           49
    attackCadence:       3.0s
    defense:             27
    baseAccuracy:        68
    evasionRating:       6
    blockChance:         0.08
    weakPointDesc:       "Corruption Sac, TORSO (visible bulge, pulses, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     12
    goldMarkDropMax:     25
    dropTable: [
        { item: "Pristine Void Spore",   chance: 0.45, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Void Core",             chance: 0.30, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.55, amount: "12-25"                            },
        { item: "Soul Residue",          chance: 0.20, qualityMin: Crude,    qualityMax: Refined  }
    ]
    specialAbility:      "Void Slam, telegraph 2s (raises both arms), ground AoE on impact.
                          All entities in 2-unit radius take 20 void damage. 12s cooldown.
                          Corruption Sac pulses Obvious during the 2s telegraph only."
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/corruption_titan.png"
}
```

---

### Veilborn Wastes Elites

---

#### Veil Stalker [Elite]

```
EnemyData {
    enemyName:           "Veil Stalker"
    factionTags:         ["Void"]
    combatLevelMin:      72
    combatLevelMax:      78
    maxHP:               1,200
    damageMin:           40
    damageMax:           62
    attackCadence:       1.6s
    defense:             25
    baseAccuracy:        82
    evasionRating:       28
    blockChance:         0.0
    weakPointDesc:       "Void Core, CHEST (always glowing, Obvious tier)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             true
    slayingXPReward:     150
    goldMarkDropMin:     40
    goldMarkDropMax:     90
    dropTable: [
        { item: "Pristine Void Spore",   chance: 0.60, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Void Shard",            chance: 0.45, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.80, amount: "40-90"                            },
        { item: "Masterwork Void Spore", chance: 0.06, qualityMin: Masterwork, qualityMax: Masterwork }
    ]
    specialAbility:      "Void Step, teleports behind player every 12s (void flash 1s before).
                          Next attack from behind is unblockable. Void Core pulses Obvious for
                          3s after each Void Step as a counter-attack window."
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/veil_stalker.png"
}
```

---

#### Sundered Revenant [Elite]

```
EnemyData {
    enemyName:           "Sundered Revenant"
    factionTags:         ["Undead", "Void"]
    combatLevelMin:      74
    combatLevelMax:      80
    maxHP:               1,380
    damageMin:           42
    damageMax:           65
    attackCadence:       2.0s
    defense:             24
    baseAccuracy:        76
    evasionRating:       15
    blockChance:         0.05
    weakPointDesc:       "Sundered Soul, CHEST (void-fractured rib cavity, Subtle P1 / Obvious P2)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             true
    slayingXPReward:     150
    goldMarkDropMin:     45
    goldMarkDropMax:     100
    dropTable: [
        { item: "Pristine Phantom Pelt", chance: 0.60, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Soul Essence",          chance: 0.35, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.80, amount: "45-100"                           },
        { item: "Masterwork Phantom Pelt",chance: 0.06,qualityMin: Masterwork, qualityMax: Masterwork }
    ]
    specialAbility:      "Phase Rift, at 50% HP, the Sundered Revenant partially phase-shifts.
                          Body becomes semi-transparent; Sundered Soul shifts to Obvious tier.
                          All damage reduced by 15% in this form but weak-point crits deal 2.5x.
                          Rewards players who switch to weak-point targeting in Phase 2."
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/sundered_revenant.png"
}
```

---

### The Veil Sovereign, Zone Boss 4A

```
EnemyData {
    enemyName:           "The Veil Sovereign"
    factionTags:         ["Void"]
    combatLevelMin:      80
    combatLevelMax:      80
    isBoss:              true
    maxHP:               16,000   (solo) / 25,600 (2p) / 35,200 (3p)
    damageMin:           48
    damageMax:           72
    attackCadence:       1.8s
    defense:             30
    baseAccuracy:        85
    evasionRating:       20
    blockChance:         0.0
    weakPointDesc:       "Void Core, CHEST (knight armor fissure, Subtle P1, Obvious P2+)"
    weakPointTier:       Subtle (P1) / Obvious (P2+)
    weakPointMultiplier: 2.0
    spawnChance:         0.05
    despawnTimer:        600
    slayingXPReward:     5,000
    goldMarkDropMin:     80
    goldMarkDropMax:     180
    dropTable: [
        { item: "Pristine Void Spore",   chance: 1.0,  guaranteed: true   },
        { item: "Pristine Phantom Pelt", chance: 1.0,  guaranteed: true   },
        { item: "Gold Mark pouch",       chance: 1.0,  guaranteed: true, amount: "80-180" },
        { item: "Pristine weapon",       chance: 0.20, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Veil Sovereign's Mantle",chance: 0.03 }
    ]
    bossAbilities: [
        "Void Lance, ranged, 2.5s telegraph, 45-60 damage",
        "Reality Fracture, two floor zones activate, 10s cycle (Phase 1+)",
        "Void Armor Crack, at 65% HP, armor fissures, Void Core goes Obvious",
        "Shade Summon, Phase 2: summons 2x Reality Shade",
        "Phase 3 Enrage: Void Lance fires double, Reality Fracture expands to 4 zones",
        "Veil Shatter, Phase 3 only: shatters part of the room floor (permanent void zone,
         any entity in it takes 8 void DoT/s for the rest of the fight)"
    ]
    spriteRef:           "Assets/Sprites/Enemies/VeilbornWastes/veil_sovereign.png"
}
```

---

## Zone 4B, Shattered Citadel

**Primary faction:** `[Arcane]`
**Secondary faction:** `[Outlaw]`
**Slaying XP (standard):** 30 per kill
**Slaying XP (elite):** 150 per kill

---

### Standard Enemies

---

#### Citadel Automaton

```
EnemyData {
    enemyName:           "Citadel Automaton"
    factionTags:         ["Arcane"]
    combatLevelMin:      61
    combatLevelMax:      67
    maxHP:               520
    damageMin:           25
    damageMax:           40
    attackCadence:       2.8s
    defense:             27
    baseAccuracy:        70
    evasionRating:       4
    blockChance:         0.10
    weakPointDesc:       "Runic Core, CHEST (amber glow, always visible, Obvious tier)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     8
    goldMarkDropMax:     18
    dropTable: [
        { item: "Pristine Runic Cog",    chance: 0.40, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Mithril Scrap",         chance: 0.35, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.50, amount: "8-18"                             },
        { item: "Arcane Residue",        chance: 0.30, qualityMin: Crude,    qualityMax: Refined  }
    ]
    specialAbility:      "Patrol Route, follows a fixed patrol path. Will not break patrol to
                          pursue player beyond its patrol boundary unless struck first. On
                          patrol-break (when struck), emits an alert pulse that raises
                          Automaton initiative by +1 action in the current turn."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/citadel_automaton.png"
}
```

---

#### Ruin Scavenger

```
EnemyData {
    enemyName:           "Ruin Scavenger"
    factionTags:         ["Outlaw"]
    combatLevelMin:      65
    combatLevelMax:      71
    maxHP:               420
    damageMin:           26
    damageMax:           42
    attackCadence:       1.8s
    defense:             22
    baseAccuracy:        76
    evasionRating:       20
    blockChance:         0.03
    weakPointDesc:       "Exposed Back, BACK (only targetable during Flee, Hidden otherwise)"
    weakPointTier:       Hidden
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     10
    goldMarkDropMax:     22
    dropTable: [
        { item: "Gold Mark",             chance: 0.55, amount: "10-22"                            },
        { item: "Salvaged Component",    chance: 0.45, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Arcane Residue",        chance: 0.25, qualityMin: Crude,    qualityMax: Rough    },
        { item: "Lost Schematic",        chance: 0.04                                             }
    ]
    specialAbility:      "Flee, when HP drops below 25%, the Scavenger breaks and runs for
                          the room exit (movement speed +50%). Exposed Back weak point becomes
                          Obvious during Flee. If it reaches the exit, it escapes and drops
                          no loot. Incentivises finishing blows or Finishing Blow ability."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/ruin_scavenger.png"
}
```

---

#### Relic Guardian

```
EnemyData {
    enemyName:           "Relic Guardian"
    factionTags:         ["Arcane"]
    combatLevelMin:      63
    combatLevelMax:      69
    maxHP:               580
    damageMin:           27
    damageMax:           44
    attackCadence:       2.4s
    defense:             26
    baseAccuracy:        72
    evasionRating:       8
    blockChance:         0.12
    weakPointDesc:       "Relic Housing, SHOULDER (rectangular panel, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     10
    goldMarkDropMax:     20
    dropTable: [
        { item: "Pristine Ancient Sigil",chance: 0.35, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Starstone Fragment",    chance: 0.30, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.50, amount: "10-20"                            },
        { item: "Arcane Residue",        chance: 0.28, qualityMin: Crude,    qualityMax: Refined  }
    ]
    specialAbility:      "Relic Shield, when HP drops below 50%, activates a shimmering
                          arcane barrier that absorbs the next 50 damage. Barrier recharges
                          90s after breaking. Relic Housing Subtle becomes Obvious for 3s
                          at the moment the barrier activates."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/relic_guardian.png"
}
```

---

#### Spell-Bound Sentinel

```
EnemyData {
    enemyName:           "Spell-Bound Sentinel"
    factionTags:         ["Arcane"]
    combatLevelMin:      68
    combatLevelMax:      74
    maxHP:               490
    damageMin:           28
    damageMax:           46
    attackCadence:       2.0s
    defense:             23
    baseAccuracy:        80
    evasionRating:       14
    blockChance:         0.05
    weakPointDesc:       "Binding Rune, FOREHEAD (carved glyph, always visible, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     10
    goldMarkDropMax:     22
    dropTable: [
        { item: "Pristine Gemstone",     chance: 0.38, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Arcane Residue",        chance: 0.40, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.50, amount: "10-22"                            },
        { item: "Salvaged Component",    chance: 0.20, qualityMin: Crude,    qualityMax: Rough    }
    ]
    specialAbility:      "Arcane Burst, channels 1.5s, then releases an arcane bolt that
                          splits into three on impact. Each fragment deals 15 arcane damage.
                          18s cooldown. Binding Rune pulses Obvious during the channel."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/spell_bound_sentinel.png"
}
```

---

#### Citadel Archmage

```
EnemyData {
    enemyName:           "Citadel Archmage"
    factionTags:         ["Arcane"]
    combatLevelMin:      72
    combatLevelMax:      78
    maxHP:               430
    damageMin:           30
    damageMax:           49
    attackCadence:       2.6s
    defense:             20
    baseAccuracy:        85
    evasionRating:       18
    blockChance:         0.0
    weakPointDesc:       "Arcane Focus, CHEST (glowing orb, Obvious tier, always)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     12
    goldMarkDropMax:     25
    dropTable: [
        { item: "Pristine Void Spore",   chance: 0.35, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Aetheric Fragment",     chance: 0.30, qualityMin: Crude,    qualityMax: Refined  },
        { item: "Gold Mark",             chance: 0.50, amount: "12-25"                            },
        { item: "Pristine Gemstone",     chance: 0.18, qualityMin: Pristine, qualityMax: Pristine }
    ]
    specialAbility:      "Arcane Overload, when Arcane Focus is hit with a crit, 30% chance
                          to discharge: deals 12 arcane damage to ALL entities in range
                          (including other enemies). Rewards hitting the weak point but adds
                          tactical consideration in multi-enemy rooms."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/citadel_archmage.png"
}
```

---

#### Ruin Lord

```
EnemyData {
    enemyName:           "Ruin Lord"
    factionTags:         ["Outlaw", "Arcane"]
    combatLevelMin:      74
    combatLevelMax:      80
    maxHP:               650
    damageMin:           31
    damageMax:           49
    attackCadence:       2.2s
    defense:             26
    baseAccuracy:        78
    evasionRating:       12
    blockChance:         0.06
    weakPointDesc:       "Schematic Node, BACK (exposed node, Hidden tier)"
    weakPointTier:       Hidden
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     30
    goldMarkDropMin:     14
    goldMarkDropMax:     28
    dropTable: [
        { item: "Pristine Runic Cog",    chance: 0.42, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Lost Schematic",        chance: 0.08                                             },
        { item: "Gold Mark",             chance: 0.55, amount: "14-28"                            },
        { item: "Salvaged Component",    chance: 0.35, qualityMin: Crude,    qualityMax: Refined  }
    ]
    specialAbility:      "Schematic Overwrite, once per encounter, at 40% HP, attempts to
                          overwrite a room's patrol routing. Causes all Citadel Automatons
                          in the same room to become active (breaks patrol mode) and focus
                          the player for 8s. Has no effect if no Automatons are present."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/ruin_lord.png"
}
```

---

### Shattered Citadel Elites

---

#### Citadel Archmage [Elite variant]

```
EnemyData {
    enemyName:           "Citadel Archmage [Elite]"
    factionTags:         ["Arcane"]
    combatLevelMin:      72
    combatLevelMax:      78
    maxHP:               1,150
    damageMin:           42
    damageMax:           64
    attackCadence:       2.2s
    defense:             24
    isElite:             true
    weakPointTier:       Obvious
    slayingXPReward:     150
    goldMarkDropMin:     40
    goldMarkDropMax:     95
    dropTable: [
        { item: "Pristine Void Spore",   chance: 0.55, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Aetheric Fragment",     chance: 0.50, qualityMin: Refined,  qualityMax: Pristine },
        { item: "Gold Mark",             chance: 0.80, amount: "40-95"                            },
        { item: "Masterwork Gemstone",   chance: 0.06, qualityMin: Masterwork, qualityMax: Masterwork }
    ]
    specialAbility:      "Arcane Overload (as standard) + Mana Shield, absorbs up to 80 damage
                          before breaking. Recharges 60s. Arcane Focus glows brighter (more
                          saturated) when Mana Shield is active, dimmer when down."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/citadel_archmage_elite.png"
}
```

---

#### Ruin Lord [Elite variant]

```
EnemyData {
    enemyName:           "Ruin Lord [Elite]"
    factionTags:         ["Outlaw", "Arcane"]
    combatLevelMin:      74
    combatLevelMax:      80
    maxHP:               1,380
    damageMin:           44
    damageMax:           66
    attackCadence:       2.0s
    defense:             28
    isElite:             true
    weakPointTier:       Hidden
    slayingXPReward:     150
    goldMarkDropMin:     45
    goldMarkDropMax:     100
    dropTable: [
        { item: "Pristine Runic Cog",    chance: 0.60, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Lost Schematic",        chance: 0.15                                             },
        { item: "Gold Mark",             chance: 0.80, amount: "45-100"                           },
        { item: "Masterwork Runic Cog",  chance: 0.06, qualityMin: Masterwork, qualityMax: Masterwork }
    ]
    specialAbility:      "Schematic Overwrite (as standard, but affects ALL Automatons in all
                          adjacent rooms, not just the current room) + Command Aura: all
                          [Arcane] enemies in the same room deal +10% damage while Ruin Lord
                          is alive."
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/ruin_lord_elite.png"
}
```

---

### Arcanist Valdren the Unfinished, Zone Boss 4B

```
EnemyData {
    enemyName:           "Arcanist Valdren the Unfinished"
    factionTags:         ["Arcane"]
    isBoss:              true
    maxHP:               17,000   (solo) / 27,200 (2p) / 37,400 (3p)
    damageMin:           50
    damageMax:           76
    attackCadence:       2.0s
    defense:             28
    baseAccuracy:        84
    evasionRating:       16
    blockChance:         0.05
    weakPointDesc:       "Runic Core, CENTER MASS (Subtle P1, Obvious P2+ when shell cracks)"
    weakPointTier:       Subtle (P1) / Obvious (P2+)
    weakPointMultiplier: 2.0
    spawnChance:         0.05
    despawnTimer:        600
    slayingXPReward:     5,200
    goldMarkDropMin:     100
    goldMarkDropMax:     200
    dropTable: [
        { item: "Pristine Gemstone",     chance: 1.0,  guaranteed: true   },
        { item: "Pristine Runic Cog",    chance: 1.0,  guaranteed: true   },
        { item: "Gold Mark pouch",       chance: 1.0,  guaranteed: true, amount: "100-200" },
        { item: "Pristine Vestments piece",chance: 0.20, qualityMin: Pristine, qualityMax: Pristine },
        { item: "Valdren's Lens",        chance: 0.03 }
    ]
    bossAbilities: [
        "Arcane Bolt, slow heavy ranged attack, 3s telegraph, 50-70 damage",
        "Arcane Surge, 2 nodes active in room (persistent until boss Phase 3)",
        "Shell Crack, at 65%, construct shell visibly cracks, Runic Core goes Obvious",
        "Sentinel Summon, Phase 2: summons 1x Spell-Bound Sentinel",
        "Experiment Feedback, Phase 3: apparatus fires stray arcane bolts every 15s
         (visible reticle 2s before, random position), Arcane Surge nodes pulse 2x",
        "Overload, Phase 3 below 20%: Valdren becomes fully erratic, Arcane Bolt
         fires without telegraph, Runic Core multiplier increases to 2.5x"
    ]
    spriteRef:           "Assets/Sprites/Enemies/ShatteredCitadel/valdren_unfinished.png"
}
```

---

## Zone 5A, Ashenwold

**Primary faction:** `[Void]`
**Secondary faction:** `[Undead]`
**Slaying XP (standard):** 50 per kill
**Slaying XP (elite):** 240 per kill

---

### Standard Enemies

---

#### Ancient Void Crawler

```
EnemyData {
    enemyName:           "Ancient Void Crawler"
    factionTags:         ["Void"]
    combatLevelMin:      81
    combatLevelMax:      87
    maxHP:               670
    damageMin:           34
    damageMax:           54
    attackCadence:       2.0s
    defense:             32
    baseAccuracy:        78
    evasionRating:       14
    blockChance:         0.02
    weakPointDesc:       "Ancient Void Core, UNDERBELLY (deep purple, larger than T4 Crawler, Subtle)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     12
    goldMarkDropMax:     28
    dropTable: [
        { item: "Masterwork Void Spore", chance: 0.35, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Soulite Dust",          chance: 0.40, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.50, amount: "12-28"                               },
        { item: "Soul Essence",          chance: 0.15, qualityMin: Crude,      qualityMax: Refined   }
    ]
    specialAbility:      "Void Phase (as T4 Void Crawler), phases 1.5s every 8s.
                          Ancient version phases more frequently and the core is Subtle
                          rather than Hidden, the longer exposure from centuries in the void
                          has made the core more visible, not less."
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/ancient_void_crawler.png"
}
```

---

#### Ashen Revenant

```
EnemyData {
    enemyName:           "Ashen Revenant"
    factionTags:         ["Undead"]
    combatLevelMin:      83
    combatLevelMax:      89
    maxHP:               750
    damageMin:           35
    damageMax:           55
    attackCadence:       2.2s
    defense:             31
    baseAccuracy:        75
    evasionRating:       16
    blockChance:         0.04
    weakPointDesc:       "Soul Flame, CHEST (pale gold flame, Obvious tier, always)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     14
    goldMarkDropMax:     30
    dropTable: [
        { item: "Masterwork Phantom Pelt",chance: 0.38, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Soul Essence",          chance: 0.45, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.50, amount: "14-30"                               },
        { item: "Void Core",             chance: 0.10, qualityMin: Crude,      qualityMax: Refined   }
    ]
    specialAbility:      "Ash Shroud, when below 40% HP, envelops self in ash cloud.
                          Player evasion reduced by 10% for 6s. Soul Flame pulses brighter
                          (more obvious) inside the shroud, rewarding players who push
                          through to hit the weak point."
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/ashen_revenant.png"
}
```

---

#### Void Titan

```
EnemyData {
    enemyName:           "Void Titan"
    factionTags:         ["Void"]
    combatLevelMin:      86
    combatLevelMax:      92
    maxHP:               1,150
    damageMin:           38
    damageMax:           60
    attackCadence:       3.2s
    defense:             38
    baseAccuracy:        65
    evasionRating:       4
    blockChance:         0.12
    weakPointDesc:       "Void Heart, CHEST (massive glowing void orb, Obvious tier)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     16
    goldMarkDropMax:     35
    dropTable: [
        { item: "Masterwork Void Spore", chance: 0.42, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Void Core",             chance: 0.35, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.55, amount: "16-35"                               },
        { item: "Soulite Dust",          chance: 0.25, qualityMin: Crude,      qualityMax: Refined   }
    ]
    specialAbility:      "Void Crush, when attacked, 20% chance to retaliate with a
                          ground pound (1.5s telegraph, 2-unit radius, 25 void damage).
                          Void Heart glows brighter during the telegraph, punishes
                          players who attack without checking the counter-window."
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/void_titan.png"
}
```

---

#### Corruption Ancient

```
EnemyData {
    enemyName:           "Corruption Ancient"
    factionTags:         ["Void"]
    combatLevelMin:      88
    combatLevelMax:      94
    maxHP:               980
    damageMin:           37
    damageMax:           58
    attackCadence:       2.6s
    defense:             34
    baseAccuracy:        72
    evasionRating:       8
    blockChance:         0.06
    weakPointDesc:       "Ancient Corruption Sac, TORSO (pulsing dark mass, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     15
    goldMarkDropMax:     32
    dropTable: [
        { item: "Masterwork Ancient Sigil",chance: 0.40, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Void Shard",            chance: 0.30, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.55, amount: "15-32"                               },
        { item: "Soul Essence",          chance: 0.20, qualityMin: Crude,      qualityMax: Refined   }
    ]
    specialAbility:      "Corruption Spread, on death, applies Corruption DoT to player
                          (8 damage per second for 5s) if within 2-unit radius of the body.
                          Corruption Sac goes Obvious for the 2s before death (the sac
                          swells visibly). Rewards finishing from range."
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/corruption_ancient.png"
}
```

---

### Ashenwold Elites

---

#### Ashen Warlord [Elite]

```
EnemyData {
    enemyName:           "Ashen Warlord"
    factionTags:         ["Undead", "Void"]
    combatLevelMin:      91
    combatLevelMax:      97
    maxHP:               1,900
    damageMin:           52
    damageMax:           76
    attackCadence:       1.8s
    defense:             35
    baseAccuracy:        80
    evasionRating:       18
    blockChance:         0.08
    weakPointDesc:       "War Brand, SHOULDER PAULDRON (ancient glowing brand, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             true
    slayingXPReward:     240
    goldMarkDropMin:     60
    goldMarkDropMax:     140
    dropTable: [
        { item: "Masterwork Phantom Pelt",chance: 0.65, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Soulite Fragment",       chance: 0.50, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.80, amount: "60-140"                              },
        { item: "Soulite Crystal",       chance: 0.04, qualityMin: Crude,      qualityMax: Crude     }
    ]
    specialAbility:      "Ash Rally, War Cry that grants +15% damage and +10% attack speed
                          to all [Undead] enemies in range for 10s. War Brand glows Obvious
                          for 3s during the War Cry (counter-attack window).
                          Cannot Rally if the only [Undead] in room is itself."
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/ashen_warlord.png"
}
```

---

#### Void Archon [Elite]

```
EnemyData {
    enemyName:           "Void Archon"
    factionTags:         ["Void"]
    combatLevelMin:      94
    combatLevelMax:      100
    maxHP:               2,200
    damageMin:           55
    damageMax:           80
    attackCadence:       1.6s
    defense:             33
    baseAccuracy:        85
    evasionRating:       22
    blockChance:         0.0
    weakPointDesc:       "Archon Core, CHEST (always glowing, brilliant purple-white, Obvious)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    isElite:             true
    slayingXPReward:     240
    goldMarkDropMin:     65
    goldMarkDropMax:     150
    dropTable: [
        { item: "Masterwork Void Spore", chance: 0.70, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Void Core",             chance: 0.55, qualityMin: Refined,    qualityMax: Pristine  },
        { item: "Gold Mark",             chance: 0.80, amount: "65-150"                              },
        { item: "Soulite Crystal",       chance: 0.06, qualityMin: Crude,      qualityMax: Crude     }
    ]
    specialAbility:      "Void Cascade, on Archon Core weak-point crit, 25% chance to
                          cascade: releases a void pulse in 3-unit radius, all enemies hit
                          gain +20% damage for 5s (INCLUDING other enemies). High-skill
                          play risks buffing the room. Rewards careful target prioritisation."
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/void_archon.png"
}
```

---

### The Ashen Sovereign, Zone Boss 5A

```
EnemyData {
    enemyName:           "The Ashen Sovereign"
    factionTags:         ["Void", "Undead"]
    isBoss:              true
    maxHP:               26,000   (solo) / 41,600 (2p) / 57,200 (3p)
    damageMin:           58
    damageMax:           88
    attackCadence:       1.8s
    defense:             36
    baseAccuracy:        88
    evasionRating:       22
    blockChance:         0.04
    weakPointDesc:       "Ancient War Seal, CHEST (millennium-old command seal, Subtle P1-P2 / Obvious P3)"
    weakPointTier:       Subtle (P1-P2) / Obvious (P3)
    weakPointMultiplier: 2.0
    spawnChance:         0.067  // 1 in 15 as per zone tables
    despawnTimer:        600
    slayingXPReward:     7,800
    goldMarkDropMin:     120
    goldMarkDropMax:     250
    dropTable: [
        { item: "Masterwork Void Spore", chance: 1.0,  guaranteed: true   },
        { item: "Masterwork Phantom Pelt",chance: 1.0, guaranteed: true   },
        { item: "Gold Mark pouch",       chance: 1.0,  guaranteed: true, amount: "120-250" },
        { item: "Legendary material component",chance: 0.25              },
        { item: "Legendary weapon",      chance: 0.05                    }
    ]
    bossAbilities: [
        "Void Command, ranged void lance, 2s telegraph, 55-75 damage",
        "Ash Storm, activates zone ash hazard in the arena (Ash Storm from dungeon brief,
         persistent through the fight, one rolling pass every 20s Phase 1)",
        "Sovereign's Call, Phase 2 at 65%: summons 1x Ashen Warlord and 1x Void Archon",
        "Ancient Seal Break, at 35%, War Seal cracks visibly, goes Obvious permanently",
        "Phase 3 Enrage: Ash Storm becomes 2 simultaneous passes every 12s.
         Void Command fires double. Void Cascade triggers on every Archon Core hit
         (if Void Archon is still alive)",
        "Millennium Rage, below 15%: all damage taken reduced by 25%, all damage dealt
         +25%. The Sovereign has waited a thousand years; it is not dying easily."
    ]
    spriteRef:           "Assets/Sprites/Enemies/Ashenwold/ashen_sovereign.png"
}
```

---

## Zone 5B, Elder Reaches

**Primary faction:** `[Arcane]`
**Secondary faction:** `[Beast]`
**Slaying XP (standard):** 50 per kill
**Slaying XP (elite):** 240 per kill

---

### Standard Enemies

---

#### World Golem

```
EnemyData {
    enemyName:           "World Golem"
    factionTags:         ["Arcane"]
    combatLevelMin:      81
    combatLevelMax:      87
    maxHP:               1,000
    damageMin:           36
    damageMax:           56
    attackCadence:       3.5s
    defense:             38
    baseAccuracy:        65
    evasionRating:       2
    blockChance:         0.15
    weakPointDesc:       "World Rune, CHEST (ancient carved symbol, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     14
    goldMarkDropMax:     30
    dropTable: [
        { item: "Masterwork Gemstone",   chance: 0.40, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Starstone Ore Chunk",   chance: 0.35, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.50, amount: "14-30"                               },
        { item: "Arcane Residue",        chance: 0.20, qualityMin: Refined,    qualityMax: Pristine  }
    ]
    specialAbility:      "Stone Patience, when not in active combat (no enemy in range),
                          regenerates 15 HP per second. Cannot regenerate if the player
                          is within 3 units. World Rune goes from Subtle to near-invisible
                          during regeneration, rewards aggressive play over kiting."
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/world_golem.png"
}
```

---

#### Primordial Drake

```
EnemyData {
    enemyName:           "Primordial Drake"
    factionTags:         ["Beast"]
    combatLevelMin:      83
    combatLevelMax:      89
    maxHP:               780
    damageMin:           36
    damageMax:           57
    attackCadence:       2.4s
    defense:             32
    baseAccuracy:        76
    evasionRating:       18
    blockChance:         0.03
    weakPointDesc:       "Ancient Throat, NECK (primordial flame scar, Subtle normally / Obvious during Fire Breath)"
    weakPointTier:       Subtle / Obvious (during Fire Breath channel)
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     14
    goldMarkDropMax:     32
    dropTable: [
        { item: "Masterwork Amber",      chance: 0.40, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Drake Scale (masterwork)",chance: 0.35, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Gold Mark",             chance: 0.50, amount: "14-32"                               },
        { item: "Wyvern Heart",          chance: 0.08, qualityMin: Crude,      qualityMax: Crude     }
    ]
    specialAbility:      "Fire Breath (as Cinderpeak Drake T3, same mechanic, throat Obvious
                          during 3s channel). Primordial version: higher damage (40-58 in
                          cone), longer channel (3.5s), shorter cooldown (8s). Older and
                          faster than any T3 drake."
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/primordial_drake.png"
}
```

---

#### Elder Construct

```
EnemyData {
    enemyName:           "Elder Construct"
    factionTags:         ["Arcane"]
    combatLevelMin:      86
    combatLevelMax:      92
    maxHP:               920
    damageMin:           38
    damageMax:           59
    attackCadence:       2.6s
    defense:             36
    baseAccuracy:        74
    evasionRating:       6
    blockChance:         0.10
    weakPointDesc:       "Elder Core, CHEST (multi-faceted crystal, Subtle tier)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     16
    goldMarkDropMax:     34
    dropTable: [
        { item: "Masterwork Runic Cog",  chance: 0.42, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Grimoire Steel Fragment",chance: 0.25, qualityMin: Crude,     qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.55, amount: "16-34"                               },
        { item: "Starstone Ore Chunk",   chance: 0.20, qualityMin: Crude,     qualityMax: Refined   }
    ]
    specialAbility:      "Overclock, once per encounter, at 50% HP, increases attack speed
                          to 1.4s cadence for 10s. Elder Core pulses Obvious during Overclock.
                          After Overclock ends, construct is briefly staggered (2s, no attacks).
                          Optimal: burst damage during the stagger window after Overclock ends."
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/elder_construct.png"
}
```

---

#### Ancient Wyvern

```
EnemyData {
    enemyName:           "Ancient Wyvern"
    factionTags:         ["Beast"]
    combatLevelMin:      88
    combatLevelMax:      94
    maxHP:               1,050
    damageMin:           40
    damageMax:           63
    attackCadence:       3.0s
    defense:             34
    baseAccuracy:        70
    evasionRating:       14
    blockChance:         0.05
    weakPointDesc:       "Ancient Wing Joint, SIDE (hidden scar where wing meets body, Hidden)"
    weakPointTier:       Hidden
    weakPointMultiplier: 2.0
    isElite:             false
    slayingXPReward:     50
    goldMarkDropMin:     16
    goldMarkDropMax:     35
    dropTable: [
        { item: "Masterwork Amber",      chance: 0.44, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Wyvern Heart",          chance: 0.20, qualityMin: Crude,      qualityMax: Refined   },
        { item: "Gold Mark",             chance: 0.55, amount: "16-35"                               },
        { item: "Drake Scale (masterwork)",chance: 0.12, qualityMin: Masterwork, qualityMax: Masterwork }
    ]
    specialAbility:      "Wing Beat Shockwave, as per Highland Wyvern T3 (knockback 1.5s,
                          no damage, 15s cooldown) PLUS: the shockwave now carries 12 flat
                          damage and knocks ALL entities in range back, not just the player.
                          Elite and construct enemies are immune. Can be used to separate
                          enemy clusters. Wing joint brief-reveals Obvious during Wing Beat."
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/ancient_wyvern.png"
}
```

---

### Elder Reaches Elites

---

#### Rune Colossus [Elite]

```
EnemyData {
    enemyName:           "Rune Colossus"
    factionTags:         ["Arcane"]
    combatLevelMin:      91
    combatLevelMax:      97
    maxHP:               2,100
    damageMin:           52
    damageMax:           78
    attackCadence:       2.8s
    defense:             38
    baseAccuracy:        72
    evasionRating:       6
    blockChance:         0.14
    weakPointDesc:       "Colossus Rune Crown, HEAD (ancient crown rune, Obvious when channeling)"
    weakPointTier:       Subtle (default) / Obvious (during Rune Channel)
    weakPointMultiplier: 2.0
    isElite:             true
    slayingXPReward:     240
    goldMarkDropMin:     65
    goldMarkDropMax:     145
    dropTable: [
        { item: "Masterwork Gemstone",   chance: 0.65, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Worldtree Shard",       chance: 0.03                                                },
        { item: "Gold Mark",             chance: 0.80, amount: "65-145"                              },
        { item: "Grimoire Steel Fragment",chance: 0.30, qualityMin: Crude,     qualityMax: Refined   }
    ]
    specialAbility:      "Rune Channel, stands still for 4s channeling the Rune Crown.
                          If uninterrupted, releases a Rune Shockwave (3-unit radius, 30 arcane
                          damage). Rune Crown is Obvious for the full 4s channel. Breaking the
                          channel (any hit during channel) cancels the shockwave and briefly
                          stuns the Colossus (1.5s). High-reward interrupt opportunity."
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/rune_colossus.png"
}
```

---

#### Primordial Alpha [Elite]

```
EnemyData {
    enemyName:           "Primordial Alpha"
    factionTags:         ["Beast"]
    combatLevelMin:      94
    combatLevelMax:      100
    maxHP:               2,250
    damageMin:           55
    damageMax:           82
    attackCadence:       2.0s
    defense:             34
    baseAccuracy:        82
    evasionRating:       22
    blockChance:         0.04
    weakPointDesc:       "Alpha Throat, NECK (deepest throat scar in the Reaches, Subtle)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    isElite:             true
    slayingXPReward:     240
    goldMarkDropMin:     70
    goldMarkDropMax:     150
    dropTable: [
        { item: "Masterwork Amber",      chance: 0.70, qualityMin: Masterwork, qualityMax: Masterwork },
        { item: "Ancient Fang",          chance: 0.50, qualityMin: Crude,      qualityMax: Crude     },
        { item: "Gold Mark",             chance: 0.80, amount: "70-150"                              },
        { item: "Worldtree Shard",       chance: 0.02                                                }
    ]
    specialAbility:      "Pack Call, calls 1x Primordial Drake to assist at 60% HP.
                          Alpha Throat becomes Obvious for 4s during the Pack Call howl.
                          Drake must be killed before Alpha to prevent a second Pack Call
                          at 30% HP. If Drake is alive at 30%, Alpha howls again (same
                          4s Obvious window, but no second Drake spawns, Drake limit 1)."
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/primordial_alpha.png"
}
```

---

### The World Warden, Zone Boss 5B

```
EnemyData {
    enemyName:           "The World Warden"
    factionTags:         ["Arcane", "Beast"]
    isBoss:              true
    maxHP:               28,000   (solo) / 44,800 (2p) / 61,600 (3p)
    damageMin:           65
    damageMax:           95
    attackCadence:       2.4s
    defense:             40
    baseAccuracy:        84
    evasionRating:       16
    blockChance:         0.06
    weakPointDesc:       "World Core, CHEST (primordial rune eye, Hidden P1, Subtle P2, Obvious P3+)"
    weakPointTier:       Hidden (P1) / Subtle (P2) / Obvious (P3+)
    weakPointMultiplier: 2.0
    spawnChance:         0.067  // 1 in 15
    despawnTimer:        600
    slayingXPReward:     8,000
    goldMarkDropMin:     150
    goldMarkDropMax:     280
    dropTable: [
        { item: "Masterwork Gemstone",   chance: 1.0,  guaranteed: true   },
        { item: "Masterwork Amber",      chance: 1.0,  guaranteed: true   },
        { item: "Gold Mark pouch",       chance: 1.0,  guaranteed: true, amount: "150-280" },
        { item: "Legendary material component",chance: 0.25              },
        { item: "Worldtree Shard",       chance: 0.25                    }
    ]
    bossAbilities: [
        "World Strike, massive melee slam, 3s telegraph (ground crack lines spread out),
         3-unit radius, 60-85 damage",
        "Stone Collapse, two wide collapse sections activate per 20s cycle (as dungeon hazard,
         here applied to the open arena)",
        "Beast Summon, Phase 2 at 65%: summons 1x Ancient Wyvern and 1x Primordial Drake",
        "World Core Reveal, at 50%, outer stone shell partially crumbles. World Core
         shifts from Hidden to Subtle. Movement causes minor tremors (player movement -5%,
         the Warden's footsteps literally shake the ground)",
        "Phase 3 at 35%: World Core fully exposed (Obvious). All Stone Collapse sections
         now 4 per cycle. Beast Summon respawns one Beast if both summoned Beasts are dead.",
        "Epoch's End, below 20%: the Warden stops using Stone Collapse and instead begins
         a sustained seismic pulse (continuous low damage, 4/s to all in arena, no dodge).
         World Core multiplier rises to 2.5x. The pulse pauses for 2s after every
         World Strike, the only window without constant damage."
    ]
    spriteRef:           "Assets/Sprites/Enemies/ElderReaches/world_warden.png"
}
```

---

## New ItemData Required

The following items are referenced in the dungeon brief and enemy drop tables but
need authoring as ItemData ScriptableObjects if not already present:

| Item | Type | Notes |
|------|------|-------|
| Soul Residue | RawMaterial | T4 drop, Soulbinding pipeline input |
| Void Crystal | RawMaterial | T4 drop, Enchanting input |
| Void Core | RawMaterial | T4-T5 drop, Soulbinding/Arcane input |
| Arcane Residue | RawMaterial | T4 drop, Arcane Weaving/Artificing input |
| Aetheric Fragment | RawMaterial | T4 Archmage drop, Enchanting input |
| Lost Schematic | Craftable | Rare T4 drop, mid-tier crafting schematic (random) |
| Starstone Ore Chunk | RawMaterial | T5 Delving/Elder Reaches drop, Smelting input |
| Soulite Dust | RawMaterial | T5 Ashenwold drop, Soulbinding input |
| Soul Essence | RawMaterial | T5 drop, Soulbinding input |
| Soulite Fragment | RawMaterial | T5 elite drop, Smelting/Soulbinding input |
| Grimoire Steel Fragment | RawMaterial | T5 Elder Construct drop, Legendary crafting |
| Wyvern Heart | RawMaterial | T5 Ancient Wyvern drop, Alchemy input |
| Ancient Fang | RawMaterial | T5 Primordial Alpha drop, Legendary component |
| Worldtree Shard | RawMaterial | Legendary crafting material, 0.5% zone / 3% dungeon |
| Void Shard | RawMaterial | T4-T5 drop, Enchanting input |
| Harbinger's Mark | Accessory | Boss accessory, T4A zone boss drop |
| Valdren's Lens | Accessory | Boss accessory, T4B zone boss drop |
| Veil Sovereign's Mantle | Accessory | Boss accessory (alternate name) |
| Valdren's Apparatus Key | Accessory | Boss accessory |

Items already confirmed as existing (do not re-author):
- Pristine Void Spore, Pristine Phantom Pelt, Pristine Gemstone, Pristine Runic Cog,
  Pristine Ancient Sigil (all T4 rare materials, authored in Phase 3 pass)
- Masterwork Void Spore, Masterwork Phantom Pelt, Masterwork Gemstone, Masterwork Amber,
  Masterwork Runic Cog (T5 rare materials, should exist from zone table authoring)
- Summoner's Tome (already specced in dungeon brief)

---

## Spawn Weight Summary

### Veilborn Wastes (4A)

| Enemy | Weight | Notes |
|-------|--------|-------|
| Void Crawler | 28 | Most common |
| Veilborn Wraith | 22 | Secondary |
| Reality Shade | 20 | Mid-frequency |
| Corruption Titan | 15 | Heaviest hitter |
| Ruin Scavenger | 0 | Not in this zone |
| Total | 85 | Remaining weight = elite roll |

### Shattered Citadel (4B)

| Enemy | Weight | Notes |
|-------|--------|-------|
| Citadel Automaton | 25 | Most common |
| Relic Guardian | 22 | Second most common |
| Spell-Bound Sentinel | 20 | Mid-frequency |
| Ruin Scavenger | 15 | Less frequent |
| Citadel Archmage | 12 | Least common standard |
| Ruin Lord | 6 | Rare standard |
| Total | 100 | |

### Ashenwold (5A)

| Enemy | Weight | Notes |
|-------|--------|-------|
| Ancient Void Crawler | 28 | Most common |
| Ashen Revenant | 22 | Secondary |
| Void Titan | 18 | Heavy hitter |
| Corruption Ancient | 17 | High damage risk on death |
| Total | 85 | Remaining = elite roll |

### Elder Reaches (5B)

| Enemy | Weight | Notes |
|-------|--------|-------|
| World Golem | 25 | Most common |
| Primordial Drake | 22 | Second most common |
| Elder Construct | 20 | Mid-frequency |
| Ancient Wyvern | 18 | Less frequent, heaviest |
| Total | 85 | Remaining = elite roll |

---

*Path: docs/phase4-enemy-content-brief.md*
*Covers: 24 standard/elite enemies + 4 zone bosses across T4 and T5.*
*Prerequisite for: dungeon-room-pools-t4t5-brief.md (dungeons cannot be authored*
*until these EnemyData ScriptableObjects exist).*
*Also covers: ZoneData authoring for veilborn_wastes, shattered_citadel, ashenwold,*
*elder_reaches, and new ItemData list for T4/T5 materials and boss drops.*
