# n8n + PostgreSQL LXC Deployment Stack

This folder contains automated deployment scripts for running `n8n` and `PostgreSQL` in lightweight, secure, unprivileged LXC containers on a Proxmox host.

---

## 📦 Stack Overview

| Component | Description |
|----------|-------------|
| **n8n** | Workflow automation engine with systemd integration |
| **PostgreSQL** | Dedicated database container with persistent storage |
| **Proxmox LXC** | Uses Debian 12 container template with RAID-mounted volumes |
| **.env** | Centralized config for container IDs, hostnames, resources, and credentials |

---

## ⚙️ Files

```bash
.
├── deploy_postgres_lxc.sh          # Sets up postgres container
├── deploy_n8n_lxc.sh               # Sets up n8n container linked to DB
├── deploy_stack_n8n_postgres.sh    # Orchestrates full stack
├── .env.n8n_stack_example          # Template configuration file
├── Makefile                        # Task runner for deployments
└── README.md                       # (This file)
```

---

## 🧾 Configuration

1. Copy and configure your environment file:

```bash
cp .env.n8n_stack_example .env.n8n_stack
nano .env.n8n_stack
```

Make sure you adjust:
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- Resource allocations
- Storage pool names
- Bridge interface

---

## 🚀 Deployment

### 🔹 Deploy Both Containers

```bash
make deploy-stack
```

### 🔹 Deploy Individually

```bash
make deploy-postgres
make deploy-n8n
```

---

## 🧹 Cleanup

To stop and remove the containers:

```bash
make clean
```

---

## 🧪 Testing

- After deployment, n8n should be accessible at:  
  `http://<n8n-container-ip>:5678`

- PostgreSQL will listen on port `5432` within its own container IP

---

## 📁 Data Storage

- All persistent data is mounted from RAID storage:
  - `n8n`: `/mnt/storage/n8n-data`
  - `Postgres`: `/mnt/storage/postgres-data`

This ensures container data survives resets, rebuilds, or Proxmox host restarts.

---

## 🔗 Related Docs

- [Container Standards](../../docs/lxc-guidelines.md)
- [Network Layout](../../docs/network-layout.md)
- [Release History](../../docs/releases.md)
