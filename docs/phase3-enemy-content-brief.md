---
type: implementation-brief
spec: enemy-zone-tables.md (v0.2), dungeon-room-pools-phase3-brief.md (v1.0)
updated: 2026-07-25
path: docs/phase3-enemy-content-brief.md
purpose: Author all Phase 3 EnemyData ScriptableObjects for Dreadhollow and
         Cinderpeak. Includes weak point data, sprite references, spawn weights,
         drop tables, and Slaying XP values. Follows the same structure as
         phase2-enemy-content-brief.md. Read that doc first for shared
         EnemyData field definitions and weak point implementation notes.
---

# Phase 3 Enemy Content — Implementation Brief

## Prerequisites

Same as Phase 2:
- 3D combat scene already built (combat-scene-3d-brief.md)
- Weak point masks authored in Aseprite after sprites are approved
- EnemyData ScriptableObject fields already exist from Phase 2

Sprite folder convention:
- `Assets/Sprites/Enemies/Dreadhollow/` for Zone 3A enemies
- `Assets/Sprites/Enemies/Cinderpeak/` for Zone 3B enemies

---

## Stat Scaling Notes

T3 enemies occupy combat levels 41-60 and deal 18-35 damage per hit (zone table).
HP and damage are scaled roughly 1.8-2.0x Phase 2 standard enemies.
Elites are roughly 3.5x standard HP, same as Phase 2 ratio.
Zone boss HP uses the same lobby-scaling formula as Phase 2 bosses.
Gold Mark replaces Silver Mark as the primary currency drop at T3.

---

## Zone 3A, Dreadhollow

**Primary faction:** `[Undead]`
**Secondary faction:** `[Void]`
**Slaying XP (standard):** 18 per kill
**Slaying XP (elite):** 90 per kill

---

### Standard Enemies

---

#### Dreadhollow Revenant

```
EnemyData {
    enemyName:           "Dreadhollow Revenant"
    factionTags:         ["Undead"]
    hp:                  200
    damageMin:           18
    damageMax:           28
    spawnWeight:         28
    attackCadence:       2.2s
    weakPointDesc:       "Helm visor slit — HEAD (narrow horizontal band, top 25%)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    slayingXP:           18
    dropTable: [
        { item: "Grave Cloth",         chance: 0.55, qualityMin: Crude,   qualityMax: Refined },
        { item: "Bone Fragment",       chance: 0.45, qualityMin: Crude,   qualityMax: Rough   },
        { item: "Gold Mark",           chance: 0.50, amount: 2-8                              },
        { item: "Refined Phantom Pelt", chance: 0.04, qualityMin: Refined, qualityMax: Refined }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/dreadhollow_revenant.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/dreadhollow_revenant_mask.png"
}
```
*Sprite notes: Armored undead in corroded plate, void energy seeping from joints.
Visor slit pulses briefly when attacking. Subtle tier. Thin horizontal mask strip.*

---

#### Void Shade

```
EnemyData {
    enemyName:           "Void Shade"
    factionTags:         ["Void"]
    hp:                  145
    damageMin:           16
    damageMax:           26
    spawnWeight:         20
    attackCadence:       1.8s (fast — phases in and out)
    weakPointDesc:       "Void Core — CHEST (glowing orb at center, always visible)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Phases out for 1.5s every 8s — untargetable while phased"
    dropTable: [
        { item: "Refined Void Spore",  chance: 0.50, qualityMin: Refined, qualityMax: Refined },
        { item: "Shadow Essence",      chance: 0.30, qualityMin: Crude,   qualityMax: Rough   },
        { item: "Void Ichor",          chance: 0.25, qualityMin: Crude,   qualityMax: Crude   },
        { item: "Gold Mark",           chance: 0.40, amount: 1-5                              }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/void_shade.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/void_shade_mask.png"
}
```
*Sprite notes: Near-featureless translucent humanoid silhouette of void energy.
Core always glowing purple-white at chest center. Obvious tier. Large circular mask.
Phase-out behavior: sprite fades to 20% opacity while phased — weak point invisible
and untargetable during phase. Resumes full opacity on reentry.*

---

#### Bone Archer

```
EnemyData {
    enemyName:           "Bone Archer"
    factionTags:         ["Undead"]
    hp:                  160
    damageMin:           20
    damageMax:           30
    spawnWeight:         22
    attackCadence:       3.0s (slow — ranged, telegraphed)
    weakPointDesc:       "Skull — HEAD (oval, top 22% of sprite)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Ranged attacker — fires from elevated position if room
                          has raised terrain. Maintains distance from player."
    dropTable: [
        { item: "Bone Fragment",       chance: 0.60, qualityMin: Crude,   qualityMax: Rough   },
        { item: "Grave Cloth",         chance: 0.35, qualityMin: Crude,   qualityMax: Crude   },
        { item: "Void Spore",          chance: 0.20, qualityMin: Crude,   qualityMax: Rough   },
        { item: "Gold Mark",           chance: 0.45, amount: 2-7                              },
        { item: "Refined Ancient Sigil", chance: 0.03, qualityMin: Refined, qualityMax: Refined }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/bone_archer.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/bone_archer_mask.png"
}
```
*Sprite notes: Skeletal archer with bare ribs visible, tattered hood, black dead-wood bow.
Skull at top 22%. Subtle: hollow eye sockets glow faintly when drawing bow. Oval mask.*

---

#### Corruption Beast

```
EnemyData {
    enemyName:           "Corruption Beast"
    factionTags:         ["Void"]
    hp:                  220
    damageMin:           22
    damageMax:           35
    spawnWeight:         15
    attackCadence:       2.8s (heavy charge attack)
    weakPointDesc:       "Void Core — CHEST underside (no glow, Hidden tier)"
    weakPointTier:       Hidden
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Charge — telegraphs with a low growl, rushes forward,
                          deals 1.4x damage if it connects. 8s cooldown."
    dropTable: [
        { item: "Refined Void Spore",  chance: 0.40, qualityMin: Refined, qualityMax: Refined },
        { item: "Void Ichor",          chance: 0.50, qualityMin: Crude,   qualityMax: Rough   },
        { item: "Shadow Essence",      chance: 0.15, qualityMin: Crude,   qualityMax: Crude   },
        { item: "Gold Mark",           chance: 0.50, amount: 3-10                             }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/corruption_beast.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/corruption_beast_mask.png"
}
```
*Sprite notes: Warped wolf-like void creature, body dissolving at edges.
Core hidden on underside of chest — no glow, no tell. Hidden tier.
Mask: small oval on lower-center of sprite. Players discover this through
experimentation or Lone Wanderer's Lone Wolf's Eye.*

---

### Dreadhollow Elites

---

#### Wight Commander

```
EnemyData {
    enemyName:           "Wight Commander"
    factionTags:         ["Undead"]
    isElite:             true
    hp:                  780
    damageMin:           28
    damageMax:           42
    spawnWeight:         N/A (elite roll)
    attackCadence:       2.0s
    specialAbility:      "War Cry — +20% damage to self and nearby undead for 8s.
                          Fires at combat start and every 20s thereafter."
    weakPointDesc:       "Helm crest — HEAD (top 20%, pulses on War Cry only)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    slayingXP:           90
    dropTable: [
        { item: "Refined Phantom Pelt", chance: 0.55, qualityMin: Refined, qualityMax: Refined },
        { item: "Grave Cloth",          chance: 0.50, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",            chance: 0.80, amount: 20-60                            },
        { item: "Pristine Phantom Pelt", chance: 0.08, qualityMin: Pristine, qualityMax: Pristine }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/wight_commander.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/wight_commander_mask.png"
}
```
*Crest only glows during War Cry (8s window). Outside that window: Hidden tier
behavior. Players who time shots to the War Cry get double damage during the
window — high-skill reward. Amber-gold elite trim on helm crest and pauldrons.*

---

#### Void Stalker

```
EnemyData {
    enemyName:           "Void Stalker"
    factionTags:         ["Void"]
    isElite:             true
    hp:                  680
    damageMin:           25
    damageMax:           40
    spawnWeight:         N/A
    attackCadence:       1.6s (fastest elite in Phase 3)
    specialAbility:      "Void Step — teleports behind player every 12s,
                          next attack from behind deals 1.6x damage."
    weakPointDesc:       "Void Crystal — CHEST (always glowing, large target)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    slayingXP:           90
    dropTable: [
        { item: "Refined Ancient Sigil", chance: 0.55, qualityMin: Refined, qualityMax: Refined },
        { item: "Void Crystal",          chance: 0.45, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",             chance: 0.80, amount: 18-55                            },
        { item: "Pristine Void Spore",   chance: 0.08, qualityMin: Pristine, qualityMax: Pristine }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/void_stalker.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/void_stalker_mask.png"
}
```
*Large obvious crystal on chest. Easy weak point, dangerous enemy. The combination
is intentional: players are rewarded for staying focused on the target while
managing the teleport threat. Amber-gold elite trim as luminous edge on silhouette.*

---

### The Hollow Archbishop — Zone Boss

```
EnemyData {
    enemyName:           "The Hollow Archbishop"
    factionTags:         ["Undead", "Void"]
    isBoss:              true
    hp:                  9200   (solo) / 14720 (2p) / 20240 (3p)
    damageMin:           35
    damageMax:           55
    weakPointDesc:       "Corrupted Holy Symbol — CHEST (Subtle Phase 1, Obvious Phase 2+)"
    weakPointTier:       Subtle   (Phase 1) / Obvious (Phase 2+)
    weakPointMultiplier: 2.0
    slayingXP:           2800
    spawnChance:         0.05  (5% per encounter, active play only)
    despawnTimer:        600
    dropTable: [
        { item: "Refined Phantom Pelt",  chance: 1.0, guaranteed: true  },
        { item: "Refined Void Spore",    chance: 1.0, guaranteed: true  },
        { item: "Gold Mark pouch",       chance: 1.0, guaranteed: true, amount: 50-120 },
        { item: "Archbishop's Vestments", chance: 0.15, qualityMin: Refined, qualityMax: Pristine },
        { item: "Archbishop's Seal",     chance: 0.03 }
    ]
    bossAbilities: [
        "Bone Lance — ranged projectile, 2s telegraph, deals 28-38 damage",
        "Void Corruption Aura — Phase 2+: void seep patches spread across combat floor",
        "Summon Void Shade — Phase 2: spawns 1x Void Shade at 65% HP",
        "Void Surge — Phase 3: rapid-fire Bone Lance, 3 shots in 2.5s, no telegraph pause",
        "Holy Symbol Pulse — weak point window 15s interval (Phase 2+), 7s interval (Phase 3)"
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/hollow_archbishop.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/hollow_archbishop_mask.png"
}
```
*Phase transitions at 65% HP (Phase 2) and 35% HP (Phase 3).
Holy Symbol mask: oval at chest center, ~20% of sprite area.
Phase 1: mask renders at 50% opacity (Subtle). Phase 2+: full white (Obvious).
Also used as Gravenspire dungeon boss at reduced HP (8,400 solo).*

---

## Zone 3B, Cinderpeak

**Primary faction:** `[Beast]`
**Secondary faction:** `[Arcane]`
**Slaying XP (standard):** 18 per kill
**Slaying XP (elite):** 90 per kill

---

### Standard Enemies

---

#### Cinderpeak Drake

```
EnemyData {
    enemyName:           "Cinderpeak Drake"
    factionTags:         ["Beast"]
    hp:                  195
    damageMin:           18
    damageMax:           28
    spawnWeight:         28
    attackCadence:       2.4s
    weakPointDesc:       "Throat ember — NECK (center front, subtle glow when attacking)"
    weakPointTier:       Subtle
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Fire Breath — 2.5s channel telegraph, deals 22-32 damage
                          in a cone. Throat fully exposed during channel (Obvious
                          tier behavior during that window only). 12s cooldown."
    dropTable: [
        { item: "Drake Scale",         chance: 0.45, qualityMin: Refined, qualityMax: Refined },
        { item: "Refined Amber",       chance: 0.30, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",           chance: 0.55, amount: 3-10                             },
        { item: "Drake Fang",          chance: 0.08, qualityMin: Crude,   qualityMax: Refined }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/cinderpeak_drake.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/cinderpeak_drake_mask.png"
}
```
*Style anchor for the zone. Generate first.
Throat mask: vertical oval at center-front of neck. Subtle outside Fire Breath,
Obvious during channel. Mask renders at 40% opacity normally, 100% during channel.*

---

#### Fire Elemental

```
EnemyData {
    enemyName:           "Fire Elemental"
    factionTags:         ["Arcane"]
    hp:                  155
    damageMin:           20
    damageMax:           30
    spawnWeight:         20
    attackCadence:       2.0s
    weakPointDesc:       "Flame Core — CHEST (white-yellow core, always glowing)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Ember Burst — on death, explodes for 14-20 AoE damage
                          in a small radius. Telegraph: body flickers rapidly
                          for 1.5s before death burst fires."
    dropTable: [
        { item: "Ember Core",          chance: 0.65, qualityMin: Refined, qualityMax: Refined },
        { item: "Refined Gemstone",    chance: 0.25, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",           chance: 0.45, amount: 2-8                              },
        { item: "Void Spore",          chance: 0.10, qualityMin: Crude,   qualityMax: Rough   }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/fire_elemental.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/fire_elemental_mask.png"
}
```
*Core always glowing white-yellow at chest center. Obvious tier. Large circular mask.
Death burst is the unique hazard — players should finish from range or step back
when the flicker telegraph starts. Works identically during idle (auto-combat
does not step back — idle players take the burst damage).*

---

#### Highland Wyvern

```
EnemyData {
    enemyName:           "Highland Wyvern"
    factionTags:         ["Beast"]
    hp:                  250
    damageMin:           22
    damageMax:           35
    spawnWeight:         15
    attackCadence:       3.2s (slow, very heavy)
    weakPointDesc:       "Wing joint — SIDE (where wing meets body, no glow)"
    weakPointTier:       Hidden
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Wing Beat — knockback 1.5s, no damage, 15s cooldown.
                          Creates distance — follow-up attack comes immediately
                          after the knockback ends."
    dropTable: [
        { item: "Wyvern Hide",         chance: 0.50, qualityMin: Refined, qualityMax: Refined },
        { item: "Wyvern Talon",        chance: 0.30, qualityMin: Crude,   qualityMax: Refined },
        { item: "Refined Amber",       chance: 0.20, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",           chance: 0.50, amount: 4-12                             }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/highland_wyvern.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/highland_wyvern_mask.png"
}
```
*Largest standard enemy in Cinderpeak. Wing joint mask: small oval at the
connection point where the wing folds against the body — center-side of sprite.
No glow, Hidden tier. Players who discover it get consistent crits on the slowest
but hardest-hitting standard enemy in the zone.*

---

#### Lava Construct

```
EnemyData {
    enemyName:           "Lava Construct"
    factionTags:         ["Arcane"]
    hp:                  210
    damageMin:           20
    damageMax:           32
    spawnWeight:         17
    attackCadence:       2.8s
    weakPointDesc:       "Chest rune — CHEST (always glowing orange-red)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    slayingXP:           18
    specialBehavior:     "Lava Splash — on taking weak point hit, 20% chance to
                          splash lava in a small radius, 8 damage to player.
                          Risk/reward for aiming at the obvious weak point."
    dropTable: [
        { item: "Refined Runic Cog",   chance: 0.40, qualityMin: Refined, qualityMax: Refined },
        { item: "Starstone Fragment",  chance: 0.25, qualityMin: Crude,   qualityMax: Refined },
        { item: "Arcane Residue",      chance: 0.45, qualityMin: Crude,   qualityMax: Rough   },
        { item: "Gold Mark",           chance: 0.50, amount: 3-10                             }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/lava_construct.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/lava_construct_mask.png"
}
```
*Central chest rune always glowing orange-red. Obvious tier, easy to see.
The Lava Splash counter punishes spam aiming at the weak point — player must
decide whether the double damage is worth the retaliation risk. Unique dynamic
not present in Phase 1 or 2 weak points.*

---

### Cinderpeak Elites

---

#### Drake Pack Alpha

```
EnemyData {
    enemyName:           "Drake Pack Alpha"
    factionTags:         ["Beast"]
    isElite:             true
    hp:                  820
    damageMin:           30
    damageMax:           46
    spawnWeight:         N/A
    attackCadence:       2.0s
    specialAbility:      "Pack Call — summons 1x Cinderpeak Drake at 70% and 40% HP.
                          Summoned drakes despawn if Alpha dies."
    weakPointDesc:       "Throat ember — NECK (Obvious only during Fire Breath channel)"
    weakPointTier:       Obvious   (during Fire Breath only, Subtle otherwise)
    weakPointMultiplier: 2.0
    slayingXP:           90
    dropTable: [
        { item: "Drake Scale",          chance: 0.65, qualityMin: Refined, qualityMax: Refined },
        { item: "Refined Amber",        chance: 0.55, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",            chance: 0.80, amount: 25-65                            },
        { item: "Pristine Amber",       chance: 0.08, qualityMin: Pristine, qualityMax: Pristine }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/drake_pack_alpha.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/drake_pack_alpha_mask.png"
}
```
*Use Cinderpeak Drake as 30% style reference — same species, larger and scarred.
Same throat mask position as standard Drake. Weak point behavior identical to
standard Drake but Pack Call makes the fight more chaotic. Amber-gold elite
trim on horn tips and crest ridge.*

---

#### Greater Fire Elemental

```
EnemyData {
    enemyName:           "Greater Fire Elemental"
    factionTags:         ["Arcane"]
    isElite:             true
    hp:                  720
    damageMin:           28
    damageMax:           44
    spawnWeight:         N/A
    attackCadence:       1.8s
    specialAbility:      "Flame Nova — AoE fire burst around itself every 15s,
                          deals 20-28 damage in a large radius. Telegraph: body
                          expands visibly for 2s before firing."
    weakPointDesc:       "Brilliant core — CHEST (always glowing white, larger than standard)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    slayingXP:           90
    dropTable: [
        { item: "Refined Gemstone",     chance: 0.60, qualityMin: Refined, qualityMax: Refined },
        { item: "Ember Shard",          chance: 0.45, qualityMin: Refined, qualityMax: Refined },
        { item: "Gold Mark",            chance: 0.80, amount: 22-60                            },
        { item: "Pristine Gemstone",    chance: 0.08, qualityMin: Pristine, qualityMax: Pristine }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/greater_fire_elemental.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/greater_fire_elemental_mask.png"
}
```
*Use Fire Elemental as 30% style reference — taller, deeper crimson-red outer
flame, larger brilliant white core. Core mask is larger than standard Elemental.
Death burst also larger AoE (1.5x radius). Amber-gold trim as golden ring at waist.*

---

### Ignarath the Ashborn — Zone Boss

```
EnemyData {
    enemyName:           "Ignarath the Ashborn"
    factionTags:         ["Beast"]
    isBoss:              true
    hp:                  10400   (solo) / 16640 (2p) / 22880 (3p)
    damageMin:           38
    damageMax:           58
    weakPointDesc:       "Throat scales — NECK (Subtle normal, Obvious during Fire Breath channel only)"
    weakPointTier:       Subtle   (normal) / Obvious (Fire Breath channel)
    weakPointMultiplier: 2.0
    slayingXP:           3000
    spawnChance:         0.05
    despawnTimer:        600
    dropTable: [
        { item: "Refined Amber",        chance: 1.0, guaranteed: true  },
        { item: "Drake Scale",          chance: 1.0, guaranteed: true  },
        { item: "Gold Mark pouch",      chance: 1.0, guaranteed: true, amount: 60-140 },
        { item: "Wyvern Hide Armor",    chance: 0.15, qualityMin: Refined, qualityMax: Pristine },
        { item: "Ignarath's Fang",      chance: 0.03 }
    ]
    bossAbilities: [
        "Claw Swipe — melee, 2.0s telegraph, deals 38-50 damage",
        "Fire Breath — 3s channel, throat exposed (Obvious), 45-65 damage in cone. 12s cooldown.",
        "Lava Surge — Phase 2+: slams ground, lava wave crosses floor. Dodge roll required. 10s cooldown.",
        "Pack Call — Phase 2: summons 1x Drake Pack Alpha at 70% HP",
        "Phase 3 Enrage — Fire Breath channel animation removed, throat exposed only 1.5s post-breath",
        "Phase 3 Lava Surge — every 8s instead of 10s"
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/ignarath_ashborn.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/ignarath_ashborn_mask.png"
}
```
*Phase transitions at 70% HP (Phase 2) and 40% HP (Phase 3).
Throat mask: vertical oval at neck center-front.
Normal stance: mask at 35% opacity (Subtle). Fire Breath channel: 100% (Obvious).
Phase 3: channel animation removed — mask goes Obvious for 1.5s after breath ends,
then back to Subtle. Tightest boss weak point window in Phase 3.*

---

## Dungeon Bosses

---

### Ignarath's Broodmother — Ignarath's Maw

```
EnemyData {
    enemyName:           "Ignarath's Broodmother"
    factionTags:         ["Beast"]
    isBoss:              true
    isDungeonBoss:       true
    dungeonId:           "ignarath_maw"
    hp:                  7800   (solo) / 12480 (2p) / 17160 (3p)
    damageMin:           32
    damageMax:           52
    weakPointDesc:       "Egg Sac — ABDOMEN (always glowing orange-red, large target)"
    weakPointTier:       Obvious
    weakPointMultiplier: 2.0
    slayingXP:           2200
    dropTable: [
        { item: "Refined Amber",        chance: 1.0, guaranteed: true  },
        { item: "Drake Scale",          chance: 1.0, guaranteed: true  },
        { item: "Gold Mark pouch",      chance: 1.0, guaranteed: true, amount: 40-100 },
        { item: "Wyvern Hide Armor",    chance: 0.20, qualityMin: Refined, qualityMax: Pristine },
        { item: "Summoner's Tome",      chance: 0.05 }
    ]
    bossAbilities: [
        "Tail Whip — sweeping melee, 1.8s telegraph, 28-40 damage",
        "Egg Spit — launches 2 egg projectiles, hatch on impact into 2x Drake Hatchlings (4 HP each)",
        "Protective Surge — Phase 2: egg sac glows more intensely, next hit on egg sac deals 2.5x instead of 2.0x",
        "Enrage — Phase 3: Egg Spit fires 4 projectiles instead of 2, Tail Whip cooldown halved"
    ]
    spriteRef:           "Assets/Sprites/Enemies/Cinderpeak/ignaraths_broodmother.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Cinderpeak/ignaraths_broodmother_mask.png"
}
```
*Distinct from zone boss Ignarath — broader build, lower protective stance,
egg sac on lower abdomen always glowing. Egg sac mask: large oval on lower
body center. Phase 2 Protective Surge means the weak point temporarily hits
even harder — rewards players who saved their best shot for Phase 2.*

---

### The Hollow Archbishop — Gravenspire Dungeon Boss

```
EnemyData {
    enemyName:           "The Hollow Archbishop"
    factionTags:         ["Undead", "Void"]
    isBoss:              true
    isDungeonBoss:       true
    dungeonId:           "gravenspire"
    hp:                  8400   (solo) / 13440 (2p) / 18480 (3p)
    damageMin:           35
    damageMax:           55
    // All other fields identical to zone boss version
    // Reduced HP only — same abilities, same phase thresholds, same drops
    // with the following adjustment:
    dropTable: [
        { item: "Refined Phantom Pelt",  chance: 1.0, guaranteed: true  },
        { item: "Refined Void Spore",    chance: 1.0, guaranteed: true  },
        { item: "Gold Mark pouch",       chance: 1.0, guaranteed: true, amount: 45-110 },
        { item: "Archbishop's Vestments", chance: 0.20, qualityMin: Refined, qualityMax: Pristine },
        { item: "Summoner's Tome",       chance: 0.05 }
    ]
    spriteRef:           "Assets/Sprites/Enemies/Dreadhollow/hollow_archbishop.png"
    weakPointMaskRef:    "Assets/Sprites/Enemies/Dreadhollow/hollow_archbishop_mask.png"
}
```
*Reuses zone boss sprite and mask assets. Dungeon version is the same encounter
at 91% HP of the zone boss version. Summoner's Tome appears here instead of the
Archbishop's Seal (dungeon bosses drop the Tome, zone bosses drop accessories).*

---

## Spawn Weight Summary

### Dreadhollow Standard Enemy Weights

| Enemy | Weight | Notes |
|-------|--------|-------|
| Dreadhollow Revenant | 28 | Most common — humanoid, readable |
| Bone Archer | 22 | Second most common — ranged threat |
| Void Shade | 20 | Mid-frequency — phasing mechanic |
| Lava Construct | 0 | Not in Dreadhollow |
| Corruption Beast | 15 | Less frequent — charge specialist |
| Total | 85 | Remaining weight reserved for elite roll |

### Cinderpeak Standard Enemy Weights

| Enemy | Weight | Notes |
|-------|--------|-------|
| Cinderpeak Drake | 28 | Most common — style anchor |
| Fire Elemental | 20 | Mid-frequency — death burst risk |
| Lava Construct | 17 | Mid-frequency — weak point gamble |
| Highland Wyvern | 15 | Less frequent — heaviest hitter |
| Total | 80 | Remaining weight reserved for elite roll |

---

## First Clear Bonus

```csharp
// On dungeon boss defeat (Phase 3):
if (IsFirstClear(playerId, dungeonId)) {
    CombatXPManager.AwardXP(equippedGrimoire, 2000);
    PlayerPrefs.SetInt($"dungeon_cleared_{dungeonId}", 1);
}
```

Same value as defined in dungeon-room-pools-phase3-brief.md.

---

## Accessory Items

Two new accessory items introduced as rare zone boss drops. No stats defined
here — accessory system design is deferred. These are placeholder named items
that exist in the item registry:

**Archbishop's Seal** — Rare drop from The Hollow Archbishop (zone boss only).
Effect (placeholder): `[Undead] dmg +8%, void resistance +10%`

**Ignarath's Fang** — Rare drop from Ignarath the Ashborn (zone boss only).
Effect (placeholder): `[Beast] dmg +8%, fire resistance +12%`

These items should be authored as ItemData ScriptableObjects with
`itemType = Accessory` and `equipped = false` until the accessory
equipment system is built.

---

*Path: docs/phase3-enemy-content-brief.md*
*Covers: Dreadhollow (4 standard, 2 elite, 1 zone boss, 1 dungeon boss),*
*Cinderpeak (4 standard, 2 elite, 1 zone boss, 1 dungeon boss).*
*New mechanics: Void Shade phase-out, Lava Construct weak point retaliation,*
*Drake channel-dependent weak point tier, Ignarath Phase 3 telegraph removal.*
