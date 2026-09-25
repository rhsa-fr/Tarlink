import { NextResponse } from "next/server";

const FAQ_DATABASE = [
  {
    keywords: ["dp", "bayar dp", "cara bayar", "qris", "transfer"],
    answer:
      "Pembayaran DP 20% dapat dilakukan langsung via QRIS atau Virtual Account di aplikasi setelah Anda klik Pesan Sekarang. Invoice DP berlaku 30 menit.",
    deeplink: "/payment",
  },
  {
    keywords: ["cair", "kapan cair", "payout", "rekening", "transfer sisa"],
    answer:
      "Pencairan dana sisa DP (setelah dipotong fee platform 8%) otomatis ditransfer ke rekening bank grup terdaftar pada H+2 setelah hajatan berstatus Selesai (COMPLETED).",
    deeplink: "/profile_group/payout",
  },
  {
    keywords: ["reschedule", "ganti tanggal", "undur tanggal"],
    answer:
      "Reschedule untuk Instant Booking dapat diajukan maksimal H-7 acara dengan biaya admin 10% dari total nilai kontrak, selama tanggal baru grup masih hijau (tersedia).",
    deeplink: "/booking/reschedule",
  },
  {
    keywords: ["pelunasan", "cash", "bayar sisa", "sisa uang", "tunai"],
    answer:
      "Pelunasan sisa biaya 80% dibayarkan langsung secara tunai/cash kepada pimpinan grup di lokasi hajatan pada hari H. Setelah itu, kedua pihak wajib klik Konfirmasi Lunas di aplikasi.",
    deeplink: "/booking/active",
  },
  {
    keywords: ["sengketa", "komplain", "telat", "batal sepihak", "grup tidak datang"],
    answer:
      "Jika terjadi kendala serius di lapangan, silakan laporkan ke Pusat Sengketa. Tim Admin Pasar akan menahan dana payout H+2 dan memediasi kedua pihak.",
    deeplink: "/disputes/new",
  },
];

export async function POST(request: Request) {
  try {
    const { query } = await request.json();
    if (!query || typeof query !== "string") {
      return NextResponse.json(
        { statusCode: 400, message: "Query text is required" },
        { status: 400 }
      );
    }

    const lower = query.toLowerCase();
    const match = FAQ_DATABASE.find((item) =>
      item.keywords.some((k) => lower.includes(k))
    );

    if (match) {
      return NextResponse.json({
        statusCode: 200,
        data: {
          reply: match.answer,
          deeplink: match.deeplink,
          is_matched: true,
        },
      });
    }

    return NextResponse.json({
      statusCode: 200,
      data: {
        reply:
          "Halo Shohibul Hajat! Pertanyaan Anda sedang diteruskan ke Tim Admin Pasar Pantura. Anda juga dapat memilih menu bantuan cepat seputar DP, Pelunasan Cash, atau Jadwal.",
        deeplink: null,
        is_matched: false,
      },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Bot error";
    return NextResponse.json({ statusCode: 500, message }, { status: 500 });
  }
}
