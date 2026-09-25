-- Migration: 20260919000001_lock_public_anon_access.sql
-- Description: Restrict public anon role from directly querying or altering critical business tables.
-- All client interactions now flow through the unified Next.js REST API backend (service_role).

-- 1. Revoke direct anon role privileges on sensitive transaction tables
REVOKE INSERT, UPDATE, DELETE ON TABLE bookings FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE payments FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE payouts FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE disputes FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE booking_offers FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE artist_profiles FROM anon;

-- 2. Restrict direct SELECT on unmasked artist profiles table
-- Mobile clients and web public must read through backend API / artist_public view
REVOKE SELECT ON TABLE artist_profiles FROM anon;
GRANT SELECT ON TABLE artist_public TO anon;

-- 3. Ensure service_role (used by Next.js backend) has full administrative access
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA public TO service_role;

-- 4. Enable RLS on core tables if not already enabled
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE artist_profiles ENABLE ROW LEVEL SECURITY;
