---
type: design-spec
version: 1.0
updated: 2026-07-25
path: docs/daily-weekly-quest-system.md
---

# Project Grimoire, Daily and Weekly Quest System
### Version 1.0

---

## 1. Design Goals

Quests give players a structured reason to engage with content they might
otherwise skip. They should feel like a natural extension of the existing
talent and combat loop, not a separate obligation layered on top.

Three principles:

**Additive, not gating.** No reward behind a quest should be exclusively
obtainable there. Quests accelerate progress; they do not gate it.

**Faction-taggable from day one.** Every quest type carries a factionId
field even when unused in the base game. The DLC faction reputation system
drops in without schema changes.

**Server-authoritative time.** All resets computed server-side via now()
at UTC. The client displays a countdown from resets_at; it never computes
eligibility itself.

---

## 2. Quest Board, New Nav Panel

A new GamePanel.Quests entry is needed. Navigation drawer wiring follows
the existing NavigationDrawerUI pattern.

Panel name: Quest Board
Icon: Notice board (existing UI misc icon A1 from asset tracker)
Position in nav: Between Guild and Settings

The Quest Board shows two tabs: Daily and Weekly. Each tab shows the
player's current quests for that cadence, progress bars, and a Claim
button when complete.

### UI Layout

```
[ Daily | Weekly ]

Quest card:
  Title           "Fell 20 Oak Logs"
  Description     "Chop Oak Logs in any zone."
  Progress bar    [========--] 16 / 20
  Reward preview  [icon] 500 Felling XP  [icon] 15 GM
  [ Claim ] (greyed until complete, highlight when ready)

Reset timer: "Resets in 6h 42m"
```

All quest progress updates in real time from the existing manager event
system. No polling required if managers fire events on resource gain or
enemy kill.

---

## 3. Data Model

### 3.1 Quest Definition (ScriptableObject)

```csharp
[CreateAssetMenu(menuName = "Grimoire/QuestDefinition")]
public class QuestDefinition : ScriptableObject
{
    public string questId;           // stable snake_case key, e.g. "fell_oak_logs"
    public QuestCadence cadence;     // Daily / Weekly
    public QuestType type;           // see Section 4
    public string displayTitle;
    public string displayDescription;

    // Targeting
    public string targetId;          // itemName, talentName, or zone id
    public EnemyFactionTag[] factionTags; // empty = any faction
    public int targetCount;

    // Pool weighting
    public int weight = 10;
    public int minZoneTier = 1;
    public int maxZoneTier = 5;

    // Rewards
    public QuestReward[] rewards;

    // DLC forward-compatibility hook
    public string factionId;               // empty in base game
    public int factionReputationAward;     // 0 in base game
}

public enum QuestCadence { Daily, Weekly }

public enum QuestType
{
    GatherItem,
    ProcessItem,
    CraftItem,
    DefeatEnemies,
    DefeatElites,
    DefeatBoss,
    CompleteDungeon,
    EarnTalentXP,
    ReachZone,
    SellOnExchange,
}

public class QuestReward
{
    public QuestRewardType type;
    public string id;     // talentName for XP, itemId for item, empty for currency
    public int amount;
}

public enum QuestRewardType
{
    TalentXP,
    CombatXP,
    Item,
    SilverMarks,
    GoldMarks,
}
```

### 3.2 Player Quest State (Supabase)

```sql
create table player_quests (
    id           uuid primary key default gen_random_uuid(),
    player_id    uuid references auth.users not null,
    quest_id     text not null,
    cadence      text not null,           -- 'daily' | 'weekly'
    progress     int not null default 0,
    target_count int not null,
    completed    boolean not null default false,
    claimed      boolean not null default false,
    assigned_at  timestamptz not null default now(),
    resets_at    timestamptz not null,
    unique (player_id, quest_id, resets_at)
);

alter table player_quests enable row level security;
create policy "own rows" on player_quests
    using (player_id = auth.uid());
```

### 3.3 Reset Timestamps

Computed server-side only. Client never writes resets_at.

```sql
-- Daily: next 00:00 UTC
select date_trunc('day', now() at time zone 'utc') + interval '1 day'

-- Weekly: next Monday 00:00 UTC
select date_trunc('week', now() at time zone 'utc') + interval '1 week'
```

The Edge Function assign_quests runs on first board open after a reset,
checks resets_at < now(), clears expired rows, and assigns a fresh set.

---

## 4. Quest Types and Targeting

### GatherItem
Triggered by: InventoryManager.OnItemAdded event, filter on item.itemName.
Progress increments by quantity added. Idle gathering counts. This is
correct: quests reward the existing loop, not require active play.

### ProcessItem
Triggered by: processing completion event in Tanning, Smelting, Timber Shaping.
Progress increments by quantity produced.

### CraftItem
Triggered by: Assembly bench success event.
Progress increments on successful assembly only (not failed attempts).

### DefeatEnemies
Triggered by: CombatManager.OnEnemyKilled.
Filter on factionTags if specified. Empty = any enemy. Idle kills count.

### DefeatElites
Triggered by: CombatManager.OnEnemyKilled, filter isElite == true.
factionTags filter applies.

### DefeatBoss
Triggered by: CombatManager.OnBossKilled.
targetId matches enemyName. Any spawn of that boss counts.

### CompleteDungeon
Triggered by: dungeon completion event (boss killed, run ends).
targetId empty = any dungeon. Populated = specific dungeon.

### EarnTalentXP
Triggered by: TalentManager.OnXPAdded, filter on talent name.
Progress = cumulative XP earned during the quest window, not talent level.

### ReachZone
Triggered by: zone entry event. Progress flips to 1 on first entry.
Useful as a nudge for players who haven't visited a zone yet.

### SellOnExchange
Triggered by: Exchange sale completion event (server-side, via collect
earnings flow). Progress increments by items sold, not by currency value.

---

## 5. Quest Pools

### 5.1 Pool Structure

Each QuestDefinition belongs to a pool by cadence. The assignment Edge
Function draws randomly from the eligible pool, weighted by the weight field.

### 5.2 Daily Pool: draw 3 per player

No duplicates within a day. Mix constraint: at most 2 from the same
QuestType to ensure variety. Recommended pool size at launch: 15-20.

### 5.3 Weekly Pool: draw 2 per player

No duplicates within a week. Weekly quests are larger in scope than
dailies: more targets, harder requirements, better rewards.
Recommended pool size at launch: 8-12.

### 5.4 Zone-Tier Gating

minZoneTier prevents a T1 player from getting a "Defeat 10 [Void]" quest
they cannot complete. Assignment filters the pool:

```csharp
var eligible = allDefinitions
    .Where(q => q.cadence == cadence)
    .Where(q => q.minZoneTier <= player.highestZoneTier)
    .Where(q => q.maxZoneTier >= player.highestZoneTier);
```

---

## 6. Reward Values

Rewards should feel meaningful but not dominant. A full day of quests
adds roughly 10-15% to a player's normal daily XP and a useful currency bonus.

### 6.1 Daily Quest Rewards (per quest, 3 per day)

| Reward type | T1 quest | T3 quest | Notes |
|-------------|----------|----------|-------|
| Talent XP | 400-600 | 800-1200 | Scales with zone tier |
| Combat XP | 300-500 | 600-900 | For combat quests |
| Gold Marks | 8-12 | 15-25 | Primary daily currency |
| Silver Marks | 50-150 | 100-200 | Secondary, lower-tier |
| Item | 1x Crude rare mat | 1x Refined rare mat | Zone-appropriate |

### 6.2 Weekly Quest Rewards (per quest, 2 per week)

| Reward type | Range | Notes |
|-------------|-------|-------|
| Talent XP | 3,000-8,000 | Significant weekly boost |
| Combat XP | 2,000-5,000 | |
| Gold Marks | 60-180 | Meaningful weekly income |
| Item | 1x Pristine to 1x Masterwork rare mat | Best item reward in base game |

Weekly quests are the primary source of Pristine and Masterwork rare
materials outside dungeons and raids. This gives non-dungeon players a
path to high-quality rare mats, consistent with the additive principle.

---

## 7. Reward Grant, Server RPC

Do NOT grant currency via direct client write. Currency is client-authoritative
and SaveCurrency patches the absolute value, which clobbers concurrent server
credits (the same bug hit with Exchange sales). Route all quest reward claims
through a server RPC.

```sql
create or replace function collect_quest_reward(p_quest_row_id uuid)
returns json
language plpgsql
security definer
as $$
declare
    v_quest  player_quests%rowtype;
    v_def    json;
begin
    -- Validate ownership and completeness
    select * into v_quest
    from player_quests
    where id = p_quest_row_id
      and player_id = auth.uid()
      and completed = true
      and claimed = false;

    if not found then
        raise exception 'Quest not claimable';
    end if;

    -- Mark claimed immediately (idempotency guard)
    update player_quests set claimed = true where id = p_quest_row_id;

    -- Grant currency server-side additively
    update players
    set gold_marks   = gold_marks   + (v_def->>'goldMarks')::int,
        silver_marks = silver_marks + (v_def->>'silverMarks')::int
    where id = auth.uid();

    -- Return non-currency reward payload for client to apply
    return json_build_object(
        'success', true,
        'rewards', v_def->'rewards'
    );
end;
$$;
```

Client receives the payload and applies:
- Talent XP via TalentManager.AddXP(name, amount)
- Combat XP via CombatXPManager.AddCombatXP(grimoireId, amount)
- Items via InventoryManager.AddItem(ItemData, quality, qty)
Currency is already credited server-side before the payload returns.

---

## 8. Assignment Edge Function

```typescript
// supabase/functions/assign_quests/index.ts

Deno.serve(async (req) => {
    const { playerId, cadence } = await req.json();
    const supabase = createClient(/* service role key */);

    // Check if current quests are still valid
    const { data: existing } = await supabase
        .from('player_quests')
        .select('resets_at')
        .eq('player_id', playerId)
        .eq('cadence', cadence)
        .limit(1)
        .single();

    if (existing && new Date(existing.resets_at) > new Date()) {
        return new Response('quests still active', { status: 200 });
    }

    // Clear expired quests
    await supabase
        .from('player_quests')
        .delete()
        .eq('player_id', playerId)
        .eq('cadence', cadence)
        .lt('resets_at', new Date().toISOString());

    // Compute next reset
    const now = new Date();
    let resetsAt: Date;
    if (cadence === 'daily') {
        resetsAt = new Date(Date.UTC(
            now.getUTCFullYear(), now.getUTCMonth(),
            now.getUTCDate() + 1, 0, 0, 0
        ));
    } else {
        const daysUntilMonday = (8 - now.getUTCDay()) % 7 || 7;
        resetsAt = new Date(Date.UTC(
            now.getUTCFullYear(), now.getUTCMonth(),
            now.getUTCDate() + daysUntilMonday, 0, 0, 0
        ));
    }

    // Fetch eligible pool for player's zone tier
    const playerTier = await getPlayerHighestZoneTier(playerId, supabase);
    const pool = await getEligiblePool(cadence, playerTier, supabase);

    // Draw quests (weighted random, no duplicates, type mix constraint)
    const count = cadence === 'daily' ? 3 : 2;
    const drawn = drawQuests(pool, count);

    // Insert new rows
    await supabase.from('player_quests').insert(
        drawn.map(q => ({
            player_id:    playerId,
            quest_id:     q.questId,
            cadence,
            target_count: q.targetCount,
            resets_at:    resetsAt.toISOString(),
        }))
    );

    return new Response(JSON.stringify({ resetsAt, quests: drawn }), {
        headers: { 'Content-Type': 'application/json' }
    });
});
```

---

## 9. Progress Tracking

Progress tracked client-side in memory, synced to player_quests.progress
on change. Debounce writes to avoid write storms (max once per 5s).

```csharp
public class QuestProgressTracker : MonoBehaviour
{
    void Start() {
        InventoryManager.OnItemAdded      += OnItemAdded;
        CombatManager.OnEnemyKilled       += OnEnemyKilled;
        CombatManager.OnBossKilled        += OnBossKilled;
        TalentManager.OnXPAdded           += OnTalentXP;
        DungeonManager.OnDungeonComplete  += OnDungeonComplete;
        ExchangeManager.OnSaleComplete    += OnSaleComplete;
    }

    void OnItemAdded(string itemName, int qty) {
        foreach (var quest in activeQuests
            .Where(q => q.type == QuestType.GatherItem
                     && q.targetId == itemName))
            IncrementProgress(quest, qty);
    }

    void IncrementProgress(PlayerQuest quest, int amount) {
        quest.progress = Mathf.Min(quest.progress + amount, quest.targetCount);
        if (quest.progress >= quest.targetCount) quest.completed = true;
        SyncDebounced(quest); // max one write per 5s per quest
    }
}
```

---

## 10. Push Notifications

**Daily quest ready:** "New quests are waiting — check the board."
Fires at 00:00 UTC daily via existing FCM pipeline. Single message per
day, not per quest.

**Quest complete:** In-game P4 notification only (same channel as ore
node and processing complete). Not worth an FCM push for a single quest.

---

## 11. Launch Quest Pool

### Daily Quests (15 definitions)

| questId | Type | Target | Count | Zone | Rewards | Weight |
|---------|------|--------|-------|------|---------|--------|
| gather_wolf_pelts | GatherItem | Wolf Pelt | 10 | T3 | 800 Trapping XP, 12 GM | 10 |
| gather_iron_ore | GatherItem | Iron Ore | 20 | T2 | 600 Delving XP, 10 GM | 12 |
| gather_common_herb | GatherItem | Common Herb | 30 | T1 | 500 Foraging XP, 8 GM | 15 |
| smelt_iron_bars | ProcessItem | Iron Bar | 10 | T2 | 700 Smelting XP, 12 GM | 10 |
| tan_fox_leather | ProcessItem | Fox Leather | 8 | T2 | 600 Tanning XP, 10 GM | 10 |
| defeat_beasts | DefeatEnemies | [Beast] | 20 | T1 | 600 Combat XP, 10 GM | 12 |
| defeat_undead | DefeatEnemies | [Undead] | 20 | T2 | 700 Combat XP, 12 GM | 10 |
| defeat_void | DefeatEnemies | [Void] | 15 | T3 | 900 Combat XP, 15 GM | 8 |
| defeat_elites | DefeatElites | any | 3 | T2 | 800 Combat XP, 1x Refined Gemstone | 8 |
| earn_felling_xp | EarnTalentXP | Felling | 1,500 | T1 | 500 Felling XP, 8 GM | 10 |
| earn_runesmithing_xp | EarnTalentXP | Runesmithing | 1,500 | T2 | 600 Runesmithing XP, 12 GM | 8 |
| sell_exchange | SellOnExchange | any | 5 | T1 | 20 GM | 8 |
| complete_dungeon | CompleteDungeon | any | 1 | T2 | 1,200 Combat XP, 1x Refined rare mat | 6 |
| defeat_zone_boss | DefeatBoss | any | 1 | T1 | 1,000 Combat XP, 1x Refined rare mat | 6 |
| enter_cinderpeak | ReachZone | Cinderpeak | 1 | T3 | 500 Combat XP, 10 GM | 4 |

### Weekly Quests (10 definitions)

| questId | Type | Target | Count | Zone | Rewards | Weight |
|---------|------|--------|-------|------|---------|--------|
| weekly_defeat_undead | DefeatEnemies | [Undead] | 100 | T2 | 5,000 Combat XP, 80 GM | 10 |
| weekly_defeat_void | DefeatEnemies | [Void] | 75 | T3 | 6,000 Combat XP, 100 GM, 1x Pristine Void Spore | 8 |
| weekly_defeat_elites | DefeatElites | any | 15 | T2 | 5,000 Combat XP, 1x Pristine Gemstone | 10 |
| weekly_defeat_boss | DefeatBoss | any | 3 | T1 | 4,000 Combat XP, 80 GM | 8 |
| weekly_complete_dungeons | CompleteDungeon | any | 3 | T2 | 6,000 Combat XP, 1x Pristine rare mat | 8 |
| weekly_smelt_steel | ProcessItem | Steel Bar | 20 | T3 | 6,000 Smelting XP, 100 GM | 8 |
| weekly_craft_weapon | CraftItem | any weapon | 2 | T2 | 5,000 Runesmithing XP, 1x Pristine Gemstone | 6 |
| weekly_gather_drake | GatherItem | Drake Scale | 5 | T3 | 5,000 Trapping XP, 1x Pristine Amber | 6 |
| weekly_earn_talent | EarnTalentXP | any | 8,000 | T1 | 4,000 Talent XP, 80 GM | 10 |
| weekly_sell_exchange | SellOnExchange | any | 20 | T1 | 150 GM | 8 |

---

## 12. DLC Faction Hook

Every QuestDefinition carries factionId and factionReputationAward.
Both are empty/0 in base game. When the faction DLC ships:

- Faction-aligned quests populate factionId with the faction name
- Claiming that quest awards factionReputationAward reputation via
  FactionManager.AddReputation(factionId, amount)
- collect_quest_reward RPC gains a faction credit branch when factionId
  is non-empty

No schema changes needed at DLC launch. The hook is in from day one.

---

## 13. Acceptance Criteria

- Daily quests: 3 assigned on first board open after 00:00 UTC, reset correctly
- Weekly quests: 2 assigned on first board open after Monday 00:00 UTC
- Idle gathering, idle combat, and idle processing all increment applicable
  quest progress without requiring active play
- Currency rewards are granted server-side via RPC, never via direct client write
- Claiming a quest marks it claimed immediately; double-tap does not double-grant
- Zone-tier gating prevents quests appearing for content the player has not unlocked
- factionId and factionReputationAward fields exist on QuestDefinition with
  empty/0 defaults
- Quest Board panel exists as a new GamePanel entry with Daily and Weekly tabs,
  progress bars, and a Claim button
- Countdown timer displays time to next reset from server resets_at value

---

*Path: docs/daily-weekly-quest-system.md*
*Version 1.0: data model, quest types, reward values, server RPC,*
*assignment Edge Function, progress tracking, push notifications, launch pool.*
