# Project Grimoire, Settings Screen
### Version 0.1

---

## Design Philosophy

Settings should be comprehensive enough to respect player preferences without being overwhelming. Every setting has a clear purpose, nothing is included just to look feature-rich. Mobile-first design: large tap targets, clear labels, instant feedback on toggle changes, no "save" button required.

---

## Access Point

Settings accessed via a **gear icon** in the top-right corner of the main HUD, always visible regardless of which screen the player is on. Tapping opens a bottom sheet or full screen overlay consistent with the pixel art UI style.

---

## Settings Categories & Options

### Audio

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Master Volume | Slider 0-100% | 80% | Controls all audio simultaneously |
| Music Volume | Slider 0-100% | 80% | Gathering, combat, menu tracks independently |
| Sound Effects Volume | Slider 0-100% | 80% | All in-world SFX (chops, splashes, tinks etc.) |
| UI Sounds Volume | Slider 0-100% | 70% | Button taps, level up chimes, Exchange sounds |
| Victory Stings | Toggle | On | Dungeon/raid completion stings only |
| Audio in Background | Toggle | Off | Whether music plays when app is backgrounded |

> All audio changes apply instantly, no save required. Player hears the effect immediately as they adjust sliders.

---

### Notifications

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| All Notifications | Master toggle | On | Disabling this overrides all below |
| Level Up | Toggle | On | When any Talent levels up during idle |
| Rare Drop | Toggle | On | When a rare material drops during idle |
| Zone Boss Spawned | Toggle | On | Boss appears, time-sensitive |
| Quest Complete | Toggle | On | Daily/weekly/Slaying task finished |
| Exchange Sale | Toggle | On | Your listing sold, marks collected |
| Exchange Buy Order | Toggle | On | Your Buy Order was fulfilled |
| Grimoire Cooldown | Toggle | On | 24hr swap cooldown expired |
| Guild Notifications | Toggle | On | General guild activity, bank deposits, material requests, bounties |
| Dungeon Rotation | Toggle | On | Monthly dungeon rotation changed |
| Raid Window | Toggle | On | Quarterly raid is now active |
| Daily Quest Reset | Toggle | Off | Midnight UTC board refresh |

> Guild chat notification preferences will live inside the chat UI when implemented in Phase 4, not in global settings.
> All notifications respect device-level Do Not Disturb, never override system preferences.

---

### Account

| Setting | Action | Notes |
|---------|--------|-------|
| Username | Display + Edit button | Edit costs 500 SM, 30-day cooldown |
| Email Address | Display (masked: d***@gmail.com) | Tap to change, requires current password |
| Change Password | Button | Prompts current + new password |
| Security Questions | Button | View/update recovery questions |
| Linked Devices | Display | Shows active sessions, tap to revoke |
| Log Out | Button | Confirmation dialog before logging out |
| Delete Account | Button (danger, bottom, red tint) | Requires typing "DELETE" + email verification. 30-day soft delete grace period |

---

### Display

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| UI Scale | Slider (Small / Medium / Large) | Medium | Adjusts text and panel sizes for readability |
| Show Damage Numbers | Toggle | On | Combat hit numbers floating above enemies |
| Show XP Notifications | Toggle | On | "+340 XP" toast on talent actions |
| Show Loot Toasts | Toggle | On | Item drop toasts during idle |
| Reduce Motion | Toggle | Off | Disables non-essential animations, Attunement pulse, menu transitions etc. |
| Show FPS Counter | Toggle | Off | Developer-friendly, hidden by default |
| Screen Brightness Lock | Toggle | Off | Keeps screen from dimming during active play sessions |
| Color Theme | Select | Dark (default) | Dark / Sepia / High Contrast, pixel art palette variants |

> Color Theme changes the entire UI palette, Dark is the default amber/black medieval feel, Sepia is warmer parchment tones, High Contrast improves readability for low vision players.

---

### Accessibility

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Large Text | Toggle | Off | Increases all text size beyond the Display UI Scale |
| Bold Text | Toggle | Off | Increases text weight throughout UI |
| Reduce Transparency | Toggle | Off | Removes UI transparency effects for clarity |
| Colorblind Mode | Select | Off | Deuteranopia / Protanopia / Tritanopia options, adjusts quality tier badge colors and combat indicators |
| Attunement Window Size | Slider (Small/Medium/Large) | Medium | Increases the tap target size of Attunement prompts for motor accessibility |
| Haptic Feedback | Toggle | On | Vibration on Attunement windows, boss spawns, rare drops |
| Screen Reader Support | Toggle | Off | Enables VoiceOver/TalkBack compatibility labels on all UI elements |

> Colorblind Mode requires separate color-safe sprite sets for quality tier badges, shape/pattern differentiation in addition to color changes so tiers are distinguishable without color alone.

---

### Privacy

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Analytics & Data Collection | Toggle | On | GameAnalytics behavioral data, can be disabled |
| Crash Reporting | Toggle | On | Automatic crash logs sent to development team |
| Personalized Royal Merchant | Toggle | On | Shows relevant purchase suggestions based on play behavior |
| Show Online Status | Toggle | On | Whether other players can see you as "Online" in guild roster and Exchange |
| Allow Friend Requests | Toggle | On | Whether other players can send friend requests |
| Allow Direct Item Sends | Toggle | On | Whether other players can send you items via Send to Player |
| Data Export | Button |, | Request a copy of all your personal data, delivered via email within 48hrs (GDPR compliance) |
| Privacy Policy | Link |, | Opens in-app browser to refugeswordpublishing.com/privacy |
| Terms of Service | Link |, | Opens in-app browser to refugeswordpublishing.com/terms |

> Analytics toggle is required for GDPR/CCPA compliance, players in EU/California must be able to opt out.
> Data Export is a GDPR requirement, must be implemented before EU launch.
> Show Online Status off = appears as offline to all other players including guild members.

---

## Settings UI Structure

```
[Gear Icon] → Opens Settings Screen

Settings
├── Audio
│   ├── Master Volume ████████░░ 80%
│   ├── Music         ████████░░ 80%
│   ├── Sound Effects ████████░░ 80%
│   ├── UI Sounds     ███████░░░ 70%
│   ├── Victory Stings    [ON]
│   └── Audio in Background [OFF]
│
├── Notifications
│   ├── All Notifications  [ON]
│   ├── Level Up           [ON]
│   ├── Rare Drop          [ON]
│   ├── Zone Boss          [ON]
│   ├── Quest Complete     [ON]
│   ├── Exchange Sale      [ON]
│   ├── Exchange Buy Order [ON]
│   ├── Grimoire Cooldown  [ON]
│   ├── Guild Notifications [ON]
│   ├── Dungeon Rotation   [ON]
│   ├── Raid Window        [ON]
│   └── Daily Quest Reset  [OFF]
│
├── Account
│   ├── Username: Dustin_SW  [Edit]
│   ├── Email: d***@gmail.com [Change]
│   ├── Change Password
│   ├── Security Questions
│   ├── Linked Devices
│   ├── Log Out
│   └── Delete Account (danger)
│
├── Display
│   ├── UI Scale        [S · M · L]
│   ├── Damage Numbers     [ON]
│   ├── XP Notifications   [ON]
│   ├── Loot Toasts        [ON]
│   ├── Reduce Motion      [OFF]
│   ├── FPS Counter        [OFF]
│   ├── Screen Brightness Lock [OFF]
│   └── Color Theme [Dark · Sepia · High Contrast]
│
├── Accessibility
│   ├── Large Text         [OFF]
│   ├── Bold Text          [OFF]
│   ├── Reduce Transparency [OFF]
│   ├── Colorblind Mode    [Off · Deut · Prot · Trit]
│   ├── Attunement Size    [S · M · L]
│   ├── Haptic Feedback    [ON]
│   └── Screen Reader      [OFF]
│
└── Privacy
    ├── Analytics          [ON]
    ├── Crash Reporting    [ON]
    ├── Personalized Merchant [ON]
    ├── Show Online Status [ON]
    ├── Allow Friend Requests [ON]
    ├── Allow Item Sends   [ON]
    ├── Request Data Export →
    ├── Privacy Policy →
    └── Terms of Service →
```

---

## Technical Notes for Implementation

**Storage:**
- All settings stored in Supabase `player_settings` table, syncs across devices
- Local cache of settings applied on app open before server sync completes, prevents flash of wrong settings
- Settings changes write to Supabase immediately on toggle/slider release

**Audio:**
- Volume sliders feed directly into Unity's Audio Mixer group volumes
- Changes apply in real-time as slider moves, player hears immediate feedback
- `Audio in Background` setting hooks into Unity's `Application.focusChanged` event

**Notifications:**
- Individual notification toggles stored as separate boolean columns in `player_settings`
- FCM notification dispatch checks player preferences server-side before sending, never sends a notification the player has disabled
- `All Notifications` master toggle: when disabled, FCM token is unregistered entirely from the device

**Display:**
- `Reduce Motion` disables particle systems and tween animations globally via a static flag checked by AnimationManager
- `Color Theme` switches between Unity UI Material palettes, store theme selection in PlayerPrefs as backup in case Supabase is unreachable on first load
- `Screen Brightness Lock` uses `Screen.sleepTimeout = SleepTimeout.NeverSleep` when enabled

**Accessibility:**
- `Colorblind Mode` swaps quality tier badge color assets at runtime, requires separate color-safe badge sprite sets per mode with shape/pattern differentiation, not color alone
- `Attunement Window Size` increases the tap target collision area of Attunement prompts, stored as a scale multiplier in player settings
- `Screen Reader` toggle enables Unity Accessibility Plugin labels on all interactive UI elements

**Privacy:**
- Analytics toggle calls `GameAnalytics.setEnabledInfoLog(false)` and stops event dispatch when disabled
- Data Export triggers a Supabase Edge Function that compiles player data and sends via email, 48hr SLA
- GDPR/CCPA: analytics consent must be obtained at first launch before any analytics events fire, implement consent banner on first open in EU/California regions

---

*Document version 0.1, Settings Screen*
*Next: Push notification triggers · Exchange unlock flow · Session 3 handoff*
