#!/usr/bin/env python3
"""
Fix asset dates in Immich by parsing dates from filenames.

Supported patterns:
  Screenshot_20200409-100810.png
  image_20251203153411.jpg
  image-1635538844306495_20260314080857.jpg
"""

import re
import sys
import json
import argparse
from datetime import datetime, timezone, timedelta
from urllib.request import Request, urlopen
from urllib.error import HTTPError

PATTERNS = [
    re.compile(r'Screenshot_(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})'),
    re.compile(r'image-\d+_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})'),
    re.compile(r'image_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})'),
    # 20231214_001025.jpg  and  IMG_20171027_121518_993.jpg
    re.compile(r'(?<!\d)(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})(?!\d)'),
]

def parse_date_from_filename(filename):
    for pattern in PATTERNS:
        m = pattern.search(filename)
        if m:
            try:
                year = int(m.group(1))
                if not (1970 <= year <= 2030):
                    continue
                dt = datetime(year, int(m.group(2)), int(m.group(3)),
                              int(m.group(4)), int(m.group(5)), int(m.group(6)))
                return dt.strftime('%Y-%m-%dT%H:%M:%S.000Z')
            except ValueError:
                continue
    return None

def api(method, path, base, headers, body=None):
    data = json.dumps(body).encode() if body else None
    req = Request(f'{base}{path}', data=data, headers=headers, method=method)
    try:
        with urlopen(req) as r:
            return json.loads(r.read())
    except HTTPError as e:
        print(f'  ERROR {e.code} {method} {path}: {e.read().decode()}', file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--server', required=True)
    parser.add_argument('--api-key', required=True)
    parser.add_argument('--since', default='2026-05-31',
                        help='Only look at assets incorrectly dated on or after this date (default: 2026-05-31)')
    parser.add_argument('--apply', action='store_true',
                        help='Apply changes (default is dry run)')
    args = parser.parse_args()

    base = args.server.rstrip('/')
    headers = {
        'x-api-key': args.api_key,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }

    since = datetime.fromisoformat(args.since).replace(tzinfo=timezone.utc)
    until = datetime.now(timezone.utc) + timedelta(days=1)

    print(f"Searching for assets dated {args.since} – today...")
    if not args.apply:
        print("DRY RUN — pass --apply to make changes\n")

    page = 1
    to_fix = []

    while True:
        result = api('POST', '/api/search/metadata', base, headers, {
            'takenAfter': since.isoformat(),
            'takenBefore': until.isoformat(),
            'size': 1000,
            'page': page,
        })
        if not result:
            break

        items = result.get('assets', {}).get('items', [])
        if not items:
            break

        for asset in items:
            filename = asset.get('originalFileName', '')
            new_date = parse_date_from_filename(filename)
            if new_date:
                to_fix.append((asset['id'], filename, new_date))

        if not result.get('assets', {}).get('nextPage'):
            break
        page += 1

    print(f"Found {len(to_fix)} assets with parseable dates in filenames\n")

    fixed = 0
    for asset_id, filename, new_date in to_fix:
        print(f"  {'[DRY RUN] ' if not args.apply else ''}'{filename}' → {new_date}")
        if args.apply:
            result = api('PUT', f'/api/assets/{asset_id}', base, headers,
                         {'dateTimeOriginal': new_date})
            if result:
                fixed += 1

    if args.apply:
        print(f"\nUpdated {fixed}/{len(to_fix)} assets.")
        print("Run 'Extract metadata' in Immich Admin → Jobs to refresh the timeline.")
    else:
        print(f"\nDry run complete. Re-run with --apply to update {len(to_fix)} assets.")

if __name__ == '__main__':
    main()
