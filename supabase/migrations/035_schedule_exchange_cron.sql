-- Project Grimoire, schedule the Exchange pg_cron jobs (Migration 035). Run AFTER 026.
--
-- The auction-close + listing/buy-order expiry-sweep functions were shipped (migrations 020, 022,
-- 025, 026) but their cron.schedule() calls were left commented out, so ended auctions never closed
-- and expired listings/buy orders were never swept. pg_cron is already enabled and running the guild
-- jobs from migration 019, this adds the three Exchange jobs. Idempotent: unschedules any prior copy
-- by name first so a re-run doesn't error or duplicate.
select cron.unschedule(jobid) from cron.job
    where jobname in ('close-ended-auctions', 'sweep-expired-exchange-listings', 'sweep-expired-buy-orders');

-- Auctions close on the hour (winner paid / items delivered promptly after the end time).
select cron.schedule('close-ended-auctions', '0 * * * *',
                     $$ select close_ended_auctions(); $$);

-- Expired fixed-price listings return escrowed items to sellers, swept daily at 03:00 UTC.
select cron.schedule('sweep-expired-exchange-listings', '0 3 * * *',
                     $$ select sweep_expired_exchange_listings(); $$);

-- Expired buy orders refund the escrowed marks, swept daily at 03:00 UTC.
select cron.schedule('sweep-expired-buy-orders', '0 3 * * *',
                     $$ select sweep_expired_buy_orders(); $$);
