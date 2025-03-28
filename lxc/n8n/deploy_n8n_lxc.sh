#!/bin/bash
# ==============================================================================
# Script: deploy_n8n_lxc.sh
# Purpose: Deploy an LXC container running n8n workflow automation
# Author: Nick Linney
# ==============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

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
  log ERROR "Missing .env file: $ENV_FILE"
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
if pct status "$N8N_CONTAINER_ID" &>/dev/null; then
  log WARN "Container $N8N_CONTAINER_ID exists. Removing..."
  pct stop "$N8N_CONTAINER_ID" || true
  pct destroy "$N8N_CONTAINER_ID"
fi

# Create container
log INFO "Creating n8n LXC container..."
pct create "$N8N_CONTAINER_ID" ${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE_NAME} \
  --hostname "$N8N_HOSTNAME" \
  --cores "$N8N_CORES" \
  --memory "$N8N_MEMORY" \
  --swap 512 \
  --rootfs ${STORAGE_POOL}:${N8N_DISK_SIZE} \
  --net0 name=eth0,bridge=$BRIDGE_IFACE,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1 \
  --ostype debian

# Mount RAID for persistence
N8N_DATA_PATH="$RAID_STORAGE_PATH/n8n-data"
mkdir -p "$N8N_DATA_PATH"
pct set "$N8N_CONTAINER_ID" -mp0 ${N8N_DATA_PATH},mp=/home/n8n/.n8n

# Start container
pct start "$N8N_CONTAINER_ID"
sleep 5

# Install Node.js and n8n
pct exec "$N8N_CONTAINER_ID" -- bash -c "
apt update &&
apt install -y curl sudo gnupg git &&
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&
apt install -y nodejs &&
useradd -m -s /bin/bash n8n &&
su - n8n -c 'npm install -g n8n'
"

# Create systemd service
pct exec "$N8N_CONTAINER_ID" -- bash -c "
cat <<EOF > /etc/systemd/system/n8n.service
[Unit]
Description=n8n Automation
After=network.target

[Service]
Type=simple
User=n8n
Environment=DB_TYPE=postgresdb
Environment=DB_POSTGRESDB_HOST=$(pct exec "$POSTGRES_CONTAINER_ID" -- hostname -I | awk '{print $1}')
Environment=DB_POSTGRESDB_PORT=5432
Environment=DB_POSTGRESDB_DATABASE=$POSTGRES_DB
Environment=DB_POSTGRESDB_USER=$POSTGRES_USER
Environment=DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD
ExecStart=/usr/bin/n8n
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable n8n
systemctl start n8n
"

# Report IP
N8N_IP=$(pct exec "$N8N_CONTAINER_ID" -- hostname -I | awk '{print $1}')
log INFO "n8n running at http://${N8N_IP}:5678"
