export const config = { runtime: 'edge' };

export default async function handler(req) {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (req.method === 'OPTIONS') return new Response(null, { status: 200, headers: cors });
  if (req.method !== 'POST') return new Response(
    JSON.stringify({ error: 'Method not allowed' }),
    { status: 405, headers: { ...cors, 'Content-Type': 'application/json' } }
  );

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) return new Response(
    JSON.stringify({ error: 'Clé API manquante — ajoutez ANTHROPIC_API_KEY dans les variables Vercel' }),
    { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
  );

  try {
    const body = await req.json();
    const tools = [{ type: 'web_search_20260209', name: 'web_search', max_uses: 3 }];
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({ ...body, tools, stream: true }),
    });

    if (!r.ok) {
      const data = await r.json();
      return new Response(JSON.stringify(data), {
        status: r.status,
        headers: { ...cors, 'Content-Type': 'application/json', 'X-Proxy-Error-Source': 'anthropic' },
      });
    }

    return new Response(r.body, {
      headers: { ...cors, 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache', 'X-Accel-Buffering': 'no' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
}
