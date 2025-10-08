.DEFAULT_GOAL := help

.PHONY: help
help: # show help for each recipe
	@grep -E '^[a-zA-Z0-9 -]+:.*#' Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: init
init: # setup for local development
	@echo "No initialization required for github-mcp"

.PHONY: lint
lint: # lint the code
	@echo "Linting not configured"

.PHONY: test
test: # run unit tests
	@echo "No tests defined for github-mcp"

.PHONY: build
build: # build docker image
	@echo "No container image for github-mcp (uses GitHub's hosted service)"

.PHONY: install
install: # install to cluster using helm
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "Error: GITHUB_TOKEN environment variable is required"; \
		echo "Usage: make install GITHUB_TOKEN=your-github-token"; \
		exit 1; \
	fi
	helm upgrade --install github-mcp ./chart --set github.token="$(GITHUB_TOKEN)"

.PHONY: uninstall
uninstall: # remove from cluster
	helm uninstall github-mcp --ignore-not-found
