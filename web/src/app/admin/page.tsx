"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import {
  TrendingUp,
  Percent,
  Calendar,
  ShieldAlert,
  ArrowUpRight,
  Sparkles,
  Music,
  MapPin,
  Clock,
  CheckCircle2,
} from "lucide-react";

interface AdminStats {
  gmv: number;
  totalBookings: number;
  platformRevenue: number;
  activeJobs: number;
  pendingVerifications: number;
  openDisputes: number;
  recentBookings: Array<{
    id: string;
    code: string;
    artist_name?: string;
    customer_name?: string;
    event_date: string;
    city: string;
    zone: string;
    distance_km: number;
    total_price: number;
    dp_amount: number;
    status: string;
  }>;
}

function formatRp(value: number): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  }).format(value);
}

export default function AdminDashboardPage() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/v1/admin/stats")
      .then((res) => res.json())
      .then((json) => {
        if (json.data) setStats(json.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="space-y-8">
      {/* Welcome Banner */}
      <div className="rounded-2xl bg-gradient-to-r from-[#191C21] via-[#2A231F] to-[#BD4024] p-6 lg:p-8 text-white relative overflow-hidden shadow-xl">
        <div className="relative z-10 max-w-2xl space-y-2">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#D4A017]/20 border border-[#D4A017]/40 text-[#D4A017] text-xs font-semibold">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Pusat Kendali Pasar Pantura • Musim Hajatan 2026</span>
          </div>
          <h2 className="text-2xl lg:text-3xl font-bold tracking-tight text-white">
            Selamat Datang di Backoffice Tarlink
          </h2>
          <p className="text-stone-300 text-sm leading-relaxed">
            Pantau pergerakan transaksi seni sandiwara, tarling dangdut, organ tunggal, verifikasi KTP seniman, serta pencairan payout H+2 se-kabupaten Indramayu & Cirebon.
          </p>
        </div>
        <div className="absolute right-0 bottom-0 opacity-10 pointer-events-none translate-x-12 translate-y-12">
          <Music className="w-96 h-96 text-white" />
        </div>
      </div>

      {/* KPI Bento Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
        {/* Total GMV */}
        <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
          <div className="flex items-center justify-between text-stone-500 text-xs font-semibold">
            <span>TOTAL NILAI TRANSAKSI (GMV)</span>
            <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <TrendingUp className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl lg:text-3xl font-bold tracking-tight text-stone-900">
            {loading ? "..." : formatRp(stats?.gmv ?? 50000000)}
          </div>
          <p className="text-xs text-stone-500">
            Volume kontrak panggung dari seluruh hajatan
          </p>
        </div>

        {/* Platform Revenue (8%) */}
        <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
          <div className="flex items-center justify-between text-stone-500 text-xs font-semibold">
            <span>KOMISI PLATFORM (8%)</span>
            <div className="w-8 h-8 rounded-lg bg-amber-50 text-amber-700 flex items-center justify-center">
              <Percent className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl lg:text-3xl font-bold tracking-tight text-[#BD4024]">
            {loading ? "..." : formatRp(stats?.platformRevenue ?? 4000000)}
          </div>
          <p className="text-xs text-stone-500">
            Fee otomatis dipotong saat pencairan H+2
          </p>
        </div>

        {/* Active Stage Jobs */}
        <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
          <div className="flex items-center justify-between text-stone-500 text-xs font-semibold">
            <span>PANGGUNG TERKUNCI (FULLDAY)</span>
            <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
              <Calendar className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl lg:text-3xl font-bold tracking-tight text-stone-900">
            {loading ? "..." : `${stats?.activeJobs ?? 2} Grup`}
          </div>
          <p className="text-xs text-stone-500">
            Terikat 1 grup 1 job per tanggal anti bentrok
          </p>
        </div>

        {/* Action Needed */}
        <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
          <div className="flex items-center justify-between text-stone-500 text-xs font-semibold">
            <span>ANTREAN PERLU TINDAKAN</span>
            <div className="w-8 h-8 rounded-lg bg-rose-50 text-rose-600 flex items-center justify-center">
              <ShieldAlert className="w-4 h-4" />
            </div>
          </div>
          <div className="flex items-center gap-3">
            <Link
              href="/admin/verifikasi"
              className="text-2xl font-bold text-amber-600 hover:underline"
            >
              {stats?.pendingVerifications ?? 1} KTP
            </Link>
            <span className="text-stone-300">•</span>
            <Link
              href="/admin/disputes"
              className="text-2xl font-bold text-rose-600 hover:underline"
            >
              {stats?.openDisputes ?? 1} Sengketa
            </Link>
          </div>
          <p className="text-xs text-stone-500">
            Review pimpinan lapak & kendala Bu Hajat
          </p>
        </div>
      </div>

      {/* Main Grid: Recent Bookings & Quick Navigation */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Table of Recent Bookings */}
        <div className="lg:col-span-2 rounded-2xl bg-white border border-stone-200/80 shadow-sm p-6 space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-base font-bold text-stone-900">Booking Panggung Terbaru</h3>
              <p className="text-xs text-stone-500">Aliran pesanan hajatan Pantura langsung dari aplikasi</p>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-stone-200 text-stone-500 font-medium">
                  <th className="pb-3">KODE / TANGGAL</th>
                  <th className="pb-3">GRUP SENI</th>
                  <th className="pb-3">SHOHIBUL HAJAT</th>
                  <th className="pb-3">ZONA & JARAK</th>
                  <th className="pb-3">TOTAL HARGA</th>
                  <th className="pb-3">STATUS</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100">
                {(stats?.recentBookings || []).map((b) => (
                  <tr key={b.id} className="hover:bg-stone-50/80 transition-colors">
                    <td className="py-3.5">
                      <p className="font-mono font-bold text-stone-900">{b.code}</p>
                      <p className="text-[11px] text-stone-500 flex items-center gap-1">
                        <Clock className="w-3 h-3 text-stone-400" />
                        {b.event_date}
                      </p>
                    </td>
                    <td className="py-3.5 font-semibold text-stone-800">
                      {b.artist_name || "Grup Seni Pantura"}
                    </td>
                    <td className="py-3.5 text-stone-600">
                      <p className="font-medium text-stone-900">{b.customer_name || "Bu Hajat"}</p>
                      <p className="text-[11px] text-stone-500">{b.city}</p>
                    </td>
                    <td className="py-3.5">
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-stone-100 text-stone-700 font-medium">
                        <MapPin className="w-3 h-3 text-[#BD4024]" />
                        {b.zone} ({b.distance_km} km)
                      </span>
                    </td>
                    <td className="py-3.5 font-bold text-stone-900">
                      {formatRp(b.total_price)}
                    </td>
                    <td className="py-3.5">
                      <span
                        className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full font-semibold text-[10px] ${
                          b.status === "DP_PAID"
                            ? "bg-emerald-100 text-emerald-800 border border-emerald-200"
                            : b.status === "COMPLETED"
                            ? "bg-blue-100 text-blue-800 border border-blue-200"
                            : "bg-amber-100 text-amber-800 border border-amber-200"
                        }`}
                      >
                        <CheckCircle2 className="w-3 h-3" />
                        {b.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Operational Modules Card */}
        <div className="space-y-4">
          <div className="rounded-2xl bg-white border border-stone-200/80 shadow-sm p-6 space-y-4">
            <h3 className="text-base font-bold text-stone-900">Aksi Cepat Admin</h3>
            <div className="space-y-3">
              <Link
                href="/admin/verifikasi"
                className="flex items-center justify-between p-3.5 rounded-xl border border-stone-200 hover:border-[#BD4024] hover:bg-stone-50 transition-all group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-amber-100 text-amber-800 flex items-center justify-center font-bold">
                    <ShieldAlert className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-stone-900 group-hover:text-[#BD4024]">
                      Verifikasi KTP Seniman
                    </h4>
                    <p className="text-xs text-stone-500">1 berkas lapak menunggu review</p>
                  </div>
                </div>
                <ArrowUpRight className="w-4 h-4 text-stone-400 group-hover:text-[#BD4024]" />
              </Link>

              <Link
                href="/admin/payouts"
                className="flex items-center justify-between p-3.5 rounded-xl border border-stone-200 hover:border-[#BD4024] hover:bg-stone-50 transition-all group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-emerald-100 text-emerald-800 flex items-center justify-center font-bold">
                    <TrendingUp className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-stone-900 group-hover:text-[#BD4024]">
                      Monitoring Payout H+2
                    </h4>
                    <p className="text-xs text-stone-500">Cairkan sisa DP ke rekening grup</p>
                  </div>
                </div>
                <ArrowUpRight className="w-4 h-4 text-stone-400 group-hover:text-[#BD4024]" />
              </Link>

              <Link
                href="/admin/disputes"
                className="flex items-center justify-between p-3.5 rounded-xl border border-stone-200 hover:border-[#BD4024] hover:bg-stone-50 transition-all group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-rose-100 text-rose-800 flex items-center justify-center font-bold">
                    <ShieldAlert className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-stone-900 group-hover:text-[#BD4024]">
                      Pusat Mediasi Sengketa
                    </h4>
                    <p className="text-xs text-stone-500">Tahan payout & input vonis</p>
                  </div>
                </div>
                <ArrowUpRight className="w-4 h-4 text-stone-400 group-hover:text-[#BD4024]" />
              </Link>

              <Link
                href="/admin/master-data"
                className="flex items-center justify-between p-3.5 rounded-xl border border-stone-200 hover:border-[#BD4024] hover:bg-stone-50 transition-all group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-stone-100 text-stone-800 flex items-center justify-center font-bold">
                    <MapPin className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-stone-900 group-hover:text-[#BD4024]">
                      Tarif Zona Pantura
                    </h4>
                    <p className="text-xs text-stone-500">Konfigurasi Ring 1, 2, 3</p>
                  </div>
                </div>
                <ArrowUpRight className="w-4 h-4 text-stone-400 group-hover:text-[#BD4024]" />
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
