# Network

## Topology

```
ISP → Modem (bridge mode) → N100 Firewall (pfSense/OPNsense) → Managed Switch → Devices
                                                                              └→ Access Points
```

## VLANs

| VLAN | Purpose | Notes |
|------|---------|-------|
| Trusted | Personal devices (phones, laptops) | Full LAN access |
| Homelab | NAS, servers, network gear | Restricted outbound |
| Work | Work laptop | Isolated from homelab |
| Guest | Visitors | Internet only |
| IoT | Smart home devices | No LAN access |

## DNS

- Pi-hole on dedicated Raspberry Pi for network-wide ad-blocking
- Runs independently of the NAS — DNS stays up even if TrueNAS is down
- Upstream: pfSense/OPNsense handles DHCP and points clients at Pi-hole

## Remote Access

- **Tailscale** — zero-trust overlay network for secure remote access to homelab
- **Cloudflare Tunnel** — exposes self-hosted projects publicly, no open inbound ports required
- **Commercial VPN** (e.g. Mullvad) — outbound privacy and geo-unblocking, separate from Tailscale

## Physical

- Wired Ethernet for primary devices: NAS, gaming PC, living room media box
- Wi-Fi access points for mobile devices and laptops
- UPS protecting NAS and core network gear
