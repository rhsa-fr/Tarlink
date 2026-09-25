"use client";

import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  ShieldCheck,
  Wallet,
  AlertTriangle,
  MapPin,
  FileCode2,
  Menu,
  X,
  ExternalLink,
  ChevronRight,
  Bell,
  Sparkles,
} from "lucide-react";

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: string;
}

const NAV_ITEMS: NavItem[] = [
  { label: "Dashboard Pasar", href: "/admin", icon: LayoutDashboard },
  { label: "Verifikasi Seniman", href: "/admin/verifikasi", icon: ShieldCheck, badge: "1" },
  { label: "Antrean Payout H+2", href: "/admin/payouts", icon: Wallet, badge: "READY" },
  { label: "Pusat Sengketa", href: "/admin/disputes", icon: AlertTriangle, badge: "1" },
  { label: "Master Wilayah & Tarif", href: "/admin/master-data", icon: MapPin },
  { label: "API Test Console", href: "/admin/api-docs", icon: FileCode2 },
];

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen flex bg-[#F9F8F6]">
      {/* Mobile backdrop */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed lg:static inset-y-0 left-0 z-50 w-72 bg-[#191C21] text-white flex flex-col transition-transform duration-300 ${
          sidebarOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
        }`}
      >
        {/* Brand Header */}
        <div className="p-6 border-b border-white/10 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#BD4024] flex items-center justify-center font-bold text-white shadow-lg shadow-[#BD4024]/30 text-lg">
              TL
            </div>
            <div>
              <h1 className="font-bold text-lg tracking-tight text-white flex items-center gap-2">
                Tarlink <span className="text-xs px-2 py-0.5 rounded bg-[#D4A017]/20 text-[#D4A017] font-medium border border-[#D4A017]/30">Admin</span>
              </h1>
              <p className="text-xs text-stone-400">Pasar Seni Budaya Pantura</p>
            </div>
          </div>
          <button
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden text-stone-400 hover:text-white"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Backend Status Card */}
        <div className="mx-4 my-4 p-3.5 rounded-xl bg-white/5 border border-white/10 text-xs">
          <div className="flex items-center justify-between mb-1.5">
            <span className="text-stone-400 flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              REST API Server
            </span>
            <span className="font-mono text-emerald-400 font-semibold">v1 Online</span>
          </div>
          <p className="text-stone-400 text-[11px] leading-relaxed">
            Menghubungkan Mobile Flutter & Web Admin tanpa direct Supabase SDK.
          </p>
        </div>

        {/* Navigation Menu */}
        <nav className="flex-1 px-3 py-2 space-y-1 overflow-y-auto">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setSidebarOpen(false)}
                className={`flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? "bg-[#BD4024] text-white shadow-md shadow-[#BD4024]/20"
                    : "text-stone-300 hover:bg-white/5 hover:text-white"
                }`}
              >
                <div className="flex items-center gap-3">
                  <Icon className={`w-5 h-5 ${isActive ? "text-white" : "text-stone-400"}`} />
                  <span>{item.label}</span>
                </div>
                {item.badge && (
                  <span
                    className={`text-[11px] px-2 py-0.5 rounded-full font-semibold ${
                      isActive
                        ? "bg-white/20 text-white"
                        : "bg-[#D4A017]/20 text-[#D4A017] border border-[#D4A017]/30"
                    }`}
                  >
                    {item.badge}
                  </span>
                )}
              </Link>
            );
          })}
        </nav>

        {/* User Footer */}
        <div className="p-4 border-t border-white/10 bg-white/[0.02]">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-gradient-to-tr from-[#D4A017] to-[#BD4024] flex items-center justify-center font-bold text-white text-sm">
              AP
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold text-white truncate">Admin Pasar Pantura</p>
              <p className="text-xs text-stone-400 truncate">Indramayu & Cirebon</p>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Topbar Header */}
        <header className="h-16 border-b border-stone-200 bg-white sticky top-0 z-30 px-4 lg:px-8 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setSidebarOpen(true)}
              className="lg:hidden p-2 rounded-lg text-stone-600 hover:bg-stone-100"
            >
              <Menu className="w-6 h-6" />
            </button>
            <div className="hidden sm:flex items-center gap-2 text-xs text-stone-500 font-medium">
              <span>Tarlink Admin</span>
              <ChevronRight className="w-3.5 h-3.5 text-stone-400" />
              <span className="text-stone-900 font-semibold">Pusat Komando Pasar</span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-50 border border-amber-200 text-[#795900] text-xs font-medium">
              <Sparkles className="w-3.5 h-3.5 text-[#D4A017]" />
              <span>Pantura Regional Ops (WIB UTC+7)</span>
            </div>
            <a
              href="/api/v1/catalog"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-stone-200 hover:border-stone-300 text-xs font-semibold text-stone-700 hover:bg-stone-50 transition-colors"
            >
              <span>Test API</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </a>
          </div>
        </header>

        {/* Page Body */}
        <main className="flex-1 p-4 lg:p-8 max-w-7xl w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
