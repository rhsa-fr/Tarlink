import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function GET() {
  try {
    const payouts = await TarlinkStore.getPayouts();
    return NextResponse.json({
      statusCode: 200,
      data: payouts,
      total: payouts.length,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const { payoutId } = await request.json();
    if (!payoutId) {
      return NextResponse.json(
        { statusCode: 400, message: "Payout ID is required" },
        { status: 400 }
      );
    }

    const completed = await TarlinkStore.triggerDisbursement(payoutId);
    return NextResponse.json({
      statusCode: 200,
      message: "Pencairan dana H+2 berhasil ditransfer ke rekening grup",
      data: completed,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Payout error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}
