# Project Grimoire, Version 0.1.5 Release Notes

## "The World Stirs"

Everything new since 0.1.4. This build is about bringing the world to life: enemies now
animate, every zone has depth, and the music breathes with what you are doing. Highlights
first, then fixes and polish.

## The World Comes Alive

- **Enemies animate.** Roughly 67 enemies across every zone now move in combat: they idle in place, wind up and swing on attack, and bosses play a full death animation when they fall. Nearly 200 new sprites and animations in all.
- **Layered zone backgrounds.** All ten combat zones are now painterly parallax scenes with far, mid, and near layers that drift independently for real front-to-back depth, from the Grimwood Fringe to the Elder Reaches.
- **Animated title screen.** The sign-in screen now sits behind a living splash: an ancient grimoire glowing on its pedestal, embers rising and arcane runes drifting, looping seamlessly.

## Sound

- **Adaptive music foundation.** A new music engine layers a single theme up and down with the moment: the full arrangement in combat, a calmer mix in the hub, a focused swell when you nail an attunement window, and a separate track for the intro and sign-in. The system is in place this build; the final tracks are assigned in the next pass.

## Wayfarer's Exchange

- **Faster listing.** Listing an item from your bag now goes straight to a choice of Guild or Exchange, no extra step.
- **Sell in either currency.** Store listings now take a Silver Mark price, a Gold Mark price, or both. Leave one blank for a single-currency listing.
- **Familiar quantity control.** Store and auction listings now use the same type / drag / Max quantity control as the rest of the game, right inside the listing window.

## New Art

- Hub ambient props for the guild hall: wall lanterns, a burning brazier, and a coin pile.

## Fixes and Polish

- Cleaned up stray white backgrounds behind several Phase 4 enemy sprites (Ashen Revenant, Corruption Ancient, Void Archon, Bound Lantern-Spirit, and others).
- The Ashen Sovereign now swings his flaming greatsword from his sword side, and the Veilborn Wraith's idle animation was rebuilt.
- Exchange listing type and auction duration toggles now read as lit or dimmed instead of a yellow highlight, ready for skinning.

---

*The adaptive music system ships wired but without final tracks; music content follows in the next build. Guild and Exchange window scrolling will get its own theme later.*
