// Edge Function: midtrans-hook
// Handles payment webhook with idempotency, signature verification, and E-Voucher generation.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts";
import { getServiceClient, corsHeaders, jsonResponse, errorResponse } from "../_shared/supabase_client.ts";

async function sha512(str: string): Promise<string> {
  const buf = await crypto.subtle.digest("SHA-512", new TextEncoder().encode(str));
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const {
      order_id,
      status_code,
      gross_amount,
      signature_key,
      transaction_status,
      transaction_id,
      payment_type,
    } = body;

    // 1. Verify Midtrans Signature
    const serverKey = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "mock-server-key";
    const expectedSignature = await sha512(`${order_id}${status_code}${gross_amount}${serverKey}`);

    if (signature_key && signature_key !== expectedSignature) {
      return errorResponse("Invalid signature", 401, "Unauthorized");
    }

    const supabase = getServiceClient();

    // 2. Idempotency check on gateway_trx_id
    const { data: existingPayment } = await supabase
      .from("payments")
      .select("id, status, booking_id")
      .eq("gateway_trx_id", transaction_id)
      .maybeSingle();

    if (existingPayment && existingPayment.status === "PAID") {
      return jsonResponse({ message: "Webhook already processed (idempotent)" }, 200);
    }

    // Determine payment success
    const isSuccess =
      transaction_status === "capture" ||
      transaction_status === "settlement";

    if (!isSuccess) {
      if (transaction_status === "expire") {
        await supabase
          .from("payments")
          .update({ status: "EXPIRED", raw_callback: body })
          .eq("gateway_trx_id", transaction_id);
      }
      return jsonResponse({ message: `Transaction status ${transaction_status} acknowledged` }, 200);
    }

    // 3. Find booking by code (order_id usually corresponds to booking code or payment ref)
    const { data: booking, error: bErr } = await supabase
      .from("bookings")
      .select("id, code, artist_id, dp_amount, status")
      .eq("code", order_id)
      .single();

    if (bErr || !booking) {
      return errorResponse("Booking not found", 404, "Not Found");
    }

    // 4. Record or update payment record
    const { data: updatedPayment, error: pErr } = await supabase
      .from("payments")
      .upsert(
        {
          booking_id: booking.id,
          type: "dp",
          amount: Number(gross_amount),
          method: payment_type,
          gateway: "midtrans",
          gateway_trx_id: transaction_id,
          status: "PAID",
          paid_at: new Date().toISOString(),
          raw_callback: body,
        },
        { onConflict: "gateway_trx_id" }
      )
      .select()
      .single();

    if (pErr) throw pErr;

    // 5. Generate E-Voucher code & update booking status to DP_PAID
    const evoucherCode = `VCHR-${booking.code}`;
    const { error: bUpdateErr } = await supabase
      .from("bookings")
      .update({
        status: "DP_PAID",
        evoucher_code: evoucherCode,
        paid_dp_at: new Date().toISOString(),
      })
      .eq("id", booking.id);

    if (bUpdateErr) throw bUpdateErr;

    // 6. Record status history
    await supabase.from("booking_status_histories").insert({
      booking_id: booking.id,
      from_status: booking.status,
      to_status: "DP_PAID",
      note: `DP terbayar via Midtrans (${payment_type}). E-Voucher ${evoucherCode} terbit.`,
    });

    // 7. Create HOLD Payout record for group disbursement H+2
    // Fee platform 8%
    const feePct = 8;
    const dpAmount = booking.dp_amount;
    const feeAmount = Math.round((dpAmount * feePct) / 100);
    const netAmount = dpAmount - feeAmount;

    await supabase.from("payouts").upsert(
      {
        booking_id: booking.id,
        artist_id: booking.artist_id,
        gross: dpAmount,
        fee_pct: feePct,
        fee: feeAmount,
        net: netAmount,
        status: "HOLD",
      },
      { onConflict: "booking_id" }
    );

    return jsonResponse(
      {
        success: true,
        message: "Payment processed, booking locked, evoucher generated",
        evoucher_code: evoucherCode,
      },
      200
    );
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : "Webhook error";
    return errorResponse(msg, 500, "Internal Server Error");
  }
});
