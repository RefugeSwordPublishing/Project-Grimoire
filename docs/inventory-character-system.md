# ⚔️ Project Grimoire — Inventory & Character Panel System
### Version 0.1

---

## 📐 Design Philosophy

Project Grimoire is an idle crafter first — players accumulate vast quantities of materials across dozens of categories. The inventory system must handle large volumes without friction, give players meaningful organizational control, and never feel like it's fighting against the idle loop.

**Core principles:**
- No stack limits — idle crafters accumulate hundreds of the same item, artificial stack limits would be punishing and immersion-breaking
- Player-defined organization — custom sort order and placeholders give dedicated players full control
- Slot expansion is a meaningful but not punishing progression — early expansions are cheap, later ones cost real Gold Marks
- Guild bank is separate from personal inventory — shared resource pool with its own slot system
- Protected categories — Quest Items and locked items cannot be accidentally sold, used, or discarded

---

## 📦 Personal Inventory

### Starting Capacity
**70 slots** at game start.

Each slot holds one item type at unlimited quantity — 1,000 Iron Bars occupies the same 1 slot as 1 Iron Bar.

### Slot Expansion
Purchased with Silver or Gold Marks, +10 slots per purchase. Cost doubles each time until the 20 GM cap is reached, then flat 20 GM per expansion thereafter.

| Purchase # | Cost | Total Slots |
|-----------|------|-------------|
| Starting | — | 70 |
| 1 | 500 SM | 80 |
| 2 | 1,000 SM | 90 |
| 3 | 2,000 SM | 100 |
| 4 | 4,000 SM | 110 |
| 5 | 8,000 SM | 120 |
| 6 | 16,000 SM (~16 GM) | 130 |
| 7+ | 20 GM each | 140, 150, 160... |

Maximum slot count revisited as new items are added to the game. No hard cap at launch — expand as needed.

---

## 🗂️ Inventory Categories

All items stored in one unified inventory, filterable by category. Default view shows all items. Category tabs filter to that type only.

| Category | Contents | Protected? |
|----------|---------|-----------|
| **Raw Materials** | Ores, timber, pelts, herbs, fish, crops, aquatic reagents, bark, sap | No |
| **Currency** | Silver Marks, Gold Marks, Old Coins | Yes — cannot be discarded |
| **Craftables** | Component parts — blades, grips, leather wraps, plate bodies, timber planks, thread, leather strips | No |
| **Consumables** | Potions, meals, coatings, lures — items with uses or duration | No |
| **Equipment** | Fully assembled weapons, armor pieces, quivers | No |
| **Grimoires** | All owned Grimoire collection | Yes — cannot be discarded or sold |
| **Rare Materials** | Crude through Masterwork upgrade materials (Amber, Gemstones, Phantom Pelt etc.) | No |
| **Scrolls & Codex** | Inscription outputs — zone maps (consumable buffs), spellbook pages, ancient texts, treasure maps, tomes | No |
| **Quest Items** | Items tied to active quests | Yes — cannot be sold, used outside quest context, or discarded while quest is active |

---

## 🔧 Inventory Features

### Item Locking
Players can lock any individual item slot — locked items cannot be:
- Sold (blocked from Exchange listing flow)
- Used in Assembly (blocked from Workbench ingredient selection)
- Discarded
- Sent to another player

Lock/unlock by long-pressing an item slot. Locked items show a small padlock icon. Particularly important for rare materials players are saving for specific Assembly attempts.

### Custom Sort & Placeholders
Players can fully define their own inventory layout:
- **Drag to reorder** — press and hold any slot to drag it to a new position
- **Placeholders** — empty reserved slots that hold a position in the layout. Set a placeholder by tapping an empty slot and naming it (e.g. "Pristine Amber — save for Legendary bow"). Placeholder slots display the label and cannot be auto-filled by incoming items
- **Auto-sort options:**
  - *Custom* — restores player's saved custom layout (default)
  - *By Category* — groups by category tab order listed above
  - *By Value* — highest Exchange price per unit first
  - *By Quantity* — most stacked first
  - *By Name* — alphabetical

### Search & Filter
- Search bar at top of inventory — type to filter visible slots by item name
- Combine search with category filter — e.g. filter to Raw Materials then search "amber"
- Search persists until cleared

### Bulk Actions
Select multiple slots (long press first item, tap others to add to selection):
- **Sell selected** — opens Exchange listing flow with all selected items pre-loaded
- **Send to Guild Bank** — deposits selected materials to guild bank (if member)
- **Discard selected** — confirmation dialog before removing (cannot discard locked or protected items)
- **Lock/Unlock selected** — apply lock state to all selected items at once

### Create Listing (from inventory)
Tapping any item opens a context menu with:
- **List on Exchange** — opens Store Listing or Auction flow with item pre-selected
- **Send to Player** — opens player search, sends item directly to another player's inventory
- **Use** (if consumable) — applies the item
- **Lock/Unlock**
- **View details** — full item card with stats, quality tier, source information

### Send to Player
Direct player-to-player item transfer:
- Search player by name
- Select item and quantity to send
- Confirmation on both sides (receiver gets a notification and must accept)
- Cannot send: Quest Items, locked items, Grimoires, Currency
- 24 hour cooldown on receiving items from players not on your friends list — prevents spam

---

## 🏛️ Guild Bank

Separate from personal inventory. Accessible from the Guild tab. Functions similarly to personal inventory with its own slot limit and expansion system.

### Guild Bank Capacity
**50 slots** at guild creation.

| Purchase # | Cost | Total Slots |
|-----------|------|-------------|
| Starting | — | 50 |
| 1 | 1,000 SM | 60 |
| 2 | 2,000 SM | 70 |
| 3 | 4,000 SM | 80 |
| 4 | 8,000 SM | 90 |
| 5 | 16,000 SM (~16 GM) | 100 |
| 6+ | 20 GM each | 110, 120... |

Guild bank expansions are paid from the **guild bank balance** — not individual members' personal marks.

### Guild Bank Access
- **View:** All members
- **Deposit:** All members — any item from personal inventory can be donated
- **Withdraw:** Officers and Guild Master only
- **Expansion purchase:** Officers and Guild Master only

### Guild Material Requests
Officers and Guild Master can post **Material Requests** to the guild bank:

```
MATERIAL REQUEST
Posted by: Guild Master
Item: Iron Bar (Rough tier or better)
Quantity needed: 500
Purpose: Tier 2 roster upgrade
Progress: 234 / 500
```

- Any member can fulfill a request by depositing the requested item
- Progress tracked automatically as deposits arrive
- Requests stay visible until fulfilled or manually closed by an Officer
- Members get a notification when a new material request is posted
- This creates a natural guild contribution path for crafters who don't raid — donating materials directly funds guild upgrades

### Guild Upgrade Material Requirements
All guild upgrades require both **Gold Marks** AND **specific materials** from the guild bank. This creates two contribution lanes:

- **Traders** fund the Marks side through Exchange tax
- **Crafters** fund the Materials side through direct donations

Example upgrade requirements (exact values to be tuned during balancing):

| Upgrade | GM Cost | Material Requirement |
|---------|---------|---------------------|
| Roster Tier 1 (10→20 members) | 5,000 GM | 200x Iron Bar, 100x Rough Leather |
| Roster Tier 2 (20→30 members) | 15,000 GM | 500x Steel Bar, 200x Fine Leather, 50x Refined Gemstone |
| Consumable Buff — Prospector's Fortune | 3,000 GM | 20x Crude Amber, 10x Rough Gemstone |
| Guild Bounty activation | varies | varies per bounty type |

> Exact material requirements to be balanced against drop rates and crafting output during Phase 4 implementation. Listed here as structure only.

---

## 🧍 Character Panel

Accessible from the main navigation. Shows the player's current equipped state and all derived stats.

### Equipment Display
Visual layered sprite of the player character showing all currently equipped items:
- Grimoire (shown as equipped book icon)
- Weapon (bow, sword, staff etc.)
- Armor pieces — helm, chest, legs, boots, gloves
- Quiver (Warden)
- Each slot is tappable — opens the item detail card and allows swapping from inventory

### Attribute Display (7 raw stats)
| Stat | Value | Source breakdown on tap |
|------|-------|------------------------|
| STR | 24 | Base 10 + Talent milestones 6 + Equipment 8 |
| DEX | 31 | Base 12 + Warden bonus 2 + Talent milestones 9 + Equipment 8 |
| VIT | 28 | Base 10 + Talent milestones 10 + Equipment 8 |
| INT | 14 | Base 10 + Talent milestones 4 |
| WIL | 19 | Base 10 + Talent milestones 9 |
| LCK | 24 | Base 10 + Talent milestones 8 + Equipment 6 |
| CHA | 11 | Base 10 + Talent milestones 1 |

Tapping any stat shows a breakdown tooltip — where each point comes from (base, Talent milestones, equipment, enchants).

### Derived Combat Stats Display
| Stat | Value | Tooltip on tap |
|------|-------|---------------|
| Attack | 84 | "Your damage output per hit" |
| Defense | 42 | "Reduces incoming damage after hit resolution" |
| Max HP | 180 | "Total health pool" |
| Evasion | 18% | "Chance to dodge an attack entirely" |
| Block | 8% | "Chance to reduce hit damage by armor block %" |
| Accuracy | 78 | "Hit chance against enemies — higher DEX improves this" |
| Crit Chance | 12% | "Chance of a critical hit — bowstring accuracy affects this actively" |
| Healing Boost | +8% | "Bonus to all healing received — scales with WIL" |
| Debuff Resist | +6% | "Chance debuffs fail to land — scales with WIL" |
| Idle Efficiency | 74% | "Current idle auto-combat effectiveness vs active play" |
| Drop Rate Bonus | +2.4% | "Bonus rare material drop chance — scales with LCK and Gleaning" |

### Grimoire Cooldown
If a Grimoire swap was made recently, the character panel shows:
```
📖 Grimoire swap cooldown: 18h 42m remaining
```
Tapping this shows which Grimoire was previously equipped and when the swap was made.

---

## ⚔️ Combat Tab (Character Panel)

A dedicated Combat Tab on the character screen replaces the old combat Talent entries. Combat progression lives on each Grimoire individually — not in the shared Talent system.

```
CHARACTER — Combat Tab
┌─────────────────────────────────────┐
│ ⚔ Total Combat Level: 90           │
│   (Sharpshot 80 + Lifebinder 10)   │
│                                     │
│ EQUIPPED GRIMOIRE                   │
│ Grimoire of Sharpshot  ★  Lv 80    │
│ ████████████████████░░ 84% to 81   │
│                                     │
│ UNLOCKED TECHNIQUES                 │
│ ✓ Basic Draw           (Lv 1)      │
│ ✓ Aimed Shot           (Lv 9)      │
│ ✓ Rapid Fire           (Lv 31)     │
│ ✓ Headshot             (Lv 44)     │
│ ✓ Trick Shot           (Lv 52)     │
│ ○ Volley               (Lv 66)     │
│ ○ Void Arrow           (Lv 79)     │
│ ○ Hunter's Instinct    (Lv 86)     │
│                                     │
│ OTHER OWNED GRIMOIRES               │
│ Lifebinder             Lv 10        │
│ Runeweaver             Not owned    │
│ Lone Wanderer          Not owned    │
└─────────────────────────────────────┘
```

**Combat Tab rules:**
- ★ marks the highest-leveled owned Grimoire — prestige indicator
- Total Combat Level displayed prominently — the bragging rights stat
- Unlocked Techniques shown with checkmarks, locked with empty circles
- Tapping any locked Technique shows what level it unlocks at
- Other Grimoires section shows all 7 base game Grimoires — owned show level, unowned show "Not owned" with purchase prompt
- Zone access reminder at bottom: "Current zone access: Tier 3 (Total Combat Level 90)"

**Supabase schema addition:**
```
player_grimoire_levels table:
  player_id     UUID (FK)
  grimoire_id   TEXT
  combat_level  INTEGER
  combat_xp     INTEGER
  owned_at      TIMESTAMP
```
Total Combat Level = SUM(combat_level) across all rows for player_id

---

## 📊 Active Buff HUD

A persistent row of buff icons displayed just below the top status bar — always visible without navigating to the character screen.

**Display rules:**
- Shows up to 6 buff icons horizontally — if more than 6 active, shows the 6 soonest to expire
- Each icon shows a small countdown timer beneath it
- Tapping any buff icon shows full details (what it does, source, exact time remaining)
- Expired buffs fade out automatically
- No buff icons shown = clean HUD, no clutter when idle

**Buff types that appear:**
- Cookery meals (stat buffs with duration)
- Alchemy potions (heal over time, stat boosts)
- Coating duration remaining on quiver (poison, fire, frost, void)
- Guild consumable buffs (drop rate, yield bonus etc.)
- Attunement Surge window (brief, shows during active play)

---

## 🔧 Technical Notes for Implementation

- Inventory data stored in Supabase — `player_inventory` table with `player_id`, `item_id`, `quantity`, `slot_position`, `is_locked`, `placeholder_label`
- Custom sort order stored as an ordered array of slot positions per player — `inventory_layout` field
- Guild bank stored in `guild_bank` table with `guild_id`, `item_id`, `quantity`, `slot_position` — separate from player inventory entirely
- Material requests stored in `guild_material_requests` table — `guild_id`, `item_id`, `quantity_needed`, `quantity_filled`, `posted_by`, `purpose_label`
- Buff HUD reads from `player_active_buffs` table — updated whenever a consumable is used or expires
- Item locking is client-side enforced at the UI layer AND server-side validated before any sell/transfer/use action — prevents exploitation
- Send to Player: implement as a `pending_transfers` table — receiver must accept before item moves. Auto-expire unclaimed transfers after 7 days and return to sender

---

*Document version 0.1 — Inventory & Character Panel System*
*Next: Player account system · Settings screen · Push notification triggers · Exchange unlock flow*
