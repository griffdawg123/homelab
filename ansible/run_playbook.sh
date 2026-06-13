#!/usr/bin/bash

usage() {
  echo "Usage: $0 <playbook>"
  echo ""
  echo "Available playbooks:"
  ls playbooks/*.yml | xargs -n1 basename | sed 's/\.yml$//'
  echo ""
  echo "Tip: run the 'facts' playbook to inspect current TrueNAS state before applying changes."
}

if [[ -z "$1" ]]; then
  usage
  exit 1
fi

playbook=$1

if [[ ! -f "playbooks/$playbook.yml" ]]; then
  echo "Playbook not found: playbooks/$playbook.yml"
  exit 1
fi

ansible-playbook "playbooks/$playbook.yml" --ask-vault-pass "${@:2}"
