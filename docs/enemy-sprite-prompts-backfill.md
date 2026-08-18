---
type: art-brief
version: 1.0
updated: 2026-08-17
path: docs/enemy-sprite-prompts-backfill.md
purpose: PixelLab generation prompts for all enemies missing prompts in the
         asset tracker. Base sprites only; animation frames derive from these.
         Enemy names match tracker cells exactly. Do not rename.
style: HD-2D dark medieval fantasy pixel art, full-body realistic proportions
       (Octopath Traveler / Blasphemous), limited palette, dark pixel outline,
       transparent background.
tier cue: standard = plain, no metal trim. elite = amber-gold trim along the
          silhouette edge. boss = towering and imposing, 320x320.
---

# Enemy Sprite Prompts, Asset Tracker Backfill

## Zone Palettes

| Zone | Palette and theme |
|------|-------------------|
| Cinderpeak (T3B) | Black volcanic rock, orange-red lava glow, ash and embers |
| Veilborn Wastes (T4A) | Deep void purple, corrupted reality tears, near-black |
| Shattered Citadel (T4B) | Broken grey-and-gold arcane stone, blue-white magic, ruined grandeur |
| Ashenwold (T5A) | Grey ash, sickly void purple-green, scorched |
| Elder Reaches (T5B) | Ancient mossy stone, primordial gold rune-light, deep green |
| Dungeon bosses | Match the home dungeon's zone theme |

---

## Cinderpeak (T3B)

### Cinderpeak Drake  (standard)  — base sprite

PROMPT:
Medium-large four-legged drake, low prowling stance with head level and wings half-folded against the flanks, thick overlapping scale hide with a ridged spine and a short blunt muzzle, black volcanic rock scales with orange-red lava glow bleeding through the cracks between plates and fine ash settled on the shoulders, plain unadorned hide with no metal trim, warm underlighting from the ground as if standing near an open lava vent, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Vertical oval at the throat, center-front of the neck, roughly 12% of sprite. Subtle. Renders at 40% opacity normally, 100% during the Fire Breath channel.

FACTION: Beast

---

### Fire Elemental  (standard)  — base sprite

PROMPT:
Medium humanoid figure composed entirely of living flame, upright neutral stance with arms loose at the sides and no discrete hands, body edges dissolving into drifting embers rather than terminating in a hard silhouette, deep orange-red flame at the extremities shading to white-yellow at the core with black volcanic slag crusting the shoulders and forearms, plain elemental form with no armor or trim, self-illuminated with the brightest light emanating outward from the chest, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Large circle at chest center, roughly 20% of sprite. Obvious. Always glowing white-yellow; flickers rapidly for 1.5s before the death burst fires.

FACTION: Arcane

---

### Highland Wyvern  (standard)  — base sprite

PROMPT:
Large two-legged wyvern with a heavy wingspan, standing tall on clawed hind legs with wings folded high behind the shoulders and neck arched, thick leathery wing membrane stretched over visible bone struts and a long counterbalancing tail, charcoal-grey hide with dull orange-red heat marks along the wing membrane and volcanic ash caked into the joints, plain hide with no metal trim, hard rim light from above catching the top edge of the folded wings, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Small oval at the wing joint where the wing folds against the body, center-side of sprite, roughly 8%. Hidden. No glow, no tell.

FACTION: Beast

---

### Lava Construct  (standard)  — base sprite

PROMPT:
Bulky humanoid construct assembled from fitted slabs of volcanic rock, heavy planted stance with oversized fists hanging low and a squat neckless head, blocky stone plating with molten seams running between every joint, black basalt exterior with orange-red lava visible in the seams and a carved rune glowing at the chest, plain construct with no metal trim, molten seam light casting upward across the underside of the jaw and forearms, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Carved rune at chest center, roughly 15% of sprite. Obvious. Always glowing orange-red; brief bright flare when the Lava Splash retaliation triggers.

FACTION: Arcane

---

### Drake Pack Alpha  (Elite)  — base sprite

PROMPT:
Large four-legged drake noticeably heavier than a common drake, wide dominant stance with head raised and chest pushed forward, scarred overlapping scale hide with a pronounced crest ridge and thickened horn tips, black volcanic scales with deeper orange-red lava glow in the cracks and old burn scarring across the shoulders, amber-gold elite trim running along the crest ridge and horn tips as a luminous silhouette edge, warm ground-up lighting with the amber trim catching the strongest highlight, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Vertical oval at the throat, same position as the standard Drake, roughly 12%. Subtle by default, Obvious during the Fire Breath channel only.

FACTION: Beast

---

### Greater Fire Elemental  (Elite)  — base sprite

PROMPT:
Tall humanoid flame figure, upright commanding stance with arms slightly raised and body noticeably taller and broader than a common elemental, outer flame layer deeper crimson-red with a large brilliant white core at the chest and heavier slag crusting across the shoulders, amber-gold elite trim forming a molten ring at the waist and a faint luminous edge along the silhouette, self-illuminated with the chest core throwing the strongest light outward, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Large circle at chest center, roughly 25% of sprite, larger than the standard elemental. Obvious. Always glowing brilliant white; expands visibly for 2s before Flame Nova.

FACTION: Arcane

---

### Ignarath the Ashborn  (Boss)  — base sprite

PROMPT:
Towering ancient drake dominating the full frame, imposing planted stance with wings mantled wide and head lowered toward the viewer, massive scarred scale plating over a deep chest with heavy curved horns and a battle-notched jaw, black volcanic scale with intense orange-red lava glow throughout the plate cracks and ash streaming continuously from the wing edges, grand and imposing scale with molten light radiating from the body itself, low dramatic underlighting from lava pooled at the feet, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Vertical oval at throat center-front, roughly 10% of sprite. Subtle in normal stance at 35% opacity, 100% Obvious during Fire Breath channel. Phase 3 removes the channel animation, leaving only a 1.5s Obvious window after the breath ends.

FACTION: Beast

---

## Veilborn Wastes (T4A)

### Corruption Titan  (standard)  — base sprite

PROMPT:
Large hunched humanoid beast with an oversized barrel chest, wide aggressive stance with heavy clawed fists hanging near the ground and shoulders rolled forward, thick corrupted musculature with a visibly distended sac across the torso, near-black flesh with deep void purple corruption spreading in veined patterns across the flanks and shoulders, plain corrupted form with no metal trim, cold purple underlight from the corruption veins with no external light source, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Oval on the lower-center torso over the corruption sac, roughly 15% of sprite. Subtle. Pulses Obvious only during the 2s Void Slam telegraph.

FACTION: Void

---

### Reality Shade  (standard)  — base sprite

PROMPT:
Tall lithe humanoid silhouette formed of void energy rather than matter, upright drifting stance with arms slightly raised and feet not quite touching the ground, near-featureless form with edges visibly fraying and unravelling into the surrounding air, deep purple-black void energy throughout with a hard-edged crystal embedded at the chest, plain unadorned form with no armor or trim, self-illuminated by the chest crystal with the fraying edges catching faint purple scatter, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Large circle at chest center over the void crystal, roughly 20% of sprite. Obvious. Always glowing purple-white.

FACTION: Void

---

### Veilborn Wraith  (standard)  — base sprite

PROMPT:
Tall spectral undead figure in tattered void-touched burial robes, upright drifting stance with both hands extended forward and robes trailing without weight, hollow skeletal face beneath a torn hood with visible rib structure through the robe gaps, near-black robes with deep void purple bleeding through the tatters and bone-pale grey at the face and hands, plain burial dress with no metal trim, pale purple self-illumination from the eye sockets and the soul core at the chest, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Pale orb at chest center, roughly 12% of sprite. Subtle. Faint steady pulse; brightens for 0.5s on the Life Drain wind-up.

FACTION: Undead

---

### Void Crawler  (standard)  — base sprite

PROMPT:
Medium six-limbed quadrupedal creature built low to the ground, crawling stance with limbs splayed wide and body held close to the floor, segmented carapace over a soft underbelly with no visible head structure, near-black chitin with subtle deep purple void shimmer along the carapace segment edges, plain carapace with no metal trim, minimal ambient light with the carapace edges catching cold purple rim light, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Small oval on the underbelly, lower-center of sprite, roughly 8%. Hidden. No glow. Invisible entirely during the 1.5s void phase-out.

FACTION: Void

---

### Sundered Revenant  (Elite)  — base sprite

PROMPT:
Tall armored undead figure in heavy corroded plate, upright braced stance with a longsword held low at one side, plate armor split open down the center of the chest revealing a void-fractured rib cavity beneath, dark corroded steel and bone-grey with deep purple void energy visible bleeding from the chest fissure and every armor joint, amber-gold elite trim along the pauldron edges and helm ridge, cold purple light from the chest fissure contrasting against the amber trim highlights, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Vertical fissure at chest center, roughly 14% of sprite. Subtle in Phase 1. At 50% HP the body phase-shifts semi-transparent and the fissure becomes Obvious with a 2.5x crit multiplier.

FACTION: Undead

---

### Veil Stalker  (Elite)  — base sprite

PROMPT:
Tall lithe void entity more defined and solid than a common shade, predatory forward-crouched stance with weight on the front foot and arms drawn back, sharply defined humanoid form with elongated limbs and a smooth featureless head, deep purple-black void energy throughout with a brilliant crystal at the chest, amber-gold elite trim as a luminous edge tracing the full silhouette, chest crystal throwing the primary light with the amber silhouette edge catching secondary highlight, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Large circle at chest center, roughly 20% of sprite. Obvious. Always glowing; pulses brighter for 3s after each Void Step teleport as a counter-attack window.

FACTION: Void

---

### The Veil Sovereign  (Boss)  — base sprite

PROMPT:
Towering armored void knight dominating the full frame, imposing commanding stance with one gauntlet raised and a cloak of void energy trailing behind, massive fitted plate armor fully fused with void matter and a fractured chest cuirass, near-black plate with deep purple void light bleeding through every joint and armor fissure, grand and imposing scale with void energy crackling continuously at the gauntlets, cold purple self-illumination from the armor fissures with no external light source, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Oval at chest center over the cuirass fissure, roughly 15% of sprite. Subtle in Phase 1 at 50% opacity. At 65% HP the armor cracks and the core becomes permanently Obvious.

FACTION: Void

---

## Shattered Citadel (T4B)

### Citadel Archmage  (standard)  — base sprite

PROMPT:
Tall robed humanoid mage in layered ceremonial robes, upright stance with one hand raised palm-open and the other holding a staff at rest, aged sharp-featured face beneath a low hood with heavy robe folds falling to the floor, dark slate-grey robes with broken-gold embroidery at the collar and hem and a glowing focus orb at the chest, plain scholarly dress with no armor or elite trim, blue-white magical light from the focus orb underlighting the face and hood interior, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Circle at chest center over the focus orb, roughly 15% of sprite. Obvious. Always glowing blue-white; discharges a visible arcane burst on the 30% Arcane Overload proc when crit.

FACTION: Arcane

---

### Citadel Automaton  (standard)  — base sprite

PROMPT:
Medium-height angular humanoid construct, formal upright patrol stance with arms locked at the sides and shoulders squared, segmented stone-and-metal plating with visible rune script etched into every panel and a smooth featureless faceplate, broken grey stone with dulled gold inlay along the panel seams and a runic core at the chest, plain construct with no additional trim, blue-white core light casting flat across the chest plating, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Circle at chest center over the runic core, roughly 15% of sprite. Obvious. Always glowing amber-blue; flares on the patrol-break alert pulse.

FACTION: Arcane

---

### Relic Guardian  (standard)  — base sprite

PROMPT:
Stocky heavy-plated construct built wide and low, planted defensive stance with a shield emitter braced on the forearm and the other fist closed, thick armored plating with a rectangular relic housing panel set into the left shoulder, broken grey-and-gold arcane stone with blue-white magic glowing in the seams and shield emitter, plain construct with no additional trim, blue-white emitter light casting across the chest and forward-facing plate, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Rectangular panel on the left shoulder, roughly 10% of sprite. Subtle. Goes Obvious for 3s at the moment the Relic Shield barrier activates below 50% HP.

FACTION: Arcane

---

### Ruin Lord  (standard)  — base sprite

PROMPT:
Tall humanoid outlaw in mismatched looted plate and leather, arrogant commanding stance with a broad sword resting point-down and one hand on the hip, ill-fitting armor pieces clearly taken from several different sources with a rectangular arcane component mounted on the back, dark iron and worn brown leather with broken-gold citadel plate at the pauldrons and blue-white component glow at the back, plain looted gear with no unified trim, blue-white spill from the back-mounted component catching the rear silhouette edge, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Rectangular node on the upper back, roughly 10% of sprite. Hidden. No glow visible from the front-facing pose.

FACTION: Outlaw

---

### Ruin Scavenger  (standard)  — base sprite

PROMPT:
Lean agile humanoid outlaw in light mismatched armor, furtive crouched stance with weight back on the rear foot and head turned as if checking over the shoulder, a bulging looter's pack slung high on the back leaving a gap of exposed cloth at the collar, dark worn leather and scavenged grey iron scraps with a few gold citadel fragments crudely strapped on, plain scavenged gear with no unified trim, dim ambient light with faint blue-white spill from nearby ruins catching one side of the face, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Small oval at the exposed back between pack and collar, roughly 7% of sprite. Hidden by default, becomes Obvious during the Flee state below 25% HP.

FACTION: Outlaw

---

### Spell-Bound Sentinel  (standard)  — base sprite

PROMPT:
Lean humanoid construct of stone and metal bound by visible arcane script, upright stance with one palm raised and open and the other at the side, thin angular frame with arcane script etched across every surface and a deep-carved binding rune on the forehead, broken grey stone with gold script inlay and blue-white magic light in the carved channels, plain bound construct with no additional trim, blue-white light emanating from the etched script channels across the whole body, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Rune on the forehead, upper 10% of sprite. Subtle. Pulses Obvious during the 1.5s Arcane Burst channel.

FACTION: Arcane

---

### Citadel Archmage  (Elite)  — base sprite

PROMPT:
Tall robed humanoid mage noticeably larger and more imposing than the common archmage, upright commanding stance with both hands raised and a staff floating unheld at one side, elaborate double-layered ceremonial robes with a high collar and a larger brighter focus orb at the chest, dark slate-grey robes with heavy broken-gold embroidery throughout and a faint shimmering mana barrier enveloping the figure, amber-gold elite trim at the robe collar and cuffs, blue-white orb light and the mana barrier shimmer both contributing to a doubled light source, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Circle at chest center over the focus orb, roughly 18% of sprite, larger than the standard version. Obvious. Glows more saturated while the Mana Shield holds and visibly dims when it breaks.

FACTION: Arcane

---

### Ruin Lord  (Elite)  — base sprite

PROMPT:
Tall heavyset humanoid outlaw in better-fitting looted plate than a common ruin lord, commanding elevated stance with a broad sword held across the body and shoulders squared, matched plate pieces with a larger and more prominent arcane component mounted on the back, dark iron and worn brown leather with broken-gold citadel plate throughout and a faint amber command aura shimmering around the figure, amber-gold elite trim on the pauldrons and belt buckle, blue-white component spill at the back competing with the warm amber command aura in front, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Rectangular node on the upper back, roughly 12% of sprite, larger than the standard version. Hidden. No glow from the front-facing pose.

FACTION: Outlaw

---

### Arcanist Valdren the Unfinished  (Boss)  — base sprite

PROMPT:
Towering arcane construct housing a mage's transferred consciousness, imposing stance with one hand extended and the other still adjusting a mechanism at its own side, humanoid construct frame of fitted arcane-fused plate with visible assembly seams where the body was built rather than born and a runic core at the center mass, broken grey-and-gold citadel stone with blue-white magic in the seams and an amber runic core, grand and imposing scale with an unmistakably academic bearing despite the construct body, blue-white seam light with the amber core throwing a warmer secondary light across the chest, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Oval at center mass over the runic core, roughly 14% of sprite. Subtle in Phase 1 at 45% opacity. At 65% HP the construct shell cracks open and the core becomes permanently Obvious.

FACTION: Arcane

---

## Ashenwold (T5A)

### Ancient Void Crawler  (standard)  — base sprite

PROMPT:
Medium six-limbed quadrupedal creature larger and more battle-worn than a common void crawler, low crawling stance with limbs splayed wide and body held close to the ground, heavily segmented carapace scarred by centuries of exposure with a soft underbelly beneath, near-black chitin with deeper sickly purple-green void veining running through the carapace segments and grey ash caked in the seams, plain carapace with no metal trim, minimal ambient light with the carapace edges catching cold purple-green rim light, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Oval on the underbelly, lower-center of sprite, roughly 10%. Subtle rather than Hidden — centuries of void exposure have made the core more visible than in the T4 version.

FACTION: Void

---

### Ashen Revenant  (standard)  — base sprite

PROMPT:
Tall undead humanoid in ancient military robes thickly coated in grey ash, upright stance with ash-dusted gauntlets outstretched and robes hanging heavy with accumulated ash, skeletal face beneath a hood with a pale gold soul flame burning openly at the chest, grey ash-covered robes and bone-pale features with a pale gold flame and faint sickly green undertone in the shadows, plain military dress with no metal trim, pale gold soul flame providing the primary light with ash particles catching the glow as they shed from the robes, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Circle at chest center over the soul flame, roughly 15% of sprite. Obvious. Always burning pale gold; burns visibly brighter inside the Ash Shroud below 40% HP.

FACTION: Undead

---

### Corruption Ancient  (standard)  — base sprite

PROMPT:
Large upright humanoid beast older and heavier than a corruption titan, deliberate weighted stance with clawed arms hanging wide and head lowered, ancient corrupted musculature with a swollen darkened sac dominating the torso and void energy visibly seeping from its edges, near-black flesh with deep sickly purple-green corruption spreading from the torso outward and grey ash dusting the shoulders, plain corrupted form with no metal trim, cold purple-green underlight from the seeping corruption sac with no external light source, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Oval on the torso over the corruption sac, roughly 16% of sprite. Subtle. Swells visibly and goes Obvious for the 2s before death, telegraphing the Corruption Spread DoT.

FACTION: Void

---

### Void Titan  (standard)  — base sprite

PROMPT:
Enormous upright void entity with a massive torso and heavy stone-like limbs, wide planted power stance with both arms hanging low and shoulders squared, dense near-black body mass with a brilliant void heart orb dominating the center of the chest, near-black form with brilliant purple-white void light radiating from the heart across the whole torso and grey ash settled in the surface crevices, plain form with no metal trim, void heart providing the sole light source casting hard upward shadows across the jaw and chest, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Large circle at chest center over the void heart, roughly 22% of sprite. Obvious. Always glowing brilliant purple-white; flares brighter during the 1.5s Void Crush retaliation telegraph.

FACTION: Void

---

### Ashen Warlord  (Elite)  — base sprite

PROMPT:
Heavily armored ancient undead commander in corrupted military plate coated in grey ash, commanding battle stance with one arm raised mid-War-Cry and a heavy sword held at the other side, full plate harness with a helm crest and a glowing war brand seared into the left pauldron, ash-grey corroded plate and bone with sickly purple-green void energy at the joints, amber-gold elite trim along the pauldron edges and helm crest, the war brand and amber trim both catching light against the otherwise matte ash-covered plate, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Oval on the left pauldron over the war brand, roughly 10% of sprite. Subtle. Goes Obvious for 3s during the Ash Rally War Cry, the intended counter-attack window.

FACTION: Undead

---

### Void Archon  (Elite)  — base sprite

PROMPT:
Tall imposing void entity fully formed and more solid than any lesser shade, levitating stance with arms raised in arcane authority and feet clear of the ground, sharply defined humanoid form with elongated proportions and a smooth featureless head, deep purple-void energy throughout with a brilliant archon core blazing at the chest and faint grey ash drifting through the body, amber-gold elite trim forming a halo-ring above the head and a luminous silhouette edge, archon core throwing intense light with the amber halo catching a distinct warmer highlight, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Large circle at chest center over the archon core, roughly 20% of sprite. Obvious. Always blazing purple-white; a crit here has a 25% chance to trigger Void Cascade, which buffs nearby enemies.

FACTION: Void

---

### The Ashen Sovereign  (Boss)  — base sprite

PROMPT:
Towering ancient sovereign undead in massive ornate plate armor buried under a thousand years of ash, imposing dominant stance with one arm raised in command and a heavy mantle hanging from the shoulders, ceremonial full plate with a large carved war seal at the chest and ash streaming continuously from the pauldrons, ash-grey plate and bone with deep sickly purple-green void energy bleeding from every armor joint, grand and imposing scale radiating ancient authority, cold purple-green joint light with ash particles catching the glow as they fall, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Oval at chest center over the ancient war seal, roughly 14% of sprite. Subtle through Phases 1 and 2 at 40% opacity. At 35% HP the seal visibly cracks and becomes permanently Obvious.

FACTION: Void

---

## Elder Reaches (T5B)

### Ancient Wyvern  (standard)  — base sprite

PROMPT:
Large two-legged wyvern heavier and more weathered than a highland wyvern, standing tall on clawed hind legs with broad leathery wings folded against the sides and an armored blunt head with deep brow ridges, thick wing membrane over prominent bone struts with an old scar at the wing-body joint, dark volcanic-grey and mossy brown scale with deep green lichen growth in the hide seams, plain hide with no metal trim, cool overhead light with primordial gold rune-glow spilling from offscreen catching the wing edges, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Small oval at the scarred wing joint where wing meets body, center-side of sprite, roughly 8%. Hidden. No glow; brief Obvious reveal during the Wing Beat shockwave only.

FACTION: Beast

---

### Elder Construct  (standard)  — base sprite

PROMPT:
Angular humanoid construct of pre-civilisation design with unfamiliar alien geometry in the limb joints, precise measured patrol stance with arms held at exact angles and a smooth featureless head, fitted stone-and-crystal frame with a multi-faceted crystal set into the chest, ancient warm grey-brown stone with deep green moss in the seams and primordial gold rune-light in the carved channels, plain construct with no additional trim, gold rune-light emanating from the carved channels with the chest crystal catching and refracting it, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Faceted crystal at chest center, roughly 13% of sprite. Subtle. Pulses Obvious during the 10s Overclock window, and the 2s stagger afterward is the optimal burst opening.

FACTION: Arcane

---

### Primordial Drake  (standard)  — base sprite

PROMPT:
Large four-legged drake more ancient and scarred than any lesser drake, aggressive low stance with head forward and wings held tight against the flanks, heavily scarred overlapping scale hide with a deep old flame scar across the throat and worn blunted horns, charcoal-black scale with deep green moss growth along the spine ridge and deep orange ember glow at the throat scar, plain hide with no metal trim, primordial gold rune-light from offscreen catching the spine ridge with the throat ember providing warm local fill, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Vertical oval at the throat scar, center-front of neck, roughly 12% of sprite. Subtle normally at 40% opacity, 100% Obvious during the 3.5s Fire Breath channel.

FACTION: Beast

---

### World Golem  (standard)  — base sprite

PROMPT:
Enormous round-limbed earth construct built from ancient quarried stone, stable planted stance with heavy arms hanging at the sides and a squat neckless head, massive rounded stone masses joined without visible mechanism and a large rune carved deep into the chest slab, ancient warm grey-brown stone with heavy deep green moss across the shoulders and back and faint primordial gold rune-light in the chest carving, plain construct with no additional trim, soft ambient light with the chest rune barely perceptible against the surrounding stone, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Carved rune on the chest slab, roughly 14% of sprite. Subtle. Dims to near-invisible while the golem regenerates out of combat, so aggressive engagement is rewarded over kiting.

FACTION: Arcane

---

### Primordial Alpha  (Elite)  — base sprite

PROMPT:
Large four-legged drake significantly heavier and more dominant than a primordial drake, commanding stance with head raised high in pack-leader posture and chest pushed forward, deeply battle-scarred scale hide with a pronounced crest ridge and a deep defined throat scar, charcoal-black scale with deep green moss along the spine and intense orange ember at the throat, amber-gold elite trim along the horn tips and crest ridge as a luminous silhouette edge, throat ember and amber crest trim providing paired warm highlights against the cool moss-green body, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Vertical oval at the throat scar, roughly 12% of sprite. Subtle. Goes Obvious for 4s during the Pack Call howl at 60% HP and again at 30% HP.

FACTION: Beast

---

### Rune Colossus  (Elite)  — base sprite

PROMPT:
Towering pre-civilisation construct considerably larger than an elder construct, still powerful stance with arms at the sides and a squared massive frame, ancient stone body covered edge to edge in unknown rune script with a rune crown etched across the head, ancient warm grey-brown stone with deep green moss in the lower seams and primordial gold rune-light throughout the carved script, amber-gold elite trim concentrated as glowing highlights in the rune crown, gold script light distributed across the whole body with the crown as the brightest point, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 256x256

WEAK-POINT NOTES:
Rune crown across the head, upper 12% of sprite. Subtle by default. Goes fully Obvious for the entire 4s Rune Channel; interrupting the channel cancels the shockwave and stuns for 1.5s.

FACTION: Arcane

---

### The World Warden  (Boss)  — base sprite

PROMPT:
Colossal ancient stone construct of pre-civilisation origin dominating the full frame, absolutely still stance with both arms at the sides radiating timeless authority, body a fusion of precisely worked stone and raw natural rock with a primordial eye-like rune carved into the chest, ancient grey-brown stone with heavy deep green moss across the shoulders and primordial gold rune-light barely visible in the carved lines, grand and imposing scale with an intact unbroken outer shell, soft ambient light with the chest rune almost imperceptible against the surrounding stone, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Eye-like rune at chest center, roughly 12% of sprite. Hidden in Phase 1 with no glow at all. Becomes Subtle at 50% HP when the shell crumbles, then fully Obvious at 35% HP.

FACTION: Arcane

---

## Dungeon Bosses (320x320)

### Aldric the Wolf  (Boss)  — base sprite

PROMPT:
Stocky humanoid bandit leader dominating the frame, confident menacing stance with dual hand-axes held loose at the belt and shoulders rolled back, battered leather armor over a heavy build with a fur-lined cloak and a raised scar visible across the left shoulder pauldron, dark earth-brown leather and worn iron with warm amber torchlight tones, grand and imposing scale for an otherwise human-sized outlaw, warm amber torchlight from the left as if lit by a tunnel brazier, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Raised scar on the left shoulder pauldron, upper-left quadrant, roughly 15% of sprite. Subtle. Always visible but never glows.

FACTION: Outlaw

---

### Captain Mirra Vane  (Boss)  — base sprite

PROMPT:
Lithe humanoid pirate captain dominating the frame, aggressive forward-leaning stance with dual cutlasses held wide and coat flaring behind, long weathered naval coat over light leather with a large ornate belt buckle at the waist center, dark sea-weathered teal and grey with brass fittings and salt-bleached highlights, grand and imposing scale for an otherwise human-sized outlaw, cool sea-cave lantern light from above with brass fittings catching warm secondary highlights, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Ornate belt buckle at torso center, roughly 10% of sprite. Subtle. Always visible but never glows.

FACTION: Outlaw

---

### Ignarath's Broodmother  (Boss)  — base sprite

PROMPT:
Massive four-legged drake with a broader lower build than a standard drake, protective low crouching stance over a nest with wings mantled defensively forward, heavy scale plating across the back with a swollen glowing egg sac dominating the lower abdomen, black volcanic scale with orange-red lava glow in the plate cracks and an intensely glowing orange egg sac, grand and imposing scale with a distinctly maternal defensive posture, egg sac providing strong warm underlight across the belly and forelimbs, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Large oval on the lower abdomen over the egg sac, roughly 20% of sprite. Obvious. Always glowing orange-red; Protective Surge in Phase 2 raises the multiplier from 2.0x to 2.5x.

FACTION: Beast

---

### The Hollow Archbishop  (Boss)  — base sprite

PROMPT:
Tall gaunt undead cleric in ruined ecclesiastical vestments dominating the frame, imposing upright stance with both arms spread in a mockery of benediction and a tall mitre crowning the head, layered ceremonial robes hanging from a skeletal frame with a corrupted holy symbol at the chest, near-black robes with void-purple corruption bleeding through the fabric and tarnished gold at the vestment trim, grand and imposing scale with a hollow ecclesiastical grandeur, cold void-purple light from the chest symbol underlighting the mitre and skeletal face, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Oval at chest center over the corrupted holy symbol, roughly 20% of sprite. Subtle in Phase 1 at 50% opacity. Obvious from Phase 2 onward, pulsing on a 15s interval and a 7s interval in Phase 3.

FACTION: Undead

---

### The Firststone Warden  (Boss)  — base sprite

PROMPT:
Enormous pre-civilisation construct of impossibly precise ancient stone dominating the frame, absolutely still commanding stance with arms locked at the sides and a smooth featureless head, flawlessly fitted stone masonry with no visible tooling marks and a primordial rune eye carved into the chest, ancient grey-brown stone with deep green moss in the lower seams and faint primordial gold rune-light in the carved lines, grand and imposing scale with a pristine unbroken outer shell, soft ambient light with the chest rune barely perceptible, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Rune eye at chest center, roughly 12% of sprite. Hidden in Phase 1, Subtle in Phase 2, Obvious in Phases 3 and 4 once the outer shell is shed. Phase 4 multiplier rises to 2.5x.

FACTION: Arcane

---

### The Pale Vault Warden  (Boss)  — base sprite

PROMPT:
Towering ancient guard construct from the void war era dominating the frame, hunched guarding stance with arms braced forward as though still holding a line, heavy corroded plate armor buried under a thousand years of vault dust with a cracked containment seal at the chest, ash-grey corroded plate with pale purple-white void light leaking from the seal cracks and grey ash drifting from the shoulders, grand and imposing scale with the bearing of something that has stood watch far too long, pale void light from the chest seal as the sole illumination, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Oval at chest center over the cracked containment seal, roughly 18% of sprite. Obvious in all phases. Always glowing pale void-white.

FACTION: Void

---

### The Veil Harbinger  (Boss)  — base sprite

PROMPT:
Massive void entity mid-emergence from a reality tear dominating the frame, commanding stance with one arm raised and the lower body still partially unformed where it meets the tear, tall humanoid form of pure void energy with reality visibly fraying and unravelling along the silhouette edges, near-black void mass with brilliant purple-white light from a pulsing core at the chest, grand and imposing scale with the fraying edge effect emphasising the unnatural nature of the form, chest core as the sole light source with the fraying edges catching purple scatter, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Large circle at chest center over the void core, roughly 20% of sprite. Obvious in all phases. Always pulsing purple-white; pulses on a 10s interval from Phase 2 as an additional crit window.

FACTION: Void

---

### Valdren the Unfinished  (Boss)  — base sprite

PROMPT:
Towering arcane construct dominating the frame shown in its shell-cracked state, active combat stance with both arms extended and arcane energy streaming from each hand, humanoid construct frame with the outer plate visibly fractured down the center revealing the runic core beneath, broken grey-and-gold citadel stone with blue-white magic in the seams and a bright amber runic core exposed through the fissure, grand and imposing scale with the cracked shell reading as damage sustained rather than design, amber core light through the fissure as the dominant source with blue-white seam light as fill, full-body realistic pixel-art proportions (Octopath Traveler / Blasphemous), limited palette, dark pixel outline, HD-2D pixel art, dark medieval fantasy, transparent background, 320x320

WEAK-POINT NOTES:
Oval at center mass over the exposed runic core, roughly 16% of sprite. Obvious, since this sprite depicts the post-crack state. Distinguishes the dungeon version visually from the zone boss sprite.

FACTION: Arcane

---

*Path: docs/enemy-sprite-prompts-backfill.md*
*38 enemies across 5 zones plus 8 dungeon bosses. Base sprites only.*
*Animation frames (idle, attack, death) derive from the approved base sprite.*
