// Edge Function: payout-auto
// Triggered on schedule or webhook to disburse net DP (H+2 after COMPLETED) via Xendit / Flip API.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getServiceClient, corsHeaders, jsonResponse, errorResponse } from "../_shared/supabase_client.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = getServiceClient();

    // Query payouts where status = 'HOLD' and associated booking is COMPLETED >= 2 days ago
    const twoDaysAgo = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString();

    const { data: eligiblePayouts, error: pErr } = await supabase
      .from("payouts")
      .select(`
        id, gross, fee, net, status, retry_count,
        artist_id, booking_id,
        artist_profiles (id, display_name, bank_name, bank_no, bank_owner),
        bookings!inner (id, code, completed_at, status)
      `)
      .eq("status", "HOLD")
      .eq("bookings.status", "COMPLETED")
      .lte("bookings.completed_at", twoDaysAgo);

    if (pErr) throw pErr;

    const results = [];

    for (const payout of eligiblePayouts ?? []) {
      const artist = payout.artist_profiles as any;
      if (!artist?.bank_no || !artist?.bank_name) {
        // Mark FAILED if bank info incomplete
        await supabase
          .from("payouts")
          .update({
            status: "FAILED",
            disbursement_status: "MISSING_BANK_INFO",
            retry_count: (payout.retry_count || 0) + 1,
          })
          .eq("id", payout.id);
        
        results.push({ payout_id: payout.id, status: "FAILED", reason: "Missing bank info" });
        continue;
      }

      // Simulate Xendit / Flip disbursement API invocation
      // In production, call fetch('https://api.xendit.co/disbursements', ...)
      const mockDisbursementId = `DISB-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

      await supabase
        .from("payouts")
        .update({
          status: "COMPLETED",
          disbursement_id: mockDisbursementId,
          disbursement_status: "SUCCESS",
          transferred_at: new Date().toISOString(),
        })
        .eq("id", payout.id);

      results.push({
        payout_id: payout.id,
        status: "COMPLETED",
        disbursement_id: mockDisbursementId,
        net_transferred: payout.net,
      });
    }

    return jsonResponse({
      message: `Processed ${results.length} eligible payouts`,
      results,
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : "Payout error";
    return errorResponse(msg, 500, "Internal Server Error");
  }
});
