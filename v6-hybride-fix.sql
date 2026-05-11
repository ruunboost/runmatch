-- ============================================================
-- RUNBOOST — CORRECTIF OBJECTIF HYBRIDE
-- Ajoute 'hybride' aux chaussures vraiment polyvalentes
-- Retire 'hybride' aux chaussures purement vitesse
-- ============================================================

-- Chaussures polyvalentes : footing + tempo + sortie longue
UPDATE shoes SET objectif = array_append(objectif, 'hybride')
WHERE name IN (
  'Gel-Cumulus 28',
  'Gel-Cumulus 27',
  'Clifton 10',
  'Ghost 18',
  'Velocity Nitro 4',
  'Pegasus 42',
  'Wave Rider 29',
  'Ride 19',
  'Fresh Foam X 1080 V15',
  'Cloudmonster 3',
  'AeroGlide 4',
  'Novablast 5',
  'Mach 7',
  'CloudRunner 3',
  'Triumph 23',
  'FuelCell Rebel V5',
  'Magnify Nitro 3',
  'Gel-Nimbus 27',
  'Bondi 9',
  'Glycerin 23',
  'Wave Sky 9',
  'CloudSurfer 2',
  'Ellipse V1',
  'GT-1000 14',
  'Adrenaline GTS 25',
  'Arahi 8',
  'Guide 19',
  'Hurricane 25',
  'Wave Inspire 22',
  'ForeverRun Nitro 2'
)
AND NOT (objectif @> ARRAY['hybride']);

-- Chaussures purement vitesse/compétition : retirer 'hybride'
UPDATE shoes SET objectif = array_remove(objectif, 'hybride')
WHERE name IN (
  'Rincon 4',
  'Launch 12',
  'Hyperion 3',
  'Streakfly 2',
  'Adizero Adios 9',
  'Wave Rebellion Flash 3',
  'Mach X3',
  'Rocket X3',
  'Endorphin Speed 5',
  'FuelCell SuperComp Pacer V2',
  'Superblast 3',
  'AeroBlaze 3'
)
AND objectif @> ARRAY['hybride'];

