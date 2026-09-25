"use client";

import React from "react";
import { MapPin, Settings2, Sliders, DollarSign, Layers } from "lucide-react";

export default function MasterDataPage() {
  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-stone-900 flex items-center gap-2">
          <MapPin className="w-7 h-7 text-[#BD4024]" />
          Master Wilayah & Tarif Zona Pantura
        </h2>
        <p className="text-xs text-stone-500 mt-1">
          Pengaturan radius logistik panggung Pantura (Haversine formula), batasan wilayah cakupan, serta komisi platform.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Zone Logistics Policy */}
        <div className="rounded-2xl bg-white border border-stone-200 p-6 shadow-sm space-y-4">
          <h3 className="text-base font-bold text-stone-900 flex items-center gap-2">
            <Sliders className="w-5 h-5 text-[#D4A017]" />
            Kebijakan Tarif Jarak (Haversine Engine)
          </h3>

          <div className="space-y-3 text-xs">
            <div className="p-3.5 rounded-xl bg-stone-50 border border-stone-200 flex items-center justify-between">
              <div>
                <p className="font-bold text-stone-900">Ring 1 (Jarak 0 – 15 km)</p>
                <p className="text-stone-500">Radius markas terdekat / satu kecamatan</p>
              </div>
              <span className="font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200">
                Gratis / Masuk Paket
              </span>
            </div>

            <div className="p-3.5 rounded-xl bg-stone-50 border border-stone-200 flex items-center justify-between">
              <div>
                <p className="font-bold text-stone-900">Ring 2 (Jarak 15.1 – 35 km)</p>
                <p className="text-stone-500">Antar-kecamatan lokal Pantura</p>
              </div>
              <span className="font-bold text-[#BD4024] bg-rose-50 px-2.5 py-1 rounded-full border border-rose-200">
                +Rp 1.000.000 (Mobil Truk Alat)
              </span>
            </div>

            <div className="p-3.5 rounded-xl bg-stone-50 border border-stone-200 flex items-center justify-between">
              <div>
                <p className="font-bold text-stone-900">Ring 3 (Jarak &gt; 35 km)</p>
                <p className="text-stone-500">Lintas kabupaten (Indramayu &harr; Cirebon/Subang)</p>
              </div>
              <span className="font-bold text-amber-800 bg-amber-50 px-2.5 py-1 rounded-full border border-amber-200">
                +Rp 2.500.000 (Logistik Full)
              </span>
            </div>
          </div>
        </div>

        {/* Global Financial Parameters */}
        <div className="rounded-2xl bg-white border border-stone-200 p-6 shadow-sm space-y-4">
          <h3 className="text-base font-bold text-stone-900 flex items-center gap-2">
            <DollarSign className="w-5 h-5 text-[#BD4024]" />
            Parameter Keuangan & Transaksi
          </h3>

          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between p-3.5 rounded-xl border border-stone-100">
              <span className="text-stone-600 font-medium">Persentase Uang Muka (DP Online)</span>
              <span className="font-bold text-stone-900 bg-stone-100 px-3 py-1 rounded-lg">20%</span>
            </div>
            <div className="flex items-center justify-between p-3.5 rounded-xl border border-stone-100">
              <span className="text-stone-600 font-medium">Batas Waktu Bayar Invoice DP (Snap)</span>
              <span className="font-bold text-stone-900 bg-stone-100 px-3 py-1 rounded-lg">30 Menit</span>
            </div>
            <div className="flex items-center justify-between p-3.5 rounded-xl border border-stone-100">
              <span className="text-stone-600 font-medium">Fee Bagi Hasil Lapak Pasar</span>
              <span className="font-bold text-[#BD4024] bg-rose-50 px-3 py-1 rounded-lg">8%</span>
            </div>
            <div className="flex items-center justify-between p-3.5 rounded-xl border border-stone-100">
              <span className="text-stone-600 font-medium">SLA Pencairan Otomatis Payout</span>
              <span className="font-bold text-stone-900 bg-stone-100 px-3 py-1 rounded-lg">H+2 (48 Jam)</span>
            </div>
            <div className="flex items-center justify-between p-3.5 rounded-xl border border-stone-100">
              <span className="text-stone-600 font-medium">Maksimal Booking Custom Pending</span>
              <span className="font-bold text-stone-900 bg-stone-100 px-3 py-1 rounded-lg">2 Pesanan (Anti-PHP)</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
