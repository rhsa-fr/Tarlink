import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function GET() {
  try {
    const disputes = await TarlinkStore.getDisputes();
    return NextResponse.json({
      statusCode: 200,
      data: disputes,
      total: disputes.length,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const { disputeId, verdict, action } = await request.json();
    if (!disputeId || !verdict || !["refund_customer", "release_group"].includes(action)) {
      return NextResponse.json(
        { statusCode: 400, message: "Invalid parameters" },
        { status: 400 }
      );
    }

    const resolved = await TarlinkStore.resolveDispute(disputeId, verdict, action);
    return NextResponse.json({
      statusCode: 200,
      message: "Sengketa berhasil diselesaikan",
      data: resolved,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Dispute error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}
