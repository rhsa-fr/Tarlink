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
