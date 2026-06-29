# ⚔️ Project Grimoire — Deferred Systems & Future DLC Notes
### Version 0.1

> This document tracks systems that are intentionally deferred from the base game. Each entry notes the planned release window, design intent, and what the base game needs to leave room for during implementation.

---

## 📋 Deferred System: Faction System

**Planned Release:** Level 120 Cap Expansion (DLC)
**Design Status:** Concept locked, full spec deferred

### Core Concept
Five factions tied to world zones and playstyle identity:
- **The Crown** — kingdom, law, order, military
- **The Wayfarer's Guild** — trade, merchants, Exchange perks
- **The Verdant Conclave** — nature, wilderness, Warden/Foraging/Tracking aligned
- **The Arcane Accord** — magic, knowledge, Arcanist aligned
- **The Underworld** — outlaws, black market, Shadowblade/Black Ledger aligned

### Planned Features
- **Personal faction standing** — individual perks per tier
- **Guild faction standing** — combined guild contribution unlocks group bonuses
- **Soft allegiance model** — primary faction (max tier possible) + other factions capped at tier 2
- **5 standing tiers** — Stranger → Known → Trusted → Honored → Exalted
- **Weekly randomly generated faction quests** — primary reputation driver
- **Faction zones** — idle assignments in a faction's zone generates slow passive standing
- **XP boosts** — higher standing grants XP bonuses in faction-relevant Talent areas
- **Faction wars** — guild vs guild weekly territory competition for cosmetic and bonus rewards; resets weekly to prevent permanent dominance
- **Black Ledger consequence** — Crown faction NPC seizure mechanic for Underworld/Shadowblade players with low Crown standing
- **Switching primary faction** — possible but costs significant Gold Marks and drops standing by one tier

### Base Game Design Constraints
> These things must be kept in mind during main game design to avoid making factions harder to implement later:

- **Zone system** must support faction ownership/influence layers — don't hardcode zones as purely neutral
- **Inscription** Diplomatic Charter items already exist in Talent spec — these will feed faction standing gain when factions launch; don't remove or repurpose them
- **CHA stat** already tied to faction reputation conceptually — keep CHA relevant in base game economy so the transition feels natural
- **Guild system** (Phase 4) should be architected to support a standing contribution layer even if faction data isn't populated yet
- **Wayfarer's Exchange** Black Ledger section for Shadowblade already noted — design this as a stub that expands with faction launch
- **Weekly quest infrastructure** needed for factions — if daily/weekly quests are built for base game, architect the system to support faction-tagged quest types
- **Enemy tagging** — outlaw-type enemies referenced in faction damage bonus design; tag enemy types in the combat system from the start (outlaw, beast, undead, arcane, elite, etc.) so faction damage bonuses can be applied cleanly later

---

## 📋 Deferred System: Faction Wars

**Planned Release:** Level 120 Cap Expansion (DLC) — alongside Faction System
**Design Status:** High-level concept only

### Core Concept
Guild vs guild weekly competition to support chosen factions for territory control and rewards. Adds a new tier of endgame gameplay beyond individual progression.

### Planned Features
- Weekly reset — no permanent territory, fresh competition each week
- Smaller guilds can ally with larger ones for war participation
- Rewards are cosmetic + bonus tier — losing doesn't hurt progression, winning feels rewarding
- Faction war rewards include exclusive cosmetic Grimoire skins, titles, and limited Mark bonuses

### Base Game Constraints
- Guild architecture must support inter-guild relationships (ally/rival flags) from Phase 4 onward
- Territory/zone system should support a "controlled by" state even if unused in base game

---

## 📋 Deferred System: Dueling / PvP Arena

**Planned Release:** Phase 4 (Multiplayer expansion)
**Design Status:** Named in Combat Talents; no further design done

### Base Game Constraints
- Combat stat tracking should be architected to support PvP modifiers separately from PvE — don't hardcode damage formulas in a way that makes PvP balancing impossible without breaking PvE

---

## 📋 Deferred System: Lifebinder Subclass

**Planned Release:** Phase 4 (Multiplayer expansion)
**Design Status:** Rune behavior defined in Spellcasting spec; subclass deep tree not designed

### Base Game Constraints
- Runic Constellation system already includes Lifebinder rune behavior column — keep this in the system even though the Grimoire isn't available yet
- Multiplayer party system must support a dedicated heal/support role from architecture standpoint

---

## 📋 Deferred Subclass: Bard / Minstrel

**Planned Release:** DLC — path TBD (likely Arcanist or new fourth path)
**Design Status:** Concept only

### Core Concept
A support/debuff hybrid that operates through performance rather than healing or direct damage. High WIL and CHA required. Genuinely unique — no current idle game has this archetype.

### Planned Features
- CHA combat role: Performance debuffs — reduces enemy accuracy and damage output
- WIL combat role: Extended buff duration, sustain auras for party
- Likely multiplayer-focused — most valuable in dungeon and raid content
- Active mechanic TBD — possibly rhythm-based performance inputs

### Base Game Constraints
- CHA and WIL formula slots explicitly reserved in stat scaling formulas
- Do NOT hardcode CHA as economy-only in implementation
- Do NOT hardcode WIL as purely mana/idle — healing boost and debuff resistance already implemented, CHA combat slot kept open

---

## 📋 Deferred Subclass: Beastbond (Warden DLC)

**Planned Release:** DLC
**Design Status:** Identity locked, tree not designed

### Core Concept
Inverted Summoner — user is primary damage dealer, tamed real-world creatures fight alongside and buff the user or debuff enemies. Permanent familiars from the world, not conjured constructs.

### Distinction from Summoner
- Summoner: backline, conjured constructs do the fighting, user buffs constructs
- Beastbond: frontline, user does primary damage, real creatures buff user stats or debuff enemies

### Base Game Constraints
- Beastmastery Talent already in spec sheets — Grimoire-locked to Beastbond
- Familiars active only when Beastbond Grimoire is equipped
- Grand Exchange creature listing already stubbed at Beastmastery 75

---

## 📋 Deferred Subclass: Warlock (Arcanist DLC)

**Planned Release:** DLC
**Design Status:** Rune behavior defined, tree not designed

### Core Concept
Soul harvesting and dark pact mechanics. Soulbinding is the primary exclusive Talent. Soul Reservoir passive idle loop. Black Ledger market access.

### Base Game Constraints
- Soulbinding Talent already in spec sheets — Grimoire-locked to Warlock
- Black Ledger stub exists in Wayfarer's Exchange design
- Runic Constellation Warlock column already defined

---

## 📋 Deferred Subclass: Kensei (Vanguard DLC)

**Planned Release:** DLC
**Design Status:** Identity locked, tree not designed

### Core Concept
Samurai discipline and Focus mechanic. Wardancing is the primary exclusive Talent. Idle streaks before manual input build up burst potential.

### Base Game Constraints
- Wardancing Talent already in spec sheets — Grimoire-locked to Vanguard
- Focus mechanic needs its own UI element — stub the slot in the combat screen

---

*Document version 0.2 — Deferred Systems & Future DLC Notes*
*Updated as new systems are deferred or constraints are identified*
