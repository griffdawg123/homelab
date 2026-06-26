# Monitoring droplet — runs the parts of the observability stack that must live
# OFF the homelab so they can still alert when the homelab itself is down:
#   - Uptime Kuma : external "is the homelab reachable?" checks
#   - ntfy        : push-to-phone pager
# Both are reached over Tailscale (private), not the public internet. The DO
# cloud firewall only permits SSH + Tailscale; the app ports are never exposed.

resource "digitalocean_ssh_key" "monitor" {
  name       = var.droplet_name
  public_key = var.ssh_public_key
}

resource "digitalocean_droplet" "monitor" {
  name     = var.droplet_name
  region   = var.region
  size     = var.droplet_size
  image    = var.droplet_image
  ssh_keys = [digitalocean_ssh_key.monitor.fingerprint]

  # cloud-init installs Docker + Tailscale and brings up the compose stack.
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    tailscale_auth_key = var.tailscale_auth_key
    tailscale_hostname = var.droplet_name
  })

  tags = ["homelab", "monitoring"]
}

resource "digitalocean_firewall" "monitor" {
  name        = "${var.droplet_name}-fw"
  droplet_ids = [digitalocean_droplet.monitor.id]

  # SSH for break-glass (Tailscale SSH also works once the node is up — you can
  # tighten or remove this rule afterwards).
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Tailscale direct (WireGuard). App traffic arrives over this, decapsulated to
  # the tailscale0 interface — so Uptime Kuma / ntfy stay private without any
  # public app-port rules.
  inbound_rule {
    protocol         = "udp"
    port_range       = "41641"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound (package installs, Tailscale DERP, ntfy push delivery).
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
