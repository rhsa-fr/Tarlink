"use client";

import React, { useEffect, useState } from "react";
import {
  AlertTriangle,
  FileCheck,
  User,
  Music,
  Shield,
  CheckCircle2,
  XCircle,
  ExternalLink,
} from "lucide-react";

interface DisputeItem {
  id: string;
  booking_id: string;
  booking_code: string;
  reporter_id: string;
  reporter_name: string;
  reporter_phone: string;
  artist_name: string;
  reason: string;
  evidence_urls: string[];
  status: "open" | "under_review" | "resolved" | "rejected";
  verdict?: string;
  created_at: string;
}

export default function DisputesPage() {
  const [disputes, setDisputes] = useState<DisputeItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeDispute, setActiveDispute] = useState<DisputeItem | null>(null);
  const [verdictText, setVerdictText] = useState("");
  const [processing, setProcessing] = useState(false);

  const loadDisputes = () => {
    setLoading(true);
    fetch("/api/v1/admin/disputes")
      .then((res) => res.json())
      .then((json) => {
        if (json.data) setDisputes(json.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadDisputes();
  }, []);

  const handleResolve = async (action: "refund_customer" | "release_group") => {
    if (!activeDispute) return;
    if (!verdictText.trim()) {
      alert("Tuliskan catatan pertimbangan/vonis admin terlebih dahulu.");
      return;
    }

    setProcessing(true);
    try {
      const res = await fetch("/api/v1/admin/disputes", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          disputeId: activeDispute.id,
          verdict: verdictText,
          action,
        }),
      });
      if (res.ok) {
        alert("Sengketa berhasil diputuskan!");
        setActiveDispute(null);
        setVerdictText("");
        loadDisputes();
      } else {
        alert("Gagal memproses sengketa.");
      }
    } catch {
      alert("Kesalahan jaringan");
    } finally {
      setProcessing(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-stone-900 flex items-center gap-2">
          <AlertTriangle className="w-7 h-7 text-[#BD4024]" />
          Pusat Mediasi & Sengketa Lapak
        </h2>
        <p className="text-xs text-stone-500 mt-1">
          Investigasi laporan Bu Hajat atau Pimpinan Grup Seni Pantura terkait pembatalan, keterlambatan acara, atau wanprestasi.
        </p>
      </div>

      {loading ? (
        <div className="p-12 text-center text-stone-400 text-sm">Memuat daftar sengketa...</div>
      ) : disputes.length === 0 ? (
        <div className="p-12 text-center rounded-2xl bg-white border border-stone-200 text-stone-500">
          <Shield className="w-12 h-12 mx-auto text-emerald-500/40 mb-2" />
          <h3 className="font-bold text-stone-800">Tidak Ada Sengketa Aktif</h3>
          <p className="text-xs">Hubungan Shohibul Hajat dan Pimpinan Grup seni berjalan harmonis.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Dispute Cards */}
          <div className="lg:col-span-2 space-y-4">
            {disputes.map((d) => (
              <div
                key={d.id}
                onClick={() => {
                  setActiveDispute(d);
                  setVerdictText(d.verdict || "");
                }}
                className={`p-6 rounded-2xl bg-white border cursor-pointer transition-all ${
                  activeDispute?.id === d.id
                    ? "border-[#BD4024] shadow-md ring-2 ring-[#BD4024]/10"
                    : "border-stone-200 hover:border-stone-300 shadow-sm"
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold px-2 py-0.5 rounded bg-stone-100 text-stone-700">
                      {d.booking_code}
                    </span>
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${
                        d.status === "open"
                          ? "bg-rose-100 text-rose-800 border border-rose-200"
                          : "bg-emerald-100 text-emerald-800"
                      }`}
                    >
                      {d.status}
                    </span>
                  </div>
                  <span className="text-[11px] text-stone-400">
                    {new Date(d.created_at).toLocaleDateString("id-ID")}
                  </span>
                </div>

                <div className="mt-3 space-y-2 text-xs">
                  <div className="flex items-center gap-4 text-stone-600">
                    <span className="flex items-center gap-1 font-medium text-stone-900">
                      <User className="w-3.5 h-3.5 text-[#BD4024]" />
                      Pelapor: {d.reporter_name} ({d.reporter_phone})
                    </span>
                    <span className="flex items-center gap-1 text-stone-700">
                      <Music className="w-3.5 h-3.5 text-[#D4A017]" />
                      Tergugat: {d.artist_name}
                    </span>
                  </div>
                  <div className="p-3 rounded-xl bg-stone-50 border border-stone-100 text-stone-700">
                    <p className="font-semibold text-stone-900 mb-1">Keluhan Pelapor:</p>
                    <p className="italic leading-relaxed">&ldquo;{d.reason}&rdquo;</p>
                  </div>
                  {d.verdict && (
                    <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800">
                      <p className="font-semibold mb-0.5">Vonis Admin:</p>
                      <p>{d.verdict}</p>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Action / Resolution Sidebar */}
          <div className="rounded-2xl bg-white border border-stone-200 p-6 shadow-sm space-y-4 h-fit sticky top-24">
            <h3 className="text-base font-bold text-stone-900 flex items-center gap-2">
              <FileCheck className="w-5 h-5 text-[#BD4024]" />
              Formulir Keputusan Admin
            </h3>
            {activeDispute ? (
              <div className="space-y-4 text-xs">
                <div className="p-3 rounded-xl bg-stone-50 text-stone-600 space-y-1">
                  <p>Tiket: <strong className="text-stone-900">{activeDispute.booking_code}</strong></p>
                  <p>Pelapor: <strong className="text-stone-900">{activeDispute.reporter_name}</strong></p>
                  <p>Grup: <strong className="text-stone-900">{activeDispute.artist_name}</strong></p>
                </div>

                <div className="space-y-1.5">
                  <label className="font-bold text-stone-700">Catatan / Putusan Mediasi:</label>
                  <textarea
                    rows={4}
                    value={verdictText}
                    onChange={(e) => setVerdictText(e.target.value)}
                    placeholder="Tuliskan hasil investigasi, bukti panggilan, atau musyawarah adat..."
                    className="w-full p-3 rounded-xl border border-stone-300 focus:outline-none focus:ring-2 focus:ring-[#BD4024]/20 text-xs"
                  />
                </div>

                <div className="space-y-2 pt-2 border-t border-stone-100">
                  <button
                    disabled={processing}
                    onClick={() => handleResolve("release_group")}
                    className="w-full inline-flex items-center justify-center gap-2 py-2.5 rounded-xl bg-[#2D6A4F] hover:bg-[#1F5D43] text-white font-bold transition-colors disabled:opacity-50"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Lepaskan Dana ke Seniman</span>
                  </button>
                  <button
                    disabled={processing}
                    onClick={() => handleResolve("refund_customer")}
                    className="w-full inline-flex items-center justify-center gap-2 py-2.5 rounded-xl border border-rose-300 hover:bg-rose-50 text-rose-700 font-bold transition-colors disabled:opacity-50"
                  >
                    <XCircle className="w-4 h-4" />
                    <span>Batalkan & Refund DP ke Bu Hajat</span>
                  </button>
                </div>
              </div>
            ) : (
              <p className="text-xs text-stone-400 py-6 text-center">
                Pilih tiket sengketa di sebelah kiri untuk melihat rincian dan mengambil keputusan.
              </p>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
