-- Migration: 20260907000001_initial_schema.sql
-- Description: Initial database schema for TarlingBook (Lapak Marketplace Sandiwara & Tarling)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Custom ENUM types
CREATE TYPE booking_status AS ENUM (
  'PENDING',
  'APPROVED',
  'WAITING_DP',
  'DP_PAID',
  'PARTIAL_PAID',
  'FULL_PAID',
  'ONGOING',
  'COMPLETED',
  'CANCELLED',
  'REFUNDED',
  'EXPIRED'
);

CREATE TYPE pay_status AS ENUM (
  'PENDING',
  'PAID',
  'FAILED',
  'EXPIRED'
);

-- Users table (supports customer, artist_owner, admin)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE,
  password_hash TEXT,
  role VARCHAR(20) DEFAULT 'customer',
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Master Categories
CREATE TABLE categories (
  slug VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- Master Cities & Districts
CREATE TABLE cities (
  name VARCHAR(50) PRIMARY KEY
);

CREATE TABLE districts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city VARCHAR(50) NOT NULL REFERENCES cities(name) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  CONSTRAINT uq_city_district UNIQUE(city, name)
);

-- Platform settings
CREATE TABLE settings (
  key VARCHAR(50) PRIMARY KEY,
  value TEXT NOT NULL
);

-- Artist Profiles (Lapak grup kesenian)
CREATE TABLE artist_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  display_name VARCHAR(150) NOT NULL,
  category VARCHAR(50) NOT NULL REFERENCES categories(slug),
  base_city VARCHAR(50) NOT NULL REFERENCES cities(name),
  base_district VARCHAR(100),
  base_lat DECIMAL(10,7),
  base_lng DECIMAL(10,7),
  coverage_cities TEXT[] DEFAULT '{}',
  description TEXT,
  auto_accept BOOLEAN DEFAULT FALSE, -- true: instant booking langsung bayar; false: butuh approve 12 jam
  price_min INT DEFAULT 0,
  price_max INT DEFAULT 0,
  rating_avg DECIMAL(2,1) DEFAULT 0,
  total_job INT DEFAULT 0,
  video_urls TEXT[] DEFAULT '{}',
  status VARCHAR(20) DEFAULT 'pending', -- pending, verified, suspended
  bank_name VARCHAR(50),
  bank_no VARCHAR(50),
  bank_owner VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_artist_search ON artist_profiles(base_city, status, rating_avg);
CREATE INDEX idx_artist_user_id ON artist_profiles(user_id);

-- Packages (Lapak packages per grup)
CREATE TABLE packages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  artist_id UUID NOT NULL REFERENCES artist_profiles(id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  duration_hours INT,
  price INT NOT NULL, -- Rupiah murni integer
  includes TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_packages_artist ON packages(artist_id);

-- Zone Prices (Biaya tambahan ongkir/jarak per paket)
CREATE TABLE zone_prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
  zone VARCHAR(20) NOT NULL, -- Ring 1, Ring 2, Ring 3, Luar Kota
  max_km DECIMAL(6,2),
  extra_price INT NOT NULL DEFAULT 0,
  CONSTRAINT uq_package_zone UNIQUE(package_id, zone)
);

-- Portfolios
CREATE TABLE portfolios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  artist_id UUID NOT NULL REFERENCES artist_profiles(id) ON DELETE CASCADE,
  type VARCHAR(10) NOT NULL, -- image, video, audio
  url TEXT NOT NULL,
  title VARCHAR(150),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Blocked Dates (Kalender libur / job luar grup - fullday)
CREATE TABLE blocked_dates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  artist_id UUID NOT NULL REFERENCES artist_profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  reason TEXT,
  CONSTRAINT uq_artist_blocked_date UNIQUE(artist_id, date)
);

CREATE INDEX idx_blocked_dates_artist_date ON blocked_dates(artist_id, date);

-- Bookings table
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL, -- Misal: TRG-2026-0042
  customer_id UUID NOT NULL REFERENCES users(id),
  artist_id UUID NOT NULL REFERENCES artist_profiles(id),
  package_id UUID NOT NULL REFERENCES packages(id),
  event_date DATE NOT NULL,
  venue_address TEXT NOT NULL,
  venue_maps_url TEXT,
  city VARCHAR(50) NOT NULL REFERENCES cities(name),
  district VARCHAR(100),
  venue_lat DECIMAL(10,7),
  venue_lng DECIMAL(10,7),
  distance_km DECIMAL(6,2),
  zone VARCHAR(20),
  total_price INT NOT NULL,
  final_price INT,
  locked_at TIMESTAMPTZ,
  dp_percent INT DEFAULT 20,
  dp_amount INT NOT NULL,
  remaining_amount INT NOT NULL,
  booking_type VARCHAR(20) DEFAULT 'instant', -- instant / custom
  evoucher_code VARCHAR(20) UNIQUE,
  approved_at TIMESTAMPTZ, -- null jika belum di-approve pemilik grup
  offer_expires_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  cash_received INT DEFAULT 0,
  cash_proof_url TEXT,
  cash_confirmed BOOLEAN DEFAULT FALSE,
  status booking_status DEFAULT 'PENDING',
  note TEXT,
  cancel_reason TEXT,
  paid_dp_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Constraint kunci tanggal fullday mutlak (1 grup 1 job per tanggal untuk booking aktif)
CREATE UNIQUE INDEX uniq_artist_date ON bookings(artist_id, event_date)
  WHERE status IN ('DP_PAID','PARTIAL_PAID','FULL_PAID','ONGOING');

CREATE INDEX idx_booking_date ON bookings(event_date, status);
CREATE INDEX idx_booking_customer_pending ON bookings(customer_id, status)
  WHERE booking_type = 'custom' AND status = 'PENDING';
CREATE INDEX idx_booking_artist ON bookings(artist_id, status);

-- Booking Offers (Untuk Jalur B Custom Nego max 3 ronde)
CREATE TABLE booking_offers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  offered_by UUID NOT NULL REFERENCES users(id),
  amount INT NOT NULL,
  note TEXT,
  round INT NOT NULL, -- Max 3 rounds
  status VARCHAR(20) DEFAULT 'proposed', -- proposed, accepted, rejected, expired
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_offers_booking ON booking_offers(booking_id, round);

-- Messages (In-app per-booking communication)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id),
  text TEXT NOT NULL,
  attachment_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_msg_booking ON messages(booking_id, created_at);

-- Booking items (breakdown rincian biaya: paket dasar, zona transport, request tambahan)
CREATE TABLE booking_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  label VARCHAR(100) NOT NULL,
  amount INT NOT NULL
);

-- Audit Status History
CREATE TABLE booking_status_histories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  from_status VARCHAR(20),
  to_status VARCHAR(20) NOT NULL,
  changed_by UUID REFERENCES users(id),
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_history_booking ON booking_status_histories(booking_id, created_at);

-- Payments (DP payment tracking)
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL, -- 'dp', 'full'
  amount INT NOT NULL,
  method VARCHAR(50),
  gateway VARCHAR(20) DEFAULT 'midtrans',
  gateway_trx_id VARCHAR(100) UNIQUE,
  snap_token TEXT,
  status pay_status DEFAULT 'PENDING',
  expired_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  raw_callback JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_payments_booking ON payments(booking_id);

-- Refunds
CREATE TABLE refunds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id),
  payment_id UUID REFERENCES payments(id),
  amount INT NOT NULL,
  reason TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  approved_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Disputes (Tiket sengketa)
CREATE TABLE disputes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id),
  reporter_id UUID NOT NULL REFERENCES users(id),
  reason TEXT NOT NULL,
  evidence_urls TEXT[] DEFAULT '{}',
  status VARCHAR(20) DEFAULT 'open', -- open, under_review, resolved, rejected
  verdict TEXT,
  resolved_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Payouts (Disbursement sisa DP ke rekening grup H+2)
CREATE TABLE payouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID UNIQUE NOT NULL REFERENCES bookings(id),
  artist_id UUID NOT NULL REFERENCES artist_profiles(id),
  gross INT NOT NULL,
  fee_pct INT DEFAULT 8,
  fee INT NOT NULL,
  net INT NOT NULL,
  status VARCHAR(20) DEFAULT 'HOLD', -- HOLD, READY, PROCESSING, COMPLETED, FAILED, DISPUTED
  disbursement_id VARCHAR(100),
  disbursement_status VARCHAR(20),
  retry_count INT DEFAULT 0,
  transferred_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_payouts_status ON payouts(status);

-- Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID UNIQUE NOT NULL REFERENCES bookings(id),
  customer_id UUID NOT NULL REFERENCES users(id),
  artist_id UUID NOT NULL REFERENCES artist_profiles(id),
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  photos TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_reviews_artist ON reviews(artist_id, rating);

-- OTPs for phone auth
CREATE TABLE otps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone VARCHAR(20) NOT NULL,
  code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  attempts INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_otps_phone ON otps(phone);

-- In-app notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(150) NOT NULL,
  body TEXT NOT NULL,
  type VARCHAR(50),
  ref_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notif_user ON notifications(user_id, is_read);

-- Bot conversations (24/7 in-app floating CS bot)
CREATE TABLE bot_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sender VARCHAR(10) NOT NULL, -- 'user', 'bot'
  text TEXT NOT NULL,
  intent VARCHAR(50),
  context JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_bot_user ON bot_conversations(user_id, created_at);

-- Bot FAQ templates
CREATE TABLE bot_faq_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  keywords TEXT[] NOT NULL,
  answer TEXT NOT NULL,
  deeplink VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Anti-Bocor View: Masked phone number view for public catalog
CREATE OR REPLACE VIEW artist_public AS
SELECT 
  ap.id,
  ap.user_id,
  ap.display_name,
  ap.category,
  ap.base_city,
  ap.base_district,
  ap.base_lat,
  ap.base_lng,
  ap.coverage_cities,
  ap.description,
  ap.auto_accept,
  ap.price_min,
  ap.price_max,
  ap.rating_avg,
  ap.total_job,
  ap.video_urls,
  ap.status,
  -- Masked phone: 0812-****-**78
  CASE 
    WHEN LENGTH(u.phone) >= 10 THEN
      CONCAT(SUBSTRING(u.phone FROM 1 FOR 4), '-****-**', RIGHT(u.phone, 2))
    ELSE
      '08**-****-**'
  END AS masked_phone,
  u.avatar_url,
  ap.created_at
FROM artist_profiles ap
JOIN users u ON ap.user_id = u.id
WHERE ap.status = 'verified';



-- ----------------------------------------------------


-- Migration: 20260907000002_rls_policies.sql
-- Description: Row Level Security policies for TarlingBook

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE artist_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE zone_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_status_histories ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_faq_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE districts ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE otps ENABLE ROW LEVEL SECURITY;

-- Helper function to extract user role from JWT (in public schema)
CREATE OR REPLACE FUNCTION public.user_role()
RETURNS TEXT AS $$
  SELECT COALESCE((auth.jwt() -> 'app_metadata' ->> 'role'), 'customer');
$$ LANGUAGE sql STABLE;

-- USERS: read own profile
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- USERS: update own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- ARTIST_PROFILES: public read verified only
CREATE POLICY "Public can read verified artists" ON artist_profiles
  FOR SELECT USING (status = 'verified');

-- ARTIST_PROFILES: owner CRUD
CREATE POLICY "Owner can manage own artist profile" ON artist_profiles
  FOR ALL USING (auth.uid() = user_id);

-- ARTIST_PROFILES: admin read all
CREATE POLICY "Admin can read all artists" ON artist_profiles
  FOR SELECT USING (public.user_role() = 'admin');

-- PACKAGES: public read active
CREATE POLICY "Public can read active packages" ON packages
  FOR SELECT USING (is_active = TRUE);

-- PACKAGES: owner CRUD
CREATE POLICY "Owner can manage own packages" ON packages
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM artist_profiles ap
      WHERE ap.id = packages.artist_id AND ap.user_id = auth.uid()
    )
  );

-- ZONE_PRICES: public read
CREATE POLICY "Public can read zone prices" ON zone_prices
  FOR SELECT USING (TRUE);

-- ZONE_PRICES: owner via package
CREATE POLICY "Owner can manage zone prices" ON zone_prices
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM packages p
      JOIN artist_profiles ap ON ap.id = p.artist_id
      WHERE p.id = zone_prices.package_id AND ap.user_id = auth.uid()
    )
  );

-- PORTFOLIOS: public read
CREATE POLICY "Public can read portfolios" ON portfolios
  FOR SELECT USING (TRUE);

-- PORTFOLIOS: owner CRUD
CREATE POLICY "Owner can manage portfolios" ON portfolios
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM artist_profiles ap
      WHERE ap.id = portfolios.artist_id AND ap.user_id = auth.uid()
    )
  );

-- BLOCKED_DATES: public read
CREATE POLICY "Public can read blocked dates" ON blocked_dates
  FOR SELECT USING (TRUE);

-- BLOCKED_DATES: owner CRUD
CREATE POLICY "Owner can manage blocked dates" ON blocked_dates
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM artist_profiles ap
      WHERE ap.id = blocked_dates.artist_id AND ap.user_id = auth.uid()
    )
  );

-- BOOKINGS: customer reads own
CREATE POLICY "Customer reads own bookings" ON bookings
  FOR SELECT USING (auth.uid() = customer_id);

-- BOOKINGS: artist reads assigned
CREATE POLICY "Artist reads assigned bookings" ON bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM artist_profiles ap
      WHERE ap.id = bookings.artist_id AND ap.user_id = auth.uid()
    )
  );

-- BOOKINGS: admin reads all
CREATE POLICY "Admin reads all bookings" ON bookings
  FOR SELECT USING (public.user_role() = 'admin');

-- BOOKING_OFFERS: participants read
CREATE POLICY "Participants read offers" ON booking_offers
  FOR SELECT USING (
    auth.uid() = offered_by OR
    EXISTS (
      SELECT 1 FROM bookings b
      JOIN artist_profiles ap ON ap.id = b.artist_id
      WHERE b.id = booking_offers.booking_id
        AND (b.customer_id = auth.uid() OR ap.user_id = auth.uid())
    )
  );

-- MESSAGES: participants read
CREATE POLICY "Participants read messages" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM bookings b
      JOIN artist_profiles ap ON ap.id = b.artist_id
      WHERE b.id = messages.booking_id
        AND (b.customer_id = auth.uid() OR ap.user_id = auth.uid())
    )
  );

-- MESSAGES: participants insert
CREATE POLICY "Participants send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- PAYMENTS: service role only (Edge Functions)
CREATE POLICY "Service role manages payments" ON payments
  FOR ALL USING (auth.role() = 'service_role');

-- PAYOUTS: service role only
CREATE POLICY "Service role manages payouts" ON payouts
  FOR ALL USING (auth.role() = 'service_role');

-- DISPUTES: reporter read own
CREATE POLICY "Reporter reads own disputes" ON disputes
  FOR SELECT USING (auth.uid() = reporter_id);

-- DISPUTES: admin reads all
CREATE POLICY "Admin reads all disputes" ON disputes
  FOR SELECT USING (public.user_role() = 'admin');

-- REVIEWS: public read
CREATE POLICY "Public reads reviews" ON reviews
  FOR SELECT USING (TRUE);

-- REVIEWS: customer insert own
CREATE POLICY "Customer writes review" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- NOTIFICATIONS: user reads own
CREATE POLICY "User reads own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- NOTIFICATIONS: user updates own read status
CREATE POLICY "User marks notification read" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- BOT_CONVERSATIONS: user reads own
CREATE POLICY "User reads own bot conversations" ON bot_conversations
  FOR SELECT USING (auth.uid() = user_id);

-- BOT_FAQ_TEMPLATES: public read active
CREATE POLICY "Public reads active FAQ" ON bot_faq_templates
  FOR SELECT USING (is_active = TRUE);

-- MASTER DATA: public read
CREATE POLICY "Public reads categories" ON categories FOR SELECT USING (TRUE);
CREATE POLICY "Public reads cities" ON cities FOR SELECT USING (TRUE);
CREATE POLICY "Public reads districts" ON districts FOR SELECT USING (TRUE);
CREATE POLICY "Public reads settings" ON settings FOR SELECT USING (TRUE);

-- OTPS: internal service only
CREATE POLICY "Internal service only for otps" ON otps FOR ALL USING (public.user_role() = 'service_role');



-- ----------------------------------------------------


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



-- ----------------------------------------------------


-- Migration: 20260907000004_artist_verification_trigger.sql
-- Description: Add ktp_url to artist_profiles and create trigger to automatically promote user role to group_leader on verification

-- 1. Add KTP verification document column to artist_profiles
ALTER TABLE artist_profiles 
ADD COLUMN IF NOT EXISTS ktp_url TEXT;

-- 2. Trigger function to promote user to group_leader when artist status is verified
CREATE OR REPLACE FUNCTION trg_promote_user_to_group_leader()
RETURNS TRIGGER AS $$
BEGIN
  -- When status changes to verified, promote user to group_leader
  IF NEW.status = 'verified' AND (OLD.status IS DISTINCT FROM 'verified') THEN
    UPDATE users 
    SET role = 'group_leader' 
    WHERE id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Bind trigger to artist_profiles
DROP TRIGGER IF EXISTS trg_artist_verified_promote_user ON artist_profiles;
CREATE TRIGGER trg_artist_verified_promote_user
AFTER INSERT OR UPDATE OF status ON artist_profiles
FOR EACH ROW
EXECUTE FUNCTION trg_promote_user_to_group_leader();



-- ----------------------------------------------------


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



-- ----------------------------------------------------


