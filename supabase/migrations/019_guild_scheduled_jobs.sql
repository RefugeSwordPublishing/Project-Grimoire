-- Project Grimoire — Guild scheduled jobs (Migration 019)
-- The two guild "background sweeps" the guild system needed. Implemented as
-- SECURITY DEFINER SQL functions run by pg_cron rather than Deno Edge Functions:
-- both are pure DB operations, so keeping them in SQL is simpler and avoids an
-- HTTP round-trip. Run AFTER 018.
--
-- If pg_cron isn't enabled yet: Supabase Dashboard → Database → Extensions →
-- enable "pg_cron", then run the cron.schedule() calls at the bottom.

-- ── 1. Close stale guild votes ───────────────────────────────────────────────
-- A vote closes (without passing) when its 7-day window elapses OR every member
-- has cast a ballot. Votes that reached the 2/3 threshold were already marked
-- 'passed' by cast_guild_vote; this only sweeps the open stragglers.
create or replace function close_expired_guild_votes()
returns integer language plpgsql security definer set search_path = public as $$
declare v_total int := 0; v_n int;
begin
    update guild_tax_votes v set status = 'closed'
    where v.status = 'open'
      and ( v.closes_at < now()
         or (select count(*) from guild_vote_ballots b where b.vote_id = v.id)
             >= coalesce((select member_count from guilds g where g.id = v.guild_id), 1) );
    get diagnostics v_n = row_count; v_total := v_total + v_n;

    update guild_name_votes v set status = 'closed'
    where v.status = 'open'
      and ( v.closes_at < now()
         or (select count(*) from guild_vote_ballots b where b.vote_id = v.id)
             >= coalesce((select member_count from guilds g where g.id = v.guild_id), 1) );
    get diagnostics v_n = row_count; v_total := v_total + v_n;

    return v_total;
end; $$;

-- ── 2. Sweep expired Guild Merchant listings ─────────────────────────────────
-- Listings past expires_at (7 days) are unsold; return the escrowed items to the
-- seller's server-side inventory (loaded on their next session) and delete the row.
create or replace function sweep_expired_merchant_listings()
returns integer language plpgsql security definer set search_path = public as $$
declare v_count int := 0; r record;
begin
    for r in select * from guild_merchant_listings where expires_at < now() for update loop
        insert into player_inventory (player_id, item_id, quantity)
            values (r.listed_by, r.item_id, r.quantity)
        on conflict (player_id, item_id)
            do update set quantity = player_inventory.quantity + excluded.quantity;
        delete from guild_merchant_listings where id = r.id;
        v_count := v_count + 1;
    end loop;
    return v_count;
end; $$;

-- ── Schedule (hourly) ────────────────────────────────────────────────────────
-- Requires the pg_cron extension. Enable it first (see header), then these run.
create extension if not exists pg_cron;

select cron.schedule('close-expired-guild-votes', '0 * * * *',
                     $$select close_expired_guild_votes()$$);
select cron.schedule('sweep-expired-merchant-listings', '0 * * * *',
                     $$select sweep_expired_merchant_listings()$$);
