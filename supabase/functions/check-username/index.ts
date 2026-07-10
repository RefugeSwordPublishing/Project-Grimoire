import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// ── Profanity filter ────────────────────────────────────────────────────────
// Covers common English slurs and profanity. Updateable server-side without
// a client update. Add game-specific terms as needed.
const BLOCKED_TERMS = [
  "ass","arse","bastard","bitch","bollocks","cock","crap","cunt","damn",
  "dick","dumbass","fag","faggot","fuck","jackass","jerk","kike","motherfuck",
  "nigga","nigger","piss","prick","pussy","shit","slut","spic","twat","wank",
  "whore","retard","spaz","tranny",
  // game-specific
  "admin","moderator","gm","gamemaster","support","staff","official",
];

// Leet-speak normalization map
const LEET: Record<string, string> = {
  "0":"o","1":"i","3":"e","4":"a","5":"s","7":"t","8":"b",
  "@":"a","$":"s","|":"i","!":"i",
};

function normalize(s: string): string {
  return s
    .toLowerCase()
    .split("")
    .map(c => LEET[c] ?? c)
    .join("")
    .replace(/[^a-z0-9]/g, ""); // strip remaining non-alphanum
}

function containsBlockedTerm(username: string): boolean {
  const clean = normalize(username);
  return BLOCKED_TERMS.some(term => clean.includes(normalize(term)));
}

// ── Username format validation ──────────────────────────────────────────────
// 3–20 chars, alphanumeric + underscores only
const VALID_USERNAME = /^[a-zA-Z0-9_]{3,20}$/;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { username } = await req.json() as { username: string };

    if (!username || typeof username !== "string") {
      return json({ available: false, reason: "Username is required." });
    }

    if (!VALID_USERNAME.test(username)) {
      return json({ available: false, reason: "Username must be 3–20 characters (letters, numbers, underscores only)." });
    }

    if (containsBlockedTerm(username)) {
      return json({ available: false, reason: "This username is not available. Please choose another." });
    }

    // Check uniqueness in DB
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { count, error } = await supabase
      .from("players")
      .select("id", { count: "exact", head: true })
      .ilike("username", username);  // case-insensitive uniqueness

    if (error) throw error;

    if ((count ?? 0) > 0) {
      return json({ available: false, reason: "This username is already taken." });
    }

    return json({ available: true, reason: "" });

  } catch (err) {
    return new Response(
      JSON.stringify({ available: false, reason: "An error occurred. Please try again." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

function json(body: object) {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
