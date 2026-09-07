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
