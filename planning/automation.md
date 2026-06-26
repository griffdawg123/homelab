# Automation

## Configuration Management — Ansible (in place)

Ansible manages TrueNAS SCALE via the REST API. All config is version-controlled in this repo.

- `settings` playbook — timezone, NTP, SSH, SSH keys
- `storage` playbook — ZFS datasets, SMB and NFS shares
- `users` playbook — local users
- `apps` playbook — installs and verifies all apps (one file per app in `ansible/apps/`)
- `facts` playbook — read-only snapshot of current state

## Infrastructure as Code — Terraform (in place)

- `terraform/` provisions an off-site DigitalOcean droplet (`homelab-monitor`)
  running Uptime Kuma + ntfy, joined to the tailnet via cloud-init. This hosts the
  part of the observability stack that must survive the homelab going down.
- Future: provisioning TrueNAS datasets; VMs on Proxmox when dedicated hardware exists.

## Observability (in place)

- **Grafana Alloy** agent on TrueNAS (`ansible/apps/alloy.yml`) ships system +
  container metrics and logs to **Grafana Cloud** (free tier) for dashboards and
  alerting — keeps the heavy control plane off the 8 GB NAS.
- **Uptime Kuma** (on the DO droplet) does external up/down checks; **ntfy** pages
  the phone. Both off-site so they alert even when home is down.

## GitOps — GitHub Actions (planned)

Self-hosted runner (on Raspberry Pi or as a TrueNAS Docker container) that triggers Ansible on push to main.

- Push app config changes → playbook runs automatically
- No separate CI/CD server to maintain
- Secrets managed via Ansible Vault, injected at run time

## Backups — Restic (planned)

- Scheduled Restic jobs backing up critical datasets to Backblaze B2
- ZFS snapshots for local point-in-time recovery
- Strategy and retention policy still to be defined
