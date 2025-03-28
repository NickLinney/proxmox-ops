# ==============================================================================
# Makefile - Task automation for n8n + Postgres LXC deployment
# Location: ./lxc/n8n/
# ==============================================================================

deploy-postgres:
	./deploy_postgres_lxc.sh

deploy-n8n:
	./deploy_n8n_lxc.sh

deploy-stack:
	./deploy_stack_n8n_postgres.sh

clean:
	- pct stop 200 2>/dev/null || true
	- pct destroy 200 2>/dev/null || true
	- pct stop 201 2>/dev/null || true
	- pct destroy 201 2>/dev/null || true

logs:
	@echo "This target is a placeholder for future logging support."

env-check:
	@echo "Using environment file: .env.n8n_stack"
	@test -f .env.n8n_stack || (echo "Missing .env.n8n_stack" && exit 1)
