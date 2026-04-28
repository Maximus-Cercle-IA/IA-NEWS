const https = require('https');
const http = require('http');

function get(url, timeout) {
  return new Promise((resolve, reject) => {
    const mod = url.startsWith('https://') ? https : http;
    let done = false;
    const req = mod.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
        'Accept': 'application/rss+xml,application/atom+xml,text/xml,application/xml,text/html;q=0.8,*/*;q=0.5',
        'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8',
      },
    }, res => {
      if ([301, 302, 303, 307, 308].includes(res.statusCode) && res.headers.location) {
        res.resume();
        let next;
        try { next = new URL(res.headers.location, url).href; } catch { return reject(new Error('bad redirect')); }
        return get(next, timeout).then(resolve, reject);
      }
      if (res.statusCode !== 200) { res.resume(); return reject(new Error('HTTP ' + res.statusCode)); }
      const chunks = [];
      let total = 0;
      res.on('data', c => { total += c.length; if (total < 600000) chunks.push(c); });
      res.on('end', () => { done = true; resolve(Buffer.concat(chunks).toString('utf8')); });
      res.on('error', reject);
    });
    req.setTimeout(timeout, () => { if (!done) { req.destroy(); reject(new Error('timeout')); } });
    req.on('error', reject);
  });
}

function isFeed(text) {
  return /^\s*<\?xml|^\s*<rss|^\s*<feed|^\s*<rdf:RDF/i.test(text.slice(0, 600));
}

function txt(block, tag) {
  const m = block.match(new RegExp(`<${tag}[^>]*>(?:<!\\[CDATA\\[)?([\\s\\S]*?)(?:\\]\\]>)?<\\/${tag}>`, 'i'));
  return m ? m[1].replace(/<[^>]+>/g, '').trim() : '';
}

function getLink(block) {
  // RSS 2.0
  const rss = block.match(/<link>([^<]+)<\/link>/i);
  if (rss && rss[1].startsWith('http')) return rss[1].trim();
  // Atom
  const atom = block.match(/<link\b[^>]+href="([^"]+)"(?![^>]*rel="self")[^>]*>/i);
  if (atom) return atom[1];
  return '';
}

function fmtDate(d) {
  return `${String(d.getDate()).padStart(2,'0')}/${String(d.getMonth()+1).padStart(2,'0')}/${d.getFullYear()}`;
}

function parseFeed(xml) {
  const cutoff = Date.now() - 7 * 24 * 60 * 60 * 1000;
  const items = [];
  const rx = /<(?:item|entry)\b[^>]*>([\s\S]*?)<\/(?:item|entry)>/gi;
  let m;
  while ((m = rx.exec(xml)) !== null) {
    const b = m[1];
    const title = txt(b, 'title');
    const url = getLink(b);
    if (!title || !url) continue;
    const ds = txt(b, 'pubDate') || txt(b, 'published') || txt(b, 'updated') || txt(b, 'dc:date');
    const d = ds ? new Date(ds) : new Date();
    if (!isNaN(d.getTime()) && d.getTime() >= cutoff) {
      items.push({ title, url, date: fmtDate(d) });
    }
  }
  return items;
}

function findRSSInHTML(html, base) {
  const rx = /<link\b[^>]+type="application\/(?:rss|atom)\+xml"[^>]+href="([^"]+)"/gi;
  const m = rx.exec(html);
  if (!m) return null;
  try { return new URL(m[1], base).href; } catch { return null; }
}

async function fetchFeedForSource(srcUrl) {
  let base;
  try { base = new URL(srcUrl); } catch { return []; }
  const origin = base.origin;
  const path = srcUrl.replace(/\/?$/, '');

  const candidates = [
    path + '/feed/',
    path + '/feed',
    path + '/rss.xml',
    path + '/rss/',
    origin + '/feed/',
    origin + '/rss.xml',
    origin + '/atom.xml',
    origin + '/feed.xml',
  ];

  // Try all candidates in parallel — return first valid feed
  try {
    return await Promise.any(
      candidates.map(url =>
        get(url, 6000).then(text => {
          if (!isFeed(text)) throw new Error('not a feed');
          const items = parseFeed(text);
          if (!items.length) throw new Error('empty');
          return items;
        })
      )
    );
  } catch {
    // Fallback: fetch source HTML, look for <link rel="alternate"> RSS tag
    try {
      const html = await get(srcUrl, 6000);
      const rssUrl = findRSSInHTML(html, srcUrl);
      if (rssUrl) {
        const xml = await get(rssUrl, 6000);
        return parseFeed(xml);
      }
    } catch {}
    return [];
  }
}

const CAT_MAP = {
  'IA Générale': 'IA Générale & Big Tech',
  'Dirigeants / RH': 'Métiers & Professions',
  'Métiers': 'Métiers & Professions',
  'Réglementation': 'Réglementation & Éthique',
  'Outils': 'Outils & Usages Pratiques',
  'Société': 'Société & Emploi',
};

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { sources } = req.body || {};
  if (!Array.isArray(sources) || !sources.length) {
    return res.status(400).json({ error: 'sources array required' });
  }

  const allResults = await Promise.all(
    sources.map(async src => {
      try {
        const items = await fetchFeedForSource(src.url);
        const cat = CAT_MAP[src.cat] || 'IA Générale & Big Tech';
        return items.slice(0, 3).map(item => ({
          id: 'n' + Math.random().toString(36).slice(2, 8),
          title: item.title,
          source: src.name,
          url: item.url,
          date: item.date,
          category: cat,
        }));
      } catch { return []; }
    })
  );

  res.status(200).json(allResults.flat());
};
