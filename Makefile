# ==============================================================================
# AIO-FilterList - Development & Build Automation Makefile
# ==============================================================================
SHELL := /usr/bin/env bash
.PHONY: help all build fetch merge readme validate clean

.DEFAULT_GOAL := help

help: ## Display available commands
	@echo "AIO-FilterList Build Automation"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

fetch: ## Concurrently fetch all upstream filter lists into filters/
	@./scripts/fetch_filters.sh

merge: ## Sanitize, deduplicate, and compile rules into AIO_Filter_List.txt
	@./scripts/merge_filters.sh

readme: ## Update dynamic telemetry and routing table in README.md
	@./scripts/update_readme.sh

validate: ## Validate shell scripts, configuration syntax, and artifact integrity
	@./scripts/validate.sh --check-artifacts

build: merge readme validate ## Compile filter list, update README, and validate artifacts

all: fetch merge readme validate ## Execute full pipeline from fetch to validation

clean: ## Remove temporary build files and download artifacts
	@rm -f *.tmp filters/.*.tmp filters/*.tmp temp_rules.txt final_rules.txt
	@echo "Cleanup complete."
