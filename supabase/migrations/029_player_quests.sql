-- Project Grimoire, Quest server layer (Migration 029)
-- Alpha swap-in for the client quest engine (QuestManager): server-persisted assignment + progress and
-- a server-authoritative reward claim. The quest POOL stays in Unity Resources (client SOs); the client
-- assigns from it and upserts the result here, so progress/claims are cross-device and the currency
-- grant can't be double-claimed. collect_quest_reward flips claimed atomically and grants the currency
-- portion (silver_reward/gold_reward, computed client-side at assignment) into player_currency; the
-- client applies the non-currency rewards (talent/combat XP, items) from rewards_json.

create table if not exists player_quests (
    id            uuid primary key default gen_random_uuid(),
    player_id     uuid not null references players(id) on delete cascade,
    quest_id      text not null,                 -- QuestDefinition.questId
    cadence       text not null,                 -- 'Daily' | 'Weekly'
    progress      int  not null default 0,
    target_count  int  not null default 1,
    completed     boolean not null default false,
    claimed       boolean not null default false,
    resets_at     timestamptz not null,          -- the reset that owns this assignment window
    silver_reward bigint not null default 0,     -- currency granted server-side on claim
    gold_reward   bigint not null default 0,
    rewards_json  text,                           -- full scaled reward list, client applies XP/items
    updated_at    timestamptz not null default now(),
    unique (player_id, quest_id, cadence, resets_at)
);

create index if not exists player_quests_player_idx on player_quests(player_id);

alter table player_quests enable row level security;

drop policy if exists "player_quests: own select" on player_quests;
create policy "player_quests: own select" on player_quests for select using (player_id = auth.uid());
drop policy if exists "player_quests: own insert" on player_quests;
create policy "player_quests: own insert" on player_quests for insert with check (player_id = auth.uid());
drop policy if exists "player_quests: own update" on player_quests;
create policy "player_quests: own update" on player_quests for update using (player_id = auth.uid()) with check (player_id = auth.uid());
drop policy if exists "player_quests: own delete" on player_quests;
create policy "player_quests: own delete" on player_quests for delete using (player_id = auth.uid());

-- Server-authoritative claim: validate the row belongs to the caller and is completed + unclaimed, flip
-- claimed, and grant the currency portion into player_currency (upsert). Returns the currency granted
-- plus the full rewards_json so the client applies talent/combat XP and item rewards locally.
create or replace function collect_quest_reward(p_id uuid)
returns table (silver bigint, gold bigint, rewards_json text)
language plpgsql
security definer
set search_path = public
as $$
declare
    q player_quests;
begin
    select * into q from player_quests where id = p_id and player_id = auth.uid() for update;
    if not found      then raise exception 'quest not found'; end if;
    if not q.completed then raise exception 'quest not complete'; end if;
    if q.claimed       then raise exception 'quest already claimed'; end if;

    update player_quests set claimed = true, updated_at = now() where id = p_id;

    if q.silver_reward <> 0 or q.gold_reward <> 0 then
        insert into player_currency (player_id, silver_marks, gold_marks)
        values (auth.uid(), q.silver_reward, q.gold_reward)
        on conflict (player_id) do update
            set silver_marks = player_currency.silver_marks + excluded.silver_marks,
                gold_marks   = player_currency.gold_marks   + excluded.gold_marks,
                updated_at   = now();
    end if;

    return query select q.silver_reward, q.gold_reward, q.rewards_json;
end;
$$;
