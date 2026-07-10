# ⚔️ Project Grimoire — Guild Hall UI Specification
### Version 0.1

---

## 📐 Design Philosophy

The Guild Hall should feel like a living place — not a menu screen. The background art evolves with Prestige, announcements appear as signpost notices in the scene, and material requests look like a medieval tavern quest board. Every interaction is grounded in the world rather than feeling like a generic app UI.

---

## 🏠 Guild Discovery Screen (No Guild)

Players not in a guild see this screen when tapping the Guild nav icon.

**Background:** A warm medieval tavern interior — pixel art, candlelit, patrons visible. Sets the tone before joining.

**Layout:**
```
┌─────────────────────────────────┐
│  [Tavern background art]        │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🔍 Search guilds...     │   │
│  └─────────────────────────┘   │
│                                 │
│  Filter: [All] [Casual] [Serious]│
│                                 │
│  ┌─ Guild Card ──────────────┐  │
│  │ Refuge Sword              │  │
│  │ Prestige 5 · 18/30 members│  │
│  │ "Crafters welcome"        │  │
│  │ [Open]        [Apply →]   │  │
│  └───────────────────────────┘  │
│  ┌─ Guild Card ──────────────┐  │
│  │ Ironspire Collective      │  │
│  │ Prestige 12 · 28/30 members│ │
│  │ "Serious raiders only"    │  │
│  │ [Invite Only] [Request →] │  │
│  └───────────────────────────┘  │
│                                 │
│  ─── or ───                     │
│                                 │
│  [ + Create a Guild — 2,000 GM ]│
└─────────────────────────────────┘
```

**Guild Cards show:**
- Guild name + emblem
- Prestige level + Hub visual stage name
- Current member count / cap
- Short description (set by Guild Master, 80 char max)
- Join policy badge — [Open] / [Invite Only]
- Action button — [Apply →] for Open, [Request →] for Invite Only

**Filters:**
- All / Casual / Serious — set in guild settings by Guild Master
- Closed guilds (invite only with no public listing) do not appear

**Search:**
- Search by guild name — live filter as player types
- Results update immediately

**Guild creation:**
- Tapping "+ Create a Guild" opens the creation flow (see below)

---

## 🏗️ Guild Creation Flow

1. **Cost confirmation:** "Creating a guild costs 2,000 GM. You have X GM. Continue?"
2. **Guild name:** Text field — 3–30 characters, profanity filtered, unique check
3. **Guild description:** 80 character max — shown on discovery screen
4. **Join policy:** Open / Invite Only / Closed (closed = members only, not discoverable)
5. **Guild type:** Casual / Serious — shown as filter tag on discovery screen
6. **Confirm:** "Found [Guild Name]" — deducts 2,000 GM, creates guild, player becomes Guild Master

On creation: player lands directly on the Guild Home screen with a brief welcome tooltip: *"Welcome to your new guild. Invite members from the Roster tab."*

---

## 🏰 Guild Home Screen (Member View)

### Background Art — Prestige Progression
The entire Guild Home screen background is the Guild Hub art stage, evolving with Prestige level. This is what members see every time they open the guild — the visual proof of the guild's history and investment.

| Prestige | Hub Visual |
|----------|-----------|
| 0–4 | Campfire Gathering — handful of people, modest fire |
| 5–9 | Tent Camp — several tents, growing community |
| 10–19 | Encampment — organized camp, banners, supply carts |
| 20–34 | Army Encampment — fortified camp, watchtowers |
| 35–49 | Fortress — stone walls, gate, defensive structure |
| 50–74 | Castle — full castle, flags, guards |
| 75–99 | Castle with Village — castle + surrounding village |
| 100+ | Stronghold Capital — sprawling fortified capital |

Background art is a full-screen pixel art scene. UI elements overlay on top as world-consistent objects (signpost, quest board) rather than floating panels.

### Navigation Tabs
Bottom navigation row — always visible on Guild Home:

```
[ Home ] [ Roster ] [ Bank ] [ Upgrades* ] [ Settings* ]
```

*Upgrades and Settings tabs only visible to Officers and Guild Master.

### Signpost — Guild Announcement (MOTD)
A wooden signpost visible in the background art scene — positioned naturally in the scene (next to the campfire at low Prestige, mounted on a castle wall at high Prestige).

Tapping the signpost opens the full announcement text.
The signpost shows the first 60 characters of the current announcement as visible text on the sign itself — readable without tapping.

If no announcement is set: signpost shows "No notices posted." in a weathered style.

**Posting announcements:**
- Guild Master only
- Tap the signpost → "Edit Announcement" button appears for Guild Master
- 280 character limit
- Previous announcement replaced (no history — latest only)
- Members get a Guild Notification push when announcement is updated

### Quest Board — Material Requests & Guild Merchant
A medieval parchment notice board visible in the scene — positioned near the signpost. Looks like the Notice Board from the main game but guild-specific.

**Two types of notices on the board:**

**1. Material Requests (Officer/Guild Master posted)**
Officers request materials for guild upgrades or bounties:
```
┌─ MATERIAL REQUEST ────────────┐
│ Posted by: GuildMaster_DS     │
│ Iron Bar × 500               │
│ Purpose: Roster Tier 2        │
│ Progress: ███░░░ 234/500      │
│ [ Donate from Inventory ]     │
└───────────────────────────────┘
```
- Any member can tap "Donate from Inventory" to contribute
- Progress bar updates in real-time
- Completed requests show green checkmark and stay visible for 24hrs then auto-remove
- Multiple requests can be active simultaneously

**2. Guild Merchant Listings**
Any member can post items for sale at guild-preferential rates:
```
┌─ GUILD MERCHANT ─────────────┐
│ Iron Bar × 240               │
│ 35 SM each (Exchange: 42 SM) │
│ Posted by: CrafterJane       │
│ [ Buy — Guild Members Only ] │
└───────────────────────────────┘
```
- **Guild members only** — not visible to allied guilds or the public. Keeping it exclusive prevents it from making the Wayfarer's Exchange redundant
- **Listing fee: half the guild's voted tax rate** — goes to guild bank (e.g. 3% guild tax → 1.5% internal rate, 2% guild tax → 1% internal rate, 0% → 0%). Always cheaper than external Exchange for guild members
- **Better sale price** — sellers set their own price, encouraged below Exchange rate. Social contract — guild culture determines norms
- No enforcement on pricing — competitive pressure within the guild keeps rates honest
- Listings expire after 7 days if unsold — returned to seller's inventory
- Items transfer via the Send to Player system on purchase

### Active Guild Buffs
Small buff icon row displayed below the quest board — same style as the player buff HUD:
```
[ Prospector's Fortune 18h ] [ Bountiful Harvest 6h ]
```
Tap any buff to see details and time remaining.

### Guild Stats (bottom of screen, below nav)
Small persistent stats row:
```
Bank: 12,840 GM  ·  Tax: 3%  ·  Prestige: 7  ·  Members: 18/30
```

---

## 👥 Roster Tab

### Member List
Scrollable list of all guild members:
```
┌─ Member ──────────────────────────┐
│ 👑 GuildMaster_DS    Last: Now    │
│    Contributed: 48,200 GM         │
│    Role: Guild Master             │
├───────────────────────────────────┤
│ ⚔ Officer_Jane       Last: 2h ago │
│    Contributed: 12,800 GM         │
│    Role: Officer          [...]   │
├───────────────────────────────────┤
│ · CrafterMark         Last: 1d ago│
│    Contributed: 3,200 GM          │
│    Role: Member           [...]   │
└───────────────────────────────────┘
```

**Sort options:** By contribution (default), by last active, by role, by name

**Tapping [...] on a member (Officer/GM only):**
- Promote to Officer
- Demote to Member
- Kick from guild (confirmation required)
- View profile

### Invite System (Officer/GM only)
Invite button visible at top of Roster tab for Officers and Guild Master only:
- **Open guild:** "Invite Player" — search by username, sends invite notification
- **Invite Only:** Same invite flow, PLUS a "Join Requests" section showing pending applications from the discovery screen. Officers can Approve or Decline each request.
- **Closed guild:** Invite only — no discovery listing, no join requests

---

## 🏦 Bank Tab

### Balance Display
```
Guild Bank Balance: 12,840 GM · 284,200 SM
```

### Donation Section (all members)
- "Donate Marks" — Silver or Gold Mark donation from player currency
- "Donate Materials" — opens inventory filtered to donatable items, tap to donate
- Recent donations log (last 10 transactions, visible to all)

### Consumable Buffs (Officer/GM only)
Grid of available buffs to purchase and activate:
```
┌─ Prospector's Fortune ────────┐
│ +15% rare drop chance         │
│ Duration: 24 hours            │
│ Cost: 3,000 GM + 20 Crude Amber│
│ [ Activate ]                  │
└───────────────────────────────┘
```
- Shows cost in both GM and required materials
- Materials pulled from guild bank inventory
- Confirmation dialog before activation
- "Already active" state shown with time remaining

### Bank Inventory
Below the marks balance — the guild's material storage:
- Same slot system as personal inventory (50 slots base, expandable)
- Category filter tabs same as personal inventory
- Officers and GM can withdraw — tap item → "Withdraw X" dialog
- All members can view (transparency)

---

## ⚔️ Upgrades Tab (Officer/GM only)

### Roster Tier Upgrades
Current tier shown prominently, next tier details below:

```
Current Tier: 2 — 30 Members
─────────────────────────────
Next: Tier 3 — 45 Members
Cost: 35,000 GM
Materials needed:
  · Steel Bar × 500        [Bank: 234/500 ⚠]
  · Fine Leather × 200     [Bank: 200/200 ✓]
  · Refined Gemstone × 50  [Bank: 12/50 ⚠]

[ Purchase Upgrade ] (grayed — insufficient materials)
```

- Materials sourced from guild bank — shows current stock vs required
- Red/amber warning if materials insufficient
- Button only active when both GM and all materials are available
- Confirmation dialog showing full cost before proceeding

### Permanent Unlocks
Other permanent upgrades below the tier section:
- Bank slot expansions
- Alliance unlock (Tier 6)

### Guild Bounties (Deferred — Future Content)
Bounty activation will live in this tab when released. A dedicated section below permanent unlocks showing available bounties, activation cost, and collective goal. Deferred to post-launch content update — guilds need time to establish before bounty coordination becomes meaningful.

---

## ⚙️ Settings Tab (Officer/GM only)

### Guild Info
- Guild name (GM only — edit)
- Guild description (GM only — edit)
- Guild emblem (GM only — change)
- Guild type: Casual / Serious (GM only)
- Join policy: Open / Invite Only / Closed (GM only)

### Tax Rate
```
Current Tax Rate: 3%
Last changed: 14 days ago
Next change eligible: In 16 days

[ Initiate Tax Vote ]
```

**Tax vote flow:**
- Either GM or any Officer can initiate
- Vote open for 48 hours — GM + all Officers vote
- Majority required to pass
- If passed: new rate takes effect 48 hours after vote closes
- Tax rate can only be changed once every **30 days** — prevents weekly manipulation while allowing monthly correction if needed
- Pending vote shown here with current tally and time remaining

### Danger Zone (GM only)
- Transfer Guild Master role to another member
- Disband guild — requires typing guild name to confirm, 7-day grace period before data deleted

---

## 🎵 Adaptive Music System — Phase 2 Audio Goal

The guild hall will use a **layered stem system** — one master composition with individual instrument stems that fade in and out based on which tab is active.

**Concept:**
- Base layer: always playing — soft ambient pad, low rhythm
- Guild Home: lute/acoustic melody joins
- Roster tab: subtle social percussion layer
- Bank tab: coin percussion, busier feel
- Upgrades tab: slight tension layer — important decisions
- Settings tab: quieter, administrative feel

**Production requirement:**
This cannot be achieved with Suno-generated complete tracks — requires a composer to export individual stems from a multi-track session. Planned as a Phase 2 audio commission once the game has revenue to support it.

**Phase 1/2 interim:** Single guild music track (same Moonlit Caravan or a guild-specific variant) plays throughout all Guild Hall tabs until stems are commissioned.

**Implementation:** Unity Audio Mixer with multiple channels — each stem on its own channel, crossfaded by GuildAudioManager based on `OnTabChanged` events.

---

## 🔧 Technical Notes for Implementation

**Guild Hub background:**
- Background art is a full-screen sprite swapped based on `guild.prestige_level`
- 8 art stages — early stages needed at launch, later stages can be added as guilds reach them
- Background renders behind all UI elements — UI panels use semi-transparent dark overlays to maintain readability
- Prestige milestone animation: brief transition effect when background upgrades

**Signpost announcement:**
- `guild_announcements` table: `guild_id`, `content`, `posted_by`, `posted_at`
- Signpost text truncates to 60 chars for the in-scene display — full text on tap
- Only one active announcement per guild — new post replaces previous

**Quest board / Guild Merchant:**
- Material requests: `guild_material_requests` table (already in guild system doc)
- Guild Merchant listings: `guild_merchant_listings` table — `guild_id`, `item_id`, `quantity`, `price_sm`, `listed_by`, `listed_at`, `expires_at`
- Listing fee (0.5–1%) credited to `guild_currency` at time of sale — not at listing
- Guild Merchant purchase triggers same Send to Player flow as inventory — `pending_transfers` table
- Listings expire after 7 days — scheduled Edge Function returns unsold items to seller inventory
- RLS policy: Guild Merchant listings only readable by players where `guild_id` matches player's current guild

**Tax vote:**
- `guild_tax_votes` table: `guild_id`, `proposed_rate`, `initiated_by`, `initiated_at`, `votes_for`, `votes_against`, `status`, `last_rate_change`
- 90-day cooldown enforced server-side — check `last_rate_change` before allowing new vote initiation
- Vote result applied via Edge Function 48hrs after vote closes if passed

**Join requests:**
- `guild_join_requests` table: `guild_id`, `player_id`, `requested_at`, `status` (pending/approved/declined)
- Officers see pending requests on Roster tab
- Approved request triggers guild membership grant + notification

**Upgrade purchase:**
- Validates GM and all materials in guild bank before allowing purchase
- Deducts from `guild_currency` and `guild_bank_inventory` in single transaction
- Updates `guild.roster_cap` on success

---

*Document version 0.1 — Guild Hall UI Specification*
*Next: Melee combo system · Summoner construct system · Lifebinder healing · Phase 2 handoff*
