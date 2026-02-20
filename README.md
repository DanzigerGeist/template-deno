# template-deno

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/DanzigerGeist/template-deno/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/DanzigerGeist/template-deno/actions/workflows/pr-checks.yml)

A batteries-included Deno project template targeting JSR, npm, browser, and standalone binary distribution.

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
| `make format`    | Format code                |
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

| Target                   | Output                                      | Description                                     |
| ------------------------ | ------------------------------------------- | ----------------------------------------------- |
| **JSR**                  | (registry)                                  | Native Deno package on [jsr.io](https://jsr.io) |
| **npm**                  | `target/npm/`                               | Node-compatible package via dnt                 |
| **Browser bundle**       | `target/bundle/index.browser.js`            | Minified IIFE for `<script>` tags               |
| **Node bundle**          | `target/bundle/index.node.js`               | Minified ESM for Node.js                        |
| **Binary**               | `target/binary/app`                         | Standalone executable via `deno compile`        |
| **Obfuscated (browser)** | `target/bundle/index.browser.obfuscated.js` | Obfuscated browser bundle                       |
| **Obfuscated (node)**    | `target/bundle/index.node.obfuscated.js`    | Obfuscated node bundle                          |

Run `deno task` to see the corresponding task name for each target.

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

### Releases

The release workflow (`.github/workflows/release.yml`) triggers on every push to `master`. It uses
[Cocogitto](https://docs.cocogitto.io/) for version management with
[Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add parser        →  minor bump (0.1.0 → 0.2.0)
fix: handle empty input →  patch bump (0.2.0 → 0.2.1)
feat!: new API          →  major bump (0.2.1 → 1.0.0)
```

When releasable commits are found (`feat:`, `fix:`, breaking changes), CI automatically:

1. Bumps the version and creates a release commit + tag
2. Creates a GitHub Release with auto-generated changelog
3. Publishes to JSR (`deno publish`)
4. Builds and publishes to npm (`npm publish`)

Non-releasable commits (`chore:`, `docs:`, etc.) are silently skipped.

## Customization Recipes

This template ships **everything**. No real project needs all of it at once — fork and strip it down to your use case.

<details>
<summary><strong>TypeScript library (JSR + npm)</strong></summary>

The most common case — a reusable package published to both registries.

**Remove** from `deno.json` tasks: `build:bundle:*`, `build:binary`, and the obfuscation tasks.\
**Remove** from `Makefile`: the bundle/binary lines inside the `build` target.\
**Keep**: `publish:jsr`, `publish:npm`, `build:npm` and both publish jobs in `release.yml`.

</details>

<details>
<summary><strong>CLI tool / standalone binary</strong></summary>

A command-line application distributed as a compiled executable. Users install via `deno install` (JSR) or download the
binary directly.

**Remove** from `deno.json` tasks: `build:bundle:*`, `build:npm`, `publish:npm`, and the obfuscation tasks.\
**Remove** from `Makefile`: the bundle/npm lines inside the `build` target.\
**Remove** from `release.yml`: the `publish-npm` job.\
**Keep**: `build:binary`, `publish:jsr`.

> You may also want to add cross-compilation targets and attach binaries to GitHub Releases as assets.

</details>

<details>
<summary><strong>Single-file browser bundle</strong></summary>

A minified JS file meant to be loaded via `<script>` tag or bundled into a larger app.

**Remove** from `deno.json` tasks: `build:binary`, `build:bundle:node`, `build:npm`, `publish:npm`.\
**Remove** from `release.yml`: the `publish-npm` job.\
**Keep**: `build:bundle:browser` (and optionally the obfuscated variant), `publish:jsr`.

> If you want the bundle available on CDNs like unpkg/jsdelivr, keep npm publish — those CDNs mirror npm.

</details>

<details>
<summary><strong>Deno-only library (JSR)</strong></summary>

The simplest setup — a library targeting only Deno consumers.

**Remove** from `deno.json` tasks: all `build:*` tasks and `publish:npm`.\
**Remove** from `deno.json` imports: `@deno/dnt`.\
**Remove** from `Makefile`: all lines inside the `build` target except the recipe itself.\
**Remove** from `release.yml`: the `publish-npm` job.

</details>

## Configuration

| File            | Purpose                                                                            |
| --------------- | ---------------------------------------------------------------------------------- |
| `deno.json`     | Project metadata, dependencies, tasks, compiler options, fmt/lint/publish rules    |
| `cog.toml`      | Cocogitto settings — version tag prefix, pre-bump hooks, changelog path, git hooks |
| `.editorconfig` | Cross-editor formatting (indent style, charset, line endings)                      |

## License

This project is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute.
