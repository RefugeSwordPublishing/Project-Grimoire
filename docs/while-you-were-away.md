# Project Grimoire, While You Were Away Screen
### Version 0.1

---

## Design Philosophy

The WYWA screen is the emotional payoff for every idle session. It should feel like opening a chest, rewarding, quick to read, and never overwhelming. Players who were away for 5 minutes and players who were away for 8 hours both see a screen that feels proportional to their time away.

**Core principles:**
- Auto-collected, everything is already in inventory when the screen appears
- Highlights first, level ups, rare drops, and notable events lead the screen
- Common gains summarized, not listed individually, grouped by Talent
- Quick to dismiss, one tap closes it, no friction between the player and the game
- Proportional feel, short sessions show less, long sessions show more but never overwhelming

---

## Screen Structure

```
┌─────────────────────────────────────┐
│  WHILE YOU WERE AWAY                │
│  2 hours · 34 minutes              │
├─────────────────────────────────────┤
│  HIGHLIGHTS                       │
│  [Notable events, level ups,       │
│   rare drops, boss spawns missed]   │
├─────────────────────────────────────┤
│  GAINS SUMMARY                   │
│  [Per-Talent grouped summary        │
│   of common resource gains]         │
├─────────────────────────────────────┤
│  COMBAT                           │
│  [Kills, marks earned, zone info]   │
├─────────────────────────────────────┤
│        [ CONTINUE ]                 │
└─────────────────────────────────────┘
```

---

## Highlights Section

Always appears at the top. Only populated with genuinely notable events, not routine gains. If nothing notable happened the section is hidden entirely rather than showing "No highlights."

**Events that qualify as highlights:**

| Event | Display |
|-------|---------|
| Talent level up | Foraging reached level 35 |
| Multiple level ups | 3 Talents leveled up, tap to see |
| Rare material drop | ◆ Crude Amber dropped from Felling |
| Very rare material drop | ◆◆ Rough Gemstone dropped, rare find |
| Quest completed during idle | Daily quest complete, Harvest 20 Crops |
| Zone boss spawned and despawned | Aldric the Poacher King appeared and left, engage next time |
| Grimoire cooldown expired | Grimoire swap is available |
| Grand Exchange sale completed | ◈ Iron Bar listing sold, +1,240 SM |
| Buy Order filled | ◈ Wolf Pelt Buy Order fulfilled, +380 SM |
| Dungeon rotation changed | New dungeons available this month |
| Raid window opened | Quarterly raid is now active |

**Highlight display rules:**
- Maximum 5 highlights shown, if more occurred, shows top 5 by rarity/importance with "and X more" link
- Rare material drops always shown regardless of limit
- Level ups consolidated, "3 Talents leveled up" not three separate lines
- Boss spawn warning always shown, motivates active play next session
- Exchange sales always shown, reinforces economy engagement

---

## Gains Summary Section

Grouped by Talent category, not individual resources. Common resources summarized as totals, not line-by-line.

**Format per active Talent:**
```
Foraging          Lv 34 → 35  ↑
   +47 resources · +1,240 XP
   
Felling           Lv 21
   +23 resources · +680 XP

Delving           Lv 28
   +31 resources · +890 XP
```

**Rules:**
- Resources shown as total count, "+47 resources" not "+23 Common Herb +12 Ironwort +8 Shadowleaf +4 Goldmoss"
- Player can tap a Talent row to expand full resource breakdown if they want detail
- Level up shown inline with an up arrow, draws attention without separate callout
- XP shown as raw number, lets players gauge idle efficiency
- Talents that produced nothing (queue was empty or disabled) are hidden

**Expanded view (tap to open):**
```
Foraging, tap to expand
   +23 Common Herb
   +12 Ironwort
   +8  Shadowleaf
   +4  Goldmoss
   +1,240 XP gained
   Current: 67% to level 36
```

---

## Combat Section

Only shown if Marksmanship or Slaying was in the idle queue.

```
Combat, Grimwood Fringe
   18 Grimwood Brigands defeated
   +760 Silver Marks
   +340 Slaying XP
   Marksmanship Lv 31 → 32 ↑
```

**Rules:**
- Enemy type shown, confirms player's target selection is working
- Marks earned shown as a total
- Level ups shown inline
- If a rare drop occurred in combat it appears in Highlights, not here

---

## ⏱ Time Away Display

Shows at the top of the screen. Tone adjusts based on duration:

| Away Duration | Display | Tone |
|--------------|---------|------|
| Under 30 min | "30 minutes" | Neutral |
| 30 min - 4 hrs | "2 hours · 34 minutes" | Neutral |
| 4-12 hrs | "8 hours away, good progress" | Encouraging |
| 12-24 hrs | "A full day's work done for you" | Satisfying |
| 24-48 hrs | "Two days of gains waiting" | Rewarding |
| 48+ hrs | "A long journey. Much was gathered." | Epic |

The tone shift is subtle, just the secondary line changes. Never guilt-trips for being away long, never dismisses short sessions as trivial.

---

## Efficiency Note (optional, dismissible)

For sessions longer than 8 hours, a small note appears below the gains summary, once per week maximum so it doesn't feel nagging:

> *"Idle gains are capped after 24 hours, active play keeps your queue fresh."*

This gently educates players about the idle cap without being punishing. Only shows if the player was actually close to or over the cap. Never shows for short sessions.

---

## Notification That Brings Players Back

The push notification that fires during idle should match what the WYWA screen will show. Notification tiers:

| Condition | Notification |
|-----------|-------------|
| Level up occurred | "Foraging reached level 35, check your new unlocks" |
| Rare drop occurred | "A rare material dropped while you were away" |
| Quest completed | "Your daily quest is complete, new rewards waiting" |
| Zone boss spawned | "A zone boss appeared in Grimwood Fringe, engage now" |
| Exchange sale | "Your Exchange listing sold, marks collected" |
| Standard idle | "Your idle queue has been running, check your gains" |
| Grimoire ready | "Your Grimoire swap cooldown has expired" |

Notifications are prioritized, if multiple conditions are true, the highest priority fires (rare drop > level up > quest > boss > sale > standard).

---

## Visual Design Notes

Pixel art aesthetic consistent with rest of UI:

- **Background:** Dark parchment panel, same as main UI panels
- **Highlight items:** Gold accent color for rare drops, green for level ups, amber for warnings
- **Gains rows:** Standard bone text, XP in dimmer tone
- **Level up indicator:** Small upward arrow in green next to Talent name
- **Continue button:** Full width, gold border, prominent, easy to tap on mobile
- **Animation:** Resources don't animate in one by one, screen appears fully formed. Speed is the priority. Optional: brief golden shimmer on rare drop entries only

---

## Technical Notes for Implementation

- WYWA screen calculates gains server-side in Supabase Edge Functions, client receives pre-calculated summary JSON on app open
- All resources already written to player inventory before WYWA screen renders, truly auto-collected
- Summary JSON structure:
```json
{
  "away_duration_seconds": 9240,
  "highlights": [
    { "type": "level_up", "talent": "Foraging", "old_level": 34, "new_level": 35 },
    { "type": "rare_drop", "item": "Crude Amber", "rarity": "T1" }
  ],
  "talent_gains": [
    { "talent": "Foraging", "xp": 1240, "resources_total": 47, "resources_detail": [...], "leveled_up": true },
    { "talent": "Felling", "xp": 680, "resources_total": 23, "leveled_up": false }
  ],
  "combat_gains": {
    "zone": "Grimwood Fringe",
    "enemy": "Grimwood Brigand",
    "kills": 18,
    "marks": 760,
    "xp": 340,
    "leveled_up": true,
    "talent": "Marksmanship",
    "new_level": 32
  },
  "exchange_gains": [
    { "type": "sale", "item": "Iron Bar", "marks": 1240 }
  ]
}
```
- Idle cap: 24 hours maximum accumulation, server stops calculating gains after 24hrs away
- Edge Function runs on app open, not continuously, calculates the delta between last session timestamp and current time
- If server is unreachable on app open, show cached last-known gains with a "syncing..." indicator

---

*Document version 0.1, While You Were Away Screen*
*Next: Monetization scope · Main design doc cleanup · Session 2 handoff*
