# Guide de déploiement — RunMatch sur Supabase + Vercel

## Ce que tu vas avoir à la fin
- Un site en ligne, accessible sur une URL publique
- Une vraie base de données avec tes chaussures
- Les prix mis à jour facilement depuis un tableau de bord
- Tout ça gratuitement

---

## Étape 1 — Créer ta base de données Supabase (15 min)

### 1.1 Créer un compte
1. Va sur **https://supabase.com**
2. Clique "Start your project" → connecte-toi avec GitHub ou email
3. Clique "New project"
4. Remplis :
   - **Name** : `runmatch`
   - **Database Password** : génère un mot de passe fort et **note-le**
   - **Region** : West EU (Ireland) — le plus proche de Paris
5. Clique "Create new project" — attends ~2 minutes

### 1.2 Créer les tables
Dans Supabase, va dans **SQL Editor** (icône en forme de terminal à gauche) et colle ce code SQL, puis clique "Run" :

```sql
-- Table principale des chaussures
CREATE TABLE shoes (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  brand TEXT NOT NULL,
  surface TEXT NOT NULL CHECK (surface IN ('route', 'trail')),
  niveau TEXT[] NOT NULL,
  foulee TEXT[] NOT NULL,
  drop_mm INTEGER NOT NULL,
  poids_g INTEGER NOT NULL,
  amorti TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des prix par revendeur
CREATE TABLE prices (
  id BIGSERIAL PRIMARY KEY,
  shoe_id BIGINT REFERENCES shoes(id) ON DELETE CASCADE,
  revendeur TEXT NOT NULL,
  prix DECIMAL(8,2) NOT NULL,
  url_affiliation TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des scores de compatibilité
CREATE TABLE scores (
  id BIGSERIAL PRIMARY KEY,
  shoe_id BIGINT REFERENCES shoes(id) ON DELETE CASCADE,
  niveau TEXT NOT NULL,
  score INTEGER NOT NULL CHECK (score BETWEEN 0 AND 100)
);

-- Activer la lecture publique (pas besoin de compte pour lire)
ALTER TABLE shoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lecture publique shoes" ON shoes FOR SELECT USING (true);
CREATE POLICY "Lecture publique prices" ON prices FOR SELECT USING (true);
CREATE POLICY "Lecture publique scores" ON scores FOR SELECT USING (true);
```

### 1.3 Remplir la base avec les données initiales
Toujours dans SQL Editor, colle et lance ce second bloc :

```sql
-- Insérer les chaussures
INSERT INTO shoes (name, brand, surface, niveau, foulee, drop_mm, poids_g, amorti, description) VALUES
('Gel-Kayano 30', 'ASICS', 'route', ARRAY['debutant','intermediaire'], ARRAY['pronateur','neutre'], 10, 310, 'Maximal', 'Maintien et amorti maximal — parfaite pour les longues sorties'),
('Vomero 17', 'Nike', 'route', ARRAY['intermediaire','expert'], ARRAY['neutre','supinateur'], 10, 295, 'Maximal', 'Confort premium pour longue distance'),
('Fresh Foam X 1080v13', 'New Balance', 'route', ARRAY['debutant','intermediaire','expert'], ARRAY['neutre','supinateur'], 8, 280, 'Maximal', 'Douceur et réactivité, polyvalente par excellence'),
('Pegasus 41', 'Nike', 'route', ARRAY['debutant','intermediaire'], ARRAY['neutre'], 10, 265, 'Modéré', 'Le best-seller polyvalent depuis 40 ans'),
('Adrenaline GTS 23', 'Brooks', 'route', ARRAY['debutant','intermediaire'], ARRAY['pronateur'], 12, 285, 'Modéré', 'Stabilité optimale pour les pronateurs'),
('Clifton 9', 'Hoka', 'route', ARRAY['debutant','intermediaire'], ARRAY['neutre','supinateur'], 5, 260, 'Maximal', 'Amorti légendaire Hoka dans un format léger'),
('Speedgoat 5', 'Hoka', 'trail', ARRAY['debutant','intermediaire','expert'], ARRAY['neutre','supinateur'], 4, 298, 'Maximal', 'La référence trail toutes conditions'),
('Peregrine 14', 'Saucony', 'trail', ARRAY['intermediaire','expert'], ARRAY['neutre'], 4, 278, 'Minimal', 'Légèreté et grip en terrain technique'),
('Sense Ride 5', 'Salomon', 'trail', ARRAY['debutant','intermediaire'], ARRAY['pronateur','neutre'], 6, 295, 'Modéré', 'Polyvalente trail accessible'),
('Alphafly 3', 'Nike', 'route', ARRAY['expert'], ARRAY['neutre'], 8, 225, 'Modéré', 'Plaque carbone — performance absolue en course');

-- Insérer les prix (shoe_id correspond à l'ordre d'insertion ci-dessus)
INSERT INTO prices (shoe_id, revendeur, prix, url_affiliation) VALUES
(1, 'Alltricks', 179.99, 'https://www.alltricks.fr'),
(1, 'Decathlon', 189.99, 'https://www.decathlon.fr'),
(2, 'Nike.com', 169.99, 'https://www.nike.com/fr'),
(3, 'Running Warehouse', 209.99, 'https://www.runningwarehouse.eu'),
(4, 'Nike.com', 139.99, 'https://www.nike.com/fr'),
(5, 'Alltricks', 134.99, 'https://www.alltricks.fr'),
(6, 'Hoka.com', 154.99, 'https://www.hoka.com/fr'),
(7, 'Alltricks', 164.99, 'https://www.alltricks.fr'),
(8, 'Saucony.com', 139.99, 'https://www.saucony.com/fr'),
(9, 'Salomon', 129.99, 'https://www.salomon.com/fr'),
(10, 'Nike.com', 284.99, 'https://www.nike.com/fr');

-- Insérer les scores
INSERT INTO scores (shoe_id, niveau, score) VALUES
(1, 'debutant', 95), (1, 'intermediaire', 88), (1, 'expert', 60),
(2, 'debutant', 80), (2, 'intermediaire', 92), (2, 'expert', 75),
(3, 'debutant', 85), (3, 'intermediaire', 90), (3, 'expert', 88),
(4, 'debutant', 82), (4, 'intermediaire', 85), (4, 'expert', 72),
(5, 'debutant', 93), (5, 'intermediaire', 82), (5, 'expert', 55),
(6, 'debutant', 90), (6, 'intermediaire', 87), (6, 'expert', 68),
(7, 'debutant', 88), (7, 'intermediaire', 92), (7, 'expert', 85),
(8, 'debutant', 65), (8, 'intermediaire', 88), (8, 'expert', 92),
(9, 'debutant', 85), (9, 'intermediaire', 86), (9, 'expert', 70),
(10, 'debutant', 50), (10, 'intermediaire', 72), (10, 'expert', 98);
```

### 1.4 Récupérer tes clés API
1. Dans Supabase, va dans **Settings → API** (icône engrenage)
2. Copie et note ces deux valeurs :
   - **Project URL** : ressemble à `https://xxxxxxxxxxxx.supabase.co`
   - **anon public key** : une longue chaîne qui commence par `eyJ...`

---

## Étape 2 — Mettre le site en ligne sur Vercel (10 min)

### 2.1 Créer un compte GitHub (si pas déjà fait)
Va sur **https://github.com** et crée un compte gratuit.

### 2.2 Créer un dépôt GitHub
1. Sur GitHub, clique le **+** en haut à droite → "New repository"
2. Nomme-le `runmatch`
3. Laisse tout par défaut, clique "Create repository"
4. Sur la page suivante, clique "uploading an existing file"
5. Glisse-dépose le fichier `index.html` que tu as téléchargé (la version connectée Supabase)
6. Clique "Commit changes"

### 2.3 Déployer sur Vercel
1. Va sur **https://vercel.com**
2. Connecte-toi avec GitHub
3. Clique "Add New Project"
4. Sélectionne ton dépôt `runmatch`
5. Dans la section **Environment Variables**, ajoute :
   - `SUPABASE_URL` → ta Project URL
   - `SUPABASE_ANON_KEY` → ta anon public key
6. Clique "Deploy"

Ton site sera en ligne en ~1 minute sur une URL du type `runmatch.vercel.app` 🎉

---

## Étape 3 — Gérer ta base de données

### Ajouter une chaussure
Dans Supabase → **Table Editor** → sélectionne la table `shoes` → clique "Insert row" et remplis les champs.

### Mettre à jour un prix
Dans **Table Editor** → table `prices` → clique sur la ligne à modifier.

### Voir les données
Supabase a un tableau de bord visuel pour voir et modifier toutes tes données sans toucher au code.

---

## Récapitulatif des coûts

| Service | Plan | Coût |
|---------|------|------|
| Supabase | Free | 0 € (500 MB, 50 000 req/mois) |
| Vercel | Hobby | 0 € (100 GB bande passante) |
| Domaine (optionnel) | — | ~12 €/an |

**Total pour démarrer : 0 €**
