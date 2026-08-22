-- Project Grimoire, Migration 044: player username lookup for send-to-player (BUG-026)
--
-- The players table is own-row-only (policy "players: own row only", auth.uid() = id), so the
-- send-to-player feature's direct SELECT on players by username always returned zero rows and the
-- lookup reported "Player not found". This SECURITY DEFINER function looks a player up by username
-- and returns ONLY {id, username} (no other columns), preserving row privacy while enabling the
-- recipient lookup. Match is exact and case-insensitive.

create or replace function lookup_player_by_username(p_username text)
returns table (id uuid, username text)
language sql security definer set search_path = public
as $$
    select p.id, p.username from players p
    where lower(p.username) = lower(p_username)
    limit 1;
$$;

grant execute on function lookup_player_by_username(text) to anon, authenticated;
