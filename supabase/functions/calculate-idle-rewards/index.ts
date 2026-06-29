import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface IdleRewardRequest {
  player_id: string;
  last_session_at: string;
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

    const lastSession = new Date(last_session_at);
    const now = new Date();
    const elapsedMs = now.getTime() - lastSession.getTime();
    const elapsedHours = elapsedMs / (1000 * 60 * 60);
    const elapsedMinutes = elapsedMs / (1000 * 60);

    // Cap idle time at 24 hours to prevent clock manipulation abuse
    const cappedHours = Math.min(elapsedHours, 24);

    if (cappedHours < 0.016) {
      return new Response(
        JSON.stringify({ elapsed_minutes: elapsedMinutes, silver_gained: 0, xp_gained: [], items_gained: [] }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Fetch player's idle queue
    const { data: queue, error: queueError } = await supabase
      .from("idle_queue")
      .select("talent_name, slot_index, efficiency_multiplier")
      .eq("player_id", player_id)
      .order("slot_index");

    if (queueError) throw queueError;
    if (!queue || queue.length === 0) {
      return new Response(
        JSON.stringify({ elapsed_minutes: elapsedMinutes, silver_gained: 0, xp_gained: [], items_gained: [] }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Fetch server-side idle XP rates (tunable without client update)
    const { data: rates } = await supabase
      .from("talent_idle_rates")
      .select("talent_name, base_xp_per_hour");

    const rateMap: Record<string, number> = {};
    if (rates) {
      for (const r of rates) rateMap[r.talent_name] = r.base_xp_per_hour;
    }

    // Calculate and apply XP per talent
    const xpGained: IdleXPEntry[] = [];
    for (const entry of queue) {
      const baseRate = rateMap[entry.talent_name] ?? 100;
      const xp = Math.floor(baseRate * cappedHours * entry.efficiency_multiplier);
      if (xp <= 0) continue;

      xpGained.push({ talent_name: entry.talent_name, xp });

      const { data: existing } = await supabase
        .from("talent_progress")
        .select("current_xp, current_level")
        .eq("player_id", player_id)
        .eq("talent_name", entry.talent_name)
        .single();

      await supabase.from("talent_progress").upsert({
        player_id,
        talent_name: entry.talent_name,
        current_xp: (existing?.current_xp ?? 0) + xp,
        current_level: existing?.current_level ?? 1,
        updated_at: now.toISOString()
      }, { onConflict: "player_id,talent_name" });
    }

    // Silver from idle Slaying
    const hasSlaying = queue.some(e => e.talent_name === "Slaying");
    const silverGained = hasSlaying ? Math.floor(cappedHours * 50) : 0;

    if (silverGained > 0) {
      await supabase.rpc("increment_silver_marks", {
        p_player_id: player_id,
        p_amount: silverGained
      });
    }

    // Update last session timestamp
    await supabase
      .from("players")
      .update({ last_session_at: now.toISOString() })
      .eq("id", player_id);

    const response: IdleRewardResponse = {
      elapsed_minutes: elapsedMinutes,
      silver_gained: silverGained,
      xp_gained: xpGained,
      items_gained: []
    };

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
