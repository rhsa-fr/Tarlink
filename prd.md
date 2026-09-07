# PRD Final - Lapak Marketplace Sandiwara & Tarling Indramayu-Cirebon (Hybrid Traveloka)

> Versi: 5.0 HYBRID | 2026-09-07 | Model: Lapak + Instant Booking (default) + Nego Khusus (opsional)

---

## 1. Pemahaman Final

Di Indramayu-Cirebon ada **puluhan grup** Sandiwara & Tarling. Aplikasi **BUKAN agensi, BUKAN bos**. Aplikasi cuma tanah lapak kayak pasar / Shopee.

**Kita tidak tahu-menahu dan tidak ikut campur:**
- Grup mau tampilkan drama apa, biduan siapa, alat apa, gaya apa — bebas.
- Harga berapa, paket apa, syarat apa — grup yang isi sendiri.
- Isi acara H-H — urusan grup + sohibul hajat.

**Kita cuma sediakan:**
1. Etalase tiap grup (toko sendiri)
2. Pencarian lintas grup by tanggal/kota/budget
3. Booking + nego + chat tercatat
4. Kunci tanggal biar tidak bentrok
5. DP tercatat + fee lapak otomatis
6. Rating biar grup bagus naik sendiri

Admin cuma tukang jaga pasar: verifikasi KTP biar bukan akun palsu, hapus lapak nipu, bantu sengketa. Tidak atur harga, tidak assign kru, tidak carikan pengganti.

---

## 2. Peran (Semua di 1 Aplikasi Flutter)

Satu aplikasi Flutter menangani 3 role berdasarkan status akun:
- **Customer (Bu Hajat):** cari, bandingkan 20 grup, booking, nego, bayar DP online, bayar sisa cash di lokasi, konfirmasi lunas, rating.
- **Pemilik Grup (Pimpinan):** buka lapak, isi profil bebas (nama sanggar, alamat, foto panggung asli, video YouTube/TikTok bebas), bikin paket bebas (nama/harga/keterangan bebas), isi tanggal kosong sendiri, balas nego, klik Mulai/Selesai, terima transfer fee.
- **Admin Pasar (Akun Khusus role='admin'):** jika login pakai akun admin, muncul tab tambahan di pojok kanan bawah **"Panel Pasar"**:
  - Menu Verifikasi KTP (lihat foto KTP + foto panggung, tombol Terima / Tolak).
  - Menu Sengketa / Komplain (tiket dari bot, lihat bukti foto/video, tombol Refund ke Customer / Cairkan ke Grup).
  - Menu Payout Monitoring (daftar transfer gagal / FAILED, tombol Retry).
  - Menu Lapak & Suspend (daftar semua grup, tombol Blokir jika curang).

Satu HP bisa beralih mode via menu profil: "Beralih ke Mode Grup" atau "Beralih ke Panel Admin" (hanya untuk akun admin).

---

## 3. Alur Booking (Dua Jalur)

### Shift = Fullday (disepakati)
Hajatan selalu fullday (siang sampai malam). Shift siang/malam dihapus. Kalender cuma ijo (kosong) / merah (booked) per tanggal per grup. Tidak ada split shift. Constraint: `UNIQUE(artist_id, event_date)`.

### Jalur A: Instant Booking (Default - Gaya Traveloka, 80% Transaksi)
> Cocok untuk hajatan standar tanpa request aneh-aneh. Cepat, pasti, tanpa nunggu.

1. **Cari:** Bu Tari cari `Tarling Indramayu 18 Zulhijah <15jt` → muncul daftar lapak dengan status tanggal ijo.
2. **Pilih:** Buka Grup X → pilih paket `Organ Fullday Rp12jt`.
3. **Lokasi:** Dropdown Kabupaten Indramayu > Kec. Kandanghaur + pin Maps ke rumah. Sistem hitung jarak dari base grup → otomatis tambah ongkir zona (misal +Rp500rb). Total langsung fix: `Rp12,5jt`.
4. **Grup approve atau auto-accept:**
   - Grup setting `auto_accept = true` (rajin update kalender) → langsung ke step 5.
   - Grup setting `auto_accept = false` (default untuk grup baru) → grup punya 12 jam untuk Terima/Tolak. Kalau terima atau timeout tanpa tolak → lanjut step 5.
5. **Bayar DP Instan:** Bu Tari klik `Pesan Sekarang` → muncul invoice `DP 20% = Rp2,5jt` (bayar dalam 30 menit).
6. **Kunci Otomatis:** Begitu QRIS/VA terbayar:
   - Tanggal 18 Grup X otomatis merah (grup lain tidak terpengaruh).
   - **E-Voucher** terbit: Kode Booking (TRG-2026-0042), QR code, nama grup, tanggal, alamat, zona, total harga. QR bisa di-scan pimpinan grup di HP untuk validasi H-H.
   - Nomor telepon pimpinan grup BARU terbuka untuk koordinasi teknis (anti-bocor).
7. **Hari H:** Pimpinan scan QR voucher di HP → status ONGOING. Sisa Rp10jt dibayar cash di lokasi. Pimpinan & customer klik `Konfirmasi Lunas` + foto kwitansi.
8. **Pencairan:** H+2 sistem otomatis transfer sisa DP (setelah potong fee lapak 8%) ke rekening grup via API. Jika transfer gagal → status FAILED + notif perbaiki rekening + retry 3x otomatis.

---

### Jalur B: Penawaran Khusus (Opsional - Untuk Request Custom, 20% Transaksi)
> Cocok jika butuh drama khusus, tambah biduan, lembur jam, atau paket non-standar.

1. Di halaman paket ada tombol: `Minta Penawaran Khusus`.
2. Bu Tari isi: tanggal, lokasi (dropdown + pin), detail request (misal: "minta biduan Siti + main sampai jam 02.00 subuh"), tawaran harga: `Rp14jt`.
3. Pimpinan grup dapat notif → punya waktu 12 jam untuk: **Terima**, **Tolak**, atau **Ajukan Harga Balasan** (misal: `Rp15jt`).
4. Maksimal 3 ronde tawar-menawar. Tiap ronde ada batas waktu 12 jam (anti-PHP kalender gantung).
5. Begitu kedua belah pihak sepakat → harga ter-LOCK → kembali ke alur Jalur A step 5 (Bayar DP 20% → Kunci Tanggal → E-Voucher).

### Anti-PHP Booking (WAJIB)
- Max **2 booking custom PENDING** aktif per customer. Mau bikin ke-3 → harus batalkan salah satu atau tunggu expired.
- Booking custom yang tidak ada aktivitas 24 jam → auto-EXPIRED, kalender grup dibuka lagi.
- Instant booking (Jalur A) tidak kena limit karena langsung bayar.
- Customer yang 3x expired berturut-turut → cooldown 7 hari tidak bisa booking custom (instant tetap bisa).

---

### Reschedule (Beda Aturan Per Jalur)
- **Instant (sudah DP + voucher):** Reschedule H-7, fee 10% dari total, tanggal baru wajib ijo. Voucher lama hangus, terbit baru.
- **Custom (belum lock/bayar):** Bebas ubah tanggal selama masih nego. Setelah lock + DP → ikut aturan instant.

---

## 4. Sistem Bayar Semi-Otomatis (yang disepakati)

**Prinsip: yang bisa online diotomatiskan, yang cash dicatat.**

### Otomatis 100% (tanpa orang):
- **Jalur A (Instant):** Bayar DP langsung setelah klik pesan. Tidak perlu nunggu siapapun. Invoice expired 30 menit. Webhook verify signature → kunci tanggal per grup (artist_id + tanggal + shift). Grup lain tidak terpengaruh.
- **Jalur B (Custom):** Bayar DP setelah harga LOCK. Invoice expired 24 jam. Sama prosesnya.
- Hitung fee 8% otomatis. Payout ke grup otomatis via Xendit Disbursement / Flip API H+2. Worker retry kalau bank gangguan.
- Auto-complete H+1 jika kedua sisi sudah klik selesai.

### Manual (wajib karena budaya):
- Pelunasan cash di lokasi → wajib klik konfirmasi dua sisi + foto. Sistem yang ubah status.
- Verifikasi KTP pertama kali → orang lihat sekali.

### Anti-Bocor WA (WAJIB):
- Nomor HP pimpinan grup **disensor/masked** sebelum DP masuk. Tampil: `0812-****-**78`.
- Begitu DP masuk → nomor baru terbuka + chat per booking aktif.
- Semua komunikasi teknis via chat di aplikasi atau tombol `Telepon via App` (relay).
- Grup yang ajak transaksi di luar + terbukti 2x = turun rating + suspend.

---

## 5. Katalog Bebas (Lapak Sendiri) + Alamat Zona

Tabel `packages` sengaja bebas:
- `name` bebas: `Sandiwara Full 2 Malam`, `Tarling + Lawak Saja`, `Nebeng 2 Jam`
- `price` bebas, `includes` text bebas, `duration` bebas
- `portfolios` bebas: foto/video/audio URL bebas
- `artist_profiles.description` bebas, bahasa Dermayon/Cirebon boleh

Wajib diisi grup: base_city, coverage_cities, price_min/max (untuk filter), blocked_dates (tanggal off diisi sendiri).

### 5.1 Penentuan Alamat (Dropdown + Pin Maps - disepakati)
1. Customer pilih **Kabupaten > Kecamatan** dari dropdown (master `districts`). Ini tentukan **zona harga** + ongkir/transport otomatis.
2. Customer **geser pin di Maps** ke titik rumah/tenda. Sistem auto-isi `lat, lng, alamat_detail, maps_url`.
3. Sistem hitung jarak dari base grup (`base_lat/lng` dari `artist_profiles`) via Haversine → tampilkan estimasi transport + zona (Ring 1/2/3) **langsung di halaman checkout**.
4. Grup set `zone_prices` per paket: misal Ring 1 (≤10km) +0, Ring 2 (≤30km) +500rb, luar kabupaten +1jt.

Filter customer: tanggal tersedia (cek blocked + booking aktif), kota/kecamatan, budget_max, kategori (sandiwara-full, tarling-dangdut, organ-tunggal, biduan-solo, mc), rating, badge verified.

---

## 6. Functional Requirements (MVP Lapak)

F-01 Auth HP+OTP, Google, JWT+refresh, multi-role.
F-02 Toko grup: CRUD profil + base markas (kecamatan + pin), setting auto_accept, paket bebas, portofolio bebas, kalender block per tanggal (fullday).
F-03 Search lintas grup + detail + kalender 90 hari (ijo/merah per tanggal).
F-04 Jalur A instant: pilih paket + lokasi (dropdown + pin) → harga zona fix → bayar DP langsung (atau tunggu approve 12 jam jika grup need_approve).
F-05 Jalur B custom: tombol Minta Penawaran Khusus → nego max 3 ronde (tiap ronde expired 12 jam) + chat per booking → lock → bayar DP. Max 2 custom PENDING per customer, idle 24 jam auto-expire, 3x expired = cooldown 7 hari.
F-06 Invoice DP 20% + webhook idempotent + E-Voucher QR (kode, grup, tanggal, alamat, zona) + scan validasi H-H di HP grup.
F-07 Reschedule beda aturan: instant (sudah DP) = H-7 + fee 10% + voucher baru; custom (belum lock) = bebas ubah. Cancel: H-14 refund 50% DP, H-7 hangus. Refund + disputes table, payout di-lock selama sengketa.
F-08 Payout auto via disbursement API H+2, status FAILED + retry 3x + notif perbaiki rekening.
F-09 Rating 1 booking 1 review.
F-10 Notif FCM+WA.
F-11 CS Bot Multi-Fungsi (lihat section 6.1).
F-12 Admin pasar: verifikasi, blokir, laporan omzet fee, monitor payout + eskalasi tiket bot sengketa.

### 6.1 CS Bot (In-App Chat Only)

Bot hidup di dalam aplikasi saja (bukan WA). Tombol chat ada di setiap layar: floating icon pojok kanan bawah. Bot jalan 24/7, tidak perlu orang kecuali eskalasi. 3 mode:

**Mode 1: FAQ & Panduan (Customer + Grup)**
Trigger: customer/grup ketuk tombol chat bot di aplikasi → ketik pertanyaan bebas.
Contoh percakapan:
- "Cara bayar DP gimana?" → Bot jawab step by step + deeplink ke halaman bayar.
- "Kapan uang cair?" → Bot cek `payouts` by user → "Job TRG-2026-0042 sudah COMPLETED, dana Rp11,5jt akan cair H+2 (20 Zulhijah) ke BRI ***456."
- "Cara reschedule?" → Bot jawab aturan (H-7, fee 10%) + tombol langsung ke form reschedule.
- "Status booking saya?" → Bot tampilkan timeline booking aktif.
Sumber jawaban: tabel `bot_faq_templates` (keyword → jawaban template). Fallback: "Maaf belum paham, saya sambungkan ke admin ya" → buat tiket eskalasi ke admin di dashboard.

**Mode 2: Intake Sengketa (Mediasi Otomatis)**
Trigger: customer ketuk `Lapor Masalah` di detail booking atau ketik "komplain" / "grup tidak datang" / "sound jelek" di chat bot.
Alur:
1. Bot tanya: "Masalah apa? (1) Grup tidak datang (2) Kualitas buruk (3) Pelunasan bermasalah (4) Lainnya"
2. Customer pilih → bot minta bukti: "Kirim foto/video sebagai bukti ya" (upload di app)
3. Bot minta kronologi: "Ceritakan singkat apa yang terjadi"
4. Bot otomatis buat record di `disputes` (booking_id, reporter_id, reason, evidence_urls, status='open')
5. Bot otomatis lock `payouts` booking ini → status DISPUTED (dana tidak cair selama sengketa)
6. Push notif ke admin dashboard: "Tiket sengketa baru TRG-2026-0042, butuh putusan dalam 3 hari"
7. Push notif ke grup di app: "Ada laporan dari customer, mohon tanggapi dalam 24 jam dengan bukti"
8. Admin putuskan di dashboard → bot kirim hasil ke dua belah pihak via in-app notif

**Mode 3: Asisten Pimpinan Gaptek (In-App Chat Bot)**
Trigger: pimpinan grup buka chat bot di aplikasi → ketik perintah sederhana pakai bahasa sehari-hari.
Perintah yang didukung:
- `"liburkan tanggal 20-25"` → bot konfirmasi: "Block 20, 21, 22, 23, 24, 25? (Ketuk YA)" → insert `blocked_dates` 6 record.
- `"buka tanggal 22"` → delete `blocked_dates` tanggal 22.
- `"cek jadwal"` → bot kirim daftar tanggal merah bulan ini dari `bookings` + `blocked_dates`.
- `"cek saldo"` → bot kirim daftar `payouts` HOLD/READY + total siap cair.
- `"ubah harga Organ jadi 13jt"` → bot cari `packages` by keyword → konfirmasi → update `price`.
- Perintah tidak dikenali → "Maaf belum paham, ketuk BANTUAN untuk lihat daftar perintah"

Semua percakapan bot tersimpan di tabel `bot_conversations` untuk audit + training bot lebih pintar.

---

## 7. Database (PostgreSQL, Lapak, 16 tabel, siap scale)

```
users 1--* artist_profiles 1--* packages, portfolios, blocked_dates
users 1--* bookings *--1 artist_profiles
bookings 1--* booking_items, booking_offers, messages, payments, refunds, histories
bookings 1--1 payouts, reviews
```

DDL inti + semi-auto:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE booking_status AS ENUM ('PENDING','APPROVED','WAITING_DP','DP_PAID','PARTIAL_PAID','FULL_PAID','ONGOING','COMPLETED','CANCELLED','REFUNDED','EXPIRED');
CREATE TYPE pay_status AS ENUM ('PENDING','PAID','FAILED','EXPIRED');

CREATE TABLE users(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), name VARCHAR(100) NOT NULL, phone VARCHAR(20) UNIQUE NOT NULL, email VARCHAR(100) UNIQUE, password_hash TEXT, role VARCHAR(20) DEFAULT 'customer', avatar_url TEXT, is_verified BOOLEAN DEFAULT FALSE, created_at TIMESTAMPTZ DEFAULT now());

CREATE TABLE categories(slug VARCHAR(50) PRIMARY KEY, name VARCHAR(100));
CREATE TABLE cities(name VARCHAR(50) PRIMARY KEY);
CREATE TABLE districts(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), city VARCHAR(50) REFERENCES cities(name), name VARCHAR(100) NOT NULL, UNIQUE(city, name));
CREATE TABLE settings(key VARCHAR(50) PRIMARY KEY, value TEXT);
-- dp_default=20, fee_lapak_pct=8, sla_hours=48, invoice_hours=24

CREATE TABLE artist_profiles(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  display_name VARCHAR(150) NOT NULL, category VARCHAR(50) NOT NULL,
  base_city VARCHAR(50) NOT NULL, base_district VARCHAR(100), base_lat DECIMAL(10,7), base_lng DECIMAL(10,7),
  coverage_cities TEXT[] DEFAULT '{}', description TEXT,
  auto_accept BOOLEAN DEFAULT FALSE, -- true: instant booking langsung bayar, false: grup approve 12 jam dulu
  price_min INT DEFAULT 0, price_max INT DEFAULT 0,
  rating_avg DECIMAL(2,1) DEFAULT 0, total_job INT DEFAULT 0,
  video_urls TEXT[] DEFAULT '{}', status VARCHAR(20) DEFAULT 'pending',
  bank_name VARCHAR(50), bank_no VARCHAR(50), bank_owner VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_artist_search ON artist_profiles(base_city, status, rating_avg);

CREATE TABLE packages(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), artist_id UUID REFERENCES artist_profiles(id) ON DELETE CASCADE, name VARCHAR(150) NOT NULL, duration_hours INT, price INT NOT NULL, includes TEXT, is_active BOOLEAN DEFAULT TRUE);
CREATE TABLE zone_prices(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), package_id UUID REFERENCES packages(id) ON DELETE CASCADE, zone VARCHAR(20) NOT NULL, max_km DECIMAL(6,2), extra_price INT NOT NULL DEFAULT 0, UNIQUE(package_id, zone));
CREATE TABLE portfolios(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), artist_id UUID REFERENCES artist_profiles(id) ON DELETE CASCADE, type VARCHAR(10), url TEXT NOT NULL, title VARCHAR(150));
CREATE TABLE blocked_dates(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), artist_id UUID REFERENCES artist_profiles(id) ON DELETE CASCADE, date DATE NOT NULL, reason TEXT, UNIQUE(artist_id, date));

CREATE TABLE bookings(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), code VARCHAR(20) UNIQUE NOT NULL,
  customer_id UUID REFERENCES users(id), artist_id UUID REFERENCES artist_profiles(id), package_id UUID REFERENCES packages(id),
  event_date DATE NOT NULL, venue_address TEXT NOT NULL, venue_maps_url TEXT, city VARCHAR(50), district VARCHAR(100), venue_lat DECIMAL(10,7), venue_lng DECIMAL(10,7), distance_km DECIMAL(6,2), zone VARCHAR(20),
  total_price INT NOT NULL, final_price INT, locked_at TIMESTAMPTZ,
  dp_percent INT DEFAULT 20, dp_amount INT NOT NULL, remaining_amount INT NOT NULL,
  booking_type VARCHAR(20) DEFAULT 'instant',
  evoucher_code VARCHAR(20) UNIQUE,
  approved_at TIMESTAMPTZ, -- null = belum approve (need_approve grup)
  offer_expires_at TIMESTAMPTZ, expires_at TIMESTAMPTZ,
  cash_received INT DEFAULT 0, cash_proof_url TEXT, cash_confirmed BOOLEAN DEFAULT FALSE,
  status booking_status DEFAULT 'PENDING', note TEXT, cancel_reason TEXT,
  paid_dp_at TIMESTAMPTZ, completed_at TIMESTAMPTZ, created_at TIMESTAMPTZ DEFAULT now()
);
CREATE UNIQUE INDEX uniq_artist_date ON bookings(artist_id, event_date) WHERE status IN ('DP_PAID','PARTIAL_PAID','FULL_PAID','ONGOING');
CREATE INDEX idx_booking_date ON bookings(event_date, status);
CREATE INDEX idx_booking_customer_pending ON bookings(customer_id, status) WHERE booking_type = 'custom' AND status = 'PENDING';

CREATE TABLE booking_offers(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE, offered_by UUID REFERENCES users(id), amount INT NOT NULL, note TEXT, round INT NOT NULL, status VARCHAR(20) DEFAULT 'proposed', expires_at TIMESTAMPTZ, created_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE messages(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE, sender_id UUID REFERENCES users(id), text TEXT NOT NULL, attachment_url TEXT, created_at TIMESTAMPTZ DEFAULT now());
CREATE INDEX idx_msg_booking ON messages(booking_id, created_at);
CREATE TABLE booking_items(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE, label VARCHAR(100), amount INT NOT NULL);
CREATE TABLE booking_status_histories(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE, from_status VARCHAR(20), to_status VARCHAR(20), changed_by UUID, note TEXT, created_at TIMESTAMPTZ DEFAULT now());

CREATE TABLE payments(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE, type VARCHAR(20) NOT NULL, amount INT NOT NULL, method VARCHAR(50), gateway VARCHAR(20), gateway_trx_id VARCHAR(100) UNIQUE, snap_token TEXT, status pay_status DEFAULT 'PENDING', expired_at TIMESTAMPTZ, paid_at TIMESTAMPTZ, raw_callback JSONB, created_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE refunds(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id), payment_id UUID REFERENCES payments(id), amount INT NOT NULL, reason TEXT, status VARCHAR(20) DEFAULT 'pending', approved_by UUID, created_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE disputes(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID REFERENCES bookings(id), reporter_id UUID REFERENCES users(id), reason TEXT NOT NULL, evidence_urls TEXT[], status VARCHAR(20) DEFAULT 'open', verdict TEXT, resolved_by UUID, created_at TIMESTAMPTZ DEFAULT now());

CREATE TABLE payouts(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID UNIQUE REFERENCES bookings(id), artist_id UUID REFERENCES artist_profiles(id), gross INT NOT NULL, fee_pct INT DEFAULT 8, fee INT NOT NULL, net INT NOT NULL, status VARCHAR(20) DEFAULT 'HOLD', disbursement_id VARCHAR(100), disbursement_status VARCHAR(20), transferred_at TIMESTAMPTZ);
CREATE TABLE reviews(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), booking_id UUID UNIQUE REFERENCES bookings(id), customer_id UUID REFERENCES users(id), artist_id UUID REFERENCES artist_profiles(id), rating INT CHECK (rating BETWEEN 1 AND 5), comment TEXT, photos TEXT[], created_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE otps(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), phone VARCHAR(20), code VARCHAR(6), expires_at TIMESTAMPTZ, attempts INT DEFAULT 0);
CREATE TABLE notifications(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES users(id) ON DELETE CASCADE, title VARCHAR(150), body TEXT, type VARCHAR(50), ref_id UUID, is_read BOOLEAN DEFAULT FALSE, created_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE bot_conversations(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES users(id) ON DELETE CASCADE, sender VARCHAR(10) NOT NULL, text TEXT NOT NULL, intent VARCHAR(50), context JSONB, created_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE bot_faq_templates(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), keywords TEXT[] NOT NULL, answer TEXT NOT NULL, is_active BOOLEAN DEFAULT TRUE);
```

---

## 8. Arsitektur (Flutter + Supabase - disepakati)

**Stack: Full Flutter tanpa server sendiri.**

```
[Flutter Mobile App]
  ├─ Auth: Supabase Auth (OTP phone + Google)
  ├─ Data: Supabase Postgres (DDL di dokumen ini langsung dipakai)
  ├─ File: Supabase Storage (foto lapak, KTP, bukti kwitansi, QR voucher offline)
  ├─ Realtime: Supabase Realtime (notif job baru, nego, status DP)
  ├─ Logic: Supabase Edge Functions (Deno/TypeScript) untuk yang tidak bisa di client:
  │    ├─ fn-create-booking (lock tanggal pakai transaction + unique constraint)
  │    ├─ fn-midtrans-webhook (verify signature + update payments idempotent)
  │    ├─ fn-expire-worker (cron: expire invoice 30 mnt, hold 48 jam, offer 12 jam)
  │    ├─ fn-reminder (cron H-3 pelunasan, H-1 acara)
  │    ├─ fn-payout-auto (H+2 panggil Xendit/Flip Disbursement API + retry 3x)
  │    └─ fn-bot-engine (FAQ template, intake sengketa, perintah pimpinan)
  └─ Maps: Google Maps Flutter (dropdown kecamatan + pin, hitung Haversine di client)

[Midtrans/Xendit IN (QRIS/VA DP)] + [Xendit/Flip OUT (Disbursement payout)] + [FCM push via Edge Function]
```

**Aturan Supabase:**
- Row Level Security (RLS) wajib ON di semua tabel. Policy contoh:
  - `artist_profiles`: publik bisa SELECT yang status=verified. Hanya owner bisa UPDATE lapak sendiri.
  - `bookings`: customer lihat miliknya, grup lihat job ke lapaknya, admin lihat semua.
  - `users.phone`: SELECT disensor via view `artist_public` (nomor masked) sampai DP_PAID.
- Semua hitung uang (DP 20%, fee 8%, zona transport) di Edge Function, bukan di Flutter (anti manipulasi).

API = Supabase auto-generated (PostgREST) + Edge Functions custom:
`auth.signInWithOtp`, `from('artist_profiles').select()`, `functions.invoke('create-booking')`, `functions.invoke('midtrans-webhook')`, dst.

---

## 9. Acceptance
- [ ] Hajatan = fullday mutlak. 1 grup = 1 job per tanggal. `UNIQUE(artist_id, event_date)` tolak booking tanggal sama (409). Grup lain tetap bisa.
- [ ] Jalur A (auto_accept=true): pesan langsung bayar DP, tanggal merah otomatis, voucher QR terbit.
- [ ] Jalur A (auto_accept=false): nunggu 12 jam grup approve baru bisa bayar DP.
- [ ] Jalur B custom: tolak penawaran ronde 4 (422), tiap ronde expired 12 jam, customer max 2 PENDING aktif (tolak ke-3 dengan 429).
- [ ] No HP grup disensor sampai DP terbayar.
- [ ] Reschedule instant kena fee 10% dan wajib H-7; custom sebelum lock bebas biaya.
- [ ] Payout gagal masuk status FAILED, worker coba 3x, notif pimpinan untuk cek no rekening.
- [ ] H-H scan QR voucher berhasil ubah status jadi ONGOING.
- [ ] Sengketa kunci payout otomatis sampai admin putuskan.

## 10. Roadmap
M1 Auth+lapak, M2 Search+kalender, M3 Booking+nego+lock, M4 DP auto+webhook, M5 Cash confirm+payout auto API, M6 Admin pasar+UAT.

---
*Platform cuma lapak. Isi seni milik grup.*
