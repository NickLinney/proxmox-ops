# Proxmox-Ops Monorepo

A modular infrastructure-as-code repository for managing LXC containers, VMs, networking, and automation stacks on a single-node or small-cluster Proxmox environment.

---

## 📁 Repository Structure

```bash
proxmox-ops/
├── lxc/                  # Modular deployment scripts for LXC containers
│   └── n8n/              # n8n automation + PostgreSQL stack
│       ├── deploy_postgres_lxc.sh
│       ├── deploy_n8n_lxc.sh
│       ├── deploy_stack_n8n_postgres.sh
│       ├── .env.n8n_stack_example
│       ├── Makefile
│       └── README.md
├── docs/                 # Cross-functional infrastructure documentation
│   ├── lxc-guidelines.md
│   ├── network-layout.md
│   └── releases.md
├── .gitignore
└── README.md             # (This file)
```

---

## 🛠️ How to Use

1. Clone the repository to your Proxmox host:
   ```bash
   git clone git@github.com:NickLinney/proxmox-ops.git
   cd proxmox-ops/lxc/n8n
   ```

2. Create a local `.env.n8n_stack` file from the example:
   ```bash
   cp .env.n8n_stack_example .env.n8n_stack
   nano .env.n8n_stack
   ```

3. Deploy the stack:
   ```bash
   make deploy-stack
   ```

4. Or deploy individual components:
   ```bash
   make deploy-postgres
   make deploy-n8n
   ```

---

## 🔄 Version Control & Releases

We follow [Semantic Versioning](https://semver.org/):
- **Major**: Incompatible infrastructure change
- **Minor**: Backward-compatible feature addition
- **Patch**: Fixes, refactoring, or script updates

All releases are logged in [`docs/releases.md`](./docs/releases.md)

---

## 🤝 Contribution Guidelines

- Use feature branches: `feature/<short-description>`
- Submit Pull Requests into `main` or `dev` branches
- Each feature folder must include its own `README.md`
- Secrets or local `.env` files must be `.gitignore`d
- Always update relevant `docs/` and root `README.md` on change

---

## 🔗 Reference Docs

- [LXC Container Standards](./docs/lxc-guidelines.md)
- [Network Topology](./docs/network-layout.md)
- [n8n Stack Deployment Guide](./lxc/n8n/README.md)
