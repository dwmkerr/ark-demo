.DEFAULT_GOAL := help

.PHONY: help
help: # show help for each recipe
	@grep -E '^[a-zA-Z0-9 -]+:.*#' Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

CHART_NAME := dwmkerr-ark-demo
CHART_PATH := ./chart
NAMESPACE ?= default
# Skip creating the 'default' model if one already exists in the cluster
HELM_EXTRA_ARGS :=
ifneq ($(shell kubectl get model default --no-headers 2>/dev/null),)
HELM_EXTRA_ARGS += --set skipDefaultModel=true
endif

.PHONY: install
install: # install the dwmkerr starter kit models to the cluster using Helm
	@if [ ! -f custom-values.yaml ]; then echo "Error: custom-values.yaml not found. Run 'cp custom-values.template.yaml custom-values.yaml' and configure your API keys."; exit 1; fi
	# Update Helm dependencies for optional MCP servers
	helm dependency update $(CHART_PATH)
	# Install everything in one step
	helm upgrade --install $(CHART_NAME) $(CHART_PATH) \
		--values custom-values.yaml \
		--create-namespace \
		--namespace $(NAMESPACE) \
		$(HELM_EXTRA_ARGS)
	# Install useful shit from the marketplace.
	# Requires ark CLI >= 0.1.55 for `marketplace/executors/...` support
	# (`npm install -g @agents-at-scale/ark@latest`).
	ark install marketplace/executors/executor-claude-agent-sdk
	ark install marketplace/executors/executor-openai-responses
	ark install marketplace/agents/noah
	ark install marketplace/services/a2a-inspector
	ark install marketplace/services/ark-sandbox
	ark install marketplace/services/file-gateway
	ark install marketplace/services/mcp-inspector
	ark install marketplace/services/phoenix
	# Post-Phoenix tweaks for OTel tracing (drop once marketplace issue #233 is fixed):
	#  1. Enable the OpenAI OTEL instrumentor on the Responses executor —
	#     chart defaults OTEL_INSTRUMENTATION_ENABLED=false so OpenAI-layer
	#     spans land in Phoenix with empty attributes. (Note: marketplace chart
	#     sets a *different* flag, OTEL_INSTRUMENTATION_A2A_SDK_ENABLED, which
	#     does NOT enable the OpenAI instrumentor.)
	#  2. Restart claude-agent-sdk so `envFrom: otel-environment-variables`
	#     re-reads the Secret Phoenix just created.
	#     (setting env on openai-responses triggers its own rollout.)
	kubectl set env deploy/executor-openai-responses OTEL_INSTRUMENTATION_ENABLED=true
	kubectl rollout restart deploy/executor-claude-agent-sdk

.PHONY: install-all
install-all: install # install all resources including internal tools
	(cd /Users/Dave_Kerr/repos/github/McK-Internal/agents-at-scale-marketplace/services/ark-agentcore-bridge && make install)
	(cd /Users/Dave_Kerr/repos/github/McK-Internal/agents-at-scale-user && ./aasctl setup && ./aasctl push && ./aasctl up)

.PHONY: uninstall
uninstall: # remove the dwmkerr starter kit from the cluster
	helm uninstall $(CHART_NAME) --namespace $(NAMESPACE) --ignore-not-found

.PHONY: uninstall-all
uninstall-all: uninstall # uninstall all resources including internal tools
	(cd /Users/Dave_Kerr/repos/github/McK-Internal/agents-at-scale-marketplace/services/ark-agentcore-bridge && make uninstall)
	(cd /Users/Dave_Kerr/repos/github/McK-Internal/agents-at-scale-user && ./aasctl dowm)


.PHONY: status
status: # show deployment status
	helm status $(CHART_NAME) --namespace $(NAMESPACE)
	kubectl get models,secrets -l ark.mckinsey.com/service=ark-demo -n $(NAMESPACE)

.PHONY: template
template: # render chart templates to see what would be created
	helm template $(CHART_NAME) $(CHART_PATH) \
		--values custom-values.yaml

.PHONY: upgrade-storage-backend-postgres
upgrade-storage-backend-postgres: # switch the Ark controller storage backend to PostgreSQL
	helm upgrade ark-controller oci://ghcr.io/mckinsey/agents-at-scale-ark/charts/ark-controller \
		--namespace ark-system --reuse-values \
		--set storage.backend=postgresql
