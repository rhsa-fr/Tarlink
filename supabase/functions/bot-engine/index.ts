// Edge Function: bot-engine
// In-App CS Bot 24/7 Engine:
// Mode 1: FAQ & panduan template
// Mode 2: Intake sengketa & lock payout
// Mode 3: Asisten pimpinan grup gaptek ("liburkan tanggal...", "cek jadwal", "cek saldo")

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getServiceClient, corsHeaders, jsonResponse, errorResponse } from "../_shared/supabase_client.ts";

interface BotRequest {
  user_id: string;
  text: string;
  context?: {
    booking_id?: string;
    role?: string;
    step?: string;
  };
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { user_id, text, context }: BotRequest = await req.json();
    const supabase = getServiceClient();

    // 1. Log incoming user message
    await supabase.from("bot_conversations").insert({
      user_id,
      sender: "user",
      text,
      context,
    });

    const lower = text.toLowerCase().trim();
    let replyText = "";
    let intent = "general";

    // Mode 2: Dispute / Sengketa detection
    if (lower.includes("sengketa") || lower.includes("komplain") || lower.includes("lapor masalah") || lower.includes("tidak datang")) {
      intent = "dispute_intake";
      if (context?.booking_id) {
        // Create dispute record & lock payout
        await supabase.from("disputes").insert({
          booking_id: context.booking_id,
          reporter_id: user_id,
          reason: text,
          status: "open",
        });

        // Lock payout to DISPUTED
        await supabase
          .from("payouts")
          .update({ status: "DISPUTED" })
          .eq("booking_id", context.booking_id);

        replyText = "Laporan sengketa telah dicatat. Payout untuk booking ini telah DIKUNCI (status DISPUTED). Tim Admin Pasar akan meninjau bukti dalam 1-3 hari kerja.";
      } else {
        replyText = "Untuk melaporkan masalah, silakan pilih nomor booking terkait di riwayat pesanan Anda lalu ketuk 'Lapor Masalah'.";
      }
    }
    // Mode 3: Asisten Pimpinan Gaptek (jika pimpinan grup)
    else if (lower.startsWith("liburkan tanggal")) {
      intent = "group_block_date";
      // Contoh: "liburkan tanggal 2026-09-20"
      const dateMatch = text.match(/\d{4}-\d{2}-\d{2}/);
      if (dateMatch) {
        const date = dateMatch[0];
        // Fetch artist profile for this user
        const { data: artist } = await supabase
          .from("artist_profiles")
          .select("id")
          .eq("user_id", user_id)
          .maybeSingle();

        if (artist) {
          await supabase.from("blocked_dates").upsert(
            { artist_id: artist.id, date, reason: "Diliburkan via Bot" },
            { onConflict: "artist_id,date" }
          );
          replyText = `Siap pimpinan! Tanggal ${date} sudah berhasil diliburkan di kalender lapak Anda.`;
        } else {
          replyText = "Profil grup tidak ditemukan untuk akun ini.";
        }
      } else {
        replyText = "Format tanggal belum terbaca. Contoh perintah: 'liburkan tanggal 2026-09-20'";
      }
    }
    else if (lower === "cek saldo" || lower.includes("saldo")) {
      intent = "group_check_balance";
      const { data: artist } = await supabase
        .from("artist_profiles")
        .select("id")
        .eq("user_id", user_id)
        .maybeSingle();

      if (artist) {
        const { data: payouts } = await supabase
          .from("payouts")
          .select("net, status")
          .eq("artist_id", artist.id);

        let totalHold = 0;
        let totalCompleted = 0;
        payouts?.forEach((p) => {
          if (p.status === "HOLD") totalHold += p.net;
          if (p.status === "COMPLETED") totalCompleted += p.net;
        });

        replyText = `Ringkasan Saldo Lapak Anda:\n• Saldo tertahan (HOLD H+2): Rp ${totalHold.toLocaleString("id-ID")}\n• Total sudah dicairkan: Rp ${totalCompleted.toLocaleString("id-ID")}`;
      } else {
        replyText = "Akun Anda belum terdaftar sebagai pimpinan grup.";
      }
    }
    // Mode 1: FAQ Template matching
    else {
      intent = "faq_lookup";
      const { data: faqs } = await supabase
        .from("bot_faq_templates")
        .select("keywords, answer, deeplink")
        .eq("is_active", true);

      let matchedAnswer: string | null = null;
      if (faqs) {
        for (const faq of faqs) {
          const matched = faq.keywords.some((kw: string) => lower.includes(kw.toLowerCase()));
          if (matched) {
            matchedAnswer = faq.answer;
            break;
          }
        }
      }

      replyText = matchedAnswer ?? "Maaf, bot belum memahami pertanyaan Anda. Ketuk menu BANTUAN atau hubungi Admin Pasar jika butuh bantuan lebih lanjut.";
    }

    // 2. Log bot response
    await supabase.from("bot_conversations").insert({
      user_id,
      sender: "bot",
      text: replyText,
      intent,
      context,
    });

    return jsonResponse({
      intent,
      reply: replyText,
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : "Bot engine error";
    return errorResponse(msg, 500, "Internal Server Error");
  }
});
