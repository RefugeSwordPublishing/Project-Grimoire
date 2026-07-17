---
type: implementation-brief
spec: phase2-zone-tables.md (v0.1), combat-scene-3d-brief.md (v0.1)
updated: 2026-07-11
purpose: Author all Phase 2 EnemyData ScriptableObjects for Ashfen Mire and
         Ironspine Reaches. Includes weak point data, sprite references, spawn
         weights, drop tables, and Slaying XP values. Read after
         combat-scene-3d-brief.md — weak point masks require the 3D scene.
---

# Phase 2 Enemy Content — Implementation Brief

## Prerequisites

- **3D combat scene must be built first** (`docs/combat-scene-3d-brief.md`)
  Weak point masks require `textureCoord` from 3D raycasting — not available
  in a flat 2D scene.
- **Sprite pass** — all enemies below need sprite assets before masks can be
  authored. Stub with placeholder sprites initially; add masks when sprites land.
- **`EnemyData` new fields** (add before authoring assets):

```csharp
// Add to EnemyData ScriptableObject:
public Texture2D weakPointMask;           // white = weak point region
public float weakPointMultiplier = 2.0f;  // fixed ×2.0 all enemies
public WeakPointTier weakPointTier;       // Obvious / Subtle / Hidden
public string weakPointDescription;       // "Skull — HEAD" etc. for editor reference
public int slayingXP;                     // XP awarded to Slaying talent on kill
public string[] factionTags;              // "[Undead]", "[Nature]" etc.
```

---

## Weak Point Design Principles

**Fixed multiplier:** ×2.0 damage on weak point hit — all enemies, all tiers.
**Three visibility tiers** (see `combat-scene-3d-brief.md` for implementation):

| Tier | Visual | Examples |
|------|--------|---------|
| Obvious | Always glowing — natural tell built into sprite | Mire Wraith (spectral core), Mountain Golem (crystal core), Rune Construct (rune core) |
| Subtle | Brief pulse when enemy attacks or takes damage | Bogwalker Skeleton, Rotting Soldier, Ironspine Deserter |
| Hidden | No visual tell — pattern recognition only | Bog Lurker, Ashfen Treant, Mountain Hawk |

Lone Wolf's Eye (Lone Wanderer level 38) and Deadeye (Sharpshot level 59)
reveal Hidden tier weak points with a subtle glow — same as Subtle behaviour.

---

## Zone 2A — Ashfen Mire

### Standard Enemies

---

#### Bogwalker Skeleton
```
EnemyData {
    enemyName:          "Bogwalker Skeleton"
    factionTags:        ["Undead"]
    hp:                 95
    damageMin:          10
    damageMax:          18
    spawnWeight:        25
    attackCadence:      2.0s
    weakPointDesc:      "Skull — HEAD (top 20% of sprite)"
    weakPointTier:      Subtle
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Bone Fragment",    chance: 0.60, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Crude Gemstone",   chance: 0.25, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Silver Mark",      chance: 0.40, amount: 2–8                            },
        { item: "Rough Gemstone",   chance: 0.05, qualityMin: Rough,  qualityMax: Rough  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/bogwalker_skeleton.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/bogwalker_skeleton_mask.png"
}
```
*Sprite notes: Humanoid skeleton, tattered bog-soaked rags, one arm missing.
Weak point mask: white oval covering skull only — top 20% of sprite height.*

---

#### Ashfen Treant
```
EnemyData {
    enemyName:          "Ashfen Treant"
    factionTags:        ["Nature"]
    hp:                 140
    damageMin:          12
    damageMax:          22
    spawnWeight:        15
    attackCadence:      3.0s (slow — heavy hits)
    weakPointDesc:      "Root Mass — CHEST (center 30% of sprite)"
    weakPointTier:      Hidden
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Blightbark",          chance: 0.55, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Rough Amber",         chance: 0.20, qualityMin: Rough,  qualityMax: Rough  },
        { item: "Deadwood",            chance: 0.50, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Crude Ancient Sigil", chance: 0.08, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/ashfen_treant.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/ashfen_treant_mask.png"
}
```
*Sprite notes: Twisted dead tree given crude form — gnarled limbs, hollow face in bark.
Root Mass is the tangled root cluster at the center of the trunk — no glow, Hidden tier.
Players learn this over time.*

---

#### Mire Wraith
```
EnemyData {
    enemyName:          "Mire Wraith"
    factionTags:        ["Undead"]
    hp:                 75
    damageMin:          8
    damageMax:          16
    spawnWeight:        12
    attackCadence:      1.5s (fast — lower damage)
    weakPointDesc:      "Spectral Core — CHEST (center of sprite, always glowing)"
    weakPointTier:      Obvious
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Void Spore",          chance: 0.45, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Ectoplasm",           chance: 0.35, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Crude Runic Cog",     chance: 0.10, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Silver Mark",         chance: 0.30, amount: 1–5                            }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/mire_wraith.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/mire_wraith_mask.png"
}
```
*Sprite notes: Translucent ghostly form — body partially see-through. Spectral core
is a glowing orb visible through the translucent body. Obvious tier — always pulsing
green-white. Weak point mask: circle at sprite center, ~25% of sprite area.*

---

#### Bog Lurker
```
EnemyData {
    enemyName:          "Bog Lurker"
    factionTags:        ["Nature"]
    hp:                 110
    damageMin:          14
    damageMax:          20
    spawnWeight:        22
    attackCadence:      2.5s
    weakPointDesc:      "Eye — HEAD (small target, top-right of sprite)"
    weakPointTier:      Hidden
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Bog Hide",            chance: 0.55, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Ashfen Spore",        chance: 0.30, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Crude Amber",         chance: 0.15, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Silver Mark",         chance: 0.35, amount: 3–10                           }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/bog_lurker.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/bog_lurker_mask.png"
}
```
*Sprite notes: Amphibious predator — frog/crocodile hybrid, low to ground, wide mouth.
Eye is small — deliberately a difficult target. Hidden tier, small mask. Rewards
practiced Warden players who've learned the hit zone.*

---

#### Rotting Soldier
```
EnemyData {
    enemyName:          "Rotting Soldier"
    factionTags:        ["Undead"]
    hp:                 120
    damageMin:          11
    damageMax:          19
    spawnWeight:        18
    attackCadence:      2.2s
    weakPointDesc:      "Helm visor gap — HEAD (narrow horizontal band, top 25%)"
    weakPointTier:      Subtle
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Crude Sword",         chance: 0.20, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Tarnished Mark",      chance: 0.50, amount: 3–12                           },
        { item: "Bone Fragment",       chance: 0.40, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Iron Scraps",         chance: 0.30, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/rotting_soldier.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/rotting_soldier_mask.png"
}
```
*Sprite notes: Armored humanoid skeleton in corroded plate armor. Helm has a visor
with a narrow gap — the eye slit. Subtle tier: visor pulses briefly when soldier
attacks (as if something flickers behind it). Mask is a thin horizontal strip.*

---

#### Spore Crawler
```
EnemyData {
    enemyName:          "Spore Crawler"
    factionTags:        ["Nature"]
    hp:                 65
    damageMin:          6
    damageMax:          12
    spawnWeight:        8
    attackCadence:      1.2s (fastest standard enemy)
    weakPointDesc:      "Spore Sac — CHEST (large, center of body)"
    weakPointTier:      Obvious
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Void Spore",              chance: 0.65, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Crude Aetheric Filament", chance: 0.20, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Bog Herb",                chance: 0.40, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/spore_crawler.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/spore_crawler_mask.png"
}
```
*Sprite notes: Small insectoid creature with a pulsing translucent sac on its back.
Obvious tier — sac visibly glows and pulses. Large mask — easiest weak point in
Ashfen Mire. Trade-off: lowest HP, lowest damage, rarest spawn.*

---

### Ashfen Mire Elites

#### Barrow Revenant
```
EnemyData {
    enemyName:          "Barrow Revenant"
    factionTags:        ["Undead"]
    isElite:            true
    hp:                 380
    damageMin:          18
    damageMax:          30
    spawnWeight:        N/A (elite roll)
    attackCadence:      2.5s
    specialAbility:     "Necrotic Aura — reduces player healing by 25% while active"
    weakPointDesc:      "Crown — HEAD (top 20%, ornate crown with dark gem)"
    weakPointTier:      Subtle
    weakPointMultiplier: 2.0
    slayingXP:          50
    dropTable: [
        { item: "Rough Gemstone",      chance: 0.55, qualityMin: Rough,  qualityMax: Rough  },
        { item: "Spectral Essence",    chance: 0.40, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Silver Mark",         chance: 0.70, amount: 15–40                          },
        { item: "Refined Gemstone",    chance: 0.08, qualityMin: Refined, qualityMax: Refined }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/barrow_revenant.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/barrow_revenant_mask.png"
}
```

#### Thornwood Ancient
```
EnemyData {
    enemyName:          "Thornwood Ancient"
    factionTags:        ["Nature"]
    isElite:            true
    hp:                 450
    damageMin:          20
    damageMax:          32
    spawnWeight:        N/A
    attackCadence:      3.5s (very slow, very heavy)
    specialAbility:     "Root Snare — immobilizes player for 3s"
    weakPointDesc:      "Heartwood — CHEST (glowing amber vein at core, always visible)"
    weakPointTier:      Obvious
    weakPointMultiplier: 2.0
    slayingXP:          50
    dropTable: [
        { item: "Rough Amber",         chance: 0.55, qualityMin: Rough,  qualityMax: Rough  },
        { item: "Ancient Bark",        chance: 0.45, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Blightbark",          chance: 0.60, qualityMin: Rough,  qualityMax: Refined },
        { item: "Refined Amber",       chance: 0.08, qualityMin: Refined, qualityMax: Refined }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/thornwood_ancient.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/thornwood_ancient_mask.png"
}
```

---

### Ashfen Lich — Zone Boss
```
EnemyData {
    enemyName:          "The Ashfen Lich"
    factionTags:        ["Undead", "Arcane"]
    isBoss:             true
    hp:                 2400   (solo) / 3840 (2p) / 5280 (3p) — scaled by lobby
    damageMin:          25
    damageMax:          45
    weakPointDesc:      "Phylactery — CHEST (glowing orb, 3-second vulnerability window)"
    weakPointTier:      Obvious
    weakPointMultiplier: 2.0
    slayingXP:          480
    spawnChance:        0.05  (5% after each standard kill, active only)
    despawnTimer:       600   (10 minutes)
    dropTable: [
        { item: "Rough Gemstone",      chance: 0.50, guaranteed: true  },
        { item: "Rough Void Spore",    chance: 0.50, guaranteed: true  },
        { item: "Spectral Tome",       chance: 0.05                    },
        { item: "Ashfen Lich Crown",   chance: 0.02, qualityMin: Pristine }
    ]
    bossAbilities: [
        "Necrotic Wave — AoE damage + 15% healing reduction 8s",
        "Summon Bog Wraiths — 2x Mire Wraith at 50% HP",
        "Death's Grasp — immobilize 2s then heavy damage",
        "Lich's Phylactery — if weak point not hit during 3s window, regenerate 10% HP"
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ashfen/ashfen_lich.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ashfen/ashfen_lich_mask.png"
}
```

---

## Zone 2B — Ironspine Reaches

### Standard Enemies

#### Ironspine Deserter
```
EnemyData {
    enemyName:          "Ironspine Deserter"
    factionTags:        ["Outlaw"]
    hp:                 105
    damageMin:          12
    damageMax:          20
    spawnWeight:        24
    attackCadence:      2.0s
    weakPointDesc:      "Helm gap — HEAD (top 25%, visor slit)"
    weakPointTier:      Subtle
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Iron Scraps",         chance: 0.55, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Silver Mark",         chance: 0.60, amount: 4–15                           },
        { item: "Crude Gemstone",      chance: 0.15, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Rough Leather",       chance: 0.25, qualityMin: Crude,  qualityMax: Rough  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/ironspine_deserter.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/ironspine_deserter_mask.png"
}
```

#### Mountain Golem
```
EnemyData {
    enemyName:          "Mountain Golem"
    factionTags:        ["Beast"]
    hp:                 160
    damageMin:          14
    damageMax:          24
    spawnWeight:        18
    attackCadence:      3.2s (slow, very heavy)
    weakPointDesc:      "Core Crystal — CHEST (glowing crystal visible in chest cavity)"
    weakPointTier:      Obvious
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Mountain Quartz",     chance: 0.60, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Crude Gemstone",      chance: 0.30, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Iron Ore",            chance: 0.40, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Rough Gemstone",      chance: 0.08, qualityMin: Rough,  qualityMax: Rough  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/mountain_golem.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/mountain_golem_mask.png"
}
```
*Sprite notes: Stone humanoid with a visible crystalline core in its chest —
naturally glowing blue-white. Obvious tier. Core is large — easy target but
Golem has the highest HP of all standard Ironspine enemies.*

#### Warband Raider
```
EnemyData {
    enemyName:          "Warband Raider"
    factionTags:        ["Outlaw"]
    hp:                 115
    damageMin:          13
    damageMax:          22
    spawnWeight:        22
    attackCadence:      2.1s
    weakPointDesc:      "Exposed chest plate gap — CHEST (center, horizontal slit in armor)"
    weakPointTier:      Subtle
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Rough Leather",       chance: 0.55, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Crude Sword",         chance: 0.20, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Silver Mark",         chance: 0.55, amount: 5–18                           },
        { item: "Iron Scraps",         chance: 0.35, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/warband_raider.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/warband_raider_mask.png"
}
```

#### Rune Construct
```
EnemyData {
    enemyName:          "Rune Construct"
    factionTags:        ["Arcane"]
    hp:                 130
    damageMin:          10
    damageMax:          18
    spawnWeight:        12
    attackCadence:      1.8s
    weakPointDesc:      "Rune Core — CHEST (central rune etching that glows when charging)"
    weakPointTier:      Obvious
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Crude Runic Cog",     chance: 0.65, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Arcane Dust",         chance: 0.40, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Rough Runic Cog",     chance: 0.12, qualityMin: Rough,  qualityMax: Rough  },
        { item: "Mountain Quartz",     chance: 0.25, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/rune_construct.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/rune_construct_mask.png"
}
```
*Sprite notes: Angular stone-and-metal construct covered in etched runes. Central
rune glows orange when the construct is charging an attack — Obvious tier, always
visible but most intense right before attack. Best Runic Cog source in Tier 2.*

#### Ironspine Scout
```
EnemyData {
    enemyName:          "Ironspine Scout"
    factionTags:        ["Outlaw"]
    hp:                 85
    damageMin:          10
    damageMax:          16
    spawnWeight:        16
    attackCadence:      1.6s (fast, low HP)
    weakPointDesc:      "Head — HEAD (unarmored, top 25%)"
    weakPointTier:      Hidden
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Crude Gemstone",      chance: 0.25, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Silver Mark",         chance: 0.65, amount: 3–10                           },
        { item: "Rough Leather",       chance: 0.20, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/ironspine_scout.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/ironspine_scout_mask.png"
}
```
*Sprite notes: Lightly armored, hooded figure. Head is unarmored and unprotected
but Hidden tier — no glow, no tell. Scout moves erratically making it harder to
aim. Players learn: scouts have no helm, aim high.*

#### Mountain Hawk
```
EnemyData {
    enemyName:          "Mountain Hawk"
    factionTags:        ["Beast"]
    hp:                 70
    damageMin:          9
    damageMax:          15
    spawnWeight:        8
    attackCadence:      1.4s (fastest Ironspine enemy)
    weakPointDesc:      "Wing joint — CHEST (where wing meets body, small target)"
    weakPointTier:      Hidden
    weakPointMultiplier: 2.0
    slayingXP:          10
    dropTable: [
        { item: "Feathers",            chance: 0.70, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Beast Hide",          chance: 0.35, qualityMin: Crude,  qualityMax: Crude  },
        { item: "Crude Phantom Pelt",  chance: 0.08, qualityMin: Crude,  qualityMax: Crude  }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/mountain_hawk.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/mountain_hawk_mask.png"
}
```
*Sprite notes: Large predatory bird, wings partially spread. Wing joint is a small
target area where the wing connects to the body. Hidden tier, small mask. Fast
movement makes this the hardest weak point to hit in Tier 2.*

---

### Ironspine Reaches Elites

#### Ironspine Warlord
```
EnemyData {
    enemyName:          "Ironspine Warlord"
    factionTags:        ["Outlaw"]
    isElite:            true
    hp:                 420
    damageMin:          22
    damageMax:          35
    spawnWeight:        N/A
    attackCadence:      2.3s
    specialAbility:     "War Cry — +20% damage to all nearby [Outlaw] enemies for 8s"
    weakPointDesc:      "Red-plumed helm crest — HEAD (distinctive red plume, top 20%)"
    weakPointTier:      Subtle
    weakPointMultiplier: 2.0
    slayingXP:          50
    dropTable: [
        { item: "Rough Gemstone",      chance: 0.55, qualityMin: Rough,  qualityMax: Rough  },
        { item: "Warlord's Badge",     chance: 0.40, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Silver Mark",         chance: 0.75, amount: 20–55                          },
        { item: "Refined Leather",     chance: 0.08, qualityMin: Refined, qualityMax: Refined }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/ironspine_warlord.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/ironspine_warlord_mask.png"
}
```

#### Awakened Stone Sentinel
```
EnemyData {
    enemyName:          "Awakened Stone Sentinel"
    factionTags:        ["Beast", "Arcane"]
    isElite:            true
    hp:                 500
    damageMin:          24
    damageMax:          38
    spawnWeight:        N/A
    attackCadence:      3.8s
    specialAbility:     "Stone Skin — blocks next 3 hits entirely; rune engravings
                         fade when active, pulse brightly when vulnerable"
    weakPointDesc:      "Rune Heart — CHEST (pulsing when Stone Skin drops)"
    weakPointTier:      Obvious (but only during vulnerability window)
    weakPointMultiplier: 2.0
    slayingXP:          50
    dropTable: [
        { item: "Rough Runic Cog",     chance: 0.55, qualityMin: Rough,  qualityMax: Rough  },
        { item: "Mountain Core",       chance: 0.40, qualityMin: Crude,  qualityMax: Rough  },
        { item: "Silver Mark",         chance: 0.70, amount: 18–50                          },
        { item: "Refined Runic Cog",   chance: 0.08, qualityMin: Refined, qualityMax: Refined }
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/stone_sentinel.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/stone_sentinel_mask.png"
}
```
*Implementation note: Stone Sentinel weak point glow is ONLY active when Stone Skin
is down. `UpdateWeakPointGlow()` checks `stoneSkinActive` flag — glow disabled
while Stone Skin is up, enabled when vulnerable. This is a special case beyond the
standard tier system.*

---

### Ironspine Colossus — Zone Boss
```
EnemyData {
    enemyName:          "The Ironspine Colossus"
    factionTags:        ["Beast", "Arcane"]
    isBoss:             true
    hp:                 2800 (solo) / 4480 (2p) / 6160 (3p)
    damageMin:          28
    damageMax:          48
    weakPointDesc:      "Rune Heart — CHEST (exposed only when Colossus rears back)"
    weakPointTier:      Obvious (during exposure window only)
    weakPointMultiplier: 2.0
    slayingXP:          480
    spawnChance:        0.05
    despawnTimer:       600
    dropTable: [
        { item: "Rough Gemstone",      chance: 0.50, guaranteed: true  },
        { item: "Rough Runic Cog",     chance: 0.50, guaranteed: true  },
        { item: "Colossus Core",       chance: 0.08                    },
        { item: "Ironspine Colossus Pauldrons", chance: 0.02, qualityMin: Pristine }
    ]
    bossAbilities: [
        "Seismic Slam — AoE stagger, interrupts active inputs 2s",
        "Stone Skin — absorbs next 5 hits, then Rune Heart exposed 4s",
        "Golem Summon — 2x Mountain Golem at 50% HP",
        "Ironspine Roar — all [Outlaw] enemies +15% damage 10s"
    ]
    spriteRef:          "Assets/Sprites/Enemies/Ironspine/ironspine_colossus.png"
    weakPointMaskRef:   "Assets/Sprites/Enemies/Ironspine/ironspine_colossus_mask.png"
}
```

---

## Tier 1 Weak Point Data — Retroactive

Tier 1 enemies (Grimwood Fringe + Saltmarsh Shore) need weak point data added to
their existing EnemyData assets. Add `weakPointMask`, `weakPointMultiplier`,
`weakPointTier`, and `weakPointDesc` fields to all existing Tier 1 EnemyData
ScriptableObjects.

**Quick reference — Tier 1 weak points:**

| Enemy | Weak Point | Tier | Mask region |
|-------|-----------|------|-------------|
| Grimwood Bandit | Exposed shoulder — CHEST | Subtle | Center-right, 20% of sprite |
| Grimwood Poacher | Hood gap — HEAD | Hidden | Top 25% |
| Wild Wolf | Head — HEAD | Subtle | Top 20%, pulse on howl |
| Forest Bear | Snout — HEAD | Obvious | Top 30%, large target |
| Saltmarsh Corsair | Chest gap in coat — CHEST | Subtle | Center, thin horizontal |
| Tide Lurker | Underbelly — CHEST | Hidden | Center lower, no tell |
| Saltmarsh Smuggler | Head — HEAD | Subtle | Top 25% |
| Dockside Brawler | Jaw — HEAD | Hidden | Very small, top-center |

> These don't block current Phase 1 combat — idle ignores weak points.
> Add before the Warden active-play sprite pass so the Bowstring mechanic
> has valid data on first active session.

---

## Sprite Pass Checklist — Per Enemy

For each enemy, Claude Code needs to track:

- [ ] Sprite generated in Layer.ai (pixel art model, 256×256, transparent PNG)
- [ ] Sprite imported with Point filter, PPU 100, Read/Write enabled
- [ ] Placed on Z=10 quad in combat scene
- [ ] `EnemyData.icon` assigned
- [ ] Weak point mask authored (white region = weak point)
- [ ] `EnemyData.weakPointMask` assigned
- [ ] `EnemyData.weakPointTier` set
- [ ] Weak point glow renderer attached if Obvious or Subtle tier
- [ ] `EnemyData.slayingXP` set
- [ ] Drop table populated in EnemyData

---

## Sprite Prompt Reference

**Ashfen Mire enemies — style notes:**
All use painterly pixel art style, dark fantasy. Palette: desaturated greens, greys,
sickly yellows. Bioluminescent accents (blue-green) on undead enemies.
Reference: `GrimwoodFringe_combat_02.png` at 25–30% similarity (forest → bog shift).

**Ironspine Reaches enemies — style notes:**
Warm amber/rust palette, harsh mountain light. Stone and metal textures prominent.
Outlaw enemies wear battered military gear. Construct enemies have etched rune details.
Reference: generate without reference image — use style prompt only.

See `docs/phase1-sprite-prompts.md` for standard prompt suffix and atlas format.
Enemy sprites are individual files (not atlas sheets) — 256×256 each.
Boss sprites: 320×320.

---

*Path: `docs/phase2-enemy-content-brief.md`*
