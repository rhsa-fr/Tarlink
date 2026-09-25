"use client";

import React, { useEffect, useState } from "react";
import {
  ShieldCheck,
  Check,
  X,
  FileText,
  Building,
  CreditCard,
  MapPin,
  AlertCircle,
  ExternalLink,
} from "lucide-react";

interface PendingArtist {
  id: string;
  display_name: string;
  category: string;
  base_city: string;
  base_district: string;
  phone?: string;
  bank_name?: string;
  bank_no?: string;
  bank_owner?: string;
  ktp_url?: string;
  description: string;
  price_min: number;
  price_max: number;
}

export default function VerifikasiPage() {
  const [artists, setArtists] = useState<PendingArtist[]>([]);
  const [loading, setLoading] = useState(true);
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const loadData = () => {
    setLoading(true);
    fetch("/api/v1/admin/verifications")
      .then((res) => res.json())
      .then((json) => {
        if (json.data) setArtists(json.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleAction = async (artistId: string, status: "verified" | "suspended") => {
    setProcessingId(artistId);
    try {
      const res = await fetch("/api/v1/admin/verifications", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ artistId, status }),
      });
      const data = await res.json();
      if (res.ok) {
        setMessage(
          status === "verified"
            ? "Lapak berhasil diverifikasi dan dipromosikan ke pimpinan grup aktif!"
            : "Lapak berhasil ditolak/disuspend."
        );
        loadData();
      } else {
        alert(data.message || "Gagal memproses");
      }
    } catch {
      alert("Terjadi kesalahan jaringan");
    } finally {
      setProcessingId(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-stone-900 flex items-center gap-2">
            <ShieldCheck className="w-7 h-7 text-[#BD4024]" />
            Verifikasi KTP & Lapak Seniman
          </h2>
          <p className="text-xs text-stone-500 mt-1">
            Validasi identitas pimpinan grup seni, data rekening bank, dan lokasi base markas panggung Pantura.
          </p>
        </div>
        <span className="px-3 py-1 rounded-full bg-amber-100 border border-amber-300 text-amber-800 text-xs font-semibold self-start">
          {artists.length} Berkas Menunggu
        </span>
      </div>

      {message && (
        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-medium flex items-center gap-2">
          <Check className="w-4 h-4 text-emerald-600" />
          <span>{message}</span>
        </div>
      )}

      {loading ? (
        <div className="p-12 text-center text-stone-400 text-sm">Memuat berkas verifikasi...</div>
      ) : artists.length === 0 ? (
        <div className="p-12 text-center rounded-2xl bg-white border border-stone-200 text-stone-500 space-y-2">
          <ShieldCheck className="w-12 h-12 mx-auto text-emerald-500/40" />
          <h3 className="font-bold text-stone-800">Semua Berkas Bersih</h3>
          <p className="text-xs">Tidak ada pendaftaran lapak seniman baru yang menunggu persetujuan saat ini.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {artists.map((artist) => (
            <div
              key={artist.id}
              className="rounded-2xl bg-white border border-stone-200 p-6 shadow-sm space-y-4 flex flex-col justify-between"
            >
              <div className="space-y-3">
                <div className="flex items-start justify-between">
                  <div>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-[#BD4024]/10 text-[#BD4024] uppercase tracking-wider">
                      {artist.category}
                    </span>
                    <h3 className="text-lg font-bold text-stone-900 mt-1">
                      {artist.display_name}
                    </h3>
                  </div>
                  <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                    Menunggu Verifikasi
                  </span>
                </div>

                <p className="text-xs text-stone-600 leading-relaxed">
                  {artist.description}
                </p>

                {/* Basecamp Location */}
                <div className="p-3 rounded-xl bg-stone-50 border border-stone-100 text-xs space-y-1">
                  <div className="flex items-center gap-2 text-stone-700 font-medium">
                    <MapPin className="w-3.5 h-3.5 text-[#BD4024]" />
                    <span>Basecamp: {artist.base_district}, Kab. {artist.base_city}</span>
                  </div>
                  <div className="flex items-center gap-2 text-stone-700 font-medium">
                    <CreditCard className="w-3.5 h-3.5 text-[#D4A017]" />
                    <span>
                      Rekening: {artist.bank_name} - {artist.bank_no} (a.n. {artist.bank_owner})
                    </span>
                  </div>
                </div>

                {/* KTP Document Card */}
                <div className="p-3 rounded-xl border border-dashed border-stone-300 bg-stone-50/50 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <FileText className="w-6 h-6 text-stone-500" />
                    <div>
                      <p className="text-xs font-bold text-stone-800">Foto KTP Pimpinan Grup</p>
                      <p className="text-[10px] text-stone-400">Verifikasi NIK & Keaslian Identitas</p>
                    </div>
                  </div>
                  {artist.ktp_url ? (
                    <a
                      href={artist.ktp_url}
                      target="_blank"
                      rel="noreferrer"
                      className="inline-flex items-center gap-1 text-xs font-semibold text-[#BD4024] hover:underline"
                    >
                      <span>Lihat KTP</span>
                      <ExternalLink className="w-3.5 h-3.5" />
                    </a>
                  ) : (
                    <span className="text-[11px] text-stone-400">Belum diunggah</span>
                  )}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="pt-4 border-t border-stone-100 flex items-center gap-3">
                <button
                  disabled={processingId === artist.id}
                  onClick={() => handleAction(artist.id, "verified")}
                  className="flex-1 inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-[#2D6A4F] hover:bg-[#1F5D43] text-white text-xs font-bold transition-colors shadow-sm disabled:opacity-50"
                >
                  <Check className="w-4 h-4" />
                  <span>Setujui Lapak (Verifikasi)</span>
                </button>
                <button
                  disabled={processingId === artist.id}
                  onClick={() => handleAction(artist.id, "suspended")}
                  className="px-4 py-2.5 rounded-xl border border-rose-200 hover:bg-rose-50 text-rose-700 text-xs font-bold transition-colors disabled:opacity-50"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
