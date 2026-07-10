import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { encode as base64url } from "https://deno.land/std@0.168.0/encoding/base64url.ts";

// ── Constants ──────────────────────────────────────────────────────────────
const COOLDOWN_MINUTES = 30;
const CAP_COUNT        = 3;
const CAP_WINDOW_HOURS = 4;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface NotificationRequest {
  player_id: string;
  priority:  1 | 2 | 3 | 4;
  title:     string;
  body:      string;
  data?:     Record<string, string>;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    // ── Auth: service role only ──────────────────────────────────────────
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.includes(serviceKey)) return json({ error: "Unauthorized" }, 401);

    const payload: NotificationRequest = await req.json();
    const { player_id, priority, title, body, data } = payload;
    if (!player_id || !priority || !title || !body) return json({ error: "Missing fields" }, 400);

    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, serviceKey);

    // ── Fetch player ─────────────────────────────────────────────────────
    const { data: player, error: playerErr } = await supabase
      .from("players")
      .select("fcm_token, notifications_enabled")
      .eq("id", player_id)
      .single();

    if (playerErr || !player)          return json({ error: "Player not found" }, 404);
    if (!player.notifications_enabled) return json({ skipped: "notifications disabled" });
    if (!player.fcm_token)             return json({ skipped: "no fcm token" });

    // ── Cooldown: P2+ only ────────────────────────────────────────────────
    if (priority > 1) {
      const cutoff = new Date(Date.now() - COOLDOWN_MINUTES * 60 * 1000).toISOString();
      const { data: recent } = await supabase
        .from("notification_log")
        .select("id")
        .eq("player_id", player_id)
        .gte("sent_at", cutoff)
        .limit(1);
      if (recent && recent.length > 0) return json({ skipped: "cooldown active" });
    }

    // ── Hard cap ──────────────────────────────────────────────────────────
    const capCutoff = new Date(Date.now() - CAP_WINDOW_HOURS * 60 * 60 * 1000).toISOString();
    const { count } = await supabase
      .from("notification_log")
      .select("id", { count: "exact", head: true })
      .eq("player_id", player_id)
      .gte("sent_at", capCutoff);
    if ((count ?? 0) >= CAP_COUNT) return json({ skipped: "hard cap reached" });

    // ── Get FCM access token ──────────────────────────────────────────────
    const accessToken = await getFCMAccessToken();

    // ── Send via FCM HTTP v1 ──────────────────────────────────────────────
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID")!;
    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type":  "application/json",
        },
        body: JSON.stringify({
          message: {
            token: player.fcm_token,
            notification: { title, body },
            data: { ...(data ?? {}), priority: String(priority) },
            android: {
              priority: priority <= 2 ? "high" : "normal",
              notification: { channel_id: channelForPriority(priority) },
            },
            apns: {
              headers: { "apns-priority": priority <= 2 ? "10" : "5" },
              payload: { aps: { sound: priority <= 2 ? "default" : "" } },
            },
          },
        }),
      },
    );

    if (!fcmRes.ok) {
      const err = await fcmRes.text();
      console.error("[send-notification] FCM error:", err);
      return json({ error: "FCM send failed", detail: err }, 502);
    }

    // ── Log ───────────────────────────────────────────────────────────────
    await supabase.from("notification_log").insert({ player_id, priority, title, body });

    return json({ sent: true });

  } catch (err) {
    console.error("[send-notification]", err);
    return json({ error: String(err) }, 500);
  }
});

// ── FCM V1 OAuth via service account JWT ──────────────────────────────────
// Env vars required:
//   FIREBASE_PROJECT_ID     — e.g. "projectgrimoire-4c75e"
//   FIREBASE_CLIENT_EMAIL   — from service account JSON
//   FIREBASE_PRIVATE_KEY    — from service account JSON (include \n literally)
async function getFCMAccessToken(): Promise<string> {
  const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
  const privateKey  = Deno.env.get("FIREBASE_PRIVATE_KEY")!.replace(/\\n/g, "\n");

  const now    = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim  = {
    iss:   clientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud:   "https://oauth2.googleapis.com/token",
    iat:   now,
    exp:   now + 3600,
  };

  const enc = (obj: unknown) =>
    base64url(new TextEncoder().encode(JSON.stringify(obj)));

  const signingInput = `${enc(header)}.${enc(claim)}`;

  // Import the RSA private key
  const keyData = pemToArrayBuffer(privateKey);
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const jwt = `${signingInput}.${base64url(new Uint8Array(signature))}`;

  // Exchange JWT for access token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion:  jwt,
    }),
  });

  const tokenData = await tokenRes.json();
  return tokenData.access_token;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binary = atob(b64);
  const bytes  = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

function channelForPriority(p: number) {
  return p === 1 ? "grimoire_critical" : p === 2 ? "grimoire_important" : p === 3 ? "grimoire_standard" : "grimoire_low";
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
