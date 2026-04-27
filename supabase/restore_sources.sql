-- Restauration des 11 sources Cercle IA
-- Coller dans Supabase > SQL Editor > Run

insert into sources (id, name, url, cat, is_on, position) values
  ('s1',  'The Verge AI',          'https://www.theverge.com/ai-artificial-intelligence', 'IA Générale',    true,  1),
  ('s2',  'MIT Technology Review', 'https://www.technologyreview.com/topic/artificial-intelligence/', 'IA Générale', true, 2),
  ('s3',  'HBR France',            'https://www.hbrfrance.fr/',                            'Métiers',        true,  3),
  ('s4',  'TechCrunch AI',         'https://techcrunch.com/category/artificial-intelligence/', 'IA Générale', true, 4),
  ('s5',  'CNIL Actualités',       'https://www.cnil.fr/fr/actualites',                   'Réglementation', true,  5),
  ('s6',  'Le Monde IA',           'https://www.lemonde.fr/intelligence-artificielle/',   'IA Générale',    true,  6),
  ('s7',  'Journal du Net IA',     'https://www.journaldunet.com/intelligence-artificielle/', 'Métiers',    true,  7),
  ('s8',  'The Conversation FR',   'https://theconversation.com/fr',                      'Société',        true,  8),
  ('s9',  'Numerama Tech',         'https://www.numerama.com/tech/',                      'IA Générale',    true,  9),
  ('s10', 'Wired AI',              'https://www.wired.com/tag/artificial-intelligence/',  'IA Générale',    true,  10),
  ('s11', 'Les Echos Tech',        'https://www.lesechos.fr/tech-medias/intelligence-artificielle/', 'Métiers', true, 11)
on conflict (id) do update set
  name = excluded.name,
  url = excluded.url,
  cat = excluded.cat,
  is_on = excluded.is_on,
  position = excluded.position;
