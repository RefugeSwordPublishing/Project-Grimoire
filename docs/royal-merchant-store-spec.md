---
type: design-spec
version: 1.0
updated: 2026-07-31
path: docs/royal-merchant-store-spec.md
resolves: royal-merchant-store-REQUEST.md
implements: RoyalMerchantUI (rebuild), RoyalMerchantManager
companion: monetization-scope.md (v0.3), consumables-spec.md
---

# Royal Merchant Store Spec
### Version 1.0

---

## 1. Reconcile Decisions

### 1.1 Location: top-level nav entry (as built)

The Royal Merchant stays as a top-level nav entry, not an Exchange tab.
`monetization-scope.md` placed it inside the Exchange when the store vision
was narrower. The full categorized store is a primary player destination
that deserves its own surface. Moving it inside the Exchange would bury it
and make the Exchange screen overly dense.

The Exchange may deep-link to specific store categories:
- "Get more listing slots" links to Royal Merchant > Inventory category.
- "Upgrade your store" links to Royal Merchant > Inventory with the listing
  slot row highlighted.

### 1.2 Auto-eat tiers: re-homed to Consumables category

The existing auto-eat upgrade tiers (T1-T4, bought with GM, wired to
`SettingsManager.SetAutoEatTier`) become the Consumables category of the
unified store. The tier model and GM prices are unchanged. The purchase
logic is reused as-is.

### 1.3 IAP build boundary

Two modes per category row:

**Live (build now):** GM purchase. `RoyalMerchantManager.Purchase(itemId, gmCost)`.
Deducts GM, applies the unlock, persists to player record. Uses existing
`SaveCurrency` pattern with the server-side additive RPC to avoid clobber.

**Stubbed (IAP pending):** Row renders with a lock icon and the label
"Available with in-app purchases." Tap does nothing except show an info
modal: "In-app purchases coming soon." No Unity IAP or RevenueCat integration
in this pass, CLAUDE.md prohibits hand-built receipt validation.

### 1.4 Accessory slot: not assumed

Hunt Trophies and boss accessories reference an accessory slot that does not
exist yet. The store spec does not include any accessory items. When the
accessory slot ships as a separate task, those items can be added to
Cosmetics or a new Accessories category.

---

## 2. Category Structure

Five tabs. Order left to right in the tab bar:

```
[ Consumables ] [ Inventory ] [ Quests & Tasks ] [ Cosmetics ] [ Grimoires & DLC ]
```

Default tab on open: Consumables (most immediately actionable).

---

## 3. Consumables Category

**Currency:** GM only. **Status:** Live.

All items in this category are purchased with Gold Marks and take effect
immediately on purchase. No IAP in this category.

### 3.1 Auto-Eat Upgrade Tiers

Existing as-built behavior, re-homed here. Purchased once per tier, permanent
unlock. Current tier shown with a checkmark; higher tiers shown with cost and
a buy button; lower tiers greyed as already owned.

| Tier | Display Name | Effect | GM Cost |
|------|-------------|--------|---------|
| T1 | Auto-Eat: Basic | Auto-consumes food when HP drops below 30% | 0 (default) |
| T2 | Auto-Eat: Quick | Triggers at 40% HP, shorter eat delay | 80 GM |
| T3 | Auto-Eat: Smart | Triggers at 50% HP, selects best available food | 200 GM |
| T4 | Auto-Eat: Elite | Triggers at 60% HP, queues a second consumable if available | 450 GM |

Display: one card per tier. T1 is always unlocked and shows "(included)".
Each card shows the tier name, effect summary, cost, and a "Upgrade" button
(or "Current" badge if active, or "Owned" if a higher tier is active).

### 3.2 Auto-Drink Mana Upgrade Tiers

Parallel system to Auto-Eat for mana consumables. Arcanist-path players
only benefit from this, but it's available to all.

| Tier | Display Name | Effect | GM Cost |
|------|-------------|--------|---------|
| T1 | Auto-Drink: Off | Manual mana management only | 0 (default) |
| T2 | Auto-Drink: Basic | Auto-consumes mana vial when Mana drops below 20% | 80 GM |
| T3 | Auto-Drink: Smart | Triggers at 30% Mana, selects best available vial | 200 GM |

**Implementation note:** `SettingsManager` needs `SetAutoEatTier` mirrored
as `SetAutoDrinkTier`. Same pattern, same storage key style, same server-side
persist. No new architecture needed.

---

## 4. Inventory Category

**Currency:** GM for standard expansions. IAP (stubbed) for large bundles.
**Status:** GM tiers live; IAP rows stubbed.

All slot expansions are permanent account-wide unlocks.

### 4.1 Inventory Slot Packs

| Item | Description | GM Cost | Status |
|------|-------------|---------|--------|
| Inventory Pack: Small | +10 inventory slots | 150 GM | Live |
| Inventory Pack: Medium | +25 inventory slots | 320 GM | Live |
| Inventory Pack: Large | +50 inventory slots | IAP | Stubbed |
| Inventory Pack: Vault | +100 inventory slots | IAP | Stubbed |

Display: show all four rows. GM rows have a buy button. IAP rows show the
lock icon and "In-app purchases" label.

**Implementation:** `PlayerData.inventorySlots += amount`. Persist to
Supabase `players` table. RLS: player writes own record only.

### 4.2 Exchange Listing Slots

| Item | Description | GM Cost | Status |
|------|-------------|---------|--------|
| Exchange Slot +1 | One additional active Exchange listing | 100 GM | Live |
| Exchange Slot +3 | Three additional active Exchange listings | 260 GM | Live |
| Exchange Slot +10 | Ten additional active listings | IAP | Stubbed |

Default listing cap: 5 (as per Exchange design). Purchased slots stack.
Display current slot count and cap: "Active listings: 3 / 8."

### 4.3 Guild Bank Slots

| Item | Description | GM Cost | Status |
|------|-------------|---------|--------|
| Guild Bank +5 Slots | Expand guild bank by 5 slots | 200 GM | Live |
| Guild Bank +15 Slots | Expand guild bank by 15 slots | 500 GM | Live |

Guild bank expansion requires Officer+ role to purchase. Show a lock icon
with "Guild Officer required" if the player is a member without officer rank.
Purchase calls the existing `expand_guild_bank` RPC (migration already exists
per implementation-status.md).

---

## 5. Quests & Tasks Category

**Currency:** GM only. **Status:** Live.

All items in this category are permanent unlocks.

### 5.1 Quest Slot Upgrades

The base game provides 3 daily quest slots and 2 weekly quest slots. Additional
slots can be purchased here.

| Item | Description | GM Cost |
|------|-------------|---------|
| Daily Quest Slot +1 | Fourth daily quest slot | 120 GM |
| Daily Quest Slot +2 | Fifth daily quest slot | 280 GM |
| Weekly Quest Slot +1 | Third weekly quest slot | 200 GM |

Display: show current slot count. Purchased slots are non-refundable.

**Implementation:** `PlayerData.dailyQuestSlots` and `weeklyQuestSlots` fields
(int, default 3 and 2). `assign_quests` Edge Function already reads these
counts when drawing from the pool, confirm the draw count reads
`playerData.dailyQuestSlots` rather than a hardcoded 3.

### 5.2 Slaying Task Slot Upgrades

The Slaying talent spec grants the 4th task slot at Slaying Lv25. Slots
5-8 are purchasable here. These exist alongside the Slaying level unlock,
not instead of it, the Slaying Lv25 slot is always free.

| Item | Description | GM Cost | Requirement |
|------|-------------|---------|-------------|
| Slaying Task Slot 5 | Fifth simultaneous Slaying task | 150 GM | Slaying 30+ |
| Slaying Task Slot 6 | Sixth simultaneous Slaying task | 300 GM | Slaying 50+ |
| Slaying Task Slot 7 | Seventh simultaneous Slaying task | 500 GM | Slaying 70+ |
| Slaying Task Slot 8 | Eighth simultaneous Slaying task | IAP | Slaying 90+ |

Slot 8 is stubbed (IAP), the diminishing returns at 8 concurrent tasks
makes it a whale purchase, appropriate for IAP. Slots 5-7 are achievable GM
sinks for engaged players who invest in Slaying.

Show locked rows with their Slaying requirement if the player is below it:
"Requires Slaying 50" with a greyed-out row.

---

## 6. Cosmetics Category

**Currency:** IAP only. **Status:** All stubbed.

No GM cosmetics in the base game. Keeping cosmetics premium avoids pay-to-win
optics (cosmetics never affect stats) and maintains a clean IAP value proposition.

All rows in this category display with lock icons and "In-app purchases" labels.
Tapping any row shows the info modal: "Cosmetics coming with in-app purchases."

### 6.1 Grimoire Skins

One skin per Grimoire class available at launch of IAP. Shown as a preview
card with the skin name and a greyed locked state.

| Item | Description |
|------|-------------|
| Sharpshot: Shadow Hunter | Dark recolor with void-edge trim |
| Runeweaver: Starweave | Deep blue with constellation-pattern robes |
| Lone Wanderer: Outcast | Weathered, desaturated, road-worn look |
| Vanguard: Iron Sentinel | Heavy plate recolor, battle-scarred |
| (additional skins per future Grimoire) | Added as Grimoires ship |

### 6.2 Portrait Frames

Decorative frames displayed around the player's character portrait in
guild roster and party UI.

| Item | Examples |
|------|---------|
| Standard frames (3) | Iron, Gold, Void |
| Seasonal frames | Added per event |

### 6.3 Name Badges

Small icon displayed next to the player's username in guild roster and chat.

| Item | Examples |
|------|---------|
| Badge pack (5) | Crossed swords, Grimoire, Shield, Crown, Wolf |

### 6.4 Guild Cosmetics

Apply to the guild's hub stage and guild banner. Purchased by any member,
cosmetic effects apply guild-wide.

| Item | Description |
|------|-------------|
| Guild Banner packs | Alternate banner designs for the guild hub |
| Guild Hall themes | Visual recolors for the hub interior |

---

## 7. Grimoires & DLC Category

**Currency:** IAP only. **Status:** All stubbed.

| Item | Description |
|------|-------------|
| Additional Base Grimoires | Extra Grimoire slots (players start with one) |
| DLC Faction Pack | Bloodweaver, Warlock, Kensei, Beastbond Grimoires |
| DLC Legendary Tier | Unlocks Legendary quality level for gear |
| DLC Cultivation | Cultivation gathering talent and farming loop |
| Future DLC | Placeholder row for future expansion packs |

All stubbed with the standard lock and "In-app purchases" label.

Note: additional base Grimoire slots are IAP because a second Grimoire is
a significant power expansion (adds to Total Combat Level, doubles the
active progression loop). This is a fair IAP purchase, not a pay-to-win
concern, because Grimoire levels are earned through play after purchase.

---

## 8. UI Layout and Behavior

### 8.1 Store page structure

```
╔══════════════════════════════════════════╗
║  ROYAL MERCHANT                          ║
║  [Consumables][Inventory][Quests][Cosm.][DLC]
╠══════════════════════════════════════════╣
║  [Category header]                       ║
║                                          ║
║  ┌──────────────────────────────────┐    ║
║  │ Item Name              [OWNED]   │    ║
║  │ Effect description               │    ║
║  └──────────────────────────────────┘    ║
║  ┌──────────────────────────────────┐    ║
║  │ Item Name              [150 GM ▶]│    ║
║  │ Effect description               │    ║
║  └──────────────────────────────────┘    ║
║  ┌──────────────────────────────────┐    ║
║  │ Item Name (🔒 IAP)               │    ║
║  │ In-app purchases coming soon     │    ║
║  └──────────────────────────────────┘    ║
║                                          ║
║  Current GM: 1,240 ◆                    ║
╚══════════════════════════════════════════╝
```

### 8.2 Item card states

| State | Visual | Tap behavior |
|-------|--------|-------------|
| Owned / Active | Teal border, "OWNED" or "ACTIVE" badge | No action |
| Purchasable | Buy button with GM cost | Confirm dialog, then purchase |
| Requirement not met | Greyed out, requirement text | Info modal |
| IAP (stubbed) | Lock icon, "In-app purchases" label | Info modal |
| Insufficient GM | Buy button red, "Need X more GM" | Tap opens exchange or info modal |

### 8.3 Purchase confirmation dialog

```
Upgrade to Auto-Eat: Smart?

Effect: Triggers at 50% HP, selects best available food.
Cost: 200 GM   (your balance: 1,240 GM)

[Cancel]  [Confirm]
```

On confirm: deduct GM server-side via RPC, apply unlock, refresh card state.
Same pattern as all GM transactions, never direct client write to currency.

### 8.4 GM balance display

Current GM balance shown at the bottom of every category page.
If balance is insufficient for any item, that item's buy button shows red.
No "Buy GM" button exists, GM is earned in-game only. IAP is for items,
not currency.

---

## 9. RoyalMerchantManager

```csharp
public class RoyalMerchantManager : MonoBehaviour
{
    // Purchase a GM item. Validates player has sufficient GM before calling RPC.
    public async Task<bool> PurchaseGMItem(string itemId, int gmCost)
    {
        if (PlayerData.goldMarks < gmCost) return false;

        var result = await SupabaseClient.Rpc("purchase_merchant_item",
            new { item_id = itemId, gm_cost = gmCost });

        if (result.IsSuccess) {
            ApplyUnlock(itemId);
            PlayerData.RefreshFromServer(); // refresh GM balance
            return true;
        }
        return false;
    }

    // Called after successful purchase to apply the effect locally:
    void ApplyUnlock(string itemId) {
        switch (itemId) {
            case "auto_eat_t2": SettingsManager.SetAutoEatTier(2); break;
            case "auto_eat_t3": SettingsManager.SetAutoEatTier(3); break;
            case "auto_eat_t4": SettingsManager.SetAutoEatTier(4); break;
            case "auto_drink_t2": SettingsManager.SetAutoDrinkTier(2); break;
            case "auto_drink_t3": SettingsManager.SetAutoDrinkTier(3); break;
            case "inventory_pack_small":  PlayerData.inventorySlots += 10; break;
            case "inventory_pack_medium": PlayerData.inventorySlots += 25; break;
            case "exchange_slot_1": PlayerData.exchangeListingSlots += 1; break;
            case "exchange_slot_3": PlayerData.exchangeListingSlots += 3; break;
            case "guild_bank_5":   GuildManager.ExpandBankSlots(5); break;
            case "guild_bank_15":  GuildManager.ExpandBankSlots(15); break;
            case "daily_quest_slot_1": PlayerData.dailyQuestSlots += 1; break;
            case "daily_quest_slot_2": PlayerData.dailyQuestSlots += 1; break;
            case "weekly_quest_slot_1": PlayerData.weeklyQuestSlots += 1; break;
            case "slaying_task_5": PlayerData.slayingTaskSlots = 5; break;
            case "slaying_task_6": PlayerData.slayingTaskSlots = 6; break;
            case "slaying_task_7": PlayerData.slayingTaskSlots = 7; break;
        }
    }
}
```

### 9.1 Server-side RPC: purchase_merchant_item

```sql
create or replace function purchase_merchant_item(item_id text, gm_cost int)
returns json
language plpgsql security definer
as $$
declare
    v_player players%rowtype;
begin
    -- Lock player row, verify balance
    select * into v_player from players
    where id = auth.uid() for update;

    if v_player.gold_marks < gm_cost then
        raise exception 'Insufficient GM';
    end if;

    -- Verify item not already purchased (for one-time unlocks)
    if item_id = any(v_player.merchant_purchases) then
        raise exception 'Already purchased';
    end if;

    -- Deduct GM additively (never absolute set)
    update players set
        gold_marks          = gold_marks - gm_cost,
        merchant_purchases  = array_append(merchant_purchases, item_id)
    where id = auth.uid();

    return json_build_object('success', true, 'item_id', item_id);
end;
$$;
```

Add `merchant_purchases text[] default '{}'` column to the `players` table
(new migration). This is the idempotency guard, attempting to buy an item
already in this array raises an error.

---

## 10. Deep Links from Other Surfaces

| Source | Links to |
|--------|---------|
| Exchange (insufficient listing slots) | Royal Merchant > Inventory, exchange_slot row highlighted |
| Quest Board (no available slots) | Royal Merchant > Quests & Tasks, daily_quest_slot_1 row highlighted |
| Slaying page (task slots full) | Royal Merchant > Quests & Tasks, slaying_task_5 row highlighted |
| Inventory (full) | Royal Merchant > Inventory, inventory_pack_small row highlighted |

Deep link pattern:
```csharp
RoyalMerchantUI.OpenToCategory(StoreCategory.Inventory, highlightItemId: "exchange_slot_1");
```

---

## 11. Acceptance Criteria

- Tapping Royal Merchant nav entry opens the store page at the Consumables tab.
- Auto-eat tier upgrade works end-to-end: select T3, confirm, GM deducted
  server-side, `SettingsManager.SetAutoEatTier(3)` called, card shows "ACTIVE."
- IAP-stubbed rows render with lock icon and "In-app purchases coming soon"
  and do nothing on tap except show the info modal.
- GM balance is shown at the bottom of every category tab and updates after purchase.
- Purchasing an item already owned (via merchant_purchases array check) fails
  gracefully with a "Already owned" toast, no double-charge.
- Guild bank expansion requires Officer+ role; non-officers see "Guild Officer
  required" and cannot purchase.
- Slaying task slot rows check `PlayerData.slayingLevel` before showing as
  purchasable, slots below the Slaying requirement show as locked with the
  requirement text.
- Exchange and Quest Board deep-link to the correct category with the specified
  item highlighted.

---

## 12. Items Deferred Until IAP Integration

These are confirmed design items that ship with Unity IAP + RevenueCat:

- All Cosmetics category items (skins, frames, badges, guild cosmetics)
- All Grimoires & DLC category items
- Inventory Pack: Large and Vault
- Slaying Task Slot 8
- Additional Exchange listing slot packs beyond Slot +3

When IAP ships, the stubbed rows are replaced with live RevenueCat product IDs.
The store UI architecture (category tabs, item cards, modal flow) does not change.

---

*Path: docs/royal-merchant-store-spec.md*
*Resolves: royal-merchant-store-REQUEST.md*
*Reconciles: monetization-scope.md (v0.3), consumables-spec.md (auto-eat tiers),*
*as-built RoyalMerchantUI (nav entry, GM auto-eat logic).*
*Live on ship: Consumables (auto-eat, auto-drink), Inventory (GM tiers),*
*Quests & Tasks (quest slots, Slaying task slots 5-7).*
*Stubbed on ship: Cosmetics, Grimoires & DLC, large inventory packs, task slot 8.*
