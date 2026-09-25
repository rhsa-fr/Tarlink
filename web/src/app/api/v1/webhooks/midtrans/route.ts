import { NextResponse } from "next/server";
import { TarlinkStore } from "@/lib/services/tarlink-store";

export async function POST(request: Request) {
  try {
    const payload = await request.json();
    const { order_id, transaction_status, gross_amount } = payload;

    if (!order_id || !transaction_status) {
      return NextResponse.json(
        { statusCode: 400, message: "Invalid webhook payload" },
        { status: 400 }
      );
    }

    const result = await TarlinkStore.handleMidtransWebhook({
      order_id,
      transaction_status,
      gross_amount,
    });

    return NextResponse.json({
      statusCode: 200,
      message: "Webhook processed successfully",
      data: result,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Webhook error";
    return NextResponse.json(
      { statusCode: 500, message, error: "Server Error" },
      { status: 500 }
    );
  }
}
