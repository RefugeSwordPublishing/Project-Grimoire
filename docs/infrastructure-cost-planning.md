# ⚔️ Project Grimoire — Infrastructure & Cost Planning
### Version 0.1 — July 2026

---

## 📐 Key Terms

**SaaS (Software as a Service)**
Software delivered over the internet rather than installed locally. Project Grimoire fits this model — players access the game through apps, progress lives on servers, and backend infrastructure is rented rather than owned. Pricing guides use this term to mean "any app with a backend and user accounts."

**MAU (Monthly Active Users)**
A user counts as "active" if they open the app at least once in a 30-day window. The standard metric cloud services use for billing auth and database tiers — more meaningful than total registered accounts since many accounts go dormant.

**Concurrent users vs MAU**
These are very different numbers:
- **Concurrent** = players online at the exact same moment (peak simultaneous)
- **MAU** = unique players who logged in at least once that month

If 1,500 players are online at peak but the game runs 24 hours a day, MAU could easily be 15,000–50,000 depending on session length and play patterns. An idle game specifically tends to have high MAU relative to concurrent since players check in briefly multiple times per day rather than sitting in long sessions.

---

## 💰 Cost Estimates at 1,500 Concurrent Players

> Estimated July 2026 pricing. Verify current rates before budget planning.
> 1,500 concurrent at peak likely represents 15,000–30,000 MAU.

| Service | Purpose | Monthly Cost | Notes |
|---------|---------|-------------|-------|
| **Supabase Pro** | Database, auth, Edge Functions, idle calculations | $25 base | Includes 100K MAU, 8GB DB |
| **Supabase Small Compute** | Handles 1,500 concurrent DB connections safely | +$15 | Upgrade from default Micro instance |
| **Supabase Egress** | Player sync data, idle calc returns | +$10–20 | Idle game is low egress vs real-time games |
| **Firebase FCM** | Push notifications (level ups, boss spawns, quest complete, Exchange sales) | $0 | Free unlimited push messages on iOS/Android |
| **GameAnalytics** | Player behavior, retention, economy balance tracking | $0 | Free up to 5,000 DAU — well above 1,500 concurrent |
| **Unity IAP** | In-app purchases (Royal Merchant) | $0 | Revenue share only — Apple/Google take 30% (15% for small devs under $1M/yr revenue) |
| **Retool** | Admin/moderation dashboard at admin.refugeswordpublishing.com | $0 | Free under 5 moderator accounts |
| **Suno** | Music generation (Moonlit Caravan, Battle, Silent Save Point) | ~$8 | Annual Pro subscription |
| **Sprite AI** | Art asset generation via MCP connector | ~$20 | Estimated based on generation volume |
| **GitHub** | Version control, design docs repository | $0 | Free for public repos |
| **Total** | | **~$78–88/mo** | At 1,500 concurrent / ~20K MAU |

---

## 📈 Cost Scaling Projections

| Player Scale | Estimated Concurrent | Estimated MAU | Supabase Est. | Total Est. |
|-------------|---------------------|---------------|--------------|------------|
| Early access / soft launch | 200–500 | 2,000–5,000 | $25 (Micro) | ~$53/mo |
| Phase 1 launch | 1,500 | 15,000–30,000 | $40–60 (Small) | ~$78–88/mo |
| Growing — post Phase 2 | 5,000 | 50,000–75,000 | $75–150 (Small–Medium) | ~$110–180/mo |
| Established — 100K MAU | 10,000+ | 100,000+ | $150–300 (Medium) | ~$185–340/mo |
| Large — 500K MAU | 50,000+ | 500,000+ | $300–500+ | Re-evaluate architecture |

> At 500K+ MAU, self-hosting Supabase on a VPS (e.g. Hetzner via Coolify) becomes worth evaluating. Infrastructure savings are significant at that scale — a Hetzner CX31 (4 vCPU, 8 GB RAM) costs ~$10/month and handles more traffic than a Supabase Micro instance.

---

## 📊 Revenue Projections at 20,000 MAU (1,500 Concurrent)

### Key Assumptions
- 20,000 MAU is the estimated monthly player base behind 1,500 concurrent peak
- Industry conversion rate for mid-priced mobile idle/RPG games: 2–5% of MAU ever make a purchase
- Paying players at 20K MAU: 400–1,000 people
- RevenueCat 2026 benchmark: median high-priced apps convert at 2.8%, top quartile at 6.1%

### Revenue by Item
| Item | Price | Est. % of paying players | Est. monthly purchases |
|------|-------|------------------------|----------------------|
| Additional Grimoire | $2.99 | 60% | 240–600 |
| Inventory Slot Ticket | $1.99 | 40% | 160–400 |
| Daily Quest Slot Ticket | $2.99 | 25% | 100–250 |
| Weekly Quest Slot Ticket | $2.99 | 20% | 80–200 |
| Exchange Listing Slots | $1.99 | 15% | 60–150 |
| Slaying Task Slot (6th) | $0.99 | 20% | 80–200 |
| Cosmetic Grimoire Skin | $0.99 | 25% | 100–250 |
| DLC Grimoires (when released) | $4.99 | 15% | 60–150 |
| DLC Content Pack (when released) | $9.99 | 10% | 40–100 |

> Note: Grimoire purchases are one-time per account — high volume in early months, then drops to new player rate only

### Monthly Revenue Scenarios
| Scenario | Conversion Rate | Monthly Revenue | Annual Revenue |
|----------|----------------|----------------|----------------|
| Conservative | 2% | $3,200–$5,500 | $38K–$66K |
| Mid | 3.5% | $6,000–$10,000 | $72K–$120K |
| Optimistic | 5% | $10,000–$16,000 | $120K–$192K |

### Net Revenue After Platform Fees (15% Small Business Program)
| Scenario | Net Monthly | Net Annual |
|----------|------------|------------|
| Conservative | $2,720–$4,675 | $32K–$56K |
| Mid | $5,100–$8,500 | $61K–$102K |
| Optimistic | $8,500–$13,600 | $102K–$163K |

### Infrastructure Cost vs Revenue
| | Monthly |
|--|---------|
| Total infrastructure | ~$88–110 (with RevenueCat) |
| Conservative net revenue | $2,720–$4,675 |
| **Net margin (conservative)** | **~$2,630–$4,587** |
| Mid net revenue | $5,100–$8,500 |
| **Net margin (mid)** | **~$5,010–$8,410** |

Infrastructure is less than 2% of conservative revenue at this scale. Real costs are development time and marketing, not server bills.

### Tradeable Ticket Additional Revenue
Players buying tickets purely to convert to Gold Marks via the Exchange adds an unmeasured second revenue layer. Estimated contribution: $500–$2,000/month at 20K MAU on top of the above.

### What Moves the Needle
1. **Conversion rate** — 2% → 4% doubles revenue entirely
2. **Grimoire variety** — each new DLC Grimoire is a fresh purchase event for existing players
3. **Retention** — idle games keep players for months; recurring cosmetic purchases add up
4. **Guild membership** — players in active guilds typically spend 3–5x more than solo players

---

## 📈 RevenueCat — Conversion Reporting & IAP Management

**RevenueCat is the recommended tool for all in-app purchase management and conversion reporting.** It replaces the need to build custom cross-platform receipt validation for iOS, Android, and Steam separately.

### What RevenueCat Provides
- **Conversion reports** — who saw the Royal Merchant, who purchased, what they bought
- **Cohort analysis** — spending patterns by player segment (Grimoire choice, Slaying level etc.)
- **Revenue waterfall charts** — where revenue comes from across all purchase types
- **LTV projections** — lifetime value per player cohort
- **Real-time dashboard** — live purchase data as it happens
- **A/B testing** — test Royal Merchant layouts and pricing without app updates
- **Cross-platform validation** — iOS, Android, and Steam receipt validation in one SDK
- **Webhook integrations** — push purchase events to Supabase, GameAnalytics, or any other service

### RevenueCat Pricing
| Tier | Monthly Cost | When to use |
|------|-------------|------------|
| Free | $0 | Up to $2,500 monthly tracked revenue — covers early launch |
| Starter | 0.99% of revenue above $2,500 | Growing phase — ~$25/mo at $5K revenue |
| Pro | 1.2% of revenue | Advanced analytics, experiments, targeting |
| Grow | $499/mo | Attribution partner integrations (AppsFlyer etc.) — not needed at launch |

**At 20K MAU projected revenue of $5,000–$10,000/mo:**
- RevenueCat cost: $25–$74/mo — negligible relative to revenue

### Adding RevenueCat to Infrastructure Table
| Service | Monthly Cost |
|---------|-------------|
| Supabase Pro + Small compute | ~$50–60 |
| Firebase FCM | $0 |
| GameAnalytics | $0 |
| Unity IAP | $0 (revenue share only) |
| **RevenueCat** | **$0–$74** (scales with revenue) |
| Retool (admin dashboard) | $0 |
| Suno | ~$8 |
| Sprite AI | ~$20 |
| **Total infrastructure** | **~$78–162/mo** |

### Implementation Note
RevenueCat sits between Unity IAP and Supabase — it validates purchases from the App Store/Google Play/Steam, grants entitlements (Grimoire unlocks, ticket grants), and sends webhook events to Supabase to update the player's account. This means Claude Code does not need to build custom receipt validation — just integrate the RevenueCat Unity SDK.

---

**Supabase egress** — $0.09/GB after included amount. An idle game syncs relatively small payloads (inventory state, XP values, currency) so this stays low. Would spike if large asset files were served through Supabase — keep all art assets in Unity bundles or CDN, not Supabase Storage.

**Supabase compute saturation** — the Micro instance can saturate at ~40–50 concurrent DB connections during traffic spikes. Move to Small before launch. The $15/mo upgrade is worth it to avoid performance issues.

**Firebase gotcha** — FCM push notifications are free, but if you ever use Firebase Firestore, Cloud Functions, or other Firebase services beyond FCM, costs can spike unexpectedly. Since Project Grimoire uses Supabase for database and logic, keep Firebase usage strictly to push notifications only.

**Unity IAP revenue share** — Apple and Google take 30% of all in-app purchases by default. Developers under $1M/year revenue qualify for Apple's Small Business Program (15% rate) and Google's equivalent. Apply for both at launch.

---

## 🏗️ Admin & Moderation Backend

**Recommended setup:** Retool hosted at `admin.refugeswordpublishing.com`

| Role | Access | Retool seat |
|------|--------|------------|
| Admin | Full — player data, bans, all reports, account management | Yes |
| Moderator | Limited — username/chat reports, forced rename, mute | Yes |

Retool connects directly to Supabase with role-based credentials. Free under 5 users — sufficient for a small moderation team at launch. Upgrade to Retool paid ($10/user/mo) when team grows beyond 5 moderators.

**Moderation queue covers:**
- Flagged usernames (automated filter misses + player reports at Phase 4)
- Chat reports (Phase 4 multiplayer)
- Player lookup by username or email
- Account actions (warn, temp ban, permanent ban, forced rename)
- Audit log of all moderator actions

---

## 🗓️ Cost Review Schedule

| Milestone | Action |
|-----------|--------|
| Pre-launch | Confirm current Supabase pricing, upgrade to Pro + Small compute |
| 1,000 MAU | Verify egress costs, check Edge Function invocation count |
| 10,000 MAU | Review compute tier, consider Medium if query times increasing |
| 50,000 MAU | Full infrastructure review — evaluate self-hosting vs managed |
| 100,000 MAU | Consider Supabase Enterprise or self-hosted for cost efficiency |

---

*Document version 0.1 — Infrastructure & Cost Planning*
*Pricing verified July 2026 — re-verify before each major milestone*
