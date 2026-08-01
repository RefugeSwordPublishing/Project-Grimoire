# Slaying, Extra Content, REQUEST for Chat

**Status:** design ask. Dustin wants Slaying to be more than a passive spawn-rate stat, ideally its own
progression track with exclusive content, before or shortly after release. Chat specs what Slaying
offers; Code then builds it and wires the Slaying Mastery page to a proper home.

---

## Where Slaying stands (as-built)

- Slaying is a global talent (same for every Grimoire), leveled by kills, elites (~5x), dungeon
  completion, and quest/task completion (`slaying-talent-spec.md`).
- In code, the ONLY implemented effect is the passive **elite spawn-rate bonus**
  (`SlayingTalent.GetEliteSpawnBonus`: 0 below Lv20, up to +20% at Lv100), folded into
  `CombatManager.EliteChance`.
- A **Slaying Mastery page** (`SlayingPanelUI`) is built (level + XP, elite-spawn bonus + next
  threshold, the level-unlock list from the spec). It is currently NOT reachable, waiting on this design
  to decide its home (a nav entry, a combat sub-page, etc.).
- `slaying-talent-spec.md` already lists intended unlocks (Lv10 Finishing Blow, spawn-bonus tiers, Lv25
  4th task slot) but most are not built.

## The ask, what does Slaying OFFER?

Dustin's direction: Slaying should feel like a reason to hunt, not just a number that ticks up. Some
directions he floated, pick/expand:

1. **Slayer zones / hunts:** special zones or timed hunts unlocked by Slaying level, with tougher
   enemies and better rewards. What gates them, what do they drop, how do they differ from normal zones?
2. **Monster varieties with higher drop chance:** rare "hunted" variants of existing enemies that
   appear more often (or only) at higher Slaying level, with boosted or exclusive drops. How are they
   surfaced (a bounty board? passive spawn?), and what do they drop?
3. **The Slaying progression track:** flesh out the full level-unlock ladder (beyond the spec's current
   Lv10/20/25), the rewards, and any prestige/mastery at Lv100.
4. **The Slaying Mastery page contents + home:** what the page should show once there is real content
   (active hunts, unlocked zones, bounty targets, mastery perks), and where it lives in navigation.

## Constraints / fit

- Zone/dungeon ACCESS is gated by **Total Combat Level** (sum of Grimoire combat levels), not Slaying,
  keep it that way; Slaying gates its OWN content (hunts, bounties, spawn bonuses), not the main zones.
- Reuse existing systems where possible: `EnemyData` (faction tags, drop tables, elite/boss flags),
  the zone/dungeon `CreatePhaseXEnemies`/`Dungeons` authoring pattern, the quest/task board.
- Keep it buildable with the current combat loop (no new turn-based/raid systems, those are deferred).

Deliver as `slaying-content-spec.md` (resolves this request). Code will build it and give the Slaying
Mastery page its home.
