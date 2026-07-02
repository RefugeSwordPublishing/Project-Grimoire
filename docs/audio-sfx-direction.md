# ⚔️ Project Grimoire — Audio & SFX Direction
### Version 0.1

---

## 📐 Design Philosophy

Project Grimoire's audio should feel like a natural extension of the idle loop — present and atmospheric without demanding attention. Players often have the app running in the background or alongside other media, so audio must be pleasant at low volume, rewarding when active, and never jarring or repetitive enough to become annoying over long sessions.

**Core pillars:**
- **Peaceful by default** — gathering, processing, and idle states feel like a relaxing medieval world ticking along
- **Distinct but not aggressive in combat** — combat music is clearly different from idle, but shares the same world tone
- **SFX grounds the experience** — sound effects tie actions to the physical world without being cartoonish
- **All audio optional** — every layer (music, SFX, UI sounds) independently toggleable in Settings
- **Proportional to action** — Attunement bonuses and rare events get audio feedback, routine idle does not

---

## 🎵 Music Direction

### Gathering & Processing (Idle and Active)
**Reference:** The Legend of Zelda series (particularly Breath of the Wild ambient tracks, Link's Awakening), Idle Iktah

**Characteristics:**
- Gentle, acoustic instrumentation — lute, acoustic guitar, soft flute, light percussion
- Slow tempo, 60–80 BPM — relaxed without being sleepy
- Melodic but not repetitive — themes should loop naturally without obvious seam points
- Dynamic layering — idle state plays the base layer only, active Attunement adds a second instrument layer subtly (e.g. a soft melody line joins the ambient base when the player is actively interacting)
- No dramatic swells or sudden changes — smooth and continuous

**Mood by Talent category:**
| Category | Mood | Instrumentation feel |
|----------|------|---------------------|
| Gathering (outdoor) | Pastoral, open air | Acoustic guitar/lute, birdsong ambient, light breeze |
| Gathering (underground — Delving) | Earthy, quiet mystery | Low strings, soft percussion, cave reverb |
| Gathering (water — Dredging) | Flowing, peaceful | Harp, soft flute, gentle water ambient |
| Processing (Cookery, Alchemy) | Warm, domestic | Piano, soft woodwind, hearth crackle ambient |
| Processing (Runesmithing, Smelting) | Purposeful, rhythmic | Light anvil rhythm as percussion, low strings |
| Arcane (Enchanting, Inscription) | Thoughtful, slightly mystical | Gentle harpsichord, soft choir undertone |

> Note: In Phase 1 (Warden only), a single gathering track and a single processing track are sufficient. Per-Talent-category music can be added progressively as new Talent categories are implemented.

### Combat Music
**Reference:** Final Fantasy series (particularly FFXIV overworld combat themes, FF9 battle themes) — melodic, rhythmically engaging, clearly distinct from idle without being intense or stressful

**Characteristics:**
- Same instrument family as the gathering music — same world, different energy
- Tempo increases to ~100–120 BPM — noticeably faster than idle but not frantic
- Melodic lead instrument over a rhythmic backing — a clear theme rather than just percussion
- Loops cleanly — combat encounters can vary in length, the music must work at any point in the loop
- Victory sting — a brief 2–3 second melodic resolution when an enemy is defeated (can be toggled separately from combat music)

**Zone music (deferred to later release):**
Each combat zone will eventually have its own version of the combat theme — same structure, different instrumentation or key to reflect the biome. For example:
- Grimwood Fringe — darker string backing, minor key feel
- Saltmarsh Shore — lighter, some water/wind instrument texture
- Ashenwold — sparse, unsettling, fewer instruments

> Zone-specific music is a post-Phase 1 addition. All zones share the base combat track at launch.

### UI / Menu Music
- Soft ambient version of the gathering theme — even quieter, more background
- Plays on the main menu, talent screen, exchange, and grimoire screens
- Same Zelda/Iktah reference — familiar and calming

### Special Event Music
| Event | Audio treatment |
|-------|----------------|
| Zone boss spawn | Brief 3-second musical sting to alert the player, then combat music begins |
| Zone boss defeated | Victory fanfare — slightly more elaborate than standard enemy defeat sting |
| Level up | Soft ascending chime — pleasant, not overstated |
| Rare material drop | Single distinctive note or brief 2-note chime — different from level up |
| Grimoire swap | Brief magical flourish — feels significant |
| Dungeon cleared | Short triumphant resolution — celebration without being excessive |
| Raid boss phase change | Musical shift within the combat track — same instruments, tension increases |

---

## 🔊 Sound Effects Direction

All SFX are grounded in the physical reality of the medieval fantasy world. No cartoonish or exaggerated sounds — everything should feel like it belongs in the same world as the visuals.

### Gathering SFX

| Talent | Action | SFX Description |
|--------|--------|-----------------|
| **Foraging** | Pluck herb/plant | Soft leaf rustle + gentle snap |
| **Foraging** | Quality tier bonus (Attunement) | Soft magical shimmer — brief, subtle |
| **Felling** | Axe swing | Clean wood chop — solid thud, satisfying |
| **Felling** | Tree falls | Slow creak then crash, distant echo |
| **Felling** | Attunement timing hit | Bark crack sound + resonant wood knock |
| **Delving** | Pickaxe strike | Metallic tink on stone — clear and crisp |
| **Delving** | Ore node depleted | Crumble of rock, small debris settle |
| **Delving** | Gem found | Faint crystalline ping |
| **Trapping** | Trap placed | Mechanical click/snap |
| **Trapping** | Creature caught | Trap snap + creature rustle |
| **Dredging** | Cast line | Soft whoosh + water splash |
| **Dredging** | Fish bite | Line tension twang |
| **Dredging** | Fish landed | Splashing + flop |
| **Gleaning** | Searching | Soft rummaging, cloth movement |
| **Gleaning** | Item found | Dry scrape of finding something buried |
| **Cultivation** | Watering | Gentle pour, soil absorption |
| **Cultivation** | Harvest | Soft pull/snap of plant from earth |
| **Tracking** | Trail found | Subtle awareness chime — more magical than physical |

### Processing SFX

| Talent | Action | SFX Description |
|--------|--------|-----------------|
| **Alchemy** | Stirring | Liquid swirl in glass |
| **Alchemy** | Brew complete | Soft pop + liquid settle |
| **Cookery** | Cooking active | Gentle sizzle/bubble ambience |
| **Cookery** | Meal complete | Soft bell, like a kitchen timer |
| **Smelting** | Bellows pump | Whoosh of air |
| **Smelting** | Bar poured | Liquid metal hiss |
| **Runesmithing** | Anvil strike | Clear metallic ring — different tone from Delving pickaxe |
| **Runesmithing** | Item forged | Metal cooling hiss + satisfied clunk |
| **Timber Shaping** | Planing | Long smooth wood scrape |
| **Tanning** | Scraping | Rhythmic leather working sound |
| **Tailoring** | Stitching | Needle through cloth, thread pull |
| **Inscription** | Writing | Quill scratch on parchment |
| **Enchanting** | Applying enchant | Rising magical hum + soft crack of energy |
| **Artificing** | Assembly | Mechanical clicks, gear engagement |

### Combat SFX

| Action | SFX Description |
|--------|-----------------|
| **Bowstring draw** | Bow creak + string tension — increases with draw distance |
| **Arrow release** | Snap + whoosh |
| **Arrow hit — body** | Solid thud |
| **Arrow hit — weak point (crit)** | Sharper thud + brief energy crack |
| **Arrow miss** | Soft whoosh fading |
| **Enemy attack incoming** | Brief warning grunt or movement sound |
| **Player hit** | Impact grunt, brief |
| **Player evade** | Quick movement swoosh |
| **Block** | Armor impact — heavier, more solid than a hit |
| **Enemy death** | Collapse sound appropriate to enemy type (humanoid fall, creature slump) |
| **LCK wild card trigger** | Very brief subtle shimmer — fortune feeling, not dramatic |
| **Poison proc** | Soft toxic drip sound |
| **Fire coating proc** | Brief whomp of flame |
| **Void coating proc** | Low hollow resonance |
| **Rune drawing (Arcanist)** | Each node touched plays a distinct tone — completing a combination plays a short chord |
| **Spell cast** | Element-appropriate — fire whoosh, frost crystalline crack, lightning snap |

### UI SFX

| Action | SFX Description |
|--------|-----------------|
| **Button tap** | Soft click — not a phone tap sound, something more tactile and medieval |
| **Menu open/close** | Light page turn or wood creak |
| **Talent level up** | Ascending chime — warm, satisfying |
| **Unlock new Field Notes/Schematic/etc** | Parchment unfurl sound |
| **Exchange listing created** | Coin clink |
| **Exchange sale completed** | Coin clink + satisfaction ding |
| **Buy Order filled** | Brief transaction sound |
| **Grimoire equipped** | Book open + magical resonance |
| **Grimoire on cooldown** | Low soft lock sound |
| **Quest accepted** | Parchment seal |
| **Quest completed** | Soft fanfare sting |
| **Push notification received** | Gentle tone — not a standard phone notification sound |
| **WYWA screen opens** | Soft page turn + ambient swell |
| **Guild bank deposit** | Coin drop into chest |
| **Guild upgrade purchased** | Heavier, more significant version of the coin sound |

---

## ⚙️ Settings — Audio Controls

All audio controls live in a dedicated **Audio** section in Settings. Each layer is independently toggled:

| Setting | Default | Options |
|---------|---------|---------|
| Master Volume | On | Slider 0–100% |
| Music | On | Toggle + volume slider |
| Sound Effects | On | Toggle + volume slider |
| UI Sounds | On | Toggle + volume slider |
| Victory Stings | On | Toggle (some players find these repetitive over time) |
| Notifications Sound | On | Toggle |

**Behavior when app is backgrounded:**
- Music fades out when app goes to background (idle mode), respects device silent mode
- SFX muted entirely when backgrounded
- Notification sound respects the Notifications Sound toggle independently of master

---

## 🎵 Phase 1 Confirmed Tracks

| Track | Title | Tool | Status |
|-------|-------|------|--------|
| Gathering/Processing idle | **Moonlit Caravan** | Suno | ✅ Locked |
| Combat | **Battle** | Suno | ✅ Locked |
| UI/Menu ambient | **Silent Save Point** | Suno | ✅ Locked |
| Short stings (level up, rare drop, boss spawn, quest complete) | TBD | Sfxr.me | Pending — to be sourced via desktop |
| Individual SFX (wood chop, tink, water splash etc.) | TBD | Freesound.org / Sfxr | Pending — to be sourced via desktop |

> Art assets (sprites, environments, UI panels) are handled by Claude Code via Sprite AI MCP connector — not sourced manually.

---

## 🛠️ Technical Notes for Implementation

- **Audio engine:** Unity's built-in Audio System is sufficient for Phase 1. Unity Audio Mixer for layered music (idle base layer + Attunement active layer)
- **Music format:** OGG Vorbis for smallest file size at acceptable quality on mobile
- **SFX format:** WAV for short clips (under 2 seconds), OGG for longer ambient loops
- **Loop points:** All music tracks need carefully set loop points to avoid seam artifacts — this should be handled in the audio source files before import into Unity
- **AudioManager.cs** — a dedicated manager should handle all audio state (what's playing, layer blending, settings application). Do not scatter AudioSource calls across individual scripts
- **Attunement layer blend:** When player enters active Attunement, the second music layer should crossfade in over ~2 seconds, not cut in abruptly
- **SFX pooling:** Use an audio pool for frequently triggered SFX (axe chops, pickaxe strikes) to avoid AudioSource instantiation overhead during active play
- **Zone music (future):** Design AudioManager to accept a zone_id parameter from the start, even if all zones return the same track in Phase 1 — prevents rework when per-zone music is added

---

## 🎼 Music Sourcing Notes

**Original composition** is the ideal long-term goal — builds a unique identity for the game and avoids licensing complexity. For Phase 1 however, two practical options:

| Option | Source | Notes |
|--------|--------|-------|
| **Licensed stock** | Artlist.io, Epidemic Sound, Musicbed | Monthly subscription gives access to royalty-free tracks that match the Zelda/ambient brief. Good for prototyping and early access |
| **Commission** | Fiverr (search "fantasy RPG game music"), UpWork | Budget $200–600 for a small suite of tracks. Brief: "peaceful medieval fantasy idle game music, Zelda BOTW and Idle Iktah influenced, needs clean loop points" |
| **Original** | Hire a game composer post-launch with revenue | Long-term goal — budget ~$2,000–5,000 for a full original suite per-zone |

**Recommended Phase 1 approach:** Source 2–3 licensed tracks from Artlist or Epidemic Sound for gathering, processing, and combat. Commission original music post-launch once revenue supports it.

---

*Document version 0.1 — Audio & SFX Direction*
*Next: Bestiary · Runic Constellation mechanic spec · Melee combo system · Skirmish Board · Phase 2 design prep*
