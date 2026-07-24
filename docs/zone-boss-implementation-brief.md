---
type: implementation-brief
spec: combat-engagement-spec.md (v0.2), enemy-zone-tables.md
updated: 2026-07-11
purpose: Implement zone boss spawning, pre-boss lobby, and boss-only zone co-op
         into the existing CombatManager and combat view infrastructure.
---

# Zone Boss, Implementation Brief

## What's Already Built

Per `implementation-status.md`:
- `CombatManager` real-time loop, weighted spawn, elite roll, respawn delay
- `EnemyData.isBoss` flag on authored enemy assets
- `ZoneCombatView` with HP bars and attack cadence bars
- Push notification system (FCM) wired
- Guild membership and roster available via Supabase

---

## Boss Spawn, Zone Event (not next fight)

Boss spawning is a **zone event separate from current combat.**
The player's current fight continues uninterrupted. Boss appears
in the zone alongside it, waiting.

```csharp
void OnEnemyKilled(EnemyData enemy) {
    // ... existing XP/loot/respawn logic ...

    // Boss roll, active sessions only, one boss at a time
    if (!enemy.isBoss && !enemy.isElite
        && CombatManager.IsActiveSession
        && !_bossActive) {
        if (Random.value < _bossSpawnChance) { // 0.05f flat
            TriggerBossSpawnEvent();
            // Do NOT replace next spawn, normal combat continues
        }
    }
}

void TriggerBossSpawnEvent() {
    _bossActive = true;
    _bossSpawnTime = Time.time;
    _bossDespawnAt = Time.time + 600f; // 10 minutes from spawn

    // Show in-zone banner (non-blocking, floats over combat view)
    ZoneCombatView.ShowBossBanner(
        $"{currentBoss.enemyName} has appeared!",
        onTap: OpenPreBossLobby
    );

    // Push notification (P1, fires even if app is backgrounded)
    NotificationManager.Send(
        title: $"{currentBoss.enemyName} has appeared!",
        body: $"{currentZone.zoneName}, 10 minutes to engage",
        priority: NotificationPriority.P1,
        deepLink: "grimoire://boss-lobby/" + currentZone.zoneId
    );

    StartCoroutine(BossDespawnCountdown());
}
```

Normal zone combat continues while the boss banner floats at the top.
Player finishes their fight, preps, then taps the banner to enter the lobby.

---

## Boss Despawn Countdown

```csharp
IEnumerator BossDespawnCountdown() {
    while (Time.time < _bossDespawnAt && _bossActive) {
        yield return new WaitForSeconds(1f);

        float remaining = _bossDespawnAt - Time.time;

        // Update banner countdown display
        ZoneCombatView.UpdateBossCountdown(remaining);

        // If lobby is open, update it too
        PreBossLobbyUI.UpdateCountdown(remaining);
    }

    if (_bossActive) {
        // Despawned without engagement
        _bossActive = false;
        ZoneCombatView.HideBossBanner();
        PreBossLobbyUI.ShowBossRetreated(); // closes lobby if open
        ZoneCombatView.ShowLog($"{currentBoss.enemyName} has retreated.");
    }
}
```

---

## Pre-Boss Lobby

### Opening the lobby

Tapping the boss banner or deep-link notification opens `PreBossLobbyUI`.
If the player is currently in combat when they tap, that combat is forfeited, 
same as pressing the back/X button. Enemy does not die; no XP or loot awarded.

```csharp
void OpenPreBossLobby() {
    if (CombatManager.IsInActiveFight) {
        CombatManager.ForfeitCurrentFight(); // no XP, no loot, enemy not killed
    }
    PreBossLobbyUI.Open(currentBoss, _bossDespawnAt, currentZone);
}
```

### Lobby UI, `PreBossLobbyUI.cs`

```
┌─────────────────────────────────────┐
│  [Boss Name]                      │
│  [Zone Name]                        │
│  Retreats in: 07:42                 │
│                                     │
│  [HOST]  DustinSW         Ready  │
│  [SLOT]  PlayerName       Ready  │
│  [SLOT], Empty, [Invite] │
│                                     │
│  [ Kick ] (host only, on members)  │
│                                     │
│  [ START FIGHT ] (host, all ready) │
└─────────────────────────────────────┘
```

**Lobby rules:**
- Host is the player who opened the lobby (spawned the boss)
- Maximum 3 players total (host + 2 guests)
- Host can invite guild members only, shows online guild roster
- Host can kick any non-ready member
- START FIGHT only enabled when ALL players in lobby are marked ready
- If countdown hits 0 while lobby is open → "Boss has retreated" screen → lobby closes → all players returned to main hub

### Supabase table, `boss_lobby`
```sql
CREATE TABLE boss_lobby (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id       TEXT NOT NULL,
    boss_id       TEXT NOT NULL,
    host_id       UUID REFERENCES players(id),
    player_2_id   UUID REFERENCES players(id),
    player_3_id   UUID REFERENCES players(id),
    status        TEXT DEFAULT 'waiting', -- waiting / ready / active / complete
    despawn_at    TIMESTAMPTZ NOT NULL,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: readable by participants only
```

Use Supabase real-time to sync lobby state, host writes, guests read.
When host taps Start, set `status = 'active'` → all clients transition to boss fight.

---

## Inviting Guild Members

From the lobby, host taps [Invite] on an empty slot:
- Shows online guild roster (fetch from `guild_members` where `last_active > now() - interval '5 minutes'`)
- Tapping a member sends them an invite notification

**Invite notification (P1):**
```
DustinSW invited you to fight [Boss Name]!
[Zone Name], 06:30 remaining
[ Join Lobby ]
```

**Invited player receiving invite mid-combat:**
- Notification banner appears over their combat view
- Tapping it forfeits their current fight (no XP/loot, enemy not killed)
- They enter the lobby as a guest

**Invited player accepting:**
- Joins lobby, shown as their slot
- Taps Ready when prepared
- If they decline or ignore: slot stays empty, host can invite someone else

---

## Boss HP Scaling

Boss HP scales with party size. Base HP is the solo value from `EnemyData`.
Each additional player adds 60% of base HP:

```csharp
float GetScaledBossHP(int playerCount, float baseHP) {
    // 1 player: 100%, base HP
    // 2 players: 160%, base + 60%
    // 3 players: 220%, base + 120%
    return baseHP * (1f + (playerCount - 1) * 0.60f);
}
```

| Party size | HP multiplier | Example (base 2,400 HP) |
|-----------|-------------|------------------------|
| 1 (solo) | ×1.0 | 2,400 HP |
| 2 players | ×1.6 | 3,840 HP |
| 3 players | ×2.2 | 5,280 HP |

HP scaling set on lobby start, not on boss spawn. A solo player who fights
the boss alone gets the base HP, scaling only applies if others join.

---

## Boss Fight, Multi-Player Combat

When host taps Start:
1. All lobby players transition to boss fight view simultaneously
2. Each player sees their own over-the-shoulder combat view
3. Party frames show all participants' HP at screen top (same as dungeon/raid party frames)
4. Quick-Comm available: "Need help!" / "I'm fine!" / "Focus boss!"
5. Boss has scaled HP shared across all players, damage from any player reduces the shared pool
6. If a player is defeated (HP → 0): they retreat, removed from the fight. Remaining players continue
7. If all players defeated: boss survives, returns to zone event state briefly before despawning
8. Boss defeated: fight ends for all participants simultaneously

**Shared boss HP, Supabase real-time:**
Boss HP is authoritative on the server. Each player's damage is sent to Supabase,
server reduces the shared HP pool, broadcasts current HP to all participants via
real-time channel. Same pattern as guild voting real-time sync, already proven.

```sql
-- boss_lobby.boss_current_hp updated by each hit
-- All participants subscribed to real-time on boss_lobby row
```

---

## Loot & XP, Independent Per Player

Each player gets their own loot roll and XP award on boss defeat:

```csharp
void OnBossDefeated() {
    foreach (var participant in activeLobby.participants) {
        LootManager.RollBossLoot(currentBoss, participant);
        CombatXPManager.AwardKill(currentBoss, participant.equippedGrimoire, isBoss: true);
    }
}
```

Each player's loot goes to their own inventory. No shared pool, no loot drama.
XP goes to each player's currently equipped Grimoire combat level.

---

## Post-Fight Flow

After boss defeated OR all players defeated:

```
Results screen shown to all participants
, Boss defeated: loot items, XP gained, "Victory" header
, All defeated: "Defeated" header, no loot, no XP
         ↓
[ Return to Hub ] button
         ↓
All players return to main hub / inventory
NOT returned to zone idle, zone combat does not resume automatically
```

```csharp
void OnBossFightEnded(bool victory) {
    _bossActive = false;
    activeLobby.status = "complete";

    ResultsScreenUI.Show(
        victory: victory,
        loot: localPlayerLoot,
        xpGained: localPlayerXP,
        onClose: () => NavigationManager.GoTo(Screen.Hub)
    );
    // NavigationManager.GoTo(Screen.Hub), NOT zone combat
}
```

---

## Boss vs Elite, Reference Table

| Property | Standard | Elite | Zone Boss |
|----------|---------|-------|----------|
| `isElite` | false | true | false |
| `isBoss` | false | false | true |
| Spawn | Weighted pool | After standard kill | After standard kill (active only) |
| Chance | Base pool | 6%+scaling | Flat 5% |
| Active only | No | No | **Yes** |
| Despawn | None | None | 10 min from spawn |
| Multiplayer | No | No | **Yes, up to 3** |
| HP scales | No | No | **Yes, +60% per extra player** |
| Post-fight | Resume idle | Resume idle | **Hub, no auto-resume** |

---

## Phase 1 Goal

- Boss roll fires after standard kills during active sessions
- In-zone banner appears with countdown, does not interrupt current fight
- Tapping banner opens Pre-Boss Lobby
- Host can invite 2 guild members, kick non-ready members
- Start Fight requires all ready
- Boss despawn closes lobby with "retreated" message
- Boss HP scales with party size
- Each player gets own loot/XP roll
- Post-fight returns to hub, not zone idle

---

*Path: `docs/zone-boss-implementation-brief.md`*
