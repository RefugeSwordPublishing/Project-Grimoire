---
type: content-spec
version: 1.0
updated: 2026-08-21
path: docs/grimoire-onboarding-lore.md
purpose: Card flavor lines and lore paragraphs for the "Choose your path"
         onboarding screen. Seven starting Grimoires.
consumes: GrimoireData ScriptableObject fields cardFlavor and loreText
note: Taglines, passives, and idle behaviors are unchanged from the existing
      spec and are reproduced here for context only. Do not treat them as new.
---

# Grimoire Onboarding Lore and Card Flavor

## Field Mapping

Add or populate these fields on the `GrimoireData` ScriptableObject:

```csharp
[TextArea(1, 2)]
public string cardFlavor;   // one line, max ~12 words, shown on the picker tile

[TextArea(4, 10)]
public string loreText;     // full paragraph, shown on the expanded detail view
```

`tagline`, `passiveName`, `passiveDescription`, and `idleDescription` already
exist. This doc does not change them.

---

## 1. Sharpshot

| Field | Value |
|-------|-------|
| grimoireId | `sharpshot` |
| path | Warden |
| talent | Marksmanship |
| tagline | Precision at range. |
| passive | Keen Eye: longer draw, harder full-draw shots |
| idle | Auto-looses arrows at zone enemies |

**cardFlavor:**
```
One arrow, correctly placed, ends the argument.
```

**loreText:**
```
A Sharpshot learns the wind before the wound. Where a frightened hand empties a whole quiver, you wait for the one shot that ends the argument, and you accept every second of stillness that waiting costs. The old rangers of the Grimwood carried this Grimoire into the deep pines, where a missed shot meant a long walk back through what you had just angered. It still remembers every arrow they made count, and it has no patience for the ones they wasted.
```

---

## 2. Lone Wanderer

| Field | Value |
|-------|-------|
| grimoireId | `lone_wanderer` |
| path | Warden |
| talent | Marksmanship |
| tagline | Fast, frequent crits. |
| passive | Quick Nock: snappier draw, tighter but more frequent crit window |
| idle | Rapid auto-fire favouring crits |

**cardFlavor:**
```
Loose often, move first, be somewhere else entirely.
```

**loreText:**
```
The Lone Wanderer answers to no camp and no captain. You travel light, loose often, and slip away before the return volley finds the place you were standing. Scouts who trusted a treeline over any wall bound this Grimoire, passing it between them without ceremony or record. It favors those who would rather run the ridge than hold it, and it has outlived every wielder who forgot the difference.
```

---

## 3. Runeweaver

| Field | Value |
|-------|-------|
| grimoireId | `runeweaver` |
| path | Arcanist |
| talent | Spellcasting |
| tagline | Weave runes into spells. |
| passive | Arcane Flow: constellation spell shaping |
| idle | Auto-casts basic runic bolts |

**cardFlavor:**
```
Speak the older language. Let fire answer in turn.
```

**loreText:**
```
Every rune is a word in a language older than the kingdoms, and the Runeweaver speaks it without stammering. You trace the constellation across the dark and let fire, frost, and storm answer in their turn, each one arriving in the shape you drew for it. Scholars once burned libraries to keep this Grimoire hidden, arguing it was too complete a grammar for any single hand. Then the fire reached their own door, and they bound it themselves.
```

---

## 4. Summoner

| Field | Value |
|-------|-------|
| grimoireId | `summoner` |
| path | Arcanist |
| talent | Spellcasting |
| tagline | Constructs fight for you. |
| passive | Bound Servitors: constructs form the HP pool |
| idle | Constructs auto-engage |

**cardFlavor:**
```
Point. Something made of stone goes instead.
```

**loreText:**
```
A Summoner never stands where the blows land. You raise servants of stone and ember and send them into the wound meant for you, and you learn to feel each one break without flinching. This Grimoire belonged to a general who never drew a blade, only pointed. The constructs that answered his hand outlived every soldier who marched beside him, and some of them are still standing where he left them.
```

---

## 5. Lifebinder

| Field | Value |
|-------|-------|
| grimoireId | `lifebinder` |
| path | Arcanist |
| talent | Spellcasting |
| tagline | HP is your resource. |
| passive | Vital Channel: HP fuels spells, passive regen |
| idle | Sustains through regen while striking |

**cardFlavor:**
```
Your magic costs blood. Learn the exact rate.
```

**loreText:**
```
The Lifebinder spends their own blood to keep the line breathing. Your magic costs you directly, so you learn to bleed at exactly the rate the fight allows, and you learn it quickly or not at all. Healers of the old orders carried this Grimoire into plague wards and siege camps alike, where the arithmetic was the same in both places. It still weighs a wielder by who they managed to bring home.
```

---

## 6. Warlord

| Field | Value |
|-------|-------|
| grimoireId | `warlord` |
| path | Vanguard |
| talent | Warfare |
| tagline | Hold the line. |
| passive | Battle Fury: Strike/Guard/Surge combos, high aggro |
| idle | Auto-trades blows, holds aggro |

**cardFlavor:**
```
A hundred blows taken so none get past.
```

**loreText:**
```
The Warlord is the reason the gate still stands at dawn. You draw every eye and every edge onto yourself so the ones behind you can finish their work, and you hold that position long past the point where holding it makes sense. Forged for those who would sooner take a hundred blows than let one slip past, this Grimoire rewards the stubborn long before the clever. Most of its wielders were never remembered by name, only by the fact that the wall held.
```

---

## 7. Shadowblade

| Field | Value |
|-------|-------|
| grimoireId | `shadowblade` |
| path | Vanguard |
| talent | Warfare |
| tagline | Strike from the dark. |
| passive | Shadow's Edge: shroud plus big flat-multiplier hits (shown as Critical!) |
| idle | Auto-strikes, low aggro |

**cardFlavor:**
```
The fight was over before anyone called it started.
```

**loreText:**
```
The Shadowblade ends fights that never officially began. You wrap yourself in gloom, close a distance no one saw closing, and leave a single clean wound behind. This Grimoire changed hands in silence for a hundred years, each new owner discovered only by the bodies, never by any claim they made. It still prefers a wielder patient enough to disappear.
```

---

## Implementation Notes

Card flavor lines run 6 to 9 words and are written to sit on a single line at
picker-tile width. None of them restate the tagline, so the tile can show both
without repeating itself.

Sharpshot and Warlord each echo a phrase from their own lore paragraph. That is
intentional: tapping from tile to detail should feel like one continuous voice
rather than two separate pieces of copy.

Every lore paragraph gained one beat of consequence over the previous version.
No new mechanics are implied anywhere. Nothing in this copy promises a system
that does not exist in the build.

Display order on the picker screen should follow the numbering above, which
groups the two Warden paths, then the three Arcanist paths, then the two
Vanguard paths.

---

*Path: docs/grimoire-onboarding-lore.md*
*Seven starting Grimoires. Populates GrimoireData.cardFlavor and GrimoireData.loreText.*
