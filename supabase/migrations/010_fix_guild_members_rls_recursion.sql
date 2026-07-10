-- Project Grimoire — Fix guild_members RLS infinite recursion (Migration 010)
-- Migration 003's "members can read own guild" policy subqueries guild_members
-- inside guild_members' own policy → Postgres error 42P17 (infinite recursion),
-- which also breaks every other policy that subqueries guild_members.
--
-- Fix: resolve the caller's guild ids through a SECURITY DEFINER function that
-- bypasses RLS, so the membership lookup no longer re-triggers the policy.

create or replace function auth_guild_ids()
returns setof uuid
language sql
security definer
stable
set search_path = public
as $$
    select guild_id from guild_members where player_id = auth.uid();
$$;

drop policy if exists "guild_members: members can read own guild" on guild_members;
create policy "guild_members: members can read own guild"
    on guild_members for select
    using (guild_id in (select auth_guild_ids()));
