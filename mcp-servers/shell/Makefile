.DEFAULT_GOAL := help

.PHONY: help
help: # show help for each recipe
	@grep -E '^[a-zA-Z0-9 -]+:.*#' Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

SERVER_NAME := shell
CHART_PATH := ./chart
NAMESPACE ?= default
PYTHON := python3

.PHONY: init
init: # setup for local development
	cd server && $(PYTHON) -m pip install -r requirements.txt

.PHONY: lint
lint: # lint the code
	cd server && $(PYTHON) -m pylint server.py || true
	cd server && $(PYTHON) -m flake8 server.py || true

.PHONY: test
test: # run unit tests
	@echo "No tests defined for shell MCP server"

.PHONY: build
build: # build docker image
	cd server && docker build -t shell-mcp-server:latest .

.PHONY: install
install: # install to cluster using devspace
	devspace deploy

.PHONY: uninstall
uninstall: # remove from cluster
	helm uninstall $(SERVER_NAME) --namespace $(NAMESPACE) --ignore-not-found

.PHONY: dev
dev: # run in development mode with hot reload
	devspace dev
