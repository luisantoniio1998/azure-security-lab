#!/bin/sh
# Local Wazuh only. Does not change Azure or remove persistent volumes.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
runtime_dir="$repo_dir/monitoring/wazuh/.runtime"
cd "$runtime_dir"
case "${1:-status}" in
  start) docker compose -p azure-lab-wazuh up -d ;;
  stop) docker compose -p azure-lab-wazuh stop ;;
  status) docker compose -p azure-lab-wazuh ps ;;
  logs) docker compose -p azure-lab-wazuh logs --tail 60 ;;
  password)
    # Display locally only. Never commit .runtime or paste credentials into chat.
    awk -F= '$1 == "INDEXER_PASSWORD" { print substr($0, index($0, "=") + 1) }' .env
    ;;
  *) echo "Usage: $0 {start|stop|status|logs|password}" >&2; exit 2 ;;
esac
