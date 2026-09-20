---
type: design-spec
version: 1.0
updated: 2026-09-20
path: docs/zone-expeditions-spec.md
resolves: retention brainstorm, pick 4 of 5
implements: expedition definitions, player_expeditions table, ExpeditionSection on zone detail
companion: bestiary-spec.md (Expert tier interlocks with it)
---

# Zone Expeditions
### Version 1.0

---

## 1. The Model

RuneScape Achievement Diaries, scoped to zones. Each of the ten zones carries three tiers of task
list. Completing a tier grants a permanent benefit scoped to that zone.

**What it buys.** The game currently gives an open-ended player nothing to aim at inside a zone. You
enter, you fight until you feel like stopping, you leave. Expeditions put a shape on that without
gating any content behind it: everything on the list is something the player could already do, listed
in one place with a reason to finish it.

**Why zone-scoped rewards.** A global reward makes every expedition mandatory and turns ten optional
checklists into a hundred-and-twenty-item chore. A reward that only applies in Grimwood Fringe is
worth doing if you like Grimwood Fringe and safely ignorable if you do not.

---

## 2. Structure

Twelve tasks per zone across three tiers. One hundred and twenty total, which sounds enormous and is
not, because they are templated.

| Tier | Tasks | Theme |
|---|---|---|
| Novice | 5 | Things a player does on their first pass through the zone |
| Adept | 4 | Things a player does if they engage with the zone properly |
| Expert | 3 | Things a player does only on purpose |

A tier unlocks when the previous one is complete. Novice is available on first zone entry.

### 2.1 Task templates

Every task is an instance of one of eight templates with zone-specific parameters. That is what makes
a hundred and twenty tasks a data job rather than a writing job.

| Template | Example |
|---|---|
| Defeat N of an enemy | Defeat 50 Forest Wolves |
| Defeat the zone boss | Defeat Aldric the Poacher King |
| Complete the dungeon | Complete Aldric's Warren |
| Complete the dungeon without falling | Complete Aldric's Warren without being downed |
| Gather N of a zone material | Gather 200 Pine Logs |
| Craft a zone-tier item | Craft any Bronze weapon |
| Reach a Talent level | Reach Felling 20 |
| Master a bestiary entry | Master the Forest Wolf entry |

The last one is deliberate and is covered in section 3.3.

### 2.2 Difficulty by tier, not by task count

Novice tasks should complete almost entirely by playing the zone normally. Adept requires deliberate
attention. Expert requires something the player would otherwise never do, which is the whole point of
the tier.

An Expert task that is just a bigger Adept number is a failure. "Gather 200 Pine Logs" at Novice and
"Gather 2,000 Pine Logs" at Expert is a grind wall, not a task. Expert should ask for a different
kind of thing: clear the dungeon without being downed, master a bestiary entry, reach a Talent level
well past what the zone requires.

---

## 3. Rewards

| Tier | Reward, permanent and scoped to that zone |
|---|---|
| Novice | Gathering yield in this zone increased 10 percent |
| Adept | Rare material drop chance in this zone increased 15 percent |
| Expert | A title, and all bestiary thresholds in this zone reduced by half |

### 3.1 Horizontal, not power

None of these makes the player stronger. They make the zone more generous to a player who has proven
they like it. That keeps expeditions out of the balance conversation entirely and means a player who
ignores all ten is not behind.

### 3.2 Why no combat reward

The obvious Expert reward is a combat XP bonus in the zone, and it is a trap. By the time a player
finishes an Expert tier they have outgrown the zone, so a combat XP bonus there is worth nothing. A
reward that is worthless at the moment it is earned is worse than no reward.

Gathering and drop rate survive outgrowing the zone, because materials from low tiers stay relevant
to crafting forever.

### 3.3 The bestiary interlock is the interesting reward

Halving bestiary thresholds in a zone turns Expert into meta-progression: finishing the expedition
makes the collection easier. Two optional systems feeding each other gives a completionist a reason
to alternate between them rather than exhausting one and leaving.

It also means an Expert task can ask for a mastered bestiary entry without that being circular,
because the reward accelerates the *other* entries, not the one that was required.

---

## 4. Where It Lives

**A section on the zone detail panel**, alongside the bestiary section from the previous spec. Same
reasoning as everywhere else in this series: the player is already looking at the zone.

```
EXPEDITION
  Novice                              Complete
  Adept                                    2/4
    Defeat the zone boss                      x
    Complete Aldric's Warren                  x
    Gather 200 Pine Logs                      -
    Reach Felling 20                          -
  Expert                                  Locked
```

Collapsed to the current tier by default. Completed tiers collapse to a single line. Locked tiers
show their name and nothing else.

**Same visibility discipline as the Almanac and the bestiary.** Counts inside this section are fine.
No nav badge, no dot, no count on the zone tile in the combat hub.

---

## 5. Data

```sql
create table player_expeditions (
  player_id     uuid not null references auth.users on delete cascade,
  zone_id       text not null,
  task_id       text not null,
  progress      int  not null default 0,
  completed_at  timestamptz,
  primary key (player_id, zone_id, task_id)
);
create index player_expeditions_player_idx on player_expeditions (player_id, zone_id);
```

Own-row RLS.

**Progress tracking reuses the quest event rails.** Every one of the eight templates maps onto an
objective type the quest system already counts: kills, dungeon completion, gather balance, craft
events, talent level, and bestiary state. Nothing new needs instrumenting.

Tier completion is derived, not stored. A tier is complete when every task under it has a
`completed_at`.

---

## 6. Authoring

One hundred and twenty task definitions as ScriptableObjects, twelve per zone. Each is a template id,
a parameter, and a display string.

**The display string is the only writing.** "Defeat 50 Forest Wolves" is generated from the template
and parameters, but a hand-written line reads better and costs a minute per task. Worth doing, and
worth keeping short.

**Do not write flavour text per task.** Twelve lines of prose per zone times ten zones is a hundred
and twenty pieces of writing nobody will read twice, and it makes the section unscannable. The task
is the text.

---

## 7. Baked Regions

**`ExpeditionSection`**, on the zone detail panel
```
Header           (Text)      "EXPEDITION"
TierContainer    (Transform) parent for ExpeditionTierRow clones
```

**`ExpeditionTierRow`**
```
Title            (Text)      "Adept"
Right            (Text)      "2/4" or "Complete" or "Locked"
TaskContainer    (Transform) parent for ExpeditionTaskRow clones, collapsed when not current
Expander         (Button)
```

**`ExpeditionTaskRow`**
```
Title            (Text)
Done             (GameObject)  toggled
Progress         (Text)        "142/200", blank for binary tasks
```

Three templates, two of which are rows.

---

## 8. Acceptance Criteria

- All ten zones have twelve tasks across three tiers.
- Every task is an instance of one of the eight templates in section 2.1.
- No Expert task is a Novice or Adept task with a larger number.
- Tiers unlock in order. Novice is available on first zone entry.
- Tier completion is derived from task state, not stored separately.
- Progress tracks through the existing quest event rails with no new instrumentation.
- Rewards are permanent and apply only within their zone.
- No reward increases combat power.
- The Expert reward halves bestiary thresholds in that zone.
- The section lives on the zone detail panel, not a new page.
- No nav badge, dot, or count renders outside the opened section.
- Runtime sets no colours, sizes, spacing, or fonts.

---

*Path: docs/zone-expeditions-spec.md*
*Ten zones, twelve templated tasks each, three tiers. Rewards are zone-scoped and horizontal so no*
*expedition is mandatory. Expert halves bestiary thresholds in that zone, which is what makes two*
*optional systems feed each other instead of competing.*
