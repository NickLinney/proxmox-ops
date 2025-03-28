# LXC Container Standards

This document outlines best practices and conventions used for managing LXC containers within the Proxmox-Ops monorepo.

---

## 🧱 Container Configuration Standards

- **Unprivileged Mode**: All containers are unprivileged for security.
- **Nesting Enabled**: `nesting=1` is enabled to support Docker, Node.js, or advanced runtime operations.
- **Storage**: Use the `vm-storage` thinpool for root filesystems. Mount `/mnt/storage` for persistent data.
- **Networking**: Attach containers to `vmbr0` (or specific bridge if overridden in `.env`).
- **Resource Profiles**:
  - Lightweight: 1–2 vCPUs, 512–1024MB RAM
  - Medium: 2–4 vCPUs, 2–4GB RAM
  - Heavy-duty: >4 vCPUs, >4GB RAM (only as needed)

---

## 📂 Directory Structure

Each container or stack should live in its own subdirectory under `lxc/`, e.g.:

```bash
lxc/
├── n8n/
├── postgres/
├── redis/
```

Each subdirectory includes:
- `README.md`: Stack-specific documentation
- `.env.<stack>_example`: Environment variable template
- `.env.<stack>`: Local (ignored) config
- `Makefile`: Task runner wrapper
- Deployment scripts

---

## 🧩 Integration & Naming

- **Hostname** should match the stack (`n8n`, `pg-n8n`, `redis-cache`, etc.)
- **Container IDs** must be unique and declared in `.env` per stack
- **Mount Paths** must reflect purpose (`/mnt/storage/n8n-data`, etc.)

---

## 🔒 Security Practices

- Never commit `.env` files containing credentials
- Always run `set -euo pipefail` in deployment scripts
- Validate required dependencies (template availability, storage pool existence)
- Only use sudo/root where absolutely necessary in guest environments

---

## 🧪 Testing

- Each stack should support being deployed in isolation
- All deployment scripts must clean up any previously existing container with same ID
- Support dry-run in future enhancements for pre-deploy checks
