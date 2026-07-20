# ⚔️ Project Grimoire — Assembly Materials & Crafting System
### Version 0.5

---

## 📐 Core Assembly Rules

### Assembly Ownership
Each weapon, armor piece, and tool has a designated **assembler Talent** — the Talent whose specialist would logically be the expert in that item. The assembler sources components from other Talents via trade or the Wayfarer's Exchange.

**The assembler always:**
- Provides at least one component themselves
- Sources the rare material for Assembly
- Performs the Assembly action and earns Assembly XP in their Talent
- Benefits from attunement bonus during Assembly (% chance to save secondary component)

### Component Counts
| Item Type | Components Required | Rare Material at Assembly |
|-----------|-------------------|--------------------------|
| Weapon (1H) | 2 (assembler component + secondary component) | 1 rare material |
| Weapon (2H/heavy) | 2 (assembler component + secondary component) | 1 rare material |
| Tool | 2 (assembler component + secondary component) | 1 rare material |
| Quiver | 2 (Tailoring body + Timber frame) | 1 rare material |
| Armor piece | 3 (primary body + lining/padding + fastening) | 1 rare material |

### Assembly XP
- Component crafters receive XP in their Talent at time of crafting
- **Assembly XP** goes to the assembler Talent specifically
- Assembly is a meaningful economy role — high-level assemblers get better attunement bonuses

### Attunement Bonuses During Assembly
Two distinct attunement moments per crafting Talent:

**1. Assembly attunement** — when combining components at the Workbench:
- Success adds +% to rare material tier success rate
- Specific % determined by assembler Talent level (see Attunement Data Spec)

**2. Component crafting attunement** — when making individual components:
- Success gives XP boost
- Small % chance to save secondary component (not consumed)

### Resource Save Chance (Component Crafting Attunement)
| Talent Level | Secondary Component Save Chance |
|-------------|-------------------------------|
| 1–20 | 1% |
| 21–40 | 2% |
| 41–60 | 4% |
| 61–80 | 6% |
| 81–100 | 8% |

### Upgrade Failure Behaviour

**Old model (v0.4) is retired.** The fail cascade (components consumed, auto-rolls down a tier) is replaced by the upgrade model.

```
Attempt to upgrade Rough Axe → Refined Axe
  → SUCCESS: Rough Axe becomes Refined Axe. Components + rare material consumed.
  → FAIL:    Rough Axe returned unchanged. Components + rare material consumed.
             No downgrade. No cascade. No output below current tier.
```

**Rules:**
- The existing tool is NEVER destroyed or downgraded on fail
- Only the upgrade components and rare material are consumed on fail
- There is no guaranteed floor output — if you attempt and fail, you keep what you had
- Crude items are always built fresh (no previous tier required)
- Every tier above Crude requires the previous tier tool as an ingredient

This applies to ALL tools and weapons. The old fail cascade is removed entirely.

### Quality Tier Reference
| Tier | Name | Color |
|------|------|-------|
| 1 | Crude | Grey |
| 2 | Rough | White |
| 3 | Refined | Green |
| 4 | Pristine | Blue |
| 5 | Masterwork | Purple |
| 6 | Legendary | Gold | DLC / Events only |

---

## 🔧 Tool & Weapon Upgrade Model

### Core Rules

All tools and weapons above Crude quality require the previous tier as an
ingredient. Crude is always built fresh from components. This eliminates
market flooding — lower tier items are consumed in the upgrade chain.

```
Crude  → built fresh from components
Rough  → Crude + tier-2 components + rare material
Refined → Rough + tier-3 components + rare material
Pristine → Refined + tier-4 components + rare material
Masterwork → Pristine + tier-5 components + rare material
```

**On success:** Previous tier tool transforms to new quality tier.
**On fail:** Previous tier tool returned unchanged. Components and rare material consumed.
**No downgrade on fail — ever.**

The attunement bonus during assembly improves success chance.
High-level assemblers offering upgrade services charge for their
attunement skill — a genuine economy role.

### Base Success Rates

| Target Quality | Base Success | With max attunement bonus |
|---------------|-------------|--------------------------|
| Crude | 100% | 100% |
| Rough | 70% | 85% |
| Refined | 55% | 72% |
| Pristine | 35% | 55% |
| Masterwork | 20% | 38% |

Attunement bonus = assembler Talent level × 0.18% (max +18% at level 100).

---

### 🏹 Bow (Warden primary weapon)
**Assembler:** Timber Shaping
**Assembly XP:** Timber Shaping
**Rare Material:** Gemstone (from Delving) — forces cross-Talent purchase

| Quality Target | Timber Shaping Component | Runesmithing Component | Rare Material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Limbs + Grip | Bronze Tips | None |
| Rough | Hardwood Limbs + Grip | Iron Tips | Crude Gemstone |
| Refined | Ashwood Limbs + Grip | Steel Tips | Rough Gemstone |
| Pristine | Ironbark Limbs + Grip | Mithril Tips | Refined Gemstone |
| Masterwork | Voidtimber Limbs + Grip | Void Tips | Pristine Gemstone |

---

### ⚔️ Sword (Vanguard primary weapon)
**Assembler:** Runesmithing
**Assembly XP:** Runesmithing
**Rare Material:** Gemstone (from Delving)

| Quality Target | Runesmithing Component | Timber Shaping Component | Rare Material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Blade | Pine Grip | None |
| Rough | Iron Blade | Hardwood Grip | Crude Gemstone |
| Refined | Steel Blade | Ashwood Grip | Rough Gemstone |
| Pristine | Mithril Blade | Ironbark Grip | Refined Gemstone |
| Masterwork | Void Blade | Voidtimber Grip | Pristine Gemstone |

---

### 🪓 Battle Axe (Vanguard weapon)
**Assembler:** Runesmithing
**Assembly XP:** Runesmithing
**Rare Material:** Gemstone (from Delving)

| Quality Target | Runesmithing Component | Timber Shaping Component | Rare Material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Head | Pine Haft | None |
| Rough | Iron Head | Hardwood Haft | Crude Gemstone |
| Refined | Steel Head | Ashwood Haft | Rough Gemstone |
| Pristine | Mithril Head | Ironbark Haft | Refined Gemstone |
| Masterwork | Void Head | Voidtimber Haft | Pristine Gemstone |

---

### 🗡️ Dagger (Warden/Shadowblade secondary)
**Assembler:** Runesmithing
**Assembly XP:** Runesmithing
**Rare Material:** Gemstone (from Delving)

| Quality Target | Runesmithing Component | Tanning Component | Rare Material |
|---------------|------------------------|-------------------|---------------|
| Crude | Bronze Blade | Rough Leather Wrap | None |
| Rough | Iron Blade | Cured Leather Wrap | Crude Gemstone |
| Refined | Steel Blade | Fine Leather Wrap | Rough Gemstone |
| Pristine | Mithril Blade | Wolf Leather Wrap | Refined Gemstone |
| Masterwork | Void Blade | Masterwork Leather Wrap | Pristine Gemstone |

---

### 🔱 Spear (Vanguard weapon)
**Assembler:** Runesmithing
**Assembly XP:** Runesmithing
**Rare Material:** Phantom Pelt (from Trapping)

| Quality Target | Runesmithing Component | Timber Shaping Component | Rare Material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Spearhead | Pine Pole | None |
| Rough | Iron Spearhead | Hardwood Pole | Crude Phantom Pelt |
| Refined | Steel Spearhead | Ashwood Pole | Rough Phantom Pelt |
| Pristine | Mithril Spearhead | Ironbark Pole | Refined Phantom Pelt |
| Masterwork | Void Spearhead | Voidtimber Pole | Pristine Phantom Pelt |

---

### 🔮 Staff (Arcanist primary weapon)
**Assembler:** Arcane Weaving
**Assembly XP:** Arcane Weaving
**Rare Material:** Abyssal Pearl (from Dredging)

| Quality Target | Timber Shaping Component | Runesmithing Component | Rare Material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Softwood Shaft | Bronze Core | None |
| Rough | Hardwood Shaft | Silver Core | Crude Abyssal Pearl |
| Refined | Magicwood Shaft | Starstone Core | Rough Abyssal Pearl |
| Pristine | Ironbark Heartwood Shaft | Starstone Core+ | Refined Abyssal Pearl |
| Masterwork | Voidtimber Shaft | Void Core | Pristine Abyssal Pearl |

---

### 🪄 Wand (Arcanist secondary)
**Assembler:** Arcane Weaving
**Assembly XP:** Arcane Weaving
**Rare Material:** Void Spore (from Foraging)

| Quality Target | Timber Shaping Component | Runesmithing Component | Rare Material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Handle | Bronze Tip | None |
| Rough | Hardwood Handle | Silver Tip | Crude Void Spore |
| Refined | Magicwood Handle | Starstone Tip | Rough Void Spore |
| Pristine | Ironbark Handle | Starstone Tip+ | Refined Void Spore |
| Masterwork | Voidtimber Handle | Void Tip | Pristine Void Spore |

---

## 🛠️ TOOL ASSEMBLY TABLES

### 🪓 Felling Axe (Felling tool)
**Assembler:** Timber Shaping
**Assembly XP:** Timber Shaping
**Rare Material:** Gemstone (from Delving) — cross-Talent purchase required

| Quality Target | Runesmithing Component | Timber Shaping Component | Rare Material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Head | Pine Haft | None |
| Rough | Iron Head | Hardwood Haft | Crude Gemstone |
| Refined | Steel Head | Ashwood Haft | Rough Gemstone |
| Pristine | Mithril Head | Ironbark Haft | Refined Gemstone |
| Masterwork | Void Head | Voidtimber Haft | Pristine Gemstone |

> Higher tier Felling Axes increase Attunement window and bonus timber yield

---

### ⛏️ Pickaxe (Delving tool)
**Assembler:** Runesmithing
**Assembly XP:** Runesmithing
**Rare Material:** Amber (from Felling) — cross-Talent purchase required

| Quality Target | Runesmithing Component | Timber Shaping Component | Rare Material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Head | Pine Haft | None |
| Rough | Iron Head | Hardwood Haft | Crude Amber |
| Refined | Steel Head | Ironbark Haft | Rough Amber |
| Pristine | Mithril Head | Ironbark Heartwood Haft | Refined Amber |
| Masterwork | Adamantine Head | Voidtimber Haft | Pristine Amber |

> Higher tier Pickaxes increase ore yield and gem drop chance in Delving

---

### 🎣 Fishing Rod (Dredging tool)
**Assembler:** Timber Shaping
**Assembly XP:** Timber Shaping
**Rare Material:** Void Spore (from Foraging)

| Quality Target | Timber Shaping Component | Arcane Weaving Component | Rare Material |
|---------------|--------------------------|--------------------------|---------------|
| Crude | Pine Rod | Basic Line Wrap | None |
| Rough | Hardwood Rod | Cured Thread Line | Crude Void Spore |
| Refined | Ashwood Rod | Arcane Thread Line | Rough Void Spore |
| Pristine | Magicwood Rod | Aetheric Line | Refined Void Spore |
| Masterwork | Voidtimber Rod | Void Filament Line | Pristine Void Spore |

---

### 🪤 Trapper's Kit (Trapping tool)
**Assembler:** Artificing
**Assembly XP:** Artificing
**Rare Material:** Ancient Sigil (from Tracking)

| Quality Target | Artificing Component | Tanning Component | Rare Material |
|---------------|----------------------|-------------------|---------------|
| Crude | Iron Trap Frame | Rough Leather Pouch | None |
| Rough | Steel Trap Frame | Cured Leather Pouch | Crude Ancient Sigil |
| Refined | Steel Clockwork Frame | Fine Leather Pouch | Rough Ancient Sigil |
| Pristine | Mithril Clockwork Frame | Wolf Leather Pouch | Refined Ancient Sigil |
| Masterwork | Adamantine Frame | Masterwork Leather Pouch | Pristine Ancient Sigil |

---

### 🏹 Quiver (Warden core equipment)
**Assembler:** Tailoring
**Assembly XP:** Tailoring
**Rare Material:** Void Spore (from Foraging)

| Quality Target | Tailoring Component | Timber Shaping Component | Rare Material |
|---------------|---------------------|--------------------------|---------------|
| Crude | Rough Leather Body | Pine Frame | None |
| Rough | Cured Leather Body | Hardwood Frame | Crude Void Spore |
| Refined | Fine Leather Body | Ashwood Frame | Rough Void Spore |
| Pristine | Wolf Leather Body | Ironbark Frame | Refined Void Spore |
| Masterwork | Masterwork Leather Body | Magicwood Frame | Pristine Void Spore |

> Higher tier Quivers increase fire rate and extend coating duration
> Crude: 1 coating slot | Refined: 2 slots | Masterwork: 3 slots, max fire rate cap raised

---

### 🔨 Smith's Hammer (Runesmithing tool)
**Assembler:** Timber Shaping
**Assembly XP:** Timber Shaping
**Rare Material:** Runic Cog (from Gleaning)

| Quality Target | Runesmithing Component | Timber Shaping Component | Rare Material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Hammer Head | Pine Handle | None |
| Rough | Iron Hammer Head | Hardwood Handle | Crude Runic Cog |
| Refined | Steel Hammer Head | Ashwood Handle | Rough Runic Cog |
| Pristine | Mithril Hammer Head | Ironbark Handle | Refined Runic Cog |
| Masterwork | Adamantine Hammer Head | Voidtimber Handle | Pristine Runic Cog |

---

### 🖼️ Tanning Frame (Tanning tool)
**Assembler:** Timber Shaping
**Assembly XP:** Timber Shaping
**Rare Material:** Runic Cog (from Gleaning)

| Quality Target | Timber Shaping Component | Artificing Component | Rare Material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Frame | Iron Brackets | None |
| Rough | Hardwood Frame | Steel Brackets | Crude Runic Cog |
| Refined | Ashwood Frame | Steel Clockwork Brackets | Rough Runic Cog |
| Pristine | Ironbark Frame | Mithril Brackets | Refined Runic Cog |
| Masterwork | Voidtimber Frame | Adamantine Brackets | Pristine Runic Cog |

---

### 🧵 Weaving Loom (Arcane Weaving / Tailoring tool)
**Assembler:** Timber Shaping
**Assembly XP:** Timber Shaping
**Rare Material:** Aetheric Filament (from Foraging + Dredging + Alchemy)

| Quality Target | Timber Shaping Component | Artificing Component | Rare Material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Beams | Iron Heddle | None |
| Rough | Hardwood Beams | Steel Heddle | Crude Aetheric Filament |
| Refined | Ashwood Beams | Steel Clockwork Heddle | Rough Aetheric Filament |
| Pristine | Ironbark Beams | Mithril Heddle | Refined Aetheric Filament |
| Masterwork | Voidtimber Beams | Adamantine Heddle | Pristine Aetheric Filament |

---

### 🧪 Alchemy Kit (Alchemy tool)
**Assembler:** Artificing
**Assembly XP:** Artificing
**Rare Material:** Aetheric Filament (from Foraging + Dredging + Alchemy)

| Quality Target | Artificing Component | Inscription Component | Rare Material |
|---------------|----------------------|-----------------------|---------------|
| Crude | Iron Apparatus | Basic Formulae Book | None |
| Rough | Steel Apparatus | Scroll-bound Formulae | Crude Aetheric Filament |
| Refined | Steel Clockwork Apparatus | Spellbook Formulae | Rough Aetheric Filament |
| Pristine | Mithril Apparatus | Ancient Text Formulae | Refined Aetheric Filament |
| Masterwork | Adamantine Apparatus | Living Grimoire Formulae | Pristine Aetheric Filament |

---

### 🍳 Cookery Set (Cookery tool)
**Assembler:** Artificing
**Assembly XP:** Artificing
**Rare Material:** Prismatic Seed (from Cultivation)

| Quality Target | Artificing Component | Tailoring Component | Rare Material |
|---------------|----------------------|---------------------|---------------|
| Crude | Iron Implements | Rough Cloth Carry Bag | None |
| Rough | Steel Implements | Linen Carry Bag | Crude Prismatic Seed |
| Refined | Steel Fine Implements | Fine Cloth Carry Bag | Rough Prismatic Seed |
| Pristine | Mithril Implements | Silk Carry Bag | Refined Prismatic Seed |
| Masterwork | Adamantine Implements | Arcane Carry Bag | Pristine Prismatic Seed |

---

### 🔧 Carpenter's Kit (Timber Shaping tool)
**Assembler:** Artificing
**Assembly XP:** Artificing
**Rare Material:** Runic Cog (from Gleaning)

| Quality Target | Artificing Component | Runesmithing Component | Rare Material |
|---------------|----------------------|------------------------|---------------|
| Crude | Iron Tool Set | Bronze Blades | None |
| Rough | Steel Tool Set | Iron Blades | Crude Runic Cog |
| Refined | Steel Fine Tool Set | Steel Blades | Rough Runic Cog |
| Pristine | Mithril Tool Set | Mithril Blades | Refined Runic Cog |
| Masterwork | Adamantine Tool Set | Void Blades | Pristine Runic Cog |

---

### 📜 Inscription Set (Inscription tool)
**Assembler:** Artificing
**Assembly XP:** Artificing
**Rare Material:** Ancient Sigil (from Tracking)

| Quality Target | Tailoring Component | Timber Shaping Component | Rare Material |
|---------------|---------------------|--------------------------|---------------|
| Crude | Rough Cloth Case | Pine Writing Desk | None |
| Rough | Linen Case | Hardwood Writing Desk | Crude Ancient Sigil |
| Refined | Fine Cloth Case | Ashwood Writing Desk | Rough Ancient Sigil |
| Pristine | Silk Case | Ironbark Writing Desk | Refined Ancient Sigil |
| Masterwork | Arcane Case | Magicwood Writing Desk | Pristine Ancient Sigil |

---

## 🛡️ ARMOR ASSEMBLY TABLES

### ⚔️ Plate/Metal Armor (Vanguard — per piece)
**Assembler:** Runesmithing
**Assembly XP:** Runesmithing
**Components:** 3 + rare material
**Rare Material:** Gemstone (from Delving)

| Quality Target | Runesmithing Component | Tailoring Component | Artificing Component | Rare Material |
|---------------|------------------------|---------------------|----------------------|---------------|
| Crude | Bronze Plate Body | Cloth Padding | Iron Fastenings | None |
| Rough | Iron Plate Body | Leather Padding | Steel Fastenings | Crude Gemstone |
| Refined | Steel Plate Body | Fine Leather Padding | Mithril Fastenings | Rough Gemstone |
| Pristine | Mithril Plate Body | Wolf Leather Padding | Adamantine Fastenings | Refined Gemstone |
| Masterwork | Adamantine Plate Body | Masterwork Padding | Starstone Fastenings | Pristine Gemstone |

> Pieces: Helm, Chest, Legs, Boots, Gauntlets — each assembled separately
> Full Masterwork Plate set requires 5 separate Masterwork Assembly attempts

---

### 🏹 Leather Armor (Warden — per piece)
**Assembler:** Tailoring
**Assembly XP:** Tailoring
**Components:** 3 + rare material
**Rare Material:** Amber (from Felling)

| Quality Target | Tanning Component | Tailoring Component | Runesmithing Component | Rare Material |
|---------------|-------------------|---------------------|------------------------|---------------|
| Crude | Rough Leather Body | Cloth Lining | Bronze Reinforcement | None |
| Rough | Cured Leather Body | Linen Lining | Iron Reinforcement | Crude Amber |
| Refined | Fine Leather Body | Fine Cloth Lining | Steel Reinforcement | Rough Amber |
| Pristine | Wolf Leather Body | Silk Lining | Mithril Reinforcement | Refined Amber |
| Masterwork | Masterwork Leather Body | Arcane Lining | Starstone Reinforcement | Pristine Amber |

---

### 🔮 Magical Vestments (Arcanist — per piece)
**Assembler:** Tailoring
**Assembly XP:** Tailoring
**Components:** 3 + rare material
**Rare Material:** Aetheric Filament (Foraging + Dredging + Alchemy)

| Quality Target | Arcane Weaving Component | Tailoring Component | Inscription Component | Rare Material |
|---------------|--------------------------|---------------------|-----------------------|---------------|
| Crude | Basic Woven Body | Rough Cloth Lining | Paper Binding | None |
| Rough | Arcane Thread Body | Linen Lining | Scroll Binding | Crude Aetheric Filament |
| Refined | Emberpetal Weave Body | Fine Cloth Lining | Spellbook Binding | Rough Aetheric Filament |
| Pristine | Drake Scale Weave Body | Silk Lining | Ancient Text Binding | Refined Aetheric Filament |
| Masterwork | Celestine Weave Body | Arcane Lining | Grimoire Page Binding | Pristine Aetheric Filament |

> Pieces: Cowl, Robe, Leggings, Boots, Gloves — each assembled separately

---

## 📊 Assembly Ownership Summary

| Assembler Talent | Items Assembled | Primary Rare Material Needed |
|-----------------|----------------|------------------------------|
| **Timber Shaping** | Bow, Felling Axe, Fishing Rod, Tanning Frame, Weaving Loom, Smith's Hammer | Gemstone, Void Spore, Runic Cog, Aetheric Filament |
| **Runesmithing** | Sword, Battle Axe, Dagger, Spear, Plate Armor, Pickaxe | Gemstone, Phantom Pelt, Amber |
| **Tailoring** | Quiver, Leather Armor, Magical Vestments | Void Spore, Amber, Aetheric Filament |
| **Arcane Weaving** | Wand, Staff | Void Spore, Abyssal Pearl |
| **Artificing** | Trapper's Kit, Alchemy Kit, Cookery Set, Carpenter's Kit, Inscription Set | Ancient Sigil, Aetheric Filament, Prismatic Seed, Runic Cog |

---

## 🔍 Gleaning — Universal Rare Material Drop Bonus

Gleaning level adds a bonus rare material drop chance across ALL sources:

| Gleaning Level | Rare Material Bonus |
|---------------|-------------------|
| 1–20 | No bonus |
| 21–40 | +0.5% to all rare material drop sources |
| 41–60 | +1.5% |
| 61–80 | +3% |
| 81–99 | +5% |
| 100 | +7% + guaranteed 1 rare material per dungeon/raid boss |

---

## 🏰 Dungeon & Raid Drop Tables

### Dungeon Drops
| Drop Type | Quality Range | Notes |
|-----------|-------------|-------|
| Components | Crude – Refined | Common drops; feeds crafting economy |
| Rare Materials | T1 – T3 | Based on dungeon tier |
| Assembled Weapons | Refined – Pristine | Pre-assembled; ready to equip |
| Assembled Armor pieces | Refined – Pristine | Pre-assembled; ready to equip |
| Boss guaranteed drop | Rare Material T2–T4 | Always drops; tier scales with dungeon level |
| Summoner's Tome | Rare drop — Tier 3+ dungeons and raids only | Unlocks Summoner deep subclass tree |

### Raid Drops
| Drop Type | Quality Range | Notes |
|-----------|-------------|-------|
| Rare Materials | T3 – T5 (Masterwork) | Best source for Masterwork materials |
| Assembled Weapons | Pristine – Masterwork | Fully assembled endgame gear |
| Assembled Armor sets | Pristine – Masterwork | Full set drops extremely rare |
| Boss guaranteed drop | Rare Material T4–T5 | Always drops Pristine or Masterwork |
| Summoner's Tome | Rare drop from all raid bosses | |

---

*Document version 0.4 — Assembly Materials & Crafting System*
*Next: Slaying Talent full spec · Attunement data spec updates · Session 3 handoff*
