# Project Grimoire, Claude Code Briefing
### Last updated: 2026-07-25

---

## Repos

| Repo | Contents | Visibility |
|------|---------|-----------|
| **Project-Grimoire** | Design docs (`docs/`), Supabase SQL (`supabase/migrations/`), Unity as git submodule at `ProjectGrimoire/` | Public |
| **ProjectGrimoire** | Unity/C# game | Private (Chat cannot read) |

**Always read `docs/implementation-status.md` first.** It records what is actually built vs. design intent. When a spec and the code conflict, the code wins.

---

## Read order at session start

1. `docs/README.md`, index of every spec with raw URLs
2. `docs/implementation-status.md`, as-built source of truth
3. The specific spec(s) relevant to current work

Use raw URLs (`raw.githubusercontent.com/...`), GitHub folder pages are JS-rendered and fail to fetch.

---

## Handing off to Chat (design collaborator)

Chat (claude.ai) designs the specs but cannot read the private Unity code and has no repo index. It
CAN cold-fetch public `raw.githubusercontent.com` URLs, but only for files already PUSHED (an unpushed
doc 404s). So every handoff to Chat follows this flow:

1. Update `docs/implementation-status.md` (as-built truth) and any spec the work touched.
2. Commit + push the parent repo (bump the submodule too if code changed).
3. Paste Chat the raw links for every doc **added or changed that session**, pointing it at
   `implementation-status.md` first.

Base URL: `https://raw.githubusercontent.com/RefugeSwordPublishing/Project-Grimoire/main/docs/<file>.md`
Keep new docs listed in `docs/README.md` (the index). Never hand Chat a link to an unpushed file.

---

## Tech stack

| Tool | Purpose |
|------|---------|
| Unity 6 | Engine |
| C# | Language |
| Supabase | Database, Auth (JWT), Edge Functions, real-time |
| Firebase Cloud Messaging | Push notifications |
| Unity IAP + RevenueCat | Purchases, do NOT build custom receipt validation |
| GameAnalytics | Player behaviour tracking |
| Layer.ai | Art asset generation (web UI; NO MCP connection, generate manually) |
| Suno | Music generation |

---

## Critical design decisions

### Grimoire Combat Progression (not shared Talents)
Combat Talents (Marksmanship, Spellcasting, Warfare) do not exist as shared Talents.
Each Grimoire has its own combat level (1-100) in `player_grimoire_levels`.

```
Total Combat Level = SUM of all owned Grimoire combat levels
→ gates zone access AND is a character prestige stat
```

Zone thresholds: 1-20 = Tier 1 · 21-50 = Tier 2 · 51-90 = Tier 3 · 91-140 = Tier 4 · 141+ = Tier 5

### No crit system for Arcanist or Vanguard
```csharp
if (path == Arcanist || path == Vanguard) { critChance = 0f; weakPointEnabled = false; }
```
Shadowblade's Shadow's Edge shows "Critical!" visually, backend is +150% damage multiplier.
Marksmanship weak point (Bowstring) is Warden only.

### Runic Constellation, 6 active nodes per subclass
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

### Lifebinder, HP as casting resource
No mana. Spell cost = Base × PowerMultiplier × (1 − WIL×0.003, max 30% reduction).
Passive regen always active in combat. HOTs stack on top. Spell cannot reduce HP below 1.

### Exchange fees (as-built)
- Solo: 3% system tax on sales → economy sink
- Guild member: 0-3% guild tax replacing system tax → guild bank
- Guild Merchant internal: half guild tax rate
- Buy Orders: always 0%
- Dual-currency pricing on Guild Merchant listings (SM + GM, either may be 0)

### Guild voting (as-built)
- **2/3 of full roster** must approve (`ceil(2/3 × member_count)`)
- Passes and applies **immediately** on reaching threshold, no 48-hour delay
- Vote open until threshold / all voted / 7 days

### Permanent stat bonuses from Grimoire milestones
Bonuses persist regardless of equipped Grimoire, accumulate cross-path.

| Path | Lv 23 | Lv 38/47 | Lv 63 | Lv 81 |
|------|-------|----------|-------|-------|
| Warden | DEX +1 | LCK +1 (38) | DEX +2 | LCK +2 |
| Arcanist | INT +1 | WIL +1 (38) | INT +2 | WIL +2 |
| Vanguard | STR +1 | VIT +1 (47) | STR +2 | VIT +2 |

### Art direction, HD-2D Grimoire Variant
- **Characters:** Full-body realistic pixel art (not chibi), Blasphemous/Dead Cells proportions
- **Camera:** Front-to-back, player moves into the screen
- **Backgrounds:** Painterly pre-rendered, 3-5 parallax layers, per-zone colour grading
- **Post-processing:** Heavy bloom, front-to-back depth of field, atmospheric particles, per-zone LUT
- Sprites: Point filter / PPU 100. Backgrounds: Bilinear filter.
- Full spec: `docs/art-asset-requirements.md`

### Quality vs Tier, do not confuse these

They are different axes. Getting this wrong has already caused two parallel enums in code.

**Quality** is the rarity of an individual item. It drives idle-action times, damage and HP
bonuses, and the quality badge overlaid on item icons. One ladder, one enum:

```csharp
ItemQuality { Crude, Rough, Refined, Pristine, Masterwork, Legendary }
// ItemData.quality  (Legendary is authored for future content; no base-game item uses it yet)
```

**Tier** is level-gated progression: iron armour to steel armour, Tier 1 to Tier 6 materials,
zone tier bands. Tier is expressed by unlock levels, recipes, and zone gates. It is never a
rarity enum, and quality fields must never be named "tier".

Correct existing usages of "tier" that DO mean level gating: `ZoneData.tier`, zone tier bands
in `ZoneAccess`, material tiers in the processing ratio tables, and Royal Merchant
subscription tiers. Leave those alone.

### Item icons, sprite atlas sheets
All item icons are atlas sheets (4-wide grid, 64×64 cells, 256 px wide).
Unity: Sprite Mode → Multiple → Sprite Editor → Slice → Grid 64×64.
Full atlas list: `docs/art-asset-requirements.md` → Sprite Atlas Organization.

### Aggro, hybrid model
```
Total Aggro = PassiveRate/sec + (DamageDealt × ClassMultiplier) + TauntComboValue
```
Warlord 15/sec ×1.5 · Bulwark 20/sec ×1.2 · Shadowblade 0/sec ×0.3
Decays 5%/sec (2%/sec for tanks). Constructs generate independent aggro.

---

## Supabase, security rules

RLS must be enabled on **every** table, immediately on creation. Never leave a table exposed.

```sql
ALTER TABLE foo ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own rows" ON foo FOR ALL USING (auth.uid() = player_id);
```

- Client calls (BackendManager.cs) → **anon key**
- Edge Functions → **service role key** (bypasses RLS by design)
- Guild RLS: use `SECURITY DEFINER` helpers `auth_guild_ids()` / `auth_officer_guild_ids()` to avoid recursion (already implemented)

---

## Supabase backend status (Phase 2, all built as of 2026-08-21)

The Phase 2 tables and scheduled jobs that were once listed as "still needed" are all live:

```sql
player_grimoire_levels  -- built (migrations 009 / 013); ownership + per-Grimoire combat level
player_stat_bonuses     -- built; milestone stat grants (written by CombatXPManager)
-- Guild tables built (migrations 002, 010-018)
```

Scheduled jobs are pg_cron SQL functions (not Deno Edge Functions), all scheduled + active + running
clean (verified 2026-08-21 via cron.job / cron.job_run_details):
`close-expired-guild-votes` (7-day vote close, migration 019), `sweep-expired-merchant-listings` (019),
`sweep-expired-exchange-listings` + `close-ended-auctions` + `sweep-expired-buy-orders` (035).

---

## Art generation workflow

Art is generated in **Layer.ai's web UI**. There is **no Layer.ai MCP** in the build environment, so
Claude Code cannot drive it; Dustin runs the generations from the prompt library and Claude handles
Unity import + assembly. (The separately connected `sprite-ai` MCP is a **different service**, not
Layer.ai; do not treat it as the project's art tool.)
- Prompt library: `docs/phase1-sprite-prompts.md`
- Generate Warden base body first; use as style reference for all subsequent sprites
- Standard suffix: `"limited palette, dark pixel outline, HD-2D pixel art, full-body realistic proportions, Octopath Traveler-inspired, transparent background"`
- Animal enemies: add `"pixel art shading only, no realistic fur texture, no 3D rendering, same art style as [approved human sprite]"`
- Save to `Assets/Sprites/[Characters|Enemies|Items|Environments|UI]/`
- Item icons: generate as atlas sheets, see atlas format in art spec

---

## Do NOT implement

See `docs/deferred-systems-dlc-notes.md` for full list. Hard stops:
- Raids (Phase 4, grid turn-based system not yet ready)
- Faction system, Guild Bounties (post-launch)
- Bloodweaver, Warlock, Kensei, Beastbond, Bard/Minstrel (DLC)
- Divination Talent (show "???" placeholder on Talents page)
- Black Ledger (removed from base game)
- Enchanting (removed from base game; Inscription remains a scroll/codex crafting talent only. The
  former enchant gates + `enchantBonus` stat channel were deleted 2026-07-25)
- Legendary quality items (the `ItemQuality.Legendary` value exists for future content, but do
  not author any base-game item at that quality)

---

## TaskBoard

Read before starting. Update after each session.
- GET: `https://lyychkqimdulfwdtcdly.supabase.co/rest/v1/taskboard?id=eq.1&select=data`
- PATCH: full `{ "data": <JSON> }`, always read before writing
- Headers: `apikey: <anon JWT>` + `Authorization: Bearer <anon JWT>`
- Vercel frontend: taskboard-sepia-beta.vercel.app (PIN 2853)

---

## Architecture guidelines

- Idle calculations server-side via Edge Functions, never trust client-reported time
- All Talent/Grimoire data: ScriptableObjects, never hardcode level unlocks
- Managers: GameManager, TalentManager, CombatManager, GrimoireManager, CombatXPManager, AggroManager, ConstructManager, AudioManager
- Mobile first: touch input, battery efficiency, background processing
- Unity C#: PascalCase classes, camelCase private fields, `_prefix` for serialized fields
- Faction enemy tags `[Outlaw][Beast][Undead][Arcane][Void][Nature]` on ALL enemies from day one
- DX12 fix: use RectMask2D, never Mask component

*Path: `CLAUDE.md` (repo root)*
