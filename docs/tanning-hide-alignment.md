# Tanning & Hide Material Alignment

**Status:** Proposed (design sign-off needed before implementation)
**Bug:** #1c8db6e3 (critical) — "Wolf hide tanning requires lvl 40, but wolves are the only beast whose hide I have."
**Reconciles to:** `material-economy.md` (CANONICAL) — leather chain is Trapping → Tanning → Tailoring.
**Author:** Claude Code · **Date:** 2026-08-22

---

## TL;DR

Per the canonical material economy, pelts come from the **Trapping** talent, not from combat
kills. The Tanning → Tailoring recipe/armor ladder is correctly designed and needs no change. Two
real defects break it: (1) the **Trapping talent is missing Wolf Pelt entirely** and mis-levels
Direwolf Hide, and (2) beasts drop **off-design stray pelts/hides** — including the Wolf Pelt that
confused the reporter, plus five items that don't even exist as assets. Fix Trapping to match the
ladder, and strip the stray pelt drops from combat.

---

## The intended chain (canonical, `material-economy.md`)

Leather is a **three-talent** chain: **Trapping** (gather pelt) → **Tanning** (pelt → leather) →
**Tailoring** (leather → armor). Beasts are **not** the pelt source; Trapping is.

| Tier | Trap for pelt | → Tan (lvl) → leather | → Tailor (lvl) → armor |
|------|---------------|------------------------|-------------------------|
| 1 | Rabbit Pelt   | Tan 1  → Rabbit Hide      | Tailor 1  → Rabbit-Hide set |
| 2 | Fox Fur       | Tan 20 → Fox Leather     | Tailor 21 → Fox Leather set |
| 3 | Wolf Pelt     | Tan 40 → Wolf Leather    | Tailor 42 → Wolfhide set |
| 4 | Direwolf Hide | Tan 65 → Direwolf Leather| Tailor 65 → Direwolf set |
| 5 | Drake Scale (drops direct as Drake Leather; no tanning) | — | Tailor 88 → Drake Scale set |

Tanning and Tailoring already match perfectly (1/20/40/65 ↔ 1/21/42/65). **Do not touch them.**

## Defect 1 — the Trapping talent doesn't feed the ladder

As-built Trapping activities:

| Trapping activity | Level | Output | Ladder need |
|-------------------|-------|--------|-------------|
| Rabbit Snare   | 1  | Rabbit Pelt    | ✓ feeds Tan 1 |
| Fox Trap       | 15 | Fox Fur        | ✓ feeds Tan 20 (close enough) |
| **(missing)**  | —  | **Wolf Pelt**  | ✗ **no source** — yet Tan 40 / Wolfhide need it |
| Direwolf Bait  | 35 | Direwolf Hide  | ✗ trappable at 35 but not tannable until Tan 65 |
| Shadow Cat Lure / Trap Shadow Pelt | 45 / 65 | Shadow Pelt | Alchemy, not leather — leave alone |

So the T3 rung (Wolf) has **no pelt source anywhere**, and Direwolf sits 30 levels below its
tanning gate.

## Defect 2 — beasts drop off-design stray pelts/hides

Pelts should not drop from kills at all. These combat drops contradict the Trapping design, and
five of them reference items that **don't exist as assets** (dead loot):

| Beast (combat lvl) | Stray drop | Item exists? |
|--------------------|-----------|--------------|
| Forest Wolf (1-5)      | Wolf Pelt        | yes — **this is the drop that gave the reporter an unusable pelt** |
| Poacher (5-10)         | Rabbit Hide (finished) | yes — lets players skip Tanning |
| Grimwood Bear (8-12)   | Bear Pelt        | **no** |
| Bog Lurker (20-35)     | Bog Hide         | **no** |
| Mountain Hawk (35-49)  | Beast Hide       | **no** |
| Ironspine Warlord (45-58)| Refined Leather| **no** |
| Highland Wyvern (61-68)| Wyvern Hide      | **no** |

---

## Recommended fix

### Part A — repair the Trapping talent (`Assets/Data/Talents/Trapping.asset`)

Add the missing Wolf rung and align Trapping levels just under their Tanning gates, so you can trap
a pelt around the time you can tan it:

| Trapping activity | Level | Output | Matches |
|-------------------|-------|--------|---------|
| Rabbit Snare   | 1  | Rabbit Pelt    | Tan 1 |
| Fox Trap       | 18 | Fox Fur        | Tan 20 |
| **Wolf Trap (NEW)** | 38 | **Wolf Pelt** | Tan 40 |
| Direwolf Bait  | 60 | Direwolf Hide  | Tan 65 (re-leveled up from 35) |
| Shadow (rare)  | 45/65 | Shadow Pelt | unchanged (alchemy) |

### Part B — strip the stray pelt/hide drops from combat (`Assets/Data/Enemies/`)

Remove the pelt/hide entries below; leave each beast's legitimate drops (meat, bone, claw, fang,
currency). This deletes the confusing Forest Wolf → Wolf Pelt drop **and** clears all five
dead-loot entries in one pass.

- [ ] Forest Wolf: remove `Wolf Pelt` (keeps Bone Fragment)
- [ ] Poacher: remove `Rabbit Hide`
- [ ] Grimwood Bear: remove `Bear Pelt` (keeps Bear Claw)
- [ ] Bog Lurker: remove `Bog Hide`
- [ ] Mountain Hawk: remove `Beast Hide` (keeps Feathers)
- [ ] Ironspine Warlord: remove `Refined Leather`
- [ ] Highland Wyvern: remove `Wyvern Hide` (keeps Drake Scale)

---

## Decisions for sign-off

1. **Should beasts drop any hide at all?** Recommended: **no** — Trapping is the canonical source,
   and mixing the two is what caused this bug. If we want beast kills to feel rewarding for hunters,
   the cleaner lever is a small-chance **Trapping-material** bonus (e.g. Dire Fang, Bear Claw) rather
   than pelts. Flagging in case design wants a deliberate combat-drop alt-path.

2. **Trapping level curve.** Proposed 1 / 18 / 38 / 60. Adjust if Trapping is meant to lead or lag
   the Tanning gates; the only hard requirement is that a pelt is trappable no later than its
   tanning level.

3. **Is Trapping surfaced to new players?** The reporter never mentioned Trapping — they expected to
   tan kill-drops. Worth confirming Trapping is visible/onboarded, since it's now the sole pelt path.
   (Tracked separately from the data fix.)

## Implementation scope

- Edit 1 talent asset (Trapping): add Wolf Trap activity, re-level Direwolf Bait (and Fox Trap).
- Edit 7 enemy assets: remove stray pelt/hide drop entries.
- No changes to Tanning, Tailoring, item assets, or armor. No new items required (Wolf Pelt already
  exists as an asset).
