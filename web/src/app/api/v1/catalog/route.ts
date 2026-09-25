import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const city = searchParams.get("city") || undefined;
    const category = searchParams.get("category") || undefined;

    const artists = await TarlinkStore.getCatalog(city, category);

    return NextResponse.json({
      statusCode: 200,
      data: artists,
      total: artists.length,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Internal Server Error";
    return NextResponse.json(
      { statusCode: 500, message, error: "Server Error" },
      { status: 500 }
    );
  }
}
