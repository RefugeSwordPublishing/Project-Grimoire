---
type: design-spec
version: 1.0
updated: 2026-08-22
path: docs/combat-screen-clarity-spec.md
implements: CombatHubUI, CombatTabUI, ZoneCombatUI, AbilityHotbarUI, BuffBarUI,
            CombatXPTrackerUI, MinimizedCombatBar, ResumeCombatPill, CoachMarkManager
reconciled-to: combat-engagement-spec.md v0.2, combat-progression-reconcile.md v1.0,
               combat-xp-curve.md v0.2, combat-balance-reconcile.md v1.0
trigger: Playtest feedback, combat screen reads as unparseable to a new player.
---

# Combat Screen Clarity Spec
### Version 1.0

---

## 1. The Actual Problem

The tester said the screen was overwhelming and that combat looked locked with no
explanation. Those are two separate failures and both need fixing.

**Failure one: no state separation.** Eight combat surfaces exist and several render
at once. A player standing in the Combat Hub can simultaneously see hub tiles, a
hotbar for a fight they are not in, a buff bar with nothing in it, an XP tracker
reading zero, and a resume pill. None of it is wrong, all of it is premature.

**Failure two: locks without arithmetic.** Zone tiles gate on Total Combat Level, but
the tile shows a padlock and the player's Total Combat Level lives on a different
screen. The player cannot subtract two numbers they never see together.

The fix is not less depth. It is three distinct states, each with one job, and a
disclosure rule tied to the level milestones the curve already defines.

---

## 2. Three States, One Job Each

Every combat surface belongs to exactly one state. No surface renders outside its state.

| State | Player intent | Surfaces that render |
|-------|--------------|---------------------|
| A. Combat Hub | "Where do I fight?" | Grimoire header, zone tiles, dungeon tiles |
| B. In Zone | "I am fighting." | Enemy stage, class input, HP, hotbar, buff bar, XP bar |
| C. Elsewhere | "I am doing something else while combat runs." | Minimized bar only |

**Rules:**
- The ability hotbar, buff bar, and XP tracker never render in State A. There is no
  fight to act on, buff, or earn from.
- The Combat Hub never renders behind the zone combat view. Entering a zone is a full
  screen transition, not an overlay.
- The resume pill and the minimized bar are the same component in two sizes. Do not
  ship both. See Section 7.

---

## 3. State A, Combat Hub Layout

This is the screen the tester was looking at. It is the one that has to teach.

```
┌─────────────────────────────────────┐
│ [Status bar, HP + marks, persistent]│
├─────────────────────────────────────┤
│                                     │
│  TIER 1  YOUR GRIMOIRE              │
│  ┌───────────────────────────────┐  │
│  │ [portrait]  SHARPSHOT         │  │
│  │             Combat Level 12   │  │
│  │             ████████░░  1,340 │  │
│  │                    /1,800 XP  │  │
│  │  ─────────────────────────── │  │
│  │  Total Combat Level     12    │  │
│  │  Next zone unlocks at   21    │  │
│  └───────────────────────────────┘  │
│                                     │
│  TIER 2  ZONES                      │
│  ┌───────────────────────────────┐  │
│  │ [art] Grimwood Fringe         │  │
│  │       Tier 1  ·  Open         │  │
│  │                     [ Enter ] │  │
│  ├───────────────────────────────┤  │
│  │ [art] Saltmarsh Shore         │  │
│  │       Tier 1  ·  Open         │  │
│  │                     [ Enter ] │  │
│  ├───────────────────────────────┤  │
│  │ [dim] Ashfen Mire        (lock)│ │
│  │       Tier 2                  │  │
│  │       Needs Total Combat 21   │  │
│  │       You have 12, 9 to go    │  │
│  └───────────────────────────────┘  │
│                                     │
│  DUNGEONS                    [ v ]  │
│  (collapsed by default until the    │
│   player has cleared one zone)      │
│                                     │
├─────────────────────────────────────┤
│ [Bottom nav, persistent]            │
└─────────────────────────────────────┘
```

### 3.1 The Grimoire header is the fix for "everything is locked"

One card, pinned at the top, always visible. It answers three questions in the order
a new player asks them: who am I, how strong am I, what does that number buy me.

Required fields:

| Line | Content | Source |
|------|---------|--------|
| Name | Equipped Grimoire display name | `GrimoireData.displayName` |
| Level | "Combat Level {n}" for the equipped Grimoire | `CombatXPManager.GetGrimoireLevel(equipped)` |
| XP bar | Current XP over XP-to-next for this level | `xpPerLevel[currentLevel]` |
| Total | "Total Combat Level {n}" | `GetTotalCombatLevel()`, sum of owned Grimoires |
| Next gate | "Next zone unlocks at {n}" | Lowest locked zone threshold above current |

When the player owns one Grimoire, Combat Level and Total Combat Level are the same
number. Show both anyway. The moment they own a second Grimoire the distinction
becomes load-bearing, and a player who has watched the two numbers sit together and
then diverge will understand it without being told.

When every zone is unlocked, the next-gate line reads "All zones unlocked."

### 3.2 Locked tiles must show the arithmetic

A padlock alone is the bug. Every locked tile states the requirement, the player's
current value, and the difference.

```
Needs Total Combat 21
You have 12, 9 to go
```

Zone thresholds, per combat-progression-reconcile.md:

| Tier | Total Combat Level required |
|------|----------------------------|
| 1 | 1 |
| 2 | 21 |
| 3 | 51 |
| 4 | 91 |
| 5 | 141 |

Locked tiles stay in the list at reduced opacity. Do not hide them. A player who
cannot see Tier 2 has no reason to want Tier 2.

### 3.3 Dungeons collapse until a zone is cleared

> **AMENDED by combat-navigation-flow-spec.md section 5/12:** the collapsed Dungeons
> section is replaced by inline dungeon sub-rows on the parent zone cards (no standalone
> Dungeons list). The intent below is preserved (a first-session player sees no dungeons);
> only the mechanism changes. The nav-flow spec wins where they conflict.

Dungeons are not idleable and carry more rules than zones. A first-session player
does not need them competing for attention. Render the Dungeons section collapsed
with a count badge ("Dungeons (2)") until the player has completed at least one zone
combat session, then expand by default from that point on.

---

## 4. State B, In-Zone Combat Layout

```
┌─────────────────────────────────────┐
│ [Status bar, persistent]            │
├─────────────────────────────────────┤
│  ← Leave        Grimwood Fringe     │  Tier 1, thin header
│                                     │
│         [ ENEMY, mid-ground ]       │
│         Forest Wolf                 │
│         ████████████░░░  HP         │
│                                     │
│         [ zone backdrop ]           │
│                                     │
│      [ player, over-shoulder ]      │
│                                     │
├─────────────────────────────────────┤
│  Buff bar, only if a buff is active │  TIER 3, conditional
├─────────────────────────────────────┤
│  ███████░░░ Sharpshot Lv 12  [i]    │  TIER 3, thin, tap to expand
├─────────────────────────────────────┤
│                                     │
│     [ CLASS INPUT, bottom 40% ]     │  TIER 1
│     bowstring / constellation /     │
│     combo triangle                  │
│                                     │
├─────────────────────────────────────┤
│  [ hotbar, unlocked slots only ]    │  TIER 2
└─────────────────────────────────────┘
```

### 4.1 Priority order

**Tier 1, always visible, largest:** the enemy, the enemy HP bar, the player HP in the
persistent status bar, and the class input surface. These are the fight. A player who
sees only these can play correctly.

**Tier 2, visible but subordinate:** the ability hotbar, rendering only unlocked slots.

**Tier 3, conditional or collapsed:** the buff bar renders only when at least one buff
is active. The XP tracker renders as a single thin progress bar with the Grimoire name
and level, and expands to a breakdown on tap.

### 4.2 The hotbar shows only what exists

Empty slots read as broken. The curve unlocks inputs gradually, so the hotbar should
grow with the player rather than sit mostly empty for the first week.

| Grimoire level | Hotbar slots rendered |
|---------------|----------------------|
| 1 to 7 | Hotbar hidden entirely, class input is the only action |
| 8 | 1 slot, Guard |
| 15 | 2 slots, first 2-input combo added |
| 31 | 3 slots, Surge added |
| 35 and up | Full row, 3-input combos available |

At level 1 to 7 the class input surface is the entire interaction. That is correct and
it is the least confusing possible first session.

### 4.3 The XP tracker collapses to one line

Default state is a thin bar across the width: fill, Grimoire name, current level, and
a small info affordance. Tapping expands a panel showing the breakdown.

Expanded panel contents:
- XP this session
- XP per kill at this zone tier
- Attunement bonus multiplier when active (×1.5)
- XP to next level

Collapsed is the default on every entry to a zone. Expansion does not persist between
sessions. A player who wants the detail can get it in one tap, and a player who does
not will never see it.

### 4.4 Aggro is hidden until it means something

Aggro has no visible representation for Warden or Arcanist at low level and is pure
noise on a first session. Render the aggro indicator only when both are true:

- The equipped Grimoire is Vanguard path, or the player has unlocked Guard at level 8
- The player is in a dungeon, or fighting an elite or boss

In every other case aggro is computed but not displayed.

---

## 5. Per-Element Tooltip Copy

One line each, plain language, no mechanics jargon. Every element gets a small info
affordance that opens these on tap. Copy is final, use verbatim.

| Element | Tooltip copy |
|---------|-------------|
| Combat Level | Your Grimoire gets stronger as it fights. Higher levels unlock new attacks. |
| Total Combat Level | Every Grimoire you own adds its level to this total. Zones unlock based on it. |
| Zone gate (locked tile) | This zone needs a higher Total Combat Level. Keep fighting anywhere to raise it. |
| Ability hotbar | Your unlocked attacks. New slots appear as your Grimoire levels up. |
| Buff bar | Temporary boosts from food, potions, and guild upgrades. |
| XP tracker | Progress toward your next Combat Level. Every point of damage earns XP. |
| Aggro | How much attention enemies are paying to you. Higher means they attack you first. |
| Class input (Warden) | Hold to draw, release to fire. A fuller draw hits harder. |
| Class input (Arcanist) | Trace the rune shape to cast. Different shapes call different spells. |
| Class input (Vanguard) | Chain Strike, Guard, and Surge to build combos. |
| Idle indicator | Your Grimoire keeps fighting while you are away. Playing actively earns more. |
| Minimized combat bar | Combat is still running. Tap to go back to the fight. |

Two rules for whoever edits these later. Say what the thing does for the player, not
what it is. Never name a formula.

---

## 6. First-Visit Coach Marks

Fires once, on the player's first entry to the Combat Hub. Complements the hub guide,
does not repeat it. Six steps, one per element, dismissible at any point, never shown
again once completed or skipped.

Store completion as `PlayerPrefs.SetInt("coach_combat_complete", 1)` and mirror to the
player record so it survives reinstall.

### Sequence

**Step 1, Combat Hub, points at the Grimoire header**
> This is your Grimoire. It levels up by fighting, and it fights for you even when
> the app is closed.

**Step 2, Combat Hub, points at the Total Combat Level line**
> Your Total Combat Level decides which zones you can enter. Right now it is the same
> as your Grimoire level.

**Step 3, Combat Hub, points at the first locked zone tile**
> Locked zones tell you exactly what they need. Fight anywhere to close the gap.

**Step 4, Combat Hub, points at an unlocked zone tile**
> Start here. Tap Enter and your Grimoire begins fighting straight away.

Steps 5 and 6 fire on first zone entry, not in the hub.

**Step 5, In Zone, points at the class input**
> This is how you fight. Playing actively deals more damage and earns more XP than
> idling does.

**Step 6, In Zone, points at the XP bar**
> Every point of damage earns XP. Tap this bar any time to see the details.

### Behavior

- One mark on screen at a time, with a dimmed backdrop and a cutout over the target.
- Next advances, Skip ends the whole sequence.
- Steps 5 and 6 fire on the first zone entry even if the player skipped steps 1 to 4,
  unless they explicitly skipped. Skip means skip everything.
- No mark points at an element that is currently hidden by the disclosure rules in
  Section 4. If the hotbar is not rendered, there is no hotbar coach mark. It appears
  the first time the hotbar itself appears, at level 8, as a single one-off mark:

> **Level 8 unlock mark:** You unlocked Guard. It lives here, on your hotbar.

Repeat this pattern for level 15, 31, and 35. One mark, at the moment the thing
becomes real. This is how the player learns depth without meeting it on day one.

---

## 7. Collapse and Hide Defaults

| Element | Default | Expands or appears when |
|---------|---------|------------------------|
| Grimoire header | Expanded, always | Never collapses |
| Zone tiles | Expanded, always | Never collapses |
| Dungeon sub-row on zone card (amended, was "Dungeon section") | Hidden | Player completes one zone session |
| Ability hotbar | Hidden | Grimoire reaches level 8 |
| Buff bar | Hidden | At least one buff is active |
| XP tracker | Collapsed to one line | On tap, per session |
| Aggro indicator | Hidden | Vanguard path, or dungeon, or elite/boss fight |
| Slaying section (Combat Tab) | Collapsed | Player reaches Slaying level 5 |
| Per-Grimoire level list (Combat Tab) | Expanded | Never collapses |

Nothing in this table is removed. Every collapsed element is one tap from open, and
every hidden element appears the moment it has meaning.

---

## 8. Resolve the Minimized Bar and Resume Pill

Two components do the same job today. Ship one.

**Keep:** a single minimized combat bar, pinned above the bottom nav, rendering in
State C only.

```
┌─────────────────────────────────────┐
│ ⚔ Grimwood Fringe   14 kills   [→]  │
└─────────────────────────────────────┘
```

Contents: zone name, kills this session, tap target to return to the fight.

**Retire:** the resume-combat pill. Delete the component and its call sites. If a
distinct visual treatment is wanted for a paused versus running session, make that a
state on the minimized bar, not a second component.

---

## 9. Combat Tab Under Character, Unchanged Behavior

The Combat Tab already exists and is correct. It is the detail view, not the hub. It
keeps per-Grimoire levels and the Slaying section as specced in
combat-progression-reconcile.md and slaying-content-spec.md. No layout change here.

Add one thing: a link at the bottom of the Grimoire header in the Combat Hub reading
"See all Grimoires" that deep-links to the Combat Tab. That gives the hub a single
clean exit to depth instead of duplicating the list.

---

## 10. Acceptance Criteria

- A first-time player entering the Combat Hub sees their Grimoire name, Combat Level,
  Total Combat Level, and the next zone threshold without scrolling or tapping.
- Every locked zone tile displays the required Total Combat Level, the player's
  current value, and the difference between them.
- The ability hotbar, buff bar, and XP tracker do not render anywhere in the Combat Hub.
- A player below Grimoire level 8 never sees an ability hotbar.
- The buff bar renders only while at least one buff is active.
- The XP tracker opens collapsed on every zone entry and expands on tap.
- The aggro indicator is hidden for a Warden or Arcanist fighting a standard enemy
  outside a dungeon.
- The coach-mark sequence fires once, covers six steps across two screens, and never
  points at a hidden element.
- Milestone coach marks fire once each at Grimoire levels 8, 15, 31, and 35.
- Only one minimized combat component exists in the codebase. The resume pill is deleted.
- Every element listed in Section 5 has an info affordance returning the exact copy given.

---

## 11. Out of Scope

Not part of this pass, do not build:

- Any change to combat math, damage, or the XP curve
- Dungeon-specific UI beyond the collapsed hub section
- Raid UI, still Phase 4 deferred
- Tutorial combat encounter or scripted first fight
- Any change to the Character sheet or talent panel

---

*Path: docs/combat-screen-clarity-spec.md*
*Covers: three-state separation, Combat Hub hierarchy, in-zone disclosure tiers,*
*tooltip copy for eleven elements, six-step coach-mark sequence plus four milestone*
*marks, collapse defaults, and retirement of the duplicate resume pill.*
