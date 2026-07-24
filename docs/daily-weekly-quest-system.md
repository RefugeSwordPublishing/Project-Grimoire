# Project Grimoire, Daily & Weekly Quest System
### Version 0.1

---

## Core Design

The quest system provides a daily engagement loop that rewards players for intentional play beyond passive idling. Quests are picked from a board, not auto-assigned, giving players agency to choose tasks that complement their current progression.

### Board Structure
- **Daily board:** 10 available quests, player picks up to 5 to accept
- **Weekly board:** 6 available quests, player picks up to 2 to accept
- **Board refreshes:** Midnight UTC for everyone simultaneously, creates a shared daily reset moment
- **Accepted quests:** Cannot be abandoned once accepted, choosing carefully matters
- **Completion:** Quests complete automatically when conditions are met, no manual turn-in required
- **Missed quests:** Uncompleted quests at reset are lost, no carryover

---

## Quest Difficulty Scaling

Quest difficulty and rewards scale with the player's overall progression. The system reads the player's **highest Talent level** to determine which difficulty tier to generate quests from.

| Difficulty Tier | Trigger | Quest Scale |
|----------------|---------|-------------|
| **Novice** | Highest Talent 1-20 | Small quantities, Tier 1 zones, Crude materials |
| **Journeyman** | Highest Talent 21-40 | Moderate quantities, Tier 2 zones, Rough materials |
| **Adept** | Highest Talent 41-60 | Larger quantities, Tier 3 zones, Refined materials |
| **Expert** | Highest Talent 61-80 | High quantities, Tier 4 zones, Pristine materials |
| **Master** | Highest Talent 81-100 | Endgame quantities, Tier 5 zones, Masterwork materials |

Each daily board always contains quests from the player's current tier plus one tier below, so a Journeyman player sees mostly Journeyman quests with a couple of easy Novice quests as reliable fillers.

---

## Quest Categories

### Gathering Quests
Generated from active gathering Talents. Quantity scales with difficulty tier.

| Quest Type | Example (Novice) | Example (Master) |
|------------|-----------------|-----------------|
| **Forage X of Y** | Forage 20 Common Herbs | Forage 15 Celestine Sprigs |
| **Fell X trees** | Fell 15 Pine trees | Fell 8 Voidtimber trees |
| **Delve X ore** | Delve 30 Copper Ore | Delve 12 Soulite Ore |
| **Catch X creatures** | Trap 5 Rabbits | Trap 3 Drake creatures |
| **Catch X fish** | Dredge 10 Perch | Dredge 5 Dragon Eel |
| **Harvest X crops** | Harvest 20 Wheat | Harvest 5 Worldseed crops |
| **Track X creatures** | Track 3 common animals | Track 1 Legendary creature |

**Rewards:** Rare materials relevant to that gathering Talent + Silver Marks

---

### Processing Quests
Generated from processing Talents the player has leveled.

| Quest Type | Example (Novice) | Example (Master) |
|------------|-----------------|-----------------|
| **Craft X batches** | Brew 3 batches of Healing Draughts | Brew 5 batches of Void Coating |
| **Cook X meals** | Cook 5 Herb Broths | Cook 3 Feasts of the Grimoire |
| **Smelt X bars** | Smelt 20 Bronze Bars | Smelt 8 Grimoire Steel Bars |
| **Tan X hides** | Tan 10 Rough Leather | Tan 5 Void Hide |
| **Shape X timber** | Shape 15 Pine Planks | Shape 6 Worldtree Grips |
| **Inscribe X scrolls** | Inscribe 3 Zone Maps | Inscribe 2 Living Grimoires |
| **Enchant X items** | Enchant 2 items with Minor Accuracy | Enchant 3 items with Legendary slot |

**Rewards:** Gold Marks + XP boost to the relevant Processing Talent (10% bonus for 2 hours)

---

### Combat Quests
Generated from current zone access and Slaying level.

| Quest Type | Example (Novice) | Example (Master) |
|------------|-----------------|-----------------|
| **Slay X enemies** | Slay 15 enemies in Grimwood Fringe | Slay 20 enemies in Ashenwold |
| **Slay X of type** | Slay 8 Outlaw enemies | Slay 10 Void creatures |
| **Defeat zone boss** | Defeat Aldric the Poacher King | Defeat The Ashen Sovereign |
| **Active combat kills** | Get 10 active kills (no idle) | Get 20 active kills with crits |
| **Attunement kills** | Land 5 crit shots actively | Land 15 weak point crits |
| **Clear dungeon** | Complete Aldric's Warren | Complete The Pale Vault |
| **Survive X hits** | Survive 30 hits without healing | Survive 50 hits in Tier 5 zone |

**Rewards:** Gold Marks + rare material drops from enemy faction type

---

### Crafting Quests
Assembly-focused, require cross-Talent cooperation, good for driving market activity.

| Quest Type | Example (Novice) | Example (Master) |
|------------|-----------------|-----------------|
| **Assemble X weapons** | Assemble 2 Crude weapons | Assemble 1 Masterwork weapon |
| **Assemble X armor pieces** | Assemble 3 Crude armor pieces | Assemble 2 Pristine armor pieces |
| **Assemble with rare material** | Attempt 1 Rough tier Assembly | Attempt 1 Masterwork tier Assembly |
| **Assemble for another player** | Assemble 1 item for a guild member | Assemble 3 items for other players |
| **List X items on Exchange** | List 5 items on Wayfarer's Exchange | List 10 items with Buy Order matches |

**Rewards:** Rare materials (Assembly components) + Silver/Gold Marks

---

### Market Quests
Economy-focused, drive Wayfarer's Exchange activity.

| Quest Type | Example (Novice) | Example (Master) |
|------------|-----------------|-----------------|
| **Sell X items** | Sell 10 items on the Exchange | Sell 5 Masterwork items |
| **Fill a Buy Order** | Fulfill any Buy Order | Fulfill a Buy Order worth 10,000+ SM |
| **Place X Buy Orders** | Place 2 Buy Orders | Place 3 Buy Orders over 50 GM each |
| **Earn X Marks trading** | Earn 500 SM from Exchange sales | Earn 50 GM from Exchange sales |
| **List auction items** | List 1 Auction item | List 3 Auction items with buyout |

**Rewards:** Silver/Gold Marks bonus (higher than other quest types to reflect economy effort)
> Note: CHA passive bonus will be added to market quest rewards post-Beastbond DLC release, CHA has no meaningful base game combat role until then

---

### Challenge Quests
Harder quests, higher rewards, always one on the weekly board.

| Quest Type | Example (Journeyman) | Example (Master) |
|------------|---------------------|-----------------|
| **Chain Attunement** | Get 10 consecutive active kills without idle | Get 25 consecutive active crits |
| **Speed run** | Complete a dungeon in under 20 min | Complete Firststone Sanctum in under 30 min |
| **No consumables run** | Slay 20 enemies without using any potion | Clear a dungeon with no meals or potions |
| **Economy challenge** | Earn 5,000 SM in one day | Earn 500 GM in one week |
| **Talent sprint** | Gain 5 levels in one Talent in one day | Gain 3 levels in a Talent above level 80 |
| **Assembly streak** | Successfully assemble 5 items in a row | Successfully hit Pristine tier 3 times |
| **Master the hunt** | Defeat 3 zone bosses in one day | Defeat all 5 zone bosses in one week |

**Rewards:** Highest rewards in the game outside of raids, Gold Marks + rare materials + Talent XP boosts

---

## Reward Structure

All rewards scale with difficulty tier. Base values at Novice, multiplied per tier.

### Silver Mark Rewards
| Difficulty | Daily Quest | Weekly Quest |
|-----------|------------|-------------|
| Novice | 200-500 SM | 1,500-3,000 SM |
| Journeyman | 500-1,500 SM | 4,000-8,000 SM |
| Adept | 1,500-4,000 SM | 10,000-20,000 SM |
| Expert | 4,000-10,000 SM | 25,000-50,000 SM |
| Master | 10,000-25,000 SM | 60,000-150,000 SM |

### Gold Mark Rewards
Combat and challenge quests pay in Gold Marks:
| Difficulty | Daily Quest | Weekly Quest |
|-----------|------------|-------------|
| Novice | 0-1 GM | 2-5 GM |
| Journeyman | 1-3 GM | 5-12 GM |
| Adept | 3-8 GM | 15-30 GM |
| Expert | 8-20 GM | 35-75 GM |
| Master | 20-50 GM | 80-200 GM |

### Rare Material Rewards
Gathering and crafting quests award rare materials relevant to their Talent:
- Novice quests: Crude tier material (1-3 units)
- Journeyman quests: Rough tier material (1-2 units)
- Adept quests: Refined tier material (1 unit)
- Expert quests: Pristine tier material (1 unit, low chance)
- Master quests: Masterwork tier material (rare chance only, keeps raids as primary source)

### XP Boost Rewards
Processing and challenge quests award temporary XP boosts:
| Boost Type | Duration | Multiplier |
|-----------|---------|-----------|
| Talent XP Boost (specific) | 2 hours | +25% to named Talent |
| Talent XP Boost (all) | 30 minutes | +15% to all Talents |
| Attunement Surge Boost | 1 hour | Active play bonus increased to 4x |

---

## Board Generation Rules

The quest board generates fresh at midnight UTC. Rules:

1. **No duplicate quest types** on the same board, each of the 5 categories appears at least once on the daily board
2. **Weighted toward active Talents**, if Foraging is in the player's idle queue it's more likely to appear
3. **At least one easy quest** always on the board, ensures players can always complete something
4. **At least one challenge quest** on the weekly board, always one high-effort high-reward option
5. **Combat quests respect zone access**, never generates a quest for a zone the player can't access
6. **Processing quests respect Talent level**, never asks for a Formulae the player hasn't unlocked
7. **Guild bonus (Phase 4):** Guild members see one shared guild quest on the weekly board, completing it contributes to a guild reward pool

---

## Notifications

Push notifications (Firebase Cloud Messaging) for quests:
- **Daily reset:** "New quests available on the board", sent at midnight UTC
- **Quest complete:** "Your quest is complete, claim your reward", sent when conditions met during idle
- **Quest expiring:** "2 of your quests expire in 1 hour", sent 1 hour before reset if incomplete quests remain
- **Weekly reset:** "Weekly board refreshed, new challenges available"

All notifications respect player notification preferences set in Settings.

---

## Quest Board UI

Accessible from main menu, dedicated Quest Board screen.

**Daily tab:**
- Shows all 10 available quests (grayed out once 5 are accepted)
- Accepted quests show progress bar and completion percentage
- Completed quests show green checkmark and reward summary
- Time remaining until reset shown at top

**Weekly tab:**
- Shows all 6 available weekly quests
- Same accept/progress/complete flow
- Larger reward display, weeklies feel more significant

**Quest card shows:**
- Quest name and description
- Category icon (gathering/processing/combat/crafting/market/challenge)
- Difficulty indicator (Novice through Master)
- Reward preview, Marks, materials, XP boost
- Progress if accepted (e.g. "12/20 enemies slain")
- Time remaining

---

## Cross-System Notes

- **Faction integration (DLC):** Quest completion for faction-tagged enemies or in faction zones will contribute to faction standing when factions launch, tag quest types from day one
- **Guild quests (Phase 4):** Shared weekly guild quest added to weekly board, no design change needed, just an additional slot
- **Dungeon quests:** "Clear X dungeon" quests are only generated during months when that dungeon is in the active rotation
- **Raid quests:** Weekly board can include a "participate in the raid" quest during active raid quarter, rewards participation not completion, so less skilled players still benefit

---

*Document version 0.1, Daily & Weekly Quest System*
*Next: Onboarding flow · While You Were Away screen · Monetization scope · Main design doc cleanup*
