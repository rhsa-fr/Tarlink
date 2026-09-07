// Supabase Edge Functions Shared Helper
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

export function getServiceClient() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  return createClient(supabaseUrl, supabaseServiceKey);
}

export { getServiceClient as createClient };

export function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

export function errorResponse(message: string, statusCode = 400, error = "Bad Request") {
  return new Response(
    JSON.stringify({
      statusCode,
      message,
      error,
    }),
    {
      status: statusCode,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    }
  );
}
