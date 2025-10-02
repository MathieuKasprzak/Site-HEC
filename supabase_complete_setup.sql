-- ============================================
-- NEW SUPABASE TABLES FOR ANIMAL PORTRAIT STUDIO
-- Complete database schema from scratch
-- ============================================

-- ============================================
-- STEP 1: Create users table
-- Stores user sign-up information
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE users IS 'Stores user information from sign-up step';
COMMENT ON COLUMN users.full_name IS 'Full name entered by user';
COMMENT ON COLUMN users.email IS 'Email address entered by user';

-- ============================================
-- STEP 2: Create uploaded_photos table
-- Stores information about uploaded photos
-- ============================================

CREATE TABLE IF NOT EXISTS uploaded_photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  photo_filename TEXT,
  file_size INTEGER,
  mime_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE uploaded_photos IS 'Stores original photos uploaded by users';
COMMENT ON COLUMN uploaded_photos.photo_url IS 'URL or path to the uploaded photo';
COMMENT ON COLUMN uploaded_photos.file_size IS 'Size of the file in bytes';

-- ============================================
-- STEP 3: Create animal_choices table
-- Stores which animal the user selected
-- ============================================

CREATE TABLE IF NOT EXISTS animal_choices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  uploaded_photo_id UUID REFERENCES uploaded_photos(id) ON DELETE CASCADE,
  animal_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE animal_choices IS 'Stores the animal selected by each user';
COMMENT ON COLUMN animal_choices.animal_type IS 'Type of animal chosen (dog, cat, panda, etc.)';

-- ============================================
-- STEP 4: Create generated_photos table
-- Stores AI-generated photos
-- ============================================

CREATE TABLE IF NOT EXISTS generated_photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  uploaded_photo_id UUID REFERENCES uploaded_photos(id) ON DELETE CASCADE,
  animal_choice_id UUID REFERENCES animal_choices(id) ON DELETE CASCADE,
  animal TEXT NOT NULL,
  generated_photo_url TEXT NOT NULL,
  status TEXT DEFAULT 'generated' CHECK (status IN ('generating', 'generated', 'failed')),
  generation_time_seconds DECIMAL(5, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE generated_photos IS 'Stores AI-generated photos with animals';
COMMENT ON COLUMN generated_photos.status IS 'Status: generating, generated, or failed';
COMMENT ON COLUMN generated_photos.generation_time_seconds IS 'Time taken to generate the photo';

-- ============================================
-- STEP 5: Create purchases table
-- Stores purchase information
-- ============================================

CREATE TABLE IF NOT EXISTS purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  generated_photo_id UUID REFERENCES generated_photos(id) ON DELETE CASCADE,
  tier TEXT NOT NULL CHECK (tier IN ('digital', 'print', 'premium')),
  price DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_method TEXT,
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE purchases IS 'Stores purchase transactions';
COMMENT ON COLUMN purchases.tier IS 'Package type: digital, print, or premium';
COMMENT ON COLUMN purchases.price IS 'Price paid in USD';
COMMENT ON COLUMN purchases.status IS 'Payment status';

-- ============================================
-- STEP 6: Create user_sessions table
-- Track user progress through the steps
-- ============================================

CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  current_step TEXT DEFAULT 'signup' CHECK (current_step IN ('signup', 'upload', 'choose', 'generate', 'purchase', 'completed')),
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE user_sessions IS 'Tracks user progress through the application';
COMMENT ON COLUMN user_sessions.current_step IS 'Current step in the workflow';

-- ============================================
-- STEP 7: Create indexes for performance
-- ============================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Uploaded photos indexes
CREATE INDEX IF NOT EXISTS idx_uploaded_photos_user_id ON uploaded_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_uploaded_photos_created_at ON uploaded_photos(created_at);

-- Animal choices indexes
CREATE INDEX IF NOT EXISTS idx_animal_choices_user_id ON animal_choices(user_id);
CREATE INDEX IF NOT EXISTS idx_animal_choices_animal_type ON animal_choices(animal_type);

-- Generated photos indexes
CREATE INDEX IF NOT EXISTS idx_generated_photos_user_id ON generated_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_generated_photos_status ON generated_photos(status);
CREATE INDEX IF NOT EXISTS idx_generated_photos_created_at ON generated_photos(created_at);

-- Purchases indexes
CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_tier ON purchases(tier);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON purchases(status);
CREATE INDEX IF NOT EXISTS idx_purchases_created_at ON purchases(created_at);

-- User sessions indexes
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_current_step ON user_sessions(current_step);

-- ============================================
-- STEP 8: Create updated_at trigger function
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STEP 9: Apply triggers
-- ============================================

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_sessions_updated_at ON user_sessions;
CREATE TRIGGER update_user_sessions_updated_at
  BEFORE UPDATE ON user_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STEP 10: Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE uploaded_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE animal_choices ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 11: Create RLS Policies
-- ============================================

-- Users policies
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view users" ON users
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update users" ON users
  FOR UPDATE USING (true);

-- Uploaded photos policies
CREATE POLICY "Anyone can insert uploaded photos" ON uploaded_photos
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view uploaded photos" ON uploaded_photos
  FOR SELECT USING (true);

-- Animal choices policies
CREATE POLICY "Anyone can insert animal choices" ON animal_choices
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view animal choices" ON animal_choices
  FOR SELECT USING (true);

-- Generated photos policies
CREATE POLICY "Anyone can insert generated photos" ON generated_photos
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view generated photos" ON generated_photos
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update generated photos" ON generated_photos
  FOR UPDATE USING (true);

-- Purchases policies
CREATE POLICY "Anyone can insert purchases" ON purchases
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view purchases" ON purchases
  FOR SELECT USING (true);

-- User sessions policies
CREATE POLICY "Anyone can insert user sessions" ON user_sessions
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view user sessions" ON user_sessions
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update user sessions" ON user_sessions
  FOR UPDATE USING (true);

-- ============================================
-- STEP 12: Create useful views
-- ============================================

-- View: Complete user journey
CREATE OR REPLACE VIEW user_complete_journey AS
SELECT 
  u.id as user_id,
  u.full_name,
  u.email,
  u.created_at as signup_date,
  up.photo_url as uploaded_photo,
  ac.animal_type as chosen_animal,
  gp.generated_photo_url,
  gp.status as photo_status,
  p.tier as purchase_tier,
  p.price as amount_paid,
  p.status as payment_status
FROM users u
LEFT JOIN uploaded_photos up ON u.id = up.user_id
LEFT JOIN animal_choices ac ON u.id = ac.user_id
LEFT JOIN generated_photos gp ON u.id = gp.user_id
LEFT JOIN purchases p ON u.id = p.user_id
ORDER BY u.created_at DESC;

COMMENT ON VIEW user_complete_journey IS 'Shows complete user journey from signup to purchase';

-- View: Popular animals
CREATE OR REPLACE VIEW popular_animals AS
SELECT 
  animal_type as animal,
  COUNT(*) as selection_count,
  ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM animal_choices), 0), 2) as percentage
FROM animal_choices
GROUP BY animal_type
ORDER BY selection_count DESC;

COMMENT ON VIEW popular_animals IS 'Shows which animals are most popular';

-- View: Revenue summary
CREATE OR REPLACE VIEW revenue_summary AS
SELECT 
  tier,
  COUNT(*) as total_sales,
  SUM(price) as total_revenue,
  AVG(price) as average_price,
  MIN(price) as min_price,
  MAX(price) as max_price
FROM purchases
WHERE status = 'completed'
GROUP BY tier
ORDER BY total_revenue DESC;

COMMENT ON VIEW revenue_summary IS 'Revenue breakdown by purchase tier';

-- ============================================
-- STEP 13: Insert sample data (optional)
-- ============================================

-- Uncomment to add sample data for testing
/*
-- Sample user
INSERT INTO users (full_name, email) VALUES ('John Doe', 'john@example.com');

-- Get the user ID
DO $$
DECLARE
  sample_user_id UUID;
BEGIN
  SELECT id INTO sample_user_id FROM users WHERE email = 'john@example.com';
  
  -- Sample uploaded photo
  INSERT INTO uploaded_photos (user_id, photo_url, photo_filename) 
  VALUES (sample_user_id, '/uploads/sample.jpg', 'sample.jpg');
  
  -- Sample animal choice
  INSERT INTO animal_choices (user_id, animal_type) 
  VALUES (sample_user_id, 'dog');
  
  -- Sample generated photo
  INSERT INTO generated_photos (user_id, animal, generated_photo_url, status) 
  VALUES (sample_user_id, 'dog', '/generated/sample_with_dog.jpg', 'generated');
  
  -- Sample purchase
  INSERT INTO purchases (user_id, tier, price, status) 
  VALUES (sample_user_id, 'digital', 9.99, 'completed');
END $$;
*/

-- ============================================
-- STEP 14: Show database structure
-- ============================================

SELECT 
  table_name as "Table Name",
  COUNT(*) as "Number of Columns"
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name IN ('users', 'uploaded_photos', 'animal_choices', 'generated_photos', 'purchases', 'user_sessions')
GROUP BY table_name
ORDER BY table_name;

-- ============================================
-- Summary
-- ============================================

DO $$ 
BEGIN
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '✅ Database Setup Complete!';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Tables created:';
  RAISE NOTICE '   1. users - User sign-up information (Full Name, Email)';
  RAISE NOTICE '   2. uploaded_photos - Original user photos';
  RAISE NOTICE '   3. animal_choices - Selected animals';
  RAISE NOTICE '   4. generated_photos - AI-generated photos';
  RAISE NOTICE '   5. purchases - Payment transactions';
  RAISE NOTICE '   6. user_sessions - User progress tracking';
  RAISE NOTICE '';
  RAISE NOTICE '📈 Views created:';
  RAISE NOTICE '   - user_complete_journey - Full user workflow';
  RAISE NOTICE '   - popular_animals - Animal selection statistics';
  RAISE NOTICE '   - revenue_summary - Sales and revenue data';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Features enabled:';
  RAISE NOTICE '   - Row Level Security (RLS)';
  RAISE NOTICE '   - Auto-updated timestamps';
  RAISE NOTICE '   - Performance indexes';
  RAISE NOTICE '   - Data integrity constraints';
  RAISE NOTICE '';
  RAISE NOTICE '🔗 Your Animal Portrait Studio is ready!';
  RAISE NOTICE '   - Database: https://dqfbhilgrmqvclbxuhwf.supabase.co';
  RAISE NOTICE '   - App: http://localhost:3001';
  RAISE NOTICE '';
  RAISE NOTICE '📝 What each step captures:';
  RAISE NOTICE '   Step 1 (Sign Up) → users table';
  RAISE NOTICE '   Step 2 (Upload) → uploaded_photos table';
  RAISE NOTICE '   Step 3 (Choose) → animal_choices table';
  RAISE NOTICE '   Step 4 (Generate) → generated_photos table';
  RAISE NOTICE '   Step 5 (Purchase) → purchases table';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;
