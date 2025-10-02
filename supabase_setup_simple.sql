-- ============================================
-- Simple SQL Setup for Animal Portrait Studio
-- Capture Full Name and Email from users
-- ============================================

-- ============================================
-- Create the users table
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Create indexes for better performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- ============================================
-- Enable Row Level Security
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Create RLS Policies (allow public access for demo)
-- ============================================

-- Allow anyone to insert users (for sign up)
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

-- Allow anyone to view users
CREATE POLICY "Anyone can view users" ON users
  FOR SELECT USING (true);

-- Allow anyone to update users
CREATE POLICY "Anyone can update users" ON users
  FOR UPDATE USING (true);

-- ============================================
-- Create trigger for automatic updated_at
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
-- Test: Insert sample data (optional)
-- ============================================

-- Uncomment to test
-- INSERT INTO users (full_name, email) VALUES ('John Doe', 'john@example.com');
-- INSERT INTO users (full_name, email) VALUES ('Jane Smith', 'jane@example.com');

-- ============================================
-- View the users table structure
-- ============================================

SELECT 
  column_name as "Column Name",
  data_type as "Data Type",
  is_nullable as "Nullable",
  column_default as "Default Value"
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- ============================================
-- Query to view all users with Full Name and Email
-- ============================================

SELECT 
  full_name AS "Full Name",
  email AS "Email",
  created_at AS "Created At"
FROM users
ORDER BY created_at DESC;

-- ============================================
-- Summary
-- ============================================

DO $$ 
BEGIN
  RAISE NOTICE '✅ Table "users" created successfully!';
  RAISE NOTICE '✅ Columns: full_name, email, created_at, updated_at';
  RAISE NOTICE '✅ Your form will now save:';
  RAISE NOTICE '   - Full Name → users.full_name';
  RAISE NOTICE '   - Email Address → users.email';
END $$;
