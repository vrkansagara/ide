.DEFAULT_GOAL := help

GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# Define variables / path
VIM:="$(HOME)/.vim"

compose_v2_not_supported = $(shell command docker compose 2> /dev/null)
ifeq (,$(compose_v2_not_supported))
	DOCKER_COMPOSE_COMMANED = docker-compose
else
	DOCKER_COMPOSE_COMMANED = docker compose
endif

ELASTIC_SEARCH := -f docker/elasticsearch.yml
DOCKER_RUN_ELASTICSEARCH = $(DOCKER_COMPOSE_COMMANED) $(ELASTIC_SEARCH)


# ============ NODE @START
NODE := -f docker/node.yml
DOCKER_RUN_NODE = $(DOCKER_COMPOSE_COMMANED) $(NODE) run --rm node

.phony: node
node:
	$(DOCKER_COMPOSE_COMMANED) $(NODE) build

.phony: node-install
node-install:
	$(DOCKER_RUN_NODE) npm install

.phony: node-cli
node-cli:
	$(DOCKER_RUN_NODE) /bin/sh

# ============ NODE @END

# ============ ELASTICSEARCH @START
.phony: elasticsearch-up
elasticsearch-up:
	$(DOCKER_RUN_ELASTICSEARCH) up -d

.phony: elasticsearch-down
elasticsearch-down:
	$(DOCKER_RUN_ELASTICSEARCH) down

.phony: elasticsearch-clean
elasticsearch-clean:
	$(DOCKER_RUN_ELASTICSEARCH) down --volume
# ============ ELASTICSEARCH @END

.phony: help
help:
	@echo "$(NC)$(GREEN)Clean : remove vendor,node_modules and pack/*"
	@echo "$(NC)$(GREEN)node : Node build"
	@echo "$(NC)$(GREEN)node-install : Node module install"
	@echo "$(NC)$(GREEN)node-cli : Node cli"
	@echo "$(NC)$(GREEN)elasticsearch-up : Elasticsearch up"
	@echo "$(NC)$(GREEN)elasticsearch-down : Elasticsearch down"
	@echo "$(NC)$(GREEN)elasticsearch-clean : Elasticsearch clean"

.phony: info
info:
	echo "Current vim directory is " $VIM

.phony: clean
clean:
	rm -rvf $(VIM)/vendor $(VIM)/node_modules $(VIM)/pack/*