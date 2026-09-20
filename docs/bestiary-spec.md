---
type: design-spec
version: 1.0
updated: 2026-09-20
path: docs/bestiary-spec.md
resolves: retention brainstorm, pick 2 of 5
implements: player_bestiary table, BestiarySection on the zone detail panel, kill tracking
companion: almanac-unlock-visibility-spec.md (same visibility discipline applies)
---

# The Bestiary
### Version 1.0

---

## 1. What It Is For

Three jobs, in order of value.

**A reason to return to low zones.** Tier 1 currently has none. A Tier 5 player has no cause to ever
see Grimwood Fringe again, which means 80 percent of the authored content becomes dead weight the
moment it is outgrown.

**A finite visible collection.** The OSRS collection log grants almost nothing mechanically and is
one of the most effective retention features that game has ever shipped. People chase things that
are countable and end.

**A home for lore already written.** The enemy content briefs contain a great deal of writing that
no player will ever read, because nothing in the game surfaces it.

---

## 2. Structure

One entry per enemy. Roughly 80 entries: 10 zones times 4 standard, 2 elite, and 1 boss, plus
dungeon bosses.

Each entry has three thresholds. Crossing one reveals something.

| Threshold | Standard | Elite | Boss | Reveals |
|---|---|---|---|---|
| Observed | 10 kills | 3 | 1 | Stats: HP, damage band, defense, cadence |
| Studied | 50 kills | 10 | 3 | Full drop table with rates |
| Mastered | 150 kills | 30 | 10 | Lore entry, and +2 percent damage against this enemy |

**Elite and boss thresholds are much lower because they spawn rarely.** A boss at 1-in-20 encounter
rate would need thousands of zone entries to reach 150, which is not a collection, it is a wall.

### 2.1 Why the drop table is the best reward on the ladder

Studied is the tier players will care about most, and it is not the damage bonus.

The crafting economy constantly poses the question "where do I get Wolf Pelts." Right now the answer
lives in a wiki nobody has written. Revealing the drop table after 50 kills turns the bestiary into
the game's own answer to that question, earned through play rather than looked up.

It is also universally useful, unlike a weak-point reveal, which would only help Warden since
Arcanist and Vanguard have `weakPointEnabled = false`.

### 2.2 The damage bonus is deliberately small

Two percent per entry, roughly 80 entries, and it only applies against that one enemy. A player who
masters everything is not meaningfully stronger; they are thorough. The bonus exists so Mastered
lands as an achievement rather than a text unlock, not as a power axis.

### 2.3 Most entries complete without trying

A player progressing normally kills several hundred of each common enemy in a tier. Observed and
Studied arrive passively and feel like the game noticing what they did.

Only elites, bosses, and the enemies of zones they rushed through need deliberate effort. That is the
correct shape: the collection rewards attention, it does not demand grinding.

---

## 3. Where It Lives

**A section on the existing zone detail panel**, under the grouped enemy list that already renders
there. Not a new page.

The enemy chips on that panel already show name, spawn rate, and elite or boss markers. The bestiary
adds a small progress indicator to each chip and makes the chip tappable to open that enemy's entry.

This follows the Almanac discipline exactly. The player is already looking at a list of that zone's
enemies when the question "which of these have I recorded" is live. Putting it anywhere else makes
it a chore list.

### 3.1 The entry

```
FOREST WOLF
Grimwood Fringe  ·  Beast  ·  Standard
-------------------------------------------
Recorded                          73 / 150
-------------------------------------------
OBSERVED
  HP 50      Damage 4 to 9
  Defense 12    Attacks every 2.2s
-------------------------------------------
STUDIED
  Wolf Pelt                            55%
  Wolf Fang                            30%
  Silver Mark                       2 to 6
-------------------------------------------
MASTERED                          at 150
  Locked
```

Unreached tiers show their threshold and the word Locked. Nothing is hidden, which is the same
horizon logic the Almanac uses: knowing what is coming is the point.

---

## 4. Visibility Discipline

Inherited wholesale from the Almanac spec, because a collection feature is the single most likely
thing in this game to become a nag.

**No nav badge. No dot. No count outside an opened surface.** Counts on the bestiary page and on
zone enemy chips are fine, because the player opened those. A count anywhere that renders
unprompted is forbidden.

**No completion percentage on the hub, the character sheet, or the guild roster.**

**The WYWA tail may mention the bestiary**, per the Almanac's two-line rule, and only under its
suppression rules. "Grimwood Fringe has 3 creatures you have not recorded" is a fact. Anything
phrased as a task is not.

---

## 5. Zone Completion

Mastering every entry in a zone grants a title and nothing else mechanical. Titles already exist
through Slaying Faction Mastery, so this reuses that system rather than inventing a reward type.

**No global completion reward.** Eighty entries mastered is a long road and putting a prize at the
end turns the whole feature into a checklist with a deadline feeling. The zone titles are enough.

---

## 6. Data

```sql
create table player_bestiary (
  player_id   uuid not null references auth.users on delete cascade,
  enemy_id    text not null,
  kills       int  not null default 0,
  first_seen  timestamptz not null default now(),
  primary key (player_id, enemy_id)
);
create index player_bestiary_player_idx on player_bestiary (player_id);
```

Own-row RLS, same as every other player table.

**Kill increments batch rather than writing per kill.** A player clearing a zone kills several enemies
a minute, and the existing combat flush already runs about once a second. Fold the bestiary increment
into that flush as a small dictionary of enemy id to count, the same way the combat tally already
accumulates.

Thresholds are computed client-side from `kills` against the enemy's role. Nothing is stored about
which tier is unlocked, because it is derivable and a stored flag would be a second source of truth.

---

## 7. Baked Regions

**`BestiaryEntryPanel`**
```
Title            (Text)
Subtitle         (Text)     "Grimwood Fringe  ·  Beast  ·  Standard"
ProgressLabel    (Text)     "73 / 150"
ProgressFill     (Image)
ObservedSection  (GameObject)
  StatContainer  (Transform)  parent for BestiaryStatRow clones
StudiedSection   (GameObject)
  DropContainer  (Transform)  parent for BestiaryDropRow clones
MasteredSection  (GameObject)
  LoreText       (Text)
  BonusLabel     (Text)
LockedLabel      (Text)     shown per section when the threshold is unmet
CloseButton      (Button)
```

**`BestiaryStatRow`** and **`BestiaryDropRow`** are both `Title` plus `Right`. Reuse one row prefab
for both if the layouts match.

**Zone enemy chip** gains one child: `RecordProgress (Text)`, reading "73/150" or a check when
mastered.

Three templates, two of which are rows.

---

## 8. Acceptance Criteria

- Every enemy in the game has a bestiary entry, including dungeon bosses.
- Kill counts increment through the existing combat flush, not per kill.
- Observed, Studied, and Mastered thresholds differ by enemy role per section 2.
- Unreached tiers display their threshold rather than hiding their existence.
- The Studied tier reveals the full drop table with rates.
- The Mastered bonus is 2 percent damage against that enemy only.
- Entries are reachable only from the zone detail panel's enemy chips.
- No nav badge, dot, or count renders outside an opened bestiary surface.
- No global completion percentage appears anywhere.
- Mastering a zone grants a title and no other mechanical reward.
- Runtime sets no colours, sizes, spacing, or fonts.

---

*Path: docs/bestiary-spec.md*
*Roughly 80 entries, three thresholds each, scaled by enemy role. Drop-table reveal at Studied is the*
*reward players will actually chase. Lives on the zone detail panel, not a new page. Same no-badge*
*discipline as the Almanac.*
