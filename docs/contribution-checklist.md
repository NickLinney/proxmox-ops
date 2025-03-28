## 🧩 **Feature Integration Checklist Template**

> Copy this into each Pull Request or Git commit message, or maintain a central checklist in `docs/contribution-checklist.md`.

### 🗂 Directory Setup

-  Create feature subdirectory: `./lxc/<feature>/`
-  Place all scripts and `.env` templates inside this folder

### 📄 `.env` Management

-  Add `.env.<feature>_example` template
-  Ensure `.env.<feature>` is included in `.gitignore`
-  Scripts load environment from correct `.env` file

### 📑 Documentation

-  Add `README.md` to `./lxc/<feature>/` with:
  -  Overview
  -  Architecture
  -  Deployment instructions
  -  Makefile usage
  -  Maintenance notes
-  Add or update `docs/network-layout.md` if virtual networking changes
-  Add or update `docs/lxc-guidelines.md` if new LXC policies or standards arise
-  Add a new row to `docs/releases.md` with semantic versioning

### 🛠 Scripts

-  Deployment script follows `set -euo pipefail` convention
-  Scripts auto-clean existing containers if present
-  Mount points use `/mnt/storage/<feature>-data` structure
-  Systemd services are registered correctly inside containers
-  Use logging convention: `log INFO|WARN|ERROR`

### 🧪 Testing

-  Stack can be deployed individually and in combination
-  IP assignment and accessibility validated post-deploy
-  `make deploy-<feature>` tested from Makefile
-  `make deploy-stack` (if combined orchestration) tested
