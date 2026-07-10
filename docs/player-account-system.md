# ⚔️ Project Grimoire — Player Account System
### Version 0.1

---

## 📐 Design Philosophy

One account, one character — everything on it. Progress lives authoritatively on Supabase with local caching for smooth UI performance. Idle calculations always server-side to prevent clock manipulation cheating. The account system should be as frictionless as possible — players want to get into the game, not wrestle with login flows.

---

## 🔐 Authentication

### Login Method
**Email + password only** via Supabase Auth.

Email is used **only for authentication** — it is never visible to other players in game. All in-game identification uses the player's chosen **username**. Players should understand clearly at registration that their email is private and their username is their public identity.

No social login (Google/Apple) at launch — simplifies implementation. Can be added post-launch if demand warrants it.

### Username vs Email
| Field | Visible to others | Used for login | Notes |
|-------|------------------|----------------|-------|
| **Email** | Never | Yes — login only | Private, never shown in game |
| **Username** | Always | No | Shown in chat, Exchange, guild roster, leaderboards |

### Account Creation Flow
1. Player opens app for the first time
2. **Welcome screen** — two options: "Create Account" or "Log In"
3. **Create Account:**
   - Email address field
   - Username field (3–20 characters, alphanumeric + underscores only)
   - Password field (min 8 characters, must contain a number)
   - Confirm password field
   - Security questions — choose 2 from preset list, enter answers (used for account recovery if email is lost)
   - "Create Account" button
   - Username checked against profanity filter AND uniqueness before submission accepted
   - On success → immediately enters onboarding flow
   - On failure → inline error message, no screen change
4. **Log In:**
   - Email field (not username — login is always by email)
   - Password field
   - "Log In" button
   - "Forgot password?" link
   - On success → loads player data, shows WYWA screen if returning player

### Username Moderation — Three Layer System

**Layer 1 — Automated filter at registration (always on)**
- Username checked against a server-side profanity and slur blocklist before acceptance
- Blocklist maintained as a Supabase Edge Function — updateable without app update
- Covers l33t speak and common character substitutions (@ for a, 0 for o, $ for s etc.)
- Base blocklist: open-source bad-words package (~1,400 terms) + game-specific additions
- Blocklist never exposed publicly — prevents deliberate bypass attempts
- Response to player: "This username is not available. Please choose another." (no explanation of why)

**Layer 2 — Player reporting (Phase 4 — multiplayer)**
- Any player can report a username from their profile card in game
- 3 reports on the same username within 7 days triggers automatic review flag
- Reports go to a moderation queue

**Layer 3 — Manual review + forced rename**
- Moderation team reviews flagged names
- Forced rename: player notified "Your username violated community guidelines" — assigned temp name until they choose a new one
- Repeat offenders: escalating action (warning → temp suspension → permanent ban)

> Layer 1 active at launch. Layers 2 and 3 activated at Phase 4 multiplayer launch when player interaction increases.

### Password Reset
- "Forgot password?" on login screen
- Enter email → Supabase sends reset link (expires in 1 hour)
- Reset link opens in-app via deep link
- Player sets new password → auto-logged in
- Old sessions invalidated on password reset

### Account Recovery (lost email access)
- Support ticket system (email to support address)
- Player provides: registered email, username, account creation date (approximate), security question answers
- Support verifies answers (stored as hashes — team verifies match without seeing plaintext)
- On successful verification: email updated to new address, password reset link sent

**Security questions — preset list (player chooses 2 at registration):**
- "What was the name of your first pet?"
- "What city were you born in?"
- "What was the name of your primary school?"
- "What is your oldest sibling's middle name?"
- "What was the make of your first car?"
- "What was the name of the street you grew up on?"

Answers stored as bcrypt hashes — same security as passwords.

### Session Persistence
- Auth token stored securely (iOS Keychain / Android Keystore)
- Token auto-refreshes — player stays logged in indefinitely unless they explicitly log out
- On app open: validate token silently while loading cached data — no login screen for returning players
- If token invalid/expired: login screen with "Session expired — please log in again"

### Account Security
- Email verification required — unverified accounts can play but see a persistent banner prompt
- Rate limiting: 5 failed login attempts → 10-minute lockout
- Password stored as bcrypt hash via Supabase Auth — never plaintext
- Row Level Security on all Supabase tables — players can only read/write their own rows

---

## 👤 Player Profile

### Username
- Set during account creation
- 3–20 characters, alphanumeric + underscores only
- Unique across all players — enforced via UNIQUE constraint
- Can be changed once every 30 days (prevents cycling to dodge reputation)
- Shown in: chat, guild roster, Exchange listings, leaderboards, profile cards
- Change costs 500 SM — small friction to discourage casual changes

### Player ID
- Internal UUID generated at account creation — never shown to players
- Used for all database references — username changes don't break any links

### Avatar / Portrait
- Default portrait assigned at account creation based on equipped Grimoire path
- Portrait frame cosmetic applied on top — purchased from Royal Merchant
- No custom image uploads — keeps moderation simple at launch

---

## 💾 Data Architecture

### Data Layers

| Layer | What it holds | Updated when |
|-------|-------------|-------------|
| **Supabase (authoritative)** | All player progress, inventory, marks, talent levels, Grimoire state, guild membership | On every meaningful action |
| **Local cache** | Last-known state of inventory, talents, marks, active buffs | Updated on sync, persists between sessions |
| **Session memory** | Current UI state, active combat, ongoing attunement window | Cleared on app close |

### Supabase Table Structure

**players**
```
id                      UUID (PK) — Supabase Auth user ID
email                   TEXT (from Auth — never shown in game)
username                TEXT UNIQUE — in-game identity, shown to other players
username_changed_at     TIMESTAMP — enforces 30-day change cooldown
security_question_1     TEXT — preset question ID
security_answer_1       TEXT — bcrypt hashed answer
security_question_2     TEXT — preset question ID
security_answer_2       TEXT — bcrypt hashed answer
created_at              TIMESTAMP
last_active             TIMESTAMP
onboarding_complete     BOOLEAN
onboarding_step         INTEGER
grimoire_equipped       TEXT (grimoire_id)
grimoire_swapped_at     TIMESTAMP (for 24hr cooldown)
deleted_at              TIMESTAMP (null = active, set = soft deleted)
```

**player_stats**
```
player_id     UUID (FK → players.id)
str           INTEGER
dex           INTEGER
vit           INTEGER
int           INTEGER
wil           INTEGER
lck           INTEGER
cha           INTEGER
max_hp        INTEGER
current_hp    INTEGER
```

**player_talents**
```
player_id     UUID (FK)
talent_id     TEXT (e.g. "foraging", "marksmanship")
level         INTEGER
current_xp    INTEGER
is_idle       BOOLEAN
idle_activity TEXT (what the talent is currently doing)
assigned_at   TIMESTAMP (when idle was started)
```

**player_inventory**
```
player_id         UUID (FK)
item_id           TEXT
quantity          INTEGER
slot_position     INTEGER
is_locked         BOOLEAN
placeholder_label TEXT
```

**player_currency**
```
player_id       UUID (FK)
silver_marks    INTEGER
gold_marks      INTEGER
updated_at      TIMESTAMP
```

**player_grimoires**
```
player_id     UUID (FK)
grimoire_id   TEXT
unlocked_at   TIMESTAMP
```

**player_active_buffs**
```
player_id     UUID (FK)
buff_id       TEXT
buff_type     TEXT
value         FLOAT
expires_at    TIMESTAMP
source        TEXT (e.g. "cookery_venison_stew")
```

**player_settings**
```
player_id               UUID (FK)
music_enabled           BOOLEAN DEFAULT true
sfx_enabled             BOOLEAN DEFAULT true
ui_sounds_enabled       BOOLEAN DEFAULT true
notifications_enabled   BOOLEAN DEFAULT true
notification_idle       BOOLEAN DEFAULT true
notification_levelup    BOOLEAN DEFAULT true
notification_raredrop   BOOLEAN DEFAULT true
notification_boss       BOOLEAN DEFAULT true
notification_quest      BOOLEAN DEFAULT true
notification_exchange   BOOLEAN DEFAULT true
```

**player_slaying_tasks**
```
player_id       UUID (FK)
task_id         TEXT
task_type       TEXT
description     TEXT
target_count    INTEGER
current_count   INTEGER
tier            INTEGER
accepted_at     TIMESTAMP
completed_at    TIMESTAMP (null if incomplete)
reward_marks    INTEGER
reward_material TEXT
```

---

## 🔄 Sync Strategy

### On App Open
1. Validate auth token silently
2. Load local cache immediately — player sees their last known state within <1 second
3. Request full sync from Supabase in background
4. Apply server state to UI — if server differs from cache, update smoothly (no jarring reload)
5. Calculate idle gains since `last_active` via Edge Function
6. Show WYWA screen with calculated gains

### During Active Play
- **Inventory changes:** Write to Supabase immediately, update local cache
- **Currency changes:** Write immediately — marks are sensitive
- **Talent XP:** Write every 30 seconds during active session + on app background/close
- **Active buffs:** Write immediately on application or expiry
- **Settings:** Write immediately on change

### On App Background/Close
- Flush any pending Talent XP writes
- Write `last_active` timestamp to Supabase — this is what idle calculation uses
- Cache current state locally

### Conflict Resolution
Server is always authoritative. If local cache and server disagree:
- Take server value for all currency and inventory (prevents duplication exploits)
- Take higher XP value for Talents (prevents XP loss from sync issues)
- Log conflict for analytics review

---

## 🖥️ Account UI

### Account Screen (accessible from Settings)
- Display name (with edit button if 30-day cooldown has passed)
- Email address (read-only)
- Account created date
- Change password button → prompts current password + new password
- Log out button → confirmation dialog ("Logging out will require your email and password to log back in. Continue?")
- Delete account button → tucked at bottom, requires typing "DELETE" to confirm, sends verification email before processing
- **Soft delete — 30 day grace period:** Account marked `deleted_at` but data retained for 30 days. Player receives confirmation email with "Restore my account" link valid for 30 days. After 30 days a scheduled Edge Function purges all player data permanently. Covers accidental deletion and rage-quit scenarios.

### Login/Registration Screen Design
- Minimal and fast — players want to get in, not look at login screens
- Project Grimoire logo at top
- Clean dark background consistent with in-game UI palette
- No marketing copy — just the essential fields
- "Create Account" and "Log In" are equal prominence — neither is the CTA over the other

---

## 🔧 Technical Notes for Implementation

- Supabase Auth handles all email/password management — do not implement custom auth
- Use Supabase JS SDK or REST API from Unity via BackendManager.cs
- JWT stored in PlayerPrefs encrypted on mobile (use Unity's built-in secure storage or a plugin like SecurePlayerPrefs)
- Local cache: serialize player state to JSON, store in Application.persistentDataPath — not PlayerPrefs (too small for full inventory)
- Idle calculation Edge Function: receives `player_id` and `current_timestamp`, reads `last_active` and all idle talent assignments, calculates gains, writes to inventory and XP tables, returns summary for WYWA screen
- Edge Function must be called server-side — never trust client-reported idle time
- `grimoire_swapped_at` field enables 24hr cooldown check server-side — client cannot bypass
- Row Level Security (RLS) on all Supabase tables: players can only read/write their own rows
- Username uniqueness enforced via UNIQUE constraint on `players.username` — handle conflict gracefully in UI
- `player_id` in all child tables is the Supabase Auth `user.id` — no separate player ID needed
- Profanity filter runs as a Supabase Edge Function — call before writing username to DB
- Security question answers stored as bcrypt hashes in `players` table — never retrievable in plaintext
- Soft delete: `deleted_at` field set on deletion request, scheduled Edge Function purges after 30 days
- Username change costs 500 SM — deduct from `player_currency` in same transaction as username update

### ⚠️ Row Level Security — Required on ALL Tables
RLS must be enabled on every Supabase table. Without it anyone with the project URL can read, edit, and delete all player data.

Enable RLS and add policies on every table:
```sql
-- Enable RLS
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_talents ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_currency ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_grimoires ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_active_buffs ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_slaying_tasks ENABLE ROW LEVEL SECURITY;

-- Players can only access their own rows
CREATE POLICY "Players can read own data" ON players
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Players can update own data" ON players
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Players can read own stats" ON player_stats
  FOR SELECT USING (auth.uid() = player_id);
CREATE POLICY "Players can update own stats" ON player_stats
  FOR UPDATE USING (auth.uid() = player_id);
-- Repeat pattern for all tables using player_id as the FK
```

**Key rule:** Every new table created must have RLS enabled and appropriate policies added immediately — never create a table and leave RLS disabled.

**Edge Functions** use the service role key which bypasses RLS by design — that's correct and intentional for server-side operations. `BackendManager.cs` must use the **anon key** for all player-facing client calls.

---

*Document version 0.2 — Player Account System*
*Next: Settings screen · Push notification triggers · Exchange unlock flow · Session 3 handoff*
