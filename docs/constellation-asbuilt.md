---
type: as-built
spec: runic-constellation-spec.md (v0.4), constellation-implementation-brief.md
updated: 2026-07-17
status: Phase 1 wired (seam + full library + node UI + idle return)
---

# Arcanist Constellation — AS-BUILT (Phase 1)

Wired the Runic Constellation into the existing `ActiveCombatMechanic` seam (the same
seam the Warden bow uses). Runeweaver is fully playable today; Summoner/Lifebinder tables
exist but lean on systems not yet built (constructs, party heals).

## What's built
- **`RuneType`** — 8-rune enum.
- **`ConstellationLibrary`** — code-defined (not 78 ScriptableObjects): full 26-spell tables
  per subclass, node layouts, counter pairs, depth/speed/mana/HP-cost tables, idle interval,
  depth-unlock gating, order-dependent key generation.
- **`ArcanistConstellationMechanic : ActiveCombatMechanic`** — `Configure/SetEngaged`, node-touch
  sequence building, resolution (`depth × speed × counter × potency`), mana gate (Runeweaver/
  Summoner) / HP gate (Lifebinder), heal branch, idle-return grace, depth cap → auto-fire.
- **`ConstellationUI`** — self-populating 6-node thumb arch; a full-panel raycast surface owns
  drag hit-testing and feeds the ordered sequence to the mechanic. Node glow + sequence readout.
- **`BuildConstellationUI`** editor tool + `ZoneCombatView` Arcanist branch (mirrors the Warden
  branch: Configure → SetEngaged → SetActiveMechanic → show panel).

## Reconciliations (where I diverged from the docs — please confirm in the next spec pass)
1. **Order-DEPENDENT lookup.** The brief's "Sequence Resolution" snippet used an order-independent
   `HashSet` key; the spec v0.4 body is emphatic that **order matters** (GLA-IGN ≠ IGN-GLA, Storm
   Caller revisits nodes). I built order-dependent string keys per the spec. The brief snippet is stale.
2. **Mana cost scales with the CAST depth, not `maxSequenceLength`.** The brief literally reads
   `manaCost = maxSequenceLength switch {…}`, which would charge full price for a 1-rune cast at a
   high level. I cost by the actual drawn sequence length. Flag if that was intentional.
3. **Spells are code, not assets.** 78 `SpellData` SOs would be brittle to author/diff. One curated
   static library instead. If you want designer-editable spells later, we can back it with SOs.
4. **Key codes.** Spec prose says `ToString().Substring(0,3)` but its own examples use TMP/VNT/TER —
   not substrings. I used explicit 3-letter codes matching the examples.

## Deferred (Phase 2 — layer on once the seam is confirmed in playtest)
- **Status effects** — burn/slow/blind/stagger/weaken/chain are captured as flavour text but not
  yet applied; only the damage multiplier lands. (Weapon-coating DoT is separate and still works.)
- **Heal effects beyond immediate HP** — HOTs, shields, cleanse, revive, party-wide heals fire a
  stand-in immediate heal + log the intent. Needs the Lifebinder HOT/shield system + party model.
- **Idle auto-cast at 60%** — idle currently uses the combat loop's generic strike. Driving the
  last-combo idle-cast needs a small hook so the mechanic can supply the idle multiplier. Low risk.
- **Targeting tether / connection lines / node spark visuals** — arch + glow only for now.
- **Summoner constructs & Lifebinder party** — those subclasses' spells resolve as damage/heal
  against the solo enemy until construct/party systems exist.
- **No-crit enforcement** — already satisfied: CombatManager has no crit path, and Arcanist damage
  flows purely through the multiplier channel (no weak-point, no crit roll). No code needed.

## Open questions for Chat
1. Mana cost by cast-depth vs unlocked-max — confirm the reconciliation above.
2. Should the weak default spell also cost when the *drawn* pattern is valid but the player lacks
   mana — currently it charges the 1-rune cost and fires the 40% blast. OK?
3. Idle auto-cast: keep generic strike for now, or prioritise the 60%-last-combo idle next?

*Path: `docs/constellation-asbuilt.md`*
