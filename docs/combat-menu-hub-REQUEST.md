---
type: design-request
for: Chat (claude.ai design collaborator)
from: Claude Code
date: 2026-08-28
subject: Redesign the combat menu to feel like a hub, add a grouped enemy view, a dungeon info popup, and a single-player dungeon lobby with invites
read-first: docs/implementation-status.md, then combat-navigation-flow-spec.md and combat-screen-clarity-spec.md
---

# Request: combat-menu hub redesign + dungeon lobby

## Where we are

Tapping Combat opens a baked overlay (`SectionHubBaked`) that covers the hub. It shows a Grimoire
header (name, combat level, XP bar), a Total Combat Level line, and a single scrolling **encounter
list**. In that list: an optional Continue row, then zone cards in tier order, then a Raids
placeholder. Tapping an unlocked zone card now **expands** it in place (View / Hide) to reveal the
zone's enemies as sub-rows (name + spawn %, elites/boss tagged), an "Enter Zone" row, and, if the
zone has one, a "Dungeon" sub-row that enters the dungeon directly.

The developer's reaction after seeing it on device: **"it feels like a deeper menu instead of a
hub."** The expanded view reads like a spreadsheet of rows. That is the problem to solve.

### What is already built and reusable

- **Skinnable card templates** (baked by `Bake Combat Hub`): `CombatCardTemplate` (full rows) and
  `CombatSubRowTemplate` (subordinate rows). Runtime clones them and fills DATA ONLY (child objects
  named `Title` / `Right` / `Subtitle` / `Locked`). Any new row type should reuse or extend these so
  it stays editor-skinnable. Runtime never imposes colour or size.
- **Zone data** (`ZoneData`): `zoneName`, `tier`, `description`, `enemies[]` (each `EnemyData` has
  `enemyName`, `spawnWeight`, `isBoss`, `isElite`), `zoneBoss`, `hasDungeon`, `dungeon` (a
  `DungeonData`), `dungeonName`. So the enemy roster + spawn percentages are already computable, and
  a dungeon's data is on hand.
- **`DungeonData`**: `dungeonName`, `zoneId`, and rooms (`entranceRoom`, `safeRoom`, `bossRoom`,
  `roomPool[]` of `RoomData` with a `RoomType` of Standard/Elite/Safe/Boss/Puzzle/Treasure/Trap).
- **The boss lobby** (`PreBossLobbyUI` + `BossLobbyManager`): a working pre-fight lobby used for zone
  bosses, co-op and solo. It has party slots (host + up to 2 guests), per-slot Ready flags, a START
  FIGHT control (solo host can always start), a Leave, and party chat. Solo routes through it and is
  ready-by-default. Invites are via the party/chat channel bound to the lobby. **The dungeon lobby
  should reuse this pattern and its manager as much as possible.**

## The hard UI rule

All UI is authored/skinned in the Unity EDITOR via bakers: an editor tool builds skinnable
templates/elements into the scene, and runtime is populate-only (clone a template, set data). So
every screen in your design must be expressible as baked, skinnable elements the developer styles in
the editor. Do not design anything that can only be built/skinned at runtime. Reuse the existing
`CombatCardTemplate` / `CombatSubRowTemplate` where possible; call out any NEW baked template or popup
you introduce so a baker can build it.

## What to design

### 1. Hub feel, not a deep menu

The combat menu should read as a hub, not a long scrolling list of rows. Propose how the top level
presents the zones so it feels like a place, not a menu: for example zone tiles/cards with art, a
clear tier grouping, the Grimoire/Total-Combat header as a banner rather than a list item. Keep it
mobile portrait (the reference device is a Samsung Galaxy S10e). You do not need pixel measurements,
but give a concrete layout: what sits where, how a zone is chosen, and how the player gets from the
hub to a specific zone's detail without it feeling like drilling through menus.

### 2. Zone detail / expanded view

When the player opens a zone, show its detail. The developer's asks:
- **Enemies shown as a GROUP, not a spreadsheet of rows.** Design a compact grouped presentation
  (e.g. a wrapped set of small enemy chips/portraits with the spawn % and an elite/boss marker, or a
  tight two-column block) that reads at a glance and does not look like a data table. If you keep
  rows, make them tight enough that they stop reading as a spreadsheet.
- **Enter Zone as a distinct button at the BOTTOM** of the zone detail (not a row in the list).
- **A Dungeon button directly BELOW the Enter Zone button**, carrying the dungeon icon. Only shown
  when the zone has a dungeon.
- The whole detail needs its own colour treatment (the current expanded view is uncoloured); specify
  the intent (a distinct panel look) so the developer can skin it, but the exact palette is theirs.

### 3. Dungeon info popup

Tapping the Dungeon button opens a **dungeon info popup** (a baked, skinnable modal, like the boss
lobby overlay). It shows the dungeon's information (name, and whatever of: room count, room-type mix,
difficulty/tier, expected rewards, boss) that reads as "here is what you are walking into", and two
actions: **Enter Lobby** and **Cancel**. Specify what info is worth showing from `DungeonData` and how
the popup is laid out.

### 4. Single-player dungeon lobby (reuse the boss lobby) + invites

Enter Lobby opens a **dungeon lobby** that behaves like the single-player boss lobby: a pre-run
lobby with party slots, a solo host who is ready by default, a Start (Enter Dungeon) control, and a
Leave. **Invites can be sent from this lobby screen** so a solo run can become co-op. Design this to
reuse `PreBossLobbyUI` / `BossLobbyManager` (the boss lobby infra) rather than a parallel system:
say clearly what is shared, what a dungeon lobby needs that the boss lobby does not (it starts a
dungeon run, not a boss fight), and how invites are surfaced on the lobby screen (a visible Invite
control that opens the friend/party invite, rather than only the chat channel). If the boss lobby
needs a small generalization to serve both, describe it.

## Constraints

- Everything must be **baked/skinnable** (editor-authored templates + a baker; populate-only runtime).
  Reuse `CombatCardTemplate` / `CombatSubRowTemplate` and the boss-lobby infra where you can.
- **Mobile portrait, touch.** One-handed reach matters for the primary actions (Enter, Dungeon).
- **Reuse over rebuild.** The enemy roster math, the zone/dungeon data, and the boss lobby all exist.
  Flag anything genuinely new (a new baked template, a new manager method) so it can be scoped.
- Do not design raids (Raids stays a placeholder).
- Writing style: no em dashes, en dashes, or "--" as prose punctuation; no emojis (this becomes UI
  copy and code comments).

## Deliverable

A spec I can implement in stages, with:
- The hub layout (top level) and how a zone is opened.
- The zone detail structure: the grouped enemy presentation, the Enter Zone button, the Dungeon
  button, and the panel's colour intent.
- The dungeon info popup: contents + layout + the Enter Lobby / Cancel actions.
- The dungeon lobby: what it reuses from the boss lobby, what it adds, and how invites appear.
- A **baker/asset checklist**: which existing templates are reused, which NEW baked templates/popups
  the developer must have a baker build, and the child element names the runtime will fill.

Point out anything in the current flow you think is wrong beyond what is listed here.
