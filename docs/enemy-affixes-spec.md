---
type: design-spec
version: 1.0
updated: 2026-09-20
path: docs/enemy-affixes-spec.md
resolves: retention brainstorm, pick 3 of 5, and the root cause in game-state-briefing section 11
implements: EnemyAffix data, affix rolling on spawn, nameplate chips, boss authored affixes
---

# Enemy Affixes
### Version 1.0

---

## 1. This Is The Root Fix

The briefing states the retention problem plainly: higher zones "differ from lower ones mostly by
stat inflation, not by mechanics, so advancing does not yet change how combat plays."

Every other retention feature on the list amplifies whatever is underneath it. This is the one that
changes what is underneath.

**The cheap version of the expensive fix.** Authoring unique special abilities for every boss and
elite across five tiers is a very large content job, which is presumably why they are still reference
text. Eight affixes applied by tier weight gets most of that outcome for a fraction of the work,
because eight behaviours reused across seventy enemies is eight behaviours to build.

---

## 2. Design Constraints That Shape The Set

Two as-built facts rule out most of the obvious affixes.

**There is no player positioning in combat.** Aim is a horizontal drag around a fixed screen-center
reference. Nothing in the game lets a player move toward or away from an enemy, so every
positional affix (ground effects, charges, knockback, melee punishment) is off the table.

**Arcanist and Vanguard have `critChance = 0` and `weakPointEnabled = false`.** Any affix built
around crits or weak points only exists for one of three paths. That is acceptable for one affix out
of eight and unacceptable for more.

So affixes have to work through damage timing, damage gating, resources, and the active mechanics.
Which, as it turns out, is where the interesting design is anyway.

---

## 3. The Eight

| Affix | Effect | Rewards | Punishes |
|---|---|---|---|
| **Armored** | Takes 40 percent reduced damage until 5 hits land, then breaks for the rest of the fight | Fast weapons, more swings | Slow heavy weapons |
| **Warded** | Takes 50 percent reduced damage until hit by an active-mechanic attack | Foreground play | Pure idling |
| **Frenzied** | Attack cadence tightens 15 percent per 25 percent HP lost | Killing it quickly | Long fights |
| **Leeching** | Heals for 20 percent of damage it deals to you | Evade, block, mitigation | Raw HP pools |
| **Volatile** | On death, deals a flat burst to the player | Topping up before the last hit | Finishing at low HP |
| **Regenerating** | Heals 2 percent max HP per second unless damaged in the last 2 seconds | Sustained uptime | Slow weapons, idle gaps |
| **Hardened** | Immune to weak-point crits | Nothing, it is a pure counter | Warden specifically |
| **Swift** | Evasion increased by 30 | Accuracy investment | Low-accuracy builds |

### 3.1 Warded is the most important one in the set

It is the only affix that directly answers "there is little pull to engage actively at higher tiers."

A Warded enemy takes half damage until the player lands a bowstring release, a completed
constellation, or a completed combo. An idling player can still kill it, slowly. An engaged player
halves the time. That is a real incentive to pick up the phone that costs no new systems, because all
three active mechanics already route through the shared `ActiveCombatMechanic` seam.

It should be the most common affix at Tier 3 and above for exactly that reason.

### 3.2 Armored inverts the usual weapon preference, on purpose

Every other system in the game gently favours slow heavy weapons, because crits and multipliers scale
off a bigger per-hit number. Armored counts hits, not damage, so a 1.40s Dagger breaks it in seven
seconds and a 2.90s Crossbow takes fourteen.

One affix that rewards the other end of the weapon table is healthy. It gives fast weapons a niche
they currently lack and it makes weapon choice situational rather than solved.

### 3.3 Hardened is deliberately Warden-only

Seven of the eight are universal. One that specifically counters the Warden's signature mechanic is
fine and arguably necessary, because an affix set with no answer to weak points means the Warden
never has to adapt to anything.

It must stay at one. Two Warden-specific counters would read as the design disliking Wardens.

---

## 4. Distribution

### 4.1 Standard enemies roll, bosses are authored

**Standard and elite enemies roll their affixes on spawn.** That is what makes a zone feel varied
across sessions rather than memorised after one clear.

**Bosses get authored affixes, not rolled ones.** A boss fight should be the same fight every time so
it can be learned, discussed, and beaten deliberately. Two or three authored affixes per boss also
gives each one an identity without anyone writing a bespoke ability.

### 4.2 Tier weighting

| Tier | Standard | Elite |
|---|---|---|
| 1 | None | None |
| 2 | 25 percent chance of 1 | 1 |
| 3 | 1 | 1, plus 25 percent chance of a second |
| 4 | 1, plus 30 percent chance of a second | 2 |
| 5 | 2 | 2, plus 25 percent chance of a third |

Tier 1 has no affixes at all. A new player should learn what an attack timer is before they learn
what Regenerating means.

### 4.3 Affix weighting by tier

Not every affix should appear at every tier. Warded and Armored are legible immediately. Leeching and
Regenerating require the player to understand sustain. Volatile needs auto-eat to be worth having.

| Affix | First appears |
|---|---|
| Armored, Swift | Tier 2 |
| Warded, Frenzied | Tier 3 |
| Leeching, Regenerating | Tier 4 |
| Volatile, Hardened | Tier 4 |

Warded's weight should be roughly double the others from Tier 3 on.

---

## 5. Display

**A chip row on the enemy nameplate**, reusing the existing debuff chip prefab. Icon plus a short
name, two or three chips maximum, which is exactly what the distribution allows.

Tapping a chip shows a one-line explanation. "Takes reduced damage until you land an active attack."
Plain language, no numbers, because the numbers are tuning and the player needs the behaviour.

**Armored and Warded need a broken state.** Once the gate is cleared, the chip visibly greys out.
Without that the player has no way to learn that hitting it five times did something, and an affix
the player cannot perceive is just a stat change wearing a costume.

### 5.1 Bestiary interlock

The bestiary's Studied tier should reveal which affixes an enemy can roll, alongside the drop table.
That gives the bestiary a second reason to exist and gives affixes a place to be learned outside
combat.

---

## 6. Balance Note, And It Is Not Optional

**Affixes increase time to kill without increasing enemy stats. Enemy stats at Tier 3 and above will
need to come down to compensate.**

A Tier 5 standard enemy with two affixes will take meaningfully longer to kill than the same enemy
does today, on top of already having the highest HP in the game. Shipping affixes without a
compensating pass makes the top tiers feel like wading.

The honest way to do it: measure time to kill on a representative Tier 4 and Tier 5 enemy before and
after, and reduce base HP until the affixed TTK matches the current unaffixed TTK. The fight should
become more interesting, not longer.

This is the piece most likely to be skipped and most likely to be blamed on the wrong thing when
playtesters say Tier 5 feels like a slog.

---

## 7. Data

```csharp
public enum EnemyAffix {
    None, Armored, Warded, Frenzied, Leeching,
    Volatile, Regenerating, Hardened, Swift
}

// On EnemyData, for bosses only.
public EnemyAffix[] authoredAffixes;

// Rolled at spawn for standard and elite, stored on the runtime instance.
public EnemyAffix[] activeAffixes;
```

One enum, one authored array on boss assets, one runtime array. No table, no migration, no server
work. The rolling table is a static per-tier weight list.

---

## 8. Acceptance Criteria

- Tier 1 enemies never carry an affix.
- Standard and elite affixes roll on spawn. Boss affixes are authored and identical every encounter.
- No enemy carries more affixes than its tier row in section 4.2 permits.
- Warded resolves against all three active mechanics through the `ActiveCombatMechanic` seam.
- Armored and Warded visibly grey their chip when their gate is cleared.
- Affix chips reuse the existing debuff chip prefab.
- Tapping a chip shows a plain-language explanation with no numbers.
- Exactly one affix in the set is Warden-specific.
- Tier 3 through 5 enemy base HP has been re-measured and reduced so affixed time to kill matches
  the current unaffixed time to kill.
- No new table, RPC, or migration is created.

---

*Path: docs/enemy-affixes-spec.md*
*Eight affixes, tier-weighted, rolled for standard and elite and authored for bosses. Warded is the*
*one that rewards foreground play and should be weighted heaviest. Positional affixes are impossible*
*because combat has no positioning. Section 6 is not optional.*
