#!/bin/bash
# ==============================================================================
# Script: deploy_postgres_lxc.sh
# Purpose: Deploy an LXC container running PostgreSQL
# Author: Nick Linney
# ==============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env.n8n_stack"

log() {
  local level="${1:-INFO}"
  shift
  echo "[$level] $*"
}

# Load environment
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  log ERROR "Missing environment file: $ENV_FILE"
  exit 1
fi

# Download template if needed
if ! pveam list "$TEMPLATE_STORAGE" | grep -q "$TEMPLATE_NAME"; then
  log INFO "Downloading Debian 12 template..."
  pveam download "$TEMPLATE_STORAGE" "$TEMPLATE_NAME"
else
  log INFO "Template already exists."
fi

# Destroy container if exists
if pct status "$POSTGRES_CONTAINER_ID" &>/dev/null; then
  log WARN "Container $POSTGRES_CONTAINER_ID exists. Removing..."
  pct stop "$POSTGRES_CONTAINER_ID" || true
  pct destroy "$POSTGRES_CONTAINER_ID"
fi

# Create container
log INFO "Creating PostgreSQL LXC container..."
pct create "$POSTGRES_CONTAINER_ID" ${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE_NAME} \
  --hostname "$POSTGRES_HOSTNAME" \
  --cores "$POSTGRES_CORES" \
  --memory "$POSTGRES_MEMORY" \
  --swap 256 \
  --rootfs ${STORAGE_POOL}:${POSTGRES_DISK_SIZE} \
  --net0 name=eth0,bridge=$BRIDGE_IFACE,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1 \
  --ostype debian

# Mount RAID for DB persistence
DATA_PATH="$RAID_STORAGE_PATH/postgres-data"
mkdir -p "$DATA_PATH"
pct set "$POSTGRES_CONTAINER_ID" -mp0 ${DATA_PATH},mp=/var/lib/postgresql

# Start container
pct start "$POSTGRES_CONTAINER_ID"
sleep 5

# Install Postgres inside
pct exec "$POSTGRES_CONTAINER_ID" -- bash -c "
apt update &&
apt install -y postgresql &&
sudo -u postgres psql -c \"CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';\" &&
sudo -u postgres psql -c \"CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER;\"
"

# Report IP
PG_IP=$(pct exec "$POSTGRES_CONTAINER_ID" -- hostname -I | awk '{print $1}')
log INFO "Postgres deployed at $PG_IP:5432"
