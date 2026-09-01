-- 059_quest_accept_delivery.sql
-- Themed-quests v2.0 (docs/daily-weekly-quest-system.md): accept-to-pin bounty model.
--
-- player_quests rows are now OFFERS on a daily/weekly notice board. A quest becomes active only when the
-- player accepts it (up to the accept cap), which flips `accepted` and stamps `accepted_at`. Track-style
-- quests count progress only from that timestamp; Delivery quests read the live inventory balance and are
-- turned in client-authoritatively (inventory + Silver persist via the existing replace_inventory rails,
-- same as the Traveling Merchant sell), so no new RPC is required here.
--
-- Existing rows default to accepted = false, so on the next board they simply present as offers.

alter table public.player_quests
  add column if not exists accepted    boolean     not null default false,
  add column if not exists accepted_at timestamptz;

-- RLS is already enabled on player_quests (own-rows policy, migration 029). Adding columns does not change
-- the policy, so no further grant is needed.
