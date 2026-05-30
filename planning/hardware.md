# Hardware

## Current

### NAS
- Older Acer desktop
- 2x 4TB HDDs (ZFS mirror, pool: `stowage`)
- Running TrueNAS SCALE 25.04 — at the limit of what this machine can do
- No virtualisation planned on this box

### Workstations
- Custom built desktop — primary gaming PC and AI workloads
  - Smaller M.2 SSD: Windows (anti-cheat games e.g. Fortnite)
  - Larger NVMe SSD: Linux (Steam, development)
  - Monitors and peripherals on KVM shared with work laptop
- Framework 13 laptop — work and portable use

### Other
- Raspberry Pi — Pi-hole and lightweight services (independent of main server)

## Planned

### Living Room Media Box
- Small form factor PC or mini PC running Bazzite
  - Gamescope / Steam Big Picture session
  - Moonlight client for streaming from gaming PC
  - Browser for streaming apps (Netflix, Disney+, etc.)
  - Replaces Roku

### Firewall / Router
- Fanless N100 mini PC running pfSense or OPNsense
- Sits behind ISP modem in bridge mode
- Handles VLANs, firewall rules, DHCP, DNS (upstream of Pi-hole)

### Network
- Managed switch with VLAN support
- Additional Wi-Fi access points for whole-home coverage
- 10m flat Ethernet for inter-room runs
- UPS for NAS and network gear

### Future Server (when hardware allows)
- Dedicated server for Proxmox / virtualisation
- Will enable: Linux dev VMs, self-hosted projects, more services
- Candidates: NUC cluster, small tower server
