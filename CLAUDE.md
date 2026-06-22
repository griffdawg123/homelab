# Homelab — Claude Code Context

See `AGENTS.md` for full conventions. This file adds Claude-specific guidance.

## Infrastructure at a glance

| Thing | Value |
|---|---|
| TrueNAS LAN IP | `192.168.1.104` |
| TrueNAS Tailscale IP | `100.75.190.13` |
| TrueNAS API | `http://192.168.1.104/api/v2.0` |
| TrueNAS web UI | `https://192.168.1.104:8443` (port moved to free 443 for NPM) |
| Domain | `griffdawg.dev` (DNS on Cloudflare) |
| ZFS pool | `stowage` |
| Timezone | `Australia/Sydney` |

## Running apps

| App | Host port | URL |
|---|---|---|
| Nextcloud | 30027 | `nextcloud.griffdawg.dev` |
| Immich | 30041 | `immich.griffdawg.dev` |
| Jellyfin | 8096 | `jellyfin.griffdawg.dev` |
| Pi-hole | 53 (DNS), 20720 (web) | `pihole.griffdawg.dev` |
| Nginx Proxy Manager | 443 (HTTPS), 30020 (admin UI) | reverse proxy for all of the above |
| Tailscale | — | provides remote access via `100.75.190.13` |
| Static file server | 30030 | `static.griffdawg.dev` |
| CouchDB (Obsidian LiveSync) | 30050 | `couchdb.griffdawg.dev` |
| Heimdall | 30025 | `homelab.griffdawg.dev` |

## Key files

- `ansible/inventory/group_vars/truenas/vars.yml` — all non-secret config (IPs, domain, ports, DNS entries)
- `ansible/inventory/group_vars/truenas/vault.yml` — secrets (AES256 encrypted, never read or print)
- `ansible/inventory/group_vars/truenas/vault.yml.example` — shows what secrets exist
- `ansible/apps/*.yml` — one file per app, picked up automatically by the `truenas_apps` role
- `ansible/apps/nginx-proxy-manager.yml` — NPM config; HTTPS bound to port 443 directly
- `ansible/apps/pihole.yml` — Pi-hole catalog app config
- `ansible/roles/nextcloud_config/` — writes `custom.config.php` to set trusted domains/proxies
- `ansible/roles/pihole_dns/` — pushes `pihole_dns_entries` to Pi-hole v6 API

## First-time setup

### 1. Vault
```bash
cp ansible/inventory/group_vars/truenas/vault.yml.example ansible/inventory/group_vars/truenas/vault.yml
./edit_vault.sh   # add all secrets
```

Required secrets: `truenas_api_key`, `nextcloud_admin_user`, `nextcloud_admin_password`, `nextcloud_db_password`, `nextcloud_redis_password`, `pihole_web_password`, `cloudflare_api_token`.

### 2. Run playbooks (in order)
```bash
cd ansible
./run_playbook.sh settings
./run_playbook.sh storage
./run_playbook.sh users
./run_playbook.sh apps
./run_playbook.sh postconfig
```

### 3. NPM — wildcard certificate (one-time, manual)
Open `http://192.168.1.104:30020` → **SSL Certificates → Add → Let's Encrypt**
- Domain: `*.griffdawg.dev`
- DNS Challenge: Cloudflare, API token from vault

### 4. NPM — proxy hosts (manual, repeat for each service)
Add a proxy host per service using the wildcard cert. Enable Force SSL + HTTP/2.

| Domain | Forward to | Special |
|---|---|---|
| `nextcloud.griffdawg.dev` | `http://192.168.1.104:30027` | |
| `immich.griffdawg.dev` | `http://192.168.1.104:30041` | |
| `jellyfin.griffdawg.dev` | `http://192.168.1.104:8096` | |
| `pihole.griffdawg.dev` | `http://192.168.1.104:20720` | |
| `truenas.griffdawg.dev` | `https://192.168.1.104:8443` | Ignore SSL cert (self-signed) |
| `static.griffdawg.dev` | `http://192.168.1.104:30030` | |
| `homelab.griffdawg.dev` | `http://192.168.1.104:30025` | |

### 5. Tailscale DNS (one-time, manual)
In tailscale.com admin → **DNS → Add nameserver → Custom → `100.75.190.13`**
Enable **Override local DNS**.

## What NOT to do

- Never read, decrypt, or print `vault.yml`
- Never delete ZFS datasets — `stowage` has live data
- Don't touch port 80 on TrueNAS — it serves the TrueNAS HTTP redirect
- Don't set `truenas_ui_https_port` to 443 — NPM owns that port

## Raspberry Pi (future)

Pi-hole on TrueNAS is temporary. When a Raspberry Pi arrives:
- Pi becomes primary DNS (Pi-hole)
- A second Pi-hole instance becomes secondary DNS
- TrueNAS Pi-hole app gets removed
- New host group added to inventory for the Pi
- Tailscale DNS updated to point to the Pi's Tailscale IP
