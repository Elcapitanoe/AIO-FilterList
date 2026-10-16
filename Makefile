# AIO-FilterList build automation.
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help fetch merge readme validate test build all clean

help: ## Display available commands
	@printf 'AIO-FilterList Build Automation\n\nUsage: make [target]\n\nTargets:\n'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

fetch: ## Fetch configured upstream filter lists
	@./scripts/fetch_filters.sh

merge: ## Compile configured lists into AIO_Filter_List.txt
	@./scripts/merge_filters.sh

readme: ## Update README telemetry and mirror table
	@./scripts/update_readme.sh

validate: ## Validate scripts, source configuration, and project metadata
	@./scripts/validate.sh

test: ## Run offline pipeline regression tests
	@./tests/test_pipeline.sh

build: merge ## Compile, update documentation, and validate artifacts
	@./scripts/update_readme.sh
	@./scripts/validate.sh --check-artifacts

all: ## Run the complete fetch-to-validation pipeline sequentially
	@./scripts/validate.sh
	@./scripts/fetch_filters.sh
	@./scripts/merge_filters.sh
	@./scripts/update_readme.sh
	@./scripts/validate.sh --check-artifacts

clean: ## Remove temporary build and download files
	@for dir in filters/.aio-fetch.*; do if [[ -d "$$dir" ]]; then rm -rf -- "$$dir"; fi; done
	@rm -f -- *.tmp *.tmp.* filters/.*.tmp filters/.*.tmp.* filters/*.tmp filters/*.tmp.* temp_rules.txt final_rules.txt
	@echo 'Cleanup complete.'
