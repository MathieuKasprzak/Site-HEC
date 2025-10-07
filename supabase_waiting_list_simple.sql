-- ============================================
-- SIMPLE WAITING LIST SETUP
-- Single table for Name and Email only
-- ============================================

-- ============================================
-- Create users table (waiting list)
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE users IS 'Waiting list - stores user name and email';
COMMENT ON COLUMN users.full_name IS 'Full name of the user';
COMMENT ON COLUMN users.email IS 'Email address of the user';

-- ============================================
-- Create indexes for performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- ============================================
-- Create trigger for auto-updating updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
DROP POLICY IF EXISTS "Anyone can view users" ON users;
DROP POLICY IF EXISTS "Anyone can update users" ON users;

-- Create RLS policies
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view users" ON users
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update users" ON users
  FOR UPDATE USING (true);

-- ============================================
-- View all waiting list entries
-- ============================================

SELECT 
  full_name AS "Full Name",
  email AS "Email",
  created_at AS "Joined At"
FROM users
ORDER BY created_at DESC;

-- ============================================
-- Summary
-- ============================================

DO $$ 
DECLARE
  user_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM users;
  
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '✅ Waiting List Setup Complete!';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Table created: users';
  RAISE NOTICE '📊 Current entries: %', user_count;
  RAISE NOTICE '';
  RAISE NOTICE '✅ Columns:';
  RAISE NOTICE '   - full_name (Name)';
  RAISE NOTICE '   - email (Email)';
  RAISE NOTICE '   - created_at (Join date)';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Features enabled:';
  RAISE NOTICE '   - Row Level Security';
  RAISE NOTICE '   - Auto-updated timestamps';
  RAISE NOTICE '   - Email uniqueness constraint';
  RAISE NOTICE '';
  RAISE NOTICE '🔗 Your waiting list is ready!';
  RAISE NOTICE '   - Database: https://dqfbhilgrmqvclbxuhwf.supabase.co';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;
