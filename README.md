# template-deno

A batteries-included Deno project template targeting JSR, npm, browser, and standalone binary distribution.

## Overview

This template ships **everything** — dual registry publishing, browser/node bundles, obfuscation, standalone binaries,
security scanning, and automated releases. No real project needs all of that at once. Fork the template, then strip it
down to match your use case.

The recipes below show what to keep and what to remove for common scenarios.

### TypeScript library (JSR + npm)

The most common case — a reusable package published to both registries.

**Remove** from `deno.json` tasks: `build:bundle:*`, `build:binary`, and the obfuscation tasks.\
**Remove** from `Makefile`: the bundle/binary lines inside the `build` target.\
**Keep**: `publish:jsr`, `publish:npm`, `build:npm` and both publish jobs in `release.yml`.

### CLI tool / standalone binary

A command-line application distributed as a compiled executable. Users install via `deno install` (JSR) or download the
binary directly.

**Remove** from `deno.json` tasks: `build:bundle:*`, `build:npm`, `publish:npm`, and the obfuscation tasks.\
**Remove** from `Makefile`: the bundle/npm lines inside the `build` target.\
**Remove** from `release.yml`: the `publish-npm` job.\
**Keep**: `build:binary`, `publish:jsr`.

> You may also want to add cross-compilation targets and attach binaries to GitHub Releases as assets.

### Single-file browser bundle

A minified JS file meant to be loaded via `<script>` tag or bundled into a larger app.

**Remove** from `deno.json` tasks: `build:binary`, `build:bundle:node`, `build:npm`, `publish:npm`.\
**Remove** from `release.yml`: the `publish-npm` job.\
**Keep**: `build:bundle:browser` (and optionally the obfuscated variant), `publish:jsr`.

> If you want the bundle available on CDNs like unpkg/jsdelivr, keep npm publish — those CDNs mirror npm.

### Deno-only library (JSR)

The simplest setup — a library targeting only Deno consumers.

**Remove** from `deno.json` tasks: all `build:*` tasks and `publish:npm`.\
**Remove** from `deno.json` imports: `@deno/dnt`.\
**Remove** from `Makefile`: all lines inside the `build` target except the recipe itself.\
**Remove** from `release.yml`: the `publish-npm` job.

## Features

- **Dual publish** — JSR and npm from a single codebase via [dnt](https://github.com/denoland/dnt)
- **Browser & Node bundles** — IIFE and ESM builds with optional obfuscation
- **Standalone binary** — `deno compile` output ready to ship
- **Quality gates** — formatting, linting, type checking, and doc validation
- **Testing & benchmarks** — parallel test runner with coverage, built-in benchmark support
- **Security scanning** — dependency audit (`deno audit`) and secret detection
  ([gitleaks](https://github.com/gitleaks/gitleaks))
- **Conventional Commits** — enforced via [Cocogitto](https://docs.cocogitto.io/) git hooks
- **Automated releases** — changelog generation, version bumping, and CI-driven publish on merge to master
- **CI/CD** — GitHub Actions for PR checks and releases

## Quick Start

```sh
# 1. Create a new repository from the template
gh repo create my-project --template danzigergeist/template-deno --clone
cd my-project

# 2. Install dependencies and git hooks
make setup

# 3. Verify everything works
make check && make test
```

## Project Structure

```
.
├── benchmarks/          # Deno benchmarks
│   └── mod.bench.ts
├── src/                 # Source code — library entrypoint
│   └── mod.ts
├── tests/               # Test suite
│   └── mod.test.ts
├── .github/workflows/   # CI/CD pipelines
│   ├── pr-checks.yml    # PR quality gates
│   └── release.yml      # CI-driven release & publish on push to master
├── deno.json            # Project config, tasks, and dependencies
├── cog.toml             # Cocogitto config (versioning, hooks, changelog)
├── Makefile             # Simplified command interface
├── .editorconfig        # Editor formatting rules
└── LICENSE              # MIT
```

## Commands

The `Makefile` provides a simplified interface over `deno task`:

| Command          | Description                |
| ---------------- | -------------------------- |
| `make setup`     | Install deps and git hooks |
| `make check`     | Run all quality checks     |
| `make test`      | Run test suite             |
| `make security`  | Run security scans         |
| `make build`     | Build all targets          |
| `make benchmark` | Run benchmarks             |
| `make docs`      | Generate HTML docs         |
| `make publish`   | Publish to JSR and npm     |
| `make update`    | Update dependencies        |
| `make clean`     | Remove generated artifacts |
| `make version`   | Print package metadata     |
| `make help`      | List all targets           |

For granular control, use `deno task` directly — run `deno task` with no arguments to see all available tasks.

## Build Targets

The template produces several build artifacts under `target/`:

| Target                   | Task                                        | Output                                      | Description                                     |
| ------------------------ | ------------------------------------------- | ------------------------------------------- | ----------------------------------------------- |
| **JSR**                  | `deno publish`                              | (registry)                                  | Native Deno package on [jsr.io](https://jsr.io) |
| **npm**                  | `deno task build:npm`                       | `target/npm/`                               | Node-compatible package via dnt                 |
| **Browser bundle**       | `deno task build:bundle:browser`            | `target/bundle/index.browser.js`            | Minified IIFE for `<script>` tags               |
| **Node bundle**          | `deno task build:bundle:node`               | `target/bundle/index.node.js`               | Minified ESM for Node.js                        |
| **Binary**               | `deno task build:binary`                    | `target/binary/app`                         | Standalone executable via `deno compile`        |
| **Obfuscated (browser)** | `deno task build:bundle:browser:obfuscated` | `target/bundle/index.browser.obfuscated.js` | Obfuscated browser bundle                       |
| **Obfuscated (node)**    | `deno task build:bundle:node:obfuscated`    | `target/bundle/index.node.obfuscated.js`    | Obfuscated node bundle                          |

## CI/CD

### PR Checks

Every pull request runs the following jobs (`.github/workflows/pr-checks.yml`):

- **Commits** — validates conventional commit messages via Cocogitto
- **Dependencies** — verifies lockfile integrity (`deno install --frozen`)
- **Format** — checks code formatting (`deno fmt --check`)
- **Lint** — runs lint rules (`deno lint`)
- **Types** — type-checks the project (`deno check`)
- **Docs** — validates JSDoc and doc code blocks
- **Test** — runs the test suite with coverage
- **Security** — audits dependencies for known vulnerabilities

### Release

The release workflow (`.github/workflows/release.yml`) triggers on every push to `master`:

1. Dry-run `cog bump --auto` to check for releasable commits — skips if none found
2. Bumps version, creates a release commit and tag, pushes back to `main`
3. Creates a GitHub Release with auto-generated changelog
4. Publishes to JSR (`deno publish`)
5. Builds and publishes to npm (`npm publish`)

## Release Flow

This template uses [Cocogitto](https://docs.cocogitto.io/) for version management with
[Conventional Commits](https://www.conventionalcommits.org/).

```
feat: add parser        →  minor bump (0.1.0 → 0.2.0)
fix: handle empty input →  patch bump (0.2.0 → 0.2.1)
feat!: new API          →  major bump (0.2.1 → 1.0.0)
```

Releases are fully automated — merging a PR to `master` triggers the release workflow. If the new commits include
releasable changes (`feat:`, `fix:`, breaking changes), CI automatically bumps the version, creates a tag, generates a
GitHub Release with changelog, and publishes to JSR and npm. Non-releasable commits (`chore:`, `docs:`, etc.) are
silently skipped.

## Configuration

| File            | Purpose                                                                            |
| --------------- | ---------------------------------------------------------------------------------- |
| `deno.json`     | Project metadata, dependencies, tasks, compiler options, fmt/lint/publish rules    |
| `cog.toml`      | Cocogitto settings — version tag prefix, pre-bump hooks, changelog path, git hooks |
| `.editorconfig` | Cross-editor formatting (indent style, charset, line endings)                      |

## License

[MIT](LICENSE)
