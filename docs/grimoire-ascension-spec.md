---
type: design-spec
version: 1.0
updated: 2026-09-20
path: docs/grimoire-ascension-spec.md
resolves: retention brainstorm, pick 5 of 5
implements: player_grimoire_levels ascension columns, Ascend flow, TCL floor rule
depends-on: enemy-affixes-spec.md shipping first, see section 1.2
---

# Grimoire Ascension
### Version 1.0

---

## 1. Scope And Sequencing

### 1.1 Full rebirth is wrong for this game

The idle-game default is reset everything for a permanent multiplier. Grimoire cannot do that. It has
a player-driven Exchange, guilds with banked contributions, fifteen Talents, and real gear investment.
Wiping those would be miserable and would gut marketplace participation, which is one of the few
systems that genuinely needs a population.

**So the reset is scoped to one Grimoire's combat level and nothing else.** Talents, gear, currency,
inventory, guild standing, bestiary, and expeditions are all untouched.

### 1.2 Build this after affixes

Ascension asks a player to climb 1 to 100 again. If that climb plays identically the second time, the
feature is a reward for repetition and players will feel it by the second ascension.

Affixes are what make the climb worth repeating, because a Tier 3 fight at rank 2 is a different
fight than a Tier 3 fight was at rank 0 with different affixes rolled. Ship affixes first or this
lands flat.

---

## 2. The Loop

At Grimoire level 100, that Grimoire may **Ascend**.

- It returns to level 1.
- Its Ascension rank increases by 1, to a cap of 10.
- Ability ring unlocks relock with the level, section 4.
- The player keeps every permanent stat milestone they already banked.

Each rank grants, permanently:

- **+8 percent XP** on that Grimoire, compounding the next climb.
- **+1 to that path's primary stat**, cross-Grimoire, exactly like the existing milestone bonuses.
- A visible rank mark on the character sheet and the guild roster.

| Rank | XP bonus | Climb time vs the first | Banked primary |
|---|---|---|---|
| 0 | none | 100 percent | none |
| 2 | +16 percent | 86 percent | +2 |
| 5 | +40 percent | 71 percent | +5 |
| 8 | +64 percent | 61 percent | +8 |
| 10 | +80 percent | 56 percent | +10 |

Reaching rank 10 on one Grimoire costs about 7.6 full climbs of accumulated time, and the tenth climb
runs at just over half the speed of the first. That is the shape an idle prestige loop needs: the
later climbs are visibly faster, which is the feeling the whole system exists to produce.

### 2.1 Why +1 primary stat per rank is the right size

The existing milestone ladder grants roughly +5 primary across an entire 1 to 100 climb. Ten
ascension ranks grant +10, for roughly eight times the time investment.

Deliberately unrewarding per hour. Ascension should be what a player does because they have run out
of other things to chase, not the efficient way to get stronger. The efficient path stays leveling a
second Grimoire, which is section 3.

---

## 3. Total Combat Level, The Real Design Question

This is the fork, and getting it wrong kills the feature.

**Total Combat Level floors at the Grimoire's peak.**

```
TCL = SUM over owned Grimoires of max(currentLevel, peakLevel)
```

Ascending never reduces Total Combat Level, so it never locks a player out of a zone they had
reached. The cost of ascending is the re-climb, not lost access.

**Why the alternative fails.** If TCL dropped on ascension, a Tier 5 player ascending one Grimoire
would fall back through zone gates into content they finished months ago, with gear far past it. They
would not do it, and the feature would ship dead. Any prestige system that takes away access rather
than power is a system nobody presses.

### 3.1 The consequence, which is good

Because the second climb adds nothing to TCL, ascension and breadth become genuinely different axes.

- **Leveling a second Grimoire** raises TCL, which unlocks zones. That is the efficient route to
  content.
- **Ascending one Grimoire** raises permanent stats and that Grimoire's climb speed. That is the
  route for a player who has already unlocked everything.

A player who has reached Tier 5 and has nowhere left to gate into is exactly the player with nothing
to do today. Ascension is aimed at them and does not distort anyone else's progression.

---

## 4. Ability Rings Relock, And That Is The Cost

Ability rings unlock by Grimoire level. On ascension they relock with everything else.

**This is deliberate.** Without it, ascension has no cost beyond time and becomes a button that is
always correct to press, which is not a decision. With it, ascending means choosing to be temporarily
weaker on that Grimoire for a permanent gain, which is what prestige is supposed to feel like.

### 4.1 And this is why it makes multiple Grimoires matter more, not less

A player with one Grimoire who ascends is weak until they re-climb. A player with three can ascend
one and play a different one while it rebuilds.

So breadth and depth reinforce each other rather than competing. Owning several Grimoires is what
makes ascension comfortable, and ascension is what gives a maxed player a use for the Grimoires they
already own. That interlock is the best thing about this design and it comes free from the relock
rule.

---

## 5. The Ascend Flow

Available only at level 100, from the Grimoire Book.

```
ASCEND SHARPSHOT
-------------------------------------------
Sharpshot returns to level 1.
Ability rings relock until you climb again.
-------------------------------------------
You gain, permanently
  Ascension rank                    1 to 2
  Sharpshot XP rate            +8%  to +16%
  DEX                            +1  to +2
-------------------------------------------
You keep
  Total Combat Level, gear, Talents,
  currency, and every banked milestone.
-------------------------------------------
This cannot be undone.
-------------------------------------------
[         ASCEND         ]
[         Cancel         ]
```

**Name what is lost before what is gained.** A confirmation that leads with rewards is selling; one
that leads with the cost is informing. The relock is the surprising part and it belongs at the top.

**No typed confirmation.** The modal is clear, the action is available only after a hundred levels of
play, and making people type a word to confirm is theatre that implies the design does not trust its
own explanation.

### 5.1 Milestone rewards

| Rank | Reward |
|---|---|
| 3 | Grimoire Book cover variant |
| 5 | Cosmetic Grimoire skin |
| 10 | Title, and the rank mark changes treatment |

Cosmetic only. Ascension already grants stats; putting mechanical rewards on the rank milestones as
well would make it the efficient path, which section 2.1 explicitly avoids.

---

## 6. Data

```sql
alter table player_grimoire_levels add column ascension_rank int not null default 0;
alter table player_grimoire_levels add column peak_level     int not null default 0;
```

`peak_level` maintains the TCL floor and updates whenever `level` exceeds it. Two columns on an
existing table, no new table.

**Ascension must be server-side.** It writes a permanent stat bonus and resets a level, which is
exactly the class of operation the currency rails already protect. An `ascend_grimoire` RPC that
validates level 100, increments rank, resets level, and returns the new state.

Client-authoritative ascension would be the single most exploitable action in the game.

---

## 7. Acceptance Criteria

- Ascend is available only at Grimoire level 100.
- Ascending resets that Grimoire to level 1 and increments its rank, capped at 10.
- Total Combat Level does not decrease on ascension, under any circumstances.
- `peak_level` updates whenever `level` exceeds it and never decreases.
- Ability rings relock with the level and re-unlock on the same schedule.
- Banked stat milestones from previous climbs are never lost.
- Each rank grants +8 percent XP on that Grimoire and +1 to the path's primary stat.
- Talents, gear, currency, inventory, guild standing, bestiary, and expeditions are untouched.
- The confirmation modal names the relock before it names the rewards.
- Ascension resolves through a server RPC and is never client-authoritative.
- Rank milestone rewards are cosmetic only.
- Enemy affixes have shipped before this reaches players, per section 1.2.

---

*Path: docs/grimoire-ascension-spec.md*
*One Grimoire resets, nothing else does. TCL floors at peak so ascending never costs access. Ability*
*rings relock, which is the real cost and which makes owning several Grimoires the thing that makes*
*ascension comfortable. Ten ranks, +8 percent XP and +1 primary each, about 7.6 climbs to cap.*
