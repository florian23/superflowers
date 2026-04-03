#!/usr/bin/env bash
# Serve frontend-design HTML files with an auto-generated index page.
# Auto-detects Tailscale for VPN access from other machines.
#
# Usage: serve-designs.sh [--dir <path>] [--port <port>]
#   --dir   Directory containing HTML files (default: current directory)
#   --port  Port to serve on (default: 8090)

set -euo pipefail

SERVE_DIR="."
PORT=8090

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) SERVE_DIR="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

SERVE_DIR="$(cd "$SERVE_DIR" && pwd)"

# Auto-detect Tailscale
BIND_HOST="0.0.0.0"
URL_HOST="localhost"
if command -v tailscale &>/dev/null; then
  TS_IP=$(tailscale ip -4 2>/dev/null || true)
  if [[ -n "$TS_IP" ]]; then
    URL_HOST="$TS_IP"
  fi
fi

# Generate index.html listing all HTML files
generate_index() {
  local dir="$1"
  local index_file="$dir/.design-index.html"

  cat > "$index_file" << 'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Design Preview</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0a0a0a; color: #e0e0e0; padding: 2rem; }
    h1 { font-size: 1.5rem; margin-bottom: 0.5rem; color: #fff; }
    .subtitle { color: #888; margin-bottom: 2rem; font-size: 0.9rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; }
    .card { background: #1a1a1a; border: 1px solid #333; border-radius: 8px; overflow: hidden; transition: border-color 0.2s; }
    .card:hover { border-color: #666; }
    .card a { text-decoration: none; color: inherit; display: block; }
    .card .preview { width: 100%; height: 200px; border: none; pointer-events: none; background: #111; }
    .card .info { padding: 1rem; }
    .card .name { font-weight: 600; color: #fff; margin-bottom: 0.25rem; }
    .card .meta { font-size: 0.8rem; color: #666; }
    .empty { text-align: center; padding: 4rem; color: #666; }
    .refresh { position: fixed; bottom: 1.5rem; right: 1.5rem; background: #333; color: #fff; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; font-size: 0.85rem; }
    .refresh:hover { background: #444; }
  </style>
</head>
<body>
  <h1>Design Preview</h1>
  <p class="subtitle">Generated HTML files from frontend-design</p>
  <div class="grid">
HEADER

  local count=0
  # Find all .html files except the index itself, sorted by modification time (newest first)
  while IFS= read -r -d '' file; do
    local basename=$(basename "$file")
    local relpath="${file#$dir/}"
    local modified=$(stat -c '%Y' "$file" 2>/dev/null || stat -f '%m' "$file" 2>/dev/null)
    local modified_human=$(date -d "@$modified" '+%Y-%m-%d %H:%M' 2>/dev/null || date -r "$modified" '+%Y-%m-%d %H:%M' 2>/dev/null)
    local size=$(stat -c '%s' "$file" 2>/dev/null || stat -f '%z' "$file" 2>/dev/null)
    local size_human=$(numfmt --to=iec "$size" 2>/dev/null || echo "${size}B")

    cat >> "$index_file" << CARD
    <div class="card">
      <a href="$relpath" target="_blank">
        <iframe class="preview" src="$relpath" loading="lazy" sandbox></iframe>
        <div class="info">
          <div class="name">$basename</div>
          <div class="meta">$modified_human &middot; $size_human</div>
        </div>
      </a>
    </div>
CARD
    count=$((count + 1))
  done < <(find "$dir" -maxdepth 2 -name '*.html' ! -name '.design-index.html' -print0 | sort -z -t/ -k2)

  if [[ $count -eq 0 ]]; then
    echo '    <div class="empty">No HTML files found yet. Run frontend-design to generate screens.</div>' >> "$index_file"
  fi

  cat >> "$index_file" << 'FOOTER'
  </div>
  <button class="refresh" onclick="location.reload()">Refresh</button>
  <script>setTimeout(() => location.reload(), 30000);</script>
</body>
</html>
FOOTER

  echo "$index_file"
}

# Generate initial index
INDEX=$(generate_index "$SERVE_DIR")

echo "Serving designs from: $SERVE_DIR"
echo "URL: http://$URL_HOST:$PORT"
echo "Index: http://$URL_HOST:$PORT/.design-index.html"
echo ""
echo "Press Ctrl+C to stop"

# Regenerate index on each request by using a wrapper
# Python's http.server serves files directly; we regenerate index periodically
(
  while true; do
    sleep 10
    generate_index "$SERVE_DIR" > /dev/null 2>&1
  done
) &
REGEN_PID=$!
trap "kill $REGEN_PID 2>/dev/null; exit 0" INT TERM

# Serve
cd "$SERVE_DIR"
python3 -m http.server "$PORT" --bind "$BIND_HOST" 2>&1
