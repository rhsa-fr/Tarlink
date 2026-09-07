-- Migration: 20260907000005_seed_pantura_artists.sql
-- Description: Seed 5 realistic Pantura artists, packages, and zone pricing

-- 1. Seed Users (Pimpinan Grup & 1 Admin Pasar)
INSERT INTO users (id, name, phone, email, role, is_verified) VALUES
  ('00000000-0000-4000-a000-000000000001', 'Admin Pasar Pantura', '081100000001', 'admin@tarlingbook.id', 'admin', TRUE),
  ('11111111-1111-4111-a111-111111111111', 'H. Waryono', '081234567801', 'waryono@dharmakudeta.id', 'group_leader', TRUE),
  ('22222222-2222-4222-a222-222222222222', 'Dalang Supriyadi', '081234567802', 'supriyadi@candrakirana.id', 'group_leader', TRUE),
  ('33333333-3333-4333-a333-333333333333', 'Hj. Dewi Kirana', '081234567803', 'dewi@dewikirana.id', 'group_leader', TRUE),
  ('44444444-4444-4444-a444-444444444444', 'Mas Rolani', '081234567804', 'rolani@rolanidiva.id', 'group_leader', TRUE),
  ('55555555-5555-4555-a555-555555555555', 'Sindy Puspita', '081234567805', 'sindy@ratupantura.id', 'group_leader', TRUE)
ON CONFLICT (phone) DO UPDATE SET
  name = EXCLUDED.name,
  role = EXCLUDED.role,
  is_verified = EXCLUDED.is_verified;

-- 2. Seed Artist Profiles (Lapak Seni)
INSERT INTO artist_profiles (
  id, user_id, display_name, category, base_city, base_district,
  base_lat, base_lng, coverage_cities, description, auto_accept,
  price_min, price_max, rating_avg, total_job, video_urls, status,
  bank_name, bank_no, bank_owner, ktp_url
) VALUES
  -- 1. Sandiwara Dharma Kudeta (Kandanghaur, Indramayu)
  (
    'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-4111-a111-111111111111',
    'Sandiwara Dharma Kudeta',
    'sandiwara-full',
    'Indramayu',
    'Kandanghaur',
    -6.3762000,
    108.1472000,
    ARRAY['Indramayu', 'Subang', 'Cirebon', 'Majalengka'],
    'Grup Sandiwara legendaris Pantura pimpinan H. Waryono. Membawakan lakon babad Dermayu, bodoran khas Pantura, dan panggung megah tata lampu modern.',
    TRUE,
    9500000,
    15000000,
    4.9,
    148,
    ARRAY['https://www.youtube.com/watch?v=mock_dharmakudeta_1'],
    'verified',
    'Bank BJB Pantura',
    '0012345678901',
    'H. Waryono',
    'https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/waryono_ktp.jpg'
  ),

  -- 2. Sandiwara Candra Kirana (Gegesik, Cirebon)
  (
    'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-4222-a222-222222222222',
    'Sandiwara Candra Kirana',
    'sandiwara-full',
    'Cirebon',
    'Gegesik',
    -6.6125000,
    108.4831000,
    ARRAY['Cirebon', 'Indramayu', 'Kuningan', 'Majalengka'],
    'Sanggar Sandiwara klasik Cirebonan dengan alunan gamelan laras slendro murni, lakon purwa, dan busana wayang wong megah.',
    FALSE,
    11000000,
    16500000,
    4.8,
    112,
    ARRAY['https://www.youtube.com/watch?v=mock_candrakirana_1'],
    'verified',
    'Bank Mandiri',
    '1310098765432',
    'Dalang Supriyadi',
    'https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/supriyadi_ktp.jpg'
  ),

  -- 3. Tarling Dangdut Dewi Kirana (Jatibarang, Indramayu)
  (
    'cccccccc-cccc-4ccc-cccc-cccccccccccc',
    '33333333-3333-4333-a333-333333333333',
    'Tarling Dangdut Hj. Dewi Kirana',
    'tarling-dangdut',
    'Indramayu',
    'Jatibarang',
    -6.4741000,
    108.3128000,
    ARRAY['Indramayu', 'Cirebon', 'Majalengka', 'Subang'],
    'Ratu Tarling Dangdut Pantura Hj. Dewi Kirana dengan lagu-lagu hits legendaris, sound system horeg pantura, dan deretan biduan papan atas.',
    TRUE,
    7000000,
    12000000,
    4.9,
    215,
    ARRAY['https://www.youtube.com/watch?v=mock_dewikirana_1'],
    'verified',
    'BRI',
    '412301098765501',
    'Hj. Dewi Kirana',
    'https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/dewi_ktp.jpg'
  ),

  -- 4. Organ Tunggal Rolani Diva Pantura (Arjawinangun, Cirebon)
  (
    'dddddddd-dddd-4ddd-dddd-dddddddddddd',
    '44444444-4444-4444-a444-444444444444',
    'Organ Tunggal Rolani Diva',
    'organ-tunggal',
    'Cirebon',
    'Arjawinangun',
    -6.6433000,
    108.4111000,
    ARRAY['Cirebon', 'Indramayu', 'Majalengka'],
    'Sajian Organ Tunggal Pantura modern, keyboardis virtouso Mas Rolani dengan 3 biduan cantik dan sound system 5000 watt jernih.',
    TRUE,
    2200000,
    4500000,
    4.7,
    89,
    ARRAY['https://www.youtube.com/watch?v=mock_rolanidiva_1'],
    'verified',
    'BCA',
    '8890123456',
    'Mas Rolani',
    'https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/rolani_ktp.jpg'
  ),

  -- 5. Biduan Solo & MC Sindy Puspita (Karangampel, Indramayu)
  (
    'eeeeeeee-eeee-4eee-eeee-eeeeeeeeeeee',
    '55555555-5555-4555-a555-555555555555',
    'Sindy Puspita (Biduan & MC)',
    'biduan-solo',
    'Indramayu',
    'Karangampel',
    -6.4633000,
    108.4522000,
    ARRAY['Indramayu', 'Cirebon'],
    'Bintang tamu penyanyi solo tarling kenthrung & dangdut Pantura, merangkap MC pembawa acara hajatan pengantin & sunatan.',
    TRUE,
    1500000,
    1500000,
    4.8,
    45,
    ARRAY['https://www.youtube.com/watch?v=mock_sindypuspita_1'],
    'verified',
    'BNI',
    '0234567891',
    'Sindy Puspita',
    'https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/sindy_ktp.jpg'
  )
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  price_min = EXCLUDED.price_min,
  price_max = EXCLUDED.price_max,
  rating_avg = EXCLUDED.rating_avg,
  total_job = EXCLUDED.total_job,
  status = EXCLUDED.status;

-- 3. Seed Packages (Paket Pementasan)
INSERT INTO packages (id, artist_id, name, duration_hours, price, includes, is_active) VALUES
  -- Paket Dharma Kudeta
  (
    'f1111111-1111-4111-a111-111111111111',
    'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
    'Paket Komplit Siang - Malam (Lakon Sandiwara + Dangdut Babak)',
    10,
    15000000,
    'Panggung 12x8m, Tata Lampu Lighting Komplit, Gamelan Laras, 25 Pemain Karakter, Dangdut Babak Bodoran',
    TRUE
  ),
  (
    'f1111111-1111-4111-a111-222222222222',
    'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
    'Paket Siang Saja (Sedekah Bumi / Ruwatan)',
    5,
    9500000,
    'Lakon Khusus Ruwatan / Sedekah Bumi, Gamelan Utama, Sesaji Lengkap, Durasi Siang 13.00 - 17.30 WIB',
    TRUE
  ),

  -- Paket Candra Kirana
  (
    'f2222222-2222-4222-a222-111111111111',
    'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',
    'Paket Panggung Akbar Lakon Purwa Klasik',
    12,
    16500000,
    'Panggung Akbar Gebyok Cirebonan, 30 Aktor & Penari, Gamelan Slendro Pelog, Sound 10000 Watt',
    TRUE
  ),

  -- Paket Dewi Kirana
  (
    'f3333333-3333-4333-a333-111111111111',
    'cccccccc-cccc-4ccc-cccc-cccccccccccc',
    'Paket Goyang Pantura Babak Dangdut Tarling',
    8,
    12000000,
    'Hj. Dewi Kirana + 4 Biduan Cantik, Full Musisi Tarling Dangdut, Sound System Horeg 10000W, Lighting Moving Head',
    TRUE
  ),
  (
    'f3333333-3333-4333-a333-222222222222',
    'cccccccc-cccc-4ccc-cccc-cccccccccccc',
    'Paket Dangdut Santai Siang Hari',
    4,
    7000000,
    '2 Biduan Pilihan, Mini Musisi Tarling Akustik, Sound System 5000W',
    TRUE
  ),

  -- Paket Rolani Diva
  (
    'f4444444-4444-4444-a444-111111111111',
    'dddddddd-dddd-4ddd-dddd-dddddddddddd',
    'Paket Organ Tunggal Komplit + 3 Biduan',
    7,
    4500000,
    '2 Keyboardist Virtuoso, 3 Penyanyi Bintang Pantura, Sound System 5000 Watt, Durasi Siang & Malam',
    TRUE
  ),
  (
    'f4444444-4444-4444-a444-222222222222',
    'dddddddd-dddd-4ddd-dddd-dddddddddddd',
    'Paket Organ Tunggal Mini + 1 Penyanyi',
    4,
    2200000,
    '1 Keyboardist, 1 Penyanyi, Sound System Standar Hajatan Rumah',
    TRUE
  ),

  -- Paket Sindy Puspita
  (
    'f5555555-5555-4555-a555-111111111111',
    'eeeeeeee-eeee-4eee-eeee-eeeeeeeeeeee',
    'Bintang Tamu 5 Lagu Hits + MC Acara Hajatan',
    3,
    1500000,
    'Sindy Puspita membawakan 5 lagu hits Pantura dan memandu acara prosesi resepsi/saweran',
    TRUE
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  price = EXCLUDED.price,
  duration_hours = EXCLUDED.duration_hours,
  includes = EXCLUDED.includes;

-- 4. Seed Zone Pricing (Biaya Transport Haversine)
INSERT INTO zone_prices (package_id, zone, max_km, extra_price) VALUES
  -- Zone Dharma Kudeta Paket Komplit
  ('f1111111-1111-4111-a111-111111111111', 'ZONA_1', 20.00, 0),
  ('f1111111-1111-4111-a111-111111111111', 'ZONA_2', 50.00, 750000),
  ('f1111111-1111-4111-a111-111111111111', 'ZONA_3', 100.00, 1500000),

  -- Zone Candra Kirana
  ('f2222222-2222-4222-a222-111111111111', 'ZONA_1', 25.00, 0),
  ('f2222222-2222-4222-a222-111111111111', 'ZONA_2', 60.00, 800000),
  ('f2222222-2222-4222-a222-111111111111', 'ZONA_3', 120.00, 1800000),

  -- Zone Dewi Kirana
  ('f3333333-3333-4333-a333-111111111111', 'ZONA_1', 15.00, 0),
  ('f3333333-3333-4333-a333-111111111111', 'ZONA_2', 45.00, 500000),
  ('f3333333-3333-4333-a333-111111111111', 'ZONA_3', 90.00, 1000000),

  -- Zone Rolani Diva
  ('f4444444-4444-4444-a444-111111111111', 'ZONA_1', 20.00, 0),
  ('f4444444-4444-4444-a444-111111111111', 'ZONA_2', 50.00, 300000),
  ('f4444444-4444-4444-a444-111111111111', 'ZONA_3', 80.00, 600000)
ON CONFLICT (package_id, zone) DO UPDATE SET
  max_km = EXCLUDED.max_km,
  extra_price = EXCLUDED.extra_price;
