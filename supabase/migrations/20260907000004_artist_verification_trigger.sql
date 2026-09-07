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
