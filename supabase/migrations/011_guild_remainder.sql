-- Project Grimoire — Guild remainder tables (Migration 011)
-- Adds the three tables the guild-hall spec still needs: merchant listings,
-- tax votes, and announcements. Run AFTER 003/007/010.
-- Membership checks use SECURITY DEFINER helpers to avoid RLS recursion.

-- ── Officer/GM guild-ids helper (mirrors auth_guild_ids from 010) ────────────
create or replace function auth_officer_guild_ids()
returns setof uuid
language sql security definer stable
set search_path = public
as $$
    select guild_id from guild_members
    where player_id = auth.uid() and role in ('officer','guild_master');
$$;

-- ── Guild Merchant listings ─────────────────────────────────────────────────
create table if not exists guild_merchant_listings (
    id         uuid primary key default gen_random_uuid(),
    guild_id   uuid   not null references guilds(id) on delete cascade,
    item_id    text   not null,
    quantity   bigint not null,
    price_sm   bigint not null,
    listed_by  uuid   not null references players(id),
    listed_at  timestamptz not null default now(),
    expires_at timestamptz not null default now() + interval '7 days'
);

alter table guild_merchant_listings enable row level security;
-- Guild-members-only visibility (keeps it from replacing the public Exchange)
drop policy if exists "merchant: members read" on guild_merchant_listings;
create policy "merchant: members read"
    on guild_merchant_listings for select
    using (guild_id in (select auth_guild_ids()));
drop policy if exists "merchant: insert own" on guild_merchant_listings;
create policy "merchant: insert own"
    on guild_merchant_listings for insert
    with check (listed_by = auth.uid() and guild_id in (select auth_guild_ids()));
drop policy if exists "merchant: seller update" on guild_merchant_listings;
create policy "merchant: seller update"
    on guild_merchant_listings for update using (listed_by = auth.uid());
drop policy if exists "merchant: seller delete" on guild_merchant_listings;
create policy "merchant: seller delete"
    on guild_merchant_listings for delete using (listed_by = auth.uid());

-- ── Guild tax votes ─────────────────────────────────────────────────────────
create table if not exists guild_tax_votes (
    id            uuid primary key default gen_random_uuid(),
    guild_id      uuid  not null references guilds(id) on delete cascade,
    proposed_rate float not null,                       -- 0.0–3.0 (%)
    initiated_by  uuid  not null references players(id),
    initiated_at  timestamptz not null default now(),
    votes_for     integer not null default 0,
    votes_against integer not null default 0,
    status        text not null default 'open',         -- open/passed/failed
    closes_at     timestamptz not null default now() + interval '48 hours'
);

alter table guild_tax_votes enable row level security;
drop policy if exists "tax_votes: members read" on guild_tax_votes;
create policy "tax_votes: members read"
    on guild_tax_votes for select
    using (guild_id in (select auth_guild_ids()));
drop policy if exists "tax_votes: officers write" on guild_tax_votes;
create policy "tax_votes: officers write"
    on guild_tax_votes for all
    using (guild_id in (select auth_officer_guild_ids()))
    with check (guild_id in (select auth_officer_guild_ids()));

-- ── Guild announcement (one per guild — latest replaces) ────────────────────
create table if not exists guild_announcements (
    guild_id  uuid primary key references guilds(id) on delete cascade,
    content   text not null,
    posted_by uuid not null references players(id),
    posted_at timestamptz not null default now()
);

alter table guild_announcements enable row level security;
drop policy if exists "announcements: members read" on guild_announcements;
create policy "announcements: members read"
    on guild_announcements for select
    using (guild_id in (select auth_guild_ids()));
drop policy if exists "announcements: officers write" on guild_announcements;
create policy "announcements: officers write"
    on guild_announcements for all
    using (guild_id in (select auth_officer_guild_ids()))
    with check (guild_id in (select auth_officer_guild_ids()));
