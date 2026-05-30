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

| App | Type | Dataset |
|---|---|---|
| Immich | Catalog (community) | `stowage/immich` |
| Jellyfin | Custom Docker Compose | `stowage/jellyfin` |
| Tailscale | Catalog (community) | — (ix_volume for state) |

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
