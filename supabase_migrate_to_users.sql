-- ============================================
-- MIGRATION: Transform waiting_list to users table
-- Keep only Name and Email
-- ============================================

-- ============================================
-- STEP 1: Create the new users table
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- STEP 2: Migrate data from waiting_list to users
-- Only keep name and email, drop country
-- ============================================

-- Migrate existing data
INSERT INTO users (full_name, email, created_at)
SELECT 
  COALESCE(NULLIF(name, ''), 'Guest') as full_name,  -- Replace empty names with 'Guest'
  email,
  created_at
FROM waiting_list
WHERE email IS NOT NULL
ON CONFLICT (email) 
DO UPDATE SET 
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- ============================================
-- STEP 3: Create indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- ============================================
-- STEP 4: Enable Row Level Security
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
DROP POLICY IF EXISTS "Anyone can view users" ON users;
DROP POLICY IF EXISTS "Anyone can update users" ON users;

-- Create new policies
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view users" ON users
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update users" ON users
  FOR UPDATE USING (true);

-- ============================================
-- STEP 5: Create trigger for updated_at
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
-- STEP 6: View migrated data (Name and Email only)
-- ============================================

SELECT 
  full_name AS "Full Name",
  email AS "Email",
  created_at AS "Created At"
FROM users
ORDER BY created_at DESC;

-- ============================================
-- STEP 7: Optional - Drop the old waiting_list table
-- ============================================

-- IMPORTANT: Only uncomment this AFTER verifying the migration was successful!
-- DROP TABLE IF EXISTS waiting_list CASCADE;

-- ============================================
-- Summary
-- ============================================

DO $$ 
DECLARE
  user_count INTEGER;
  migrated_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM users;
  SELECT COUNT(*) INTO migrated_count FROM waiting_list;
  
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '✅ Migration Complete!';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '📊 Records in old waiting_list: %', migrated_count;
  RAISE NOTICE '📊 Records in new users table: %', user_count;
  RAISE NOTICE '';
  RAISE NOTICE '✅ Kept columns:';
  RAISE NOTICE '   - Full Name (from name)';
  RAISE NOTICE '   - Email';
  RAISE NOTICE '';
  RAISE NOTICE '❌ Removed columns:';
  RAISE NOTICE '   - Country (dropped)';
  RAISE NOTICE '';
  RAISE NOTICE '💡 Next steps:';
  RAISE NOTICE '   1. Verify the data in users table';
  RAISE NOTICE '   2. Test your application';
  RAISE NOTICE '   3. Uncomment DROP TABLE to remove waiting_list';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;
