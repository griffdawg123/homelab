# Agent Guidelines

Context and conventions for AI agents working in this repository.

## What this repo is

Infrastructure-as-code for a personal homelab built on TrueNAS SCALE 25.04 (Fangtooth). Ansible manages TrueNAS configuration via its REST API, and also configures an off-site DigitalOcean monitoring droplet over SSH (the `monitor` inventory group). Terraform (`terraform/`, state in Terraform Cloud) provisions that droplet but only **bootstraps** it (Docker + Tailscale + tailnet join); the `monitor_stack` Ansible role then deploys its compose stack (Uptime Kuma + ntfy + Caddy). Observability: a **Grafana Alloy** agent on TrueNAS ships metrics + logs to **Grafana Cloud**, and the droplet provides external up/down checks + push paging that survive a full homelab outage.

## Key facts

- **TrueNAS LAN IP:** `192.168.1.104` (var: `truenas_ip`)
- **TrueNAS Tailscale IP:** `100.75.190.13` (var: `truenas_tailscale_ip`)
- **ZFS pool:** `stowage` — existing data, never delete or recreate datasets
- **API base:** `http://192.168.1.104/api/v2.0` (var: `truenas_api_url`)
- **Admin username:** `truenas_admin`
- **Tailscale hostname:** `truenas-scale`
- **Domain:** `griffdawg.dev` (Cloudflare-managed DNS, var: `homelab_domain`)
- **TrueNAS web UI HTTPS port:** `8443` (moved from 443 to free it for NPM)

## Ansible conventions

- TrueNAS app/config management uses `ansible.builtin.uri` (REST API, `ansible_connection: local`)
- SSH access for file operations uses the `truenas_ssh` host (inside `truenas_files` group, child of `truenas`, inherits all vars)
- The playbooks run from `ansible/` as the working directory
- Secrets live in `ansible/inventory/group_vars/truenas/vault.yml` (AES256 encrypted — never decrypt or print)
- Non-secret config lives in `ansible/inventory/group_vars/truenas/vars.yml`
- `truenas_api_headers` is defined in `vars.yml` and references `truenas_api_key` from the vault

## Playbook run order

```
settings   → moves TrueNAS HTTPS to port 8443, system config, NTP, SSH keys
storage    → creates ZFS datasets
users      → local user accounts
apps       → deploys all apps in ansible/apps/ via TrueNAS API (incl. Grafana Alloy)
postconfig → Nextcloud custom.config.php, Pi-hole DNS entries, static index, Grafana Alloy config
```

Run from `ansible/`:
```bash
./run_playbook.sh <playbook>
```

The `monitor` playbook is **separate** — it targets the off-site droplet over SSH (not the TrueNAS API), so it isn't part of the TrueNAS chain above:
```
monitor    → deploys the droplet compose stack (Uptime Kuma + ntfy + Caddy) via the monitor_stack role
```

## Manual steps (not automated by Ansible)

These must be done once after a fresh deployment:

### NPM wildcard certificate
1. Open NPM admin at `http://192.168.1.104:30020`
2. **SSL Certificates → Add SSL Certificate → Let's Encrypt**
3. Domain: `*.griffdawg.dev`, enable DNS Challenge, provider: Cloudflare
4. Enter Cloudflare API token (from vault: `cloudflare_api_token`)

### NPM proxy hosts
For each service, add a proxy host in NPM pointing to the backend. Use the `*.griffdawg.dev` wildcard cert. Enable **Force SSL** and **HTTP/2 Support**.

| Domain | Forward to | Notes |
|---|---|---|
| `nextcloud.griffdawg.dev` | `http://192.168.1.104:30027` | |
| `immich.griffdawg.dev` | `http://192.168.1.104:30041` | |
| `jellyfin.griffdawg.dev` | `http://192.168.1.104:8096` | |
| `pihole.griffdawg.dev` | `http://192.168.1.104:20720` | |
| `truenas.griffdawg.dev` | `https://192.168.1.104:8443` | Enable "Ignore SSL Certificate" |
| `japan.griffdawg.dev` | `http://192.168.1.104:30030` | |

### Tailscale DNS
In the Tailscale admin console (tailscale.com/admin/dns):
- Add nameserver → Custom → `100.75.190.13`
- Enable **Override local DNS**

This makes all Tailscale devices use Pi-hole for DNS, so `*.griffdawg.dev` resolves everywhere.

## Reverse proxy and DNS

- **Nginx Proxy Manager** runs as a TrueNAS catalog app (`ansible/apps/nginx-proxy-manager.yml`). Owns port 443 directly (`https_port.port_number: 443`). Wildcard cert `*.griffdawg.dev` via Cloudflare DNS-01 challenge — no ports open to the internet. Proxy hosts and certs configured manually in NPM UI at `http://192.168.1.104:30020`.
- **Pi-hole** runs as a TrueNAS catalog app (`ansible/apps/pihole.yml`). DNS port 53 published on host. DNS entries managed via `pihole_dns_entries` in `vars.yml`, applied by the `pihole_dns` role (`postconfig` playbook). Config stored in Pi-hole v6 TOML format at `/mnt/.ix-apps/app_mounts/pihole/config/pihole.toml`.
- All service subdomains resolve to `100.75.190.13` (Tailscale IP) so URLs work identically at home and over Tailscale.
- Non-Tailscale LAN devices (Roku, smart TVs etc.) use direct IP:port — they cannot use custom domains unless the router is configured to use Pi-hole as its DNS server.

## Monitoring droplet (off-site)

- **Provisioned** by `terraform/` (DigitalOcean, state in Terraform Cloud). cloud-init **only** installs Docker + Tailscale and joins the tailnet — keep `cloud-init.yaml.tftpl` **ASCII-only** (an em-dash in a comment once broke the cloud-config parse and silently skipped all `runcmd`).
- **Configured** by the `monitor_stack` role over SSH (`monitor` group, host `homelab-monitor`, connects via `~/.ssh/homelab-monitor` to the droplet's **public IP** — the tailnet IP routes through Tailscale SSH, which needs interactive auth). The role templates `docker-compose.yml` (Uptime Kuma + ntfy + Caddy), the Caddyfile, and a `0600` `.env`. After a rebuild, update `ansible_host` (group_vars/monitor) and `monitor_tailscale_ip` (truenas vars) — both IPs change.
- **Caddy** terminates TLS for `kuma.griffdawg.dev` via Cloudflare DNS-01. NPM on TrueNAS can't proxy it — NPM runs in a container with no route to the tailnet. Pi-hole points `kuma.griffdawg.dev` at the droplet's tailnet IP (`monitor_tailscale_ip`), not TrueNAS.
- **Secret:** `cloudflare_api_token` in `group_vars/monitor/vault.yml` (same value as the truenas vault). Edit with `./edit_vault.sh monitor` (the script takes an optional group arg, default `truenas`).
- After changing `pihole_dns_entries` or an NPM host, clients may serve a stale `NXDOMAIN`; flush with `sudo resolvectl flush-caches` (verify with `dig @192.168.1.104 <name>`). See CLAUDE.md.

## Adding a new service subdomain

1. Add an entry to `pihole_dns_entries` in `vars.yml`
2. Add a proxy host in the NPM UI (`http://192.168.1.104:30020`) using the `*.griffdawg.dev` wildcard cert
3. Run `./run_playbook.sh postconfig` to push the DNS entry to Pi-hole

## Adding a new app

Create `ansible/apps/<name>.yml`. For a TrueNAS catalog app:

```yaml
app_name: myapp
catalog_app: myapp
train: community   # or stable

values:
  TZ: "Australia/Sydney"
  # ... values from user_config.yaml on TrueNAS
```

The `truenas_apps` role picks up all files in `ansible/apps/` automatically — no other changes needed.

**Note:** TrueNAS custom apps (type: custom) do not support `dockerfile_inline` or `configs:` with inline `content:`. Use pre-built images from a registry instead.

**Custom app API requirements:** `custom_app: true` must be set and the compose config must be sent as a YAML string via `custom_compose_config_string` (not a dict via `custom_compose_config`). The role handles this automatically via `| to_yaml`.

**API deprecation:** `/api/v2.0` is deprecated in 25.04 and removed in TrueNAS 26. Future migration path is JSON-RPC 2.0 over WebSocket at `wss://<host>/api/current`.

## Adding secrets

1. Add the variable reference to the relevant `ansible/apps/<name>.yml` or `vars.yml`
2. Add the example entry to `ansible/inventory/group_vars/truenas/vault.yml.example`
3. Run `./edit_vault.sh` to add the real value

Never write plaintext secrets into any file. Never suggest committing an unencrypted vault.

## Sourcing app config

To get the exact values for a TrueNAS catalog app, SSH in and read:

```bash
cat /mnt/.ix-apps/app_configs/<appname>/versions/*/user_config.yaml
```

The questions schema (field names, types, defaults) is at:

```bash
cat /mnt/.ix-apps/app_configs/<appname>/versions/*/questions.yaml
```

Use these rather than guessing the API schema.

## Data safety

- The `stowage` pool has existing data (Immich library, Jellyfin config, VM disks)
- Dataset creation tasks always `GET` before `POST` — never overwrite existing datasets
- Do not add tasks that delete, format, or scrub datasets without explicit user instruction

## SMB share layout

```
stowage/stowage-share/
└── media/
    ├── movies/    # mounted into Jellyfin at /movies
    └── shows/     # mounted into Jellyfin at /shows
```

This share is mounted as a network drive on Windows machines for easy media uploads.
