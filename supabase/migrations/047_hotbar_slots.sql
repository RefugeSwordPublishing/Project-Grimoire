-- 047_hotbar_slots.sql
-- Editable combat consumable hotbar (#51). Stores the player's three chosen consumable item names
-- for the 3-slot combat hotbar, pipe-delimited (item names contain spaces and apostrophes but never
-- a '|'). An empty string means "unassigned", and the client falls back to the auto-fill default.
ALTER TABLE player_settings
  ADD COLUMN IF NOT EXISTS hotbar_slots text NOT NULL DEFAULT '';
