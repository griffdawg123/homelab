# Requirements

## Services & Applications

### Media
- Home media server (Jellyfin) — running
- DVD and Blu-ray ripping and encoding
- Living room media box (Bazzite + Steam Big Picture) to replace Roku
  - Gamescope session for console-like TV experience
  - Browser-based streaming apps (Netflix, Disney+, etc.)
  - Moonlight for low-latency game streaming from gaming PC
- Torrent downloading and management

### Files & Storage
- SMB file sharing — running
- Nextcloud to replace Google Drive (document sync, mobile apps, arbitrary files)
- Immich for photo/video backup — running

### Networking & Remote Access
- Tailscale for remote access tunneling — running
- Commercial VPN (e.g. Mullvad) for location privacy and geo-unblocking
- Pi-hole for network-wide ad-blocking and DNS
- VLANs for traffic separation (guest, trusted, homelab, IoT)
- Hardware firewall (pfSense or OPNsense on N100 mini PC)

### Security & Identity
- Vaultwarden (self-hosted Bitwarden) for password management
  - Bitwarden clients cache the vault locally — passwords accessible offline even if server is down
  - Deferred until infrastructure is stable enough to be trusted as a daily driver
  - Keep critical passwords (email, vault master) in a separate offline backup regardless

### DNS & Internal Routing
- Vanity URLs / custom local DNS via Pi-hole (e.g. `jellyfin.home`, `immich.home`)
- Reverse proxy (Nginx Proxy Manager or Caddy) to route by hostname without port numbers
- Single domain for both internal and external access:
  - Internal: Pi-hole DNS record → reverse proxy → service
  - External: Cloudflare Tunnel → same reverse proxy → service

### Development & Self-Hosting
- Linux VM for development and testing (when dedicated hardware arrives)
- Self-hosted personal projects via Cloudflare Tunnel (no inbound ports, no static IP needed)
- Minecraft server

### Gaming
- Gaming PC dual-boot: Windows (anti-cheat games) + Linux (Steam, AI workloads)
- Sunshine on gaming PC for streaming to living room box via Moonlight

## Storage
- Personal documents (Nextcloud)
- Photos and video backup (Immich)
- Media library (Jellyfin)
- Offsite backups via Restic to Backblaze B2 (S3-compatible, cheap)
- ZFS snapshots for local point-in-time recovery

## Networking
- ISP modem in bridge mode (WAN termination only)
- N100 mini PC running pfSense or OPNsense as primary router and firewall
- Managed switch with VLAN support
- Wired Ethernet for primary devices (NAS, gaming PC, TV box)
- Wi-Fi access points for mobile devices

## Security
- VLANs: guest, work, trusted, homelab
- Pi-hole on a dedicated Raspberry Pi (independent of main server — DNS always up)
- Tailscale for zero-trust remote access
- Commercial VPN for outbound privacy and geo-unblocking
- Hardware firewall at the perimeter
- Cloudflare Tunnel for self-hosted project exposure (no open inbound ports)

## Monitoring
- Prometheus + Grafana for metrics and dashboards
- Alerts for critical issues (disk health, server down, high resource usage)
- UPS monitoring and power status

## Backup & Recovery
- Automated backups of critical datasets
- Offsite target: Backblaze B2 via Restic or Duplicati
- ZFS snapshots for local recovery
- Full strategy still to be defined

## Automation
- Ansible for TrueNAS configuration management — in place
- Terraform for infrastructure provisioning (planned)
- GitHub Actions with a self-hosted runner for GitOps
  - Push to main triggers ansible-playbook runs automatically
  - No CI/CD server to maintain
