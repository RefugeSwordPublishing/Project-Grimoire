# Project Grimoire — Claude Code Briefing
### Last updated: 2026-07-11

---

## Repos

| Repo | Contents | Visibility |
|------|---------|-----------|
| **Project-Grimoire** | Design docs (`docs/`), Supabase SQL (`supabase/migrations/`), Unity as git submodule at `ProjectGrimoire/` | Public |
| **ProjectGrimoire** | Unity/C# game | Private (Chat cannot read) |

**Always read `docs/implementation-status.md` first.** It records what is actually built vs. design intent. When a spec and the code conflict, the code wins.

---

## Read order at session start

1. `docs/README.md` — index of every spec with raw URLs
2. `docs/implementation-status.md` — as-built source of truth
3. The specific spec(s) relevant to current work

Use raw URLs (`raw.githubusercontent.com/...`) — GitHub folder pages are JS-rendered and fail to fetch.

---

## Tech stack

| Tool | Purpose |
|------|---------|
| Unity 6 | Engine |
| C# | Language |
| Supabase | Database, Auth (JWT), Edge Functions, real-time |
| Firebase Cloud Messaging | Push notifications |
| Unity IAP + RevenueCat | Purchases — do NOT build custom receipt validation |
| GameAnalytics | Player behaviour tracking |
| Layer.ai (Sprite AI MCP) | Art asset generation |
| Suno | Music generation |

---

## Critical design decisions

### Grimoire Combat Progression (not shared Talents)
Combat Talents (Marksmanship, Spellcasting, Warfare) do not exist as shared Talents.
Each Grimoire has its own combat level (1–100) in `player_grimoire_levels`.

```
Total Combat Level = SUM of all owned Grimoire combat levels
→ gates zone access AND is a character prestige stat
```

Zone thresholds: 1–20 = Tier 1 · 21–50 = Tier 2 · 51–90 = Tier 3 · 91–140 = Tier 4 · 141+ = Tier 5

### No crit system for Arcanist or Vanguard
```csharp
if (path == Arcanist || path == Vanguard) { critChance = 0f; weakPointEnabled = false; }
```
Shadowblade's Shadow's Edge shows "Critical!" visually — backend is +150% damage multiplier.
Marksmanship weak point (Bowstring) is Warden only.

### Runic Constellation — 6 active nodes per subclass
8 runes exist; each subclass uses 6. Inactive nodes not rendered.
```
Runeweaver: Ignis, Glacius, Tempest, Ventus, Umbra, Lux
Summoner:   Ignis, Glacius, Tempest, Ventus, Terra, Umbra
Lifebinder: Ignis, Glacius, Tempest, Ventus, Vita, Lux
```

### Summoner HP pool
```csharp
effectiveHP = (baseHP * 0.25f) + activeConstructs.Sum(c => c.currentHP);
```
Constructs are the primary HP pool. Enemies target highest-aggro construct.

### Lifebinder — HP as casting resource
No mana. Spell cost = Base × PowerMultiplier × (1 − WIL×0.003, max 30% reduction).
Passive regen always active in combat. HOTs stack on top. Spell cannot reduce HP below 1.

### Exchange fees (as-built)
- Solo: 3% system tax on sales → economy sink
- Guild member: 0–3% guild tax replacing system tax → guild bank
- Guild Merchant internal: half guild tax rate
- Buy Orders: always 0%
- Dual-currency pricing on Guild Merchant listings (SM + GM, either may be 0)

### Guild voting (as-built)
- **2/3 of full roster** must approve (`ceil(2/3 × member_count)`)
- Passes and applies **immediately** on reaching threshold — no 48-hour delay
- Vote open until threshold / all voted / 7 days

### Permanent stat bonuses from Grimoire milestones
Bonuses persist regardless of equipped Grimoire, accumulate cross-path.

| Path | Lv 23 | Lv 38/47 | Lv 63 | Lv 81 |
|------|-------|----------|-------|-------|
| Warden | DEX +1 | LCK +1 (38) | DEX +2 | LCK +2 |
| Arcanist | INT +1 | WIL +1 (38) | INT +2 | WIL +2 |
| Vanguard | STR +1 | VIT +1 (47) | STR +2 | VIT +2 |

### Art direction — HD-2D Grimoire Variant
- **Characters:** Full-body realistic pixel art (not chibi) — Blasphemous/Dead Cells proportions
- **Camera:** Front-to-back — player moves into the screen
- **Backgrounds:** Painterly pre-rendered, 3–5 parallax layers, per-zone colour grading
- **Post-processing:** Heavy bloom, front-to-back depth of field, atmospheric particles, per-zone LUT
- Sprites: Point filter / PPU 100. Backgrounds: Bilinear filter.
- Full spec: `docs/art-asset-requirements.md`

### Item icons — sprite atlas sheets
All item icons are atlas sheets (4-wide grid, 64×64 cells, 256 px wide).
Unity: Sprite Mode → Multiple → Sprite Editor → Slice → Grid 64×64.
Full atlas list: `docs/art-asset-requirements.md` → Sprite Atlas Organization.

### Aggro — hybrid model
```
Total Aggro = PassiveRate/sec + (DamageDealt × ClassMultiplier) + TauntComboValue
```
Warlord 15/sec ×1.5 · Bulwark 20/sec ×1.2 · Shadowblade 0/sec ×0.3
Decays 5%/sec (2%/sec for tanks). Constructs generate independent aggro.

---

## Supabase — security rules

RLS must be enabled on **every** table, immediately on creation. Never leave a table exposed.

```sql
ALTER TABLE foo ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own rows" ON foo FOR ALL USING (auth.uid() = player_id);
```

- Client calls (BackendManager.cs) → **anon key**
- Edge Functions → **service role key** (bypasses RLS by design)
- Guild RLS: use `SECURITY DEFINER` helpers `auth_guild_ids()` / `auth_officer_guild_ids()` to avoid recursion (already implemented)

---

## New Supabase tables still needed (Phase 2)

```sql
player_grimoire_levels (player_id, grimoire_id, combat_level, combat_xp, owned_at)
player_stat_bonuses    (player_id, grimoire_id, stat_type, amount, granted_at)
-- Guild tables already built (migrations 002, 010–018)
-- Two Edge Functions pending: vote auto-close at 7 days, expired listing sweep
```

---

## Art generation workflow

Sprite AI connected via MCP — use it directly.
- Prompt library: `docs/phase1-sprite-prompts.md`
- Generate Warden base body first; use as style reference for all subsequent sprites
- Standard suffix: `"limited palette, dark pixel outline, HD-2D pixel art, full-body realistic proportions, Octopath Traveler-inspired, transparent background"`
- Animal enemies: add `"pixel art shading only — no realistic fur texture, no 3D rendering, same art style as [approved human sprite]"`
- Save to `Assets/Sprites/[Characters|Enemies|Items|Environments|UI]/`
- Item icons: generate as atlas sheets — see atlas format in art spec

---

## Do NOT implement

See `docs/deferred-systems-dlc-notes.md` for full list. Hard stops:
- Raids (Phase 4 — grid turn-based system not yet ready)
- Faction system, Guild Bounties (post-launch)
- Bloodweaver, Warlock, Kensei, Beastbond, Bard/Minstrel (DLC)
- Divination Talent (show "???" placeholder on Talents page)
- Black Ledger (removed from base game)
- Legendary quality tier

---

## TaskBoard

Read before starting. Update after each session.
- GET: `https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard?id=eq.1&select=data`
- PATCH: full `{ "data": <JSON> }` — always read before writing
- Headers: `apikey: <anon JWT>` + `Authorization: Bearer <anon JWT>`
- Vercel frontend: taskboard-sepia-beta.vercel.app (PIN 2853)

---

## Architecture guidelines

- Idle calculations server-side via Edge Functions — never trust client-reported time
- All Talent/Grimoire data: ScriptableObjects — never hardcode level unlocks
- Managers: GameManager, TalentManager, CombatManager, GrimoireManager, CombatXPManager, AggroManager, ConstructManager, AudioManager
- Mobile first: touch input, battery efficiency, background processing
- Unity C#: PascalCase classes, camelCase private fields, `_prefix` for serialized fields
- Faction enemy tags `[Outlaw][Beast][Undead][Arcane][Void][Nature]` on ALL enemies from day one
- DX12 fix: use RectMask2D, never Mask component

*Path: `CLAUDE.md` (repo root)*
