import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";
import { z } from "zod";

const createBookingSchema = z.object({
  customer_id: z.string().trim().min(1, "Customer ID wajib diisi"),
  artist_id: z.string().trim().min(1, "Artist ID wajib diisi"),
  package_id: z.string().trim().min(1, "Package ID wajib diisi"),
  event_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Format tanggal YYYY-MM-DD"),
  venue_address: z.string().trim().min(3, "Alamat hajatan wajib diisi"),
  city: z.string().trim().min(2, "Kota wajib diisi"),
  district: z.string().trim().min(2, "Kecamatan wajib diisi"),
  venue_lat: z.number().min(-90, "Latitude minimal -90").max(90, "Latitude maksimal 90"),
  venue_lng: z.number().min(-180, "Longitude minimal -180").max(180, "Longitude maksimal 180"),
  booking_type: z.enum(["instant", "custom"]).optional(),
  note: z.string().optional(),
  customer_name: z.string().trim().optional(),
  customer_phone: z.string().trim().optional(),
});

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const validated = createBookingSchema.parse(body);

    const booking = await TarlinkStore.createBooking(validated);

    return NextResponse.json(
      {
        statusCode: 201,
        message: "Booking berhasil dibuat. Silakan selesaikan pembayaran DP 20%.",
        data: booking,
      },
      { status: 201 }
    );
  } catch (error: unknown) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          statusCode: 400,
          message: error.issues[0]?.message || "Validation Error",
          error: "Bad Request",
        },
        { status: 400 }
      );
    }

    const message = error instanceof Error ? error.message : "Gagal membuat booking";
    const status = message.includes("sudah memiliki jadwal") ? 409 : 400;

    return NextResponse.json(
      {
        statusCode: status,
        message,
        error: status === 409 ? "Conflict" : "Bad Request",
      },
      { status }
    );
  }
}
