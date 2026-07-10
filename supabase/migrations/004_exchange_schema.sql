-- Project Grimoire — Wayfarer's Exchange Schema (Migration 004)
-- Run AFTER 003_guild_schema.sql.

-- ── Store listings (fixed-price, partial fills allowed) ───────────────────
create table if not exists exchange_store_listings (
    id            uuid primary key default gen_random_uuid(),
    seller_id     uuid not null references players(id) on delete cascade,
    item_id       text not null,
    quantity      bigint not null,
    price_per_unit bigint not null,   -- in Silver Marks
    fee_paid      bigint not null default 0,
    created_at    timestamptz not null default now(),
    expires_at    timestamptz,        -- null = never
    cancelled_at  timestamptz
);

alter table exchange_store_listings enable row level security;
create policy "store_listings: anyone can read active"
    on exchange_store_listings for select using (cancelled_at is null and quantity > 0);
create policy "store_listings: seller can insert"
    on exchange_store_listings for insert with check (auth.uid() = seller_id);
create policy "store_listings: seller can update own"
    on exchange_store_listings for update using (auth.uid() = seller_id);

-- ── Auction listings ───────────────────────────────────────────────────────
create table if not exists exchange_auctions (
    id              uuid primary key default gen_random_uuid(),
    seller_id       uuid not null references players(id) on delete cascade,
    item_id         text not null,
    quantity        bigint not null,
    starting_bid    bigint not null,
    buyout_price    bigint,           -- null = no buyout
    current_bid     bigint not null default 0,
    current_bidder  uuid references players(id),
    fee_paid        bigint not null default 0,
    duration_days   integer not null default 7,
    created_at      timestamptz not null default now(),
    ends_at         timestamptz not null,
    completed_at    timestamptz,
    cancelled_at    timestamptz
);

alter table exchange_auctions enable row level security;
create policy "auctions: anyone can read active"
    on exchange_auctions for select using (cancelled_at is null and completed_at is null);
create policy "auctions: seller can insert"
    on exchange_auctions for insert with check (auth.uid() = seller_id);
create policy "auctions: seller can cancel"
    on exchange_auctions for update using (auth.uid() = seller_id);

-- ── Buy orders ─────────────────────────────────────────────────────────────
create table if not exists exchange_buy_orders (
    id              uuid primary key default gen_random_uuid(),
    buyer_id        uuid not null references players(id) on delete cascade,
    item_id         text not null,
    quantity        bigint not null,
    remaining_qty   bigint not null,
    price_per_unit  bigint not null,
    escrow_amount   bigint not null,  -- held from buyer's wallet
    created_at      timestamptz not null default now(),
    cancelled_at    timestamptz
);

alter table exchange_buy_orders enable row level security;
create policy "buy_orders: anyone can read active"
    on exchange_buy_orders for select using (cancelled_at is null and remaining_qty > 0);
create policy "buy_orders: buyer can insert"
    on exchange_buy_orders for insert with check (auth.uid() = buyer_id);
create policy "buy_orders: buyer can cancel"
    on exchange_buy_orders for update using (auth.uid() = buyer_id);

-- ── Sale history (last N sales per item, written by Edge Function) ─────────
create table if not exists exchange_sale_history (
    id          uuid primary key default gen_random_uuid(),
    item_id     text not null,
    price       bigint not null,
    quantity    bigint not null,
    sold_at     timestamptz not null default now()
);

alter table exchange_sale_history enable row level security;
create policy "sale_history: anyone can read"
    on exchange_sale_history for select using (true);

-- ── Watchlist ──────────────────────────────────────────────────────────────
create table if not exists exchange_watchlist (
    player_id   uuid not null references players(id) on delete cascade,
    item_id     text not null,
    added_at    timestamptz not null default now(),
    primary key (player_id, item_id)
);

alter table exchange_watchlist enable row level security;
create policy "watchlist: own rows only"
    on exchange_watchlist for all using (auth.uid() = player_id);

-- ── Helper: place store purchase (server-authoritative) ────────────────────
-- Called via rpc/purchase_store_listing — Edge Function validates and executes.
-- Stub here; full logic lives in Edge Function to prevent client-side manipulation.

-- ── Helper: cancel buy order and refund escrow ─────────────────────────────
create or replace function cancel_buy_order(p_order_id uuid, p_player_id uuid)
returns bigint language plpgsql security definer as $$
declare
    v_escrow bigint;
    v_remaining bigint;
begin
    select escrow_amount * remaining_qty / quantity, remaining_qty
    into v_escrow, v_remaining
    from exchange_buy_orders
    where id = p_order_id and buyer_id = p_player_id and cancelled_at is null;

    if not found then return 0; end if;

    update exchange_buy_orders
    set cancelled_at = now()
    where id = p_order_id;

    -- Refund proportional escrow
    update player_currency
    set silver_marks = silver_marks + v_escrow, updated_at = now()
    where player_id = p_player_id;

    return v_escrow;
end;
$$;
