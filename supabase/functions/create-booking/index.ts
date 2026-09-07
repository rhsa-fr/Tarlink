// Edge Function: create-booking
// Handles server-side booking creation, transactional lock, and DP calculation.
// CRITICAL: Financial calculations (DP 20%, fee 8%, zone transport) strictly executed on server.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getServiceClient, corsHeaders, errorResponse, jsonResponse } from "../_shared/supabase_client.ts";

interface CreateBookingPayload {
  customer_id: string;
  artist_id: string;
  package_id: string;
  event_date: string; // YYYY-MM-DD
  venue_address: string;
  venue_maps_url?: string;
  city: string;
  district: string;
  venue_lat: number;
  venue_lng: number;
  booking_type?: "instant" | "custom";
  note?: string;
}

// Haversine formula (km)
function calculateHaversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const toRad = (v: number) => (v * Math.PI) / 180;
  const R = 6371; // Earth radius in KM
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 100) / 100;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: CreateBookingPayload = await req.json();
    const supabase = getServiceClient();

    // 1. Validate customer max 2 pending custom bookings (Anti-PHP)
    if (payload.booking_type === "custom") {
      const { count: pendingCount, error: countErr } = await supabase
        .from("bookings")
        .select("id", { count: "exact", head: true })
        .eq("customer_id", payload.customer_id)
        .eq("booking_type", "custom")
        .eq("status", "PENDING");

      if (countErr) throw countErr;
      if ((pendingCount ?? 0) >= 2) {
        return errorResponse("Batas maksimal 2 booking kustom berstatus PENDING telah tercapai", 429, "Too Many Requests");
      }
    }

    // 2. Fetch artist profile and base location
    const { data: artist, error: artistErr } = await supabase
      .from("artist_profiles")
      .select("id, display_name, base_lat, base_lng, auto_accept, status")
      .eq("id", payload.artist_id)
      .single();

    if (artistErr || !artist) {
      return errorResponse("Grup tidak ditemukan", 404, "Not Found");
    }

    if (artist.status !== "verified") {
      return errorResponse("Lapak grup belum terverifikasi", 400, "Bad Request");
    }

    // 3. Verify artist is not blocked on event_date
    const { data: blocked } = await supabase
      .from("blocked_dates")
      .select("id")
      .eq("artist_id", payload.artist_id)
      .eq("date", payload.event_date)
      .maybeSingle();

    if (blocked) {
      return errorResponse("Grup meliburkan jadwal pada tanggal tersebut", 409, "Conflict");
    }

    // 4. Verify no active booking on the same date (Fullday mutlak)
    const { data: existingBooking } = await supabase
      .from("bookings")
      .select("id, status")
      .eq("artist_id", payload.artist_id)
      .eq("event_date", payload.event_date)
      .in("status", ["DP_PAID", "PARTIAL_PAID", "FULL_PAID", "ONGOING"])
      .maybeSingle();

    if (existingBooking) {
      return errorResponse("Grup sudah memiliki jadwal manggung pada tanggal tersebut", 409, "Conflict");
    }

    // 5. Fetch package details
    const { data: pkg, error: pkgErr } = await supabase
      .from("packages")
      .select("id, name, price, is_active")
      .eq("id", payload.package_id)
      .eq("artist_id", payload.artist_id)
      .single();

    if (pkgErr || !pkg || !pkg.is_active) {
      return errorResponse("Paket tidak valid atau tidak aktif", 400, "Bad Request");
    }

    // 6. Calculate distance via Haversine and determine zone price
    let distanceKm = 0;
    let zoneName = "Ring 1";
    let extraTransportPrice = 0;

    if (artist.base_lat && artist.base_lng && payload.venue_lat && payload.venue_lng) {
      distanceKm = calculateHaversineKm(
        Number(artist.base_lat),
        Number(artist.base_lng),
        payload.venue_lat,
        payload.venue_lng
      );

      // Fetch zone prices for this package
      const { data: zones } = await supabase
        .from("zone_prices")
        .select("zone, max_km, extra_price")
        .eq("package_id", payload.package_id)
        .order("max_km", { ascending: true });

      if (zones && zones.length > 0) {
        const matched = zones.find((z) => distanceKm <= Number(z.max_km));
        if (matched) {
          zoneName = matched.zone;
          extraTransportPrice = matched.extra_price;
        } else {
          // Default to highest tier / Luar Kota
          const highest = zones[zones.length - 1];
          zoneName = highest.zone;
          extraTransportPrice = highest.extra_price;
        }
      }
    }

    // 7. Calculate server-side total price and DP amount
    const basePackagePrice = pkg.price;
    const totalPrice = basePackagePrice + extraTransportPrice;
    const dpPercent = 20;
    const dpAmount = Math.round((totalPrice * dpPercent) / 100);
    const remainingAmount = totalPrice - dpAmount;

    // 8. Generate booking code
    const year = new Date().getFullYear();
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const bookingCode = `TRG-${year}-${randomSuffix}`;

    // Determine initial status based on auto_accept
    const isAutoAccept = artist.auto_accept === true;
    const initialStatus = isAutoAccept ? "WAITING_DP" : "PENDING";
    const approvedAt = isAutoAccept ? new Date().toISOString() : null;

    // 9. Insert booking record
    const { data: newBooking, error: insertErr } = await supabase
      .from("bookings")
      .insert({
        code: bookingCode,
        customer_id: payload.customer_id,
        artist_id: payload.artist_id,
        package_id: payload.package_id,
        event_date: payload.event_date,
        venue_address: payload.venue_address,
        venue_maps_url: payload.venue_maps_url,
        city: payload.city,
        district: payload.district,
        venue_lat: payload.venue_lat,
        venue_lng: payload.venue_lng,
        distance_km: distanceKm,
        zone: zoneName,
        total_price: totalPrice,
        final_price: totalPrice,
        dp_percent: dpPercent,
        dp_amount: dpAmount,
        remaining_amount: remainingAmount,
        booking_type: payload.booking_type ?? "instant",
        approved_at: approvedAt,
        status: initialStatus,
        note: payload.note,
        expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(), // 30 minutes invoice window
      })
      .select()
      .single();

    if (insertErr) throw insertErr;

    // 10. Record booking items
    await supabase.from("booking_items").insert([
      { booking_id: newBooking.id, label: `Paket Dasar: ${pkg.name}`, amount: basePackagePrice },
      { booking_id: newBooking.id, label: `Biaya Transport (${zoneName}, ${distanceKm} km)`, amount: extraTransportPrice },
    ]);

    // 11. Record status history
    await supabase.from("booking_status_histories").insert({
      booking_id: newBooking.id,
      from_status: null,
      to_status: initialStatus,
      changed_by: payload.customer_id,
      note: isAutoAccept ? "Instant booking (auto-approved)" : "Menunggu konfirmasi pimpinan grup",
    });

    return jsonResponse(
      {
        message: "Booking berhasil dibuat",
        booking: newBooking,
      },
      201
    );
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : "Terjadi kesalahan pada server";
    return errorResponse(msg, 500, "Internal Server Error");
  }
});
