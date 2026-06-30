# ⚔️ Project Grimoire — Onboarding Flow
### Version 0.1

---

## 📐 Design Philosophy

Onboarding has one job: get the player to their first meaningful idle loop as fast as possible while teaching them just enough to make an informed Grimoire choice. Everything beyond that is revealed naturally through play.

**Core principles:**
- Show don't tell — demonstrate mechanics rather than explain them
- Respect the player's time — total onboarding under 5 minutes
- Fully skippable — returning or experienced players tap Skip and go straight to Grimoire selection
- No feature dumps — tooltips unlock contextually as features become relevant
- The Grimoire choice is the emotional peak of onboarding — everything before it builds toward that moment

---

## 🗺️ Onboarding Flow Overview

```
Launch
  └─ Skip available throughout ──────────────────────────► Grimoire Selection
  
  Step 1: The World (30 seconds)
  Step 2: Your First Talent — Foraging (60 seconds)
  Step 3: Your First Combat — Bowstring intro (90 seconds)
  Step 4: The Grimoire Choice (60 seconds)
  Step 5: First Idle Session begins
  
  Total guided time: ~4 minutes
  Post-onboarding: Natural tooltip system takes over
```

---

## 📋 Step 1 — The World (30 seconds)

**What happens:**
A brief atmospheric introduction — not a lore dump. Sets tone and world without overwhelming.

**Format:** 3 static illustrated panels (pixel art style) with minimal text, auto-advancing every 8 seconds. Skip button always visible.

**Panel 1:**
> *A vast world of forgotten magic and ancient danger.*
> *Resources to gather. Creatures to hunt. Power to forge.*

Visual: Wide shot of the world — forest, mountain, coastline visible. Small figure in foreground.

**Panel 2:**
> *The Grimoire is your identity. Choose your path wisely.*
> *But first — survive long enough to earn it.*

Visual: Several Grimoires on a table, glowing faintly. Each a different color.

**Panel 3:**
> *Your journey begins here.*

Visual: Grimwood Fringe entrance — trees, a worn path, a distant campfire.

**Skip behavior:** Tapping Skip at any point during Step 1 jumps directly to Step 4 — Grimoire Selection.

---

## 📋 Step 2 — Your First Talent (60 seconds)

**What happens:**
Player is placed in Grimwood Fringe with a single tutorial prompt. No combat yet — just gathering.

**Sequence:**

1. Screen fades in on Grimwood Fringe. A glowing herb node pulses gently on screen.

2. Tooltip appears:
   > *"This is a Foraging node. Tap it to gather."*

3. Player taps the node. A simple gather animation plays. They receive 3x Common Herbs.

4. Tooltip appears:
   > *"You can assign Foraging to run automatically while you're away.*
   > *Tap the Talent queue to set it."*

5. Player opens Talent queue — Foraging is already highlighted. They tap to assign it.

6. Idle animation begins — small foraging loop plays in the background.

7. Tooltip appears:
   > *"Foraging is now running. Resources accumulate even when you close the app."*
   > *"Active play earns faster — but idle always progresses."*

8. Brief Attunement demo — a second herb node appears with a golden glow.
   > *"When two plants appear, choose the rarer one for a quality bonus."*
   Player taps the glowing node. Receives higher quality herb. Small XP burst visual.

9. Tooltip:
   > *"That's the Attunement bonus — active choices improve your gains."*

**What player learns:**
- Tapping nodes gathers resources
- Idle queue exists and runs automatically
- Active play gives a bonus over idle
- Talent XP exists and progresses

**Skip behavior:** Tapping Skip at any point during Step 2 jumps to Step 3.

---

## 📋 Step 3 — Your First Combat (90 seconds)

**What happens:**
A brief controlled combat encounter introduces the Bowstring mechanic without pressure. Enemy is weak, player cannot die during tutorial combat.

**Sequence:**

1. A Grimwood Brigand walks into the scene — clearly a threat. Screen shifts to over-the-shoulder combat view.

2. Tooltip appears:
   > *"A Grimwood Brigand. Press and drag to draw your bow.*
   > *Aim at the enemy and release to fire."*

3. Player presses and holds. Bowstring pulls back. Fading arc appears.
   > *"The arc shows your rough trajectory — read it to aim."*

4. Player releases. Arrow fires. Brigand takes damage.

5. Tooltip:
   > *"Every enemy has a weak point — watch for the subtle glow.*
   > *Hit it precisely for a critical strike and Attunement bonus."*

6. Weak point glows gently on the Brigand. Player aims and fires again.
   - If they hit the weak point: Critical hit fires, XP burst, tooltip:
     > *"Critical hit! Attunement bonus earned — active accuracy matters."*
   - If they miss: Normal hit, tooltip:
     > *"Close — weak points reward precision. You'll get faster with practice."*

7. Enemy defeated. Loot drops — a few Silver Marks and a Wolf Pelt.

8. Tooltip:
   > *"Enemies drop Silver Marks and crafting materials.*
   > *Higher zones mean better drops — but you'll need better gear first."*

9. Auto-combat brief demo:
   > *"When you're not actively playing, combat runs automatically.*
   > *Active play earns Attunement bonuses — idle keeps you progressing."*

**What player learns:**
- Over-the-shoulder combat perspective
- Press/drag/release Bowstring mechanic
- Weak point system and crit bonus
- Loot drops from combat
- Idle auto-combat exists

**Player cannot die during tutorial combat** — if HP drops to 20%, Brigand is automatically defeated. Prevents frustration before the player has any gear.

**Skip behavior:** Tapping Skip during Step 3 jumps to Step 4 with tutorial combat resolved automatically.

---

## 📋 Step 4 — The Grimoire Choice (60 seconds)

**What happens:**
The emotional peak of onboarding. Player chooses their first Grimoire — this is their class identity. The presentation should feel significant.

**Sequence:**

1. Screen fades to a room with Grimoires laid out on a stone table. Candlelight. Each Grimoire glows faintly in its path color.

2. Narrator text (no voice — pixel art text crawl):
   > *"You have survived your first trial. Now choose your path."*
   > *"The Grimoire you carry defines your power — but not your limits."*
   > *"You may walk other paths in time. For now — choose one."*

3. Seven Grimoires displayed in a scrollable row:

| Grimoire | Preview Text | Color |
|---------|-------------|-------|
| Sharpshot | *"Patience and precision. One shot, one kill."* | Forest Green |
| Lone Wanderer | *"Self-sufficient and swift. The wilderness is your ally."* | Amber |
| Runeweaver | *"Command the elements. Master the constellation."* | Deep Purple |
| Summoner | *"Lead from safety. Your constructs fight for you."* | Void Blue |
| Lifebinder | *"Keep others standing. Your power is their survival."* | Emerald |
| Warlord | *"Hold the line. Nothing passes while you stand."* | Crimson |
| Shadowblade | *"Strike unseen. The shadows are your home."* | Midnight Black |

4. Tapping a Grimoire shows a brief preview panel:
   - Signature passive
   - Playstyle summary (2 sentences max)
   - A small pixel art icon representing the subclass identity

5. Player confirms their choice. The Grimoire glows brightly, floats up, and settles into the character's hands.

6. Tooltip:
   > *"This is your Grimoire. Additional Grimoires can be unlocked — but choose your first path thoughtfully. Switching takes time."*

**What player learns:**
- All 7 base game Grimoires exist from day one
- Each has a distinct identity
- Grimoire switching has a cooldown — choice matters
- More Grimoires can be unlocked later

---

## 📋 Step 5 — First Idle Session (immediate)

**What happens:**
Player is placed into the full game immediately after Grimoire selection. No more guided steps — natural tooltip system takes over.

**Immediate state after onboarding:**
- Foraging assigned to idle queue (set during Step 2)
- 3x Common Herbs in inventory (gathered during Step 2)
- Small amount of Silver Marks (dropped during Step 3)
- Grimoire equipped
- Grimwood Fringe zone unlocked

**First natural tooltip triggers:**

| Trigger | Tooltip |
|---------|---------|
| First time opening Talent screen | *"Each Talent has a level cap of 100. Idle progress is steady — active play is faster."* |
| First time opening inventory | *"Materials stack automatically. Higher quality items show a tier indicator."* |
| First time Talent levels up | *"Level up! Check the Talent for newly unlocked Field Notes."* |
| First time opening Wayfarer's Exchange | *"The Exchange opens once any Talent reaches level 10. Browse, list, or place Buy Orders."* |
| First time entering combat zone | *"Different enemies drop different materials. Choose your target carefully."* |
| First time a zone boss spawns | *"A zone boss has appeared! This is active play only — engage before it despawns."* |
| First time idle session returns resources | *"While You Were Away screen shows everything accumulated during your session."* |
| First time Grimoire cooldown message appears | *"Grimoire swaps take ~24 hours. Plan your path each day."* |
| First time Alchemy queue runs | *"Processing Talents run in your queue. Assign them like Gathering Talents."* |

---

## 📱 While You Were Away — First Session

The very first time a player returns after leaving the game idle, a special version of the WYWA screen appears with extra context:

```
┌─────────────────────────────────┐
│  WELCOME BACK                   │
│  You were away 2 hours 14 min   │
├─────────────────────────────────┤
│  FORAGING                       │
│  +47 Common Herbs               │
│  +12 Ironwort                   │
│  Foraging XP: +340              │
│  → Level 3 reached!             │
├─────────────────────────────────┤
│  💡 Your idle queue ran while   │
│  you were away. Active play     │
│  earns Attunement bonuses on    │
│  top of this.                   │
└─────────────────────────────────┘
```

The tip at the bottom only shows on the first WYWA return — after that the screen is clean data only.

---

## 🔄 Skip Behavior Summary

| Point in onboarding | Skip destination |
|--------------------|-----------------|
| Step 1 (World intro) | Step 4 (Grimoire Selection) |
| Step 2 (Foraging tutorial) | Step 3 (Combat tutorial) |
| Step 3 (Combat tutorial) | Step 4 (Grimoire Selection) |
| Step 4 (Grimoire Selection) | Cannot skip — must choose a Grimoire |
| Natural tooltips | Each tooltip has an X to dismiss permanently |

**Grimoire Selection cannot be skipped** — it's the one required step. Even returning players who skip everything must confirm their Grimoire choice on a new account.

---

## 🔧 Technical Notes for Implementation

- Tutorial state tracked in Supabase player record — `onboarding_complete: bool`, `onboarding_step: int`
- Skip state persists — if player partially completes tutorial, quits, and returns, they resume from current step or can choose to skip remaining steps
- Tutorial combat uses a special scene flag — `isTutorialCombat: true` — which disables player death and auto-resolves the Brigand at 20% player HP
- Natural tooltips use a `TooltipManager` that tracks which tooltips have been shown — each tooltip has a unique ID and fires once per account
- Grimoire choice writes to `player_grimoire` table in Supabase immediately on selection — no confirmation dialog beyond the in-game choice moment
- Foraging idle assignment during Step 2 is simulated in the tutorial scene — actual queue assignment is confirmed when Step 5 begins

---

*Document version 0.1 — Onboarding Flow*
*Next: While You Were Away screen · Monetization scope · Main design doc cleanup*
