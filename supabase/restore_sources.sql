-- Restauration des 11 sources Cercle IA
-- Coller dans Supabase > SQL Editor > Run

insert into sources (id, name, url, cat, is_on, position) values
  ('s1',  'The Verge AI',      'https://www.theverge.com/ai-artificial-intelligence',           'IA Générale',     true, 1),
  ('s2',  'MIT Tech Review',   'https://www.technologyreview.com/',                              'IA Générale',     true, 2),
  ('s3',  'HBR France',        'https://www.hbrfrance.fr/innovation',                            'Dirigeants / RH', true, 3),
  ('s4',  'Artificial Lawyer', 'https://www.artificiallawyer.com/',                              'Métiers',         true, 4),
  ('s5',  'Le Monde IA',       'https://www.lemonde.fr/intelligence-artificielle/',              'IA Générale',     true, 5),
  ('s6',  'IAPP',              'https://iapp.org/news/a',                                        'Réglementation',  true, 6),
  ('s7',  'Bens Bites',        'https://www.bensbites.com',                                      'Outils',          true, 7),
  ('s8',  'Legal Geek',        'https://www.legalgeek.co/blog',                                  'Métiers',         true, 8),
  ('s9',  'HR Executive',      'https://hrexecutive.com/category/hr-technology',                 'Métiers',         true, 9),
  ('s10', 'Usbek & Rica',      'https://usbeketrica.com/fr/tech-and-innovation',                 'Société',         true, 10),
  ('s11', 'FutureTools',       'https://futuretools.io/news',                                    'Outils',          true, 11)
on conflict (id) do update set
  name = excluded.name,
  url = excluded.url,
  cat = excluded.cat,
  is_on = excluded.is_on,
  position = excluded.position;
