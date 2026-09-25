"use client";

import React, { useState } from "react";
import { FileCode2, Play, Check, Copy } from "lucide-react";

interface EndpointSpec {
  method: "GET" | "POST";
  path: string;
  desc: string;
  sampleBody?: string;
}

const ENDPOINTS: EndpointSpec[] = [
  {
    method: "GET",
    path: "/api/v1/catalog",
    desc: "Mendapatkan daftar grup seni pantura terverifikasi dengan nomor HP tersensor (0812-****-**78).",
  },
  {
    method: "GET",
    path: "/api/v1/catalog/a1111111-1111-4111-a111-111111111111",
    desc: "Mendapatkan rincian profil artis dan paket manggung lengkap.",
  },
  {
    method: "POST",
    path: "/api/v1/bookings",
    desc: "Membuat booking baru dengan hitung jarak Haversine, penentuan zona, DP 20%, dan anti double-booking.",
    sampleBody: JSON.stringify(
      {
        customer_id: "user-bu-hajat-1",
        artist_id: "a1111111-1111-4111-a111-111111111111",
        package_id: "p1",
        event_date: "2026-11-28",
        venue_address: "Desa Eretan Kulon, Kandanghaur",
        city: "Indramayu",
        district: "Kandanghaur",
        venue_lat: -6.3501,
        venue_lng: 108.1302,
        booking_type: "instant",
      },
      null,
      2
    ),
  },
  {
    method: "POST",
    path: "/api/v1/bot",
    desc: "CS Bot in-app FAQ menjawab pertanyaan DP, Reschedule, Payout H+2, atau Pelunasan Cash.",
    sampleBody: JSON.stringify({ query: "Kapan uang payout ditransfer?" }, null, 2),
  },
  {
    method: "POST",
    path: "/api/v1/webhooks/midtrans",
    desc: "Webhook Midtrans idempotent untuk mengubah status booking menjadi DP_PAID.",
    sampleBody: JSON.stringify(
      {
        order_id: "TRG-2026-0041",
        transaction_status: "settlement",
        gross_amount: "6000000",
      },
      null,
      2
    ),
  },
  {
    method: "GET",
    path: "/api/v1/admin/stats",
    desc: "Ringkasan metrik pasar (GMV, booking aktif, fee 8%, sengketa).",
  },
];

export default function ApiDocsPage() {
  const [selectedEndpoint, setSelectedEndpoint] = useState<EndpointSpec>(ENDPOINTS[0]);
  const [responseJson, setResponseJson] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleTest = async () => {
    setLoading(true);
    setResponseJson(null);
    try {
      const opts: RequestInit = {
        method: selectedEndpoint.method,
        headers: { "Content-Type": "application/json" },
      };
      if (selectedEndpoint.method === "POST" && selectedEndpoint.sampleBody) {
        opts.body = selectedEndpoint.sampleBody;
      }
      const res = await fetch(selectedEndpoint.path, opts);
      const data = await res.json();
      setResponseJson(JSON.stringify(data, null, 2));
    } catch (err: unknown) {
      setResponseJson(
        JSON.stringify({ error: err instanceof Error ? err.message : "Request failed" }, null, 2)
      );
    } finally {
      setLoading(false);
    }
  };

  const copyResponse = () => {
    if (!responseJson) return;
    navigator.clipboard.writeText(responseJson);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-stone-900 flex items-center gap-2">
          <FileCode2 className="w-7 h-7 text-[#BD4024]" />
          Tarlink REST API Console & Dokumentasi
        </h2>
        <p className="text-xs text-stone-500 mt-1">
          Konsol interaktif pengujian endpoint REST API v1 yang digunakan oleh Mobile App Flutter dan Web Admin.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Endpoint List */}
        <div className="space-y-2">
          {ENDPOINTS.map((ep, idx) => (
            <div
              key={idx}
              onClick={() => {
                setSelectedEndpoint(ep);
                setResponseJson(null);
              }}
              className={`p-3.5 rounded-xl border cursor-pointer transition-all ${
                selectedEndpoint.path === ep.path && selectedEndpoint.method === ep.method
                  ? "bg-white border-[#BD4024] shadow-sm ring-1 ring-[#BD4024]/20"
                  : "bg-white/60 hover:bg-white border-stone-200"
              }`}
            >
              <div className="flex items-center gap-2">
                <span
                  className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                    ep.method === "GET"
                      ? "bg-emerald-100 text-emerald-800"
                      : "bg-blue-100 text-blue-800"
                  }`}
                >
                  {ep.method}
                </span>
                <span className="font-mono text-xs font-semibold text-stone-900 truncate">
                  {ep.path}
                </span>
              </div>
              <p className="text-[11px] text-stone-500 mt-1.5 line-clamp-2">{ep.desc}</p>
            </div>
          ))}
        </div>

        {/* Request & Response Workbench */}
        <div className="lg:col-span-2 space-y-4">
          <div className="p-6 rounded-2xl bg-white border border-stone-200 shadow-sm space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span
                  className={`text-xs font-bold px-2.5 py-1 rounded-md ${
                    selectedEndpoint.method === "GET"
                      ? "bg-emerald-100 text-emerald-800"
                      : "bg-blue-100 text-blue-800"
                  }`}
                >
                  {selectedEndpoint.method}
                </span>
                <span className="font-mono text-sm font-bold text-stone-900">
                  {selectedEndpoint.path}
                </span>
              </div>
              <button
                disabled={loading}
                onClick={handleTest}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-[#BD4024] hover:bg-[#9B280E] text-white text-xs font-bold shadow-sm transition-colors disabled:opacity-50"
              >
                <Play className="w-3.5 h-3.5 fill-current" />
                <span>{loading ? "Mengirim..." : "Jalankan Request"}</span>
              </button>
            </div>

            <p className="text-xs text-stone-600">{selectedEndpoint.desc}</p>

            {selectedEndpoint.sampleBody && (
              <div className="space-y-1.5">
                <span className="text-xs font-bold text-stone-700">Payload JSON:</span>
                <pre className="p-3 rounded-xl bg-stone-900 text-stone-100 font-mono text-xs overflow-x-auto">
                  {selectedEndpoint.sampleBody}
                </pre>
              </div>
            )}
          </div>

          {/* Response Viewer */}
          <div className="p-6 rounded-2xl bg-[#191C21] text-white shadow-sm space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-stone-300 font-mono">Response Payload (JSON)</span>
              {responseJson && (
                <button
                  onClick={copyResponse}
                  className="inline-flex items-center gap-1 text-xs text-stone-400 hover:text-white"
                >
                  {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                  <span>{copied ? "Tersalin!" : "Salin JSON"}</span>
                </button>
              )}
            </div>

            <div className="min-h-[220px] max-h-[400px] overflow-y-auto font-mono text-xs text-emerald-400 p-3 rounded-xl bg-black/40 border border-white/5">
              {loading ? (
                <span className="text-stone-500 italic">Mengirim request ke server...</span>
              ) : responseJson ? (
                <pre>{responseJson}</pre>
              ) : (
                <span className="text-stone-500 italic">
                  Klik &apos;Jalankan Request&apos; untuk melihat balikan real-time dari backend REST API.
                </span>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
