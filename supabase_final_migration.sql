-- ============================================
-- MIGRATION: Transform waiting_list to users
-- Based on your current schema
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
-- Transform: name → full_name, email → email
-- ============================================

INSERT INTO users (full_name, email, created_at)
SELECT 
  CASE 
    WHEN name IS NULL OR name = '' THEN 'Guest User'
    ELSE name
  END as full_name,
  email,
  created_at
FROM waiting_list
WHERE email IS NOT NULL
ON CONFLICT (email) 
DO UPDATE SET 
  full_name = CASE 
    WHEN EXCLUDED.full_name != 'Guest User' THEN EXCLUDED.full_name
    ELSE users.full_name
  END,
  updated_at = NOW();

-- ============================================
-- STEP 3: Create additional tables for the app
-- ============================================

-- Table for generated photos
CREATE TABLE IF NOT EXISTS generated_photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  animal TEXT NOT NULL,
  photo_url TEXT NOT NULL,
  status TEXT DEFAULT 'generated',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table for purchases
CREATE TABLE IF NOT EXISTS purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tier TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- STEP 4: Create indexes for performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_generated_photos_user_id ON generated_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);

-- ============================================
-- STEP 5: Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
DROP POLICY IF EXISTS "Anyone can view users" ON users;
DROP POLICY IF EXISTS "Anyone can update users" ON users;
DROP POLICY IF EXISTS "Anyone can insert generated photos" ON generated_photos;
DROP POLICY IF EXISTS "Anyone can view generated photos" ON generated_photos;
DROP POLICY IF EXISTS "Anyone can insert purchases" ON purchases;
DROP POLICY IF EXISTS "Anyone can view purchases" ON purchases;

-- Create RLS policies
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view users" ON users
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update users" ON users
  FOR UPDATE USING (true);

CREATE POLICY "Anyone can insert generated photos" ON generated_photos
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view generated photos" ON generated_photos
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert purchases" ON purchases
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view purchases" ON purchases
  FOR SELECT USING (true);

-- ============================================
-- STEP 6: Create trigger for updated_at
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
-- STEP 7: View migrated data
-- ============================================

SELECT 
  full_name AS "Full Name",
  email AS "Email",
  created_at AS "Created At"
FROM users
ORDER BY created_at DESC;

-- ============================================
-- STEP 8: Compare old and new data
-- ============================================

SELECT 
  'waiting_list' as "Table",
  COUNT(*) as "Record Count"
FROM waiting_list
UNION ALL
SELECT 
  'users' as "Table",
  COUNT(*) as "Record Count"
FROM users;

-- ============================================
-- STEP 9: Optional - Rename or drop waiting_list
-- ============================================

-- Option A: Rename waiting_list as backup (RECOMMENDED)
-- ALTER TABLE waiting_list RENAME TO waiting_list_backup;

-- Option B: Drop waiting_list completely (ONLY AFTER VERIFICATION!)
-- DROP TABLE IF EXISTS waiting_list CASCADE;

-- ============================================
-- Summary and Statistics
-- ============================================

DO $$ 
DECLARE
  old_count INTEGER;
  new_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO old_count FROM waiting_list;
  SELECT COUNT(*) INTO new_count FROM users;
  
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '✅ Migration Complete!';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Records in waiting_list: %', old_count;
  RAISE NOTICE '📊 Records in users table: %', new_count;
  RAISE NOTICE '';
  RAISE NOTICE '✅ Tables created:';
  RAISE NOTICE '   - users (with full_name and email)';
  RAISE NOTICE '   - generated_photos';
  RAISE NOTICE '   - purchases';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Data transformation:';
  RAISE NOTICE '   - waiting_list.name → users.full_name';
  RAISE NOTICE '   - waiting_list.email → users.email';
  RAISE NOTICE '   - Empty names converted to "Guest User"';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Features enabled:';
  RAISE NOTICE '   - Row Level Security (RLS)';
  RAISE NOTICE '   - Auto-updated timestamps';
  RAISE NOTICE '   - Performance indexes';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Next steps:';
  RAISE NOTICE '   1. Verify the data in users table';
  RAISE NOTICE '   2. Test your Animal Portrait Studio app';
  RAISE NOTICE '   3. Rename waiting_list to waiting_list_backup';
  RAISE NOTICE '   4. After confirming, drop the backup table';
  RAISE NOTICE '';
  RAISE NOTICE '🔗 Your app is now connected to:';
  RAISE NOTICE '   - Supabase URL: https://dqfbhilgrmqvclbxuhwf.supabase.co';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;
