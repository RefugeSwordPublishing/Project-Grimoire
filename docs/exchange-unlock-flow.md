# Project Grimoire, Exchange Unlock Flow
### Version 0.1

---

## Design Philosophy

The Wayfarer's Exchange unlocking is a milestone moment, the player's first connection to the wider game economy. It should feel like arriving at a market for the first time, not like a feature being toggled on. The unlock should be rewarding, clear, and immediately actionable.

---

## Unlock Condition

**Trigger:** Any single Talent reaches level 10
**Gate:** Checked server-side on every Talent level-up, cannot be bypassed client-side
**One-time event:** Once unlocked, the Exchange is permanently accessible

For most players following the Phase 1 idle loop this happens naturally within the first 1-3 sessions depending on how actively they play. Foraging or Marksmanship will typically be the first to hit level 10.

---

## Unlock Flow, Step by Step

### Step 1, Talent Reaches Level 10
Normal level-up flow plays, XP bar fills, level number increments, standard level-up chime sounds.

Immediately after the level-up animation completes, a special unlock banner slides in from the top of the screen:

```
┌─────────────────────────────────────┐
│  THE WAYFARER'S EXCHANGE          │
│  The market has opened its doors    │
│                    [ Visit Now ] →  │
└─────────────────────────────────────┘
```

- Banner uses gold border styling, distinct from standard notifications
- "Visit Now" button is optional, player can dismiss and visit later
- Banner auto-dismisses after 8 seconds if not tapped
- A permanent Exchange icon appears in the bottom navigation immediately

### Step 2, First Exchange Visit
When the player first opens the Exchange (either via "Visit Now" or by tapping the nav icon), a brief one-time introduction sequence plays:

**Welcome panel, single screen, tap to dismiss:**

```
┌─────────────────────────────────────┐
│  Welcome to the                   │
│     Wayfarer's Exchange             │
│                                     │
│  Buy and sell with other players.   │
│  List items, place buy orders,      │
│  or browse what others have to      │
│  offer.                             │
│                                     │
│  The Royal Merchant also trades     │
│  here, look for the crown icon.   │
│                                     │
│           [ Enter the Market ]      │
└─────────────────────────────────────┘
```

- Pixel art market scene as background, stalls, lanterns, figures browsing
- Single tap to enter, no multi-step tutorial
- Never shown again after first dismissal

### Step 3, Exchange Opens with Starter Hint
On the first visit, a single contextual tooltip appears over the listing creation button:

> *"You can list items directly from your inventory, tap any item and select 'List on Exchange'."*

Tooltip dismisses on tap. Never shown again.

No further hand-holding, the Exchange UI is discoverable on its own from here.

---

## Notification

If the player is not actively in the app when the unlock triggers (Talent leveled up during idle):

**Push notification, P3:**
| Field | Value |
|-------|-------|
| Title | `The Wayfarer's Exchange is open` |
| Body | `Your Talents have earned you market access` |
| Deep link | `grimoire://exchange` |
| Fires once | Never repeated, one-time unlock notification |

---

## Technical Notes for Implementation

- Unlock state stored as `exchange_unlocked: boolean` in `players` table, defaults false
- On every Talent level-up: Edge Function checks if any Talent is now level 10+ AND `exchange_unlocked = false`
- If condition met: set `exchange_unlocked = true`, trigger unlock notification if player is idle
- Client reads `exchange_unlocked` on app open, Exchange nav icon hidden if false, visible if true
- Exchange nav icon uses a distinct "new" indicator on first appearance, small golden glow that fades after first visit
- First visit state tracked via `exchange_first_visit: boolean` in `players` table, controls welcome panel display
- Starter tooltip state tracked in local PlayerPrefs, shown once, then `exchange_tooltip_shown = true`
- Royal Merchant tab visible immediately on first Exchange visit, no separate unlock required

---

## Related Flows

- **Royal Merchant**, accessible from first Exchange visit, no separate gate
- **Listing items**, player can list immediately, no minimum Exchange level
- **Buy Orders**, available from first visit
- **Guild Bank**, separate from Exchange, unlocked when player joins a guild
- **Notice Board**, separate HUD element, not inside Exchange

---

*Document version 0.1, Exchange Unlock Flow*
*Phase 1 design complete, ready for Session 3 handoff*
