"use client";

import React, { useEffect, useState } from "react";
import {
  Wallet,
  CheckCircle2,
  Clock,
  ArrowRight,
  AlertCircle,
  Building,
  Check,
} from "lucide-react";

interface PayoutItem {
  id: string;
  booking_id: string;
  artist_id: string;
  artist_name?: string;
  bank_name?: string;
  bank_no?: string;
  bank_owner?: string;
  gross: number;
  fee_pct: number;
  fee: number;
  net: number;
  status: "HOLD" | "READY" | "PROCESSING" | "COMPLETED" | "FAILED" | "DISPUTED";
  disbursement_id?: string;
  created_at: string;
}

function formatRp(val: number): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  }).format(val);
}

export default function PayoutsPage() {
  const [payouts, setPayouts] = useState<PayoutItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<string | null>(null);

  const loadPayouts = () => {
    setLoading(true);
    fetch("/api/v1/admin/payouts")
      .then((res) => res.json())
      .then((json) => {
        if (json.data) setPayouts(json.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadPayouts();
  }, []);

  const handleDisburse = async (payoutId: string) => {
    setProcessingId(payoutId);
    try {
      const res = await fetch("/api/v1/admin/payouts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ payoutId }),
      });
      const data = await res.json();
      if (res.ok) {
        setFeedback("Pencairan dana H+2 berhasil ditransfer via API Disbursement!");
        loadPayouts();
      } else {
        alert(data.message || "Gagal mencairkan");
      }
    } catch {
      alert("Kesalahan koneksi");
    } finally {
      setProcessingId(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-stone-900 flex items-center gap-2">
            <Wallet className="w-7 h-7 text-[#BD4024]" />
            Monitoring Antrean Payout H+2
          </h2>
          <p className="text-xs text-stone-500 mt-1">
            Dana DP 20% ditahan aman di rekening escrow platform dan dicairkan ke rekening bank grup seni pada H+2 setelah panggung selesai.
          </p>
        </div>
      </div>

      {feedback && (
        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-medium flex items-center gap-2">
          <Check className="w-4 h-4 text-emerald-600" />
          <span>{feedback}</span>
        </div>
      )}

      {/* Info Card */}
      <div className="p-4 rounded-xl bg-amber-50/80 border border-amber-200 text-xs text-[#795900] space-y-1">
        <p className="font-bold flex items-center gap-1.5">
          <AlertCircle className="w-4 h-4 text-[#D4A017]" />
          Aturan Bisnis Payout Pantura:
        </p>
        <p>
          1. Status <strong>HOLD</strong>: Acara belum selesai atau baru selesai kurang dari 48 jam (H+2).
        </p>
        <p>
          2. Status <strong>READY</strong>: Lewat masa sanggah H+2, siap ditransfer ke rekening bank pimpinan grup.
        </p>
        <p>
          3. Sisa pelunasan 80% tidak lewat sistem, melainkan dibayar tunai oleh Shohibul Hajat langsung di lokasi.
        </p>
      </div>

      {loading ? (
        <div className="p-12 text-center text-stone-400 text-sm">Memuat antrean payout...</div>
      ) : (
        <div className="rounded-2xl bg-white border border-stone-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-stone-200 bg-stone-50 text-stone-600 font-semibold">
                  <th className="p-4">GRUP SENI & REKENING</th>
                  <th className="p-4">DANA DP (GROSS)</th>
                  <th className="p-4">FEE PLATFORM (8%)</th>
                  <th className="p-4">TRANSFER BERSIH (NET)</th>
                  <th className="p-4">STATUS</th>
                  <th className="p-4 text-right">AKSI</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100">
                {payouts.map((p) => (
                  <tr key={p.id} className="hover:bg-stone-50/80 transition-colors">
                    <td className="p-4">
                      <p className="font-bold text-stone-900">{p.artist_name}</p>
                      <p className="text-[11px] text-stone-500 flex items-center gap-1 mt-0.5">
                        <Building className="w-3 h-3 text-stone-400" />
                        {p.bank_name} {p.bank_no} (a.n. {p.bank_owner})
                      </p>
                    </td>
                    <td className="p-4 font-medium text-stone-700">
                      {formatRp(p.gross)}
                    </td>
                    <td className="p-4 text-rose-600 font-medium">
                      -{formatRp(p.fee)}
                    </td>
                    <td className="p-4 font-bold text-emerald-700 text-sm">
                      {formatRp(p.net)}
                    </td>
                    <td className="p-4">
                      <span
                        className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full font-semibold text-[10px] ${
                          p.status === "READY"
                            ? "bg-amber-100 text-amber-800 border border-amber-200"
                            : p.status === "COMPLETED"
                            ? "bg-emerald-100 text-emerald-800 border border-emerald-200"
                            : "bg-stone-100 text-stone-700 border border-stone-200"
                        }`}
                      >
                        {p.status === "COMPLETED" && <CheckCircle2 className="w-3 h-3" />}
                        {p.status === "HOLD" && <Clock className="w-3 h-3" />}
                        {p.status}
                      </span>
                    </td>
                    <td className="p-4 text-right">
                      {p.status === "READY" && (
                        <button
                          disabled={processingId === p.id}
                          onClick={() => handleDisburse(p.id)}
                          className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#BD4024] hover:bg-[#9B280E] text-white font-bold text-xs shadow-sm transition-colors disabled:opacity-50"
                        >
                          <span>Cairkan Sekarang</span>
                          <ArrowRight className="w-3.5 h-3.5" />
                        </button>
                      )}
                      {p.status === "COMPLETED" && (
                        <span className="text-[11px] text-emerald-700 font-semibold">
                          Ditransfer ({p.disbursement_id?.slice(0, 14)}...)
                        </span>
                      )}
                      {p.status === "HOLD" && (
                        <span className="text-[11px] text-stone-400">
                          Menunggu H+2
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
