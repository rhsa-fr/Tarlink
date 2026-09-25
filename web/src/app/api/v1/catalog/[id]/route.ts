import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const cleanId = id?.trim();

    if (!cleanId) {
      return NextResponse.json(
        { statusCode: 400, message: "ID grup seni wajib diisi", error: "Bad Request" },
        { status: 400 }
      );
    }

    const artist = await TarlinkStore.getArtistDetail(cleanId);

    if (!artist) {
      return NextResponse.json(
        { statusCode: 404, message: "Grup seni tidak ditemukan", error: "Not Found" },
        { status: 404 }
      );
    }

    return NextResponse.json({
      statusCode: 200,
      data: artist,
    });
  } catch (error: unknown) {
    console.error("[CatalogDetailAPI] Error fetching artist:", error);
    return NextResponse.json(
      { statusCode: 500, message: "Terjadi kesalahan pada server", error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
