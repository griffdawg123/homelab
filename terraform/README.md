# Terraform — monitoring droplet

Provisions a small DigitalOcean droplet that hosts the **off-site** half of the
homelab observability stack — the parts that must keep running when the homelab
is down so they can still alert you:

- **Uptime Kuma** — external "is the homelab reachable?" checks → `http://homelab-monitor:3001`
- **ntfy** — push-to-phone pager → `http://homelab-monitor:8080`

The metrics/dashboards/alerting layer itself lives in **Grafana Cloud** (free
tier); the homelab pushes to it via the Grafana Alloy agent (`../ansible/apps/alloy.yml`).

## How it fits together

```
Homelab (TrueNAS)                Grafana Cloud (free)        DO droplet (this)
  Alloy agent  ──metrics/logs──►  dashboards + alerting        Uptime Kuma ──► ntfy ──► phone
                                                               (external up/down)
        ▲                                                            │
        └───────────────── Tailscale (private) ─────────────────────┘
```

The droplet joins your tailnet on first boot. The DO cloud firewall only allows
SSH + Tailscale inbound — the app ports are reachable over Tailscale only, never
the public internet.

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in do_token, ssh_public_key, tailscale_auth_key
terraform init
terraform plan
terraform apply
```

After apply, find the node's Tailscale IP in the Tailscale admin console (or it
resolves as `homelab-monitor` with MagicDNS), then open Uptime Kuma to add your
first monitors and point its notifications at the ntfy instance.

## Notes

- **Cost:** `s-1vcpu-1gb` ≈ $6/mo. Override `droplet_size` for more headroom.
- **State:** local by default and gitignored. Switch to Terraform Cloud (org
  `griffdawg123`) via a `cloud {}` block in `versions.tf` to match the other projects.
- **Secrets:** `do_token` and `tailscale_auth_key` are sensitive vars — keep them
  in the gitignored `terraform.tfvars` or in `TF_VAR_*` env vars.
