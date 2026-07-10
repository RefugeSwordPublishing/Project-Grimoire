import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface IdleRewardRequest {
  player_id: string;
  // Optional — if omitted, Edge Function reads last_active from players table
  last_session_at?: string;
}

interface IdleXPEntry {
  talent_name: string;
  xp: number;
}

interface IdleRewardResponse {
  elapsed_minutes: number;
  silver_gained: number;
  xp_gained: IdleXPEntry[];
  items_gained: string[];
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { player_id, last_session_at }: IdleRewardRequest = await req.json();

    // Read last_active from DB — never trust client-reported time
    const { data: playerRow, error: playerErr } = await supabase
      .from("players")
      .select("last_active")
      .eq("id", player_id)
      .single();

    if (playerErr || !playerRow) {
      return errorResponse("Player not found.");
    }

    const lastActive = playerRow.last_active
      ? new Date(playerRow.last_active)
      : (last_session_at ? new Date(last_session_at) : null);

    if (!lastActive) {
      return emptyResponse(0);
    }

    const now = new Date();
    const elapsedMs = now.getTime() - lastActive.getTime();
    const elapsedMinutes = elapsedMs / (1000 * 60);

    // Under 1 minute — nothing meaningful to report
    if (elapsedMinutes < 1) {
      return emptyResponse(elapsedMinutes);
    }

    // Cap at 8 hours to prevent exploitation
    const cappedHours = Math.min(elapsedMs / (1000 * 60 * 60), 8);

    // Fetch active idle talents
    const { data: activeTalents, error: talentErr } = await supabase
      .from("player_talents")
      .select("talent_id, idle_activity, level")
      .eq("player_id", player_id)
      .eq("is_idle", true);

    if (talentErr) throw talentErr;
    if (!activeTalents || activeTalents.length === 0) {
      await updateLastActive(supabase, player_id, now);
      return emptyResponse(elapsedMinutes);
    }

    // Fetch server-side XP rates
    const { data: rates } = await supabase
      .from("talent_idle_rates")
      .select("talent_name, base_xp_per_hour");

    const rateMap: Record<string, number> = {};
    if (rates) {
      for (const r of rates) rateMap[r.talent_name] = r.base_xp_per_hour;
    }

    // Calculate XP and apply to player_talents
    const xpGained: IdleXPEntry[] = [];
    for (const t of activeTalents) {
      const talentName = capitalize(t.talent_id);
      const baseRate = rateMap[talentName] ?? 100;
      const xp = Math.floor(baseRate * cappedHours);
      if (xp <= 0) continue;

      xpGained.push({ talent_name: talentName, xp });

      const { data: existing } = await supabase
        .from("player_talents")
        .select("current_xp")
        .eq("player_id", player_id)
        .eq("talent_id", t.talent_id)
        .single();

      await supabase.from("player_talents").upsert({
        player_id,
        talent_id:  t.talent_id,
        current_xp: (existing?.current_xp ?? 0) + xp,
        level:      t.level ?? 1,
      }, { onConflict: "player_id,talent_id" });
    }

    // Silver from idle Slaying
    const hasSlaying = activeTalents.some(t => t.talent_id === "slaying");
    const silverGained = hasSlaying ? Math.floor(cappedHours * 50) : 0;

    if (silverGained > 0) {
      await supabase.rpc("increment_silver", {
        p_player_id: player_id,
        p_amount:    silverGained,
      });
    }

    await updateLastActive(supabase, player_id, now);

    const response: IdleRewardResponse = {
      elapsed_minutes: elapsedMinutes,
      silver_gained:   silverGained,
      xp_gained:       xpGained,
      items_gained:    [],
    };

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

async function updateLastActive(supabase: ReturnType<typeof createClient>, playerId: string, now: Date) {
  await supabase
    .from("players")
    .update({ last_active: now.toISOString() })
    .eq("id", playerId);
}

function emptyResponse(elapsedMinutes: number) {
  return new Response(
    JSON.stringify({ elapsed_minutes: elapsedMinutes, silver_gained: 0, xp_gained: [], items_gained: [] }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );
}

function errorResponse(msg: string) {
  return new Response(
    JSON.stringify({ error: msg }),
    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );
}

function capitalize(s: string): string {
  return s.charAt(0).toUpperCase() + s.slice(1);
}
