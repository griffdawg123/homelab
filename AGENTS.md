# Agent Guidelines

Context and conventions for AI agents working in this repository.

## What this repo is

Infrastructure-as-code for a personal homelab built on TrueNAS SCALE 25.04 (Fangtooth). Ansible manages TrueNAS configuration via its REST API. Terraform is planned but not yet present.

## Key facts

- **TrueNAS IP:** `192.168.1.104` (also reachable as `truenas-scale` via Tailscale)
- **ZFS pool:** `stowage` — existing data, never delete or recreate datasets
- **API base:** `http://192.168.1.104/api/v2.0`
- **Admin username:** `truenas_admin`
- **Tailscale hostname:** `truenas-scale`

## Ansible conventions

- All TrueNAS interaction is via the `ansible.builtin.uri` module (REST API), not SSH
- The playbooks run from `ansible/` as the working directory
- Secrets live in `ansible/inventory/group_vars/truenas/vault.yml` (AES256 encrypted — never decrypt or print)
- Non-secret config lives in `ansible/inventory/group_vars/truenas/vars.yml`
- `truenas_api_headers` is defined in `vars.yml` and references `truenas_api_key` from the vault

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

For a custom Docker Compose app:

```yaml
app_name: myapp
type: custom

compose:
  services:
    myapp:
      image: ...
```

The `truenas_apps` role picks up all files in `ansible/apps/` automatically — no other changes needed.

## Adding secrets

1. Add the variable reference to the relevant `ansible/apps/<name>.yml` or `vars.yml`
2. Add the example entry to `ansible/inventory/group_vars/truenas/vault.yml.example`
3. Tell the user to run `./edit_vault.sh` to add the real value

Never write plaintext secrets into any file. Never suggest committing an unencrypted vault.

## Sourcing app config

To get the exact values for a TrueNAS app, SSH in and read:

```bash
cat /mnt/.ix-apps/app_configs/<appname>/versions/*/user_config.yaml
```

This is the ground truth for what values the API accepts. Use it rather than guessing schema.

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
