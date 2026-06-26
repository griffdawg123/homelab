variable "do_token" {
  description = "DigitalOcean API token (create at cloud.digitalocean.com/account/api). Pass via TF_VAR_do_token or terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region slug"
  type        = string
  default     = "syd1"
}

variable "droplet_size" {
  description = "Droplet size slug. s-1vcpu-1gb ($6/mo) is ample for Uptime Kuma + ntfy."
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_image" {
  description = "Droplet base image slug"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "droplet_name" {
  description = "Name + Tailscale hostname for the monitoring droplet"
  type        = string
  default     = "homelab-monitor"
}

variable "ssh_public_key" {
  description = "SSH public key uploaded to DO and authorized on the droplet for break-glass access."
  type        = string
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key (tailscale.com/admin/settings/keys). Joins the droplet to your tailnet on first boot. Use an ephemeral, pre-approved key."
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token (Zone:DNS:Edit on the griffdawg.dev zone). Used by Caddy on the droplet to issue/renew the kuma.griffdawg.dev cert via DNS-01. Same token as the Ansible vault's cloudflare_api_token."
  type        = string
  sensitive   = true
}
