---
type: design-spec
version: 1.0
updated: 2026-07-31
path: docs/offline-combat-wywa.md
implements: GameManager.OnApplicationPause, StopZoneCombat, IdleSessionResult (or parallel),
            WhileYouWereAwayUI.ShowResult
companion: offline-combat-wywa-REQUEST.md
---

# Offline Combat on the While-You-Were-Away Screen
### Version 1.0

Resolves all design questions in `offline-combat-wywa-REQUEST.md`.

---

## 1. Model Decision: Summary Only (Option A)

No offline combat progression. When the app backgrounds mid-combat, the live
session stops accruing and the results so far are persisted and shown on return.

**Why not Option B (estimated offline kills):**
Zone combat is a real-time loop where player decisions, weak-point timing,
ability ring use, consumable choices, determine outcomes. Estimating kills
offline would produce results disconnected from what the player was actually
doing. It also introduces a kill-rate model that needs to be tuned per zone
and per player build, which is significant complexity for a feature whose value
is showing the player what happened, not simulating play they weren't present for.

Option B can be added later as a premium or Slaying-mastery-gated enhancement
if the community asks for it. The infrastructure built here (running tally,
persist-on-background) supports it without rework.

---

## 2. What Gets Persisted and Shown

When the app backgrounds during active zone combat, the WYWA screen on return shows:

| Field | Source | Notes |
|-------|--------|-------|
| Zone name | `CombatManager.ActiveZoneId` | "You were fighting in Grimwood Fringe" |
| Grimoire | `PlayerState.equippedGrimoireId` | "as Sharpshot" |
| XP earned | Running tally flushed from `CombatXPManager` | Per-Grimoire XP from all hits + kills in the session |
| Slaying XP | Running tally from `TalentManager` (Slaying) | Separate from Grimoire XP |
| Items dropped | Running tally from combat drop rolls | All items that rolled and landed during the session |
| Consumables used | Running tally from auto-eat / manual use | NEW render row, see Section 5 |
| Knockout flag | `CombatManager.wasKnockedOut` | If true, shows knockout note and stops tallies at that point |

**What is NOT shown:**
- Damage dealt or taken (not relevant to the WYWA summary)
- Enemies remaining in the queue (session is over)
- Estimated loot the player would have gotten if they had stayed

---

## 3. Data Model

### 3.1 Running combat tally

Add a persistent running tally to `CombatManager`, updated on every kill, drop,
and consumable use during the live session:

```csharp
public class CombatSessionTally
{
    public string zoneId;
    public string grimoireId;
    public int grimoireXpEarned;
    public int slayingXpEarned;
    public Dictionary<string, int> itemsDropped;   // itemId -> quantity
    public Dictionary<string, int> itemsConsumed;  // itemId -> quantity
    public bool wasKnockedOut;
    public DateTime sessionStartUtc;
}

// In CombatManager:
private CombatSessionTally _currentTally;

void OnZoneCombatStart(string zoneId, string grimoireId) {
    _currentTally = new CombatSessionTally {
        zoneId = zoneId,
        grimoireId = grimoireId,
        sessionStartUtc = DateTime.UtcNow,
    };
}

void OnKill(EnemyData enemy) {
    _currentTally.grimoireXpEarned += computedGrimoireXp;
    _currentTally.slayingXpEarned  += enemy.slayingXP;
    foreach (var drop in rolledDrops)
        _currentTally.itemsDropped.TryAdd(drop.itemId, 0);
        _currentTally.itemsDropped[drop.itemId] += drop.quantity;
}

void OnConsumableUsed(string itemId, int qty) {
    _currentTally.itemsConsumed.TryAdd(itemId, 0);
    _currentTally.itemsConsumed[itemId] += qty;
}

void OnKnockout() {
    _currentTally.wasKnockedOut = true;
    // Tally stops updating after knockout, no further events are recorded
}
```

### 3.2 Persist on background

```csharp
// GameManager.OnApplicationPause(bool pausing):
if (pausing && CombatManager.IsInCombat) {
    CombatSessionTally tally = CombatManager.FlushAndStopCombat();
    // Serialize and persist to PlayerPrefs or local file:
    PlayerPrefs.SetString("PendingCombatWYWA", JsonUtility.ToJson(tally));
    PlayerPrefs.Save();
}
```

`FlushAndStopCombat` calls the existing `StopZoneCombat` logic (flushing pending
XP to `CombatXPManager`) and returns the completed tally. Items already rolled
and added to inventory during the live session remain in inventory, the tally
is display-only, not a grant.

### 3.3 On return: read and show

```csharp
// GameManager.OnApplicationFocus or startup:
if (PlayerPrefs.HasKey("PendingCombatWYWA")) {
    string json = PlayerPrefs.GetString("PendingCombatWYWA");
    CombatSessionTally tally = JsonUtility.FromJson<CombatSessionTally>(json);
    PlayerPrefs.DeleteKey("PendingCombatWYWA");

    WhileYouWereAwayUI.ShowCombatResult(tally);
}
```

Show combat WYWA before (or instead of) the idle WYWA if both have pending
results. If both exist (player gathered, then fought, then backgrounded),
show combat result first, then idle result, or merge into a single screen
with two sections. Combat section first.

---

## 4. Knockout Handling

If `wasKnockedOut` is true:

```
WYWA header: "You were knocked out in Grimwood Fringe"
             (vs "You were away from Grimwood Fringe" if not knocked out)
```

Show all XP and drops earned BEFORE the knockout. Nothing earned after, because
nothing was earned after, the tally stopped at `OnKnockout()`. No partial
rewards are fabricated. No auto-revive-and-continue for the offline case.

The knocked-out state means the player's session ended at that point. WYWA
shows an honest report of what they earned before it happened.

---

## 5. WYWA Render Changes (WhileYouWereAwayUI)

### 5.1 New: ShowCombatResult

Add a parallel render path to `ShowResult` for combat tallies:

```csharp
public void ShowCombatResult(CombatSessionTally tally)
{
    // Header
    zoneLabel.text = tally.wasKnockedOut
        ? $"Knocked out in {ZoneRegistry.GetDisplayName(tally.zoneId)}"
        : $"Away from {ZoneRegistry.GetDisplayName(tally.zoneId)}";
    grimoireLabel.text = $"as {GrimoireRegistry.GetDisplayName(tally.grimoireId)}";

    // XP rows (reuse existing xpGained row style)
    RenderXpRow("Grimoire XP", tally.grimoireXpEarned);
    RenderXpRow("Slaying XP",  tally.slayingXpEarned);

    // Items dropped (reuse existing itemsGained row style)
    foreach (var (itemId, qty) in tally.itemsDropped)
        RenderItemRow(itemId, qty, isGain: true);

    // Items consumed (NEW row style, show as spent/used, not gained)
    if (tally.itemsConsumed.Count > 0)
    {
        RenderSectionHeader("Consumables Used");
        foreach (var (itemId, qty) in tally.itemsConsumed)
            RenderItemRow(itemId, qty, isGain: false);  // grey or red tint
    }
}
```

### 5.2 New render row: itemsConsumed

`ShowResult` currently renders only `xpGained` and `itemsGained`. The
consumables-used section is new render work. Use a muted or desaturated
style (grey icon, quantity in parentheses) to distinguish "spent" from
"gained." The user explicitly asked for this visibility.

Example display:
```
AWAY FROM GRIMWOOD FRINGE  (as Sharpshot)
───────────────────────────────────────
Grimoire XP gained       +124
Slaying XP gained         +18

Items gained:
  Wolf Pelt               × 2
  Bone Fragment           × 1

Consumables used:
  Crude Healing Draught   × 1
```

---

## 6. Zero-result Case

If the player backgrounded immediately after entering a zone (tally is empty
or near-empty, no kills, no drops, no XP), do not show the WYWA combat result.
Delete the pending key silently.

```csharp
if (tally.grimoireXpEarned == 0 && tally.itemsDropped.Count == 0)
{
    PlayerPrefs.DeleteKey("PendingCombatWYWA");
    return; // skip WYWA
}
```

---

## 7. Acceptance Criteria

- Backgrounding the app during zone combat shows a WYWA screen on return
  with XP earned, drops obtained, and consumables used from the live session.
- A knockout during the session is noted in the header; rewards stop at the
  knockout point and nothing is fabricated after.
- Items that dropped during the live session are already in inventory on return
  (the WYWA is display-only, not a grant, XP was already credited via
  `CombatXPManager.AddCombatXP` during the live session).
- Backgrounding during idle (not combat) shows only the existing idle WYWA.
- If both an idle result and a combat result are pending, both are shown
  (combat result first).
- The "Consumables Used" row renders in a distinct style from "Items Gained."
- A tally with zero XP and zero drops does not show a WYWA screen.

---

*Path: docs/offline-combat-wywa.md*
*Resolves: offline-combat-wywa-REQUEST.md (all 6 design questions).*
*Model: Option A (summary only). Option B (offline kill estimation) is deferred.*
