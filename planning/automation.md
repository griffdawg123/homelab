# Automation

## Configuration Management — Ansible (in place)

Ansible manages TrueNAS SCALE via the REST API. All config is version-controlled in this repo.

- `settings` playbook — timezone, NTP, SSH, SSH keys
- `storage` playbook — ZFS datasets, SMB and NFS shares
- `users` playbook — local users
- `apps` playbook — installs and verifies all apps (one file per app in `ansible/apps/`)
- `facts` playbook — read-only snapshot of current state

## Infrastructure as Code — Terraform (planned)

- Provisioning TrueNAS datasets
- Future: provisioning VMs on Proxmox when dedicated hardware exists

## GitOps — GitHub Actions (planned)

Self-hosted runner (on Raspberry Pi or as a TrueNAS Docker container) that triggers Ansible on push to main.

- Push app config changes → playbook runs automatically
- No separate CI/CD server to maintain
- Secrets managed via Ansible Vault, injected at run time

## Backups — Restic (planned)

- Scheduled Restic jobs backing up critical datasets to Backblaze B2
- ZFS snapshots for local point-in-time recovery
- Strategy and retention policy still to be defined
