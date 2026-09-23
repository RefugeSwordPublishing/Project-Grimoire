# Dungeon Diegetic Puzzles, Design Brief (for Chat)
### Created 2026-09-23 by Claude Code. Status: brief for Chat to turn into a full spec.

## Why
Dungeon puzzles currently pop as a bare UI panel (`DungeonPuzzleUI`) floating over the run. Now that
dungeons render in the **HD-2D combat scene** (3D floor + painterly backdrop + placed prop sprites), the
puzzle should feel **diegetic**: a physical puzzle object stands in the room, and tapping it opens the
puzzle framed as *examining / using that object*. Dustin's north star: the Glyph puzzle should feel like
**leaning over a lit map/rune table**, not reading a menu.

## As-built (code wins; verify before specing)
- `DungeonData.DungeonPuzzle` enum: `None, PyrePuzzle, PressureValvePuzzle, GlyphPuzzle (T2 Mirefall, rune
  sequence memory), WeightPuzzle (T2 Warden's Folly, counterweight balance), VoidRiftSeal (T5 Pale Vault,
  tap 5 rifts ascending within 8s), RuneLock (T5 Firststone, 3 interdependent rune wheels, no timer)`.
- Puzzle logic + current presentation: `Assets/Scripts/UI/DungeonPuzzleUI.cs`; dungeon run flow in
  `Assets/Scripts/UI/*Dungeon*` + `BuildDungeonRunUI.cs`; rooms with `RoomType.Puzzle` trigger it.
- Dungeon environments: each `DungeonData.environmentPrefab` (a `GameEnvironment`: Backdrop + Floor + Props
  root). 6 empty scaffolds exist (`Env_Dungeon_*`); interior art being generated per dungeon (2026-09-23).

## The change to design
1. **Diegetic prop:** each puzzle type has a physical prop placed in the Puzzle room's scene (see art list).
   Idle state shows the prop; an interact affordance (glow/outline + tap target) invites the tap.
2. **Tap to engage:** tapping the prop transitions the camera/framing to an "examine" view of that object and
   opens the puzzle logic *inside* that frame, reskinned to read as the object itself:
   - **GlyphPuzzle** -> top-down glyph/rune **table** (the map-table feel): runes light in sequence on the table.
   - **RuneLock** -> the door's 3 rune **wheels** turned in place.
   - **WeightPuzzle** -> a counterweight/scale **rig** whose pans you load.
   - **PressureValvePuzzle** -> a pipe **console** of valve wheels.
   - **VoidRiftSeal** -> the cluster of **rifts** hovering in the room, tapped in order.
   - **PyrePuzzle** -> a ritual **brazier/pyre** lit in sequence.
3. **Solve / fail / exit:** same win + reward + hazard rules as today; success animates the object (table
   glows solved, door opens, weights balance) then returns to the run. Keep a visible "back/leave" affordance.

## Open questions for Chat
- Does the puzzle UI reskin sit *on* the prop in world space (best for the map-table feel) or as a framed
  overlay anchored to it? Trade-offs for touch targets on mobile portrait.
- Camera move on engage: dolly/tilt to the object, or a soft cut? Keep the run's floor/backdrop visible behind?
- One shared "examine frame" component parameterized per puzzle, or per-puzzle bespoke views?
- Accessibility: timed puzzles (VoidRiftSeal 8s) need the tap targets large and unambiguous at phone size.

## Dungeon room presentation (broader question, design this too)
A dungeon RUN is `minRooms 3`..`maxRooms 5` rooms drawn from the pool plus fixed entrance/safe/boss
(`RoomType`: Standard, Elite, Safe, Boss, Puzzle, Treasure, Trap). Open question Dustin raised: **how do the
rooms present and vary** within one run? The environment is one `GameEnvironment` per dungeon (shared backdrop
+ floor). Proposal to spec: rooms keep the dungeon's shared backdrop/floor but **re-dress the Props root per
room** from a per-dungeon prop **library** (~6-8 dressing props: pillars, rubble, banners, braziers, crates,
statues), plus a **room-type "hero" prop** that reads the room at a glance:
- Treasure -> a chest / loot hoard.  Boss -> a dais / throne / altar centerpiece.  Safe -> a campfire / shrine
  (heal beat).  Puzzle -> the puzzle prop above.  Trap -> the telegraphed hazard object.  Standard/Elite ->
  library dressing only.
Chat should decide: how many rooms show distinct dressing vs. a quick re-arrange, whether the camera/backdrop
shifts between rooms, and the prop count per dungeon. That sizing decides how many prop sprites Claude Code makes
(backdrops + floors are per-dungeon and mechanic-independent, so those get generated first).

## Art (Claude Code generates once the interaction is specced)
Six puzzle-prop sprites (HD-2D, organic/gritty, transparent), each with the **idle** in-scene look and, for
the ones that become the puzzle surface (glyph table, rune-lock door, valve console, scale rig), a clean
**examine/top-down** variant to host the interaction: pyre brazier, valve console, glyph/rune table,
counterweight scale rig, void-rift cluster, 3-wheel rune-lock door.
