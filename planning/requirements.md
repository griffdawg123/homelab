# Requirements
## Services & Applications
- Home media server (Jellyfin)
    - Server and client --> Mini PC for TV
    - DVD and Blu-ray ripping and encoding
    - Torrent downloading and management
- VPN server to access network remotely
- Linux VM for development and testing
- Windows VM for occasional use
- Web server for personal projects
- File sharing service (Samba and Nextcloud)
- Minecraft server
- Gaming PC network access for game streaming to TV or laptop
## Storage
- Personal documents
- Media files (photos, videos, music)
- Home media server (Jellyfin)
## Networking
- Wired Ethernet for main devices (gaming PC, server, TV box)
- Wi-Fi for mobile devices (laptops, smartphones, tablets)
## Security
- VLANs to separate traffic (guest network, trusted devices, homelab devices)
- Pi-hole for ad-blocking and network-wide DNS
- VPN for location spoofing
- Hardware firewall for perimeter security
## Monitoring
- Network monitoring (bandwidth usage, device status)
- Server monitoring (CPU, memory, disk usage)
- Alerts for critical issues (e.g., server down, high resource usage)
- Power monitoring (UPS status, power consumption)
- Grafana and Prometheus for visualization and alerting
## Backup and Recovery
- Regular backups of important data (documents, media files)
- Offsite backups for critical data
- Automated backup solutions (e.g., Duplicati, Restic)
## Automation
- Ansible for configuration management and deployment
- Scheduled tasks for maintenance (e.g., updates, backups)
- Terraform for infrastructure as code 
- Jenkins for CI/CD pipelines --> GitOps configuration as code

## Hardware
- Existing gaming PC for network gaming
    - Smaller M.2 SSD with Windows for Fortnite and other games with kernal level anti-cheat
    - Larger NVMe SSD for Linux and other gaming (Steam)
    - AI workloads
- Current monitors and peripherals connected to gaming PC / work laptop kvm
- Raspberry PI for TV media box (Kodi, Jellyfin client)
- Old Laptop repurposed as a Linux VM host (Proxmox) --> Will be replaced eventually with a dedicated server, maybe a
    nuc cluster or small tower server
- Old desktop repurposed as a NAS (TrueNAS) --> Will be replaced eventually with a dedicated NAS device or
    another server
- Switch with VLAN support for network segmentation
- Fanless N100 mini PC for router and firewall (pfSense or OPNsense)
- Uninterruptible Power Supply (UPS) for power backup and surge protection
- Access points for Wi-Fi coverage
- 10m flat Ethernet cable for connecting devices in different rooms
- Another Raspberry Pi for Pi-hole and other lightweight services (no dependency on server)

