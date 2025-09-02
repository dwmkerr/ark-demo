.DEFAULT_GOAL := help

.PHONY: help
help: # show help for each recipe
	@grep -E '^[a-zA-Z0-9 -]+:.*#' Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

CHART_NAME := dwmkerr-starter-kit
CHART_PATH := ./chart
NAMESPACE ?= default

# Environment variables for API keys
ANTHROPIC_API_KEY ?= 
GEMINI_API_KEY ?= 
AZURE_OPENAI_API_KEY ?= 
OPENAI_API_KEY ?=

.PHONY: install
install: # install the dwmkerr starter kit models to the cluster using Helm
	./scripts/check-env.sh
	# Phase 1: Install models and secrets only
	helm upgrade --install $(CHART_NAME) $(CHART_PATH) \
		--values values.yaml \
		--set agents=null --set teams=null \
		--set models.anthropic.enabled=$(if $(ANTHROPIC_API_KEY),true,false) \
		--set models.anthropic.apiKey="$(ANTHROPIC_API_KEY)" \
		--set models.gemini.enabled=$(if $(GEMINI_API_KEY),true,false) \
		--set models.gemini.apiKey="$(GEMINI_API_KEY)" \
		--set models.azureOpenAI.enabled=$(if $(AZURE_OPENAI_API_KEY),true,false) \
		--set models.azureOpenAI.apiKey="$(AZURE_OPENAI_API_KEY)" \
		--set models.openai.enabled=$(if $(OPENAI_API_KEY),true,false) \
		--set models.openai.apiKey="$(OPENAI_API_KEY)" \
		--create-namespace \
		--namespace $(NAMESPACE) \
		--wait
	# Phase 2: Add agents and teams (models already exist)
	helm upgrade $(CHART_NAME) $(CHART_PATH) \
		--values values.yaml \
		--set models.anthropic.enabled=$(if $(ANTHROPIC_API_KEY),true,false) \
		--set models.anthropic.apiKey="$(ANTHROPIC_API_KEY)" \
		--set models.gemini.enabled=$(if $(GEMINI_API_KEY),true,false) \
		--set models.gemini.apiKey="$(GEMINI_API_KEY)" \
		--set models.azureOpenAI.enabled=$(if $(AZURE_OPENAI_API_KEY),true,false) \
		--set models.azureOpenAI.apiKey="$(AZURE_OPENAI_API_KEY)" \
		--set models.openai.enabled=$(if $(OPENAI_API_KEY),true,false) \
		--set models.openai.apiKey="$(OPENAI_API_KEY)" \
		--namespace $(NAMESPACE) \
		--wait

.PHONY: uninstall
uninstall: # remove the dwmkerr starter kit from the cluster
	helm uninstall $(CHART_NAME) --namespace $(NAMESPACE) --ignore-not-found

.PHONY: status
status: # show deployment status
	helm status $(CHART_NAME) --namespace $(NAMESPACE)
	kubectl get models,secrets -l ark.mckinsey.com/service=dwmkerr-starter-kit -n $(NAMESPACE)

.PHONY: template
template: # render chart templates to see what would be created
	helm template $(CHART_NAME) $(CHART_PATH) \
		--values values.yaml \
		--set models.anthropic.enabled=$(if $(ANTHROPIC_API_KEY),true,false) \
		--set models.anthropic.apiKey="$(ANTHROPIC_API_KEY)" \
		--set models.gemini.enabled=$(if $(GEMINI_API_KEY),true,false) \
		--set models.gemini.apiKey="$(GEMINI_API_KEY)" \
		--set models.azureOpenAI.enabled=$(if $(AZURE_OPENAI_API_KEY),true,false) \
		--set models.azureOpenAI.apiKey="$(AZURE_OPENAI_API_KEY)" \
		--set models.openai.enabled=$(if $(OPENAI_API_KEY),true,false) \
		--set models.openai.apiKey="$(OPENAI_API_KEY)"