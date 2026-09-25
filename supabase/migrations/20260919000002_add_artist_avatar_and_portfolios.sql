-- Migration: 20260919000002_add_artist_avatar_and_portfolios.sql
-- Description: Add avatar_url column to artist_profiles and seed dynamic portfolios for Pantura artists

-- 1. Ensure avatar_url column exists in artist_profiles
ALTER TABLE artist_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. Update dynamic profile avatars for all 5 verified groups
UPDATE artist_profiles
SET avatar_url = 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=800&auto=format&fit=crop&q=80'
WHERE id = 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa'; -- Dharma Kudeta

UPDATE artist_profiles
SET avatar_url = 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80'
WHERE id = 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb'; -- Candra Kirana

UPDATE artist_profiles
SET avatar_url = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80'
WHERE id = 'cccccccc-cccc-4ccc-cccc-cccccccccccc'; -- Dewi Kirana

UPDATE artist_profiles
SET avatar_url = 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80'
WHERE id = 'dddddddd-dddd-4ddd-dddd-dddddddddddd'; -- Rolani Diva

UPDATE artist_profiles
SET avatar_url = 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&auto=format&fit=crop&q=80'
WHERE id = 'eeeeeeee-eeee-4eee-eeee-eeeeeeeeeeee'; -- Sindy Puspita

-- Also update users table avatar_url
UPDATE users
SET avatar_url = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80'
WHERE id = '00000000-0000-4000-a000-000000000001'; -- Admin Pasar

-- 3. Seed Portfolios (Dynamic Photo Gallery per Artist)
INSERT INTO portfolios (id, artist_id, type, url, title) VALUES
  -- Dharma Kudeta Photos
  ('p1111111-1111-4111-a111-111111111111', 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa', 'image', 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=800&auto=format&fit=crop&q=80', 'Pentas Akbar Lapangan Kandanghaur'),
  ('p1111111-1111-4111-a111-222222222222', 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa', 'image', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80', 'Busana Klasik Wayang Wong Pantura'),
  ('p1111111-1111-4111-a111-333333333333', 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa', 'image', 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80', 'Tata Lampu & Panggung Terop Megah'),

  -- Candra Kirana Photos
  ('p2222222-2222-4222-a222-111111111111', 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb', 'image', 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80', 'Nayaga Gamelan Slendro'),
  ('p2222222-2222-4222-a222-222222222222', 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb', 'image', 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80', 'Lakon Purwa Babad Cirebon'),
  ('p2222222-2222-4222-a222-333333333333', 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb', 'image', 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&auto=format&fit=crop&q=80', 'Kemeriahan Penonton Gegesik'),

  -- Dewi Kirana Photos
  ('p3333333-3333-4333-a333-111111111111', 'cccccccc-cccc-4ccc-cccc-cccccccccccc', 'image', 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80', 'Aksi Panggung Ratu Tarling Pantura'),
  ('p3333333-3333-4333-a333-222222222222', 'cccccccc-cccc-4ccc-cccc-cccccccccccc', 'image', 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&auto=format&fit=crop&q=80', 'Sound Horeg Pantura Jatibarang'),
  ('p3333333-3333-4333-a333-333333333333', 'cccccccc-cccc-4ccc-cccc-cccccccccccc', 'image', 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=800&auto=format&fit=crop&q=80', 'Keluarga Besar Musisi Dangdut Pantura'),

  -- Rolani Diva Photos
  ('p4444444-4444-4444-a444-111111111111', 'dddddddd-dddd-4ddd-dddd-dddddddddddd', 'image', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80', 'Keyboard Virtuoso Performance'),
  ('p4444444-4444-4444-a444-222222222222', 'dddddddd-dddd-4ddd-dddd-dddddddddddd', 'image', 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80', 'Deretan 3 Biduan Rolani Diva'),

  -- Sindy Puspita Photos
  ('p5555555-5555-4555-a555-111111111111', 'eeeeeeee-eeee-4eee-eeee-eeeeeeeeeeee', 'image', 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&auto=format&fit=crop&q=80', 'Penampilan Spesial Resepsi Pengantin'),
  ('p5555555-5555-4555-a555-222222222222', 'eeeeeeee-eeee-4eee-eeee-eeeeeeeeeeee', 'image', 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80', 'MC Acara Saweran Tradisional')
ON CONFLICT (id) DO NOTHING;
