#!/usr/bin/bash

VAULT_FILE="inventory/group_vars/truenas/vault.yml"

if [[ ! -f "$VAULT_FILE" ]]; then
  echo "Vault file not found: $VAULT_FILE"
  echo "Copy vault.yml.example to vault.yml and encrypt it first."
  exit 1
fi

ansible-vault edit "$VAULT_FILE" --ask-vault-pass
