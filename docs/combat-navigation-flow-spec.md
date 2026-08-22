---
type: design-spec
version: 1.0
updated: 2026-08-22
path: docs/combat-navigation-flow-spec.md
implements: CombatHubUI (section menu removal), ZoneTileUI, DungeonRowUI,
            RaidPlaceholderCard, CombatBreadcrumbHeader, EncounterResultUI,
            NavigationDrawerUI (Slayer entry removal)
companion: combat-screen-clarity-spec.md v1.0 (governs what a screen shows,
           this file governs how the player moves between them)
reconciled-to: combat-engagement-spec.md v0.2, combat-progression-reconcile.md v1.0,
               implementation-status.md
amends: combat-screen-clarity-spec.md sections 3.3 and 7, see section 12 below
trigger: Playtest feedback, the path from the Combat nav to an actual fight is unclear.
---

# Combat Navigation Flow Spec
### Version 1.0

---

## 1. The Change in One Line

Delete the section menu. Combat nav opens the encounter list directly.

The as-built flow is Combat nav → section menu (Slayer, Zone Combat, Dungeons, Raids)
→ tile list → fight. That is three levels of menu guarding a game whose core loop is
"tap a zone, your Grimoire starts fighting." The section menu adds a decision before
the player knows what any of the options mean, and it presents four flat choices where
one is the answer for the first several hours, one is not built, and one is not an
encounter at all.

The clarity spec already assumes the section menu is gone. Its Combat Hub layout shows
zone tiles immediately under the Grimoire header, with no intervening choice. This spec
makes that explicit and resolves where the other three options go.

| As-built | This spec |
|----------|-----------|
| Zone Combat, one of four menu options | The hub body itself, no menu entry |
| Dungeons, one of four menu options | Inline sub-row on the parent zone card |
| Raids, one of four menu options | Single non-interactive card at the list foot |
| Slayer, one of four menu options | Removed from the encounter path, lives on Combat Tab |

---

## 2. Screen Map

Three screens total. There is no fourth level anywhere in this flow.

```
BOTTOM NAV
    │
    └── Combat ─────────────→ COMBAT HUB  (State A)
                                   │
                                   │  Grimoire header
                                   │  Continue row (conditional)
                                   │  Zone cards, tier order
                                   │    └─ dungeon sub-row (conditional)
                                   │  Raids placeholder card
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
              [Enter] on zone            [Enter] on dungeon
                    │                             │
                    ▼                             ▼
              IN ZONE (State B)            IN DUNGEON (State B)
              infinite session             finite run
                    │                             │
                    │ Leave                       │ run completes
                    ▼                             ▼
              Session summary              Run result screen
                    │                             │
                    └──────────────┬──────────────┘
                                   ▼
                              COMBAT HUB
```

State C from the clarity spec is not a screen. It is the minimized bar rendering over
whatever else the player navigated to.

---

## 3. Depth Budget

| Scenario | Taps to an active encounter |
|----------|----------------------------|
| First-time player, cold start | 2 (Combat nav, then Enter) |
| Returning player, no session running | 2 (Combat nav, then Enter on Continue row) |
| Returning player, session already running | 1 (minimized bar) |
| Player entering a dungeon | 2 (Combat nav, then Enter on the dungeon sub-row) |

Two taps is the ceiling for every encounter type. If a change to this flow pushes any
path to three, the change is wrong.

The as-built cold-start path is four taps (Combat nav, Zone Combat, tile, Enter). This
spec removes two of them: the section menu, and the tile-then-Enter split. The zone
card carries its own Enter button, so selecting and entering are one action.

---

## 4. Ordering and Hierarchy

### 4.1 Vertical order in the hub

```
1. Grimoire header            always
2. Continue row               only if a last-played zone exists and no session is running
3. Zone cards, tier ascending always
4. Raids placeholder card     always
```

### 4.2 Zone cards stay in strict tier order

Ascending by tier, then alphabetical within a tier. Do not sort unlocked zones to the
top. The list is a ladder and it should read as one from top to bottom, with the
player able to see exactly where they currently stand on it and what is above them.

Sorting unlocked content to the top destroys that reading and makes the locked tiles
feel like a junk drawer at the bottom rather than the next rungs.

### 4.3 The Continue row solves the returning player

A returning player should not have to hunt down the ladder for the zone they were in
twenty minutes ago. Directly under the Grimoire header, when a last-played zone exists
and no session is currently running:

```
┌───────────────────────────────────┐
│ Continue                          │
│ Grimwood Fringe  ·  Tier 1        │
│                        [ Enter ]  │
└───────────────────────────────────┘
```

Hidden entirely for a brand-new player, and hidden while a session is running because
the minimized bar already covers that case. One purpose per element.

### 4.4 Which encounter type is primary

Zone combat, without qualification. It is the only idleable encounter type, it is the
only one available at Total Combat Level 1, and it is the sole source of the XP that
unlocks everything else. It gets the body of the screen and it needs no label calling
it out as the default, because it is the only thing there when the player arrives.

Dungeons and raids do not compete for first attention because on a first session
neither of them renders as an actionable option. See sections 5 and 7.

---

## 5. Zones and Dungeons Are Parent and Child

`ZoneData.hasDungeon` already models the relationship. The navigation should show it
rather than flattening it into a separate list.

A dungeon is not a peer of its zone. It is the harder thing inside that zone. Putting
Aldric's Warren in a separate Dungeons list severs it from Grimwood Fringe and forces
the player to hold the pairing in their head. Putting it on the Grimwood Fringe card
teaches the pairing for free.

### 5.1 Zone card with dungeon sub-row

```
┌─────────────────────────────────────┐
│ [art]  Grimwood Fringe              │
│        Tier 1  ·  Open              │
│                          [ Enter ]  │
│  ·································  │
│  Dungeon  Aldric's Warren           │
│  Needs Combat Level 8    (locked)   │
└─────────────────────────────────────┘
```

The sub-row is visually subordinate: indented, smaller type, a dotted rule separating
it from the zone action. It reads as a property of the zone, not a sibling of it.

### 5.2 Sub-row visibility rules

| Condition | Sub-row state |
|-----------|--------------|
| Player has never completed a zone session | Hidden entirely |
| Zone has no dungeon (`hasDungeon == false`) | Hidden entirely |
| Player has completed a session, dungeon locked | Visible, dimmed, shows requirement |
| Dungeon unlocked | Visible, active, own Enter button |

The first rule preserves the intent of clarity spec section 3.3: a first-session player
sees zones and nothing else. The mechanism differs (inline suppression rather than a
collapsed section) and that is a deliberate amendment, recorded in section 12.

### 5.3 No standalone Dungeons list

Do not build one. Every dungeon in the game belongs to exactly one zone and is
reachable from that zone's card. A separate list would be a second path to the same
destination, which is how the original section menu became confusing in the first place.

---

## 6. Slayer Leaves the Encounter Path

Slaying is a mastery track. It has levels, unlocks, faction kill counters, and titles.
It is not a place you go to fight, and putting it in a menu of fight destinations
mislabels it for every player who taps it expecting an encounter.

**Remove** the Slayer entry from the combat section menu, along with the menu itself.

**Keep** the Slaying page exactly where slaying-content-spec.md and
combat-progression-reconcile.md already put it: the Combat Tab under Character, below
the per-Grimoire level list.

**Reach it** through the link the clarity spec already added to the Grimoire header,
"See all Grimoires", which deep-links to the Combat Tab. Slaying is visible on that
page. One entry point, no duplication.

The one exception worth allowing later: when Slayer Hunts ship at Slaying 40, a Hunt
is genuinely an encounter modifier and an active Hunt could surface as a banner on the
Combat Hub. That is a Slaying-spec concern, not a navigation concern, and it does not
require a menu entry.

---

## 7. Raids Placeholder

Raids are Phase 4 deferred and on the do-not-build list. The failure mode to avoid is
a player tapping Raids, getting nothing, and concluding the game is broken. The second
failure mode is a padlock, which implies "grind to unlock this" and sets a target that
does not exist.

Neither. Use a distinct treatment that reads as unbuilt rather than ungrant.

```
┌─────────────────────────────────────┐
│  RAIDS                              │
│  Large group encounters.            │
│  Coming in a future update.         │
└─────────────────────────────────────┘
```

Rules:
- Renders at the foot of the zone list, always, from the first session.
- Muted surface, no artwork, no padlock icon, no progress arithmetic, no Enter button.
- Not tappable. No tooltip, no modal, no toast. There is nothing further to say.
- No "Total Combat Level required" line. That number does not exist yet and inventing
  one now commits the design to a threshold before the content is scoped.

Its presence is the entire point: it tells a new player the shape of the game without
promising a date or a number.

---

## 8. Back, Wayfinding, and Post-Encounter Landing

### 8.1 Header, not breadcrumbs

Portrait mobile has no room for a breadcrumb trail, and the hierarchy is only two deep,
so a trail would be ceremony. Use a contextual header in State B:

```
←   Grimwood Fringe  ·  Tier 1                          [ Leave ]
```

The back chevron and the Leave button do different things. This distinction is the
most important behavioral rule in this spec.

### 8.2 Back versus Leave

| Action | Combat session | Destination |
|--------|---------------|-------------|
| Back chevron | Keeps running | Combat Hub, minimized bar visible |
| Android hardware back | Keeps running | Combat Hub, minimized bar visible |
| Bottom nav to another section | Keeps running | That section, minimized bar visible |
| Leave button | Ends, summary shown | Combat Hub |

Navigation is not a decision to stop fighting. In an idle-first game, a player who taps
back to check their inventory has not asked to end their session, and ending it for
them is punishing. Only the explicitly labelled Leave button stops combat.

This means the minimized bar can appear over the Combat Hub itself. That is correct and
intended: the player is looking at the list of places to fight while still fighting
somewhere. The bar is their way back.

### 8.3 Where the player lands after an encounter

Zones and dungeons end differently, so they land differently.

**Zone, infinite.** A zone session has no natural end. Tapping Leave shows a session
summary as a sheet over the hub, listing kills, XP earned, and items gained. Dismissing
the sheet leaves the player on the Combat Hub, scrolled to the zone they just left,
with that card briefly highlighted so they can find their place.

**Dungeon, finite.** A dungeon run ends when the boss dies or the party wipes. Show a
full result screen, not a sheet, since the run was a discrete accomplishment.

```
┌─────────────────────────────────────┐
│         ALDRIC'S WARREN             │
│            CLEARED                  │
│                                     │
│  Rooms cleared           4          │
│  Combat XP           1,240          │
│  First clear bonus     500          │
│                                     │
│  Items gained                       │
│  [ ... ]                            │
│                                     │
│        [ Run Again ]                │
│        [ Back to Hub ]              │
└─────────────────────────────────────┘
```

Run Again re-enters the same dungeon directly, keeping the repeat loop at one tap.
Back to Hub returns to the Combat Hub scrolled to the parent zone card.

On a wipe, the same screen reads "DEFEATED" with the rooms cleared and any XP earned
before the wipe. Run Again still appears. Do not punish a loss by making the player
navigate back through the ladder to try again.

### 8.4 Scroll restoration

The Combat Hub restores its scroll position whenever the player returns to it from
State B, for the duration of the app session. A player who was looking at Tier 3
should not be dumped back at the top of the ladder every time they leave a fight.

---

## 9. Reconciliation With the Three-State Model

| Clarity spec state | This spec's screens | Notes |
|-------------------|--------------------|-------|
| A, Combat Hub | Combat Hub | Now the direct target of the Combat nav, no menu before it |
| B, In Zone | In Zone and In Dungeon | Both are State B, they differ only in how they end |
| C, Elsewhere | Not a screen | Minimized bar over any other section, including the hub |

No new state is introduced. The dungeon run is State B with a finite terminator.

---

## 10. Copy Strings

Use verbatim.

| Location | Copy |
|----------|------|
| Continue row label | Continue |
| Zone card, unlocked status | Tier {n}  ·  Open |
| Zone card, locked status | Needs Total Combat {n} |
| Zone card, locked delta | You have {current}, {diff} to go |
| Dungeon sub-row label | Dungeon |
| Dungeon sub-row, locked | Needs Combat Level {n} |
| Raids card title | RAIDS |
| Raids card body line 1 | Large group encounters. |
| Raids card body line 2 | Coming in a future update. |
| Leave button | Leave |
| Zone summary sheet title | Session Summary |
| Dungeon result, win | CLEARED |
| Dungeon result, loss | DEFEATED |
| Dungeon result, primary action | Run Again |
| Dungeon result, secondary action | Back to Hub |

---

## 11. Acceptance Criteria

- Tapping Combat in the bottom nav opens the encounter list directly. No section menu
  exists anywhere in the codebase.
- A first-time player reaches an active fight in two taps from the bottom nav.
- Zone cards render in ascending tier order and are never re-sorted by unlock state.
- The Continue row appears only when a last-played zone exists and no session is running.
- A player who has never completed a zone session sees no dungeon sub-rows anywhere.
- No standalone Dungeons list screen exists. Every dungeon is reachable only from its
  parent zone card.
- The Raids card is present from the first session, is not tappable, shows no padlock,
  and states no level requirement.
- The Slayer entry is removed from the combat navigation. Slaying remains reachable via
  the Combat Tab under Character.
- Tapping the back chevron or hardware back from a zone returns to the Combat Hub with
  combat still running and the minimized bar visible.
- Tapping Leave ends the session, shows the summary sheet, and returns to the hub.
- Completing a dungeon shows a full result screen with a working Run Again that
  re-enters the same dungeon in one tap.
- A dungeon wipe shows the same result screen with Run Again still available.
- Combat Hub scroll position is restored when returning from any encounter.

---

## 12. Amendments to combat-screen-clarity-spec.md

Two sections of the clarity spec are superseded by this file. Where they conflict,
this file wins.

**Section 3.3, "Dungeons collapse until a zone is cleared."** The collapsed Dungeons
section with a count badge is replaced by inline dungeon sub-rows on the parent zone
cards, per section 5 above. The intent is preserved exactly: a first-session player
sees no dungeons. The mechanism changes from a collapsed section to inline suppression.

Rationale for the change: a separate Dungeons section, collapsed or not, is one more
top-level thing on a screen this spec is trying to simplify, and it hides the
zone-to-dungeon relationship that `ZoneData.hasDungeon` already encodes. Attaching the
dungeon to its zone removes a section and teaches the pairing at the same time.

**Section 7, collapse defaults table, "Dungeon section" row.** Replace that row with:

| Element | Default | Expands or appears when |
|---------|---------|------------------------|
| Dungeon sub-row on zone card | Hidden | Player completes one zone session |

Everything else in the clarity spec stands unchanged.

---

## 13. Out of Scope

Do not build as part of this pass:

- Any change to the in-fight screen layout, that is the clarity spec's scope
- Any change to combat math, the XP curve, or zone gate thresholds
- Raid functionality of any kind, the placeholder card is the entire raid deliverable
- Changes to the Slaying page itself, only its entry point changes
- Dungeon room puzzles, still on the do-not-build list
- A zone search or filter control, the ladder is short enough to scroll

---

*Path: docs/combat-navigation-flow-spec.md*
*Covers: section menu removal, three-screen map, two-tap depth budget, tier-order*
*rules, zone-to-dungeon parent-child model, Slayer relocation, raid placeholder*
*treatment, back versus Leave semantics, and post-encounter landing per type.*
