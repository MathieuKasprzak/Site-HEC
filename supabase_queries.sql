-- ============================================
-- REQUÊTES SQL POUR VISUALISER LES DONNÉES
-- Animal Portrait Studio - Supabase
-- ============================================

-- ============================================
-- 1. VUE COMPLÈTE : Tous les utilisateurs avec leurs photos et paiements
-- ============================================
SELECT 
  u.id AS user_id,
  u.full_name AS "Nom complet",
  u.email AS "Email",
  u.created_at AS "Date d'inscription",
  COUNT(DISTINCT gp.id) AS "Nombre de photos générées",
  COUNT(DISTINCT p.id) AS "Nombre de paiements",
  COALESCE(SUM(p.price), 0) AS "Total dépensé ($)",
  STRING_AGG(DISTINCT gp.animal, ', ') AS "Animaux choisis"
FROM users u
LEFT JOIN generated_photos gp ON u.id = gp.user_id
LEFT JOIN purchases p ON u.id = p.user_id
GROUP BY u.id, u.full_name, u.email, u.created_at
ORDER BY u.created_at DESC;

-- ============================================
-- 2. DÉTAILS DES UTILISATEURS
-- ============================================
SELECT 
  id,
  full_name AS "Nom complet",
  email AS "Email",
  created_at AS "Inscrit le",
  updated_at AS "Mis à jour le"
FROM users
ORDER BY created_at DESC;

-- ============================================
-- 3. PHOTOS GÉNÉRÉES PAR UTILISATEUR
-- ============================================
SELECT 
  u.full_name AS "Nom complet",
  u.email AS "Email",
  gp.animal AS "Animal",
  gp.status AS "Statut",
  gp.created_at AS "Généré le"
FROM generated_photos gp
JOIN users u ON gp.user_id = u.id
ORDER BY gp.created_at DESC;

-- ============================================
-- 4. PAIEMENTS PAR UTILISATEUR
-- ============================================
SELECT 
  u.full_name AS "Nom complet",
  u.email AS "Email",
  p.tier AS "Forfait",
  p.price AS "Prix ($)",
  p.status AS "Statut",
  p.created_at AS "Date du paiement"
FROM purchases p
JOIN users u ON p.user_id = u.id
ORDER BY p.created_at DESC;

-- ============================================
-- 5. STATISTIQUES GLOBALES
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM users) AS "Total utilisateurs",
  (SELECT COUNT(*) FROM generated_photos) AS "Total photos générées",
  (SELECT COUNT(*) FROM purchases) AS "Total paiements",
  (SELECT COALESCE(SUM(price), 0) FROM purchases) AS "Revenu total ($)",
  (SELECT COALESCE(AVG(price), 0) FROM purchases) AS "Panier moyen ($)";

-- ============================================
-- 6. ANIMAUX LES PLUS POPULAIRES
-- ============================================
SELECT 
  animal AS "Animal",
  COUNT(*) AS "Nombre de générations",
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM generated_photos), 2) AS "Pourcentage (%)"
FROM generated_photos
GROUP BY animal
ORDER BY COUNT(*) DESC;

-- ============================================
-- 7. FORFAITS LES PLUS VENDUS
-- ============================================
SELECT 
  tier AS "Forfait",
  COUNT(*) AS "Nombre de ventes",
  SUM(price) AS "Revenu total ($)",
  AVG(price) AS "Prix moyen ($)"
FROM purchases
GROUP BY tier
ORDER BY COUNT(*) DESC;

-- ============================================
-- 8. ACTIVITÉ PAR JOUR
-- ============================================
SELECT 
  DATE(created_at) AS "Date",
  COUNT(DISTINCT user_id) AS "Nouveaux utilisateurs",
  (SELECT COUNT(*) FROM generated_photos WHERE DATE(created_at) = DATE(u.created_at)) AS "Photos générées",
  (SELECT COUNT(*) FROM purchases WHERE DATE(created_at) = DATE(u.created_at)) AS "Paiements"
FROM users u
GROUP BY DATE(created_at)
ORDER BY DATE(created_at) DESC;

-- ============================================
-- 9. UTILISATEURS AVEC LEURS DERNIÈRES ACTIVITÉS
-- ============================================
SELECT 
  u.full_name AS "Nom complet",
  u.email AS "Email",
  u.created_at AS "Inscrit le",
  (SELECT COUNT(*) FROM generated_photos WHERE user_id = u.id) AS "Photos",
  (SELECT COUNT(*) FROM purchases WHERE user_id = u.id) AS "Paiements",
  (SELECT MAX(created_at) FROM generated_photos WHERE user_id = u.id) AS "Dernière photo",
  (SELECT MAX(created_at) FROM purchases WHERE user_id = u.id) AS "Dernier paiement"
FROM users u
ORDER BY u.created_at DESC;

-- ============================================
-- 10. RAPPORT COMPLET DÉTAILLÉ
-- ============================================
SELECT 
  u.id,
  u.full_name AS "Nom complet",
  u.email AS "Email",
  u.created_at AS "Inscription",
  gp.animal AS "Animal choisi",
  gp.created_at AS "Photo générée le",
  p.tier AS "Forfait acheté",
  p.price AS "Prix payé ($)",
  p.created_at AS "Date paiement"
FROM users u
LEFT JOIN generated_photos gp ON u.id = gp.user_id
LEFT JOIN purchases p ON u.id = p.user_id
ORDER BY u.created_at DESC, gp.created_at DESC;
