terraform {
  required_version = ">= 1.6"
  cloud {
    organization = "griffdawg123"
    workspaces {
      name = "homelab"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
