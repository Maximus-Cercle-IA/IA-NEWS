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

-- Sources par défaut
insert into sources (id, name, url, cat, is_on, position) values
  ('s1', 'Le Monde IA',           'https://www.lemonde.fr/intelligence-artificielle/', 'IA Générale',    true, 1),
  ('s2', 'MIT Technology Review', 'https://www.technologyreview.com/topic/artificial-intelligence/', 'IA Générale', true, 2),
  ('s3', 'Numerama',              'https://www.numerama.com/tech/', 'IA Générale',    true, 3),
  ('s4', 'Journal du Net IA',     'https://www.journaldunet.com/intelligence-artificielle/', 'Métiers', true, 4),
  ('s5', 'CNIL Actualités',       'https://www.cnil.fr/fr/actualites', 'Réglementation', true, 5),
  ('s6', 'HBR France',            'https://www.hbrfrance.fr/', 'Métiers',            true, 6),
  ('s7', 'The Conversation FR',   'https://theconversation.com/fr', 'Société',        true, 7),
  ('s8', 'TechCrunch AI',         'https://techcrunch.com/category/artificial-intelligence/', 'IA Générale', true, 8)
on conflict (id) do nothing;
