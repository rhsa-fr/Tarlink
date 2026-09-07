import { createClient } from "../_shared/supabase_client.ts";
import { errorResponse, successResponse } from "../_shared/response.ts";

Deno.serve(async (req) => {
  if (req.headers.get("Authorization") !== `Bearer ${Deno.env.get("CRON_SECRET")}`) {
    return errorResponse(401, "Unauthorized", "Unauthorized");
  }

  const supabase = createClient();
  const now = new Date().toISOString();

  const { data: expiredInvoices, error: invoiceErr } = await supabase
    .from("bookings")
    .update({ status: "EXPIRED" })
    .lte("expires_at", now)
    .eq("status", "WAITING_DP")
    .select("id");

  const { data: expiredOffers, error: offerErr } = await supabase
    .from("booking_offers")
    .update({ status: "expired" })
    .lte("expires_at", now)
    .eq("status", "proposed")
    .select("id");

  const { data: expiredPendingCustom, error: customErr } = await supabase
    .from("bookings")
    .update({ status: "EXPIRED" })
    .eq("booking_type", "custom")
    .eq("status", "PENDING")
    .lte("offer_expires_at", now)
    .select("id");

  if (invoiceErr || offerErr || customErr) {
    return errorResponse(500, "Expire worker failed", "InternalError");
  }

  return successResponse({
    invoicesExpired: expiredInvoices?.length ?? 0,
    offersExpired: expiredOffers?.length ?? 0,
    customExpired: expiredPendingCustom?.length ?? 0,
  });
});

