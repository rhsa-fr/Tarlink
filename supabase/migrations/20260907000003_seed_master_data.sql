-- Migration: 20260907000003_seed_master_data.sql
-- Description: Master seed data for Pantura region (Indramayu & Cirebon)

-- 1. Master Categories
INSERT INTO categories (slug, name) VALUES
  ('sandiwara-full', 'Sandiwara Pantura Full'),
  ('tarling-dangdut', 'Tarling Dangdut Kombinasi'),
  ('organ-tunggal', 'Organ Tunggal / Dangdut Mini'),
  ('biduan-solo', 'Biduan Solo / Bintang Tamu'),
  ('mc-pranatacara', 'MC / Pranata Cara Hajatan')
ON CONFLICT (slug) DO NOTHING;

-- 2. Master Cities
INSERT INTO cities (name) VALUES
  ('Indramayu'),
  ('Cirebon'),
  ('Majalengka'),
  ('Kuningan'),
  ('Subang')
ON CONFLICT (name) DO NOTHING;

-- 3. Master Districts (Kecamatan Utama Pantura)
INSERT INTO districts (city, name) VALUES
  -- Indramayu
  ('Indramayu', 'Kandanghaur'),
  ('Indramayu', 'Patrol'),
  ('Indramayu', 'Losarang'),
  ('Indramayu', 'Jatibarang'),
  ('Indramayu', 'Haurgeulis'),
  ('Indramayu', 'Anjatan'),
  ('Indramayu', 'Sliyeg'),
  ('Indramayu', 'Krangkeng'),
  ('Indramayu', 'Balongan'),
  ('Indramayu', 'Widasari'),
  ('Indramayu', 'Gabuswetan'),
  ('Indramayu', 'Kroya'),
  ('Indramayu', 'Bongas'),
  ('Indramayu', 'Sukra'),
  ('Indramayu', 'Arahan'),
  ('Indramayu', 'Cantigi'),
  ('Indramayu', 'Pasekan'),
  ('Indramayu', 'Tukdana'),
  ('Indramayu', 'Terisi'),
  ('Indramayu', 'Kertasmaya'),
  ('Indramayu', 'Kedokan Bunder'),
  ('Indramayu', 'Juntinyuat'),
  ('Indramayu', 'Karangampel'),
  ('Indramayu', 'Sindang'),
  ('Indramayu', 'Lohbener'),
  ('Indramayu', 'Lelea'),
  ('Indramayu', 'Cikedung'),
  -- Cirebon
  ('Cirebon', 'Arjawinangun'),
  ('Cirebon', 'Sumber'),
  ('Cirebon', 'Weru'),
  ('Cirebon', 'Palimanan'),
  ('Cirebon', 'Klangenan'),
  ('Cirebon', 'Plered'),
  ('Cirebon', 'Kedawung'),
  ('Cirebon', 'Plumbon'),
  ('Cirebon', 'Gunung Jati'),
  ('Cirebon', 'Kapetakan'),
  ('Cirebon', 'Gegesik'),
  ('Cirebon', 'Kaliwedi'),
  ('Cirebon', 'Panguragan'),
  ('Cirebon', 'Susukan'),
  ('Cirebon', 'Ciwaringin'),
  ('Cirebon', 'Gempol'),
  ('Cirebon', 'Dukupuntang'),
  ('Cirebon', 'Depok'),
  ('Cirebon', 'Suranenggala'),
  ('Cirebon', 'Losari'),
  ('Cirebon', 'Gebang'),
  ('Cirebon', 'Babakan'),
  ('Cirebon', 'Mundu'),
  ('Cirebon', 'Astanajapura')
ON CONFLICT (city, name) DO NOTHING;

-- 4. Platform Settings
INSERT INTO settings (key, value) VALUES
  ('dp_default', '20'),
  ('fee_lapak_pct', '8'),
  ('sla_hours', '48'),
  ('invoice_minutes', '30'),
  ('custom_offer_hours', '12'),
  ('reschedule_fee_pct', '10')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 5. In-App CS Bot FAQ Initial Templates
INSERT INTO bot_faq_templates (keywords, answer, deeplink, is_active) VALUES
  (
    ARRAY['dp', 'bayar dp', 'cara bayar', 'qris', 'transfer'],
    'Pembayaran DP 20% dapat dilakukan langsung via QRIS atau Virtual Account di aplikasi setelah Anda klik Pesan Sekarang. Invoice DP berlaku 30 menit.',
    '/payment',
    TRUE
  ),
  (
    ARRAY['cair', 'kapan cair', 'payout', 'rekening', 'transfer sisa'],
    'Pencairan dana sisa DP (setelah dipotong fee platform 8%) otomatis ditransfer ke rekening bank grup terdaftar pada H+2 setelah hajatan berstatus Selesai (COMPLETED).',
    '/profile_group/payout',
    TRUE
  ),
  (
    ARRAY['reschedule', 'ganti tanggal', 'undur tanggal'],
    'Reschedule untuk Instant Booking dapat diajukan maksimal H-7 acara dengan biaya admin 10% dari total nilai kontrak, selama tanggal baru grup masih hijau (tersedia).',
    '/booking/reschedule',
    TRUE
  ),
  (
    ARRAY['pelunasan', 'cash', 'bayar sisa', 'sisa uang'],
    'Pelunasan sisa biaya dibayarkan langsung secara tunai/cash kepada pimpinan grup di lokasi hajatan pada hari H. Setelah itu, kedua pihak wajib klik Konfirmasi Lunas di aplikasi.',
    '/booking/active',
    TRUE
  )
ON CONFLICT DO NOTHING;
