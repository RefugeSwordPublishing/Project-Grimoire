---
type: design-spec
version: 1.0
updated: 2026-08-28
path: docs/combat-menu-hub-spec.md
resolves: combat-menu-hub-REQUEST.md
implements: SectionHubBaked (Combat), ZoneDetailPanel, DungeonInfoPopup,
            PreBossLobbyUI generalization, BossLobbyManager generalization
amends: combat-navigation-flow-spec.md section 5, see section 9
companion: combat-screen-clarity-spec.md v1.0
---

# Combat Menu Hub Redesign
### Version 1.0

---

## 1. Why It Reads As A Menu

The developer's reaction is correct and the cause is structural rather than cosmetic.

Every element on the screen is the same shape. Zone cards are full-width rows. Expanding
a zone produces more full-width rows nested inside the first ones. Enemies are rows,
Enter is a row, the dungeon is a row. A screen made entirely of one repeated shape is a
list, and a list of lists is a menu no matter how it is skinned.

Worse, expanding in place never moves the player anywhere. They tap, the list gets
longer, and they are still in the list. That is the definition of drilling through a menu.

Three moves fix it, in order of impact:

1. **Zone detail becomes its own surface**, pushed over the hub, not an in-place
   expansion. The player arrives somewhere instead of scrolling further.
2. **Zones become tiles in a two-column grid with art**, grouped under tier headers.
   Different shape, different rhythm, art carries the identity.
3. **Primary actions become buttons at the bottom**, not rows in the middle. A button
   that looks like a button stops the screen reading as data.

Everything below is those three moves plus the dungeon path the brief asks for.

---

## 2. Stage Plan

Implement in this order. Each stage is shippable on its own.

| Stage | Scope | Depends on | Why this order |
|---|---|---|---|
| 1 | Hub reshape: banner, tier headers, zone tile grid, Continue strip, Raids | nothing | Highest impact on the hub-feel complaint, lowest risk, touches no new systems |
| 2 | Zone detail panel: grouped enemies, Enter Zone, Dungeon button | Stage 1 | Removes in-place expansion, which is the root cause |
| 3 | Dungeon info popup | Stage 2 | Needs the Dungeon button to exist |
| 4 | Dungeon lobby and invites | Stage 3 | Needs the popup's Enter Lobby action, and carries the only real scope risk |

Stage 4 is the one to scope before committing. See section 8.4.

---

## 3. Stage 1, Hub Layout

```
┌───────────────────────────────────────┐
│  BANNER                               │
│  [portrait]  SHARPSHOT      Lv 12     │
│              ██████████░░  1,340/1,800│
│              Total Combat Level 12    │
│              Next zone unlocks at 21  │
├───────────────────────────────────────┤
│  CONTINUE                             │
│  Grimwood Fringe · Tier 1    [Enter]  │
├───────────────────────────────────────┤
│  TIER 1                               │
│  ┌───────────┐  ┌───────────┐         │
│  │ [art]     │  │ [art]     │         │
│  │ Grimwood  │  │ Saltmarsh │         │
│  │ Fringe    │  │ Shore     │         │
│  │ Open      │  │ Open      │         │
│  │   [Enter] │  │   [Enter] │         │
│  └───────────┘  └───────────┘         │
│                                       │
│  TIER 2                               │
│  ┌───────────┐  ┌───────────┐         │
│  │ [art dim] │  │ [art dim] │         │
│  │ Ashfen    │  │ Ironspine │         │
│  │ Mire      │  │ Reaches   │         │
│  │ Needs 21  │  │ Needs 21  │         │
│  │ (have 12) │  │ (have 12) │         │
│  └───────────┘  └───────────┘         │
│                                       │
│  ...                                  │
├───────────────────────────────────────┤
│  RAIDS                                │
│  Large group encounters.              │
│  Coming in a future update.           │
└───────────────────────────────────────┘
```

### 3.1 The banner

The Grimoire header stops being a list item and becomes a banner: portrait on the left,
name and level stacked to the right, XP bar beneath, Total Combat Level and the next
gate as two quiet lines under that. Fixed at the top of the scroll, not pinned, so it
scrolls away as the player moves down the ladder.

Content is unchanged from the clarity spec. Only the shape changes.

### 3.2 Tier grouping

A small header row per tier, then that tier's zones in a two-column grid. Tier headers
are the only full-width text elements in the body, which makes them read as structure
rather than content.

Grouping by tier does the work the old flat list could not: the ladder becomes visible
as a ladder, and the locked tiers below the player's position read as territory rather
than as a junk drawer of greyed rows.

### 3.3 Zone tiles

Two columns. Each tile carries the zone card art already specced at 576x240 in
art-asset-requirements.md, so no new art is needed.

Tile contents:

| Element | Unlocked | Locked |
|---|---|---|
| Art | Full colour | Dimmed |
| Title | Zone name | Zone name |
| Subtitle | "Tier N · Open" | "Needs 21 (have 12)" |
| Enter button | Visible | Hidden |

The locked subtitle keeps both numbers on one line. The clarity spec required the
arithmetic to be visible and a tile has less room than a card, so the requirement and
the player's current value share a line rather than losing the delta entirely.

### 3.4 Two tap targets per tile, deliberately

Tapping the tile body opens the zone detail. Tapping the Enter button on the tile enters
the zone directly.

This preserves the two-tap ceiling from combat-navigation-flow-spec.md for a player who
knows where they are going, while giving a new player a detail surface to read. Without
the tile Enter button, every cold-start path becomes three taps and the nav spec's own
rule says that change would be wrong.

### 3.5 Raids stays full width

Raids keeps the full-width muted card from the nav flow spec rather than becoming a
grid tile. Different shape communicates different meaning: a tile among tiles reads as a
zone you cannot reach yet, which is precisely the wrong message for content that is not
built.

---

## 4. Stage 2, Zone Detail Panel

A distinct surface pushed over the hub, in the same manner `SectionHubBaked` covers the
main hub. Not an expansion. The player goes somewhere.

```
┌───────────────────────────────────────┐
│  [<]  GRIMWOOD FRINGE        Tier 1   │
├───────────────────────────────────────┤
│  [ hero art strip, zone backdrop ]    │
│                                       │
│  Old pines and older grudges. Bandits │
│  work the treeline here.              │
├───────────────────────────────────────┤
│  ENEMIES                              │
│                                       │
│  Standard                             │
│  ┌──────────────┐ ┌──────────────┐    │
│  │ Grimwood     │ │ Forest Wolf  │    │
│  │ Brigand  28% │ │          22% │    │
│  └──────────────┘ └──────────────┘    │
│  ┌──────────────┐ ┌──────────────┐    │
│  │ Poacher  20% │ │ Grimwood     │    │
│  │              │ │ Bear     15% │    │
│  └──────────────┘ └──────────────┘    │
│                                       │
│  Elite                                │
│  ┌──────────────┐ ┌──────────────┐    │
│  │ Bandit Scout │ │ Rabid Wolf-  │    │
│  │       ELITE  │ │ pack  ELITE  │    │
│  └──────────────┘ └──────────────┘    │
│                                       │
│  Boss                                 │
│  ┌──────────────┐                     │
│  │ Aldric the   │                     │
│  │ Poacher BOSS │                     │
│  └──────────────┘                     │
├───────────────────────────────────────┤
│  [        ENTER ZONE        ]         │
│  [ (icon) ALDRIC'S WARREN   ]         │
└───────────────────────────────────────┘
```

### 4.1 Grouped enemies, not a spreadsheet

Enemies are chips in a two-column grid, grouped under three sub-headers: Standard,
Elite, Boss. The grouping is what stops it reading as a table. A player scanning the
panel learns the shape of the zone (four standard, two elite, one boss) before reading
a single name.

Chip contents: enemy name, spawn percentage right-aligned and muted, and a marker tag
for Elite and Boss. Standard enemies carry no marker, so the markers stay meaningful.

Two columns rather than three. Names like "Spell-Bound Sentinel" and "Rabid Wolfpack
Leader" do not fit a third of a portrait-width screen without truncation, and truncated
enemy names in a panel whose job is orientation defeats the panel.

Spawn percentages are computed from `spawnWeight` normalised across the zone's standard
enemies. Elites and bosses do not roll on the standard table, so their chips show the
marker in place of a percentage rather than a misleading number.

### 4.2 A note on showing exact percentages

The brief asks for spawn percentages and this spec delivers them. Worth flagging that
exact percentages are the single most spreadsheet-like element remaining on the panel,
and they are the first thing to soften if the panel still reads as data after skinning.
The softer version is frequency bands (Common, Uncommon, Rare) with the exact figure on
long press. I would ship the percentages first and see how it feels on device.

### 4.3 The two action buttons

Both full-width, stacked, at the bottom of the panel where a thumb reaches without a
grip change.

**ENTER ZONE.** Primary treatment. Always present.

**Dungeon button.** Secondary treatment, directly beneath, carrying the dungeon icon and
the dungeon's name as its label. Present only when `hasDungeon` is true.

When the zone has a dungeon the player has not yet unlocked, show the button disabled
with the requirement as its label rather than hiding it. A button that vanishes teaches
nothing. A button that says what it needs teaches the gate.

### 4.4 Colour intent

The panel needs a treatment distinct from the hub so that arriving on it feels like
arriving somewhere. The intent, for the developer to skin:

- A raised surface, darker and warmer than the hub background, with a visible edge so
  the panel reads as sitting on top rather than replacing.
- The hero art strip bleeding to the panel edges at the top, so the zone's own palette
  is the first colour the player sees.
- Section headers (ENEMIES, Standard, Elite, Boss) in a quiet accent, small and
  letter-spaced, so they structure without competing.
- The two action buttons carrying the only saturated colour on the panel. Primary and
  secondary should be visibly different weights, not two of the same button.

Exact palette is the developer's. If a per-zone accent is wanted later, it would need an
`accentColor` field on `ZoneData`. Not required for this pass, the art carries the
identity.

---

## 5. Stage 3, Dungeon Info Popup

A baked modal in the same family as the boss lobby overlay. Its job is one sentence:
here is what you are walking into.

```
┌─────────────────────────────────┐
│         [dungeon icon]          │
│       ALDRIC'S WARREN           │
│    Tier 1 · Recommended Lv 8    │
├─────────────────────────────────┤
│  Rooms              5 to 6      │
│  Boss     Aldric the Wolf       │
│  First clear    500 Combat XP   │
├─────────────────────────────────┤
│  ROOM TYPES                     │
│  [i] Standard 5   [i] Treasure 1│
│  [i] Safe 1       [i] Boss 1    │
├─────────────────────────────────┤
│      [   ENTER LOBBY   ]        │
│      [     Cancel      ]        │
└─────────────────────────────────┘
```

### 5.1 What to show and where it comes from

| Line | Source | Notes |
|---|---|---|
| Name | `DungeonData.dungeonName` | |
| Tier | parent `ZoneData.tier` | |
| Recommended level | `DungeonData.recommendedLevel` | Verify the field exists, see section 8.1 |
| Rooms | fixed rooms plus `minRooms` to `maxRooms` | Entrance, safe, boss are always present, so the total is minRooms+3 to maxRooms+3 |
| Boss | `DungeonData.bossRoom` enemy name | |
| First clear | `DungeonData.firstClearXP` | Verify the field exists |
| Room types | count by `RoomType` across `roomPool[]` | Only types actually present are listed |

Room type icons already exist in the asset tracker at 64x64 for all seven types
(Standard, Elite, Safe, Boss, Puzzle, Treasure, Trap). Reuse them.

Do not list expected item rewards. Drop tables are per-room and per-enemy, so any summary
would either be a wall of text or a promise the run may not keep.

### 5.2 Actions

**ENTER LOBBY.** Primary. Opens the dungeon lobby.

**Cancel.** Secondary. Dismisses back to the zone detail panel with the panel's scroll
position intact.

---

## 6. Stage 4, Dungeon Lobby

Reuse `PreBossLobbyUI` and `BossLobbyManager`. Do not build a parallel system.

### 6.1 What is shared, unchanged

- Party slot layout, host plus up to two guests
- Per-slot Ready flags
- Solo host is ready by default and can always start
- Start control
- Leave control
- Party chat bound to the lobby channel

### 6.2 What a dungeon lobby needs that the boss lobby does not

**A launch target that is not a boss.** The manager currently starts a boss fight. It
needs to start a dungeon run instead. The smallest generalization:

```csharp
public enum LobbyEncounterKind { ZoneBoss, Dungeon }

public class LobbyContext
{
    public LobbyEncounterKind kind;
    public string zoneId;
    public string targetId;   // boss enemy id, or dungeonId
}
```

`BossLobbyManager` takes a `LobbyContext` when the lobby opens and its start handler
branches on `kind`. Everything upstream of the start handler is identical for both
encounter types, which is why the reuse is worth doing rather than forking.

**A different header.** The boss lobby names the boss. The dungeon lobby names the
dungeon and shows the room count, so a guest who was invited without seeing the info
popup still knows what they joined.

**A visible Invite control.** See below.

### 6.3 Invites

Today invites go through the party or chat channel, which means a player has to know
that is how it works. Make it visible in two places on the lobby.

**Empty party slots are the invite affordance.** An empty slot renders an "INVITE"
label and is tappable. This is the clearest possible mobile pattern: the action sits
exactly where the mental model already is, in the hole a person would fill.

**A dedicated Invite button** beneath the party slots, for the case where all slots are
somehow occupied by pending invites, and for discoverability.

Both open the same existing friend and party invite picker. No new invite system.

### 6.4 Lobby layout

```
┌─────────────────────────────────┐
│  ALDRIC'S WARREN                │
│  Tier 1 · 5 to 6 rooms          │
├─────────────────────────────────┤
│  [host portrait] Dustin   READY │
│  [empty slot]           INVITE  │
│  [empty slot]           INVITE  │
├─────────────────────────────────┤
│         [   INVITE   ]          │
├─────────────────────────────────┤
│  [ party chat ]                 │
├─────────────────────────────────┤
│  [   ENTER DUNGEON   ]          │
│  [       Leave       ]          │
└─────────────────────────────────┘
```

Start control reads ENTER DUNGEON rather than START FIGHT when `kind` is `Dungeon`.

---

## 7. Baker And Asset Checklist

### 7.1 Existing templates reused, no baker work

| Template | Used for |
|---|---|
| `CombatCardTemplate` | Continue strip, Raids placeholder |
| `CombatSubRowTemplate` | Dungeon popup info lines (Rooms, Boss, First clear) |
| `PreBossLobbyUI` overlay | Dungeon lobby, with the generalization in 6.2 |
| Room type icons, 64x64, seven types | Dungeon popup room mix |
| Zone card art, 576x240 | Zone tiles and zone detail hero strip |

### 7.2 New baked templates the developer must build

Runtime clones and fills data only. Child object names below are what the runtime looks
for, following the existing `Title` / `Right` / `Subtitle` / `Locked` convention.

**1. `CombatHubBanner`** (one instance, top of hub)
```
GrimoirePortrait (Image)
Title            (Text)   Grimoire name
Right            (Text)   "Lv 12"
XPFill           (Image)  fillAmount 0..1
XPLabel          (Text)   "1,340 / 1,800"
TotalLevel       (Text)   "Total Combat Level 12"
NextGate         (Text)   "Next zone unlocks at 21"
```

**2. `TierGroupHeader`** (one per tier)
```
Title            (Text)   "TIER 2"
```

**3. `ZoneTileTemplate`** (grid cell, two columns)
```
ZoneArt          (Image)
Title            (Text)   zone name
Subtitle         (Text)   "Tier 1 · Open" or "Needs 21 (have 12)"
Locked           (GameObject)  dim overlay, toggled
EnterButton      (Button)      hidden when locked
```

**4. `ZoneDetailPanel`** (one, full-screen overlay)
```
BackButton       (Button)
Title            (Text)   zone name
Right            (Text)   "Tier 1"
HeroArt          (Image)
Description      (Text)
EnemyContainer   (Transform)   parent for group headers and chip grids
EnterZoneButton  (Button)
DungeonButton    (GameObject)  toggled on hasDungeon
DungeonIcon      (Image)
DungeonLabel     (Text)        dungeon name, or requirement when locked
```

**5. `EnemyGroupHeader`** (one per group: Standard, Elite, Boss)
```
Title            (Text)   "Standard"
```

**6. `EnemyChipTemplate`** (grid cell, two columns)
```
Title            (Text)   enemy name
Right            (Text)   "28%" or empty
Marker           (GameObject)  toggled for elite and boss
MarkerLabel      (Text)        "ELITE" or "BOSS"
```

**7. `DungeonInfoPopup`** (one, modal)
```
DungeonIcon      (Image)
Title            (Text)   dungeon name
Subtitle         (Text)   "Tier 1 · Recommended Lv 8"
InfoContainer    (Transform)   parent for CombatSubRowTemplate clones
RoomTypeContainer(Transform)   parent for RoomTypeChip clones
EnterLobbyButton (Button)
CancelButton     (Button)
```

**8. `RoomTypeChipTemplate`** (grid cell)
```
Icon             (Image)
Title            (Text)   "Standard"
Right            (Text)   "5"
```

**9. `LobbyInviteSlot`** (extension of the existing empty party slot)
```
InviteButton     (Button)
InviteLabel      (Text)   "INVITE"
```

### 7.3 Layout components the baker sets, not the runtime

Zone tiles, enemy chips, and room type chips all sit in `GridLayoutGroup` containers
with fixed cell sizes authored in the editor. The runtime instantiates children and
never sets cell size, spacing, or padding. This keeps the two-column decision skinnable:
if the developer wants three columns of enemy chips on a wider device, that is a cell
size change in the editor with no code touched.

### 7.4 New art

None strictly required. Zone card art and room type icons already exist. The dungeon
icon for the Dungeon button and the popup header should come from the existing room type
Boss icon or a dedicated dungeon glyph if one exists. If not, one 64x64 dungeon glyph is
the only new art in this spec.

---

## 8. Fields And Scope To Verify Before Building

**8.1 `DungeonData` fields.** The popup wants `recommendedLevel`, `minRooms`, `maxRooms`,
and `firstClearXP`. The brief lists only `dungeonName`, `zoneId`, and the room fields.
Those four values exist in the dungeon design briefs, so confirm whether they are
authored on the asset or only in documentation. If they are documentation only, they need
adding to `DungeonData` before Stage 3.

**8.2 Boss name for the popup.** `bossRoom` is a `RoomData`. Confirm it carries a
reference to the boss `EnemyData` so the popup can show the boss name, or add one.

**8.3 Spawn percentage normalisation.** Confirm `spawnWeight` is only meaningful across
standard enemies. If elites carry a weight that participates in the same roll, the
percentages shown need to account for it or they will be wrong.

**8.4 `BossLobbyManager` coupling, the real scope risk.** The generalization in 6.2 is
small if the manager already treats the encounter as a parameter, and large if boss
identity is threaded through the ready checks, the chat channel setup, and the start
handler. Read the manager before committing Stage 4 to a sprint. If the coupling is
deep, an acceptable interim is a dungeon lobby that reuses the baked overlay and the
party slot UI while calling its own start path.

---

## 9. Amendment To combat-navigation-flow-spec.md

That spec put dungeons as inline sub-rows on the parent zone card, hidden until the
player completes a zone session. This spec moves the dungeon to a button in the zone
detail panel with an info popup in front of it.

**Section 5 of the nav flow spec is superseded.** The parent-child relationship it
argued for is preserved and strengthened: the dungeon is now reached only from inside
its parent zone's own panel, which ties them together more firmly than a sub-row did.

**The progressive disclosure rule is preserved.** Keep the dungeon button hidden until
the player has completed at least one zone session. A first-session player still sees no
dungeons anywhere.

**The two-tap ceiling is preserved** via the tile Enter button, section 3.4.

---

## 10. Things I Think Are Wrong Beyond The Brief

**10.1 In-place expansion is the actual bug.** The brief asks for a grouped enemy view
and a coloured panel, and both help, but a grouped enemy list inside an expanding row is
still a list inside a list. If only one thing from this spec ships, make it the separate
detail panel.

**10.2 The Dungeon button should not disappear when locked.** The brief says show it when
the zone has a dungeon. Dungeons have their own level gates, and a button that vanishes
when the player is underlevelled teaches nothing and reads as a bug. Show it disabled
with the requirement as its label.

**10.3 Locked zone tiles lose space the clarity spec needed.** That spec required the
requirement, the player's current value, and the difference all visible on a locked
tile. A grid tile cannot carry three lines without becoming a card again. Compromise in
3.3 keeps two of the three numbers on one line and drops the explicit delta. If the
delta matters, it belongs on the detail panel, which locked zones should still be able
to open.

**10.4 Elites and bosses should not show a spawn percentage.** They do not roll on the
standard spawn table, so any number shown against them is either wrong or means
something different from the number next to it. Marker instead of percentage, per 4.1.

**10.5 Party chat on a solo lobby is dead space.** A solo player opening a dungeon lobby
sees a chat panel with nobody to talk to. Consider collapsing chat until a second player
joins, which also gives the lobby a visible reason to feel different when someone does.

---

## 11. Acceptance Criteria

- The Combat hub shows a banner, tier group headers, and zones in a two-column tile grid.
- Tapping a zone tile body opens the zone detail panel. Tapping the tile Enter button
  enters the zone directly, keeping cold start at two taps from the bottom nav.
- The zone detail panel is a separate surface. No zone expands in place anywhere.
- Zone detail groups enemies under Standard, Elite, and Boss headers as chips in a grid.
- Elite and boss chips show a marker and no spawn percentage.
- Enter Zone and the Dungeon button are full-width buttons at the bottom of the panel.
- The Dungeon button is present but disabled with a requirement label when the dungeon
  is locked, and absent only when the zone has no dungeon at all.
- Tapping the Dungeon button opens the info popup with name, tier, room count, boss,
  first clear XP, and the room type mix.
- Enter Lobby opens a lobby reusing the boss lobby overlay and party slots.
- Empty party slots render a tappable INVITE affordance.
- A solo host is ready by default and can start alone.
- The start control reads ENTER DUNGEON in a dungeon lobby.
- Runtime sets no colours, cell sizes, spacing, or padding on any element in this spec.

---

*Path: docs/combat-menu-hub-spec.md*
*Four stages. Nine new baked templates, four existing reused. Amends*
*combat-navigation-flow-spec.md section 5. Stage 4 carries the only scope risk.*
