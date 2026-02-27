.PHONY: list test lint lint-snippets validate help npm-publish pip-publish

SHELL := /bin/bash

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

list: ## List all available overlays, snippets, and presets
	@./sync.sh --list

lint: ## Run ShellCheck on all shell scripts
	@echo "🔍 Running ShellCheck..."
	@shellcheck sync.sh new-project.sh docs-build.sh pip-prepare.sh
	@echo "✅ ShellCheck passed"

lint-snippets: ## Validate snippet format (min lines, required sections)
	@echo "🔍 Checking snippet format..."
	@fail=0; \
	for f in snippets/*.md; do \
		name=$$(basename "$$f"); \
		lines=$$(wc -l < "$$f" | xargs); \
		if [ "$$lines" -lt 30 ]; then \
			echo "   ❌ $$name: only $$lines lines (minimum 30)"; fail=1; \
		fi; \
		if ! grep -qi "pitfall" "$$f"; then \
			echo "   ❌ $$name: missing Common Pitfalls section"; fail=1; \
		fi; \
		if ! grep -q "^## Domain Context" "$$f"; then \
			echo "   ❌ $$name: missing Domain Context section"; fail=1; \
		fi; \
		if ! grep -q "^# Snippet:" "$$f"; then \
			echo "   ❌ $$name: missing '# Snippet:' title line"; fail=1; \
		fi; \
	done; \
	if [ "$$fail" -eq 1 ]; then exit 1; fi
	@echo "✅ All snippets pass format checks"

test: ## Run bats test suite
	@echo "🧪 Running tests..."
	@bats tests/
	@echo "✅ All tests passed"

validate: ## Validate current project directory against rules
	@./sync.sh --validate

init: ## Create .ai-rules.yaml in current directory
	@./sync.sh --init

ci: lint lint-snippets test ## Run full CI pipeline (lint + test)

npm-publish: ## Publish to npm registry
	npm publish --access public

pip-publish: ## Build and publish to PyPI
	bash pip-prepare.sh
	python -m build
	twine upload dist/*

docs: ## Build docs site (requires mkdocs-material)
	@bash docs-build.sh
	@mkdocs build --strict

docs-serve: ## Serve docs locally with hot-reload
	@bash docs-build.sh
	@mkdocs serve

