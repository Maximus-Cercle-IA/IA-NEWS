-- Sources
create table if not exists sources (
  id text primary key,
  name text not null,
  url text not null default '',
  cat text not null default 'IA Générale',
  is_on boolean not null default true,
  position integer not null default 0,
  created_at timestamptz not null default now()
);

-- News
create table if not exists news (
  id text primary key,
  title text not null,
  source text not null default '',
  url text not null default '',
  date text not null default '',
  category text not null default 'IA Générale & Big Tech',
  summary text not null default '',
  full_text text not null default '',
  score integer not null default 0,
  scores jsonb,
  angles jsonb,
  week_key date not null,
  created_at timestamptz not null default now()
);

-- Favorites
create table if not exists favorites (
  id uuid primary key default gen_random_uuid(),
  news_id text not null references news(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(news_id)
);

-- RLS
alter table sources enable row level security;
alter table news enable row level security;
alter table favorites enable row level security;

create policy "anon_all" on sources for all to anon using (true) with check (true);
create policy "anon_all" on news for all to anon using (true) with check (true);
create policy "anon_all" on favorites for all to anon using (true) with check (true);

-- Sources par défaut (upsert)
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
