---
type: as-built
spec: vanguard-combo-system.md (v0.2), vanguard-combo-implementation-brief.md
updated: 2026-07-17
status: Phase 1 wired (seam + full combo library + stamina + cooldown)
---

# Vanguard Combo — AS-BUILT (Phase 1)

Wired the Strike/Guard/Surge melee combo system into the `ActiveCombatMechanic` seam — the
same seam as the Warden bow and Arcanist constellation. This completes the active mechanic for
all three base paths (Warden ✓, Arcanist ✓, Vanguard ✓).

## What's built
- **`ComboInput`** enum (Strike/Guard/Surge) + **`VanguardComboLibrary`** — code-defined full
  combo tables for **Warlord / Bulwark / Shadowblade** (2-input L15, 3-input L35), base attacks,
  cooldown/stamina/depth/idle tables, key gen, prefix helper.
- **`VanguardComboMechanic : ActiveCombatMechanic`** — sequence resolution, per-combo cooldown,
  stamina cost + fallback, speed bonus, Shadow's Edge, idle-return grace.
- **`VanguardComboUI`** — self-populating Strike/Guard/Surge buttons with downward-emptying
  cooldown overlays (red-tinted while a taunt combo fired) + input-queue label.
- **`BuildVanguardComboUI`** editor tool + `ZoneCombatView` Vanguard branch.

## Reconciliations (confirm in the next spec pass)
1. **Input model — hybrid, not pure instant-fire.** The brief says "instant fire, no timer";
   the spec says "1.5s auto-fire". These conflict, and **instant-fire is broken for this library**:
   nearly every 2-input combo (SS, SG, SU, GS, …) is the prefix of a 3-input combo, so firing on
   the 2nd tap makes all 3-input combos unreachable. I built a hybrid: **fire instantly when
   unambiguous** (max depth reached, or an exact match that isn't a prefix of a longer unlocked
   combo); **use a short commit window (`_commitWindow`, default 1.0s, tunable) only for ambiguous
   prefixes.** At L15–34 (max depth 2) everything fires instantly; at L35+ the commit window
   disambiguates 2- vs 3-input — which is exactly the spec's timer behaviour, only where needed.
   **Please pick the canonical model** (I recommend keeping the hybrid + tuning `_commitWindow`).
2. **Damage multipliers were interpreted from the effect text** ("+80% dmg" → ×1.8, etc.). Pure
   defensive/taunt combos (Iron Stance, Warcry, Void Step) got a low chip multiplier so the tap
   isn't dead until their real effects land (see deferred). Numbers are first-pass — tune freely.

## Deferred (Phase 2 — layer on once the seam feels right)
- **Defence buffs / taunt / DoT (bleed, void) / stealth / evasion states** — captured as data on
  `ComboData` (defenseModifier, tauntValue, durationSeconds) but not applied; only the damage
  multiplier + Shadow's Edge land. Defence needs a transient-defence channel (PlayerData only has
  VIT-derived defence today); taunt needs the AggroManager (deferred to Summoner).
- **Combo streak bonus** (L38) — not tracked yet.
- **Weighted-random idle** — idle uses the combat loop's generic single Strike (cost 0), which is
  the spec's own "idle always uses Strike" fallback. The brief's weighted-random idle-cast is deferred.
- **Speed bonus** applied simply (whole sequence < 1s → ×1.25); the "all inputs under 1.0s" and
  counter-after-damage attunement bonuses are approximated / deferred.
- **No-crit** — already satisfied (no crit path in CombatManager; damage flows through the
  multiplier channel). Shadow's Edge is a flat ×1.8 shown as "Critical!" text only.

## To test
`Tools > Grimoire > Add Vanguard Combo UI`, save the scene, equip a Warlord/Bulwark/Shadowblade
Grimoire, enter a zone. Tap Strike/Guard/Surge. At combat level < 15 only singles fire; 2-input
unlocks at 15, 3-input at 35 (`CombatXPManager` grimoire level).

## Update 2026-07-17 — unlock restagger + descriptions LANDED
Chat delivered the full per-combo unlock tables + in-world descriptions (all 3 subclasses). Applied:
- Every combo now has a staggered `unlockLevel` (L1 starters → up to L93) instead of the depth-gate
  dump, plus a `description` field shown in the Grimoire Book. Level-1 starters: Warlord S→G, Bulwark
  G→S, Shadowblade S→S.
- Prefix/commit-window check is now **unlock-aware** (`IsPrefixOfLonger(..., combatLevel)`) so a 2-input
  combo fires instantly when its 3-input extensions aren't unlocked yet — no pointless commit delay.

## Open questions for Chat
1. Confirm the hybrid input model + a canonical `_commitWindow` value.
2. When should defence/taunt effects come online — before or after Summoner's AggroManager?
3. First-pass damage multipliers — want a balancing pass, or leave for playtest tuning?

*Path: `docs/vanguard-combo-asbuilt.md`*
