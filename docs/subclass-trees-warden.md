# Project Grimoire, Warden Subclass Trees
### Version 0.4

---

## Warden Path Overview

**Warden is a category label, not a playable character.** Players choose a specific Warden Grimoire (Sharpshot, Lone Wanderer, or Beastbond DLC), that subclass IS their identity from day one. There is no generic "base Warden" character.

**Warden path passive bonus** (applies to ALL Warden Grimoires):
- +2 DEX baseline, reflects the Warden's natural ranged affinity regardless of subclass

**Permanent stat bonuses from Warden Grimoire combat milestones:**
| Grimoire | Level 23 | Level 38 | Level 63 | Level 81 |
|---------|---------|---------|---------|---------|
| Sharpshot | DEX +1 | LCK +1 | DEX +2 | LCK +2 |
| Lone Wanderer | DEX +1 | LCK +1 | DEX +2 | LCK +2 |
| Beastbond (DLC) | DEX +1 | LCK +1 | DEX +2 | LCK +2 |

Stat bonuses are permanent to the character and accumulate across ALL owned Grimoires regardless of path. See docs/warfare-spec.md for full cross-path accumulation details.

**Grimoire Combat Progression:**
Combat no longer uses a shared Talent. Each Warden Grimoire has its own combat level (1-100) tracked independently. Purchasing a new Grimoire starts its combat progression at level 1. Combat XP from Slaying feeds the currently equipped Grimoire's combat level. Techniques and combat unlocks live on the Combat Tab of the Character Panel, not the Talents page.

**Universal Warden mechanics** (apply to all Warden Grimoires):
- Bowstring mechanic always active in combat
- Quiver equipped item enables infinite standard arrows
- Grimoire Combat Progression governs all Warden combat unlocks, not a shared Talent
- Coating buffs from Alchemy apply to quiver slot

**Bowstring tuning per subclass:**
| Subclass | Weak point glow duration | Fire rate | Damage model |
|----------|------------------------|-----------|-------------|
| Sharpshot | Longer, rewards patience and precise aim | Slow | Single massive hits |
| Lone Wanderer | Shorter, rewards speed and rapid attempts | Fast | Many smaller proc hits |

Same Bowstring mechanic, two different skill expressions. May be revisited for further mechanical distinction in a later design pass.

---

## Grimoire of the Sharpshot
*"Patience is the first weapon. Everything else is secondary."*

**Unlock:** Any player may choose this as their starting Grimoire, or purchase for 500 GM
**Playstyle:** Precision over volume. Slow, deliberate shots with massive single-hit payoff. The Sharpshot is the first Grimoire new Warden players encounter, approachable, powerful, deeply rewarding for players who invest in the draw mechanic. Every unlock deepens the single-shot mastery fantasy.
**Idle behaviour:** Auto-combat fires at reduced rate but maintains aimed targeting on highest HP enemy. Steady Hand passive always active.
**Signature passive:** *Steady Hand*, draw time +20% but damage per shot +30% from equip. Always active.
**Active mechanic:** Bowstring, press and hold to draw, drag to aim, release to fire. Weak points glow per enemy type. Draw power × weak point multiplier = damage multiplier. See `combat-engagement-spec.md`.

---

### Hybrid Unlock Gates
Sharpshot unlocks require **Grimoire combat level** (Sharpshot Grimoire-specific) and cross-Talent milestones focused on precision, crafting, and field knowledge.

---

### Sharpshot Tree

| Unlock | Grimoire Level | Cross-Talent Req | Type | Description |
|--------|---------------|-----------------|------|-------------|
| **Steady Hand** | 1 |, | Signature Passive | Draw time +20%, damage per shot +30%. Always active from equip. The Sharpshot's unhurried precision is their defining quality. |
| **Piercing Shot** | 9 | Runesmithing 6 | Technique | Triggered by full-draw release after 1.5s hold, shot penetrates the enemy and continues, dealing 60% damage to the next enemy in line. Requires reinforced arrowhead (Runesmithing 6). In zone combat: if next enemy spawns while Piercing is active, it deals carry-through damage on spawn. |
| **Hunter's Patience** | 17 |, | Passive | Each additional 0.5 seconds held at full draw adds +8% damage, up to 3 seconds (+24% max). Rewards controlled timing, the Sharpshot who waits for the perfect moment hits harder. |
| **Mark of the Hunt** | 24 | Tracking 22 | Technique | After any successful weak-point hit, the enemy is Marked for 15 seconds, all subsequent shots deal +20% damage. One mark active at a time. Tracking 22 required to recognise vulnerability patterns. |
| **Barbed Shot** | 31 | Foraging 29 | Ring Unlock | Unlocks the Barbed Shot ring slot (1.0s hold threshold). Fires a standard shot with 20% chance to apply bleed DoT, cannot stack, cannot refresh while bleed is active. Bleed scales with quiver tier. Foraging 29 knowledge of natural toxins and barbed plant matter required. Adjust proc chance during playtesting. |
| **Fletchery** | 38 | Tailoring 43 | Passive | Reinforced Quiver (Tailoring 43) unlocks a second coating slot, two different coatings can be active simultaneously. Each shot rolls against both coating proc chances independently. |
| **Sniper's Vantage** | 44 |, | Passive | Full-draw shots (held 1.5s or longer) deal an additional +15% damage on top of all other modifiers. Rewards deliberate play, the Sharpshot who commits to full draws is rewarded further. |
| **Killshot** | 52 | Slaying 46 | Technique | Triggered by releasing at full draw against any enemy below 20% HP, deals 500% damage regardless of weak point or coating. Executes the kill instantly on non-elite non-boss enemies. Slaying 46 combat experience required. 30-second cooldown. |
| **Deadeye** | 59 | Slaying 55 | Passive | Weak point glow duration +50%, more time to aim at and hit weak points accurately. The weak point detection window that was once tight becomes generous for a skilled Sharpshot. Slaying 55 elite hunting experience required. |
| **Crosswind Read** | 66 | Tracking 58 | Passive | Shots against Marked enemies have their weak point multiplier increased by ×0.25 (e.g. ×2.0 becomes ×2.25). Tracking 58 environmental reading knowledge required. The Sharpshot accounts for every variable. |
| **Armor Piercer** | 73 | Runesmithing 56 | Technique | Triggered by any full-draw shot, next shot ignores enemy armor rating entirely. 45-second cooldown. Runesmithing 56 Mithril-tier bow component knowledge required. Essential against heavily armored enemies. |
| **Sharpshot's Resolve** | 79 | Slaying 79 | Passive | After landing a weak-point hit, next shot has a guaranteed weak-point hit regardless of aim accuracy. The chain, land one perfect shot, the next is gifted. Slaying 79 elite kill experience required. |
| **The Long Shot** | 86 | Tracking 74 | Technique | Hold full draw for 5 full seconds, fires a screen-crossing shot that deals 600% damage to any enemy and ignores all armor and resistances. 5-minute cooldown. Tracking 74 trajectory calculation required. Not a finisher, an opener. The Sharpshot who begins with The Long Shot starts from a position of total dominance. |
| **Precision Mastery** | 93 |, | Passive | Steady Hand draw time bonus reduced by half (now +10% not +20%), shots are both fast AND powerful. The Sharpshot no longer sacrifices speed for precision; the two have become the same thing. |
| **Master's Draw** *(Level 100 capstone)* | 100 |, | Passive | Idle auto-combat now fires at 80% of active fire rate instead of reduced idle rate. The Sharpshot's discipline extends to muscle memory, even unattended, every motion is purposeful. A solid foundation. The truly legendary shots, the ones the old Warden texts describe, remain beyond what current training reaches. |

---

### Sharpshot Build Identity
The Sharpshot is the **precision sniper**, every unlock deepens the single-shot mastery fantasy:
- Early game: Steady Hand + Bowstring mechanic teaches draw timing and weak-point targeting
- Mid game: Mark of the Hunt, Hunter's Patience, and Sniper's Vantage stack into massive single-hit damage
- Late game: Sharpshot's Resolve, The Long Shot, and Precision Mastery create moments of devastating, controlled power
- Idle: Reduced fire rate but intelligent targeting, the Sharpshot never wastes a shot

**Synergizes with:**
- Alchemy coatings, fewer shots means each coating proc matters more; Fletchery doubles coating potential; Long Shot procs all coatings simultaneously
- Tracking, Mark of the Hunt, Deadeye, Crosswind Read, and The Long Shot all gate on Tracking
- Runesmithing, Piercing Shot and Armor Piercer both require Runesmithing investment
- Foraging, Barbed Arrow gates on Foraging 29; the bleed DoT stacks with coating DoTs
- Slaying, Killshot, Deadeye, Sharpshot's Resolve, and The Long Shot gate on Slaying milestones

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | DEX +1 (permanent, character-wide) |
| 38 | LCK +1 (permanent, character-wide) |
| 63 | DEX +2 (permanent, character-wide) |
| 81 | LCK +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---

## Grimoire of the Lone Wanderer
*"The wilderness provides. You just have to know how to ask."*

**Unlock:** Available as starting Grimoire choice or purchase for 500 GM
**Playstyle:** Self-sufficient survivalist. Rapid fire, poison proc stacking, stealth, and solo zone bonuses. Where the Sharpshot rewards precision, the Lone Wanderer rewards aggression and preparation. Built for players who want to push into higher zones solo and profit from it.
**Idle behaviour:** Auto-combat at standard fire rate with poison coating active if applied before idle. First enemy of each idle session benefits from a stealth opener bonus. Best solo idle performance of any Warden subclass.
**Signature passive:** *Wanderer's Instinct*, when playing solo (no active party), all XP gains +10% and rare drop chance +5%. Always active when no party is formed.
**Active mechanic:** Same Bowstring as Sharpshot, press, drag, release. Lone Wanderer fires faster and procs coatings on more shots but hits less hard per shot. Volume over precision.

---

### Hybrid Unlock Gates
Lone Wanderer unlocks require **Grimoire combat level** (Lone Wanderer Grimoire-specific) and cross-Talent milestones focused on self-sufficiency, stealth, and survival.

---

### Lone Wanderer Tree

| Unlock | Grimoire Level | Cross-Talent Req | Type | Description |
|--------|---------------|-----------------|------|-------------|
| **Wanderer's Instinct** | 1 |, | Signature Passive | Solo play: all XP +10%, rare drop chance +5%. Always active when no party is formed. Party of 2 or fewer counts as solo from level 86. |
| **Rapid Nock** | 9 |, | Passive | Fire rate +15%. The Lone Wanderer's first step toward coating proc stacking, more shots means more procs. |
| **Poison Proficiency** | 17 | Alchemy 19 | Passive | Poison Coating duration +25% and proc chance +10% when applied by Lone Wanderer. Alchemy 19 poison chemistry knowledge required. More coatings land, and they last longer. |
| **Fade** | 24 | Gleaning 23 | Technique | Enter stealth for 8 seconds, next shot from stealth triggers Shadow's Edge equivalent (+150% damage, displays as "Critical!"). 60-second cooldown. Gleaning 23 terrain and shadow movement knowledge required. The Lone Wanderer's combat opener. |
| **Survivalist's Cache** | 31 | Foraging 29 | Passive | Foraging in any zone has a 15% chance to yield a combat-usable herb, a minor instant HP restore (flat 40 HP) that can be consumed between shots without interrupting auto-attack. Foraging 29 field herb knowledge required. |
| **Lone Wolf's Eye** | 38 | Tracking 33 | Passive | All enemy weak points are always visible in the current zone, no Hunter's Instinct needed to reveal them. Tracking 33 monster sign reading required. The Wanderer who knows the wilderness knows where everything is vulnerable. |
| **Rapid Fire** | 44 |, | Technique | Hold draw for 0.3 seconds then release, fires 3 rapid successive shots at 65% damage each. Each shot rolls coating proc independently. Total potential: 195% damage + up to 3 coating procs in one burst. 8-second cooldown between Rapid Fire uses. |
| **Zone Mastery** | 52 | Slaying 46 | Passive | In any zone where the Lone Wanderer has killed 50+ enemies solo (tracked per zone, persistent), all drop rates in that zone +15%. Rewards dedicated solo farming of specific zones, the Wanderer who knows a zone's rhythms gets more from it. |
| **Venom Build** | 59 | Alchemy 63 | Passive | Poison Coating stacks up to 3 times on the same enemy, each stack ticks independently. Requires Shadow Blend Alchemy knowledge. With Rapid Fire, all 3 stacks can be applied in one burst. |
| **Survivor's Instinct** | 66 | Gleaning 54 | Passive | After entering and exiting stealth (Fade), the Lone Wanderer's next 5 shots have +20% coating proc chance. Stealth becomes a resource, use it to prime a coating burst window. Gleaning 54 battlefield awareness required. |
| **Survivalist's Feast** | 73 | Cookery 54 | Passive | Cookery meals consumed solo give double the buff duration for the Lone Wanderer. Self-sufficient in dungeons without needing a party Cookery provider. |
| **Outpost Knowledge** | 79 | Gleaning 63 | Passive | In zones where Gleaning is unlocked, Lone Wanderer has a bonus Scavenger's Edge proc (15% chance per kill) on top of the standard Gleaning passive. Exclusive to this subclass. Gleaning 63 Void Cache knowledge required. |
| **Apex Predator** | 86 | Slaying 79 | Passive | After killing 10 enemies in a single active session without taking damage, all DEX and LCK +8% for the remainder of the session. Wanderer's Instinct solo bonus now applies to parties of 2 or fewer. Slaying 79 required, elite-level awareness. |
| **Vanishing Act** | 93 | Shadowblade Grimoire owned* | Technique | Full stealth for 20 seconds, untargetable, coating procs continue ticking on last targeted enemy during stealth. *Requires owning Shadowblade Grimoire (any level), cross-path knowledge of shadow movement. |
| **Wanderer's Mastery** *(Level 100 capstone)* | 100 |, | Passive | Wanderer's Instinct XP bonus increases from +10% to +20% solo. Rapid Fire fires 4 shots instead of 3. The Lone Wanderer's independence is deeply ingrained, self-reliance has become reflex. A strong foundation. The deeper wilderness knowledge the wandering masters speak of, the kind that blurs the line between hunter and hunted, lies further down a path not yet fully mapped. |

---

### Lone Wanderer Build Identity
The Lone Wanderer is the **poison assassin and solo specialist**, every unlock builds toward proc stacking or self-sufficiency:
- Early game: Rapid Nock and Poison Proficiency establish the coating proc loop
- Mid game: Fade opener + Venom Build + Rapid Fire creates burst coating windows
- Late game: Apex Predator and Vanishing Act reward near-perfect play with enormous bonuses
- Idle: Poison coating persists, solo zone bonus applies, best idle solo farming of any subclass

**Synergizes with:**
- Alchemy, Poison Proficiency, Venom Build gate on Alchemy; coatings are the Lone Wanderer's primary damage tool
- Gleaning, Survivor's Instinct, Outpost Knowledge, Fade, and Vanishing Act all gate on Gleaning
- Cookery, Survivalist's Feast makes the Lone Wanderer self-sufficient in dungeons
- Shadowblade (cross-path), Vanishing Act requires Shadowblade Grimoire ownership, players who invest in both understand stealth more deeply than either alone

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | DEX +1 (permanent, character-wide) |
| 38 | LCK +1 (permanent, character-wide) |
| 63 | DEX +2 (permanent, character-wide) |
| 81 | LCK +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---

## Warden Subclass Comparison

| | Sharpshot | Lone Wanderer |
|--|-----------|---------------|
| **Fire rate** | Slow, deliberate | Fast, aggressive |
| **Damage model** | Single massive hits | Many smaller proc hits |
| **Crit focus** | High, crit zone targeting | Moderate, stealth crit opener |
| **Coating use** | Fewer shots = each proc matters | Many shots = constant proc stream |
| **Solo bonus** | None specific | Major, core identity |
| **Group value** | High, boss burst damage | Moderate, better solo |
| **Active skill ceiling** | Very high, precision rewarded | High, timing and positioning |
| **Idle efficiency** | Good, intelligent targeting | Good, poison persists |
| **Best zone** | Any, scales with bow tier | Solo zones, Wanderer's Instinct |
| **Dungeon role** | Single target DPS / boss killer | Solo dungeon runner / skirmisher |

---

## Deferred Warden Subclass

### Grimoire of the Beastbond *(DLC)*
- Tames real world creatures as permanent familiars
- User is primary damage dealer; familiars buff user stats or debuff enemies
- Beastmastery is the primary Talent (Grimoire-locked)
- Familiars active only when Beastbond Grimoire is equipped
- Full tree designed at DLC spec phase

---

*Document version 0.1, Warden Subclass Trees*
*Next: Arcanist trees (Runeweaver, Summoner, Lifebinder) · Vanguard trees (Warlord, Shadowblade)*
