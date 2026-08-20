import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Anon-callable boss-invite push. The client can't call send-notification directly (that one is
// service-role only), so this function authenticates the caller's JWT, verifies they are the host of
// the given boss_lobby, then delegates to send-notification with the service role. send-notification
// keeps the FCM send plus the per-player cooldown and hard cap, so a host can't spam a target.
//
// Body: { lobby_id: string, target_player_id: string }
// Invites also still arrive via the 12s discovery poll; this is the push on top.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const url        = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const anonKey    = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    // ── Identify the caller from their JWT ────────────────────────────────
    const userClient = createClient(url, anonKey, { global: { headers: { Authorization: authHeader } } });
    const { data: userData, error: userErr } = await userClient.auth.getUser();
    if (userErr || !userData?.user) return json({ error: "Unauthorized" }, 401);
    const callerId = userData.user.id;

    const { lobby_id, target_player_id } = await req.json();
    if (!lobby_id || !target_player_id) return json({ error: "Missing fields" }, 400);
    if (target_player_id === callerId)  return json({ skipped: "self" });

    const admin = createClient(url, serviceKey);

    // ── Verify the caller hosts this lobby and it is still open ───────────
    const { data: lobby, error: lobbyErr } = await admin
      .from("boss_lobby")
      .select("id, host_id, boss_id, zone_id, status")
      .eq("id", lobby_id)
      .single();
    if (lobbyErr || !lobby)          return json({ error: "Lobby not found" }, 404);
    if (lobby.host_id !== callerId)  return json({ error: "Not the host" }, 403);
    if (lobby.status !== "waiting")  return json({ skipped: "lobby not open" });

    // ── Delegate to send-notification (service role: fcm + cooldown + cap) ─
    const resp = await fetch(`${url}/functions/v1/send-notification`, {
      method: "POST",
      headers: { "Authorization": `Bearer ${serviceKey}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        player_id: target_player_id,
        priority:  3,
        title:     "Boss fight forming",
        body:      "A guildmate opened a boss lobby. Tap to join.",
        data: {
          type:    "boss_invite",
          lobby_id: String(lobby.id),
          zone_id:  String(lobby.zone_id ?? ""),
          boss_id:  String(lobby.boss_id ?? ""),
        },
      }),
    });
    const result = await resp.json().catch(() => ({}));
    return json({ ok: true, delegated: result });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
