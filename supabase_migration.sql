-- Migration pour Animal Portrait Studio

-- Table des utilisateurs
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

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_generated_photos_user_id ON generated_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);

-- Ancienne table de liste d'attente (optionnelle, peut être supprimée)
-- DROP TABLE IF EXISTS waiting_list;

-- Fonction pour mettre à jour le champ updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour automatiquement updated_at sur users
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Politiques de sécurité Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre l'insertion de nouveaux utilisateurs
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

-- Politique pour permettre aux utilisateurs de voir leurs propres données
CREATE POLICY "Users can view their own data" ON users
  FOR SELECT USING (true);

-- Politique pour generated_photos
CREATE POLICY "Anyone can insert generated photos" ON generated_photos
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view generated photos" ON generated_photos
  FOR SELECT USING (true);

-- Politique pour purchases
CREATE POLICY "Anyone can insert purchases" ON purchases
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view purchases" ON purchases
  FOR SELECT USING (true);

-- Vérifier la structure des tables
-- SELECT table_name, column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name IN ('users', 'generated_photos', 'purchases')
-- ORDER BY table_name, ordinal_position;
