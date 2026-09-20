---
type: design-spec
version: 1.0
updated: 2026-09-20
path: docs/almanac-unlock-visibility-spec.md
resolves: retention brainstorm, pick 1 of 5
implements: UnlockLadderSection on existing pages, WYWA Next Up lines
scope: surfacing existing data. No new systems, no new nav entry, no new persistent UI.
---

# The Almanac
### Version 1.0, unlock visibility

---

## 1. There Is No Almanac Screen

The feature name is a convenience. **What ships is a section pattern added to pages that already
exist**, plus two lines appended to the While You Were Away summary.

That is the whole architecture and it is deliberate. A new top-level page needs a nav entry, a nav
entry acquires a badge, a badge acquires a count, and a count turns a reference into a chore list.
Building no screen removes the failure mode at the root rather than disciplining it later.

Precedent already exists in the codebase: the Grimoire Book's "The Unwritten" page shows the rune
unlock schedule on the page a player opened to read about their Grimoire. This is that idea applied
to the other fourteen places it belongs.

---

## 2. The Four Rules

Every decision below follows from these. If a future change violates one, it is the change that is
wrong.

**Pull, not push.** Ladders live on the page for the thing they describe. A player reading the
Smelting page already wanted to know about Smelting. The only push channel in this entire feature is
the WYWA tail, section 5.

**Descriptive, not imperative.** "Steel Bar unlocks at Smelting 30" is a fact about the world.
"2 recipes remaining" is an instruction with an implied failure. Nothing in the Almanac tells the
player to do anything.

**Horizon, not map.** Three unlocks ahead plus one teaser. The full ladder is one tap away and never
the default. Seeing the whole mountain is what creates the overwhelm.

**No clocks, no dots, no counts outside the surface.** A count inside a list the player opened is
describing that list and is fine. A count on a nav entry, a hub tile, or anything that renders
without being opened is forbidden. This single rule does more work than any amount of trimming.

---

## 3. Where The Ladder Goes

| Page | Ladder content | Data source |
|---|---|---|
| Each of the 15 Talent pages | Next recipe and tool unlocks by level | Recipe unlock levels on the Talent assets |
| Slaying page | Next ladder unlocks (spawn bonus, Hunted Variants, Finishing Blow, task slots) | Slaying Lv1-100 ladder |
| Grimoire Book | Next milestone and ability ring unlocks for the equipped Grimoire | Milestone table, ring unlock levels |
| Combat Hub | Unchanged. Locked zone tiles already show the requirement. | `ZoneAccess` |

Four surfaces, and one of them needs no work. The Combat Hub already does the right thing and adding
anything to it would be the first step toward a home-screen strip.

**No ladder for:** the Assembly bench (quality is not level-gated), the Exchange, the Royal Merchant,
guilds, or quests. Quests are already imperative by nature and correctly so; mixing a reference
surface into a task surface is how the tone collapses.

---

## 4. The Section

```
UNLOCKS AHEAD
  Steel Bar                       Smelting 30
  Steel Fitting                   Smelting 34
  Mithril Bar                     Smelting 65
  ---------------------------------------------
  Show all 22
```

Three rows, then a teaser row, then an expander.

**Rows 1 to 3** are the next three unlocks above the player's current level, in level order, with the
unlock name and its level. Nothing else. No inputs, no description, no icon.

**The teaser** is the next meaningful jump beyond those three, usually the next material tier. It is
named but not detailed, so it reads as a horizon marker rather than a puzzle. A player at Smelting 12
sees Mithril Bar exists at 65 and learns the shape of the ladder without being shown 22 rows.

**The expander** opens the full list in place. This is explicit pull and the only place a count
appears, because the count is describing the list the player is choosing to open.

**When the ladder is exhausted**, the section reads "Nothing further to unlock here" and stops. Not
"Complete", which invites a completion badge somewhere else.

### 4.1 Copy rules

Present tense, third person, no second person. "Steel Bar unlocks at Smelting 30", never "You unlock
Steel Bar at 30" and certainly never "Only 4 levels to go".

Unlock names are the recipe or feature name as already authored. **The only new authoring is a
one-line description for feature unlocks that are not self-describing**, such as the Slaying ladder
entries. Recipe unlocks need nothing; "Steel Bar" says what it is.

---

## 5. The WYWA Tail, The Only Push

Two lines appended to the end of the While You Were Away summary, below the existing results.

```
  ---------------------------------------------
  Your Smelting is 2 levels from Steel Bars.
  Grimwood Fringe has 3 creatures you have not recorded.
```

This lands at the one moment a returning player is already reading and already deciding what to do
next. It costs no persistent UI, competes with nothing on screen, and is gone when the screen is
dismissed.

### 5.1 Selection

Pick at most two, from different systems, choosing the nearest by estimated effort rather than by
raw level gap. Never two lines about the same talent.

### 5.2 Suppression, which matters more than selection

**Show nothing if the nearest unlock is far.** "Your Smelting is 14 levels from Mithril Bars" is
discouraging, not motivating. The threshold should be roughly what a session or two of that activity
covers.

**Show nothing on a session where the player collected nothing.** A WYWA screen that opens with an
empty result and closes with a suggestion reads as nagging.

**Never more than two lines, and no line if only weak candidates exist.** One good line beats two
where the second is filler. Zero is an acceptable and frequent outcome.

### 5.3 Tone

Same rules as section 4.1, and one more: the WYWA lines state a fact about the player's world, never
a suggestion about their time. "Your Smelting is 2 levels from Steel Bars" is a fact. "Smelt some ore
to reach Steel Bars" is a chore.

---

## 6. Baked Regions

Four templates, three of which are rows. Runtime populates and toggles only.

**`UnlockLadderSection`**, dropped into the four host pages
```
Header          (Text)        "UNLOCKS AHEAD"
RowContainer    (Transform)   parent for UnlockRow clones
TeaserRow       (GameObject)  toggled
ExpanderButton  (Button)
ExpanderLabel   (Text)        "Show all 22"
EmptyLabel      (GameObject)  "Nothing further to unlock here"
```

**`UnlockRow`**
```
Title           (Text)        unlock name
Right           (Text)        "Smelting 30"
Teaser          (GameObject)  toggled, dims the row for the horizon marker
```

**`WYWANextUpRow`**, appended to the existing WYWA result list
```
Body            (Text)        one full sentence
```

No new prefab for the expanded state; the expander instantiates more `UnlockRow` clones into the
same container.

---

## 7. What This Does Not Get

Stated explicitly so nobody adds them in a later pass believing they were an oversight.

No nav entry. No badge or dot anywhere. No count outside an opened surface. No progress bar toward
the next unlock. No notification, push or local. No daily reset. No streak. No completion percentage.
No "recommended next action". No sorting by anything other than level.

If any of these appears, the feature has become the thing it was designed to avoid.

---

## 8. Acceptance Criteria

- No new top-level page and no new nav entry exists.
- The unlock section appears on all 15 Talent pages, the Slaying page, and the Grimoire Book.
- The Combat Hub is unchanged.
- Each section shows exactly three rows plus one teaser by default.
- The full ladder is reachable in one tap and is never the default state.
- No count, badge, dot, or timer renders anywhere outside an opened section.
- All copy is third person present tense and contains no instruction to the player.
- The WYWA tail shows at most two lines, from different systems.
- The WYWA tail shows nothing when the nearest unlock is beyond a session or two of effort.
- The WYWA tail shows nothing on a session that collected nothing.
- A ladder with no remaining unlocks reads "Nothing further to unlock here" and adds no badge.
- Runtime sets no colours, sizes, spacing, or fonts.

### 8.1 The review test, which is not automatable

**Close the section. Does it feel fine?** If closing it leaves a sense of something undone, the
feature has drifted, and the cause will be a count, a clock, or a dot. Find it and remove it.

Worth running this by hand once on device before shipping, because it is the only criterion that
actually measures the thing the feature is for.

---

*Path: docs/almanac-unlock-visibility-spec.md*
*No screen, no nav entry, no badges. A section pattern on 17 existing pages plus at most two*
*sentences on the WYWA tail. Three unlocks and a teaser by default, full ladder one tap away.*
*The only new authoring is a one-line description for feature unlocks that are not self-describing.*
