import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function GET() {
  try {
    const pendings = await TarlinkStore.getPendingVerifications();
    return NextResponse.json({
      statusCode: 200,
      data: pendings,
      total: pendings.length,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const { artistId, status } = await request.json();
    if (!artistId || !["verified", "suspended"].includes(status)) {
      return NextResponse.json(
        { statusCode: 400, message: "Invalid parameters" },
        { status: 400 }
      );
    }

    const updated = await TarlinkStore.updateArtistStatus(artistId, status);
    return NextResponse.json({
      statusCode: 200,
      message: `Status lapak berhasil diperbarui menjadi ${status}`,
      data: updated,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Update error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}
