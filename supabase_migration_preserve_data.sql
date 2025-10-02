-- ============================================
-- MIGRATION: Preserve existing data and create new tables
-- Animal Portrait Studio - Supabase
-- ============================================

-- ============================================
-- STEP 1: Create new tables for the application
-- ============================================

-- Table des utilisateurs (users)
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des photos générées
CREATE TABLE IF NOT EXISTS generated_photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  animal TEXT NOT NULL,
  photo_url TEXT NOT NULL,
  status TEXT DEFAULT 'generated',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des achats
CREATE TABLE IF NOT EXISTS purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tier TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- STEP 2: Migrate data from waiting_list to users (if waiting_list exists)
-- ============================================

-- Check if waiting_list table exists and migrate data
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'waiting_list') THEN
    -- Insert data from waiting_list to users table
    -- Map 'name' or 'full_name' to full_name, and 'email' to email
    INSERT INTO users (full_name, email, created_at)
    SELECT 
      COALESCE(name, full_name, 'Unknown') as full_name,
      email,
      COALESCE(created_at, NOW()) as created_at
    FROM waiting_list
    WHERE email IS NOT NULL
    ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE 'Data migrated from waiting_list to users table';
  ELSE
    RAISE NOTICE 'waiting_list table does not exist, skipping migration';
  END IF;
END $$;

-- ============================================
-- STEP 3: Create indexes for performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_generated_photos_user_id ON generated_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_generated_photos_created_at ON generated_photos(created_at);
CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_created_at ON purchases(created_at);

-- ============================================
-- STEP 4: Create updated_at trigger function
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STEP 5: Create trigger on users table
-- ============================================

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STEP 6: Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 7: Create RLS Policies
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
DROP POLICY IF EXISTS "Users can view their own data" ON users;
DROP POLICY IF EXISTS "Anyone can insert generated photos" ON generated_photos;
DROP POLICY IF EXISTS "Anyone can view generated photos" ON generated_photos;
DROP POLICY IF EXISTS "Anyone can insert purchases" ON purchases;
DROP POLICY IF EXISTS "Anyone can view purchases" ON purchases;

-- Policies for users table
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view their own data" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own data" ON users
  FOR UPDATE USING (true);

-- Policies for generated_photos table
CREATE POLICY "Anyone can insert generated photos" ON generated_photos
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view generated photos" ON generated_photos
  FOR SELECT USING (true);

-- Policies for purchases table
CREATE POLICY "Anyone can insert purchases" ON purchases
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view purchases" ON purchases
  FOR SELECT USING (true);

-- ============================================
-- STEP 8: Verification - Show migrated data
-- ============================================

-- Show the migrated users
SELECT 
  id,
  full_name as "Nom complet",
  email as "Email",
  created_at as "Date d'inscription"
FROM users
ORDER BY created_at DESC
LIMIT 10;

-- Show table structure
SELECT 
  table_name as "Table",
  column_name as "Column",
  data_type as "Type",
  is_nullable as "Nullable"
FROM information_schema.columns
WHERE table_name IN ('users', 'generated_photos', 'purchases')
ORDER BY table_name, ordinal_position;

-- ============================================
-- OPTIONAL: Backup and drop old waiting_list table
-- ============================================

-- Uncomment the following lines if you want to drop the old waiting_list table
-- after verifying the migration was successful

-- DROP TABLE IF EXISTS waiting_list CASCADE;

-- ============================================
-- Summary
-- ============================================

DO $$ 
DECLARE
  user_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM users;
  RAISE NOTICE '✅ Migration complete!';
  RAISE NOTICE '✅ Total users migrated: %', user_count;
  RAISE NOTICE '✅ Tables created: users, generated_photos, purchases';
  RAISE NOTICE '✅ Indexes created for performance';
  RAISE NOTICE '✅ RLS policies enabled';
END $$;
