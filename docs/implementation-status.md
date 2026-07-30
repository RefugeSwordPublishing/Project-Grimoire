---
type: implementation-status
updated: 2026-07-25
purpose: Single source of truth for WHAT IS ACTUALLY BUILT vs. design intent in the specs.
audience: Claude (Chat or Code) starting a session. Read this FIRST, then the relevant spec.
---

# Project Grimoire, Implementation Status (as-built)

The spec files in `docs/` describe **design intent**. This file records **what is actually
implemented in code** where the two diverge. When they conflict, the code (and this file) win.
Claude Code updates this file as features land; Claude Chat should read it before any design work
so it builds on the current state rather than the original design.

## Repo layout
- `Project-Grimoire` (public), this repo: design docs (`docs/`), Supabase SQL (`supabase/migrations/`), and the Unity project as a **git submodule** at `ProjectGrimoire/`.
- `ProjectGrimoire` (private), the Unity/C# game. Chat cannot read it (private → 404); design docs + SQL here are public and readable.

## Phase status
- **Phase 1:** complete (managers, ScriptableObjects, Bowstring mechanic, idle loop, Supabase + FCM).
- **Phase 2:** guild system + Guild Merchant complete (below). Exchange buy orders + auctions now functional server-side (migration 022) + client-wired. Remaining Phase 2: Vanguard combo panel into combat (verify), zone content, sprite pass, auction buyout UI control. Arcanist trio (Runeweaver, Summoner, Lifebinder), aggro, and the progression rebalance are done.

## Session 2026-07-29, quest system + Talents merge + combat progression reconcile

- **Quest system (client-first):** `QuestDefinition` SO + `QuestManager` (weighted daily/weekly
  assignment, UTC resets, zone-tier gating, progress matching, claim + reward grant, PlayerPrefs
  persistence, pool loaded from `Resources/Quests`) + `QuestProgressTracker`. Quest Board UI (windowed,
  Daily/Weekly, layout-group cards) + `GamePanel.Quests` nav. `QuestScaler` scales targets/rewards by
  tier + real talent XP curve; pool banded (`maxZoneTier`) + 5 fill quests (30 total). Tracking events
  added: `OnItemAdded`, `OnEnemyDefeated`, `OnXPAdded`. Server layer (player_quests table, assign
  Edge Function, collect RPC) is the deferred alpha swap-in. Docs: `daily-weekly-quest-system-scaling.md`.
- **Tools menu:** 67 flat entries reduced to Build/ Content/ Dev/ submenus; 6 dead one-time tools deleted.
- **Talents menu merged:** Gathering + Crafting now one combined list (`_mergeGatheringAndCrafting`),
  single "Talents" nav entry (`Build Talents Menu`).
- **Idle bar:** stop-X moved inside the bar's right edge (clear of the menu button); progress bar
  shifted left to make room. Attunement slider: bar persistent while running, green target flashes in
  per window, tap brought to front so it registers (temporary; per-talent sprite attunements later).
- **Combat progression reconcile** (`combat-progression-reconcile.md`): per-Grimoire XP was already
  wired (`CombatManager.AwardDamageXP(_grimoireId)`), and zone gating already reads
  `CombatXP.TotalCombatLevel`. Removed the redundant shared `Marksmanship` award in `BowstringMechanic`;
  added a kill bonus (25% of Slaying value to the equipped Grimoire, additive with Slaying); added a
  Slaying Mastery section to `CombatTabUI`. Marksmanship/Spellcasting/Warfare surface in no UI (retired).
  Skipped the banked-XP migration on purpose: the Grimoire already earned damage XP those sessions, so a
  transfer would double-count. Deferred cleanup: delete the retired shared-talent enums/SOs +
  `GetHighestCombatTalentLevel`. CLAUDE.md's per-Grimoire combat rule is now accurate as-built.

## Session 2026-07-25, Wayfarer's Exchange buy orders + auctions

The Exchange tables existed since migration 004 and the store side was modernised in 020, but the
**transaction RPCs for buy orders and auctions were never built**, and buy-order placement deducted
escrow client-side only (so `cancel_buy_order` refunded money never charged, an exploit).

### Server (migration 022, run AFTER 021)
Six server-authoritative SECURITY DEFINER RPCs, mirroring `purchase_store_listing` (mutate
`player_currency`/`player_inventory`, return the caller's new balance):
- `place_buy_order` (real escrow out of the wallet), `fulfill_buy_order` (0% fee, delivers the item
  to the buyer server-side, pays the seller from escrow, draws down remaining qty).
- `place_auction_bid` (escrow bid, refund previous high bidder, 5% minimum increment enforced),
  `buy_auction_buyout` (fee on sale, refund standing bidder, deliver item, complete),
  `close_ended_auctions` (hourly cron: winner delivery + seller payout, or return to seller on no bids).
- `sweep_expired_buy_orders` (daily cron: refund remaining escrow).
- Added `quality int` to auctions + buy orders (delivery is quality-aware per the migration-021
  `player_inventory` key), `expires_at` on buy orders, `ending_soon_notified` on auctions.
- **SM-only** (buy orders/auctions match the as-built single-price columns; the store side stays
  dual-currency). Item delivery uses the `(player_id, item_id, quality)` inventory key.
- **pg_cron not yet scheduled:** enable pg_cron, then schedule `close_ended_auctions` (hourly) +
  `sweep_expired_buy_orders` (daily) per the comment block in 022.

### Client (MarketManager + ExchangeUI)
- `PlaceBuyOrder` now routes through `place_buy_order` (server escrow) and adopts the returned
  balance instead of pre-deducting client-side. `CreateAuctionListing` carries item quality.
- New `PlaceAuctionBid` / `AuctionBuyout` methods (adopt balance; buyout adds the delivered item).
- `fulfill_buy_order` result adopted for the seller's balance.
- Auction rows in the item-detail view are display-only in the builder (`withButton:false`); made
  tappable at runtime → open the **bid panel**: a custom bid-amount input (pre-filled to the minimum,
  shows current + minimum bid) plus a **Buyout** button (shown only when the auction has a buyout).
  `ExchangeBidPanel` built by `BuildPlaceBid` in `Build Exchange UI` (re-run it + Ctrl+S to get the
  panel). Server errors are mapped to player-facing messages (outbid, insufficient funds, ended).
### UX pass (on-device testing feedback)
- **Cancel listing fixed:** the direct PATCH failed RLS (42501) and never returned the escrowed
  item. Now `cancel_store_listing` RPC (migration 023): verifies ownership, cancels, and hands the
  item back (text→int quality map for the inventory key). MarketManager re-adds it.
- **Notch:** the Exchange header/close now live inside a `SafeAreaFitter` built into `Build Exchange
  UI` itself (a rebuild used to wipe the wrapper Apply-Safe-Area added).
- **Item detail de-cluttered:** active-buy-order list + "Sell This" removed; store section relabeled
  "Sell Orders"; "Place Buy Order" moved to the action row.
- **Create panel:** captions sit BESIDE fields (not placeholder-in-field); shows **Total** and a
  **recent-average suggested price** (qty-weighted from sale history) alongside the fee; tighter buttons.
- **Item icons** added to browse / detail / my-listings / my-buy-order rows and the create / bid /
  buy-order panels (from `ItemData.icon`, transparent when art is missing).
### UX pass 2 (browse rework + auction cancel)
- **Auction cancel** built: `cancel_auction` RPC (migration 024) refunds the standing bidder and
  returns the item to the seller; My Listings auction rows now wire it (previously did nothing).
- **Search is now a live typeahead** over the item registry (client-side, tradeable items only via
  `isProtected`), replacing the broken server-filter search. The Store/Auction/Buy-Order filter
  buttons + sort dropdown are removed; picking a result opens that item's market.
- **Item market view = collapsible sections** (Sell Orders / Auctions / Buy Orders), each showing a
  live count and collapsed by default; buy orders re-added as one of them. "Create Buy Order" sits in
  the action row (works for items the player doesn't own, which the inventory sell flow can't).
- **Button skin hook:** `BuildExchangeUI.Button` reads optional `ButtonSprite` / `ButtonFont` (+
  `ButtonHeight`/`ButtonFontSize`) so the coming sprite-button pass re-skins every Exchange button in
  one place; null keeps the flat look.
- **Layout fix:** `HRow` now pins `flexibleHeight = 0` (its HorizontalLayoutGroup reported a positive
  flexible height, so the parent VLG stretched every button row to fill leftover space, that was the
  oversized-button bug). Button rows now honour their preferredHeight. Also: panel item icons +30%,
  number fields right-aligned (bid field centered at 60% width), Watch / Create Buy Order / Back
  compacted and centered (~25% width).
### UX pass 3 (watchlist, toggles, dual currency, guild parity)
- **Watchlist pins to top:** opening the Exchange with no search lists the player's watched items
  (from `exchange_watchlist`); typing switches to the typeahead. Makes Watch meaningful.
- **Toggle selected-state:** Store/Auction type + 1/7/15-day duration (and the new currency toggle)
  show a camel/dim tint for the active choice.
- **Dual currency (migration 025):** buy orders now escrow SM AND GM (either may be 0); auctions are
  single-currency (seller picks SM or GM at creation, bids/buyout in it, so bids stay rankable). All
  buy-order/auction RPCs rewritten with a `_wallet_credit(player, cur, amt)` helper and return both
  balances; client adopts both. Buy-order panel gains a GM offer field; auction create gains an
  SM/GM currency toggle; the bid panel shows the auction's currency.
- **Guild merchant parity:** `BuildGuildBankUI` got the same `HRow` flexibleHeight fix + a
  `LabeledInput` (captions outside + right-aligned, right-aligned number fields); the listing
  composer's qty/price(SM+GM)/note now match the Exchange styling.
### UX pass 4 (seller earnings + toasts)
- **Seller earnings surfaced:** currency is client-authoritative (`SaveCurrency` PATCHes an absolute
  value), so a seller's client showed a stale balance and could even overwrite the server-side sale
  credit. `GameManager.RefreshCurrencyFromServer` reloads `player_currency` on Exchange open and
  adopts it **upward only** (never clobbers an unsaved local gain). The top bar polls the balance, so
  it updates live.
  - **Known limitation:** if the seller's client autosaves a stale balance in the window between the
    sale and reopening the Exchange, the credit can still be lost. Proper fix = server-authoritative
    currency (client sends deltas via RPCs) or a claim-based pending-earnings row. Tracked for later.
- **Toasts:** reused `LootToastUI` (now has a static `Instance` + `ShowMessage`); Exchange toasts
  "Bought X", "Sold X".

### Pending earnings + collect-at-merchant (migration 026) — the real fix
Sale proceeds no longer credit the seller's wallet directly (which the client could overwrite).
Instead a sale accrues to a **server-side pending bucket per marketplace** (`exchange_pending_earnings`,
source `exchange`|`guild`); the seller taps **Collect** at that merchant, a client-initiated
`collect_earnings(source)` that moves pending → `player_currency` and returns the amount (client adds
it, additive, never clobbers a local gain). Fixes the lost-earnings bug and makes collecting a
rewarding step (the user's idea).
- Every sale RPC redefined to route the SELLER to `_add_pending`: `purchase_store_listing`,
  `fulfill_buy_order`, `buy_auction_buyout`, `close_ended_auctions`.
- **Guild merchant fixed too:** `buy_guild_listing` now charges the buyer from `player_currency`
  (was `players.*`, the long-standing split-table bug) and routes the seller to pending('guild').
- UI: a **Collect** bar on Exchange **My Listings** and the **Guild Merchant** tab shows the total and
  collects. `RefreshCurrencyFromServer` stays for escrow refunds.
- **Deferred:** buy-order fill quantity picker (fills 1 at a time), FCM outbid/sold notifications
  (schema flag `ending_soon_notified` ready), a project-wide UITheme for the sprite-button swap,
  server-authoritative currency.

## Session 2026-07-27, Phase 3 dungeons (full system)

Dungeons were net-new (no Phase 2 foundation existed). Built the **whole system**:
- **Data:** `DungeonData` + `RoomData` SOs + `RoomType`/`DungeonHazard`/`DungeonPuzzle` enums.
  `Create Phase 3 Dungeons` authors Gravenspire + Ignarath's Maw (entrance/safe/boss + 8-room weighted
  pools, hazards, exclusive puzzle, dungeon boss) and links each host zone via `ZoneData.dungeon`.
- **Generator** (`DungeonGenerator`): entrance + min..max pool rooms (guaranteed + puzzle-by-chance +
  weighted, shuffled) + safe (2nd-last) + boss (last).
- **Crawl** (`CombatManager`): `EnterDungeon` full-heals + generates; room enemies queue and spawn one
  at a time; clearing a room awaits `AdvanceDungeonRoom`; safe rooms heal; boss room -> complete with
  first-clear XP. Hub dungeon tile launches it.
- **UI:** `DungeonRunUI` (room-progress banner + Advance/Finish + Complete/Leave). `DungeonPuzzleUI`
  (Pyre 5-brazier flash-repeat / Pressure-Valve 3-valve shown-order sequence; solve = bonus Refined
  material; wrong = reset + minor damage; optional). Both added by `Build Dungeon Run UI`.
- **Hazards:** simplified periodic tick while fighting in a hazardous room (telegraphed/avoidable
  behaviour deferred).
- **Deferred:** hazard telegraphs, room-specific loot bonuses (lootNote is reference text), enforced
  puzzle gating. Boss reconciliation flagged for Chat (used enemy-brief dungeon bosses: Archbishop-
  Gravenspire 8400 + Broodmother 7800).
- **Run:** Create Phase 3 Enemies -> Create Phase 3 Dungeons -> Build Dungeon Run UI, Ctrl+S.

## Session 2026-07-27, Tier 1 dungeons (Aldric's Warren + Crestfall Cove)

Per `docs/dungeon-room-pools-t1-brief.md`. The two T1 zones already carried placeholder dungeon tiles
(`hasDungeon` + a name) but no `DungeonData`, so the tiles dead-tapped. Now built for real:
- **Bosses:** `Aldric the Wolf` (Warren, 1800 HP, 2-phase) and `Captain Mirra Vane` (Cove, 2100 HP,
  2-phase), authored into `Enemies/Dungeons`. Silver-Mark drops (T1 is pre-Gold). Abilities are
  reference text (same deferral as every other boss). Note: the Warren zone boss is still
  `Aldric the Poacher King`; the Wolf is the dungeon variant (same split as the T3 Archbishop).
- **Dungeons** (`Create Phase 1 Dungeons`): entrance/safe/boss + 5-room weighted pools each,
  `minRooms 2 / maxRooms 3`, `firstClearXP 500`, **no puzzle**. Rooms reuse existing zone enemies
  (Grimwood Brigand, Bandit Scout, Saltmarsh Smuggler, Coastal Poacher).
- **Zone link:** matches the real `zoneId` (`zone_1a` / `zone_1b`, NOT the brief's
  `grimwood_fringe`/`saltmarsh_shore`) and sets `ZoneData.dungeon`.
- **New hazard `DungeonHazard.TidalSurge`** (Cove's Tidal Chamber): movement-penalty-only by design,
  so with no movement system yet it ticks **no damage**, just a periodic "Tidal surge" cue.
- **UI fix:** `DungeonRunUI` banner moved down (y -250) and made non-raycast so it no longer covers the
  Leave Combat button (top-right).
- **Run:** Create Phase 1 Dungeons, Ctrl+S. (No enemy tool needed; the two bosses are authored inline.)

## Session 2026-07-27, Tier 2 dungeons (Mirefall Barrow + Warden's Folly)

Per `docs/dungeon-room-pools-brief.md`, with the puzzle do-not-build flag lifted. Fills the T2 gap (we
had built T3 first, skipping T2).
- **Bosses:** `Aldrath the Sunken` (Mirefall, 4800 HP, 3-phase phylactery-pulse lich) and
  `Commander Valdris the Turncoat` (Folly, 5200 HP, 3-phase, shifting weak point). Silver-Mark drops.
  Abilities are reference text; Valdris's Chest->HEAD mask swap is deferred with the mask system.
- **Two new puzzle types** (`DungeonPuzzle.GlyphPuzzle` / `WeightPuzzle`), both live in `DungeonPuzzleUI`:
  - **GlyphPuzzle** (Mirefall): rune sequence memory, reuses the flash-repeat mechanic but full 5-length
    (harder than the T3 Pyre's 4).
  - **WeightPuzzle** (Folly): counterweight balance, tap the subset of weights that sums to the target.
    Deviation from the brief's inventory-item balance (our dungeons are linear, no bypass path), so it is
    a self-contained numeric balance, always solvable. Toggle freely, no damage on a wrong pick.
- **New hazards** (`DungeonHazard`): BogSeepage, PoisonGas, CursedSarcophagus, Tripwire, PowderKeg
  (simplified periodic tick; Falling Debris reuses CollapsingMasonry, Arcane Discharge reuses ArcaneDischarge).
- **Dungeons** (`Create Phase 2 Dungeons`): entrance/safe/boss + 8-room weighted pools each,
  `minRooms 3 / maxRooms 5`, `firstClearXP 1000`, exclusive Glyph / Weight puzzle. All room enemies are
  existing Ashfen Mire / Ironspine Reaches assets. Links `ashfen_mire` / `ironspine_reaches`, flips
  `hasDungeon`, registers the zones in the hub.
- **Run:** Create Phase 2 Dungeons, Ctrl+S.

## Session 2026-07-27, Phase 3 combat zone events + nav cleanup

- **Combat zone events** (VoidPulse / ThermalVentBurst): `ZoneData.combatEvent` (`ZoneCombatEvent` enum).
  `CombatManager` counts encounters per zone and fires the event every N (4-7 / 5-8), opening a
  damage-buff window. Idle gets the passive bonus automatically (+10% / +8%); an active tap of the cue
  gives the full bonus (+20% / +15%). `ZoneEventDamageMult` scales the strike; `TapZoneEvent` +
  `OnZoneEvent`; `ZoneCombatView` shows a tappable "<cue> (tap!)" prompt. Phase 3 tool wires VoidPulse
  -> Dreadhollow, ThermalVentBurst -> Cinderpeak (re-run the tool to set them on the zones).
- **Nav cleanup:** `RelayoutNav()` re-stacks the visible nav rows so the hidden Processing entry no
  longer leaves a gap.
- **Attunement is a real mechanic, not stubbed:** during any idle cycle with `hasAttunement`, a tap-cue
  button appears (via `AttunementUI` on `IdleManager.OnAttunementWindowOpen`); tapping within the window
  grants the yield/XP/rare bonus (idle always gets base). Per-cue-type VISUALS aren't differentiated yet
  (Smelting's HeatGauge shows the generic tap button); the mechanic works for all talents.

## Session 2026-07-27, Phase 3 attunement + locked-zone overlay

- **Tanning tiered attunement + Smelting HeatGauge** (`Add Phase 3 Attunement` tool): Tanning's 4
  leather grades get per-grade cycle lengths (12/18/25/35s) + window durations + rare bonuses + cue
  labels (Pulse cue); Smelting's 7 bars get HeatGauge attunement (window per bar, quality bonus for
  Steel+). `TalentActivity.attunementCueType` + `AttunementCueType` enum (Pulse/Crack/Shimmer/
  HeatGauge/Placement) added. The dedicated HeatGauge visual is deferred (timing runs on the existing
  cycle-window mechanic; cueType flags it for that UI). Shadow Leather grade omitted (material-economy
  keeps Shadow Pelt Alchemy-only) - flagged for Chat.
- **Locked-zone overlay** (`CombatHubUI`): locked zones/dungeons get a "???" overlay over the banner
  (assign `_lockedOverlaySprite` + `_lockedOverlayOpacity`, 0.85 default peeks the art through; dark
  placeholder until a sprite is assigned).
- **Still open in Phase 3:** combat zone events (VoidPulse / ThermalVentBurst), dungeon DungeonData
  (room pools + wire the 2 dungeon bosses), and the new T3 drop-material ItemData.

## Session 2026-07-27, Phase 3 enemies + zones

`Create Phase 3 Enemies` authors all Phase 3 EnemyData per phase3-enemy-content-brief: Dreadhollow
([Undead]/[Void]) and Cinderpeak ([Beast]/[Arcane]), 4 standard + 2 elite + 1 zone boss each (Hollow
Archbishop, Ignarath the Ashborn), plus the two dungeon bosses (Ignarath's Broodmother, Archbishop-
Gravenspire variant) as standalone assets in Enemies/Dungeons for later dungeon wiring. Creates the
2 T3 ZoneData (Dreadhollow lv51, Cinderpeak lv60, hasDungeon set), wires enemies + zone boss, and
registers them in the hub.
- `EnemyData.goldMarkDropMin/Max` added; `CombatManager` credits Gold Marks on kill (T3 primary
  currency; silver zeroed at T3). Special/boss abilities are reference text (behaviour deferred, as
  Phase 2). Sprites/masks null (sprite pass). Drop-table material names resolve once those items exist.
- **Still open in Phase 3:** dungeon DungeonData (room pools, wire the 2 dungeon bosses), Tanning
  tiered attunement, Smelting HeatGauge cue, combat zone events (VoidPulse/ThermalVentBurst),
  and authoring the new T3 drop-material ItemData.

## Session 2026-07-27, crafting panel UX: detail popup + keep-open

`CategoryTalentPanelUI`: tapping a recipe/gather tile now opens a runtime **detail popup** over the
panel instead of starting the task and closing to the main screen.
- Shows what it makes (+ gear stats via `ItemStats` for equipment), each input with held/needed and
  its SOURCE (`Gather: <talent>` / `Craft: <talent>` / drop) via `SourceOf`, and XP+cycle yield.
- **Start/Stop runs the action without closing the panel** (queue a few, then switch); Start is gated
  on the recipe's materials being held. Locked tiles stay inert. No canvas rebuild (runtime popup).
- Note: gather source names the talent (gathering isn't zone-gated in the data model), not a zone.

## Session 2026-07-27, Processing->Crafting merge + idle/recipe fixes

- **Processing merged into Crafting.** `TalentCategory.Arcane` renamed to `Crafting`; the 4 processing
  talents (Smelting/Tanning/Cookery/Alchemy) moved into it. The category split is now just Gathering
  (from the world) vs Crafting (consumes materials). The Crafting panel queries by category at runtime
  so it shows all 9 talents with no canvas rebuild; the Processing nav entry is hidden. `Processing`
  enum value kept (deprecated) to preserve Combat=2/Crafting=3 serialization.
- **Processing/crafting idle no longer vanishes offline** (inventory-load race): `InventoryManager.
  MarkLoaded/IsLoaded` + `IdleManager.WaitForInventory` gate resume + offline calc on the bag being
  loaded. Dev `Simulate 30 min Offline` ContextMenu on IdleManager for testing WYWA in-editor.
- **Recipe hygiene:** Cookery recipes made single-output (dead Broth/Energy Cake/Rare Spice byproducts
  removed); the only either/or crafting outputs were those 3. Gathering nodes still yield varied mats.

## Session 2026-07-27, Inscription rebuild + stacking buffs + recipe sweep

- **Full recipe sweep** (parsed every talent recipe, gather, drop): the ONLY self-referential /
  unsourced junk in the economy was **Inscription** (4 recipes consuming their own output + duplicating
  Gleaning's sigils). Everything else traces cleanly to gather/process/Gleaning/mob-drop. Remaining
  unsourced items are the two expected T5 drops (Drake Leather, Void Creature Part).
- **Leather -> Vellum -> Scroll pipeline** (`Build Inscription Economy` tool): Tanning gains a second
  product line (pelt -> Vellum / Fine Vellum / Runed Vellum); Inscription rebuilt to real scroll/codex
  `TimedBuff` consumables (Scroll of Precision/Warding, Codex of Insight/the Hunt, Ancient Glyph) from
  Vellum + a Gleaning sigil. Removes all Inscription junk; fixes the stale "auto-enchant" description.
- **Stacking timed buffs** (`BuffManager`): using the same buff again now EXTENDS its timer (up to 6h)
  instead of replacing it, so many short consumables bank into one long buff. Magnitude applies once;
  different buffs coexist. Scrolls use short durations by design. Regen buffs stack the same way.
- **Reagent orphans sourced:** Alchemy distils Clear/Swift/Pure; Gleaning gathers Binding Stone + Rare
  Ore (Gleaning is Artificing's supply talent). Limbs + Base Oil producers added earlier.
- **Economy cleanups (done):** deduped Shadow Essence (Trapping now drops only Shadow Pelt; Alchemy
  makes Essence) + Herb Extract (Alchemy owns it; removed from Cookery's Herb Broth). Tool crafting
  rare-material diversified off Bone Fragment (`ToolRareMat` in AddGearRecipes: metal->Gemstone,
  gather/leather/wood->Amber, arcane->Rune Shard; re-run Add Gear Crafting Recipes). The 5 dead
  buff-consumables (Clarity Tonic / Speed Draught / Power Elixir / Stone Totem / Ironbone Relic) were
  craftable no-ops; `Wire Buff Consumables` gives them stackable TimedBuff effects.

## Session 2026-07-27, material-economy audit + gap fills

Audited the material-economy batch against the code: **most of it is already built** and only a few
real gaps remained.
- **Already built:** Delving talent (17 nodes: ore/coal/gem/amber), Smelting talent (7 bar/alloy
  recipes), all bar/ore/limb/apparatus item assets (`Data/Items/Materials/`), Pine Haft recipe
  (`Shape Pine Haft`), `ItemData.materialTier` + `EquipmentStats` tier bonus arrays (match spec
  exactly), Shadow Essence + Base Oil item assets, and the leather rename (via `Reconcile Leather
  Chain`). Tailoring already consumes processed leather (Rabbit Hide/Fox/Wolf/Direwolf/Drake).
- **Fixed this session:** leather item descriptions still read the old names (corrected); **Tanning
  moved to the Processing category** (was Arcane/crafting) at the source (`Phase1DataCreator`) + asset,
  placing it between Trapping and Tailoring. New `Add Missing Producer Recipes` tool fills the two
  "consumed but never produced" gaps: **limbs** (Runesmithing forges Bronze/Iron/Steel/Mithril/Void
  Limbs from the tier bar; Timber Shaping bows consume them) and **Base Oil** (Alchemy `Render Base
  Oil` from Common Herb; Healing Salve + Inscription consume it).
- **Still open in the batch:** arcane apparatus recipes (verify producers exist), Drake Leather as a
  live enemy drop (needs Drake enemies), and the larger Phase 3 pieces: enemy/dungeon ScriptableObjects,
  Tanning/Smelting attunement cues, combat zone events, and the full quest system.
- Also (testing): Grimoire swap cooldown set to 0 (restore before release).

## Session 2026-07-26, combat rebuild hardening + Warden ability tiers

### Combat panel rebuild is now self-contained
`Build Character Combat UI` destroys + rebuilds `ZoneCombatPanel`, which used to silently drop
everything other tools layer onto it (3D scene link, Warden ring, Leave button, minimized-bar
Resume). The builder now re-applies all of them in one run: re-links the surviving `CombatScene3D`
(recreates the RawImage + wires `_sceneController`), then runs `BuildWardenAbilityUI`,
`AddCombatLeaveButton`, and `BuildMinimizedCombatBar`. Also: the combat hub (zone-choose) wraps its
header/body in its own `SafeAreaFitter` (X clears the notch, survives rebuilds); the in-combat draw
charge bar/DRAW% are hidden in the 3D scene (the trajectory arc is the feedback); `ZoneData.background`
is a dedicated in-combat backdrop sprite (falls back to `icon`).

### Warden ability stack = hold-duration tiers (warden-combat-spec)
Replaced the wrong tap-to-arm buttons. `WardenBowstringMechanic` accumulates hold time while drawing
and exposes a per-subclass tier ladder; the highest fully-charged, unlocked, off-cooldown tier fires
on release (falls back to the best lower tier when a higher one is locked/cooling).
- Rings are the subclass's UNLOCKED abilities only (no "Standard" ring; a sub-charge release is the
  standard shot). Ordered by unlock level so a new unlock slots in at the top and lower rings keep
  their timing. Windows are short (~0.5-0.8s each) so the top ring is ~2-3s of hold.
- Sharpshot (5): Full Draw (Lv1, x1.3) / Aimed (Lv18, guaranteed-WP approx x2) / Barbed (Lv31, 20%
  bleed) / Pierce (Lv55, armour-shred approx x1.5) / Long Shot (Lv86, 90s CD, x8).
- Lone Wanderer (4): Full Draw (Lv1) / Twin (Lv15, 2 arrows) / Rapid (Lv44, 8s CD, 3 shots) /
  Volley (Lv68, 12s CD, 4 arrows).
- **Single-target approximations pending multi-enemy combat:** Pierce's true line-pierce and Volley's
  AoE are single-target multi-hits for now; Aimed's guaranteed-WP and Long Shot's guaranteed-WP are
  flat multipliers. Upgrade when combat supports multiple simultaneous targets. Playtester feedback
  will tune the set (user's call).
- Row tap ability: Sharpshot Armor Piercer (primes +armour-ignore), Lone Wanderer Fade (dodge next hit).
- `WardenAbilityUI` draws a right-side stack whose rings FILL as you draw (lowest first, then the
  next), plus one bottom row button. Per the user's note the tiers visibly fill (overrides the spec's
  "no ring loader"). Ability buttons are procedural round rings (swap for authored sprites later).
- Approximations pending deeper combat plumbing: Long Shot's guaranteed-weak-point and Armor Piercer's
  true armour-ignore are flat multipliers for now; Rapid Fire fires 3 `FireAttack` calls.

## Session 2026-07-25, quality-as-flag + tier system + item stats

### Quality is now an INSTANCE FLAG, not a separate asset
Big architecture change. Quality (Crude..Masterwork) is a flag on the inventory stack, not a distinct
ItemData per quality. One asset per gear/tool item.
- `InventorySlot.quality`; stacking is quality-aware (a Crude and a Rough of the same item are
  separate stacks). No-quality `AddItem/RemoveItem/GetQuantity/HasItem` default to `item.quality`
  (so materials, which have a fixed rarity, behave as before); overloads take an explicit quality.
- Persistence: LocalSave stores per-slot quality; **Supabase migration 021** adds a `quality` column
  and widens the PK to `(player_id, item_id, quality)`; the sync reads/writes it. Materials load at
  their fixed `item.quality`, gear at the saved flag.
- The **Assembly bench** raises the flag in place (previous quality unit consumed on success, plus
  shared band components + a rare material; fail keeps the item). `AssemblyManager` is quality-flag
  based; the per-quality gear assets were collapsed to one-per-item.
- Quality **badge shows only for gear/tools**, not materials (a rarity badge on "Masterwork Leather"
  was meaningless). EquipmentManager carries each equipped piece's quality into the stat channel.

### Equipment Tier axis (equipment-tier-design.md, canonical)
Two axes: quality (flag, via bench) and **tier** (crafted item ladder, the power axis).
- `ItemData.materialTier` (1=Bronze .. 5=Void; tools always 1, default 1 keeps old items identical).
- `EquipmentStats` adds a **flat tier bonus** to weapon damage and armour rating only (additive:
  `{0,0,20,45,80,125}` weapons; per-type armour). Evasion, stat bonuses, and tool idle-time are
  quality-only. No compounding.
- Content: **105 tier gear assets** (Bronze/Iron/Steel/Mithril/Void weapons + Plate; Rabbit-Hide ->
  Drake Scale leather; Cloth -> Void vestments; Pine -> Heartwood staff/wand), one asset each, base
  Crude. Authored by `Create Equipment`.
- **Tier crafting recipes** (`Add Gear Crafting Recipes`): craft tier N from the tier-(N-1) item + a
  tier material, on the owning smith talent, gated at levels 1/21/42/65/88.
- **Material economy is NOT built:** the tier materials (Copper/Iron/Steel/Mithril Bar, Void Alloy,
  limbs, apparatus, drake scale, etc.) are authored but have **no acquisition path** (dev-grant only,
  `Grant Tier Materials`). Design pending, see `material-economy-REQUEST.md`. Also unresolved: material
  names reusing quality words (Rough/Masterwork Leather) and the Tanning leather-chain vs tier mapping.

### Item stats in inventory
Tapping a gear/tool item shows its computed stats (damage/armour/evasion/bonuses, or tool idle-time,
at its exact quality AND tier) plus a coloured "vs equipped" comparison, in a stats card in the item
context menu. `ItemStats` helper; materials/consumables show no card.

## Session 2026-07-24, equipment system + assembly + tools-as-gear

### Equipment as a stat-bearing system (gear)
Weapons and armour now carry stats, derived (not stored) from (quality, type) per
`stat-scaling-combat-formulas.md` section 2.
- `ItemData` gains `weaponType` (Bow/Sword/Dagger/Staff/Wand/Axe) and `armorType`
  (Plate/Leather/Vestments). `EquipmentStats` (Data) holds every spec table: weapon damage band,
  armour rating, armour evasion base, stat-bonus bands, favoured stats per type.
- `PlayerData` gains an equipment stat channel (`STREquip..LCKEquip`, `armorRating`,
  `armorEvasionBase`). ADDITIVE: with nothing equipped every getter matches its old value. New
  `GetMeleeAttack`/`GetMagicAttack` join `GetRangedAttack`; `GetDefense`/`GetEvasionRating`/
  `GetMaxHP`/`GetMaxMana` fold in the equipment terms.
- `EquipmentManager` (new, `GameManager.Equipment`): equip/unequip weapon+armour by slot and tools
  by talent; recomputes the channel from the spec tables; PlayerPrefs persistence, restored on boot
  after inventory load. `CharacterPanelManager.equipmentBonus` now reads this channel (was 0).
- `CombatManager.ResolveAttack` picks the attack by equipped Grimoire path (Vanguard melee/STR,
  Arcanist magic/INT, Warden ranged/DEX), so weapon damage matters for all paths.

### Tools now behave like gear (CHANGED)
Tools are no longer auto-applied from the bag. They are equipped into their talent slot (out of the
bag), and the EQUIPPED tool drives the idle-time multiplier (`IdleManager.GetToolMultiplier`). An
owned-but-unequipped tool gives no bonus.

### Assembly / quality upgrade (STEP 8)
`AssemblyManager` (`GameManager.Assembly`): `AttemptUpgrade` walks an item one quality step
(Crude->Masterwork). Base success 100/70/55/35/20 + 0.18% per assembler-talent level; XP
15/35/65/110/250 on win OR lose. Success consumes the item + components + rare material and yields
the next quality; failure returns the item, still consumes components + rare, no downgrade.
- `AssemblyView` popup (live success %, component checklist, ~0.85s cosmetic build bar).
- `AssemblyStationView` overlay lists every upgradeable item in the bag; opened from an "Assembly
  Station" button in the Crafting panel header.
- As-built simplifications: assembler talent = "Artificing" for all items (the spec's Timber
  Shaping / Runesmithing / Tailoring do not exist as talents yet); components shared by
  target-quality band, not per-item.

### Character page equip UI
- Equip from the inventory item menu (Equip action) OR from an empty slot: tapping an empty gear
  slot or tool tile opens `EquipPickerUI` listing matching inventory items.
- Tap a filled slot/tile to unequip. Quality badges show on slots and tool tiles (Crude = none).
- Tool rows use flexible-fill layout (cannot overflow horizontally); grimoire-slot icon tint fixed.

### Content authored
- `CreateEquipment`: 6 weapons + 15 armour pieces (Plate/Leather/Vestment x Helm/Chest/Legs/Boots/
  Gloves), full Crude->Masterwork ladders with upgrade chains.
- `CreateTools` extended to full ladders; `AssemblyMaterials`: 12 shared band materials.
- Editor build tools (run into a scene, save after each): `Create Equipment`, `Create Sample
  Tools`, `Build Assembly View`, `Build Assembly Station`, `Build Equip Picker`, `Build Inventory
  Context Menu`, `Add Quality Badges`.

### Still open
- Gear/tool items have no icon art yet (slots show a highlight + short name until art lands).
- **Weapon accuracy now live:** `EquipmentStats.WeaponAccuracyBonus(weaponType)` (bow +12 .. axe +3)
  flows through `PlayerData.weaponAccuracy` into the combat hit chance. **Enchanting was removed** from
  the base game (CLAUDE.md do-not-build); the `enchantBonus` stat channel + Inscription enchant gates
  were deleted. Per-craft smithing talents deferred.
- **Lifebinder shields now live:** shield spells (Holy Aegis) grant a real absorb buffer
  (`PlayerData.ShieldHP` soaks damage before HP; refresh-not-stack). Still deferred: cleanse (needs a
  debuff system), revive (needs downed-ally/party state), drag-to-ally targeting.
- **Warden ability ring built:** 3 active abilities on `WardenBowstringMechanic` with cooldowns:
  Long Shot (next shot x2.2, 6s), Barbed Shot (arms a bleed DoT via `CombatManager.ApplyEnemyDot`, 8s),
  Fade (`SetDodgeNextEnemyAttack`, dodges the next enemy strike, 12s). `WardenAbilityUI` self-populates
  a 3-button ring with cooldown fills; `Add Warden Ability UI` editor tool wires it into the combat
  view (shown only when a Warden Grimoire is engaged). Enchanting was REMOVED from the base game.

## Session 2026-07-21/22, Arcanist trio complete + quality/tier correction

### Character page rebuilt as a paper doll
Class body sprite centred with 8 equipment slots flanking it, zone-buff row, tool slots (3-3-2
centred), and collapsible Stats + Advanced sections. The class body comes from a new
`GrimoireData.bodySprite`, so each Grimoire supplies its own. The Grimoire slot taps to the equip
picker and long-presses to the Grimoire Book. (Tools auto-applied here; as of 2026-07-24 they equip
like gear, see the 2026-07-24 section above.) Built by `Tools > Grimoire > Build Character Paper Doll`.

### Arcanist path complete (all three subclasses)
- **Constellation live in combat.** `Add Constellation UI` builds the rune arch and wires
  `ZoneCombatView`; press-drag-release across nodes casts. Per-rune sprite slots (`_runeSprites`).
  A 1s cast cooldown lives in the mechanic, so throttled casts no longer waste mana.
- **Progressive rune unlock** (runic-constellation-spec v0.5): `NodeLayout(subclass, level)` returns
  only unlocked runes (2 at Lv1, all 6 by Lv13). `IsSpellAvailable` / `SpellUnlockLevel` gate on
  BOTH rune unlock and combo depth; the Grimoire Book shows the combined "unlocks Lv X".
- **Summoner Phase 1 + 2.** Constructs auto-summon at combat start (free, the baseline board), then
  single-rune draws are construct commands: summon, focus if already out, or recall on Ventus.
  Enforces the active cap (1 / 2 at Lv25 / 3 at Lv50), per-construct unlock level, a real mana cost
  (25-40), and a resummon lockout (20s on death, 12s on dismiss). Construct HP/damage scale off the
  Summoner's VIT/INT/WIL. HUD: segmented HP bar (constructs ARE the pool), construct row with
  per-construct attack-timer bars, and attack projectiles that launch from the construct.
- **Lifebinder.** HP as the casting resource with the WIL cost reduction and a hard block at 1 HP,
  x1.6 HP pool, always-on combat regen (3 + VIT*0.08 + WIL*0.05), heal-aggro (x0.4), and HOTs that
  stack additively on top of passive regen: Mending Wind +10/s 12s, Sacred Renewal +30/s 15s,
  Cleansing Flame +15/s 10s. Still deferred: shields, cleanse, revive, drag-to-ally targeting.

### Quality vs Tier corrected (breaking rename, data preserved)
Code had two parallel enums and used "tier" for what is actually quality. Now:
- One ladder: `ItemQuality { Crude, Rough, Refined, Pristine, Masterwork, Legendary }` on
  `ItemData.quality`. `EquipmentTier` and `ItemQualityTier` are gone.
- **Quality** is rarity: drives idle-action times, damage/HP bonuses, and the quality badge.
  **Tier** means level-gated progression only (zone bands, material tiers, unlock levels).
- Values are index-aligned and `FormerlySerializedAs` carries existing item data across.
  ~140 references over 19 files; `TierForLevel`, `ToolTierMultiplier`, `CanEnchantTier`,
  `hpByTier`, `damageByTier` and `Construct.tier` renamed to their quality equivalents.
- Bug the merge exposed: `CreateTools` assigned quality twice, stamping Masterwork tools as Epic.
- The 17 spec docs still use the old language (quality tier, Common/Uncommon/Rare/Epic). Chat pass
  pending; CLAUDE.md now carries the authoritative definition.

### Combat HUD
Subclass-aware resource bar (mana for Arcanist casters, stamina for Vanguard, hidden for Warden and
Lifebinder since HP is their resource). Active-effects buff bar listing HOTs and meal buffs with
countdowns, hidden when nothing is running. Enemy HP/attack-timer bars now track the base of the
enemy sprite, narrowed to 320px and floored so they cannot cover the player HUD. Quality badges on
inventory slots (distinct shapes, not colour alone, top-right of the icon). In-combat mana regen
added (3 + WIL*0.03 per sec); previously mana only regenerated out of combat, so the bar just drained.

### Fixes
- Equipped Grimoire persists across sessions on the server-auth path (LocalSave only covered local dev).
- Combat exit (X) was being swallowed by the full-screen constellation input surface; the build
  tools now re-raise the Hotbar and Back button above it.
- `CharacterPanelManager.GetStatBreakdown` / `GetMaxHP` NREs were aborting the entire Character
  refresh before tools and buffs ran.
- Inventory wipe on load and unclickable slots.

### Cleanup
Deduped the Sharpshot Grimoire (two assets shared `subclassName`, so equip/restore could match
either). Pruned superseded and one-off editor tools: the Tools menu went from ~45 items to 31.

### Editor tools added
`Build Character Paper Doll`, `Add Combat Resource Bar`, `Add Construct Bar`, `Add Combat Buff Bar`,
`Add Quality Badges`, `Reset Swap Cooldown (dev)`, `Set Grimoire Lv 13/25/50 (dev)`.

## Session 2026-07-20, active mechanics + content + fixes
This session shipped (all wired, several verified on-device):
- **Arcanist Constellation** (Step 5): full 26-spell library per subclass, seam mechanic, node-arch UI, editor build tool. Detail + reconciliations in `constellation-asbuilt.md`.
- **Vanguard combo** (Step 8): Strike/Guard/Surge library, seam mechanic (hybrid instant-fire + commit-window), cooldown UI. Then Chat's re-spec applied: staggered per-combo unlock levels (L1 starters to L93) and in-world descriptions, plus unlock-aware prefix check. Detail in `vanguard-combo-asbuilt.md`.
- **Grimoire Book UI**: tap the character portrait to open a book listing combos/spells (with unlock levels + descriptions) or the bow summary; small Change button opens the equip picker.
- **Phase 2 enemy content**: `Tools > Grimoire > Create Phase 2 Enemies` authors 18 EnemyData (Ashfen Mire + Ironspine Reaches) with weak-point tier/description, per-enemy attack cadence, combat range, slaying XP, drops; creates the two Tier-2 zones and registers them on `CombatHubUI`. `CombatManager` now honours per-enemy `attackCadence`. Enemy sprites still null (placeholder).
- **Zone backdrop**: `CombatSceneController.SetBackground` + a `ZoneBackdrop` SpriteRenderer added by the 3D scene tool; `ZoneCombatView` feeds `zone.icon`. Renders once zone art is assigned (re-run Convert Combat Scene to 3D).
- **Prestige hub backgrounds**: `PrestigeHubBackground` on PlayArea swaps per prestige stage, supports animation frames / single sprite / fallback tint; persisted via `PrestigeState`; Guild Bank publishes prestige. Add the component to PlayArea to enable.
- **Fixes:** offline While-You-Were-Away now credits and displays on resume (was inactive-panel + no lifecycle hook; driven from IdleManager, OnApplicationPause/Focus wired); mobile double-tap / X cascade (MouseInputBridge made editor-only); Android APK launcher (custom manifest was missing the GameActivity MAIN/LAUNCHER activity).
- **Docs:** committed the Chat rebalance handoff (progression-rebalance-brief, combat-xp-curve v0.2, assembly v0.5, warden v0.2, vanguard combos v0.3) at `a44b9df`. Implementation of that rebalance is NOT started (next session).

## Combat vertical slice + Warden bow, AS-BUILT (2026-07-11)
The Warden Bowstring was **redesigned in-engine from playtesting** and **diverges from
`warden-combat-spec` v0.1**. Full detail + open questions for re-spec: **`warden-archery-asbuilt.md`**.
Summary of what actually ships:
- **3D combat scene:** perspective camera (tilted ~10° down) → RenderTexture → full-screen RawImage
  backdrop on the combat panel (overlay canvas draws HUD on top). World quads: player (launch), enemy
  (SpriteRenderer + invisible MeshCollider sized to sprite), parallax bg. `CombatSceneController` owns it;
  `Tools > Grimoire > Convert Combat Scene to 3D` builds/wires it (idempotent, dedupes).
- **Bow mechanic:** aim = horizontal drag around a fixed screen-centre ref (`Aim Center X`); draw =
  vertical pull → arc **loft** (more draw = higher arch). Arrow arc is **Linecast-traced vs the enemy
  collider** → hit = arc passes through the body; **draw is effectively the vertical aim**. No draw-power
  damage, no draw-%% bar; a live trajectory line previews the arc (`_trajectoryReveal` hides the end).
- **Weak point** = hit UV vs `EnemyData.weakPointMask` (×2.0) with optional per-idle-frame `idleMasks[]`.
  A landed active shot then rolls **accuracy vs Evasion/Block** (Evaded/Blocked); no RNG miss on a good
  shot. Idle auto-attack keeps full-RNG accuracy. `AttackOutcome` = Hit/Miss/Evaded/Blocked.
- **Enemy depth:** `EnemyData.combatRange` (Close/Medium/Far/VeryFar) → fixed world Z (constant per enemy).
- **HP:** persists between fights; death = retreat to hub (no free heal); out-of-battle HP regen
  (`_hpRegenFraction`); in combat recover via food / idle auto-eat.
- **Enemy animation:** `EnemyData` idle/attack/death `Sprite[]` + `animFPS`, static `icon` fallback
  (idle loops, attack once→idle, death once→hide).
- **NOT built (Warden remainder):** the ability ring (Barbed Shot / Long Shot / Model C: Fade + Armor
  Piercer), reveal talents, per-subclass tuning, pending Chat re-spec on top of the arc mechanic.

## Persistence, Supabase wired behind login (2026-07-11)
`GameManager` routes inventory/talents/currency **load+save to Supabase when signed in** (`ServerAuthed`),
with the local JSON save as the offline fallback. Added `SupabaseManager.Upsert` (Prefer merge-duplicates)
and `PlayerDataService.LoadTalents`/`SaveAllTalents` (upsert on PK player_id,talent_id). Combat XP
self-persists server-side; **equipped Grimoire server-save is still a follow-on**. Auth session persists
in PlayerPrefs (auto-refresh) so testing doesn't re-prompt login.

## Arcanist Constellation, Phase 1 wired (2026-07-17)
Wired the Runic Constellation into the `ActiveCombatMechanic` seam (Phase 2 Step 5). Built:
`RuneType`, `ConstellationLibrary` (code-defined full 26-spell tables per subclass + counter
pairs + depth/speed/mana/HP + gating), `ArcanistConstellationMechanic` (sequence resolution
`depth×speed×counter×potency`, mana/HP cost, heal branch, idle-return grace), `ConstellationUI`
(self-populating 6-node thumb arch, drag hit-testing), `BuildConstellationUI` editor tool, and
the Arcanist branch in `ZoneCombatView.Engage`. **Reconciliations + deferred items (status effects,
HOT/shield heals, idle auto-cast, targeting visuals) + open questions: `constellation-asbuilt.md`.**
Order-DEPENDENT keys per spec v0.4 (brief's HashSet snippet was stale). Manual step to test:
`Tools > Grimoire > Add Constellation UI`, then equip a Runeweaver-path Grimoire.
Aggro (Step 4) intentionally deferred to Summoner (Step 6), inert in solo/single-enemy combat.

## Vanguard Combo, Phase 1 wired (2026-07-17)
Strike/Guard/Surge melee combo system wired into the `ActiveCombatMechanic` seam (Phase 2 Step 8).
This completes the active mechanic for all three base paths (Warden Arcanist Vanguard ). Built:
`ComboInput`+`VanguardComboLibrary` (code-defined full Warlord/Bulwark/Shadowblade tables),
`VanguardComboMechanic` (sequence resolution, per-combo cooldown, stamina cost+fallback, speed
bonus, Shadow's Edge), `VanguardComboUI` (self-populating buttons + cooldown overlays), the
`BuildVanguardComboUI` editor tool, and the Vanguard branch in `ZoneCombatView.Engage`.
**Reconciliations (hybrid instant-fire/commit-window input model, resolves a brief-vs-spec
conflict) + deferred effects (defence/taunt/DoT/streak) + open questions: `vanguard-combo-asbuilt.md`.**
Test: `Tools > Grimoire > Add Vanguard Combo UI`, equip a Vanguard Grimoire.

## Phase 2 enemy content, authored (2026-07-17)
`Tools > Grimoire > Create Phase 2 Enemies` authors **18 EnemyData** (Ashfen Mire 6 std + 2 elite +
Lich boss; Ironspine Reaches 6 std + 2 elite + Colossus boss) per `phase2-enemy-content-brief.md`:
full stats, per-enemy **attack cadence**, **combat range**, **weak-point tier + description**,
Slaying XP, silver ranges, and drop tables. Also **creates the two Tier-2 ZoneData** (Ashfen Mire
`combatTalentLevelRequired 21`, Ironspine Reaches 35), wires enemies + boss, and registers both on
`CombatHubUI._zones`. `EnemyData` gained `weakPointDescription`, `attackCadence`, `specialAbility`.
`CombatManager` now honours per-enemy `attackCadence` (fast Spore Crawler 1.2s ↔ slow Treant 3.0s).
**Deferred:** sprites/masks (null icons, enemies render as placeholders), boss/elite ability AI
(`specialAbility` is reference text), lobby HP scaling (boss HP = solo value), Tier-1 retroactive
weak-point data, and authoring the new material ItemData (drop names resolve once those exist).

## Session 2026-07-11, persistence, consumables Part A, fixes
- **Idle gathering fixed.** Root cause: category-panel Sheet background is a raycast target with no click handler, so taps on talent/activity tiles bubbled up to the full-screen panel-root Close button, the panel opened the detail view then instantly closed. Fix: new `ClickSwallow` (Assets/Scripts/UI/ClickSwallow.cs) on the Sheet consumes clicks; taps outside still close. Applies to Gathering/Processing/Crafting.
- **Inventory fixes.** Grid now populates on open (`InventoryUI.OnEnable` refreshes, nav drawer shows via SetActive, not Open()). Quality border no longer renders as a white box behind transparent icons (item backdrop inset + opaque). Enemy sprite red tint fixed earlier (ZoneCombatView resets colour to white with a real icon).
- **Inventory tabs consolidated 10 → 5:** All / Materials (Raw+Rare+Craftables) / Consumables (+Scrolls) / Equipment (+Grimoires) / Quests. Currency items surface under All only. `InventoryUI` uses a CategoryFilter group model; single width-independent row. `Tools > Grimoire > Rebuild Inventory Tabs` rebuilds in-scene without a full canvas rebuild.
- **Enemy asset cleanup:** deleted 14 orphaned root `Data/Enemies/*.asset` duplicates (zones reference the `GrimwoodFringe/` + `SaltmarshShore/` subfolder copies).
- **Local persistence (dev testing), BUILT.** `Assets/Scripts/Core/LocalSave.cs` writes JSON to `persistentDataPath/grimoire_save.json`: currency, talent progress, inventory (exact slot layout), equipped Grimoire, per-Grimoire combat XP/levels. Loaded on boot in `GameManager.InitGame` before idle resume; throttled autosave (~4s) on inventory/talent/combat change; flushed on pause/quit (synchronous write, so editor Stop persists). Milestone stat bonuses replayed on load (talents + combat). `Tools > Grimoire > Delete Local Save` resets. **At alpha:** swap for the Supabase services (`InventorySyncService`, `PlayerDataService`, needs an upsert path for talents) behind the same call sites; server saves require login.
- **Consumables Part A COMPLETE.** `BuffManager` (Assets/Scripts/Core/BuffManager.cs): `TimedBuff` meals apply buffStats/buffValues to `PlayerData.*Bonus` for `buffDurationSeconds`, reverse on expiry; one general + one Vanguard-stamina meal coexist, new meal replaces old in-category. `WeaponManager` (Assets/Scripts/Core/WeaponManager.cs): `WeaponCoating` stores charges; each landed hit spends a charge and applies a DoT (damage/tick × duration) to the enemy, ticked by `CombatManager.TickEnemyDot` (1s ticks, can land the kill, cleared on spawn). Both auto-created by GameManager (`.Buffs` / `.Weapon`); `UseConsumable` wires both branches. **Deferred:** regen-type meals need a `StatType` HP/stamina-regen member (skipped with a warning for now); manual hotbar slot assignment still pending.

## Guild system, DONE (2026-07-10)
Unity: `Assets/Scripts/UI/GuildBankUI.cs` (+ `Editor/BuildGuildBankUI.cs`). SQL: migrations 002, 010-018.
Tabs: **Home / Roster / Bank / Upgrades / Prestige / Merchant / Settings**.
- Discovery + create (`create_guild` RPC) + join (`join_guild` RPC / apply for invite-only).
- Bank: responsive tile grid, donate/withdraw, expand slots, material requests, bounties.
- Upgrades: roster-tier purchase, consumable guild buffs.
- Prestige: milestone spend, hub stages.
- Roster shows username + equipped Grimoire + combat level (PostgREST embed).
- Settings: tax vote, join-policy toggle (Open/Invite-Only), name-change vote (3-month cooldown), announcement, disband.

### Voting (as-built), differs from spec
- **2/3 approval of the full roster** (`ceil(2/3 × member_count)`), not "majority of GM + Officers".
- Applied server-side by `cast_guild_vote` RPC (migration 015); one ballot per member.
- Passes and applies **immediately** on reaching threshold (no 48-hour delay). Open until threshold / all voted / 7 days.
- **Auto-close (built, migration 019):** `close_expired_guild_votes()` SQL function, run hourly by pg_cron, closes open votes once 7 days elapse OR all members have voted.

### Guild Merchant, as-built
- Members-only listings; fee = **half the guild tax**, credited to the guild bank on sale.
- **Dual-currency price:** a listing carries both `price_sm` AND `price_gm` (either may be 0), a combined-marks price, e.g. "3 GM 500 SM". (Superseded the original single-SM design, then a brief SM/GM toggle.)
- Buying goes through the atomic `buy_guild_listing` RPC (migrations 016→018): charges the buyer both currencies, pays the seller minus the per-currency fee, credits the guild bank the fee, deletes the listing. Items escrow out of inventory on post, return on cancel.
- **Expiry sweep (built, migration 019):** `sweep_expired_merchant_listings()` SQL function, run hourly by pg_cron, returns escrowed items from listings past `expires_at` (7 days) into the seller's `player_inventory` (loaded on next session) and deletes the listing.

### Scheduled jobs (migration 019)
Implemented as SECURITY DEFINER SQL functions run by **pg_cron** (hourly), not Deno Edge Functions, both are pure DB ops. Requires enabling the `pg_cron` extension in the Supabase dashboard. Jobs: `close-expired-guild-votes`, `sweep-expired-merchant-listings`.

### Guild constants (as-built, do not re-derive from memory)
- **Create cost:** 2,000 GM. Name 3-30 chars. Join policies: `open`, `invite_only` only (no "Closed" yet). Default tax 2%.
- **Roster tiers** (cap → GM cost): 10→start, 20→5k, 30→15k, 45→35k, 60→75k, 80→150k, 100→300k (7 tiers).
- **Prestige milestones:** 1/5/10/20/35/50/75/100 → hub stages Campfire Gathering → Tent Camp → Encampment → Army Encampment → Fortress → Castle → Castle with Village → Stronghold Capital.
- **Consumable buffs** (5): Prospector's Fortune 3,000 (+15% rare, 24h) · Merchant's Window 2,000 (guild tax 0%, 24h) · Bountiful Harvest 2,500 (+20% gathering, 24h) · Hunter's Providence 3,500 (+25% SM/GM drops, 24h) · Lucky Charm 4,000 (+10% LCK, 12h).
- **Bank:** 50 slots base; Officers/GM expand +10 at a time from the bank.

### Reusable ItemListingComposer
`Assets/Scripts/UI/ItemListingComposer.cs`, a shared, domain-agnostic composer: searchable item
picker (live-filter over the ItemRegistry, held-qty per row) + quantity + optional dual SM/GM price +
optional note. Driven via `Open(title, confirmText, requireOwnership, showPrice, showNote, callback)`.
Currently backs guild merchant listings and material requests. **Intended reuse:** Wayfarer's Exchange
buy orders / sell orders / auctions (buy orders → `requireOwnership:false`, escrow currency instead of item).

## Combat progression, foundation BUILT (migration 009 + CombatXPManager)
- Tables `player_grimoire_levels` (per-Grimoire combat_level + combat_xp) and `player_stat_bonuses` (milestone-keyed permanent stat grants), both RLS-owner-only. Helper `total_combat_level(player_id)` sums per-Grimoire levels. `players.combat_level` (migration 013) caches the total for other players to read (guild roster).
- `CombatXPManager.cs`: loads both tables, creates rows for owned Grimoires, PATCHes level/XP on level-up, posts milestone stat bonuses, caches Total Combat Level, exposes `TotalCombatLevel`. `CombatTabUI` displays it.
- **Zone gating logic BUILT:** `ZoneAccess.cs` is the single source of truth for the tier→level thresholds (T1≥1 · T2≥21 · T3≥51 · T4≥91 · T5≥141), with a per-zone `combatTalentLevelRequired` override. `CombatManager.EnterZone(zone)` now returns `bool` and refuses locked zones. `ZoneData` carries `tier` + `combatTalentLevelRequired`.
- **Combat hub BUILT (`CombatHubUI.cs`):** nav → Combat shows large Zone/Dungeon **tiles**, art placeholder (`ZoneData.icon`, null → colour box), title + tier, lock state via `ZoneAccess`, and per-zone **enemy roster with spawn rate** (`EnemyData.spawnWeight` share; elites/boss tagged). Tapping an unlocked tile calls `CombatManager.EnterZone`. Raids = Phase-4 placeholder. `BuildCombatTabUI` auto-fills tiles from every `ZoneData` asset.
- **Combat loop, BUILT (real-time idle, in `CombatManager`):** `EnterZone` stops any idle gather/craft (`Idle.StopAction`, one activity at a time), then runs a real-time loop: player and enemy each attack on **independent timers** (`_playerAttackInterval` 2s, `_enemyAttackInterval` 2.8s); on kill → roll `dropTable` + Silver Marks + `CombatXP.AwardKill` to the equipped Grimoire → brief respawn delay → next enemy (weighted spawn, elite roll 6%+0.1%/level cap +9%). Exposes `PlayerAttackProgress`/`EnemyAttackProgress`, HP, and events `OnEnemyChanged`/`OnPlayerAttack`/`OnEnemyAttack`/`OnCombatLog`.
- **Combat view, BUILT (placeholder art, `ZoneCombatView.cs`):** entering a zone opens an over-the-shoulder screen, background/enemy/player **placeholder boxes**, enemy + player **HP bars**, and **attack-cadence bars** (fill = timer; idle auto-fires at full, active-play tap window later). Back stops combat → hub. `EnemyData.icon`/animations plug into the existing hooks during the sprite pass.
- **Active-play seam BUILT (`ActiveCombatMechanic`):** the abstraction each Grimoire path implements, `Configure(subclass)`, `SetEngaged(bool)`, `OnAttackFired(multiplier)`. `CombatManager.SetActiveMechanic` registers it; the player's strike is driven by the mechanic (when the attack bar is full) instead of the idle auto-fire, with a fallback auto-shot if the player idles.
- **Warden Bowstring integrated (`WardenBowstringMechanic`):** wraps the existing `BowstringMechanic`; the combat view's full-screen input surface turns press/drag/release into a bow draw, and the shot's damage multiplier (draw power × weak-point crit) scales the strike. Engaged automatically when the equipped Grimoire is Warden (Sharpshot/Lone Wanderer); other paths fall back to idle auto-attack. **Template for the remaining mechanics**, Arcanist (Constellation) and Vanguard (Combo) implement the same seam.
- **Not yet:** Constellation + Combo mechanics, zone-boss spawns (active-only), Slaying-talent elite bonus, sprites/animations (`OnPlayerAttack`/`OnEnemyAttack` hooks + weak-point glow).
- **Spawn-rate buff bonus, DECIDED: none.** Per the combat spec, no buff modifies enemy spawn rate (buffs affect drops/yield/marks/LCK only). `CombatHubUI.SpawnBonusPercent()` and the "(+X%)" slot were removed.
- `ZoneData.icon` / `EnemyData.icon` are placeholder slots for the later sprite pass.

## Zone enemy content, Tier 1 authored (Grimwood Fringe + Saltmarsh Shore)
- `Editor/CreateZoneEnemies.cs` (menu: Tools > Grimoire > Create Zone Enemies) authors `EnemyData` for both Tier-1 zones and wires `ZoneData.enemies` + `zoneBoss`. Stats from `enemy-zone-tables.md` (names/levels/drops) + `stat-scaling-combat-formulas.md` (Tier-1 damage 4-12). 6 standard/elite + 1 boss per zone; `spawnWeight` set (common high, elite=1); loot via `dropTable` + Silver Marks + Slaying XP.
- **First-pass balance, tune later.** Icons null (sprite pass). Remaining zones (Ashfen Mire, Ironspine Reaches) + dungeon randomization still to author.

## Grimoires, assets + equip UI BUILT
- `Editor/CreateGrimoires.cs` (Tools > Grimoire > Create Grimoires) authors the **7 free-starter `GrimoireData`** (Warden: Sharpshot, Lone Wanderer · Arcanist: Runeweaver, Summoner, Lifebinder · Vanguard: Warlord, Shadowblade) and wires the scene `GrimoireManager` (owned list + default equipped **Sharpshot**). `subclassName` matches the combat-progression id convention.
- `GrimoireEquipUI.cs` + `Editor/BuildGrimoireEquipUI.cs`: a **Grimoires** button on the Character page opens an equip picker listing owned Grimoires; Equip calls `GrimoireManager.EquipGrimoire` (24h swap cooldown enforced/shown). `GrimoireManager.Owned` now exposes the list. Equipped path drives combat (Warden → Bowstring active mechanic).

## Other notable as-built facts
- Inventory, gathering→live-inventory, talent tiles with live XP, Combat Tab under Character, Exchange lock gate: built.
- Auth: Supabase Auth (JWT) wired into the core loop; RLS on all tables; guild RLS recursion avoided via SECURITY DEFINER helpers `auth_guild_ids()` / `auth_officer_guild_ids()`.

## Combat feel, as-built (2026-07-11)
- Real-time loop with a **live combat view** (`ZoneCombatView`): enemy/player HP bars, dual attack-cadence bars, hit/miss marker over the enemy (`OnPlayerHit`), and the Bowstring draw visuals (charge meter, DRAW %, rotating aim arrow).
- **Idle vs active arbitration:** idle auto-attacks fire **instantly** when the cadence bar fills, but only while the player isn't drawing (or within a 1.5s grace after). Drawing hides the idle bar and takes over; active shots fire on **release**, instantly, with a 0.5s anti-spam cooldown. `CombatManager.IdleAttackActive` drives the bar's visibility.
- **Player HP persists between fights** (no heal-on-kill). Defeat (HP→0) triggers a full-heal "retreat". Recovery is meant to come from consumables (active) / idle auto-eat (idle), neither built (see below).
- 7 starter Grimoires equippable from the Character page; equipped path selects the active mechanic (Warden Bowstring live; Arcanist/Vanguard fall back to idle).

## Consumables, Part A foundation BUILT (2026-07-11)
Per `consumables-spec.md`. Done so far:
- **`ItemData`:** `ConsumableEffectType` enum (None/InstantHP/InstantMana/InstantStamina/CureDebuff/TimedBuff/WeaponCoating/ZoneMap) + effect fields (effectValue, cooldownSeconds, inventoryOnly, requiredPath, buffStats/Values, duration, curedDebuffs, coatingCharges, dot*).
- **`PlayerData` resources:** `CurrentHP/Mana/Stamina` pools with `GetMaxMana()` (50+WIL×2), `GetMaxStamina()` (30+VIT×1.5), `EnsureResourcesInit`, `RestoreHP/Mana/Stamina`, `DamageHP`, `FullHeal`. `GrimoirePath.None` added (path gate).
- **Combat HP moved to `PlayerData.CurrentHP`**, persists between fights; consumables can heal it. `CombatManager.PlayerHP` reads it.
- **`InventoryManager.UseConsumable`** now switches on `effectType`: InstantHP/Mana/Stamina (path-gated), ZoneMap; CureDebuff no-ops (no debuff system yet); TimedBuff/WeaponCoating gated + return false (pending BuffManager/WeaponManager); inventory-only items blocked during active combat.
- **Combat hotbar BUILT (`CombatHotbarUI`):** 3 slots at the bottom of the combat view, slot 1 best Healing Draught, slot 2 class resource (Mana Vial/Endurance Draught, else 2nd HP), slot 3 Antidote. Auto-fills from inventory (highest quality held), tap → `UseConsumable`, per-slot cooldown (button disables + countdown). Manual assignment + `player_settings` persistence still pending.
- **Consumable items authored (`CreateConsumables` tool):** Healing Draughts (Crude/Refined/Masterwork), Refined Mana Vial (Arcanist), Refined Endurance Draught (Vanguard), Refined Antidote, registered in the ItemRegistry. Dev **+Consumables** button on the Combat Progression panel grants a test stock.
- **Regen BUILT:** `CombatManager.TickResources`, mana 1/sec out of combat (Arcanist), stamina 2/sec in combat (Vanguard); HP has no passive regen.
- **Idle auto-eat BUILT (free tier):** at 25% HP, after a 2s delay, once per encounter, `CombatManager` auto-consumes the lowest-quality Healing Draught in stock. Royal-Merchant upgrade tiers + `player_settings.auto_eat_tier` still pending.
- **Safe area:** `Editor/ApplySafeArea.cs` (Tools > Grimoire > Apply Safe Area To Panels) wraps every panel's HUD in the existing `SafeAreaFitter` so close buttons/headers clear the notch (background stays full-bleed). Idempotent.
- **Part A COMPLETE (2026-07-11):** `BuffManager` (meals) + `WeaponManager` (poison coating + enemy DoT) built, see Session 2026-07-11 above. Still pending: regen-type meals (need StatType HP/stamina-regen member), manual hotbar slot assignment + `player_settings` persistence.

## Consumables / resources, original design notes
The combat hotbar + auto-eat the user wants are **blocked on design**:
- **Resources:** only **HP** exists in code. Game-design doc says WIL → "mana pool" (intended, unbuilt); **Lifebinder uses HP as its resource, no mana** (contradiction to resolve). **Stamina** isn't a real concept anywhere. → a combat hotbar today is HP-only.
- **`ItemData`** has only a bare `isConsumable` bool, no heal amount / buff / duration / effect-type. **`InventoryManager.UseConsumable` only routes zone maps**; food/potions/poisons have **no effect implementation**.
- Docs name the item *types* (Healing Draught, Antidote, Poison Coating, meals/stews) but not their *effects*. **Royal Merchant** (for the upgradeable auto-eat tiers) is **not built**.
- **Rules set by the user:** stat **buffs → inventory-use only, never in active combat**; **instant fills (HP) → combat hotbar**; **idle auto-eat** free at 25% HP, higher thresholds upgraded via Royal Merchant.
- **Next:** Chat writes `consumables-spec.md` (effects per item, food-vs-buff ruling, combat-hotbar list, poison model, Royal Merchant auto-eat tiers); then Code adds `ItemData` effect fields → real `UseConsumable` → combat hotbar (HP fills) → idle auto-eat.

## Do-not-build (still in force)
Raids, faction system, Bloodweaver/Warlock/Kensei/Beastbond (DLC), guild bounties (post-launch), Divination talent, Legendary tier, Black Ledger.

**Dungeon room puzzles are IN (flag lifted 2026-07-27).** T2/T3 dungeons have puzzles (Pyre / Pressure
Valve, live via `DungeonPuzzleUI`); T1 dungeons have none by design. The prior "dungeon room puzzles"
do-not-build entry was stale, the shipped T3 dungeons already used them.
