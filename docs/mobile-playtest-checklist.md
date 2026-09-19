# Mobile Playtest Checklist, 0.1.5

What to verify on the 0.1.5 phone build ("The World Stirs"), grouped by the release notes. Check items
off as you confirm them on device. Passed 0.1.4 checks (weapons/shields, attack speed, ally cards, concurrent
idle, merchant sell, shared quantity picker) are dropped here; pull them from git history if you need to re-run one.

---

## Step 0, Unity editor (run + save the scene before building)

- [ ] **Assets > Refresh** so Unity imports the newly staged art (enemy strips, zone backgrounds, splash mp4).
- [ ] **Art > Import Enemy Animations** (slices the 16-frame strips and wires icon / idle / attack / death on ~67 enemies). Console should log "Wired 36 base, 68 idle, 68 attack, 20 death".
- [ ] **Art > Import Zone Parallax** then **Build > Combat > Bake Combat Parallax** (wires each zone's far/mid/near planes + ParallaxSway).
- [ ] **Build Exchange UI**, then **Build > Panels > Bake Fresh Market**, then **Art > Copy Donate Skin To Quantity Popups** (in that order; each Build Exchange UI resets the Fresh Market, so re-bake it after).
- [ ] **Build > Panels > Bake Auth Gate Splash Video** (looping splash behind the sign-in gate). Requires the mp4 imported first.
- [ ] **Audio (optional this build):** on GameManager's AudioManager, assign the Forest of the Whispering stems + Moonlit Caravan clip and tick each stem's context boxes. If left empty, the game is silent but stable.
- [ ] **STILL PENDING (inspector, not a blocker):** assign `CombatHubUI._roomTypeIcons` (7) + a dungeon glyph.

---

## 1. Enemy animations (new)

- [ ] Enter combat in several zones (early, mid, and a Phase 4 zone like Veilborn or Ashenwold). Enemies **animate at rest** (idle sway), not a static frame.
- [ ] On an enemy's turn, it plays an **attack animation**; the swing reads from the correct side (check the Ashen Sovereign's flaming greatsword swings from his sword side).
- [ ] A **boss** plays a death animation when defeated. Standard enemies simply vanish (no death anim by design).
- [ ] No stray **white boxes / halos** behind any enemy sprite (spot-check Ashen Revenant, Corruption Ancient, Void Archon, Bound Lantern-Spirit).

## 2. Zone parallax backgrounds (new)

- [ ] Every zone's combat backdrop shows **layered depth** with a gentle independent drift on the far / mid / near planes, no seams, no hard edges where a layer ends.
- [ ] Backdrops fill the screen on a **tall phone** without stretching or leaving gaps (cover-crop).
- [ ] The enemy stands **in front of the mid layer** and behind the near framing.

## 3. Animated splash (new)

- [ ] At cold launch / sign-out, the **sign-in screen** shows the animated grimoire splash looping behind the login form (embers rising, runes drifting), with the form still readable over it.
- [ ] The loop has **no visible jump** when it repeats.
- [ ] The onboarding walkthrough (new account) uses the same intro backdrop feel.

## 4. Wayfarer's Exchange (changed)

- [ ] From the bag, **Create Listing** goes straight to a Guild / Exchange choice (no Auction / Sell Order step). Guild opens the guild composer; Exchange opens the new-listing page.
- [ ] A **store listing shows a Price Each row with SM and GM fields**; leaving one blank posts a single-currency listing; both filled posts dual-currency.
- [ ] Store and auction **quantity uses the type / drag / Max control** inside the listing window, capped at what you own.
- [ ] The store/auction and auction-duration **toggles read as lit vs dimmed** (no yellow highlight).
- [ ] The **Fresh Market** band (Just Listed + Recently Sold + the Store/Auction/Buy-Order filter) is present on the browse tab.

## 5. Audio (system only this build)

- [ ] If stems are assigned: music **layers up in combat** and **calms in the hub / menus**; the **intro / sign-in plays the Moonlit track**; an attunement tap window gives a brief **swell**. If no stems assigned: confirm the build is simply silent with no errors.

## 6. Regression spot-checks

- [ ] Combat, idle gather/craft, dungeon runs, and the merchant sell / quantity popups all still work (the exchange and audio wiring touched shared UI and manager code).
- [ ] Navigation between hub and every panel is responsive.

---

*The adaptive music tracks are assigned in the next pass; a silent 0.1.5 is expected and fine. Guild / Exchange
window scrolling music is deferred.*
