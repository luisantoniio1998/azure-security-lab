#!/bin/sh
# Outbound HTTPS collection only; Ctrl+C stops this lab collector.
set -eu
umask 077
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_dir"
mkdir -p work/wazuh-ingest
az webapp log tail \
  -g rg-azure-security-lab \
  -n app-security-lab-backend 2>&1 \
  | python3 -u scripts/collect_azure_logs.py --state-file work/azure-collector-seen.sqlite3 \
  >> work/wazuh-ingest/azure-security-events.jsonl
