---
type: design-spec
version: 1.2
updated: 2026-09-05
path: docs/concurrent-idle-progression-spec.md
resolves: Concurrent idle progression, MVP
implements: IdleManager mutual-stop removal, ActiveIdleBar persistence in combat,
            attunement routing, WYWA combined result, WYWA consumables-used list
scope: MVP is one combat session plus one production track. Multi-track is stretch,
       section 8. Offline combat accrual is section 5 and is a separate build slice.
supersedes: offline-combat-wywa.md decision 1 (Option A, summary only)
changelog: v1.2 adds section 5.7, consumables used during the away session surfaced on
           the WYWA screen for restock. v1.1 added offline combat accrual (section 5).
---

# Concurrent Idle Progression
### Version 1.0, MVP

---

## 1. What Actually Changes

The brief calls this "remove the three mutual-stop calls." That is the right size for the code
change, and it is not the whole design, because three things that were previously guaranteed
exclusive now are not.

| Was exclusive | Now concurrent | Needs a decision |
|---|---|---|
| The two coroutines | Both tick | No, they touch different state |
| Inventory writes | Two producers | Yes, section 6.2 |
| The player's tap | Two attunement windows | **Yes, and it is the sharpest one, section 3** |

The attunement collision is the part worth designing carefully. Everything else follows.

---

## 2. State Model

### 2.1 What runs when

| Player state | Combat | Production | Notes |
|---|---|---|---|
| Hub, production running | No | Yes | Today's behaviour |
| In zone or dungeon, no production set | Yes | No | Today's behaviour |
| In zone or dungeon, production running | Yes | Yes | **The new state** |
| Knocked out in combat | Ended | Yes | Production is independent of the player's HP |
| Backgrounded | Flushed and stopped | Continues offline | Section 5 |

Zones and dungeons behave identically. Both are combat, and neither touches the production track.

### 2.2 What still replaces what

**Starting a new production still replaces the running production.** One production track in the
MVP, unchanged. `IdleManager` keeps its single slot.

**Entering combat no longer stops production, and starting production no longer stops combat.**
That is the whole behavioural change.

**Being knocked out does not stop production.** The player's Grimoire went down. The forge did
not.

---

## 3. Attunement

### 3.1 Manual attunement is off during combat

Choosing to fight means giving up the ability to attend the production window. No tap target,
no window rendered, no bonus. The production track runs at its full base rate and nothing else.

This is the right call and it is simpler than the alternatives. Two timed inputs competing for
one thumb on a phone was never going to resolve into a good experience, and every scheme that
tried to keep both reachable either handed out a bonus for nothing or made both inputs
unreliable.

**It is not a throttle.** The locked decision is that the production track runs at full base rate
while combat is active, and it does. Attunement is a bonus above base rate that is earned by
attending the cycle, and a player in a dungeon is not attending the cycle.

### 3.2 Slaying attunement still lands on production, and that is the substitution

When an enemy drops below 20 percent HP, the Slaying attunement fires into the running production
track, as the brief recommends.

Read alongside 3.1 this is not an exception, it is the point. **The attunement channel does not
disappear during combat, it changes.** Outside combat you earn production attunement by attending
the forge. Inside combat you earn it by fighting well. The player who fights attentively while
smelting still gets attuned cycles, they just get them from kills rather than taps.

That framing matters for how it should read in the UI: the bar says attunement is coming from
combat, not that attunement is disabled.

**One attunement per production cycle, from any source.** Without the cap, a player clearing a
low-tier zone at thirty kills a minute would land thirty attunements on a twenty-second smelt
cycle. This is the whole anti-abuse story for attunement and it is small.

### 3.3 No attunement of any kind fires offline

Attunement is an active-play mechanic by definition. Offline production already runs at base rate
with no attunement, and offline combat does not generate attunements into production either.

Without that rule, offline combat would silently boost offline production, and two accruing
tracks would compound. Section 5.

### 3.4 What does not change

The Marksmanship weak point stays in combat and stays Warden-only. It is a combat multiplier
rather than an attunement and nothing about it routes anywhere.

---

## 4. UI: Stop Hiding The Bar You Already Have

### 4.1 Reuse `ActiveIdleBarUI`

The answer to "second idle bar or compact readout" is neither. `ActiveIdleBarUI` already exists,
is already skinned, already shows the talent, the activity, cycle progress, and the attunement
window. It is currently hidden during combat because production stops during combat.

**Keep it rendered during combat.** That is the UI change.

Building a second component would mean maintaining two things that show the same data, and
skinning a compact variant would mean the production readout looks different depending on whether
the player is fighting, which is worse for recognition rather than better.

### 4.2 Screen density

Stacking from the bottom during combat: bottom nav, `ActiveIdleBarUI`, the minimized chat dock
line, then combat content.

Three thin strips is roughly 180px of chrome on a 1080 portrait screen. Acceptable, and the chat
dock already auto-minimizes on entering combat per `chat-dock-panel-spec.md` section 3.4, so only
one line of that stack is chat.

Worth watching rather than pre-solving. If it reads as cramped on device, the lever is the chat
dock rather than the idle bar, because the idle bar is now carrying an active second track and the
chat dock is carrying one truncated line.

### 4.3 States on the bar during combat

| State | Rendering |
|---|---|
| Production running | Normal, cycle progress filling |
| Attunement, in combat | No window. Label reads "Attuning from combat", section 3.2 |
| Attunement, out of combat | Full-width tap window as today |
| Attunement already granted this cycle | Indicator shown, no further grant |
| Out of input materials | Bar shows "Out of materials", progress stops |
| Inventory full | Bar shows "Bags full", progress stops, section 6.2 |
| No production set | Bar shows the empty prompt as it does today |

The bar is tappable to open the full production panel outside combat. **During combat the whole
bar is inert**, because a mis-tap that yanks the player out of a boss fight into the crafting
screen is the worst possible outcome of this feature. With manual attunement off during combat
there is nothing on the bar that needs to be touchable, which is a pleasant simplification.

---

## 5. Offline: Combat Accrues Too

### 5.0 Correcting the brief, and flagging the scope

The brief lists "combat is a foreground, active-only loop, no offline combat accrual" as an
as-built fact and recommends leaving offline unchanged. Dustin's correction is that combat is
meant to accrue while the phone is off, and that auto-eat exists precisely so a player can prep
and set both tracks running overnight.

Taking that as the intent, **offline is not unchanged and my earlier recommendation was wrong.**

**This supersedes `offline-combat-wywa.md`.** That spec chose Option A, summary only, and
explicitly deferred offline kill simulation as Option B. Option B is now the requirement.

**Scope warning, read before scheduling.** The concurrency MVP in sections 1 through 4 is three
removed lines and some label states. Offline combat accrual is not. It needs a kill-rate model, a
damage-taken model, offline auto-eat consumption, a death condition, and a second offline result
surface. It is a real feature and it should be its own build slice rather than riding along with
the three-line change. Sections 1 through 4 ship without it and deliver every loop the brief
describes for a player who is awake.

### 5.1 What both tracks share

| Property | Production | Combat |
|---|---|---|
| Offline cap | 8 hours | 8 hours, same window |
| Rate | Full base rate | Full base rate, times the 0.80 idle multiplier |
| Attunement | None | None, and grants none to production |
| Weak points | N/A | Never rolled offline |
| Natural limiter | Materials on hand | **Food on hand, section 5.3** |
| Consumption applied | On collect | On collect |

### 5.2 The model

Simulate in coarse buckets rather than per swing. One minute per bucket is enough resolution for
an 8 hour window and it keeps the whole computation to at most 480 iterations.

Per bucket, from data the client already has:

```
dps        = idleAttack * 0.80, minus enemy defense mitigation, over weapon interval
timeToKill = enemyHP / dps
cycle      = timeToKill + encounterGap
kills      = 60 / cycle
damageIn   = enemyDamage * hitChance * (60 / enemyCadence), minus player mitigation
```

Accumulate kills, drops, Grimoire XP, and Slaying XP. Subtract `damageIn` from HP. When HP falls
below the auto-eat threshold, consume one draught from inventory and restore. When no draught
remains and HP reaches zero, **combat stops at that bucket** and the remaining offline window is
production only.

Everything in that block already exists as data. Nothing new needs authoring.

### 5.3 Food is the cap, and that symmetry is the design

Production offline is materials-capped. It stops when the ore runs out, not when the clock does.
Combat offline needs the same kind of limiter or it runs the full 8 hours unconditionally, which
is a categorically different thing from every other offline system in the game.

**Food stock is that limiter.** The player's draught inventory determines how long they survive,
which makes both offline tracks consumable-limited rather than time-limited, and which is exactly
the prep loop the correction describes. Setting up an overnight session means stocking ore for
the forge and draughts for the fight.

A player who massively out-gears their zone takes near-zero damage, never eats, and runs the full
window. That is fine. They earned it by out-gearing the content, and the reward for out-gearing
should be that lower content stops costing you anything.

### 5.4 The number worth checking before this ships

A T1 Sharpshot in Crude gear kills a Grimwood Brigand in about 5.8 seconds idle, so roughly 460
kills per hour, or about 3,700 across a full 8 hour window. At 18 Slaying XP per T1 kill that is
roughly 65,000 Slaying XP overnight, plus 3,700 rolls on the drop table.

That is a lot, and it is the intended shape rather than a bug, but it should be a number somebody
looked at on purpose. Food consumption is the brake: the same player takes roughly 1.9 HP per
second and would drink about 180 draughts an hour, so a realistic stock runs out well short of
eight hours and the session ends when the food does.

If the overnight yield still reads as too high once food is modelled, the lever is the encounter
gap or the idle multiplier, not the 8 hour cap, because shortening the cap would break the
overnight promise that motivated the correction.

### 5.5 The background transition

Backgrounding with both running now stops nothing. Combat flushes its foreground tally and hands
off to the offline simulation from that timestamp, production continues as today, and both accrue
against the same 8 hour window.

### 5.6 One result screen, three sections

A player returning from an overnight session has a foreground combat tally from before they
backgrounded, an offline combat result, and an offline production result.

Show one While You Were Away screen with **Combat** and **Production** sections, folding the
foreground tally into the combat section rather than reporting it separately. Two numbers for the
same activity on one screen is confusing, and the player does not care where the boundary fell.

The combat section should name the stop reason when it was not the cap: "You ran out of draughts
after 5h 20m" is the single most useful line the screen can show, because it tells the player
exactly what to stock more of next time.

### 5.7 Consumables used, surfaced for restock

The screen shows what was gained. It must also show what was **spent**, because the single most
useful thing an idle-game away-screen can tell a player is what to restock before the next
session. A player who sees "used 240 Grimwood Ore, 61 Minor Draughts" knows exactly what ran the
session and what to top up. Rewards alone hide the cost and let a track quietly stall next time.

**What counts as a consumable used:**

| Source | Item | Already tracked |
|---|---|---|
| Production inputs | Recipe ingredients spent per cycle | Yes, `IdleSessionResult.itemsConsumed` |
| Combat food | Draughts eaten by offline auto-eat | No, section 5 adds it |
| Combat ammunition, if any | Per the ammo model when built | No, future |

**Rendering.** Each of the two WYWA sections gets a short "Used" line under its "Gained" list:

- **Production section:** list `itemsConsumed` as "Used: 240 Grimwood Ore, 30 Coal". This data is
  already computed today and only needs surfacing, so it ships with the MVP WYWA screen rather
  than waiting for section 5.
- **Combat section:** list draughts consumed by offline auto-eat as "Used: 61 Minor Draught". The
  offline combat simulation in 5.2 already decrements draughts, so it records the count into the
  combat result; the screen renders it. This ships with the section 5 slice.

**Restock cue, not just a receipt.** When a track stopped because it ran out of a consumable, the
Used line names that item as the stop cause, tying it to the stop-reason line in 5.6. "Out of
Grimwood Ore after 3h 10m" on production, "Out of draughts after 5h 20m" on combat. The item that
ended the session is the item the player most needs to see.

**Empty state.** A track that consumed nothing (pure gathering, or a fight where the player never
dropped low enough to eat) shows no Used line rather than "Used: none". Absence reads correctly.

This is display only. Consumption itself is unchanged: production inputs are spent on collect per
section 5.1, and offline auto-eat is spent inside the simulation. The Used line reports numbers
that were already going to be deducted, so it adds no balance surface, only visibility.

---

## 6. Anti-Abuse Audit

The brief expects nothing here. Working through it, three things are worth confirming and one
needs a rule.

### 6.1 No shared resource is double-dipped

| Resource | Combat | Production | Verdict |
|---|---|---|---|
| Talent XP | No | Yes | Separate channels |
| Grimoire and Slaying XP | Yes | No | Separate channels |
| Input materials | Does not consume | Consumes, material-capped | No overlap |
| Currency | Drops | None | No overlap |
| Attunement | Grants to production | Receives | Capped at one per cycle, section 3.3 |
| Quest progress | Track objectives | Delivery objectives | Both progressing at once is intended |

The one that looks like a double-dip and is not: a kill now yields Grimoire XP, Slaying XP, and a
production attunement. Three rewards for one action. But the attunement only exists because the
player set up a production track with their own materials, so it is a reward for managing two
things rather than a reward for one. That is the feature working.

### 6.2 Inventory full needs a rule

Both tracks produce items and the bags are shared. If they fill mid-dungeon, something has to give.

**Production halts, combat continues.** Production stops cleanly with the bar showing "Bags full",
and resumes when space appears. Combat drops follow whatever the existing full-inventory behaviour
is and this spec does not change it.

The reason production yields is that it is the recoverable one. A halted smelt loses nothing but
time and the player can clear space and resume. A combat session interrupted mid-dungeon loses the
run. When two systems collide, the one that can be resumed should be the one that stops.

### 6.3 Consumables produced and consumed at once

A player can cook food while auto-eat consumes food. That is a loop, not an exploit: the food is
still made from inputs and eaten one at a time, and nothing is created. Explicitly fine.

---

## 7. The Progression Consequence, Said Plainly

A player who manages both tracks now earns production talent XP and Grimoire XP at the same time,
each at full rate. **Total XP per hour roughly doubles for a player who sets up production before
every fight.**

That is the accepted trade and the brief locks it. It is worth writing down as a number rather
than a vibe, because the first person to look at a levelling curve after this ships will notice it
and should find the reasoning already recorded rather than treating it as a bug.

Two things soften it in practice. The production track is still material-capped, so it stops when
the ore runs out regardless of how long the player fights. And setting up a production track costs
the player the gathering time that produced its inputs, which is time not spent fighting.

---

## 8. Stretch: Multiple Production Tracks

Not designed here. Two notes so the MVP does not make it harder than it needs to be.

**Do not hardcode "the production track" at the call sites.** The MVP keeps `IdleManager`'s single
slot, but the UI and the attunement router should reach it through an accessor that returns a
collection with one element today:

```csharp
IReadOnlyList<IdleTrack> GetProductionTracks();   // one element in the MVP
```

Then the stretch changes `IdleManager` and the bar's layout, rather than every call site that
touched a singular `CurrentAction`. That costs nothing now and removes most of the refactor later.

**What the stretch actually needs**, for scoping when it comes up: a keyed track collection, N
progress bars in the idle bar region, per-track persistence, per-track offline math against a
shared 8 hour cap, and a decision about whether the Slaying attunement picks a track, splits, or
hits all of them. That last one is a real design question and it is why the stretch is a spec of
its own rather than a follow-up commit.

---

## 9. Build Scope

**Sections 1 through 4 are client only. No Supabase tables, no RPCs, no migration.**

**Section 5 is a separate slice** and is not costed here. It needs the offline simulation loop,
offline auto-eat consumption, a death condition, and the combat section of the WYWA screen. See
5.0.

| Change | Where | Size |
|---|---|---|
| Remove the stop-idle call from `EnterZone` | Combat entry | One line |
| Remove the stop-idle call from `EnterDungeon` | Combat entry | One line |
| Remove the stop-combat call from `StartAction` | `IdleManager` | One line |
| Keep `ActiveIdleBarUI` rendered during combat | UI visibility | Small |
| Suppress the attunement window during combat | `ActiveIdleBarUI` | Small |
| Whole bar inert during combat | `ActiveIdleBarUI` | Small |
| Slaying attunement routes to the production track | Attunement router | Small |
| One attunement per cycle cap | `IdleManager` | Small |
| Bags-full halt state on the bar | `IdleManager` plus UI | Small |
| `GetProductionTracks()` accessor | `IdleManager` | Small, forward compat |
| WYWA renders combat and production sections together | WYWA | Already specced |
| WYWA production "Used" line from `itemsConsumed` | WYWA | Small, MVP, data already exists |
| WYWA combat "Used" draughts line | WYWA | Small, section 5 slice |

**Baked UI work:** label states on `ActiveIdleBarUI` for "Attuning from combat", "Bags full",
and "Out of materials". A "Used" line under each WYWA section's gained list. No new region and no
new prefab.

---

## 10. Acceptance Criteria

- Entering a zone or dungeon does not stop a running production track.
- Starting a production action does not stop an active combat session.
- Starting a new production action still replaces the running one.
- A production track continues at its normal base rate while combat is active, with no reduction.
- Being knocked out in combat does not stop production.
- `ActiveIdleBarUI` remains visible and updating throughout combat.
- During combat the idle bar is entirely inert. No tap on it does anything.
- No production attunement window or tap target renders during combat.
- A Slaying attunement fires into the running production track when an enemy drops below 20
  percent HP.
- No more than one attunement is granted per production cycle regardless of source.
- Offline production is unchanged: one track, 8 hour cap, same rate, materials-capped.
- Offline combat accrues against the same 8 hour window at the 0.80 idle multiplier, rolls no
  weak points, and grants no attunement to production.
- Offline combat consumes draughts through auto-eat and stops when the player is out of food and
  reaches zero HP.
- Returning shows one While You Were Away screen with a Combat section and a Production section,
  with the foreground tally folded into Combat.
- The Combat section names the stop reason when the session ended before the cap.
- The Production section shows a "Used" line listing the input materials consumed during the away
  session, and the Combat section shows a "Used" line listing draughts eaten by offline auto-eat.
- When a track stopped for lack of a consumable, its "Used" line names that item as the stop cause.
- A track that consumed nothing shows no "Used" line at all.
- When the inventory fills, production halts with a visible state and combat continues.
- No new Supabase table, RPC, or migration is created.

---

*Path: docs/concurrent-idle-progression-spec.md*
*MVP is one combat session plus one production track at full rate. Three stop calls removed, the*
*existing idle bar stays on screen, and manual production attunement is suppressed during combat*
*so two timed inputs do not fight for one thumb. Slaying attunement lands on production, capped at*
*one per cycle. The While You Were Away screen reports both what each track gained and what it*
*used, so the player knows what to restock. Offline combat accrual is section 5, a separate slice.*
