# Software

## NAS (TrueNAS SCALE 25.04)

### Running
- Immich — photo and video backup
- Jellyfin — media server (custom Docker Compose)
- Tailscale — remote access

### Planned
- Nextcloud — Google Drive replacement (document sync, file storage)
- Nginx Proxy Manager or Caddy — reverse proxy for vanity URLs and routing
- Vaultwarden — self-hosted Bitwarden password manager (deferred until infra is stable)
- Restic / Duplicati — automated backups to Backblaze B2
- Prometheus + Grafana — metrics and alerting
- Torrent client (e.g. qBittorrent)
- Sunshine — game streaming server for Moonlight client on living room box

## Living Room Box (Bazzite)

- Gamescope / Steam Big Picture session
- Moonlight — game streaming client (from gaming PC running Sunshine)
- Browser — Netflix, Disney+, and other streaming apps

## Firewall / Router (pfSense or OPNsense)

- VLAN configuration
- Firewall rules
- DHCP server
- DNS forwarding to Pi-hole

## Raspberry Pi

- Pi-hole — network-wide DNS ad-blocking (independent of NAS)
- Potentially: GitHub Actions self-hosted runner

## App Management Evolution

Currently all apps run inside TrueNAS SCALE's ix-apps system (TrueNAS-managed Docker). This limits config
management — no direct Compose files, no Portainer, runtime changes require `docker exec` workarounds.

**When a second machine is available**, the preferred path is:
- Move apps off TrueNAS onto a dedicated container host (mini PC or VM)
- Use Portainer or plain Docker Compose for full config-as-code control
- TrueNAS stays as pure storage (ZFS, SMB/NFS shares) — what it's best at
- Ansible manages both: TrueNAS via REST API, container host via SSH + Docker Compose templates

TrueNAS apps are fine for now (single machine, low complexity) but this is the direction once
hardware allows it.

## Self-Hosted Projects (future, requires dedicated server)

- Reverse proxy: Nginx Proxy Manager or Caddy
- Cloudflare Tunnel for public exposure without open inbound ports
- Proxmox for VM management (when dedicated hardware available)
