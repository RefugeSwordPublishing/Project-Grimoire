# Project Grimoire, Push Notification Triggers
### Version 0.1

---

## Design Philosophy

Push notifications exist to bring players back at meaningful moments, not to spam them into disabling notifications entirely. Every notification must pass a simple test: **would a player be glad they were interrupted for this?**

**Rules:**
- Never send more than 3 notifications in a 4-hour window, hard cap, regardless of events
- Priority system resolves conflicts when multiple events trigger simultaneously, highest priority fires, others queue or drop
- All notifications respect the player's individual settings toggles and device-level Do Not Disturb
- Notification copy matches the game's medieval fantasy tone, not generic app-speak
- Short and scannable, title under 50 characters, body under 100 characters
- No notification within 30 minutes of a previous one (soft cooldown) unless it's Priority 1

---

## Priority Tiers

When multiple events trigger simultaneously, only the highest priority fires. Lower priority events within the same 30-minute window are dropped (not queued).

| Priority | Tier | Examples |
|----------|------|---------|
| **P1, Critical** | Always fires, ignores cooldown | Zone boss spawn (time-sensitive, despawns in 10 min) |
| **P2, High** | Fires if no P1 in last 30 min | Rare drop, dungeon/raid events |
| **P3, Medium** | Fires if no P1/P2 in last 30 min | Level up, quest complete, Exchange sale |
| **P4, Low** | Fires if no higher priority in last 4 hrs | Grimoire cooldown, daily reset, rotation change |

---

## Notification Triggers, Full Specification

### Combat Events

**Zone Boss Spawned, P1**
| Field | Value |
|-------|-------|
| Trigger | Enemy spawn system rolls zone boss during active or idle combat |
| Timing | Fires immediately on spawn |
| Expires | After 10 minutes (boss despawn time), notification becomes irrelevant if not acted on |
| Title | `{BossName} has appeared!` |
| Body | `{ZoneName}, engage before it disappears` |
| Setting toggle | Zone Boss Spawned |
| Example | `Aldric the Poacher King has appeared! · Grimwood Fringe, engage before it disappears` |

---

### Talent & Progression Events

**Talent Level Up, P3**
| Field | Value |
|-------|-------|
| Trigger | Any Talent reaches a new level during idle session |
| Batching | If multiple Talents level up in same idle session, batch into one notification |
| Timing | Fires on app-open idle calculation OR after 2hrs idle if player hasn't opened app |
| Title | `{TalentName} reached level {N}` |
| Body (single) | `Check your new unlocks` |
| Title (batched) | `{N} Talents leveled up` |
| Body (batched) | `{Talent1}, {Talent2} and more, check your unlocks` |
| Setting toggle | Level Up |
| Example | `Foraging reached level 35 · Check your new unlocks` |

**Rare Material Drop, P2**
| Field | Value |
|-------|-------|
| Trigger | Rare material (Crude tier or above) drops during idle gathering or combat |
| Timing | Fires after 2hrs idle if player hasn't opened app |
| Title | `◆ Rare find while you were away` |
| Body | `{MaterialName} dropped, check your inventory` |
| Setting toggle | Rare Drop |
| Example | `◆ Rare find while you were away · Crude Amber dropped, check your inventory` |

---

### Quest Events

**Daily/Weekly Quest Complete, P3**
| Field | Value |
|-------|-------|
| Trigger | Quest objective conditions met during idle |
| Batching | If multiple quests complete simultaneously, batch |
| Timing | Fires within 15 minutes of completion during idle |
| Title | `Quest complete` |
| Body (single) | `{QuestName}, reward waiting` |
| Body (batched) | `{N} quests complete, rewards waiting` |
| Setting toggle | Quest Complete |
| Example | `Quest complete · Harvest 20 Crops, reward waiting` |

**Slaying Task Complete, P3**
| Field | Value |
|-------|-------|
| Trigger | Slaying task objective met |
| Timing | Fires within 15 minutes of completion |
| Title | `Slaying task complete` |
| Body | `{TaskDescription}, collect your reward` |
| Setting toggle | Quest Complete |
| Example | `Slaying task complete · Clear Aldric's Warren, collect your reward` |

**Daily Quest Board Reset, P4**
| Field | Value |
|-------|-------|
| Trigger | Midnight UTC board refresh |
| Timing | Fires at midnight UTC |
| Frequency cap | Once per day maximum |
| Title | `New quests available` |
| Body | `Your quest board has refreshed` |
| Setting toggle | Daily Quest Reset (default OFF) |
| Example | `New quests available · Your quest board has refreshed` |

---

### Economy Events

**Exchange Sale Complete, P3**
| Field | Value |
|-------|-------|
| Trigger | Player's Store Listing or Auction is purchased |
| Batching | Multiple sales within 1hr batched into one notification |
| Timing | Fires within 5 minutes of sale |
| Title | `◈ Your listing sold` |
| Body (single) | `{ItemName}, {Amount} SM collected` |
| Body (batched) | `{N} listings sold, marks collected` |
| Setting toggle | Exchange Sale |
| Example | `◈ Your listing sold · Iron Bar × 240, 10,080 SM collected` |

**Buy Order Fulfilled, P3**
| Field | Value |
|-------|-------|
| Trigger | Player's Buy Order is partially or fully filled |
| Batching | Multiple fills within 1hr batched |
| Timing | Fires within 5 minutes of fill |
| Title | `◈ Buy order fulfilled` |
| Body (partial) | `{ItemName}, {FilledQty}/{TotalQty} filled` |
| Body (complete) | `{ItemName}, order complete` |
| Setting toggle | Exchange Buy Order |
| Example | `◈ Buy order fulfilled · Wolf Pelt, 18/20 filled` |

---

### Grimoire Events

**Grimoire Swap Cooldown Expired, P4**
| Field | Value |
|-------|-------|
| Trigger | 24hr Grimoire swap cooldown timer completes |
| Timing | Fires exactly when timer expires |
| Title | `Grimoire swap available` |
| Body | `Your Grimoire can be changed again` |
| Setting toggle | Grimoire Cooldown |
| Example | `Grimoire swap available · Your Grimoire can be changed again` |

---

### Dungeon & Raid Events

**Dungeon Rotation Changed, P4**
| Field | Value |
|-------|-------|
| Trigger | Monthly dungeon rotation refreshes on 1st of month |
| Timing | Fires at rotation time (first of month) |
| Frequency cap | Once per month |
| Title | `New dungeons available` |
| Body | `This month's rotation has changed, check the board` |
| Setting toggle | Dungeon Rotation |
| Example | `New dungeons available · This month's rotation has changed, check the board` |

**Raid Window Opens, P2**
| Field | Value |
|-------|-------|
| Trigger | Quarterly raid becomes active |
| Timing | Fires when raid activates |
| Frequency cap | Once per quarter |
| Title | `The raid is now active` |
| Body | `{RaidName}, Slaying 45 required` |
| Setting toggle | Raid Window |
| Example | `The raid is now active · Voidthrone, Slaying 45 required` |

> **Raid 14-day advance notice** is in-game only, displayed on the Notice Board (see below), not sent as a push notification. Players who open the app will see it naturally without being interrupted two weeks early.

---

### Guild Events

**Guild Material Request Posted, P4**
| Field | Value |
|-------|-------|
| Trigger | Officer or Guild Master posts a new material request to guild bank |
| Timing | Fires within 5 minutes of posting |
| Title | `Guild needs materials` |
| Body | `{ItemName} × {Quantity} requested, donate from inventory` |
| Setting toggle | Guild Notifications |
| Example | `Guild needs materials · Iron Bar × 500 requested, donate from inventory` |

**Guild Bounty Activated, P4**
| Field | Value |
|-------|-------|
| Trigger | Officer activates a guild bounty |
| Timing | Fires within 5 minutes |
| Title | `Guild bounty activated` |
| Body | `{BountyName}, contribute before time runs out` |
| Setting toggle | Guild Notifications |
| Example | `Guild bounty activated · The Ashfen Bounty, contribute before time runs out` |

**Guild Prestige Level Up, P3**
| Field | Value |
|-------|-------|
| Trigger | Guild reaches a new Prestige level |
| Timing | Fires within 5 minutes |
| Title | `Guild prestige increased` |
| Body | `{GuildName} reached Prestige {N}, new hub unlocked` |
| Setting toggle | Guild Notifications |
| Example | `Guild prestige increased · Refuge Sword reached Prestige 5, Tent Camp unlocked` |

---

## Priority Resolution Examples

**Scenario 1:** Zone boss spawns at the same time a Talent levels up
- P1 (Zone Boss) fires immediately
- P3 (Level Up) is dropped, player is already coming back

**Scenario 2:** Two Exchange sales complete within 10 minutes of each other
- First sale fires as P3
- Second sale within 30-minute cooldown is batched into the next notification slot

**Scenario 3:** Rare drop AND quest complete during same idle session
- P2 (Rare Drop) fires first
- P3 (Quest Complete) fires after 30-minute cooldown if player hasn't opened app

**Scenario 4:** Player has opened the app within the last 30 minutes
- All P3 and P4 notifications suppressed, player is already active
- P1 still fires (zone boss time-sensitive)
- P2 fires only if more than 30 minutes since last notification

---

## Technical Notes for Implementation

**Firebase Cloud Messaging setup:**
- FCM token registered on app install, stored in `player_settings.fcm_token` in Supabase
- Token refreshed automatically by Firebase SDK, update in Supabase on refresh event
- When player disables All Notifications in settings: unregister FCM token entirely (`FirebaseMessaging.Instance.DeleteTokenAsync()`)
- When re-enabled: re-register and update Supabase

**Server-side dispatch via Supabase Edge Functions:**
- All notifications dispatched server-side, never client-triggered
- Edge Function `send_notification(player_id, notification_type, payload)` checks:
  1. Player's `player_settings` notification toggles
  2. Last notification timestamp (30-min cooldown)
  3. 4-hour notification cap count
  4. Priority vs current pending notifications
  5. Whether player has been active in last 30 minutes (suppress P3/P4 if so)
- FCM HTTP v1 API called from Edge Function with notification payload

**Idle session notifications:**
- Level Up and Rare Drop notifications triggered by the idle calculation Edge Function
- After calculating gains: if player hasn't opened app in 2+ hours AND significant event occurred → dispatch notification
- "Significant event" threshold: level up OR rare material drop OR quest completion

**Batching logic:**
- Multiple same-type events within 1hr window → batch into single notification
- Batch counter stored in `player_notification_queue` table with expiry timestamp
- Edge Function checks queue before dispatching, merges pending same-type notifications

**Zone boss P1 expiry:**
- Boss spawn triggers immediate P1 notification
- Supabase stores `boss_spawn_time` + 10 min expiry
- If player opens app before expiry: suppress the notification via FCM cancel
- After expiry: notification becomes irrelevant but no cancellation needed (already delivered)

**Notification payload structure (FCM HTTP v1):**
```json
{
  "message": {
    "token": "player_fcm_token",
    "notification": {
      "title": "Aldric the Poacher King has appeared!",
      "body": "Grimwood Fringe, engage before it disappears"
    },
    "data": {
      "notification_type": "zone_boss",
      "zone_id": "grimwood_fringe",
      "boss_id": "aldric_poacher_king",
      "deep_link": "grimoire://combat/grimwood_fringe"
    },
    "android": {
      "priority": "high",
      "notification": { "channel_id": "combat_alerts" }
    },
    "apns": {
      "headers": { "apns-priority": "10" }
    }
  }
}
```

**Deep links:** Each notification includes a `deep_link` in the data payload, tapping the notification opens the relevant screen directly:
| Notification Type | Deep Link |
|------------------|-----------|
| Zone Boss | `grimoire://combat/{zone_id}` |
| Level Up | `grimoire://talents` |
| Rare Drop | `grimoire://inventory` |
| Quest Complete | `grimoire://quests` |
| Exchange Sale | `grimoire://exchange/my_listings` |
| Grimoire Cooldown | `grimoire://grimoire` |
| Dungeon Rotation | `grimoire://quests/slaying` |
| Guild Events | `grimoire://guild/bank` |

**Android notification channels:**
| Channel | Notifications | Default importance |
|---------|--------------|-------------------|
| `combat_alerts` | Zone boss, raid window | High (sound + vibrate) |
| `progression` | Level up, quest, rare drop | Default |
| `economy` | Exchange sale, buy order | Default |
| `guild` | All guild notifications | Low |
| `general` | Grimoire cooldown, rotation, reset | Low |

---

## In-Game Notice Board

A themed alternative to push notifications for non-urgent announcements. Fits the medieval fantasy world naturally, a physical board players check when they visit town.

**Access:** Small parchment/scroll icon in the main HUD, near the gear settings icon. Shows a red dot indicator when new notices are unread.

**What appears on the Notice Board:**
| Notice Type | Timing | Expires |
|-------------|--------|---------|
| Raid incoming, 14 day warning | 14 days before raid opens | When raid goes live |
| Raid incoming, 48 hour warning | 2 days before raid opens | When raid goes live |
| Dungeon rotation preview | 48hrs before monthly rotation changes | On rotation change |
| Guild Master announcements | When posted by Guild Master | 7 days or until dismissed |
| Patch notes / update summary | On app update | 14 days |
| Event announcements (future) | When event scheduled | On event start |
| Early Supporter Badge window closing | 7 days before window closes | When window closes |

**Notice Board UI:**
- Styled as a wooden board with parchment notices pinned to it, pixel art consistent with game world
- Each notice is a small pinned parchment card with title, body, and timestamp
- Tap a notice to expand full text
- Dismiss button on each notice, clears it from the board
- "Clear All" button at top
- Unread count shown on the HUD icon badge

**Technical notes:**
- Notices stored in a `game_notices` table in Supabase, global, not per-player
- Player's read/dismissed state stored in `player_notice_state` table
- New notices automatically appear on next app open
- No push notification sent for Notice Board updates, in-game only by design

---

*Document version 0.1, Push Notification Triggers & Notice Board*
*Next: Exchange unlock flow · Session 3 handoff*
