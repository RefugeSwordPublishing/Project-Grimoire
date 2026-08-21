# Mobile Playtest Checklist

What to verify on the phone build after this session's work. Grouped so you run the Unity editor
bakers first, then deploy and test on device. Check items off as you confirm them.

---

## Step 0, Unity editor bakers to run first (at the machine)

These change the scene/prefabs and must run in the editor before the build. Menu items under
**Tools > Grimoire > ...**. Save the scene (Ctrl+S) after each.

- [ ] **Art > Skin Hub Bars** — reskins the hub HP bar + idle task bar with the UISkin frame + fill.
- [ ] **Art > Add Currency Icons** — silver/gold coins next to the SM/GM labels.
- [ ] **Build > Toggle Resume Bar (Editor)** — reveal the resume/minimized combat bar to reposition/reskin, then toggle it back off before building.
- [ ] **Art > Slice Icon Atlases**, then **Art > Reassign Icon Atlas Sprites** — re-batch the corrected material-sheet atlases (icons were reverted to individual PNGs; this points them at the fixed atlases). Verify a few item icons look right after.
- [ ] Other still-pending bakers from `pending-editor-steps.md` (Build Chat Pill, Add Alchemy Potion Recipes, Build Buff Bar, Build Hub Stations, Build Eat Quantity UI, Create Economy Talents, Audit/Build Item Source Index) if not already run.

The rest below works on a plain recompile, no baker needed.

---

## 1. Item icons (regression check)

- [ ] Open inventory, item icons show the correct art (not swapped/wrong pictures). This was the reassignment bug; icons were reverted, then the atlases rebuilt.
- [ ] After running Slice + Reassign (Step 0), re-check that material icons (ores, bars, logs, hides, potions) still match their items.

## 2. Chat keyboard (guild / DM / lobby)

- [ ] Open Guild Chat, tap the input. The input row lifts **above** the on-screen keyboard so you can see what you type.
- [ ] Type a message and tap Send (or the keyboard's return). Message sends and the keyboard **closes** (does not reopen).
- [ ] Repeat in a DM and in the pre-boss lobby chat, same behavior (they share the UI).
- [ ] If the lift looks too tall/short on your device, note it, the fallback is ~42% of screen height and is one tunable number.

## 3. Hub HUD reskin

- [ ] Hub HP bar + idle task bar show the new frame + fill (match the combat bars).
- [ ] SM/GM currency shows the coin icons.
- [ ] Resume/minimized combat bar (during a minimized fight) looks right where you repositioned it.

## 4. XP tuning, advanced recipes

- [ ] Simple one-ingredient gathers: XP per cycle unchanged from before.
- [ ] A multi-ingredient or advanced (higher-tier input) craft: XP per cycle is **noticeably higher**. The talent tile's "N XP" preview should match what you actually gain.
- [ ] Sanity: an advanced craft should not exceed ~6x the base (the multiplier is capped).

## 5. Royal Merchant capacity purchases (need Gold Marks)

Open the Royal Merchant. Buy each, confirm the effect, then **relaunch** and confirm it persisted.

- [ ] **Inventory Pack Small/Medium** (Inventory tab): bag grows by +10 / +25 slots.
- [ ] **Exchange Slot +1/+3** (Inventory tab): try to create more than 10 active listings, blocked with a "limit reached" message until you buy slots. (Client-soft; visit My Listings so the count loads.)
- [ ] **Daily/Weekly Quest Slot** (Quests & Tasks tab): extra quest slots appear at the **next daily/weekly reset** (not instantly).
- [ ] **Slaying Task Slot 5/6/7** (Quests & Tasks tab): each is level-gated at purchase (Slaying 30/50/70); after buying, the Bounty Board shows an extra slot.
- [ ] **Auto-Drink Mana** (Consumables tab): as an Arcanist with mana potions in the bag, in combat when mana drops below 30% it auto-drinks after ~2s. (No effect for non-mana classes, e.g. Lifebinder.)
- [ ] **Guild Bank +5/+15** (Inventory tab, officer/guild_master only): buy it, the guild bank grows for all members and persists across relaunch. A non-officer buying is rejected.

## 5b. Quest Board redesign (Idle Clans-inspired)

- [ ] Open the Quest Board. It shows **4 daily / 3 weekly** quests (plus any Royal Merchant slots).
- [ ] Quests are **compact rows**: title + a **red-to-green** progress bar reading **"X / Y  NN%"** + a status (Ready / ▼). It scans cleanly.
- [ ] **Tap a row** to expand it (accordion, one at a time): shows the description, **reward icons + amounts** (currency/XP as chips), the **bonus chip with its drop %**, and the Claim button.
- [ ] **Claim** shows a **toast** summarizing what you earned (XP included, and "Bonus …" if the bonus dropped).
- [ ] Claim a few completed quests; roughly 1 in 5 should also grant the bonus (XP by default). Guaranteed rewards always land.
- [ ] Author a real bonus on a quest (QuestDefinition.bonusReward + bonusChance) and confirm it shows + rolls. Currency bonuses won't persist (use item/XP).
- [ ] **Bounties tab** (third tab): shows Slayer bounties in the same accordion (target + kill progress; expand for hunt target, faction, Slaying XP + GM + material, Claim). Below Slaying Lv 50 it shows the unlock message. Claiming toasts the reward.

## 6. Status effects + shields (combat)

- [ ] As Lifebinder, cast a **shield** spell (Glacial Shield / Holy Aegis): an absorb buffer soaks the next hits before HP drops.
- [ ] Cast a **cleanse** spell while debuffed: debuff-like statuses (including any poison/bleed DoT) are removed.
- [ ] If any enemy applies a damage-over-time on you, it ticks HP damage over time, is absorbed by a shield if one is up, and the buff bar shows it as a chip. (Enemy-inflicted DoTs are not authored on enemies yet, so you may not see one in normal play, the pipe is ready.)

## 7. Boss invite push notification

- [ ] With two accounts in the same guild: host opens a boss lobby and invites a guildmate to a slot.
- [ ] The invited account gets a push ("Boss fight forming"). If the push does not arrive (FCM token, notifications disabled, or cooldown/cap), the invitee still sees the lobby via the discovery poll within ~12s.
- [ ] Note: tapping the push currently opens the app; deep-linking straight into the lobby from the notification is a follow-up.

---

## Known-deferred (do not expect these to work yet)

- Buff-bar icon + radial timer upgrade (needs the debuff icons imported to Unity; still text chips).
- Phoenix Wave revive + drag-to-ally targeting (needs a party downed-ally state, multiplayer).
- Commander Valdris shifting weak point (needs the sprite-mask system).
