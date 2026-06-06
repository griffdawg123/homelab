#!/bin/sh
STATIC=/mnt/stowage/stowage-share/static
TMP="$STATIC/index.html.tmp"
UPDATED=$(date '+%d %b %Y, %H:%M')

cat > "$TMP" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>static.griffdawg.dev</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg: #0d0d0d;
      --surface: #161616;
      --border: #2a2a2a;
      --text: #e8e8e8;
      --muted: #666;
      --accent: #7c6af7;
      --accent-hover: #9d8fff;
      --radius: 10px;
    }

    body {
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      min-height: 100vh;
      padding: 60px 24px;
    }

    .container {
      max-width: 680px;
      margin: 0 auto;
    }

    header {
      margin-bottom: 48px;
    }

    .domain {
      font-size: 0.8rem;
      font-weight: 500;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--accent);
      margin-bottom: 12px;
    }

    h1 {
      font-size: 1.75rem;
      font-weight: 600;
      letter-spacing: -0.02em;
      color: var(--text);
    }

    h1 span {
      color: var(--muted);
      font-weight: 400;
    }

    .grid {
      display: grid;
      gap: 10px;
    }

    .card {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px 20px;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      text-decoration: none;
      color: var(--text);
      transition: border-color 0.15s, background 0.15s;
    }

    .card:hover {
      border-color: var(--accent);
      background: #1a1a2e;
    }

    .card-icon {
      font-size: 1.2rem;
      flex-shrink: 0;
      width: 28px;
      text-align: center;
    }

    .card-title {
      font-size: 0.95rem;
      font-weight: 500;
    }

    .card-arrow {
      margin-left: auto;
      color: var(--muted);
      font-size: 0.85rem;
      transition: color 0.15s, transform 0.15s;
    }

    .card:hover .card-arrow {
      color: var(--accent-hover);
      transform: translateX(3px);
    }

    .empty {
      color: var(--muted);
      font-size: 0.9rem;
      padding: 32px 0;
    }

    footer {
      margin-top: 48px;
      font-size: 0.78rem;
      color: var(--muted);
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div class="domain">static.griffdawg.dev</div>
      <h1>Files <span>&amp; pages</span></h1>
    </header>
    <div class="grid" id="grid">
HTMLEOF

count=0

# Subdirectories first
for d in "$STATIC"/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  printf '      <a class="card" href="%s/">\n        <span class="card-icon">📁</span>\n        <span class="card-title">%s</span>\n        <span class="card-arrow">→</span>\n      </a>\n' \
    "$name" "$name" >> "$TMP"
  count=$((count + 1))
done

# HTML files (skip index.html)
for f in "$STATIC"/*.html; do
  [ -f "$f" ] || continue
  fn=$(basename "$f")
  [ "$fn" = "index.html" ] && continue
  title=$(echo "${fn%.html}" | tr '_-' '  ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
  printf '      <a class="card" href="%s">\n        <span class="card-icon">📄</span>\n        <span class="card-title">%s</span>\n        <span class="card-arrow">→</span>\n      </a>\n' \
    "$fn" "$title" >> "$TMP"
  count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
  printf '      <p class="empty">Nothing here yet.</p>\n' >> "$TMP"
fi

cat >> "$TMP" << HTMLEOF
    </div>
    <footer>Updated $UPDATED</footer>
  </div>
</body>
</html>
HTMLEOF

mv "$TMP" "$STATIC/index.html"
