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

## Self-Hosted Projects (future, requires dedicated server)

- Reverse proxy: Nginx Proxy Manager or Caddy
- Cloudflare Tunnel for public exposure without open inbound ports
- Proxmox for VM management (when dedicated hardware available)
