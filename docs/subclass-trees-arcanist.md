# ⚔️ Project Grimoire — Arcanist Subclass Trees
### Version 0.4

---

## 🔮 Arcanist Path Overview

**Arcanist is a category label, not a playable character.** Players choose a specific Arcanist Grimoire (Runeweaver, Summoner, Lifebinder, or Warlock DLC) — that subclass IS their identity from day one. There is no generic "base Arcanist" character.

**Arcanist path passive bonus** (applies to ALL Arcanist Grimoires):
- +2 INT baseline — reflects the Arcanist's natural arcane affinity regardless of subclass

**Permanent stat bonuses from Arcanist Grimoire combat milestones:**
| Grimoire | Level 23 | Level 38 | Level 63 | Level 81 |
|---------|---------|---------|---------|---------|
| Runeweaver | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Summoner | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Lifebinder | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Warlock (DLC) | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Bloodweaver (DLC) | INT +1 | WIL +1 | INT +2 | WIL +2 |

Stat bonuses are permanent to the character and accumulate across ALL owned Grimoires regardless of path. See docs/warfare-spec.md for full cross-path accumulation details.

**Grimoire Combat Progression:**
Combat no longer uses a shared Talent. Each Arcanist Grimoire has its own combat level (1–100) tracked independently. Purchasing a new Grimoire starts its combat progression at level 1. Combat XP from Slaying feeds the currently equipped Grimoire's combat level. Techniques and combat unlocks live on the Combat Tab of the Character Panel, not the Talents page.

**Universal Arcanist mechanics** (apply to all Arcanist Grimoires):
- Runic Constellation always active in combat — 6 active nodes per subclass (not all 8)
- Single rune casts available from Grimoire combat level 1
- 2-rune combinations unlock at Grimoire combat level 16
- Subclass alters rune behavior AND which 6 nodes are active — different constellation per subclass
- Idle fallback: auto-casts last queued single-rune spell at 60% potency
- **Targeting mechanic (universal):** Draw constellation combination → drag thumb to target before releasing. Runeweaver drags to enemies, Summoner drags to specific constructs, Lifebinder drags to allies or self. Releasing without dragging uses subclass default target.

**Subclass constellation layouts (positions 1-4 shared, 5-6 unique):**
| Position | Runeweaver | Summoner | Lifebinder |
|----------|-----------|---------|-----------|
| 1 | Ignis | Ignis | Ignis |
| 2 | Glacius | Glacius | Glacius |
| 3 | Tempest | Tempest | Tempest |
| 4 | Ventus | Ventus | Ventus |
| 5 | **Umbra** | **Terra** | **Vita** |
| 6 | **Lux** | **Umbra** | **Lux** |

---

## ✨ Grimoire of the Runeweaver
*"The world is written in runes. I am merely editing it."*

**Unlock:** Available as starting Grimoire or 500 GM
**Playstyle:** Elemental offense and battlefield control. The Runeweaver is the most straightforward Arcanist — powerful elemental combinations, crowd control, and area damage. High skill ceiling through constellation mastery but approachable for new Arcanist players.
**Idle behaviour:** Auto-casts last queued single-rune spell. At Grimoire level 100 upgrades to 2-rune auto-cast at 75% potency.
**Signature passive:** *Elemental Attunement* — all elemental damage +10% from the moment the Grimoire is equipped.
**Active nodes:** Ignis, Glacius, Tempest, Ventus, Umbra, Lux
**No crit system** — skill expression is draw speed + counter knowledge + Technique timing.

---

### Hybrid Unlock Gates
> **Constellation Spell Unlocks:** In addition to the Technique unlocks below,
> new constellation spells unlock as Grimoire combat level increases. Shared spells
> unlock at levels 16 (2-rune) and 42 (3-rune, Runeweaver: 35). Subclass-specific
> spells unlock at levels 16, 24, 44, 55, 70, and 85. See `docs/runic-constellation-spec.md`
> for the full unlock schedule. 4-rune spells unlock at level 88 for all subclasses.

Runeweaver unlocks require **Grimoire combat level** (Runeweaver Grimoire-specific, not Total Combat Level) and cross-Talent milestones focused on arcane knowledge and material mastery.

---

### 🌿 Runeweaver Tree

| Unlock | Grimoire Level | Cross-Talent Req | Type | Description |
|--------|---------------|-----------------|------|-------------|
| **Elemental Attunement** | 1 | — | Signature Passive | All elemental damage +10%. Always active from equip. |
| **Runic Inscription** | 9 | Inscription 11 | Passive | Spell scrolls crafted via Inscription give +1 charge when used by a Runeweaver. Inscription knowledge deepens rune understanding. |
| **Elemental Surge** | 17 | — | Technique | Draw Ignis+Ventus to activate — applies a 12-second self-buff. All casts during the window deal +50% damage. Appears as a buff icon with shading cooldown timer near the HP bar. Recast to refresh. 45-second cooldown after the buff expires. |
| **Counter-Element Mastery** | 24 | Runelore 18 | Passive | Runeweaver counter-element bonuses are elevated — replaces the base counter bonus rather than stacking on top. Counter pairs: Ignis↔Glacius ×1.5, Tempest↔Ventus ×1.5, Umbra↔Lux ×1.75 (Runeweaver signature). Runelore 18 required to understand elemental opposition theory. |
| **Runeforging** | 31 | Runesmithing 27 | Passive | Runeweaver can engrave weapons and armor with elemental bonuses at the Workbench — adds elemental damage type to any assembled weapon. Requires Steel-tier Runesmithing knowledge. |
| **Arcane Shield** | 38 | Arcane Weaving 22 | Technique | Draw Lux+Ventus → drag to target (self or ally) to apply a flat HP shield (absorbs damage before HP is reduced). One shield per target — recasting replaces existing shield. Shield HP scales with Runeweaver Grimoire level: Lv38=80HP · Lv55=140HP · Lv75=220HP · Lv100=320HP. 60-second cooldown. Appears as a shield buff icon with shading timer on target's frame. |
| **Constellation Flow** | 44 | — | Passive | Drawing rune combinations 20% faster without accuracy penalty. Rewards practiced active play — speed tier bonuses easier to hit. |
| **Terra Mastery** | 52 | Delving 44 | Passive | Terra rune combinations deal +30% damage and have a chance to stagger enemies. Delving knowledge of earth and stone deepens Terra rune potency. |
| **Tempest Surge** | 59 | — | Passive | All Tempest-based casts chain to 2 additional enemies automatically. No extra input needed — fires on any combination containing Tempest. Crowd control tool for multi-enemy encounters. |
| **Runic Resonance** | 66 | Runelore 58 | Passive | Cast 3 different elemental combinations in a row without repeating — the next cast deals +60% damage. Streak resets after the bonus fires or if a combination is repeated. Constellation arch pulses gold when the bonus is ready. Rewards deep spell library knowledge and intentional combo cycling. |
| **Elemental Weave** | 73 | Arcane Weaving 62 | Passive | Magical Vestments assembled while Runeweaver Grimoire is equipped gain a passive elemental resistance matching the Runeweaver's last cast element. |
| **Storm Caller** | 79 | — | Technique | Draw all 4 runes in sequence: Tempest→Ventus→Tempest→Ignis. Creates a sustained storm field dealing ongoing elemental damage to all enemies in zone for 15 seconds. Requires Grimoire combat level 79 and 4-rune depth unlock (Grimoire level 88). Heavy active play skill expression — all 4 runes must be drawn manually. 90-second cooldown. |
| **Ancient Inscription** | 86 | Runelore 84 | Passive | Elder Tongue knowledge (Runelore 84) permanently unlocks two Runeweaver-exclusive elemental modifiers: **Solaris** — all Ignis-based casts apply a fire DoT to the enemy (burn ticks 3 damage/sec for 8 seconds). **Permafrost** — all Glacius-based casts apply a slow to the enemy (enemy attack speed −25% for 5 seconds). Both modifiers are always active once unlocked — no trigger required. |
| **Runic Mastery** | 93 | Inscription 72 | Passive | All Inscription scrolls produced while Runeweaver is equipped have maximum charges automatically. Cross-Talent mastery reward. |
| **The Living Constellation** *(Level 100 capstone)* | 100 | — | Passive | Idle auto-cast upgrades to 2-rune combinations at 75% potency. The constellation moves at a thought — runes that once required focus now flow naturally. This is the beginning of true mastery, not its end. The deeper patterns of the Elder Tongue remain beyond current reach. |

---

### Technique Summary — Implementation Reference

| Technique | Trigger | Duration | Cooldown | Target |
|-----------|---------|---------|---------|--------|
| Elemental Surge | Draw Ignis+Ventus | 12s buff | 45s after expiry | Self only |
| Arcane Shield | Draw Lux+Ventus → drag to target | Until absorbed or 30s | 60s | Self or ally |
| Storm Caller | Draw Tempest→Ventus→Tempest→Ignis | 15s field | 90s | All enemies in zone |

**Buff display** — all three Techniques show as icons with shading cooldown timers in the buff row near the HP bar. Same pattern as meal buffs. Elemental Surge = flame icon, Arcane Shield = shield icon on target's frame, Storm Caller = storm cloud icon.

---

### Passive Chain — Solaris + Permafrost Interaction

At level 86 the Runeweaver becomes significantly more dangerous in sustained combat:
- Ignis cast → immediate damage + fire DoT ticking afterward
- Glacius cast → immediate damage + slow applied
- Ignis+Glacius counter combo → counter bonus damage + both DoT AND slow simultaneously

The counter-element system and Solaris/Permafrost stack naturally — the best
Runeweaver play at endgame cycles Ignis and Glacius combinations to apply both
DoT and slow while benefiting from the elevated counter bonus.

---

### Runeweaver Build Identity
The Runeweaver is the **elemental battlemage** — powerful, versatile, and rewarding to master:
- Early game: Single element mastery, learning counter-combinations
- Mid game: Elemental Surge and Arcane Shield add active Technique management; Runeforging adds crafting value
- Late game: Runic Resonance rewards deep spell variety; Storm Caller enables AoE dominance; Solaris+Permafrost make every cast compound
- Idle: Consistent single-element damage with upgrade to 2-rune idle at capstone

**Synergizes with:**
- Runelore — Counter-Element Mastery, Runic Resonance, Ancient Inscription all gate on Runelore
- Arcane Weaving — Elemental Weave gives vestments passive resistance tied to combat
- Inscription — Runic Inscription and Runic Mastery reward crafting investment
- Runesmithing — Runeforging makes the Runeweaver valuable to the crafting economy

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | INT +1 (permanent, character-wide) |
| 38 | WIL +1 (permanent, character-wide) |
| 63 | INT +2 (permanent, character-wide) |
| 81 | WIL +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---

## 👥 Grimoire of the Summoner
*"Why fight when you can delegate?"*

**Unlock:** Available as starting Grimoire or 500 GM
**Playstyle:** Backline tactician whose constructs ARE the HP pool. The Summoner fights through constructs — managing their deployment, issuing commands via the constellation, and chaining synergy combos for devastating coordinated output. The largest idle-to-active output gap of any class. Strategic depth extends into session planning — construct choice before going idle determines survivability.
**Idle behaviour:** Auto-issues single-rune commands on a 4-second rotation. Constructs auto-attack at base level (~50% of active output). No specials or synergies during idle — active commands only. Construct persists until destroyed; no queue system.
**Signature passive:** *Arcane Bond* — all active constructs gain +15% HP and +15% damage from equip. Always active.
**Active nodes:** Ignis, Glacius, Tempest, Ventus, Terra, Umbra
**No crit system** — skill expression is construct coordination, synergy timing, and command knowledge.

---

### Hybrid Unlock Gates
> **Constellation Spell Unlocks:** In addition to the Technique unlocks below,
> new constellation spells unlock as Grimoire combat level increases. Shared spells
> unlock at levels 16 (2-rune) and 42 (3-rune, Runeweaver: 35). Subclass-specific
> spells unlock at levels 16, 24, 44, 55, 70, and 85. See `docs/runic-constellation-spec.md`
> for the full unlock schedule. 4-rune spells unlock at level 88 for all subclasses.

Summoner unlocks require **Grimoire combat level** (Summoner Grimoire-specific, not Total Combat Level) and cross-Talent milestones focused on arcane construction and material knowledge.

---

### 🌿 Summoner Tree

| Unlock | Grimoire Level | Cross-Talent Req | Type | Description |
|--------|---------------|-----------------|------|-------------|
| **Arcane Bond** | 1 | — | Signature Passive | All active constructs +15% HP and +15% damage. Always active from equip. |
| **Ember Sprite** | 9 | Alchemy 13 | Construct Unlock | Conjure an Ember Sprite — high damage, low HP fire attacker. Triggered by drawing Ignis → drag to empty field position. Alchemy 13 combustion knowledge required to shape fire into construct form. |
| **Stone Golem** | 17 | Delving 21 | Construct Unlock | Conjure a Stone Golem — primary tank, highest HP, highest aggro generation. Triggered by drawing Terra → drag to field position. Delving 21 earth and stone knowledge required. |
| **Construct Surge** | 24 | — | Technique | Draw Ignis→Terra — command all active constructs to focus the same target simultaneously. All constructs deal +40% damage for 8 seconds. Buff appears as a shared construct icon with shading timer. Reusable on 30-second cooldown. |
| **Frost Shard** | 31 | Runelore 18 | Construct Unlock | Conjure a Frost Shard — utility attacker that slows enemies. Triggered by drawing Glacius → drag to field position. Runelore 18 knowledge of elemental shaping required to maintain ice form. |
| **Dual Summon** | 38 | Slaying 33 | Passive | Maintain 2 constructs simultaneously. Slaying 33 combat experience required to coordinate multiple entities in combat. |
| **Storm Wisp** | 44 | Delving 49 | Construct Unlock | Conjure a Storm Wisp — chain lightning attacker, spreads damage across multiple enemies. Triggered by drawing Tempest → drag to field position. Delving 49 deep conductive mineral knowledge required. |
| **Construct Shield** | 52 | Arcane Weaving 43 | Technique | Draw Terra→Ventus — grants all active constructs a temporary HP shield absorbing the next hit each. Shield amount scales with Grimoire level. Arcane Weaving 43 magical barrier knowledge required. 45-second cooldown. |
| **Void Shade** | 59 | Foraging 57 | Construct Unlock | Conjure a Void Shade — debuffer with near-zero aggro. Reduces enemy accuracy and drains life. Triggered by drawing Umbra → drag to field position. Foraging 57 Voidmoss knowledge of void essence required. |
| **Arcane Surge** | 66 | — | Technique | Draw Ignis→Tempest→Terra — the Summoner's major burst command. All active constructs fire their special abilities simultaneously. Uses each construct's special cooldown. Constellation 3-rune depth required (Grimoire level 42+). 60-second cooldown between uses. |
| **Summon Resilience** | 73 | Arcane Weaving 62 | Passive | All constructs permanently +25% max HP. Arcane Weaving 62 deep magical construction knowledge deepens construct durability. Stacks with Arcane Bond. |
| **Celestial Guardian** | 79 | Inscription 56 | Construct Unlock | Conjure a Celestial Guardian — support construct that heals the weakest active construct each tick and buffs Summoner INT. Triggered by drawing Lux→Terra (note: Lux is NOT in Summoner's constellation — this unlocks via the 4-rune system at Grimoire level 88, using a special Inscription-granted pattern). Inscription 56 light magic weaving required. |
| **Triple Summon** | 86 | Slaying 79 | Passive | Maintain 3 constructs simultaneously. Deep combat experience required to coordinate three entities. Enables Trinity Formation synergy from the summoner-spec command table. |
| **Construct Mastery** | 93 | Runelore 71 | Passive | All construct special ability cooldowns reduced by 25%. Active command loops run tighter — specials available more frequently. Runelore 71 understanding of elemental cycle theory required. |
| **Eternal Bond** *(Level 100 capstone)* | 100 | — | Passive | Arcane Bond bonus increases from +15% to +30% HP and damage for all active constructs. The bond between Summoner and construct deepens — constructs respond faster, hit harder, endure longer. The connection is strong. The ancient arts of construct binding speak of bonds stronger still, locked behind knowledge not yet recovered. |

---

### Technique Trigger Summary — Implementation Reference

| Technique | Rune Draw | Cooldown | Effect |
|-----------|----------|---------|--------|
| Construct Surge | Ignis→Terra | 30s | All constructs +40% damage 8s |
| Construct Shield | Terra→Ventus | 45s | All constructs absorb next hit |
| Arcane Surge | Ignis→Tempest→Terra | 60s | All construct specials fire simultaneously |

**Celestial Guardian special note:** Lux is not in the Summoner's 6-node constellation. The Celestial Guardian unlock at level 79 uses a 4-rune pattern unlocked through Inscription knowledge — available only after Grimoire level 88 (4-rune depth) and Inscription 56 are both met. Until then the Guardian cannot be summoned. This is intentional — the Celestial Guardian is the Summoner's most powerful and hardest-to-access construct.

**Idle command rotation:** Ventus (Recall if any construct at critical HP) → Terra (Golem advance) → Ignis (Sprite focus fire) → repeat.

---

### Construct Command System — Rune Draws

Each construct responds to its element rune as a command:

| Draw | Command |
|------|---------|
| Ignis | Command Ember Sprite — focus fire on primary target |
| Glacius | Command Frost Shard — slow priority target |
| Tempest | Command Storm Wisp — chain attack |
| Ventus | Recall all constructs — defensive repositioning |
| Terra | Command Stone Golem — charge/advance |
| Umbra | Command Void Shade — apply debuffs |

2-rune and 3-rune command combinations activate synergy effects — see `summoner-spec.md` for the full synergy combo table.

---

### Summoner Build Identity
The Summoner is the **tactical backline commander** — the highest skill ceiling of any base game class:
- Early game: Single construct mastery — learn each construct's strengths, use Construct Surge timing
- Mid game: Dual Summon opens Stone Golem + Storm Wisp combinations — tank + chain damage
- Late game: Triple Summon + Arcane Surge + Construct Mastery enables devastating synchronized burst windows
- Idle: Construct choice before logging off determines survivability — strategic depth extends into session planning

**Synergizes with:**
- Alchemy — Ember Sprite requires Alchemy knowledge
- Inscription — Celestial Guardian gates on Inscription 56; the hardest construct to unlock
- Arcane Weaving — Construct Shield and Summon Resilience gate on Arcane Weaving
- Runelore — Frost Shard and Construct Mastery reward Runelore investment

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | INT +1 (permanent, character-wide) |
| 38 | WIL +1 (permanent, character-wide) |
| 63 | INT +2 (permanent, character-wide) |
| 81 | WIL +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---

## 💚 Grimoire of the Lifebinder
*"They fight. I make sure they can keep fighting."*

**Unlock:** Available as starting Grimoire or 500 GM
**Playstyle:** Support and sustain built on a unique risk/reward foundation — the Lifebinder spends their own HP to heal. Passive regen and HOTs maintain sustainability; aggressive healing depletes HP; self-management IS the skill. In solo play the Lifebinder is nearly unkillable through regen. In group content they are the indispensable healer — the difference between a party surviving Tier 3+ content or not.
**Idle behaviour:** Auto-applies Mending Touch HOT to self every 8 seconds. Auto-casts Vita→self when below 50% HP. Passive HP regen always active. Best idle survivability of any Arcanist subclass.
**Signature passive:** *Life's Cost* — WIL reduces spell HP cost by 0.3% per point (max 30% at WIL 100). The Lifebinder's mastery of life magic makes healing cheaper over time. Always active from equip.
**Active nodes:** Ignis, Glacius, Tempest, Ventus, Vita, Lux (no Umbra, no Terra)
**No crit system** — skill expression is HOT management, HP resource discipline, and target prioritisation.

---

### Hybrid Unlock Gates
> **Constellation Spell Unlocks:** In addition to the Technique unlocks below,
> new constellation spells unlock as Grimoire combat level increases. Shared spells
> unlock at levels 16 (2-rune) and 42 (3-rune, Runeweaver: 35). Subclass-specific
> spells unlock at levels 16, 24, 44, 55, 70, and 85. See `docs/runic-constellation-spec.md`
> for the full unlock schedule. 4-rune spells unlock at level 88 for all subclasses.

Lifebinder unlocks require **Grimoire combat level** (Lifebinder Grimoire-specific, not Total Combat Level) and cross-Talent milestones focused on life magic and restorative knowledge.

---

### 🌿 Lifebinder Tree

| Unlock | Grimoire Level | Cross-Talent Req | Type | Description |
|--------|---------------|-----------------|------|-------------|
| **Life's Cost** | 1 | — | Signature Passive | WIL reduces all spell HP costs by 0.3% per point (max 30% at WIL 100). Passive regen 3 HP/sec + VIT×0.08 + WIL×0.05 always active in combat. Always active from equip. |
| **Mending Touch** | 9 | Cookery 14 | Technique | Draw Vita → self — applies Mending Touch HOT (+5 HP/sec for 8s). First HOT unlock. Costs 8 HP. Cookery 14 restorative ingredient knowledge deepens healing instinct. |
| **Cauterize** | 17 | Alchemy 19 | Technique | Draw Ignis → drag to target — removes all bleed and burn DoTs immediately. Costs 8 HP. Alchemy 19 knowledge of wound cauterisation required. The Lifebinder's primary debuff counter in early play. |
| **Glacial Shield** | 24 | Arcane Weaving 22 | Technique | Draw Glacius→Vita → drag to target — restores 15% HP and absorbs the target's next 2 hits. Costs 18 HP. Arcane Weaving 22 barrier knowledge required. Lifebinder's first ally-protective Technique. |
| **Rejuvenation** | 31 | — | Technique | Draw Vita→Ventus → drag to target — applies Rejuvenation HOT (+10 HP/sec for 12s). Costs 14 HP. Upgrades from Mending Touch — stronger regen, longer duration. |
| **Empathic Link** | 38 | Runelore 29 | Passive | While the Lifebinder has a HOT active on an ally, 10% of damage that ally takes is redirected to the Lifebinder instead. Passive — no trigger. Lifebinder must maintain their own regen to sustain the link. Runelore 29 life-magic theory required. |
| **Radiant Heal** | 44 | Inscription 33 | Technique | Draw Vita→Lux → drag to target — restores 20% HP and removes all debuffs from target. Costs 18 HP. Inscription 33 healing script knowledge required. Best single-target emergency heal. |
| **Lifebloom** | 52 | — | Technique | Draw Ventus→Vita → self only — applies Lifebloom HOT (+18 HP/sec for 10s). Costs 20 HP. Self-only, highest regen HOT available at this level. Enables aggressive healing without HP depletion. |
| **Divine Wind** | 59 | Inscription 44 | Technique | Draw Lux→Ventus — AoE debuff cleanse — removes all negative effects from ALL party members simultaneously. Costs 22 HP. Inscription 44 protective imbuing knowledge required. Raid essential for AoE debuff encounters. |
| **Soul Tether** | 66 | Warlock Grimoire owned* | Passive | Tether self to one ally — 15% of all damage they take is redirected to Lifebinder. Passive — always active when tethered. Reapply by reequipping the Grimoire. *Requires owning Warlock Grimoire (any level) — cross-path knowledge of soul mechanics. |
| **Sacred Renewal** | 73 | — | Technique | Draw Vita→Lux→Ventus — applies Sacred Renewal HOT (+30 HP/sec for 15s) to self. Costs 28 HP. Requires 3-rune depth (Grimoire level 42+). The Lifebinder's peak self-sustain — at maximum HOT stack enables indefinite aggressive healing. |
| **Holy Aegis** | 79 | Inscription 56 | Technique | Draw Lux→Lux→Vita — party-wide shield absorbing 20% of each member's max HP in damage. Costs 38 HP. Requires 3-rune depth. Inscription 56 required. Raid phase cooldown — use before known heavy AoE. |
| **Phoenix Wave** | 86 | — | Technique | Draw Vita→Lux→Ventus→Ignis — if cast while Lifebinder's own HP is below 20%, revives from defeat once per dungeon run with 30% HP. Costs 58 HP. Requires 4-rune depth (Grimoire level 88+). The Lifebinder's panic button — a skilled player uses it intentionally, not desperately. |
| **Mass Miracle** | 93 | Inscription 64 | Technique | Draw Vita→Vita→Lux→Lux — restores 40% HP to ALL party members and removes all debuffs simultaneously. Costs 65 HP. Requires 4-rune depth. Inscription 64 mastery required. The Lifebinder's most powerful group save. 10-minute cooldown enforced in code — not the rune system. |
| **Eternal Vigil** *(Level 100 capstone)* | 100 | — | Passive | Passive HP regen increases to 5 HP/sec base (from 3 HP/sec). VIT and WIL contributions unchanged. The regen floor rises permanently — life magic flows through the Lifebinder without effort now. A solid foundation. The deeper expressions of life and renewal, the kind that old texts only hint at, lie beyond what current study can reach. |

---

### Technique Trigger Summary — Implementation Reference

| Technique | Rune Draw | Cost | Cooldown | Notes |
|-----------|----------|------|---------|-------|
| Mending Touch | Vita→self | 8 HP | None | HOT +5/sec 8s |
| Cauterize | Ignis→target | 8 HP | None | Remove bleed/burn |
| Glacial Shield | Glacius→Vita→target | 18 HP | None | Heal 15% + absorb 2 hits |
| Rejuvenation | Vita→Ventus→target | 14 HP | None | HOT +10/sec 12s |
| Radiant Heal | Vita→Lux→target | 18 HP | None | Heal 20% + remove all debuffs |
| Lifebloom | Ventus→Vita→self | 20 HP | None | HOT +18/sec 10s |
| Divine Wind | Lux→Ventus→all | 22 HP | None | AoE debuff cleanse |
| Sacred Renewal | Vita→Lux→Ventus→self | 28 HP | None | HOT +30/sec 15s |
| Holy Aegis | Lux→Lux→Vita→all | 38 HP | None | Party shield 20% max HP |
| Phoenix Wave | Vita→Lux→Ventus→Ignis | 58 HP | Once/dungeon | Revive from defeat at <20% HP |
| Mass Miracle | Vita→Vita→Lux→Lux | 65 HP | 10 min | Party 40% heal + all debuffs |

**No cooldowns on most Techniques** — the HP cost IS the limiting resource. Casting too aggressively depletes the Lifebinder's HP pool. Mass Miracle and Phoenix Wave are the only code-enforced cooldowns due to their outsized impact.

**All draws use only Lifebinder's 6 active nodes:** Ignis, Glacius, Tempest, Ventus, Vita, Lux. No Umbra, no Terra — those nodes do not appear on the Lifebinder's constellation arch.

---

### HOT Stack — Peak Regen Calculation

A fully active Lifebinder with all HOTs running simultaneously:

```
Passive base (VIT 75, WIL 60):    11 HP/sec
+ Mending Touch:                   +5 HP/sec
+ Rejuvenation:                   +10 HP/sec
+ Lifebloom:                      +18 HP/sec
+ Sacred Renewal:                 +30 HP/sec
─────────────────────────────────────────────
Peak total regen:                  74 HP/sec
```

At this regen rate a Lifebinder can sustain aggressive 2-rune healing (16 HP cost)
every 0.2 seconds indefinitely — theoretical maximum of active Lifebinder performance.
In practice Sacred Renewal costs 28 HP to cast and requires 3-rune depth — getting
all four HOTs active simultaneously is a high-skill accomplishment.

---

### Lifebinder Build Identity
The Lifebinder is the **raid healer and party sustain engine** — self-sufficient solo, indispensable in groups:
- Early game: Mending Touch + passive regen establish the HP-as-resource loop immediately
- Mid game: Empathic Link and Radiant Heal make the Lifebinder an essential dungeon role — parties push higher tiers with one present
- Late game: Sacred Renewal + Holy Aegis + Phoenix Wave define the raid experience
- Solo: HOT stacking makes the Lifebinder nearly unkillable at appropriate zone tier — just slow to kill enemies

**Synergizes with:**
- Cookery — Mending Touch gates on Cookery; meals that boost VIT and WIL directly improve HP pool and regen
- Inscription — Radiant Heal, Divine Wind, Holy Aegis, and Mass Miracle all gate on Inscription levels
- Alchemy — Cauterize gates on Alchemy; Antidotes extend the Lifebinder's debuff management
- Arcane Weaving — Glacial Shield gates on Arcane Weaving
- Warlord (cross-path) — natural raid pairing; Warlord tanks, Lifebinder heals

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | INT +1 (permanent, character-wide) |
| 38 | WIL +1 (permanent, character-wide) |
| 63 | INT +2 (permanent, character-wide) |
| 81 | WIL +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---
- Enchanting — Aura of Warding gates on Inscription 38

---

## 🔗 Arcanist Subclass Comparison

| | Runeweaver | Summoner | Lifebinder |
|--|-----------|----------|------------|
| **Combat role** | Elemental DPS / Control | Backline tactician | Healer / Support |
| **Damage model** | Direct elemental hits | Summon damage | Minimal — sustain focused |
| **Survivability** | Moderate — Arcane Shield | High — summons absorb hits | Very high — self-heal passives |
| **Group value** | High — AoE and control | High — tank summons + debuffs | Essential — only dedicated healer |
| **Solo viability** | Strong | Strong | Moderate — slow kill speed |
| **Idle efficiency** | Good — elemental auto-cast | Good — persistent idle summon | Excellent — Vita self-heal reduces damage |
| **Skill ceiling** | Very high — constellation mastery | High — summon management | Moderate — timing cooldowns |
| **Rune constellation** | Full elemental offense | Summon-type selection | Full support effects |
| **Dungeon role** | Primary DPS | Secondary DPS / tank support | Essential healer |
| **Raid role** | AoE damage / boss phases | Summon tanking / debuff | Raid healer — required role |

---

## 📋 Deferred Arcanist Subclasses

### Grimoire of the Warlock *(DLC)*
- Soul harvesting and dark pact mechanics
- Soulbinding is the primary exclusive Talent
- Soul Reservoir passive idle loop
- Soulbinding exclusive Talent
- Soul harvesting mechanics
- *(Black Ledger deferred — may return as post-launch DLC content)*
- Full tree designed at DLC spec phase

---

*Document version 0.1 — Arcanist Subclass Trees*
*Next: Vanguard trees (Warlord, Shadowblade)*
