import Link from "next/link";
import {
  ShieldCheck,
  LayoutDashboard,
  Server,
  ArrowRight,
  Smartphone,
  Music,
  CheckCircle2,
  Sparkles,
} from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-[#F9F8F6] text-[#191C21] flex flex-col justify-between">
      {/* Header */}
      <header className="border-b border-stone-200 bg-white/80 backdrop-blur sticky top-0 z-20">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#BD4024] text-white flex items-center justify-center font-bold text-lg shadow-md shadow-[#BD4024]/20">
              TL
            </div>
            <div>
              <h1 className="font-bold text-base tracking-tight text-stone-900">
                Tarlink Pantura
              </h1>
              <p className="text-[11px] text-stone-500">Unified Backend & Admin Portal</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              API Server Online
            </span>
            <Link
              href="/admin"
              className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#BD4024] hover:bg-[#9B280E] text-white text-xs font-bold shadow-sm transition-colors"
            >
              <span>Buka Admin Portal</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="max-w-6xl mx-auto px-6 py-12 lg:py-20 flex-1 w-full space-y-12">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-[#D4A017]/15 border border-[#D4A017]/30 text-[#795900] text-xs font-semibold">
            <Sparkles className="w-3.5 h-3.5 text-[#D4A017]" />
            <span>Arsitektur Ramping 2-Tier: Next.js + Flutter</span>
          </div>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-stone-900 leading-tight">
            Pusat Komando & Backend API <br />
            <span className="text-[#BD4024]">Tarlink Pasar Pantura</span>
          </h2>
          <p className="text-stone-600 text-sm sm:text-base leading-relaxed">
            Menghilangkan beban 3 stack terpisah. Backend REST API untuk mobile Flutter dan antarmuka Web Admin disatukan dalam satu server Next.js yang terhubung aman ke database.
          </p>
          <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/admin"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-[#BD4024] hover:bg-[#9B280E] text-white font-bold text-sm shadow-md transition-all"
            >
              <LayoutDashboard className="w-4 h-4" />
              <span>Masuk ke Dashboard Admin</span>
            </Link>
            <Link
              href="/admin/api-docs"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl border border-stone-300 hover:bg-stone-100 font-bold text-sm text-stone-800 transition-all"
            >
              <Server className="w-4 h-4 text-stone-500" />
              <span>API Test Console</span>
            </Link>
          </div>
        </div>

        {/* 3 Pillars Bento */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#BD4024]/10 text-[#BD4024] flex items-center justify-center">
              <Smartphone className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-stone-900">Mobile Tanpa Direct Supabase</h3>
            <p className="text-xs text-stone-500 leading-relaxed">
              Aplikasi Flutter berkomunikasi murni via HTTP REST API (`/api/v1/catalog`, `/api/v1/bookings`). Nomor kontak grup tersensor otomatis anti bocor platform.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#D4A017]/15 text-[#795900] flex items-center justify-center">
              <Server className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-stone-900">Server Backend Terpusat</h3>
            <p className="text-xs text-stone-500 leading-relaxed">
              Logika kritis dijalankan di server: rumus Haversine jarak markas ke venue, penguncian fullday mutlak, DP 20%, fee platform 8%, dan limit 2 booking kustom.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-white border border-stone-200/80 shadow-sm space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#2D6A4F]/10 text-[#2D6A4F] flex items-center justify-center">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-stone-900">Web Admin Lengkap</h3>
            <p className="text-xs text-stone-500 leading-relaxed">
              Dashboard Admin Pasar siap pakai: Verifikasi KTP pimpinan grup, antrean pencairan dana H+2 (Xendit/Disbursement), pusat mediasi sengketa, dan master wilayah.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-stone-200 bg-white py-6">
        <div className="max-w-6xl mx-auto px-6 text-center text-xs text-stone-500">
          Tarlink • Platform Marketplace Digital Seni Pertunjukan Pantura (Indramayu & Cirebon) &copy; 2026
        </div>
      </footer>
    </div>
  );
}
