# Offline Combat on the While-You-Were-Away Screen, REQUEST for Chat

**Status:** open design question. Raised 2026-07-31. This is a **feature gap**, not a wiring bug:
there is no offline-combat accrual in the game today. Chat sets the payout model; Code implements.

---

## What exists today

- **While-You-Were-Away (WYWA)** covers **only** `IdleManager` gathering / crafting / processing.
  Its data source is `IdleManager.LastSessionResult`, produced by `CalculateOfflineRewards` from a
  timestamp diff (`DateTime.UtcNow − PlayerPrefs["LastSessionTimestamp"]`) against the active
  gather/craft activity.
- **Zone combat** is a **live real-time loop** (`CombatManager.Update`). It has **no** timestamp,
  no offline accrual, and no session summary. Backgrounding the app freezes it.
- Idle and combat are **mutually exclusive** and clear each other's state: entering combat calls
  `Idle.StopAction()` (which deletes the `ActiveTalent`/`ActiveActivity` keys WYWA depends on), and
  starting an idle action calls `Combat.StopZoneCombat()`. So while combat is the active pursuit,
  WYWA has nothing to show and never appears.
- Combat XP (per hit + on kill), drops (rolled live per kill), and consumable auto-eat all happen
  **live only**. `StopZoneCombat` flushes pending XP but builds no summary object.

Net: if the player leaves the app mid-combat, they get **nothing** on return, and WYWA does not fire.

## What the user asked for

> "Combat idles don't show on WYWA. Even if the user gets knocked out, it should show exp earned,
> drops obtained, and used consumables."

So the ask is: treat an interrupted/backgrounded combat session like an idle session, and surface
its results (XP, drops, consumables spent) on the WYWA screen, including the knocked-out case.

## Design questions for Chat

1. **Does combat accrue while backgrounded at all, or only up to the moment of backgrounding?**
   - Option A (summary only): no offline progression; on return, show a summary of what the *live*
     session earned before it was frozen (requires persisting a running tally + flushing it into a
     result on background). Simplest, no new economy.
   - Option B (true offline combat): estimate kills over the elapsed away-time and pay out
     accordingly. Needs a kill-rate model and a cap.
2. **If offline (Option B): what is the kill rate?** Derive from the player's recent live DPS vs the
   active zone's enemy HP? A flat "N kills per minute in zone T"? Is there an offline efficiency
   penalty (e.g. 50% of live rate, like some idle games)?
3. **Knock-out handling:** if the player would have died, does offline combat stop at the point of
   death (partial rewards) or auto-revive-and-continue at the 10%-HP recovery rule already used
   live? The user explicitly wants *some* reward even on a knockout.
4. **Drops and consumables:** roll drops per estimated kill from the zone's drop tables? Auto-consume
   healing/consumables from the bag to sustain the offline fight (and report what was spent), or
   assume no consumable use offline? What happens when consumables run out?
5. **Elite / boss encounters offline:** included in the estimate, or basic enemies only?
6. **Away-time cap** for combat (idle gathering has its own cap; combat should too).

## Implementation notes for Code (once the model is set)

- Persist a combat "last active" marker (timestamp + zone id + grimoire id) parallel to
  `SaveSessionTimestamp`, written on background in `GameManager.OnApplicationPause/Focus` (or in
  `StopZoneCombat`).
- Add an offline-combat calculator analogous to `IdleManager.CalculateOfflineRewards`.
- Surface it in WYWA: either extend `IdleSessionResult` with combat fields or add a parallel result
  type, and add render rows in `WhileYouWereAwayUI.ShowResult`. Note: `ShowResult` currently renders
  only `xpGained` and `itemsGained`; it does **not** yet render `itemsConsumed`, so a
  "consumables used" section is new render work regardless of the accrual model chosen.
