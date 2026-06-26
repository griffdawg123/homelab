output "droplet_public_ip" {
  description = "Public IPv4 of the monitoring droplet (for break-glass SSH only)."
  value       = digitalocean_droplet.monitor.ipv4_address
}

output "ssh_command" {
  description = "Break-glass SSH command."
  value       = "ssh root@${digitalocean_droplet.monitor.ipv4_address}"
}

output "access_note" {
  description = "How to reach the apps."
  value       = <<-EOT
    Reach the apps over Tailscale (find the node's tailnet IP in the Tailscale admin console):
      Uptime Kuma : http://${var.droplet_name}:3001
      ntfy        : http://${var.droplet_name}:8080
    The DO firewall does not expose these ports publicly.
  EOT
}
