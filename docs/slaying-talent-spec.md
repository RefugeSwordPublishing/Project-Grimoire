# ⚔️ Project Grimoire — Slaying Talent Full Spec
### Version 0.1

---

## 📐 Design Philosophy

Slaying is the **dungeon mastery and elite hunting Talent** — not a combat power stat, but a progression key that unlocks harder content, drives dungeon engagement, and rewards players who push into dangerous territory. It functions the same regardless of which Grimoire is equipped — a Sharpshot and a Warlord level Slaying the same way and receive the same bonuses.

Slaying answers the question: *"Why should I do dungeons and hunt elites rather than just idling in a zone?"* The answer is exclusive content access, meaningful task rewards, and passive spawn rate bonuses that make active zone grinding more exciting over time.

---

## 📊 XP Sources

| Source | Slaying XP | Notes |
|--------|-----------|-------|
| Standard zone enemy kill | **0** | No Slaying XP from routine combat |
| Elite enemy kill | **Small** (~5x standard combat XP) | Rewards active zone hunting |
| Zone boss kill | **Moderate** (~20x standard combat XP) | Active play only — rare event |
| Dungeon completion | **Primary** — large flat award | Scales with dungeon tier (see table below) |
| Task completion | **Bonus** — 2–3x dungeon completion XP | Rewards intentional targeted play |

### Dungeon Completion XP by Tier
| Dungeon Tier | Zone | Base Slaying XP |
|-------------|------|----------------|
| Tier 1 | Grimwood Fringe, Saltmarsh Shore | 500 XP |
| Tier 2 | Ashfen Mire, Ironspine Reaches | 1,500 XP |
| Tier 3 | Dreadhollow, Cinderpeak | 4,000 XP |
| Tier 4 | Veilborn Wastes, Shattered Citadel | 10,000 XP |
| Tier 5 | Ashenwold, Elder Reaches | 25,000 XP |

### Task Completion XP Bonus
| Task Tier | Bonus XP on Completion |
|-----------|----------------------|
| Tier 1 tasks | 1,000 XP (2x dungeon) |
| Tier 2 tasks | 4,000 XP (2.5x dungeon) |
| Tier 3 tasks | 12,000 XP (3x dungeon) |
| Tier 4 tasks | 30,000 XP (3x dungeon) |
| Tier 5 tasks | 75,000 XP (3x dungeon) |

---

## 📈 Level Unlocks

### Zone Spawn Rate Bonuses
Higher Slaying level causes more elites and zone bosses to appear during normal zone combat. Stacks with base spawn rates.

| Slaying Level | Elite Spawn Bonus | Zone Boss Spawn Bonus |
|--------------|------------------|----------------------|
| 1 | 0% | 0% |
| 20 | +2% | +1% |
| 40 | +5% | +3% |
| 60 | +9% | +6% |
| 80 | +14% | +10% |
| 100 | +20% | +15% |

### Content Access Unlocks
| Level | Unlock |
|-------|--------|
| 1 | Slaying Task Board accessible |
| 10 | Technique: Finishing Blow — execute sub-20% HP enemies for bonus Slaying XP |

> **Zone/dungeon access now based on Total Combat Level** (sum of all owned Grimoire combat levels) not Slaying level. Slaying level gates task board content and spawn rate bonuses only. See Grimoire System doc for zone threshold table.
| 25 | **4th active task slot unlocked** (milestone reward) |
| 30 | Technique: Combat Awareness — dodge window unlocked in active combat |
| 40 | Tier 3 dungeons accessible |
| 45 | **Raid participation unlocked** — Slaying 45 required to join any raid group |
| 50 | **5th active task slot unlocked** (milestone reward) |
| 57 | Technique: Hunter's Mark — mark target for +20% damage |
| 60 | Tier 4 dungeons accessible |
| 70 | Technique: Slayer's Focus — +20% Slaying XP from all sources for 10 min cooldown |
| 75 | Elite enemies in all zones have expanded drop tables |
| 80 | Tier 5 dungeons accessible |
| 88 | Legendary enemy spawns added to Tier 5 zones |
| 100 | Idle auto-combat never retreats from Tier 4 or lower zones | Mastery — reliable high-zone idle farming |

### Additional Task Slots (beyond level milestones)
| Method | Slots | Cost |
|--------|-------|------|
| Slaying level 25 | 4th slot | Free — milestone |
| Slaying level 50 | 5th slot | Free — milestone |
| Royal Merchant purchase | 6th slot | 200 GM or real money |
| Royal Merchant purchase | 7th slot | 300 GM or real money |
| Royal Merchant purchase | 8th slot | 500 GM or real money |

---

## 📋 Slaying Task Board

### Board Structure
- **Always shows 10 available tasks** — tasks weighted toward player's current Slaying tier
- **Pick up to 3 tasks simultaneously** (base) — increases with milestone unlocks and Royal Merchant purchases
- **No daily/weekly reset** — tasks complete and immediately replace with new ones
- **No expiry** — accepted tasks persist until completed or manually abandoned
- **Abandon penalty** — abandoned tasks go on a 2hr cooldown before that task type reappears on the board

### Task Generation
Tasks are procedurally generated from pools weighted to the player's Slaying level. Board always contains a mix:
- At least 2 tasks from the player's current tier
- At least 2 tasks from the tier below (accessible, achievable)
- 1 challenge task from the tier above (hard but possible)
- Remainder randomly weighted from current and adjacent tiers

### Task Tiers
| Tier | Slaying Level | Task Pool Focus |
|------|--------------|----------------|
| 1 | 1–20 | Tier 1 dungeons, Tier 1 elites, Zone 1 bosses |
| 2 | 21–40 | Tier 1–2 dungeons, Tier 1–2 elites and bosses |
| 3 | 41–60 | Tier 2–3 dungeons, all Tier 2 bosses, Tier 3 elites |
| 4 | 61–80 | Tier 3–4 dungeons, all elite types, zone bosses |
| 5 | 81–100 | All dungeons, all elites, all bosses, raid participation |

---

## 📝 Task Types

### Dungeon Tasks
| Task | Description | Solo/Group |
|------|-------------|-----------|
| Clear [Dungeon Name] | Complete the full dungeon — defeat all enemies and the boss | Both |
| Clear [Dungeon Name] solo | Complete without a party | Solo only |
| Defeat [Boss Name] | Defeat the dungeon boss only — can skip trash | Both |
| Clear [Dungeon Name] without dying | Full clear with no player deaths | Both |
| Speed clear [Dungeon Name] | Complete within a time limit | Both |

### Elite Hunting Tasks
| Task | Description | Solo/Group |
|------|-------------|-----------|
| Slay X [Elite type] in [Zone] | Hunt a specific elite enemy type | Both |
| Slay X elites in [Zone] | Any elite enemy in the zone counts | Both |
| Slay [Named Elite] | Hunt a specific named elite | Both |
| Slay X [Faction tag] elites | e.g. "Slay 5 Outlaw elites" | Both |

### Zone Boss Tasks
| Task | Description | Solo/Group |
|------|-------------|-----------|
| Defeat [Zone Boss] | Kill the zone boss during active play | Both |
| Defeat [Zone Boss] without taking damage | Perfect kill | Solo |
| Defeat [Zone Boss] using only [combat mechanic] | e.g. Sharpshot crits only | Solo |

### Raid Tasks (Slaying 45+)
| Task | Description | Solo/Group |
|------|-------------|-----------|
| Participate in [Raid Name] | Complete a raid run regardless of outcome | Group |
| Defeat [Raid Boss] | Successfully kill the raid boss | Group |
| Defeat [Raid Phase] | Complete a specific raid phase | Group |

### Challenge Tasks (rare, high reward)
| Task | Description | Solo/Group |
|------|-------------|-----------|
| Chain clear | Complete 3 dungeons in a single session | Both |
| No consumables | Clear a dungeon without using any potions or meals | Both |
| Full roster | Clear a dungeon with a full party | Group |
| Boss hunter | Defeat all 3 active dungeon rotation bosses in one week | Both |

---

## 💰 Task Rewards

All tasks reward a combination of Marks, rare materials, and occasional equipment. No permanent stat gains ever.

### Silver/Gold Mark Rewards
| Tier | Solo Task | Group Task |
|------|-----------|-----------|
| 1 | 800–1,500 SM | 1,200–2,500 SM |
| 2 | 2,000–5,000 SM | 3,500–8,000 SM |
| 3 | 5,000–15,000 SM | 8,000–25,000 SM |
| 4 | 8–25 GM | 15–40 GM |
| 5 | 25–75 GM | 40–120 GM |

### Rare Material Rewards
| Tier | Material Reward |
|------|---------------|
| 1 | 1–2 Crude rare materials (random type) |
| 2 | 1–2 Rough rare materials |
| 3 | 1 Refined rare material |
| 4 | 1 Pristine rare material (low chance) |
| 5 | 1 Masterwork rare material (rare chance) |

### Equipment Rewards
| Tier | Equipment Drop Chance | Quality |
|------|----------------------|---------|
| 1 | 15% chance | Crude–Rough assembled weapon or armor piece |
| 2 | 20% chance | Rough–Refined assembled gear |
| 3 | 25% chance | Refined–Pristine assembled gear |
| 4 | 30% chance | Pristine assembled gear |
| 5 | 35% chance | Pristine–Masterwork assembled gear |

### Temporary XP Boost Rewards (rare task reward, not sold in store)
| Boost | Duration | Chance |
|-------|---------|--------|
| Specific Talent XP +25% | 2 hours | 10% chance on any task completion |
| All Talents XP +10% | 30 minutes | 5% chance on Tier 3+ tasks |

---

## 🔔 Notifications
| Event | Notification |
|-------|-------------|
| Task completed | "Slaying task complete — collect your reward" |
| Elite spawned in active zone | "Elite enemy detected in [Zone]" |
| Zone boss spawned | "[Boss Name] has appeared in [Zone]" |
| Dungeon rotation changed | "New dungeons available this month" |
| Raid window opened | "Quarterly raid is now active — Slaying 45+ required" |

---

## 🔗 Cross-System Notes

- **Dungeon rotation** — 3 dungeons active per month. Slaying task board generates dungeon tasks only for currently active rotation dungeons. Players blocked on a task type can abandon and reroll
- **Raid access** — Slaying 45 hard gate. Guild must also be Tier 2+ for organized raid roster. Guest access available at Slaying 45 even without a Tier 2 guild
- **Enemy faction tags** — Slaying tasks reference faction tags from day one (e.g. "Slay 5 Outlaw elites") — DLC faction bonuses will interact with these naturally
- **Gleaning during dungeons** — post-combat loot room access (Gleaning 47 unlock) gives bonus drops after dungeon completion — synergizes with Slaying task completion rewards
- **Royal Merchant** — additional task slots (6th, 7th, 8th) purchased via Royal Merchant tab in Wayfarer's Exchange. 200/300/500 GM or real money equivalent
- **Faction DLC** — Slaying tasks will gain faction-themed variants at DLC launch (e.g. Crown faction task: "Slay 10 Outlaw elites in Crown territory"). No rework needed — task generation just adds faction-tagged pool

---

## 📱 Task Board UI

- Accessible from main navigation — dedicated Slaying tab
- Two sub-tabs: **Available** (10 tasks to choose from) and **Active** (your current accepted tasks)
- Each task card shows:
  - Task name and description
  - Type icon (dungeon/elite/boss/raid/challenge)
  - Tier indicator
  - Reward preview (Marks range, rare material, equipment chance)
  - Solo/Group tag
  - Progress if accepted (e.g. "2/5 elites slain")
- Accept button on Available tasks — grayed out if at task slot cap
- Abandon button on Active tasks — triggers 2hr cooldown for that task type

---

*Document version 0.1 — Slaying Talent Full Spec*
*Next: Update attunement data spec with revised window durations and assembly success % bonus · Session 3 handoff*
