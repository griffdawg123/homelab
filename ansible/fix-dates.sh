#!/usr/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_FILE="$SCRIPT_DIR/inventory/group_vars/truenas/vault.yml"
VARS_FILE="$SCRIPT_DIR/inventory/group_vars/truenas/vars.yml"

read -s -p "Vault password: " VAULT_PASS
echo

PASS_FILE=$(mktemp)
trap "rm -f '$PASS_FILE'" EXIT
echo "$VAULT_PASS" > "$PASS_FILE"

IMMICH_API_KEY=$(ansible-vault view --vault-password-file "$PASS_FILE" "$VAULT_FILE" | grep 'immich_api_key' | awk '{print $2}' | tr -d '"')
IMMICH_SERVER_URL=$(grep 'immich_server_url' "$VARS_FILE" | awk '{print $2}' | tr -d '"')

python3 "$SCRIPT_DIR/fix-dates.py" \
  --server="$IMMICH_SERVER_URL" \
  --api-key="$IMMICH_API_KEY" \
  "$@"
