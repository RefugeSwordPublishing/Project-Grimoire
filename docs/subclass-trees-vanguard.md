# ⚔️ Project Grimoire — Vanguard Subclass Trees
### Version 0.4

---

## ⚔️ Vanguard Path Overview

**Vanguard is a category label, not a playable character.** Players choose a specific Vanguard Grimoire (Warlord, Shadowblade, or Kensei DLC) — that subclass IS their identity from day one. There is no generic "base Vanguard" character.

**Vanguard path passive bonus** (applies to ALL Vanguard Grimoires):
- +2 STR baseline — reflects the Vanguard's natural melee affinity regardless of subclass
- Carry weight bonus — all Vanguard Grimoires hold more materials in field inventory than other paths

**Grimoire Combat Progression:**
Combat no longer uses a shared Talent. Each Vanguard Grimoire has its own combat level (1–100) tracked independently. Purchasing a new Grimoire starts its combat progression at level 1. Combat XP from Slaying feeds the currently equipped Grimoire's combat level. Techniques and combat unlocks live on the Combat Tab of the Character Panel, not the Talents page.

**Universal Vanguard mechanics** (apply to all Vanguard Grimoires):
- Bulwark is the primary defensive Talent (Grimoire-locked to Vanguard)
- Wardancing unlocks ritual combat forms (Grimoire-locked to Vanguard)
- Melee combo system active in combat — chaining attacks builds combo meter
- Idle fallback: auto-combat at base melee rate, combo meter does not build during idle

---

## 🛡️ Grimoire of the Warlord
*"The line holds because I hold it."*

**Unlock:** Available as starting Grimoire or 500 GM
**Playstyle:** Immovable frontliner. The Warlord absorbs damage that would destroy other classes, generates massive aggro, and is the essential tank role in group content. In multiplayer dungeons and raids, without a Warlord parties struggle to survive elite encounters. Solo play is methodical and durable rather than flashy — the Warlord outlasts enemies rather than outpacing them.
**Idle behaviour:** Auto-combat in defensive stance — Iron Resolve passive always active, reduced damage taken. At capstone, idle deals full damage output.
**Signature passive:** *Iron Resolve* — incoming damage −10% and max HP +5% from the moment the Grimoire is equipped. Always active.
**Active nodes:** Strike (S), Guard (G), Surge (U)
**No crit system** — skill expression is combo knowledge, stamina management, and Technique timing.

---

### Hybrid Unlock Gates
Warlord unlocks require **Warfare level** (Grimoire-locked to Warlord Grimoire) and cross-Talent milestones focused on combat endurance and material mastery.

---

### 🌿 Warlord Tree

| Unlock | Warfare Level | Cross-Talent Req | Type | Description |
|--------|--------------|-----------------|------|-------------|
| **Iron Resolve** | 1 | — | Signature Passive | Incoming damage −10%, max HP +5%. Always active from equip. |
| **Shield Mastery** | 9 | Runesmithing 13 | Passive | Guard input combos deal +20% bonus taunt value on top of their standard taunt. Runesmithing knowledge of shield construction deepens defensive technique. |
| **Taunt** | 17 | Slaying 22 | Technique | Triggered by U→U combo (Warcry). Forces all nearby enemies to target the Warlord for 6 seconds. In solo combat locks enemy aggro; in group content pulls enemies off struggling allies. Slaying 22 experience reading enemy aggression patterns required. |
| **Bulwark's Endurance** | 24 | Cookery 27 | Passive | Warrior's Ration and Hearty Stew buff durations +50% when consumed by Warlord. Cookery provisioning knowledge deepens physical endurance. |
| **Ground Slam** | 31 | — | Technique | Triggered by S→S→S (Whirlwind). Hits the enemy with maximum force — adds a 2-second stagger on top of standard Whirlwind damage. At Warfare level 31 the Warlord's Whirlwind gains the stagger modifier automatically. |
| **Fortified Stance** | 38 | Tanning 37 | Passive | Hardened Leather components used in Warlord armor assembly give +10% armor rating bonus. Tanning 37 hide treatment knowledge required. |
| **Rally** | 44 | Slaying 46 | Technique | Triggered by G→G→U (Bulwark's Oath). On cast: all party members in range gain +15% damage for 20 seconds in addition to the combo's standard defense buff. Solo: self-only. Raid essential — Warlord buffs the whole party while holding aggro. |
| **Unbreakable** | 52 | — | Passive | When HP drops below 20%, incoming damage −25% additional. Stacks additively with Iron Resolve (−10%) for −35% total at critical HP. Last stand mechanic — the Warlord gets harder to kill the closer to death they are. |
| **Siege Commander** | 59 | Slaying 58 | Passive | When the Warlord lands the killing blow on a zone boss or dungeon boss, all party members gain +25% XP from the next 10 encounters. Rewards the Warlord for staying engaged and finishing the fight. Slaying 58 elite kill experience required. |
| **Crushing Blow** | 66 | Runesmithing 67 | Technique | Triggered by G→U→S (Titan's Blow). At Warfare level 66, Titan's Blow gains an armor break modifier — reduces enemy defense by 30% for 8 seconds on top of standard damage. Runesmithing 67 adamantine-tier weapon knowledge required. Warlord's strongest debuff tool. |
| **Iron Aura** | 73 | — | Passive | All party members gain +5% damage reduction while Warlord is in active combat. Passive group protection — no trigger needed. In solo play applies only to the Warlord. |
| **Relentless** | 79 | Slaying 79 | Passive | The Warlord's stamina regeneration rate +50% while in active combat. More aggressive combo chains become sustainable without Endurance Draughts. Slaying 79 elite combat endurance required. |
| **Warlord's Command** | 86 | — | Passive | When Warlord kills an elite or boss enemy, all party members gain +20% damage for 15 seconds. Reward for successfully tanking dangerous targets to completion. |
| **Indomitable** | 93 | Cookery 67 | Passive | Warlord cannot be one-shot by any non-boss attack regardless of damage amount. If a single hit would reduce HP to 0, it reduces to 1 HP instead. Cookery 67 endurance provisioning supports the physical conditioning required. |
| **The Immovable** *(Level 100 capstone)* | 100 | — | Passive | Idle auto-combat now uses the Warlord's last manually entered combo at full potency instead of basic Strike at 70%. The Warlord's combat instincts are fully formed — every motion deliberate, every stance second nature. The foundation is complete. What deeper warfare knowledge may yet build upon it remains to be seen. |

---

### Technique Trigger Summary — Implementation Reference

| Technique | Triggers via | Additional effect at unlock level |
|-----------|------------|----------------------------------|
| Taunt | U→U (Warcry) — already in combo library | Forces all nearby enemy aggro to Warlord 6s |
| Ground Slam | S→S→S (Whirlwind) — already in combo library | Adds 2s stagger modifier at Warfare 31 |
| Rally | G→G→U (Bulwark's Oath) — already in combo library | Adds party +15% damage 20s at Warfare 44 |
| Crushing Blow | G→U→S (Titan's Blow) — already in combo library | Adds armor break −30% defense 8s at Warfare 66 |

**Implementation note:** Warlord Techniques don't add new combo sequences — they upgrade existing combos with additional modifiers when the Warfare level threshold is reached. `CombatManager` checks `GrimoireLevel >= techniqueUnlockLevel` before applying the extra modifier on combo resolution.

```csharp
void OnComboResolved(string comboKey, float damage) {
    // Standard combo effect always applies
    ApplyComboEffect(comboKey, damage);

    // Technique modifiers apply if Warfare level threshold reached
    int level = CombatXPManager.GetGrimoireLevel(equippedGrimoireId);

    if (comboKey == "UU" && level >= 17)  // Taunt
        AggroManager.Instance.TauntAll(duration: 6f);

    if (comboKey == "SSS" && level >= 31) // Ground Slam
        CombatManager.ApplyStagger(currentEnemy, duration: 2f);

    if (comboKey == "GGU" && level >= 44) // Rally
        BuffManager.Instance.ApplyPartyBuff(StatType.DamageBonus, 0.15f, 20f);

    if (comboKey == "GUS" && level >= 66) // Crushing Blow
        CombatManager.ApplyArmorBreak(currentEnemy, 0.30f, 8f);
}
```

---

### Passive Chain — Unbreakable + Indomitable Interaction

At endgame the Warlord becomes nearly unkillable by non-boss enemies:
- Above 20% HP: Iron Resolve −10% damage reduction
- Below 20% HP: Iron Resolve −10% + Unbreakable −25% = **−35% total**
- Any single hit that would kill outright: Indomitable prevents it (HP → 1)

Combined with high VIT investment and a Lifebinder in the party, the Warlord can
tank Tier 4–5 content that would instantly kill any other class.

---

### Warlord Build Identity
The Warlord is the **essential raid tank** and **party anchor**:
- Early game: Iron Resolve + Shield Mastery establish tank identity immediately
- Mid game: Taunt, Rally, and Unbreakable add group utility and survival depth
- Late game: Crushing Blow, Iron Aura, and Warlord's Command make every elite kill a party event
- Idle: Full combo potency at capstone — the Immovable never stops fighting

**Synergizes with:**
- Runesmithing — Shield Mastery and Crushing Blow gate on Runesmithing levels
- Cookery — Bulwark's Endurance and Indomitable reward Cookery investment
- Lifebinder — natural pairing in dungeons and raids; Warlord tanks, Lifebinder heals
- Tanning — Fortified Stance rewards leather crafting cross-investment
- Slaying — Taunt, Rally, Relentless, and Siege Commander all gate on Slaying milestones

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | STR +1 (permanent, character-wide) |
| 47 | VIT +1 (permanent, character-wide) |
| 63 | STR +2 (permanent, character-wide) |
| 81 | VIT +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---

## 🌑 Grimoire of the Shadowblade
*"They never see me coming. That's the point."*

**Unlock:** Available as starting Grimoire or 500 GM
**Playstyle:** Pure burst assassin. The Shadowblade opens from stealth for devastating burst damage, applies stacking poisons and hemorrhage DoTs, and has deep synergy with Gleaning for battlefield scavenging. Highest single-encounter damage potential of any Vanguard subclass but lowest survivability. Rewards aggressive, skillful active play.
**Idle behaviour:** Auto-combat at reduced potency — the Shadowblade's burst toolkit doesn't translate to sustained idle DPS. Shadow's Edge does not trigger during idle (no stealth opener). Gleaning passive (Scavenger's Edge) continues during idle in unlocked zones.
**Signature passive:** *Shadow's Edge* — first attack from stealth deals +150% damage. Displays as 'Critical!' visually — backend is a damage multiplier, not a true crit proc. Always active.
**Active nodes:** Strike (S), Guard (G), Surge (U)
**No crit system** — Shadow's Edge is a flat multiplier. Skill expression is stealth timing, combo knowledge, and DoT stacking.

---

### Hybrid Unlock Gates
Shadowblade unlocks require **Warfare level** (Grimoire-locked to Shadowblade Grimoire) and cross-Talent milestones focused on stealth, poison, and scavenging.

---

### 🌿 Shadowblade Tree

| Unlock | Warfare Level | Cross-Talent Req | Type | Description |
|--------|--------------|-----------------|------|-------------|
| **Shadow's Edge** | 1 | — | Signature Passive | First attack from stealth deals +150% damage. Visual 'Critical!' label — backend damage multiplier, no crit system. Always active. |
| **Vanish** | 9 | — | Technique | Triggered by U→U (Void Step combo). Enter Shroud state — player fades near-invisible for up to 10 seconds. Next attack from Shroud triggers Shadow's Edge (+150%). Shroud breaks on attack or after 10 seconds. 60-second cooldown after Shroud breaks. Core opener tool. |
| **Poison Mastery** | 17 | Alchemy 19 | Passive | All poison and coating effects applied by Shadowblade deal +30% damage per tick and last +20% longer. Alchemy 19 poison chemistry knowledge required. |
| **Backstab** | 24 | Slaying 22 | Technique | Triggered by U→S (Shadow Strike combo). At Warfare level 24, Shadow Strike from Shroud gains an additional +80% damage modifier on top of Shadow's Edge. The combo becomes the primary stealth opener — tap U→U to enter Shroud, then U→S to Backstab. Slaying 22 combat experience required. |
| **Scavenger's Instinct** | 31 | Gleaning 31 | Passive | After any combat kill, Shadowblade has a +10% bonus chance to trigger Scavenger's Edge (the Gleaning passive). Stacks additively with base Gleaning chance. Gleaning 31 battlefield scavenging knowledge required. |
| **Shroud Step** | 38 | — | Technique | Triggered by U→G (Phantom Step combo). At Warfare level 38, Phantom Step enters a brief Shroud state (3 seconds) in addition to its evasion buff. Allows the Shadowblade to re-enter stealth mid-combat — resets Shadow's Edge for the next Strike. Tight window — must land the next hit within 3 seconds. |
| **Veil Walk** | 44 | Gleaning 47 | Passive | In combat zones, Shadowblade auto-generates a Gleaning attempt on each enemy killed — treating every kill as a Gleaning opportunity in addition to normal loot. Gleaning 47 dungeon scavenging knowledge required. |
| **Hemorrhage** | 52 | Alchemy 57 | Passive | All Strike-based attacks by the Shadowblade have a 30% chance to apply a bleed DoT (3 damage/sec for 15 seconds). Stacks independently with poison coatings. Alchemy 57 precise blade application knowledge required. |
| **Shadow Smoke** | 59 | Gleaning 47 | Technique | Triggered by G→U (Shadow Surge combo). At Warfare level 59, Shadow Surge enters a 5-second Shroud state instead of just an evasion buff — a longer stealth window for setup. Cooldown 45 seconds. Allows mid-combat stealth resets for sustained Shadow's Edge openers. |
| **Death Mark** | 66 | Slaying 66 | Technique | Triggered by U→S→U (Death Mark combo). Marks the enemy — if the Shadowblade lands the killing blow within 20 seconds, guaranteed rare item drop from that enemy's loot table. Marks one target at a time. Slaying 66 elite hunting knowledge required. The Shadowblade's loot tool — rewards aggressive finishing. |
| **Hemorrhage Mastery** | 73 | Alchemy 67 | Passive | Hemorrhage bleed DoTs stack twice on the same enemy — two independent bleeds running simultaneously. Combined with Poison Mastery and active coatings creates the highest sustained DoT output of any class. Alchemy 67 advanced precision required. |
| **Void Assassin** | 79 | Slaying 79 | Technique | Triggered by U→U→S combo. At Warfare level 79, this combo deals +250% damage specifically when entering from Shroud state (`_comingFromShroud = true`). The Shadowblade's signature kill shot — Void Step into stealth, then Void Assassin from Shroud. Slaying 79 elite assassination experience required. |
| **Hemorrhage Cascade** | 86 | Alchemy 86 | Passive | When both hemorrhage stacks AND poison coating are active simultaneously on an enemy, each DoT tick has a 15% chance to refresh the other's duration. Creates a self-sustaining DoT loop at endgame — the Shadowblade's primary sustained damage identity. Alchemy 86 mastery required. |
| **Spectral Form** | 93 | Gleaning 79 | Passive | While in Shroud state, the Shadowblade's Gleaning passive chance doubles. Every kill from stealth has exceptional scavenging value. Gleaning 79 shadow movement knowledge required. |
| **Phantom's Mastery** *(Level 100 capstone)* | 100 | — | Passive | Shadow's Edge now applies to the first Strike of every combat encounter regardless of stealth — +150% damage opener guaranteed even when detected. Visual 'Critical!' displayed. The Shadowblade moves like a shadow whether seen or unseen — a reflex, not a technique. The edge is sharp. Sharper still is possible, for those who seek it. |

---

### Technique Trigger Summary — Implementation Reference

| Technique | Triggers via | Additional effect at unlock level |
|-----------|------------|----------------------------------|
| Vanish | U→U (Void Step) — already in combo library | Enters 10s Shroud state at Warfare 9 |
| Backstab | U→S (Shadow Strike) — already in combo library | +80% additional damage when from Shroud at Warfare 24 |
| Shroud Step | U→G (Phantom Step) — already in combo library | Adds 3s Shroud entry at Warfare 38 |
| Shadow Smoke | G→U (Shadow Surge) — already in combo library | Extends to 5s Shroud instead of evasion at Warfare 59 |
| Death Mark | U→S→U (Death Mark) — already in combo library | Adds guaranteed rare drop on kill within 20s at Warfare 66 |
| Void Assassin | U→U→S — already in combo library | +250% damage when from Shroud at Warfare 79 |

**Implementation note:** Like the Warlord, Shadowblade Techniques upgrade existing combos at Warfare level thresholds. The Shroud state (`_comingFromShroud`) is the key flag — multiple Techniques read and write it.

```csharp
void OnComboResolved(string comboKey, float damage) {
    ApplyComboEffect(comboKey, damage);

    int level = CombatXPManager.GetGrimoireLevel(equippedGrimoireId);

    // Vanish — enter Shroud
    if (comboKey == "UU" && level >= 9) {
        EnterShroud(duration: 10f);
        _comingFromShroud = true;
    }

    // Backstab — bonus damage from Shroud
    if (comboKey == "US" && level >= 24 && _comingFromShroud)
        ApplyAdditionalMultiplier(0.80f); // +80% on top of Shadow's Edge

    // Shroud Step — brief re-entry to Shroud
    if (comboKey == "UG" && level >= 38) {
        EnterShroud(duration: 3f);
        _comingFromShroud = true;
    }

    // Shadow Smoke — extended Shroud
    if (comboKey == "GU" && level >= 59) {
        EnterShroud(duration: 5f);
        _comingFromShroud = true;
    }

    // Death Mark
    if (comboKey == "USU" && level >= 66)
        ApplyDeathMark(currentEnemy, window: 20f);

    // Void Assassin — massive damage from Shroud
    if (comboKey == "UUS" && level >= 79 && _comingFromShroud)
        ApplyAdditionalMultiplier(2.50f); // +250%
}
```

---

### Shroud State — Core Mechanic

Shroud is the Shadowblade's central resource — entered via multiple Techniques,
consumed by any attack:

```
Enter Shroud (via Vanish/Shroud Step/Shadow Smoke)
    → Player renderer fades to near-invisible (alpha 0.2)
    → _comingFromShroud = true
    → Shroud timer starts (3s / 5s / 10s depending on Technique)
    → Next enemy attack misses entirely (one attack)

On next Strike input from Shroud
    → Shadow's Edge fires (+150% damage, "Critical!" displayed)
    → If Backstab unlocked (Warfare 24): +80% additional
    → If Void Assassin (Warfare 79) and U→U→S: +250% additional
    → _comingFromShroud = false
    → Player renderer restores
    → Shroud timer cancelled
```

---

### DoT Stack — Hemorrhage + Poison Interaction

At endgame (Warfare 73+) the Shadowblade stacks multiple DoTs simultaneously:

| Source | DoT | Stacks |
|--------|-----|--------|
| Poison Coating (Alchemy item) | Poison DoT | 1 (base) |
| Hemorrhage passive | Bleed DoT | 2 (with Hemorrhage Mastery) |
| Hemorrhage Cascade | Cross-refresh | Refreshes each other 15% per tick |

Peak DoT at endgame: 2× bleed + 1× poison all ticking simultaneously + cross-refresh loop.
Combined with Shadow's Edge opener and Void Assassin burst = highest total encounter damage in base game.

---

### Shadowblade Build Identity
The Shadowblade is the **pure burst assassin**:
- Early game: Vanish + Shadow's Edge establish the stealth opener identity immediately
- Mid game: Hemorrhage and Veil Walk add sustained damage and zone scavenging value
- Late game: Hemorrhage Mastery, Void Assassin, and Hemorrhage Cascade create a devastating DoT + burst combination
- Idle: Weakest Vanguard idle — designed to be played actively. Scavenger's Instinct and Spectral Form reward active sessions

**Synergizes with:**
- Alchemy — Poison Mastery, Hemorrhage, and Hemorrhage Cascade all gate on Alchemy. The Shadowblade is Alchemy's best customer
- Gleaning — More Gleaning cross-requirements than any other subclass. Veil Walk, Spectral Form, and Scavenger's Instinct reward Gleaning investment
- Slaying — Backstab, Death Mark, and Void Assassin gate on Slaying milestones

---

### Permanent Stat Bonuses (from Grimoire combat level milestones)
| Level | Bonus |
|-------|-------|
| 23 | STR +1 (permanent, character-wide) |
| 47 | VIT +1 (permanent, character-wide) |
| 63 | STR +2 (permanent, character-wide) |
| 81 | VIT +2 (permanent, character-wide) |

Bonuses accumulate across all owned Grimoires regardless of path.
See `docs/warfare-spec.md` for full cross-path accumulation details.

---

## 🔗 Vanguard Subclass Comparison

| | Warlord | Shadowblade |
|--|---------|-------------|
| **Combat role** | Tank / Frontliner | Burst assassin |
| **Damage model** | Sustained melee + AoE | Burst opener + DoT stacking |
| **Survivability** | Very high — the highest | Low — glass cannon |
| **Group value** | Essential — only dedicated tank | Moderate — DPS + disruption |
| **Solo viability** | Strong — nearly unkillable | Strong — high damage, careful play |
| **Idle efficiency** | Excellent — full damage at capstone | Poor — burst toolkit doesn't translate |
| **Skill ceiling** | Moderate — cooldown management | Very high — stealth timing + poison stacking |
| **Economy role** | None specific | None — pure combat specialist |
| **Dungeon role** | Essential tank | Burst DPS / skip puller |
| **Raid role** | Primary tank — required role | Burst DPS / off-tank in emergencies |

---

## 📋 Deferred Vanguard Subclass

### Grimoire of the Kensei *(DLC)*
- Samurai discipline and Focus mechanic
- Wardancing is the primary exclusive Talent
- Idle streaks before manual input build up burst potential
- Ritual weapon crafting ties to Runesmithing endgame
- Full tree designed at DLC spec phase

---

*Document version 0.1 — Vanguard Subclass Trees*
*Next: Stat scaling formulas · Daily/weekly quest structure · Onboarding flow · Bestiary*
