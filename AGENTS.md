# AGENTS.md - Panduan & Aturan Pengembangan Sistem Booking Tarling / Artis

> Panduan ini wajib dipatuhi oleh setiap AI Agent / Developer saat membuat kode untuk proyek **TarlingBook** (Marketplace Booking Hiburan Pantura).
> Dokumen referensi bisnis utama: `prd.md`.

---

## 1. Peran & Domain Proyek
- **Aplikasi:** Marketplace booking seni pertunjukan Sandiwara Tarling, dangdut, organ tunggal Indramayu-Cirebon.
- **Model:** Marketplace lapak mandiri (bukan agensi monopoli). Pembayaran semi-otomatis: DP online via Payment Gateway (Midtrans/Xendit), pelunasan cash di lokasi.
- **Jalur Booking:** Dual-path (Instant Booking mirip Traveloka 80% + Custom Nego max 3 ronde 20%).
- **Platform:**
  - Mobile App: Flutter (Customer + Pemilik Grup + Admin Pasar dalam satu app, multi-role via tab khusus).
  - Backend & Database: **Supabase** (PostgreSQL 15 + Supabase Auth + Edge Functions Deno/TypeScript + Storage + Realtime). Tanpa deploy VPS server sendiri.
  - Web Admin: Supabase Dashboard + lightweight Next.js / Flutter Web untuk pantau pasar & payout.

---

## 2. Pemetaan Skill & Konvensi

Gunakan keahlian / skill berikut saat mengerjakan modul terkait:

| Modul / Pekerjaan | Skill Terkait | Standar & Fokus Utama |
|---|---|---|
| **Mobile App (Frontend)** | `flutter-expert`, `mobile-developer`, `dart` | Flutter 3.x, Riverpod / Bloc untuk State Management, Clean Architecture, responsive UI, offline cache E-Voucher. |
| **Desain Antarmuka & Interaksi** | `ui-ux-pro-max`, `mobile-design`, `baseline-ui` | Desain bersih, kontras ramah orang tua/desa, form bertahap (Dropdown Kecamatan > Pin Peta), floating CS bot. |
| **Backend API & Service** | `backend-architect`, `nodejs-backend-patterns`, `typescript-pro` | Supabase Edge Functions (Deno/TypeScript), Zod validation, function per domain (create-booking, webhook, payout, bot). |
| **Database & Migrasi** | `postgresql-optimization`, `database-design` | Skema PostgreSQL sesuai `prd.md`, UUID v4 PK, timezone UTC, indexing komposit, transactional lock anti double-booking. |
| **Standar Kode & Refactoring** | `clean-code`, `uncle-bob-craft`, `andrej-karpathy` | SOLID principles, KISS, DRY, jangan overengineering, nama variabel ekspresif, fungsi kecil single-responsibility. |
| **Pengujian & QA** | `tdd-workflow`, `unit-testing-test-generate` | TDD untuk logic kritis (perhitungan jarak Haversine, DP 20%, fee 8%, limit pending max 2, expired ronde 12 jam). |
| **Keamanan & Pembayaran** | `backend-security-coder`, `payment-integration` | Idempotency key di webhook pembayaran, masking no HP anti-bocor WA, verifikasi signature webhook Midtrans/Xendit. |

---

## 3. Aturan Arsitektur & Struktur Folder

### 3.1 Flutter Mobile (`/mobile`)
Menggunakan **Feature-First Clean Architecture**:
```
lib/
├── core/
│   ├── network/        # Dio client, interceptor, error handler
│   ├── theme/          # Warna, tipografi, tema terang/gelap
│   ├── utils/          # Haversine distance, currency formatter (Rp)
│   └── widgets/        # Tombol utama, input field, modal, dialog
├── features/
│   ├── auth/           # Login OTP, Register Grup/Customer
│   ├── catalog/        # List grup, filter tanggal/kota/budget, detail lapak
│   ├── booking/        # Instant booking, custom nego, konfirmasi cash
│   ├── voucher/        # Tampilan QR E-Voucher (bisa dibuka offline)
│   ├── payment/        # Snap webview, status DP
│   ├── chat_bot/       # Floating in-app CS bot (FAQ, komplain, asisten gaptek)
│   └── profile_group/  # Manajemen lapak grup (paket, harga zona, kalender block)
└── main.dart
```

### 3.2 Backend Supabase (`/supabase`)
Menggunakan **Supabase Functions & Migrations**:
```
supabase/
├── migrations/         # PostgreSQL schema, RLS policies, triggers, DDL
└── functions/          # Edge Functions (Deno/TypeScript)
    ├── _shared/        # Supabase client, auth helpers, response formatter
    ├── create-booking/ # Lock tanggal pakai transaction, hitung zona
    ├── midtrans-hook/  # Webhook payment Midtrans (verify signature, idempotent)
    ├── payout-auto/    # Panggil Xendit/Flip Disbursement API H+2
    ├── expire-worker/  # Scheduled cron: expire invoice, hold, custom offer
    └── bot-engine/     # Logic CS bot in-app (FAQ, sengketa, asisten gaptek)
```

---

## 4. Aturan Kritis Bisnis (DOs & DON'Ts)

### Kategori Booking & Tanggal
- **DO:** Pastikan 1 grup hanya punya 1 job per tanggal (fullday mutlak). Gunakan constraint unik pada database `(artist_id, event_date)` untuk booking berstatus aktif (`DP_PAID`, `PARTIAL_PAID`, `FULL_PAID`, `ONGOING`).
- **DO:** Hitung jarak dari base markas grup (`base_lat`, `base_lng`) ke titik hajatan customer (`venue_lat`, `venue_lng`) memakai rumus Haversine untuk memetakan tambahan biaya zona secara otomatis.
- **DON'T:** Jangan mengunci tanggal secara global se-kabupaten. Grup lain di tanggal yang sama wajib tetap berstatus hijau (tersedia).

### Kategori Pembayaran & Payout
- **DO:** Webhook pembayaran DP **wajib idempotent** berdasarkan `gateway_trx_id`. Mencegah double update jika webhook terpanggil berulang.
- **DO:** Payout sisa DP (setelah dipotong fee lapak 8%) dilakukan otomatis via API Disbursement pada H+2 setelah acara berstatus `COMPLETED`.
- **DON'T:** Jangan biarkan uang pelunasan tunai (cash di lapangan) masuk ke rekening platform. Pelunasan cash diserahkan langsung di tempat dan dicatat via tombol konfirmasi dua sisi + foto kwitansi.

### Anti-Bocor & Perlindungan Platform
- **DO:** Masking / sensor nomor HP grup (`0812-****-**78`) sebelum customer melunasi DP 20%. Tampilkan nomor asli hanya setelah status booking menjadi `DP_PAID`.
- **DO:** Batasi maksimal 2 pemesanan kustom (`custom`) berstatus `PENDING` aktif per customer untuk mencegah pemblokiran kalender palsu (PHP).

### CS Bot In-App
- **DO:** CS Bot wajib berjalan sepenuhnya di dalam aplikasi (in-app floating chat), bukan di WhatsApp.
- **DO:** Bot harus mampu menangani 3 skenario: FAQ otomatis, form intake sengketa (buat record `disputes` & kunci payout), dan asisten pimpinan grup (perintah teks sederhana seperti *"liburkan tanggal 20"*).

---

## 5. Standar Penulisan Kode (Clean Code)

1. **Prinsip Terse & Efisien:** Kode harus bebas dari komentar basa-basi. Tulis self-documenting code dengan penamaan fungsi dan variabel yang jelas.
2. **Penanganan Error:** Selalu gunakan format error JSON standar pada API:
   ```json
   {
     "statusCode": 409,
     "message": "Grup sudah memiliki jadwal manggung pada tanggal tersebut",
     "error": "Conflict"
   }
   ```
3. **Format Mata Uang & Waktu:**
   - Semua nominal uang disimpan dalam bentuk `INTEGER` (Rupiah murni, tanpa desimal).
   - Semua tanggal dan waktu disimpan di database dalam format `TIMESTAMPTZ` (UTC). Konversi ke WIB (UTC+7) hanya dilakukan pada layer presentasi UI.
4. **Validasi Input:** Seluruh endpoint penerima data wajib memvalidasi schema (DTO di NestJS / Model form di Flutter) sebelum menyentuh service/database.
