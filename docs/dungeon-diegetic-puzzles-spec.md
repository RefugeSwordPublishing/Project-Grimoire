---
type: design-spec
version: 1.0
updated: 2026-09-23
path: docs/dungeon-diegetic-puzzles-spec.md
resolves: dungeon-diegetic-puzzles-brief.md
implements: ExamineFrame, in-room puzzle mode, RoomDressing system, camera presets
scope: presentation only. No change to puzzle solve logic, rewards, or hazard rules.
---

# Diegetic Dungeon Puzzles and Room Presentation
### Version 1.0

---

## 0. Two Answers Up Front

**There are two interaction modes, not one.** The brief treats all six puzzles as "tap the prop, open
an examine view." Two of them should not work that way. Pyre and VoidRiftSeal are made of several
objects scattered in the room, and pulling the camera into a single examine frame would mean either
cramming them together or cutting away from the room they live in. Those two stay in-room. The other
four use the examine frame. Section 2.

**World-space framing, screen-space input.** The map-table feel comes from the camera, not from
raycasting into 3D geometry. Section 3, and it is the decision most likely to be built the expensive
wrong way if it is not stated.

Both change the art list, so they are worth settling before Code generates anything. The revised
budget is section 7.

---

## 1. What Makes It Diegetic

The brief's north star is leaning over a lit rune table rather than reading a menu. Three things
produce that feeling, in order of importance.

**The backdrop stays visible.** If the puzzle fills the screen, it is a menu with better art. Keeping
the room's backdrop and floor in frame behind the puzzle is what makes the player still feel located.

**The camera moves rather than cutting.** A cut is an edit. A short dolly is a person leaning in. That
distinction is most of the effect and it costs 0.4 seconds.

**The object responds physically.** Weights actually tip, wheels actually turn, the table lights where
you touched. Solve states animate the object rather than showing a Solved banner.

Everything below serves those three.

---

## 2. Two Interaction Modes

### 2.1 Examine mode, four puzzles

`GlyphPuzzle`, `RuneLock`, `WeightPuzzle`, `PressureValvePuzzle`.

These are single objects a person would walk up to and lean over. Tapping the prop dollies the camera
to a fixed anchor where the object fills a known screen region, and the puzzle's controls render over
it.

### 2.2 In-room mode, two puzzles

`PyrePuzzle`, `VoidRiftSeal`.

These are several objects distributed in the room: braziers to light in sequence, rifts hovering in a
cluster. There is nothing to lean over.

**No camera move on engage.** The camera eases back slightly to guarantee every element is inside the
safe area, an interact prompt appears, and the elements become tappable in place. The room is the
puzzle surface.

This is better for both puzzles and it removes two examine-variant sprites from the art list, because
a pyre and a rift cluster never need a top-down version of themselves.

### 2.3 Why this split matters beyond art

VoidRiftSeal is the one timed puzzle, at five taps in eight seconds. Forcing it into an examine frame
would add a 0.4 second camera move to a puzzle with a 1.6 second per-tap budget, and the player would
lose a quarter of their first tap to a transition. In-room mode means the timer starts when they are
already looking at the rifts.

---

## 3. Framing And Input

**The camera creates the perception. Screen-space UI takes the input.**

On engage, the camera moves to an authored anchor on the prop, a fixed pose, not a computed one.
Because the pose is deterministic, the puzzle's interactive elements are screen-space rects authored
once against that known framing.

**Do not raycast into world geometry for puzzle input.** A rune table rendered in perspective gives
trapezoidal targets that shrink toward the far edge, which on a phone means the back row of runes is
materially harder to hit than the front row. That is a difficulty gradient nobody designed and nobody
can see.

The player perceives a physical table because the camera is looking at one. The engine gets uniform
rectangular targets because the UI is flat. Both halves get what they need.

### 3.1 The authored anchor

Each examine-mode prop carries an `ExamineAnchor` transform: the exact camera position and rotation
for its examine view. Authored in the editor per prop, per dungeon if placement differs.

This is what keeps the whole thing bakeable. The UI overlay is laid out against a fixed framing, so
the designer positions rune targets by eye once and they are correct forever.

---

## 4. Camera And Transitions

| Moment | Move | Duration |
|---|---|---|
| Engage examine puzzle | Dolly and tilt to `ExamineAnchor` | 0.40s, ease out |
| Engage in-room puzzle | Ease back to fit all elements | 0.25s |
| Solve | Hold on the object through its solve animation | animation length |
| Leave or fail out | Return to the room's camera preset | 0.30s |
| Room to room | Forward push with a short fade | 0.35s |

**Tapping during a transition snaps it to the end.** Players who have solved a puzzle before should
not sit through the same 0.4 seconds every retry, and a skip is cheaper and more honest than
special-casing the second engage.

**The room to room push is worth more than it costs.** A hard cut between rooms reads as a slideshow
of the same room. A short forward dolly with a fade reads as moving deeper into a place. It is one
transition, reused eight times a run, and it is most of what sells a run as a journey.

---

## 5. Per-Puzzle Reskin

Solve logic is untouched in every case. This is presentation only.

| Puzzle | Mode | Object | Interaction reads as |
|---|---|---|---|
| Glyph | Examine | Low rune table, lit from within | Runes light across the table surface in sequence, you repeat by touching them |
| RuneLock | Examine | Door with three inset wheels | Each wheel turns in place under the thumb, the door's bands realign |
| Weight | Examine | Counterweight rig with two pans | You load pans, the beam tips and settles physically |
| PressureValve | Examine | Pipe console of valve wheels | Wheels turn, pipes pressurise and hiss along their length |
| Pyre | In-room | Several braziers around the room | Each lights when touched, in sequence, and the room brightens |
| VoidRiftSeal | In-room | Five rifts hovering in a loose arc | Tapped in ascending order, each seals with a collapse |

### 5.1 Solve and fail states are on the object

Success animates the object and the object alone. The table's runes all light and hold. The door's
wheels lock and it swings. The beam balances and stops. No banner, no modal, no panel.

Failure does the same in reverse: the table dims, the wheels spin back, the pans crash down. Then the
existing hazard and retry rules apply unchanged.

---

## 6. Accessibility, And The VoidRiftSeal Problem

**Minimum tap target 88dp for timed puzzles, 64dp otherwise.** The Android guideline of 48dp is a
floor for untimed UI. A puzzle giving the player 1.6 seconds per tap needs more margin than a
settings toggle does.

**The ascending cue must not be colour.** Five rifts the player must tap in ascending order need an
ordinal cue that reads instantly and reads for everyone. **Use size.** Largest to smallest is
unambiguous at a glance, survives every form of colour blindness, and needs no legend.

If a second cue is wanted, brightness paired with size is fine. Colour alone is not.

**The eight second timer must be visible before it starts.** A countdown that appears at the same
moment the first tap is expected costs the player their orientation time. Show the timer, then start
it on first tap rather than on engage.

That single change removes most of the difficulty complaint without touching the eight seconds.

**Failure retries in place.** The camera does not move, the room does not reset, the rifts respawn.
Existing hazard consequences apply as they do today, but the player does not walk back through a
transition to try again.

---

## 7. Room Presentation

The brief's proposal is right. What follows is the sizing it asks for.

### 7.1 Variety comes from three cheap axes, not from more art

| Axis | Options | Cost |
|---|---|---|
| Camera yaw preset | 4 per dungeon | Free, authored transforms |
| Layout preset | 4 per dungeon | Free, authored prop positions |
| Dressing subset | 3 drawn from a library of 6 | 6 sprites per dungeon |

Four yaw by four layout by twenty subsets is **320 distinct room presentations per dungeon from six
prop sprites.** The longest possible run is eight rooms, so a player sees about two and a half
percent of the space in a single run.

**Camera yaw is the most underrated axis on that list.** Rotating the camera fifteen to twenty-five
degrees against the same backdrop makes a room read as a different part of the same complex, for
literally zero art. It does more perceptual work than three extra props would.

### 7.2 Constraints on selection

- Consecutive rooms never share a yaw preset.
- Consecutive rooms never share a layout preset.
- The entrance always uses yaw preset 1, so every run opens the same way and the dungeon has a
  recognisable front door.
- The boss room always uses a dedicated fifth yaw preset that no other room uses, so arriving reads
  as arriving.

### 7.3 Hero props carry room identity

One per room type, placed at the layout's focal position.

| Room type | Hero prop |
|---|---|
| Treasure | Chest or hoard |
| Boss | Dais, throne, or altar |
| Safe | Campfire or shrine |
| Puzzle | The puzzle prop, section 5 |
| Trap | The telegraphed hazard object |
| Standard, Elite | None. Dressing only. |

Standard and Elite deliberately get no hero prop. If every room announces itself, none of them do,
and the rooms that matter stop standing out.

### 7.4 Hero props are shared across dungeons, with tier variants

A chest is a chest. Authoring ten chests for ten dungeons is ten times the work for a difference
nobody will articulate.

**Three variants per hero prop, one per tier band.** T1 to T2, T3, T4 to T5. That gives a visible
escalation as the player climbs without per-dungeon duplication. Four hero types times three
variants is twelve sprites total rather than forty.

**Dressing props stay per-dungeon.** They are what makes Mirefall Barrow feel unlike Firststone
Sanctum, and that is the one place per-dungeon art earns its cost.

---

## 8. Art Budget

This is the number the brief asked for, to order generation against.

| Group | Count |
|---|---|
| Backdrops, one per dungeon | 6 |
| Floors, one per dungeon | 6 |
| Dressing props, 6 per dungeon | 36 |
| Hero props, 4 types x 3 tier variants | 12 |
| Puzzle props, idle | 6 |
| Puzzle props, examine variant, examine-mode only | 4 |
| **Total** | **70** |

**Generation order**, since backdrops and floors are mechanic-independent:

1. Backdrops and floors, 12 sprites. Unblocks everything and needs no further design.
2. Puzzle props, 10 sprites. Unblocks the puzzle work in sections 2 through 6.
3. Hero props, 12 sprites. Unblocks room typing.
4. Dressing props, 36 sprites. The long tail, and the one that can ship partially. Four per dungeon
   works; the remaining two per dungeon can follow.

**In-room mode saved two sprites** by removing examine variants for Pyre and VoidRiftSeal, per
section 2.2.

---

## 9. Baked Structure

One shared frame, six content prefabs. Not six systems.

**`ExamineFrame`**, one instance, used by the four examine-mode puzzles
```
ContentRoot      (Transform)   the per-puzzle prefab mounts here
TimerBar         (GameObject)  toggled, timed puzzles only
TimerFill        (Image)
HintLabel        (Text)        one line, puzzle-specific
LeaveButton      (Button)
SolveOverlay     (GameObject)  drives the prop's solve animation, not a banner
```

**`InRoomPuzzleController`**, no frame, for Pyre and VoidRiftSeal
```
ElementContainer (Transform)   parent for tappable element clones
TimerBar         (GameObject)
TimerFill        (Image)
HintLabel        (Text)
LeaveButton      (Button)
```

**Six content prefabs**, one per puzzle, each holding its own interactive elements as screen-space
rects authored against the prop's `ExamineAnchor` framing.

**`RoomDressing`**, on the environment's Props root
```
FocalSlot        (Transform)   hero prop mounts here
DressingSlots    (Transform)   4 authored positions per layout preset
```

The frame owns camera, timer, leave, and solve transitions. Content prefabs own only their puzzle's
elements. That split is what keeps a seventh puzzle cheap to add later.

---

## 10. Acceptance Criteria

- Pyre and VoidRiftSeal resolve in-room with no examine camera move.
- The other four use `ExamineFrame` with a dolly to an authored `ExamineAnchor`.
- The room backdrop and floor remain visible behind every puzzle in both modes.
- Puzzle input uses screen-space rects, never a raycast into world geometry.
- Tapping during any camera transition snaps it to the end.
- Solve and fail animate the prop. No banner or modal appears in either case.
- Timed puzzle tap targets are at least 88dp. Untimed are at least 64dp.
- The VoidRiftSeal ordinal cue is size-based and does not rely on colour.
- The VoidRiftSeal timer is visible before it starts, and starts on first tap.
- Failure retries in place without a camera return.
- Consecutive rooms never share a camera yaw or layout preset.
- The entrance always uses yaw preset 1 and the boss room uses a preset no other room uses.
- Standard and Elite rooms have no hero prop.
- Hero props are shared across dungeons with three tier variants each.
- Room to room uses a forward push with fade, not a cut.
- No puzzle solve logic, reward, or hazard rule changes.
- Runtime sets no colours, sizes, spacing, or fonts.

---

*Path: docs/dungeon-diegetic-puzzles-spec.md*
*Two interaction modes: four examine-mode puzzles and two in-room. World-space framing with*
*screen-space input. Room variety from 4 camera yaws by 4 layouts by 20 dressing subsets, which is*
*320 presentations from 6 prop sprites per dungeon. Art budget 70 sprites, generation order in*
*section 8.*
