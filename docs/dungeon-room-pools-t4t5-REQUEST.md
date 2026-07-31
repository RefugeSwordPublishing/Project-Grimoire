# T4/T5 Dungeon Room Pools, REQUEST for Chat

**Status:** design ask. Dungeon design currently stops at T3; Dustin has decided **T4 and T5 zones DO
get dungeons**, and needs a Chat brief before Code builds them. Match the format of the existing briefs.

---

## Decision

Yes, T4 (Veilborn Wastes) and T5 (Ashenwold), plus any second zones in those tiers, each get a dungeon,
same shape as T1-T3: a procedural room-pool crawl with an entrance, a weighted standard pool, a safe
room, a boss room, first-clear XP, hazards, and an exclusive puzzle (T2/T3 have puzzles; carry that
forward for T4/T5).

## What to produce (per dungeon)

Mirror `dungeon-room-pools-phase3-brief.md` (Gravenspire + Ignarath's Maw, T3) exactly so Code can drop
it into a `CreatePhaseXDungeons.cs` authoring pass:

- **Dungeon identity:** name, the zone it hangs off (zone id), entry combat-level gate, first-clear XP.
- **Room pool:** entrance room, the weighted standard-room pool (name, type, weight, hazard, short
  desc), one safe room (heal + a small consumable), and the boss room.
- **Boss:** name (avoid name collisions with zone bosses, see the Aldric/Garrik reconcile), HP, damage,
  defense, weak-point tier + description, phases / special ability, drop table (including T4/T5 rare
  materials from `enemy-zone-tables.md`), slaying XP.
- **Hazard(s):** reuse existing `DungeonHazard` values where they fit, or specify new ones (Code adds
  the enum + the simplified periodic-tick behaviour, telegraphs are deferred).
- **Puzzle:** one exclusive puzzle per dungeon. We have Pyre, Pressure Valve, Glyph rune-sequence, and
  Weight counterweight-balance built (`DungeonPuzzleUI`); either reuse one or spec a new mechanic (name
  + rules + fail/success), and Code will build the minigame.

## Inputs already in the repo

- Format to copy: `dungeon-room-pools-brief.md` (T2), `dungeon-room-pools-t1-brief.md` (T1),
  `dungeon-room-pools-phase3-brief.md` (T3).
- Zone + enemy + drop tables for T4/T5: `enemy-zone-tables.md` (Tier 4 Zones, Tier 5 Zones sections,
  Veilborn Wastes, Ashenwold). Use those enemies for the standard pool and those rare materials for the
  boss drops.
- As-built dungeon system: `implementation-status.md` (DungeonData/RoomData, DungeonGenerator, the
  CombatManager crawl, DungeonPuzzleUI, the existing hazards).

## Open questions for Chat to settle

1. How many dungeons at T4/T5, one per zone, or a single capstone dungeon per tier?
2. New puzzle mechanics for endgame, or reuse the four existing minigames?
3. Any new hazards, or reuse the current set (Void seep, lava, arcane discharge, etc.)?
4. Boss multi-phase complexity at endgame (T3 bosses are 2-3 phase, should T5 push to 3-4)?

Deliver as `dungeon-room-pools-t4t5-brief.md` (resolves this request).
