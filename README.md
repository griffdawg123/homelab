# homelab

Configuration and infrastructure-as-code for my homelab, built around TrueNAS SCALE.

## Stack

- **TrueNAS SCALE 25.04 (Fangtooth)** — storage, apps, and virtualisation
- **ZFS pool: `stowage`** — 3.7 TiB, all data lives here
- **Ansible** — configuration management (this repo)
- **Terraform** — infrastructure management (planned)

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

./edit_vault.sh              # edit encrypted secrets
```

### Playbooks

| Playbook | Role(s) | What it manages |
|---|---|---|
| `facts` | — | Read-only snapshot of TrueNAS state |
| `settings` | `truenas_settings` | Timezone, NTP servers, SSH service, SSH public keys |
| `storage` | `truenas_storage` | ZFS datasets, SMB shares, NFS shares |
| `users` | `truenas_users` | Local TrueNAS users with Samba auth |
| `apps` | `truenas_apps` | TrueNAS catalog and custom Docker Compose apps |

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
├── edit_vault.sh
├── apps/                          # one file per app
├── inventory/
│   ├── hosts.yml
│   └── group_vars/truenas/
│       ├── vars.yml               # non-secret config
│       ├── vault.yml              # encrypted secrets (committed)
│       └── vault.yml.example      # template
├── playbooks/
└── roles/
    ├── truenas_apps/
    ├── truenas_settings/
    ├── truenas_storage/
    └── truenas_users/
```
