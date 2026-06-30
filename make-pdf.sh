#!/usr/bin/env bash
#
# make-pdf.sh — export a reveal.js deck to a clean 16:9, one-slide-per-page PDF
# with correct colours (white text on dark slides), bypassing the browser print
# dialog entirely.
#
# Usage:
#   ./make-pdf.sh [input.html] [output.pdf]
#
# Defaults: input  = money-creation-uk.html
#           output = <input without .html>.pdf
#
# Requirements: Google Chrome and Node.js (v18+ for the built-in WebSocket).
#
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT="${1:-money-creation-uk.html}"
# Resolve input to an absolute path.
case "$INPUT" in
  /*) ;;                       # already absolute
  *) INPUT="$DIR/$INPUT" ;;
esac
if [ ! -f "$INPUT" ]; then
  echo "Error: input file not found: $INPUT" >&2
  exit 1
fi
OUTPUT="${2:-${INPUT%.html}.pdf}"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME" ]; then
  CHROME="$(command -v google-chrome || command -v chromium || true)"
fi
if [ -z "$CHROME" ] || [ ! -x "$CHROME" ]; then
  echo "Error: Google Chrome not found." >&2
  exit 1
fi

PORT=9325
PROFILE="$(mktemp -d)"
cleanup() {
  kill "${CHROME_PID:-}" 2>/dev/null || true
  wait "${CHROME_PID:-}" 2>/dev/null || true
  rm -rf "$PROFILE" 2>/dev/null || true
}
trap cleanup EXIT

"$CHROME" --headless --disable-gpu --no-first-run --no-default-browser-check \
  --remote-debugging-port="$PORT" --user-data-dir="$PROFILE" \
  "file://$INPUT?print-pdf" >/dev/null 2>&1 &
CHROME_PID=$!

# Wait for the DevTools endpoint to come up.
for _ in $(seq 1 50); do
  if curl -s "http://localhost:$PORT/json/version" >/dev/null 2>&1; then break; fi
  sleep 0.2
done

INPUT="$INPUT" OUTPUT="$OUTPUT" PORT="$PORT" node <<'NODE'
const http = require('http');
const fs = require('fs');
const PORT = process.env.PORT, OUTPUT = process.env.OUTPUT;
const get = (u) => new Promise((res, rej) => {
  http.get(u, (r) => { let d = ''; r.on('data', c => d += c); r.on('end', () => res(JSON.parse(d))); }).on('error', rej);
});

(async () => {
  const tabs = await get(`http://localhost:${PORT}/json`);
  const page = tabs.find(t => t.type === 'page');
  if (!page) throw new Error('No page target found');

  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let id = 0; const pending = {};
  const send = (method, params = {}) => {
    const i = ++id;
    ws.send(JSON.stringify({ id: i, method, params }));
    return new Promise(r => (pending[i] = r));
  };
  ws.onmessage = (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pending[m.id]) { pending[m.id](m.result); delete pending[m.id]; }
  };
  await new Promise(r => (ws.onopen = r));

  await send('Runtime.enable');
  // reveal.js drops the `print-pdf` class under print media, which reverts the
  // deck to its reflowed "document" print mode (black headings, extra pages).
  // Continuously re-assert it so the slide-per-page layout is preserved, and
  // record when reveal signals its PDF layout is ready.
  await send('Runtime.evaluate', {
    expression: `
      window.__pdfReady = false;
      setInterval(() => document.documentElement.classList.add('print-pdf'), 40);
      (function hook() {
        if (typeof Reveal !== 'undefined' && Reveal.on) {
          Reveal.on('pdf-ready', () => { window.__pdfReady = true; });
        } else { setTimeout(hook, 50); }
      })();
    `
  });

  // Poll until reveal has built the multi-page PDF layout (or time out). We
  // treat it as ready when pdf-ready has fired AND every slide has been laid
  // out with a real height (so we never print a half-built deck).
  const probe = `JSON.stringify((() => {
    const secs = Array.from(document.querySelectorAll('.reveal .slides > section'));
    const laid = secs.filter(s => s.offsetHeight > 0).length;
    const imgs = Array.from(document.images);
    const imgsLoaded = imgs.filter(i => i.complete && i.naturalWidth > 0).length;
    return { ready: !!window.__pdfReady, total: secs.length, laid,
             imgs: imgs.length, imgsLoaded };
  })())`;
  const deadline = Date.now() + 30000;
  let state = { ready: false, total: 0, laid: 0, imgs: 0, imgsLoaded: 0 };
  while (Date.now() < deadline) {
    const r = await send('Runtime.evaluate', { expression: probe, returnByValue: true });
    state = JSON.parse(r.result.value);
    if (state.ready && state.total > 0 && state.laid === state.total
        && state.imgsLoaded === state.imgs) break;
    await new Promise(r => setTimeout(r, 200));
  }
  // Small settle for web fonts.
  await new Promise(r => setTimeout(r, 600));

  const { data } = await send('Page.printToPDF', {
    preferCSSPageSize: true,   // honour reveal's 16:9 @page size
    printBackground: true,     // print the navy/gold fills
    marginTop: 0, marginBottom: 0, marginLeft: 0, marginRight: 0
  });
  fs.writeFileSync(OUTPUT, Buffer.from(data, 'base64'));
  ws.close();
  process.exit(0);
})().catch(err => { console.error(err); process.exit(1); });
NODE

echo "Wrote $OUTPUT"
