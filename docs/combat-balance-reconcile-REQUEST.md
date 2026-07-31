# Combat Balance Reconcile, REQUEST for Chat

**Status:** open design question. Raised 2026-07-31 from a live playtest. Claude Code has diagnosed
the as-built pipeline; the balance model itself is a design decision for Chat to set, then Code
implements. One clear bug is called out at the end.

---

## Symptom

A level-13 Sharpshot (Warden) with a **Crude Bronze bow** nearly 2-shots every enemy in zone 1.

## What is NOT the cause (measured, on-spec)

- **Bow base damage.** Crude Bronze bow rolls a **4-8** damage band (quality base, Bronze tier flat
  bonus is 0). Identical to the unarmed baseline. `EquipmentStats.WeaponDamage` /
  `CreateEquipment.cs`.
- **Zone-1 enemy HP.** Grimwood Fringe: Brigand 55, Forest Wolf 50, Poacher 90, Bear 140, elites
  180-210, boss 600. Saltmarsh Shore is comparable. These sit within the doc's Tier-1 band.
  `CreateZoneEnemies.cs`.

## The actual cause: active-shot multipliers stack

The player's ranged damage per **active** shot (tap-to-fire, not idle auto-attack) is:

```
raw    = GetRangedAttack()                       // ≈ (effDEX × 1.2) + bowRoll + DEXEquip
postDef = max(1, raw − enemyDefense × 0.4)       // enemy def 3-10, so this shaves ~1-4 only
final   = postDef × bowstringMultiplier          // ← applied over the WHOLE post-defense number
```

`bowstringMultiplier` is where it compounds:

1. **Bullseye / weak-point crit** is coded at **×2.0** (`BowstringMechanic`), but
   `stat-scaling-combat-formulas.md` specs the weak-point crit at **×1.6**.
2. On top of the crit, the **charged ability ring** multiplies again (`WardenBowstringMechanic`):
   Full Draw ×1.30, Aimed ×2.0, Pierce ×1.5, **Long Shot ×8.0**, plus multi-arrow tiers, plus
   Armor Piercer ×1.15. The design doc's ranged formula contains **no second ability factor**.

At level 13 only Full Draw is unlocked, so the reachable active multiplier is roughly
`2.0 (crit) × 1.30 (Full Draw) × 1.15 (Armor Piercer) ≈ 3.0`. With a ~27 post-defense base that is
**~80 damage per active shot**, which 1-shots the 50-55 HP tier and 2-shots the rest. Idle
auto-attacks are unaffected (they pass `active:false` and skip the multiplier entirely), so this is
purely an active-play problem, and it gets far worse later (Long Shot ×8).

## Divergences from `stat-scaling-combat-formulas.md`

| Element | Doc intent | As-built |
|---|---|---|
| Weak-point crit | ×1.6 | ×2.0 |
| Ability-ring multiplier | none (formula has no ability factor) | ×1.30 to ×8.0, multiplicative on top of crit |
| Armor Piercer | none | ×1.15 on top |
| Defense application | (not specified) | subtracted BEFORE the multiplier, so the multiplier scales the mitigated number up again |
| Idle baseline ×0.80 | ×0.80 | ×0.80 (matches) |

## Design questions for Chat

1. **Crit value:** hold the doc's ×1.6, or bless the ×2.0 the code uses?
2. **Ability-ring stacking:** should Full Draw / Aimed / Long Shot multiply *on top of* the crit, or
   replace it, or add rather than multiply? What is the intended peak active multiplier at low level
   vs. endgame? Long Shot ×8 over a crit is the scariest term.
3. **Defense order:** apply enemy defense *after* the multiplier (so mitigation isn't scaled away),
   or keep it before? Enemy defense is currently 3-10; should Tier-1 defense rise?
4. **A combined-multiplier cap** (e.g. clamp crit × ring × pierce to some ceiling), yes/no?
5. **Zone-1 target time-to-kill:** how many active shots *should* a well-built lv13 take to drop a
   basic zone-1 enemy? That number anchors the whole reconcile.

## One clear bug (Code can fix independently once confirmed)

`PlayerData.GetRangedAttack()` folds `DEXEquip` into the `×1.2` term **and** adds it flat again:
`(effDEX incl. DEXEquip) × 1.2 + bowRoll + DEXEquip`. The doc line reads
`(DEX × 1.2) + Bow Damage + DEX Equipment Bonus`, which could be read either way. Chat: is the
equip-DEX double-count intended (equipment DEX worth ~2.2×), or a bug to collapse to one application?
