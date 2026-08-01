# T4/T5 Enemy Content, REQUEST for Chat

**Status:** design ask, and a **hard prerequisite** for the T4/T5 dungeons. The
`dungeon-room-pools-t4t5-brief.md` is done and specs the four dungeons + their bosses in full, but its
rooms reference ~20 **T4/T5 zone enemies that do not exist as `EnemyData` yet**. `enemy-zone-tables.md`
lists their names, factions, combat levels, and notable drops, but NOT the full combat stats Code needs
to author them. Chat provides those stats (as `phase3-enemy-content-brief.md` did for T3); Code then
authors them via a `CreatePhase4Enemies` pass, and only THEN can the dungeons be built.

---

## What Code needs per enemy (the EnemyData fields)

Mirror `phase3-enemy-content-brief.md` exactly, one block per enemy with:

- `enemyName`, `factionTags` (from the zone tables), `combatLevelMin/Max`
- `maxHP`, `damageRangeMin/Max`, `attackCadence`
- `baseAccuracy`, `evasionRating`, `blockChance`, `defense`
- `weakPointTier` (Obvious / Subtle / Hidden) + `weakPointDescription` + `weakPointMultiplier`
- `isElite` where the table marks `[Elite]`
- `silverMarkDropMin/Max`, `goldMarkDropMin/Max`, `slayingXPReward`
- `dropTable` (item + chance), using the zone tables' drops + any new rare materials
- Any `specialAbility` text / new mechanic (e.g. a "hunted variant" or phase behaviour)

Keep the numbers in band with T3 (`phase3-enemy-content-brief.md`) scaled up for T4/T5, the dungeon
brief's bosses are a good yardstick (T4 zone enemies feed dungeons whose bosses sit at ~18-20k HP; T5 at
~32-38k). Standard enemy defense should track the combat-balance reconcile (T1 is 10-18; scale up).

## Enemies to stat (from `enemy-zone-tables.md` + the dungeon brief)

**T4 - Veilborn Wastes (4A):** Void Crawler, Veilborn Wraith, Reality Shade, Corruption Titan,
Veil Stalker `[Elite]`, Sundered Revenant `[Elite]`; zone boss **The Veil Sovereign**.

**T4 - Shattered Citadel (4B):** Citadel Automaton, Ruin Scavenger, Relic Guardian, Spell-Bound
Sentinel, Citadel Archmage, Ruin Lord; the two elites; zone boss.

**T5 - Ashenwold (5A):** Ancient Void Crawler, Ashen Revenant, Void Titan, Corruption Ancient,
Ashen Warlord, Void Archon; zone boss.

**T5 - Elder Reaches (5B):** World Golem, Primordial Drake, Elder Construct, Rune Colossus,
Ancient Wyvern, Primordial Alpha; zone boss.

(The four DUNGEON bosses, Veil Harbinger, Valdren the Unfinished, Pale Vault Warden, Firststone Warden,
are already fully specced in `dungeon-room-pools-t4t5-brief.md`, no need to re-stat those.)

## Also confirm

- The T4/T5 **zones** themselves (`ZoneData`), do they exist, or does `CreatePhase4Enemies` author the
  zones too (as `CreatePhase2/3Enemies` did)? The dungeon brief uses zone ids `veilborn_wastes`,
  `shattered_citadel`, `ashenwold`, `elder_reaches`.
- Any brand-new rare materials to add (the brief mentions Soul Residue, Void Crystal, Void Core, Arcane
  Residue, Starstone Ore Chunk, Drake Scale, Ancient Fang, Worldtree Shard, Summoner's Tome), confirm
  which need `ItemData` authoring vs already exist.

Deliver as `phase4-enemy-content-brief.md`. Once it lands, Code authors the enemies + zones, then builds
the four T4/T5 dungeons (data + the two new puzzle minigames + the four new hazards, enum values already
added).
