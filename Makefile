MAKEFLAGS += --no-print-directory
.SILENT:
DENO_TASK = deno task -q
.DEFAULT_GOAL := help

.PHONY: benchmark build check ci clean docs format help publish security setup test update version

benchmark: ## ⏱️ Run benchmarks
	@$(DENO_TASK) benchmark

build: ## 🧱 Run available build tasks
	@$(DENO_TASK) build:bundle:browser
	@$(DENO_TASK) build:bundle:node
	@$(DENO_TASK) build:npm
	@$(DENO_TASK) build:binary

check: ## ✅ Run fast quality checks (format, lint, types, docs, examples)
	@$(DENO_TASK) check

ci: ## 🚦 Run every check CI runs (checks, tests, security, publish dry-runs)
	@$(DENO_TASK) check:publish

clean: ## 🧹 Clean generated artifacts and the machine-global Deno cache
	@$(DENO_TASK) clean

docs: ## 📚 Generate docs
	@$(DENO_TASK) docs

format: ## 🎨 Format code
	@deno fmt

help: ## ❓ List available make targets
	@deno eval 'const files=Deno.args; const entries=[]; const pattern=/^([A-Za-z0-9_.:-]+):.*?##\s*(.+)\s*$$/; for (const file of files) { const text=await Deno.readTextFile(file); for (const line of text.split(/\r?\n/)) { const m=line.match(pattern); if (m) entries.push([m[1], m[2]]); } } entries.sort((a,b)=>a[0].localeCompare(b[0])); const pad=Math.max(8,...entries.map(([n])=>n.length))+2; for (const [name, desc] of entries) console.log(name.padEnd(pad)+desc);' $(MAKEFILE_LIST)

publish: ## 🚀 Publish to JSR and npm
	@$(DENO_TASK) publish

security: ## 🔒 Run security checks
	@$(DENO_TASK) security

setup: ## ⚙️ Setup repository
	@$(DENO_TASK) setup

test: ## 🧪 Run tests
	@$(DENO_TASK) test

update: ## 🔄 Update dependencies
	@$(DENO_TASK) update

version: ## 📦 Print package metadata
	@$(DENO_TASK) version
