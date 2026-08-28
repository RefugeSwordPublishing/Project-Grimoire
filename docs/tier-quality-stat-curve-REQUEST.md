---
type: design-request
for: Chat (claude.ai design collaborator)
from: Claude Code
date: 2026-08-28
subject: Tier should raise a gear piece's STAT bonus, not just its physical band (bug #54)
read-first: docs/implementation-status.md
---

# Request: tier-vs-quality stat curve

## The bug that triggered this

Tester #54: "Ash staff is weaker than the upgraded pine staff (one upgrade). Makes unlocking it
disappointing." A Pine staff (Tier 1) upgraded one quality step out-performs a fresh Ash staff
(Tier 2), so climbing to a new material tier feels like a downgrade.

I root-caused it in the code. It is not a data typo; it is a systemic gap in how tier and quality
contribute to a gear piece.

## How gear stats work today (as-built, `EquipmentStats.cs`)

A weapon or armour piece contributes two things:

1. A **physical value** (weapon damage band, or armour rating). This gets BOTH a quality base AND a
   flat tier bonus.
2. A **stat bonus** (the piece's favoured primary + secondary stat, e.g. a staff gives INT + WIL).
   This gets the **quality base ONLY. There is no tier component at all.**

The exact tables:

```
// Quality bases (index = Crude, Rough, Refined, Pristine, Masterwork, Legendary)
BonusPrimary    = { 2, 5, 9, 14, 20, 35 }   // favoured stat per piece — QUALITY ONLY
BonusSecondary  = { 1, 3, 6, 10, 15, 25 }   // second stat per piece   — QUALITY ONLY
WeaponDmgMin    = { 4, 8, 14, 22, 32, 45 }
WeaponDmgMax    = { 8, 14, 22, 32, 45, 60 }

// Flat TIER bonus (index = materialTier 1..5; T1 = 0)
TierWeaponBonus   = { -, 0, 20, 45, 80, 125 }   // added to the weapon damage band
TierPlateBonus    = { -, 0,  8, 18, 32,  50 }   // added to armour rating (Plate)
TierLeatherBonus  = { -, 0,  5, 12, 22,  35 }
TierVestmentBonus = { -, 0,  3,  8, 14,  22 }
// There is NO TierPrimaryBonus / TierSecondaryBonus. The stat bonus never sees tier.
```

So for a staff:
- Ash (T2) Crude damage band = 24-28 vs Pine (T1) Rough band = 8-14. Ash wins on the physical band.
- Ash (T2) Crude **INT** = 2 vs Pine (T1) Rough **INT** = 5. Pine wins on INT.

An Arcanist's damage rides on INT (spellcasting), not the physical weapon band, so the player felt
the INT drop and read Ash as weaker. The same gap hits every class through its primary stat, and it
hits armour too (armour rating is tier-scaled, but the DEX/INT/VIT/etc. bonus from armour is quality
only). Right now, quality is the only lever that moves the stat that actually drives most builds, so
upgrading a low tier beats climbing to a new one.

## What we want you to design

A **tier component for the stat bonus** so that climbing a material tier is always a real upgrade,
without making quality upgrades pointless (they are separate axes and BOTH must matter, per our
Quality-vs-Tier design rule).

Deliverables:

1. **`TierPrimaryBonus` and `TierSecondaryBonus` tables** (indexed by materialTier 1..5, T1 = 0),
   in the same flat-integer style as the tables above. These get added on top of the quality base,
   exactly like `TierWeaponBonus` adds to the damage band.
2. **State the intended relationship** in one line: "one material tier ≈ N quality upgrades of stat."
   That is the core knob. My instinct is a tier should be worth roughly 1.5-2 quality steps of the
   primary stat, so a fresh Tier-N piece clearly beats a Tier-(N-1) piece upgraded once and roughly
   ties one upgraded twice. Tell us if you would tune it differently and why.
3. **A worked check** on the exact bug: show Ash (T2) Crude INT vs Pine (T1) at Rough, Refined, and
   Pristine under your numbers, confirming base Ash beats a one-upgrade Pine.
4. **Reconcile it against the whole curve.** Confirm your stat-tier values sit sensibly next to the
   existing physical tier bonuses (weapon band, armour rating), so a tier jump feels consistent
   across both the physical value and the stat. Flag anything in the current physical tier bonuses
   you think is off while you are in here.
5. Note any knock-on effects worth watching (e.g. total stat inflation at Tier 5 Masterwork, whether
   the secondary stat should scale slower than the primary, whether armour and weapons want the same
   tier-stat table or different ones).

## Constraints

- **Quality and Tier are separate axes and both must stay meaningful.** The fix adds a tier lever to
  the stat; it must not flatten the quality lever. A max-quality low-tier piece and a low-quality
  high-tier piece should each have a reason to exist.
- Keep the numbers as flat integer tables (no new enums, no formulas the code can't express as a
  lookup). Match the existing `EquipmentStats` table style so I can drop them in.
- Do not touch the physical band / armour rating tier bonuses unless you are deliberately proposing a
  change and say so (point 4).
- No Legendary-tier authored content (the index exists for the future; base game stops at Masterwork
  quality and Tier 5).
- Writing style: no em dashes, en dashes, or "--" as prose punctuation; no emojis (these end up in
  code comments and commits).

Hand it back as a short spec I can implement directly into `EquipmentStats.cs` (two new tables + the
two lines in `EquipmentManager` that add them alongside the existing `PrimaryBonus`/`SecondaryBonus`).
