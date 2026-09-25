import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function GET() {
  try {
    const stats = await TarlinkStore.getAdminStats();
    return NextResponse.json({
      statusCode: 200,
      data: stats,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Stats error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}
