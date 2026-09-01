---
type: design-spec
version: 1.0
updated: 2026-08-29
path: docs/grimoire-book-spec.md
resolves: bug #64, Grimoire inspection overhaul
implements: GrimoireBookUI rebuild, page templates, InputDiagram variants
reads-from: ConstellationLibrary, VanguardComboLibrary, GrimoireData
companion: runic-constellation-spec.md v0.5, subclass-trees-*.md,
           grimoire-onboarding-lore.md, combat-screen-clarity-spec.md
---

# Grimoire Book, Inspection View Overhaul
### Version 1.0

---

## 1. What Is Wrong Today

One runtime-generated scrolling column holding identity, passive, idle behaviour, and
every ability at every depth. Three separate problems wear one costume:

**It is a list, so it reads as a list.** Everything is the same shape at the same weight,
so nothing is more important than anything else. The signature passive that defines the
Grimoire sits in the same visual register as the eighteenth locked spell.

**The input is described, not shown.** `IGN→GLA` tells a player who already knows the
system what to draw. It tells a new player nothing. The Arcanist's entire skill
expression is drawing a shape quickly from muscle memory, and the book currently teaches
the shape as a string of letters.

**The one-line cue carries all the instruction.** "Draw a path across the rune nodes,
then release" is the whole tutorial for a mechanic with order dependence, four depth
tiers, a speed bonus with four tiers, and subclass-specific counter pairs worth up to
×1.75. Almost none of what determines a player's damage is written down anywhere they
can read it.

The third one is the real bug. The cosmetic complaint is the symptom people notice.

---

## 2. Page Model

**Single page, not a two-page spread.** A spread on a 1080-wide portrait screen gives
each page roughly 500px, which forces either two-column ability rows or a font size
nobody can read on a bus. The book frame renders as an open book with the spine visible
at the left edge and one readable page filling the rest, which preserves the object
fantasy without halving the usable width.

### 2.1 Page order

| Page | Name | Content | Present for |
|---|---|---|---|
| 1 | Frontispiece | Cover art, name, path and subclass, tagline | All |
| 2 | The Binding | Signature passive, idle behaviour, lore, combat level | All |
| 3 | The Casting | Input primer with diagram, rules, bonus tables | All, per-path content |
| 4 to N | Ability pages | One page per depth group | All, per-path content |
| Last | The Unwritten | Runes or inputs not yet unlocked, what comes next | Arcanist and Vanguard |

Pages 1 to 3 are fixed. Pages 4 onward are generated from the depth groups the library
returns, so a Grimoire with three depth tiers gets three pages and one with four gets
four. No page is ever empty.

### 2.2 One page per depth group

Depth is the right chapter boundary for three reasons. Each depth group holds five to
eight entries, which fits one portrait page without scrolling. Depth is already how both
libraries group their data, so the page structure needs no new grouping logic. And depth
is the progression axis, so a page the player cannot use yet becomes a visible locked
chapter rather than a scattering of greyed rows among usable ones.

### 2.3 Locked content is shown, not hidden

**Individual locked entries** render dimmed in place with a lock icon and an "Unlocks at
level N" label, per the direction already in runic-constellation-spec.md section on
Grimoire Book display. The player sees what is coming.

**A wholly locked depth page** renders all its entries dimmed under a wax seal band
across the top reading "Sealed until Grimoire Level 88". The page is still reachable and
still readable. A locked chapter you can leaf through is an invitation. A hidden one is
an absence the player cannot plan around.

---

## 3. Navigation

**Horizontal swipe** turns pages, left for next and right for previous, with a page
corner curl following the finger.

**A bookmark rail** runs down the right edge, one ribbon tab per page, tap to jump. This
is the index, and it doubles as the progression readout because sealed pages show their
ribbon in a muted state. Ribbons are thumb-reachable on the right edge in portrait.

**A footer** holds the page number as "3 of 7" plus explicit previous and next controls,
because swipe alone is undiscoverable for a player who has never turned a page in this
game before.

**Close** returns to the Character page. The book remembers the last page viewed for the
duration of the app session, so a player checking a spell mid-session does not start at
the cover every time.

---

## 4. Page 1, Frontispiece

```
┌─────────────────────────────────────┐
│ ║                                   │
│ ║        [ cover art plate ]        │
│ ║                                   │
│ ║      GRIMOIRE OF THE RUNEWEAVER   │
│ ║        Arcanist · Runeweaver      │
│ ║                                   │
│ ║   "Speak the older language.      │
│ ║    Let fire answer in turn."      │
│ ║                                   │
│ ║              Level 34             │
│ ║                                   │
│ ║                             [1/7] │
└─────────────────────────────────────┘
```

Cover art is the Grimoire's own plate, one per Grimoire. Tagline uses the `cardFlavor`
line from grimoire-onboarding-lore.md rather than the shorter tagline, because the card
flavor is written to be evocative and this page has room for it.

---

## 5. Page 2, The Binding

```
┌─────────────────────────────────────┐
│ ║  THE BINDING                      │
│ ║                                   │
│ ║  Every rune is a word in a        │
│ ║  language older than the          │
│ ║  kingdoms, and the Runeweaver     │
│ ║  speaks it without stammering...  │
│ ║                                   │
│ ║  ─────────────────────────────    │
│ ║  SIGNATURE PASSIVE                │
│ ║  Arcane Flow                      │
│ ║  Constellation spell shaping.     │
│ ║                                   │
│ ║  ─────────────────────────────    │
│ ║  WHEN YOU ARE AWAY                │
│ ║  Auto-casts your last drawn       │
│ ║  spell at 60 percent power,       │
│ ║  every 4.0 seconds at this level. │
│ ║                             [2/7] │
└─────────────────────────────────────┘
```

The idle line is populated with the player's actual current interval from the level
table rather than generic text. A number that moves as the player levels is worth far
more than a sentence that does not.

Lore text is the `loreText` paragraph from grimoire-onboarding-lore.md, so the book and
the onboarding picker speak with one voice.

---

## 6. Page 3, The Casting

The instruction page. This is the fix for the second half of the bug report and it
carries the highest-value content in the overhaul.

### 6.1 Arcanist

```
┌─────────────────────────────────────┐
│ ║  THE CASTING                      │
│ ║                                   │
│ ║      [ large rune arch diagram ]  │
│ ║       showing a finger path       │
│ ║       across three nodes with     │
│ ║       order numbers 1, 2, 3       │
│ ║                                   │
│ ║  Press a rune, drag through the   │
│ ║  runes you want, then lift to     │
│ ║  cast. Order matters. Fire into   │
│ ║  ice is not ice into fire.        │
│ ║                                   │
│ ║  ─────────────────────────────    │
│ ║  DRAW FAST                        │
│ ║  Under 0.4s      damage x1.5      │
│ ║  0.4s to 0.8s    damage x1.25     │
│ ║  0.8s to 1.5s    damage x1.0      │
│ ║  Over 1.5s       damage x0.85     │
│ ║                                   │
│ ║  ─────────────────────────────    │
│ ║  COUNTER PAIRS                    │
│ ║  Ignis and Glacius     x1.5       │
│ ║  Tempest and Ventus    x1.5       │
│ ║  Umbra and Lux         x1.75      │
│ ║                             [3/7] │
└─────────────────────────────────────┘
```

The speed table and the counter pairs are currently invisible to the player and together
they are the difference between a ×0.85 cast and a ×2.6 one. Putting them on a page the
player can read is the single largest improvement in this document.

Counter pair values are read from the library per subclass, so Runeweaver shows its
elevated numbers and Summoner and Lifebinder show theirs.

### 6.2 Vanguard

Same page structure, different content: the three input glyphs named and explained, then
how sequences chain, then the depth unlock levels. If Vanguard has timing or window
rules in `VanguardComboLibrary`, they belong here in the same table position the
Arcanist speed tiers occupy.

### 6.3 Warden

```
│ ║      [ draw arc diagram ]         │
│ ║   a bow draw bar with the hold    │
│ ║   thresholds marked along it      │
│ ║                                   │
│ ║  Press and hold to draw. Drag to  │
│ ║  aim. Release to fire. The longer │
│ ║  you hold, the harder it lands.   │
│ ║                                   │
│ ║  HOLD THRESHOLDS                  │
│ ║  1.0s    Barbed Shot ring         │
│ ║  1.5s    Full draw, Piercing Shot │
│ ║  3.0s    Hunter's Patience cap    │
│ ║  5.0s    The Long Shot            │
│ ║                                   │
│ ║  WEAK POINTS                      │
│ ║  Enemy weak points glow. A hit    │
│ ║  there multiplies your damage.    │
```

The threshold list is populated from the Grimoire's own unlocked techniques, so a level
9 Sharpshot sees two rows and a level 90 Sharpshot sees five.

---

## 7. Pages 4 to N, Ability Pages

```
┌─────────────────────────────────────┐
│ ║  TWO-RUNE SPELLS                  │
│ ║  Unlocked at level 16             │
│ ║                                   │
│ ║  ┌───────────────────────────┐    │
│ ║  │ [diagram]  Steam Burst     │    │
│ ║  │  IGN→GLA   AoE fire and    │    │
│ ║  │            ice, plus blind │    │
│ ║  │            10 mana         │    │
│ ║  └───────────────────────────┘    │
│ ║  ┌───────────────────────────┐    │
│ ║  │ [diagram]  Twilight Surge  │    │
│ ║  │  UMB→LUX   Counter burst,  │    │
│ ║  │            highest 2-rune  │    │
│ ║  │            10 mana  x1.75  │    │
│ ║  └───────────────────────────┘    │
│ ║  ┌───────────────────────────┐    │
│ ║  │ [dimmed]   Eclipse Strike  │    │
│ ║  │  LUX→UMB   Unlocks at 44   │    │
│ ║  └───────────────────────────┘    │
│ ║                             [5/7] │
└─────────────────────────────────────┘
```

### 7.1 The ability entry

Every entry, on every path, holds the same six regions. This is what makes one framework
serve three paths.

| Region | Arcanist | Vanguard | Warden |
|---|---|---|---|
| InputDiagram | Mini rune path | Glyph row | Draw bar with threshold |
| Title | Spell name | Combo name | Technique name |
| InputKey | `IGN→GLA` | `S→G→U` | `Hold 1.5s` |
| Effect | Effect text | Effect text | Effect text |
| Cost | Mana or HP | Blank or resource | Blank |
| Right | Unlock level or counter bonus | Unlock level | Unlock level |

The cost line is new and matters. Depth costs 5, 10, 18, and 28 mana, and for Lifebinder
it is 8, 16, 28 HP instead. A Lifebinder reading that their heal costs health is
learning the defining fact about their Grimoire, and the current view does not tell them.

### 7.2 The input diagram is the point

A mini diagram beside every entry is what turns the book from a reference into a
teaching tool. The player looks at the shape, then draws that shape. `IGN→GLA` requires
them to translate a code into a position on an arch they are not currently looking at.

**Arcanist, DiagramRunePath.** The subclass six-node arch drawn small, with the spell's
path stroked between nodes and small order numbers at each stop. Nodes not in the path
render faint. Revisited nodes, as in Storm Caller, show the path passing through twice.

**Vanguard, DiagramComboGlyphs.** The Strike, Guard, and Surge glyphs in sequence with
connectors and order numbers, up to four.

**Warden, DiagramDrawArc.** A horizontal draw bar with a marker at that technique's hold
threshold and the earlier thresholds shown faintly, so a player reading Killshot sees
where full draw sits relative to it.

All three occupy the same region at the same size. Three prefab variants, one slot.

---

## 8. Last Page, The Unwritten

For Arcanist and Vanguard only, since both have progressive input unlocks.

Arcanist shows the rune unlock schedule: which runes the player has, which are coming,
and at what level. That schedule exists in the library and is surfaced nowhere in the
game today, so a player at level 8 has no idea a fifth rune arrives at 10.

Vanguard shows the equivalent for input depth.

Warden skips this page, because its progression is the technique list itself and a
separate page would repeat it.

---

## 9. How The Three Paths Share One Framework

| Element | Shared | Per path |
|---|---|---|
| Book frame, page surface, bookmarks, footer | Yes | |
| Pages 1 and 2 | Yes, same regions | Data only |
| Page 3 body copy and tables | Structure only | Copy and table rows |
| Ability page header and entry list | Yes | |
| Ability entry regions | Yes, all six | |
| InputDiagram | Region shared | Three prefab variants |
| Depth group count and names | Driven by data | Library supplies groups |

Warden is the path that needs work before this ships. It currently renders a single bow
summary because there is no `WardenTechniqueLibrary` equivalent to the other two. The
subclass trees define fifteen unlocks per Warden Grimoire with levels, types, and
descriptions, which is exactly the shape the ability page wants. Section 12.1 covers this.

---

## 10. Baked Structure

Runtime populates and toggles. It never sets a colour, a size, a spacing value, or a
font. Child names below are what the runtime looks for.

### 10.1 Root

**`GrimoireBookRoot`**
```
BookFrame          (Image)        static book and spine art
PageSurface        (Image)        parchment
PageContent        (Transform)    one page prefab instantiated here
BookmarkRail       (Transform)    parent for BookmarkTab clones
PageCurl           (Image)        follows drag during a turn
Footer
  PageNumber       (Text)         "3 of 7"
  PrevButton       (Button)
  NextButton       (Button)
CloseButton        (Button)
```

### 10.2 Page prefabs, dropped into PageContent

**`PageFrontispiece`**
```
CoverArt           (Image)
Title              (Text)         "GRIMOIRE OF THE RUNEWEAVER"
Subtitle           (Text)         "Arcanist · Runeweaver"
Flavor             (Text)         cardFlavor line
LevelLabel         (Text)         "Level 34"
```

**`PageBinding`**
```
Header             (Text)         "THE BINDING"
Lore               (Text)         loreText paragraph
PassiveHeader      (Text)         "SIGNATURE PASSIVE"
PassiveName        (Text)
PassiveBody        (Text)
IdleHeader         (Text)         "WHEN YOU ARE AWAY"
IdleBody           (Text)         interval interpolated from current level
```

**`PageCasting`**
```
Header             (Text)         "THE CASTING"
DiagramSlot        (Transform)    holds one large InputDiagram variant
PrimaryCopy        (Text)         the three or four input rules
TableAHeader       (Text)         "DRAW FAST" / "INPUT WINDOW" / "HOLD THRESHOLDS"
TableAContainer    (Transform)    parent for BookTableRow clones
TableBHeader       (Text)         "COUNTER PAIRS" / "" / "WEAK POINTS"
TableBContainer    (Transform)    parent for BookTableRow clones, hidden if unused
```

**`PageAbilityList`**
```
Header             (Text)         "TWO-RUNE SPELLS"
Subheader          (Text)         "Unlocked at level 16"
SealBand           (GameObject)   toggled when the whole depth is locked
SealLabel          (Text)         "Sealed until Grimoire Level 88"
EntryContainer     (Transform)    parent for AbilityEntry clones
```

**`PageUnwritten`**
```
Header             (Text)         "THE UNWRITTEN"
Body               (Text)
UnlockContainer    (Transform)    parent for BookTableRow clones
```

### 10.3 Row and part prefabs

**`AbilityEntry`**
```
DiagramSlot        (Transform)    holds one small InputDiagram variant
Title              (Text)
InputKey           (Text)         "IGN→GLA"
Effect             (Text)
Cost               (Text)         "10 mana" / "16 HP" / blank
Right              (Text)         "x1.75" or blank
Locked             (GameObject)   dim overlay plus lock icon
LockLabel          (Text)         "Unlocks at level 44"
```

**`BookTableRow`**
```
Title              (Text)
Right              (Text)
```

**`BookmarkTab`**
```
Label              (Text)         short page name
Active             (GameObject)   toggled for the current page
Sealed             (GameObject)   toggled for locked depth pages
```

**`DiagramRunePath`**
```
NodeContainer      (Transform)    six node slots, positions authored
PathLine           (UILineRenderer or Image chain)
OrderLabels        (Transform)    small numeric labels
```

**`DiagramComboGlyphs`**
```
GlyphSlots         (Transform)    up to four, positions authored
Connectors         (Transform)
OrderLabels        (Transform)
```

**`DiagramDrawArc`**
```
Bar                (Image)
ThresholdMarker    (RectTransform)
GhostMarkers       (Transform)    earlier thresholds, faint
ThresholdLabel     (Text)         "1.5s"
```

Twelve prefabs, of which four are pages and three are diagram variants. The diagram
variants are the only genuinely novel authoring work.

---

## 11. Art Assets

| Asset | Size | Notes |
|---|---|---|
| Book frame, open book portrait with spine | 1080x1800 | The container. Aged leather, brass corner fittings, visible stitching at the spine. |
| Parchment page surface | 1080x1600 | Tileable vertically. Warm cream, subtle fibre, slightly darker at the spine edge. |
| Page corner curl | 256x256 | Follows the drag during a turn |
| Ribbon bookmark tab, two states | 96x160 | Active and inactive. Faded crimson silk. |
| Wax seal band | 900x120 | For sealed depth pages. Dark red wax over a paper band. |
| Strike, Guard, Surge glyphs | 96x96 each | Three. Carved sigil style, gold on dark. |
| Draw arc bar and marker | 512x64 | Warden diagram |
| Grimoire cover plates | 720x720 | One per Grimoire, seven at launch |

**Reused, no new art:** the eight rune node sprites from `ConstellationUI`, the existing
lock icon, and the existing dim overlay treatment.

Audio worth one line: a page turn sound. The whole design rests on the object reading as
a book, and a silent page turn undercuts every pixel of the frame art.

---

## 12. Things Wrong Beyond The Brief

**12.1 Warden has no ability library, so its book will be one page.** Arcanist reads from
`ConstellationLibrary` and Vanguard from `VanguardComboLibrary`. Warden has neither, which
is why it renders a single bow summary today. If this ships without fixing that, a
Sharpshot player opens the overhauled book and finds three pages where an Arcanist finds
seven, and the original complaint comes straight back from half the playerbase.

The data exists. subclass-trees-warden.md defines fifteen unlocks per Grimoire with
level, type, cross-talent requirement, and description. That wants to become a
`WardenTechniqueLibrary` with the same shape the other two expose. Grouping is by type
rather than depth: Techniques, Ring Unlocks, Passives. Three pages, same framework.

I would treat this as a prerequisite rather than a follow-up.

**12.2 The speed and counter tables are the most valuable thing missing from the game,
not just from this view.** An Arcanist's damage swings by roughly 3x between a slow
non-counter cast and a fast counter cast, and nothing in the game tells them. Page 3 is
the fix, but it is worth asking whether the combat screen should surface the speed tier
as feedback on each cast too. Out of scope here, flagged because this document is where
the gap became obvious.

**12.3 The rune unlock schedule is invisible.** Runes arrive at levels 1, 4, 7, 10, and
13, and the arch silently grows. runic-constellation-spec.md specifies a level-up
notification for this, which may or may not be wired. The Unwritten page covers the
reference case, but a player at level 8 should also be able to learn that a fifth rune is
two levels away without opening a book.

**12.4 Cross-talent requirements are not shown anywhere.** Warden techniques gate on
Runesmithing, Tracking, Foraging, Alchemy, and more. A player at Grimoire level 9 who
cannot use Piercing Shot because their Runesmithing is 4 has no way to discover why. When
Warden entries are built, the lock label needs to name both gates, not just the level.

**12.5 The book should say which Grimoire this is when several are owned.** With multiple
Grimoires the player can inspect any of them, but the view is opened from the equipped
portrait and reads as though it is the only one. A small "Equipped" mark on the
frontispiece, and eventually the ability to page between owned Grimoires, would prevent
the confusion. Not required for this pass.

---

## 13. Acceptance Criteria

- The view renders as a single-page book with frame, parchment, bookmarks, and a footer.
- Pages 1 to 3 exist for every Grimoire on every path.
- Ability pages are generated one per depth group returned by the path's library.
- Every ability entry shows an input diagram, not only a text key.
- Arcanist entries show mana cost, and Lifebinder entries show HP cost instead.
- Page 3 shows the speed tier table and the counter pair table for Arcanists, with values
  read from the library for the current subclass.
- Locked entries render dimmed in place with the level that unlocks them.
- A fully locked depth page renders sealed and remains reachable and readable.
- Bookmarks jump directly to any page and show the sealed state.
- Swipe and the footer buttons both turn pages.
- The book reopens on the last page viewed within an app session.
- Warden renders at least three ability pages, not one summary.
- Runtime sets no colours, sizes, spacing, or fonts anywhere in this view.

---

*Path: docs/grimoire-book-spec.md*
*Single-page book, three fixed pages plus one page per depth group. Twelve baked prefabs,*
*three of them input diagram variants. Warden technique library flagged as a prerequisite.*
