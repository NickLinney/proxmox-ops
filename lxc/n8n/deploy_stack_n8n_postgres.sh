#!/bin/bash
# ==============================================================================
# Script: deploy_stack_n8n_postgres.sh
# Purpose: Deploy Postgres + n8n LXC containers in sequence
# Author: Nick Linney
# ==============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  local level="${1:-INFO}"
  shift
  echo "[$level] $*"
}

log INFO "Deploying Postgres container..."
"$SCRIPT_DIR/deploy_postgres_lxc.sh"

log INFO "Deploying n8n container..."
"$SCRIPT_DIR/deploy_n8n_lxc.sh"

log INFO "Deployment complete."
