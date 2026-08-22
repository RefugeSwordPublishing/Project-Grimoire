# Background Art Prompt Library (HD-2D Parallax Environments)
### For Layer.ai / FLUX / Gemini painterly generation. Last updated: 2026-08-22

Ready-to-run prompts for the front-to-back combat scene backgrounds. The parallax system is already
built (`Build3DCombatScene`): a zone backdrop quad plus parallax layers at increasing Z depth. This
library provides the painterly art to feed those layers, one prompt per layer, per zone and per dungeon.

Companion to `art-asset-requirements.md` (Workflow A). This is prompts only; the style rules, import
settings, and pipeline live there.

---

## How to use

- **Model:** a painterly / concept-art model (FLUX, Gemini Flash Image, or similar). NOT the pixel-art
  sprite model. Backgrounds are high-res concept art, not pixel art.
- **Resolution:** 1920x1080.
- **Generate each layer separately.** Back-to-front per zone: `far/sky` -> `mid` -> `near/foreground`.
  The particle layer is done in Unity, not generated.
- **Z placement in-engine:** backdrop ~Z18, near ~Z20, mid ~Z35, far/sky ~Z50. Far layers read softer
  (the camera's depth-of-field blurs beyond the enemy plane), so keep far layers lower-contrast and hazy.
- **Import:** Bilinear filter, Max Size 4096, Lossless. One `SpriteRenderer` per layer at its Z depth.
- **Save to:** `Assets/Sprites/Environments/<ZoneOrDungeon>/<layer>.png`.

### Shared style tokens (append to every prompt)
```
dark fantasy medieval RPG, painterly concept art style, cinematic lighting, atmospheric depth,
volumetric god rays, high resolution game background, horizontal 16:9 composition, no characters,
no creatures, no people, no UI, no text, no watermark
```

### Shared negative prompt
```
pixel art, low resolution, characters, people, creatures, UI, HUD, text, logo, watermark, signature,
flat lighting, cartoon, chibi, oversaturated, cluttered foreground blocking the center
```

### Layer intent (same for every zone)
- **far / sky:** the horizon and sky. Low contrast, hazy, most distant. Leaves the center open.
- **mid:** the main environment mass (treeline, cliffs, ruins). The scene's identity layer.
- **near / foreground:** framing elements at the screen edges (trunks, rocks, arches). Center stays
  clear so the enemy and player read. Higher contrast, slight vignette.

---

## TIER 1

### Zone 1A, Grimwood Fringe  (temperate forest, clearings, bandit camps)
Color grade: cool greens with warm amber shafts. Time: dappled late afternoon. Particles (Unity): drifting pollen, light ground fog.
- **far/sky:** `Grimwood Fringe distant treeline and pale overcast sky, temperate forest horizon, soft amber sunlight breaking through haze, cool green and gold, hazy atmospheric depth, [shared style tokens]`
- **mid:** `Ancient forest clearing with mossy ruins and old oaks, dappled sunlight through the canopy, cool greens and amber light, drifting fog between trunks, cinematic depth of field, [shared style tokens]`
- **near/foreground:** `Large foreground oak trunks and fern undergrowth framing the edges, moss and roots, shafts of warm light, dark vignette at the sides, center left open, [shared style tokens]`

### Zone 1B, Saltmarsh Shore  (coastal cliffs, tidal caves, smuggler coves)
Color grade: cold blue-grey with pale seafoam highlights. Time: overcast dusk. Particles: sea spray, drifting mist.
- **far/sky:** `Saltmarsh Shore horizon, grey stormy sea meeting a pale overcast sky, distant sea stacks in mist, cold blue-grey palette, hazy, [shared style tokens]`
- **mid:** `Rocky coastal cove with wet dark cliffs and a tidal cave mouth, breaking waves and sea foam, cold moody light, drifting sea mist, cinematic depth, [shared style tokens]`
- **near/foreground:** `Foreground barnacled rocks and tide pools framing the edges, wet stone, coiled rope and broken crates hinting at smugglers, dark vignette, center open, [shared style tokens]`

---

## TIER 2

### Zone 2A, Ashfen Mire  (swamp, foggy bog, ancient burial mounds)
Color grade: sickly green over murky brown, heavy fog. Time: foggy twilight. Particles: fireflies, swamp-gas wisps, thick low fog.
- **far/sky:** `Ashfen Mire distant swamp horizon lost in green fog, dead skeletal trees as silhouettes, sickly green twilight, very hazy and low contrast, [shared style tokens]`
- **mid:** `Foggy bog with knee-deep black water, ancient moss-covered burial mounds and standing stones, twisted dead willows, eerie green light, thick drifting fog, [shared style tokens]`
- **near/foreground:** `Foreground reeds, gnarled cypress roots and a half-sunken burial stone framing the edges, murky water reflections, dark vignette, center open, [shared style tokens]`

### Zone 2B, Ironspine Reaches  (mountain passes, rocky outcrops, shallow caves)
Color grade: cold grey-blue, bare stone. Time: cold overcast midday. Particles: dust, drifting cold mist, occasional falling pebbles.
- **far/sky:** `Ironspine Reaches distant jagged grey peaks under a cold pale sky, snow-dusted ridges in haze, cold blue-grey, atmospheric distance, [shared style tokens]`
- **mid:** `Rocky mountain pass with sheer grey cliffs and a shallow cave entrance, scattered boulders and scree, cold overcast light, thin drifting mist, [shared style tokens]`
- **near/foreground:** `Foreground broken rock ledges and a weathered stone cairn framing the edges, sparse hardy shrubs, cold shadow, dark vignette, center open, [shared style tokens]`

---

## TIER 3

### Zone 3A, Dreadhollow  (dead forest, collapsed villages, shadow-touched clearings)
Color grade: desaturated with sickly purple-grey shadow. Time: perpetual gloom. Particles: falling dead leaves, faint shadow wisps, ash.
- **far/sky:** `Dreadhollow distant horizon of dead blackened forest under a bruised purple-grey sky, no sun, oppressive gloom, hazy silhouettes, [shared style tokens]`
- **mid:** `Dead forest clearing with leafless blackened trees and a half-collapsed abandoned village, broken timber and sagging roofs, shadow-touched sickly light, cold fog, [shared style tokens]`
- **near/foreground:** `Foreground dead twisted trunks and a broken fence framing the edges, scattered bones and dead leaves, deep shadow, heavy vignette, center open, [shared style tokens]`

### Zone 3B, Cinderpeak  (volcanic rock, lava channels, thermal vents)
Color grade: orange-red ember glow over black basalt. Time: night lit by lava. Particles: rising embers, ash flakes, heat shimmer.
- **far/sky:** `Cinderpeak distant volcanic horizon, black mountains glowing with orange lava veins, smoke-filled red-black sky, ember haze, [shared style tokens]`
- **mid:** `Volcanic highland with black basalt rock and glowing orange lava channels, thermal vents venting steam, hot ember light from below, smoke, [shared style tokens]`
- **near/foreground:** `Foreground jagged basalt rocks and a cracked lava-lit ledge framing the edges, glowing cracks, rising embers, hot rim light, dark vignette, center open, [shared style tokens]`

---

## TIER 4

### Zone 4A, Veilborn Wastes  (corrupted plains, void tears, reality fractures)
Color grade: unnatural violet and magenta with teal fracture glow. Time: eerie no-time twilight. Particles: floating void motes, reality-glitch sparks.
- **far/sky:** `Veilborn Wastes distant corrupted plain under a torn violet sky with floating shards of shattered reality, teal void-light on the horizon, surreal hazy distance, [shared style tokens]`
- **mid:** `Corrupted wasteland with cracked earth and glowing void tears ripping through the air, floating rock fragments, ruined outpost, unnatural violet and teal light, [shared style tokens]`
- **near/foreground:** `Foreground fractured ground and a jagged void rift framing the edges, floating debris, glitching magenta glow, dark vignette, center open, [shared style tokens]`

### Zone 4B, Shattered Citadel  (ruined fortress, collapsed towers, unstable magic)
Color grade: cold moonlit blue with unstable arcane cyan. Time: moonlit night. Particles: floating dust, arcane sparks, drifting debris.
- **far/sky:** `Shattered Citadel distant broken skyline of collapsed towers against a moonlit blue night sky, drifting clouds, cold pale light, hazy, [shared style tokens]`
- **mid:** `Ruined fortress interior courtyard with crumbling stone walls and toppled columns, unstable cyan arcane light leaking from cracks, overgrown ivy, moonlight, [shared style tokens]`
- **near/foreground:** `Foreground shattered pillars and a broken archway framing the edges, rubble and floating dust, cold rim light, arcane sparks, dark vignette, center open, [shared style tokens]`

---

## TIER 5

### Zone 5A, Ashenwold  (ash fields, void-scarred ruins, bone fields)
Color grade: ashen grey-white with faint void-purple. Time: ashen overcast, no sun. Particles: falling ash, bone dust, void embers.
- **far/sky:** `Ashenwold distant grey ash fields under a colorless ash-choked sky, void-scarred ruins as faint silhouettes, desaturated grey-white, very hazy, [shared style tokens]`
- **mid:** `Field of grey ash and scattered bleached bones, void-scarred broken ruins and leaning monoliths, faint purple void-light seeping from cracks, drifting ash, [shared style tokens]`
- **near/foreground:** `Foreground ash dunes and a half-buried skeletal ruin framing the edges, bone shards, cold grey light, faint void glow, dark vignette, center open, [shared style tokens]`

### Zone 5B, Elder Reaches  (ancient ruins, primordial wilderness, arcane-scarred)
Color grade: deep teal and old gold, primordial green. Time: mystical golden hour. Particles: drifting spores, arcane pollen, golden motes.
- **far/sky:** `Elder Reaches distant horizon of colossal ancient ruins swallowed by primordial jungle, mist and golden light, deep teal and gold, majestic hazy distance, [shared style tokens]`
- **mid:** `World-old stone ruins overgrown with giant ferns and glowing arcane vines, massive carved monoliths, shafts of golden light through mist, primordial green and gold, [shared style tokens]`
- **near/foreground:** `Foreground vast mossy tree roots and a carved arcane-scarred pillar framing the edges, glowing runes, golden rim light, soft vignette, center open, [shared style tokens]`

---

## Dungeon Interiors

Dungeons are room-by-room; the fight still uses the front-to-back scene, so each dungeon wants its own
interior backdrop (darker, enclosed, torch/glow-lit versus the open zone skies). One `mid` backdrop per
dungeon is the priority; add `near` framing if you want extra depth. Each dungeon's theme matches its
host zone's enemy faction.

| Dungeon | Host zone | Backdrop prompt (mid layer) |
|---|---|---|
| **Aldric's Warren** | Grimwood Fringe | `Cramped bandit warren carved into a hillside, timber-braced dirt tunnels, hanging lanterns and stolen loot crates, warm dim torchlight, cool shadows, [shared style tokens]` |
| **Crestfall Cove** | Saltmarsh Shore | `Flooded sea cave with wet dark rock, dripping stalactites and a smuggler's plank walkway over black water, cold blue glow and lantern light, sea mist, [shared style tokens]` |
| **Mirefall Barrow** | Ashfen Mire | `Ancient underground burial barrow, moss-covered stone crypt walls and sarcophagi, sickly green witchlight, cobwebs and drifting fog, oppressive gloom, [shared style tokens]` |
| **Warden's Folly** | Ironspine Reaches | `Collapsed mountain fortress interior, cracked grey stone halls and fallen pillars, shafts of cold daylight through a broken ceiling, dust and rubble, [shared style tokens]` |
| **Gravenspire** | Dreadhollow | `Shadow-touched ruined spire interior, blackened stone stairs and broken arches, sickly purple-grey shadow light, dead vines and bones, cold fog, [shared style tokens]` |
| **Ignarath's Maw** | Cinderpeak | `Volcanic cavern interior, black basalt and rivers of glowing orange lava, obsidian pillars, hot ember light and rising smoke, oppressive heat, [shared style tokens]` |
| **The Breach** | Veilborn Wastes | `Void-torn cavern where reality fractures, floating shattered stone and glowing teal-violet rifts, warped geometry, surreal unstable void-light, [shared style tokens]` |
| **Valdren's Keep** | Shattered Citadel | `Unstable arcane keep interior, cracked marble halls and toppled statues, leaking cyan arcane energy and floating debris, cold moonlight through broken windows, [shared style tokens]` |
| **The Pale Vault** | Ashenwold | `Bone-white void vault interior, pale ashen stone and rows of sealed reliquaries, faint purple void-rifts pulsing in the walls, drifting ash, cold dread, [shared style tokens]` |
| **Firststone Sanctum** | Elder Reaches | `Primordial arcane sanctum interior, colossal world-old carved stone and glowing rune-pillars, deep teal and gold light, mist and floating motes, sacred and ancient, [shared style tokens]` |

---

## Generation order (suggested)

1. **Tier 1 zones first** (Grimwood Fringe, Saltmarsh Shore), all 3 layers each, since new players see these
   most and they double as the style reference for consistency.
2. Then zone by zone up the tiers (2 zones per tier).
3. Dungeon interiors last (10 mid backdrops), matched to their host-zone palette.

That is **10 zones x 3 layers (30) + 10 dungeon backdrops = ~40 background images** for full coverage.
A minimum viable pass is the Tier 1 and 2 zone `mid` layers (4 images) to prove the pipeline end to end.
