# Todo

## In Progress
- [ ] Ansible configuration for TrueNAS (storage, settings, apps)

## Up Next
- [ ] Add Nextcloud to apps playbook
- [ ] Add reverse proxy (Nginx Proxy Manager or Caddy) to apps playbook
- [ ] Configure Pi-hole local DNS records for vanity URLs (e.g. `jellyfin.home`)
- [ ] Add qBittorrent to apps playbook
- [ ] Add Prometheus + Grafana to apps playbook
- [ ] Add Sunshine to apps playbook (for Moonlight game streaming)
- [ ] Wire up GitHub Actions self-hosted runner for GitOps
- [ ] Define backup strategy and implement Restic jobs to Backblaze B2

## Deferred (until infrastructure is stable)
- [ ] Vaultwarden — evaluate uptime confidence before migrating passwords

## Hardware
- [ ] Source living room media box (Bazzite + Moonlight)
- [ ] Source N100 mini PC for pfSense/OPNsense
- [ ] Source managed switch with VLAN support
- [ ] Set up UPS for NAS and network gear
- [ ] Put ISP modem into bridge mode

## Networking
- [ ] Configure VLANs (trusted, homelab, work, guest, IoT)
- [ ] Set up Pi-hole on Raspberry Pi
- [ ] Configure pfSense/OPNsense

## Future (requires dedicated server hardware)
- [ ] Proxmox for virtualisation
- [ ] Linux dev VM
- [ ] Self-hosted personal projects via Cloudflare Tunnel
- [ ] Minecraft server
- [ ] Migrate apps from TrueNAS ix-apps to dedicated container host (Portainer or Docker Compose)
      — TrueNAS becomes pure storage, container host gets full config-as-code control via Ansible
