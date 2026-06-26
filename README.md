# homelab

Configuration and infrastructure-as-code for my homelab, built around TrueNAS SCALE.

## Stack

- **TrueNAS SCALE 25.04 (Fangtooth)** — storage, apps, and virtualisation
- **ZFS pool: `stowage`** — 3.7 TiB, all data lives here
- **Ansible** — configuration management (TrueNAS + the off-site monitoring droplet)
- **Terraform** — provisions the off-site monitoring droplet (`terraform/`, state in Terraform Cloud)
- **Grafana Alloy → Grafana Cloud** — metrics + logs; off-site **Uptime Kuma + ntfy** for up/down + paging

## Ansible

All Ansible config lives under `ansible/`. It talks to TrueNAS exclusively via the REST API — no SSH required for playbook runs.

### Prerequisites

```bash
pip install ansible
```

### Setup

1. Copy and populate the vault:
   ```bash
   cp ansible/inventory/group_vars/truenas/vault.yml.example \
      ansible/inventory/group_vars/truenas/vault.yml
   # Fill in your API key and secrets, then encrypt:
   ansible-vault encrypt ansible/inventory/group_vars/truenas/vault.yml
   ```

2. Update `ansible/inventory/group_vars/truenas/vars.yml` with your TrueNAS IP and any config changes.

### Usage

```bash
cd ansible

./run_playbook.sh facts      # inspect current TrueNAS state (read-only)
./run_playbook.sh settings   # timezone, NTP, SSH, SSH keys
./run_playbook.sh storage    # ZFS datasets, SMB and NFS shares
./run_playbook.sh users      # local users
./run_playbook.sh apps       # install/verify apps
./run_playbook.sh postconfig # Nextcloud/Pi-hole DNS/static index/Grafana Alloy
./run_playbook.sh monitor    # off-site droplet stack (Uptime Kuma + ntfy + Caddy)

./edit_vault.sh              # edit encrypted secrets (truenas)
./edit_vault.sh monitor      # edit the monitoring droplet's vault
```

### Playbooks

| Playbook | Role(s) | What it manages |
|---|---|---|
| `facts` | — | Read-only snapshot of TrueNAS state |
| `settings` | `truenas_settings` | Timezone, NTP servers, SSH service, SSH public keys |
| `storage` | `truenas_storage` | ZFS datasets, SMB shares, NFS shares |
| `users` | `truenas_users` | Local TrueNAS users with Samba auth |
| `apps` | `truenas_apps` | TrueNAS catalog and custom Docker Compose apps |
| `postconfig` | `nextcloud_config`, `pihole_dns`, `static_index`, `alloy_config` | Post-deploy config: Nextcloud trusted domains, Pi-hole DNS, static index, Grafana Alloy |
| `monitor` | `monitor_stack` | Off-site droplet stack (Uptime Kuma + ntfy + Caddy) — runs over SSH, not the TrueNAS API |

### Apps

Apps are defined as individual YAML files in `ansible/apps/`. Adding a new file and running `./run_playbook.sh apps` is all that's needed to deploy it.

| App | Type | Port | Dataset |
|---|---|---|---|
| Heimdall | Custom Docker Compose | 30025 | `stowage/heimdall` (plain dir) |
| Immich | Catalog (community) | 30041 | `stowage/immich` |
| Jellyfin | Custom Docker Compose | 8096 | `stowage/jellyfin` |
| Nextcloud | Catalog (community) | 30027 | `stowage/nextcloud` |
| Nginx Proxy Manager | Custom Docker Compose | 443, 30020 | — |
| Pi-hole | Catalog (community) | 53, 20720 | — (ix_volume) |
| Static file server | Custom Docker Compose | 30030 | `stowage/stowage-share/static` |
| Tailscale | Catalog (community) | — | — (ix_volume for state) |
| Grafana Alloy | Custom Docker Compose | 12345 (host, internal) | `stowage/alloy` |

## Observability

Two layers, both managed as code:

- **Metrics + logs → Grafana Cloud.** A single **Grafana Alloy** agent on TrueNAS (`ansible/apps/alloy.yml` + the `alloy_config` role) runs node + cAdvisor exporters and `remote_write`s system/container metrics plus container logs to Grafana Cloud (free tier). Outbound-only; endpoints in `vars.yml`, token in the vault (`grafana_cloud_api_key`). Deployed by `apps` + `postconfig`.
- **External up/down + paging.** An off-site **DigitalOcean droplet** (`terraform/`) runs **Uptime Kuma** + **ntfy**, so alerting survives a full homelab outage. Terraform only bootstraps the box (Docker + Tailscale + tailnet join); the **`monitor_stack`** Ansible role deploys the compose stack and a **Caddy** reverse proxy that serves `https://kuma.griffdawg.dev` with a Cloudflare DNS-01 cert (NPM on TrueNAS can't reach the tailnet-only droplet). The droplet is a real SSH host in the `monitor` inventory group.

```bash
cd terraform && terraform apply          # bootstrap the droplet
cd ../ansible && ./edit_vault.sh monitor # add cloudflare_api_token (same value as the truenas vault)
./run_playbook.sh monitor                # deploy Uptime Kuma + ntfy + Caddy
```

After a droplet rebuild its IPs change — update `ansible_host` in `inventory/group_vars/monitor/vars.yml` and `monitor_tailscale_ip` in the truenas `vars.yml`.

## Heimdall

Heimdall is the homelab dashboard, available at `homelab.griffdawg.dev`. Configuration is UI-only (stored in SQLite) — there is no declarative config format.

### Enhanced app tiles

The following services support live stats directly on their tiles. Set each one up at `homelab.griffdawg.dev` → *Add Application* → search for the service name → select the Enhanced type.

| Service | URL to enter | Credential needed | Where to get it |
|---|---|---|---|
| Pi-hole | `http://192.168.1.104:20720` | API token | Pi-hole web UI → Settings → API |
| Immich | `http://192.168.1.104:30041` | API key | Immich → Account Settings → API Keys |
| Jellyfin | `http://192.168.1.104:8096` | API key | Jellyfin → Dashboard → API Keys → + |
| Nextcloud | `http://192.168.1.104:30027` | Admin user + password | `nextcloud_admin_*` in vault |
| Nginx Proxy Manager | `http://192.168.1.104:30020` | Admin email + password | NPM web UI credentials |

TrueNAS (`https://192.168.1.104:8443`) has no enhanced app — add it as a plain link.

### Backup and restore

Heimdall config does not survive a volume wipe without a backup. After finishing tile setup, export a snapshot:

**Export:** `homelab.griffdawg.dev` → Settings (top-right) → *Export* → save the `.tar.gz`

Commit the file to this repo:
```bash
cp ~/Downloads/heimdall-export-*.tar.gz ansible/heimdall-backup.tar.gz
git add ansible/heimdall-backup.tar.gz
git commit -m "Update Heimdall config backup"
```

**Restore:** `homelab.griffdawg.dev` → Settings → *Import* → select the `.tar.gz`

### Structure

```
ansible/
├── ansible.cfg
├── run_playbook.sh
├── edit_vault.sh                  # ./edit_vault.sh [group]   (default: truenas)
├── apps/                          # one file per app
├── inventory/
│   ├── hosts.yml                  # truenas (API/local) + monitor (SSH droplet)
│   └── group_vars/
│       ├── truenas/               # vars.yml, vault.yml (encrypted, committed), vault.yml.example
│       └── monitor/               # off-site droplet: connection vars + its own vault
├── playbooks/
└── roles/
    ├── truenas_apps/  truenas_settings/  truenas_storage/  truenas_users/
    ├── nextcloud_config/  pihole_dns/  static_index/  alloy_config/
    └── monitor_stack/             # off-site droplet stack (Kuma + ntfy + Caddy)
```

Infrastructure for the off-site monitoring droplet lives in `terraform/` (DigitalOcean, state in Terraform Cloud).
