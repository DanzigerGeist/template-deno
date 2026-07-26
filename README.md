# Deno Project Template

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A batteries-included Deno project template targeting JSR, npm, browser, and standalone binary distribution.

## Features

- **Dual publish** — JSR and npm from a single codebase via [dnt](https://github.com/denoland/dnt)
- **Browser & Node bundles** — IIFE and ESM builds with optional obfuscation, plus a `deno compile` binary
- **Quality gates** — formatting, linting, type checking, and doc examples executed as real tests
- **Enforced coverage** — 80% lines, 80% branches, 100% functions, configured in `deno.json`
- **Security scanning** — dependency audit (`deno audit`) and secret detection
  ([gitleaks](https://github.com/gitleaks/gitleaks))
- **Conventional Commits** — [Cocogitto](https://docs.cocogitto.io/) git hooks locally, commitlint in CI
- **Automated releases** — changelog generation, version bumping, and CI-driven publish on merge to master
- **AI-ready** — agent guidance in [`AGENTS.md`](AGENTS.md), imported by `CLAUDE.md`
- **Cross-platform** — the whole task suite runs on Linux, macOS, and Windows

## Prerequisites

| Tool                                             | Purpose                                 | macOS / Linux            | Windows                            |
| ------------------------------------------------ | --------------------------------------- | ------------------------ | ---------------------------------- |
| [Deno](https://docs.deno.com/runtime/) ≥ 2.9     | Runtime, toolchain, and task runner     | `brew install deno`      | `winget install DenoLand.Deno`     |
| [Cocogitto](https://docs.cocogitto.io/)          | Git hooks and commit validation         | `brew install cocogitto` | `cargo install cocogitto`          |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Local secret scanning (`make security`) | `brew install gitleaks`  | `scoop install gitleaks`           |
| [Node.js](https://nodejs.org/) + npm             | npm package verification and publishing | `brew install node`      | `winget install OpenJS.NodeJS.LTS` |
| make _(optional)_                                | Shorthand for `deno task` commands      | preinstalled             | `scoop install make`               |
| [gh](https://cli.github.com/) _(optional)_       | Creating a repository from the template | `brew install gh`        | `winget install GitHub.cli`        |

Every command is also available directly through `deno task`, which uses Deno's built-in cross-platform shell — `make`
is a convenience layer, not a requirement. Line endings are forced to LF via `.gitattributes`, so formatting checks
behave identically on Windows.

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

`make check` is the fast inner loop. Before pushing, run `make ci` — it runs everything CI runs.

After creating a project from the template: change `name`, `description` and `repository` in `deno.json` — leave
`version` alone, `cog bump` owns it, and `description` is copied verbatim into the published package. Then update the
matching import specifier in the `src/mod.ts` JSDoc `@example` blocks (they are compiled and executed as tests), claim
your JSR scope before the first release, and enable branch protection on `master`.

## Project Structure

```
.
├── benchmarks/          # Deno benchmarks
│   └── mod.bench.ts
├── src/                 # Source code — library entrypoint
│   └── mod.ts
├── tests/               # Test suite
│   └── mod.test.ts
├── .github/
│   ├── workflows/
│   │   ├── pr-checks.yml    # PR quality gates
│   │   └── release.yml      # CI-driven release & publish on push to master
│   └── dependabot.yml       # Dependency update automation (Deno + GitHub Actions)
├── AGENTS.md            # Guidance for AI agents
├── CLAUDE.md            # Claude Code entrypoint (imports AGENTS.md)
├── deno.json            # Project config, tasks, dependencies, coverage thresholds
├── deno.lock            # Locked dependency versions, enforced in CI by deno ci
├── cog.toml             # Cocogitto config (versioning, hooks, changelog)
├── Makefile             # Simplified command interface
├── .editorconfig        # Editor formatting rules
├── .gitattributes       # Forces LF line endings on every platform
├── .gitignore           # Ignored artifacts (target/, docs/, .coverage/)
└── LICENSE              # MIT
```

## Commands

The `Makefile` provides a simplified interface over `deno task`:

| Command          | Description                                |
| ---------------- | ------------------------------------------ |
| `make setup`     | Install deps and git hooks                 |
| `make format`    | Format code                                |
| `make check`     | Run fast quality checks                    |
| `make ci`        | Run every check CI runs                    |
| `make test`      | Run test suite                             |
| `make security`  | Run security scans                         |
| `make build`     | Build all targets                          |
| `make benchmark` | Run benchmarks                             |
| `make docs`      | Generate HTML docs                         |
| `make publish`   | Publish to JSR and npm                     |
| `make update`    | Update dependencies                        |
| `make clean`     | Remove artifacts and the global Deno cache |
| `make version`   | Print package metadata                     |
| `make help`      | List all targets                           |

For granular control, use `deno task` directly — run `deno task` with no arguments to see all available tasks. Build
artifacts land in `target/`: npm package (`target/npm/`), browser and Node bundles (`target/bundle/`), and a standalone
executable (`target/binary/`).

## Conventions

- **Conventional Commits** — enforced by the Cog `commit-msg` hook locally and by commitlint in CI.
- **All dependencies live in the `deno.json` `imports` map** — source files use bare specifiers only; no inline
  `npm:`/`jsr:` specifiers in code.
- **No `node_modules`** — prefer `jsr:` packages, use `npm:` only when no JSR alternative exists.
- **Coverage thresholds** — 80% lines, 80% branches, 100% functions; configured under `coverage.thresholds` in
  `deno.json`.
- **Formatting and linting** — `deno fmt` / `deno lint`, line width 120.
- **Documentation** — every exported symbol needs JSDoc; public functions ship a runnable `@example` executed as a real
  test in CI.

## CI/CD

### PR Checks

Every pull request runs the following jobs (`.github/workflows/pr-checks.yml`):

- **Commits** — validates conventional commit messages (commitlint)
- **Dependencies** — strict lockfile install (`deno ci`)
- **Format** — checks code formatting (`deno fmt --check`)
- **Lint** — runs lint rules (`deno lint`)
- **Types** — type-checks the project including JSDoc code blocks (`deno check --doc`)
- **Docs** — lints JSDoc for completeness across exported symbols (`deno doc --lint src/`)
- **Examples** — compiles and runs the JSDoc and README code blocks as tests (`deno test --doc src/ README.md`)
- **Test** — runs the test suite and enforces the coverage thresholds
- **Publish dry-run (JSR)** — verifies the package publishes cleanly (`deno publish --dry-run`)
- **Publish dry-run (npm)** — builds the npm package with dnt and verifies it packages (`npm publish --dry-run`)
- **Audit** — audits dependencies for known vulnerabilities (`deno audit`)
- **Secrets** — scans the full Git history for leaked credentials (gitleaks)

Repositories owned by a GitHub **organization** must supply a `GITLEAKS_LICENSE` secret — without it the gitleaks action
exits before scanning. Personal accounts need no license and can ignore this.

### Releases

The release workflow (`.github/workflows/release.yml`) triggers on every push to `master`, and can be run manually from
the Actions tab. It uses [Cocogitto](https://docs.cocogitto.io/) for version management with
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

Nothing is published unless the full PR check suite passes first — `release.yml` invokes `pr-checks.yml` via
`workflow_call` and the release job depends on it.

Non-releasable commits (`chore:`, `docs:`, etc.) are silently skipped. The template repository itself never releases —
the release job is guarded by `github.event.repository.is_template`.

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

**Remove** from `deno.json` tasks: `build:bundle:*`, `build:npm`, `publish:npm`, `check:publish:npm` (also drop it from
the `check:publish` dependency list), and the obfuscation tasks.\
**Remove** from `Makefile`: the bundle/npm lines inside the `build` target.\
**Remove** the `publish-npm` job from both `release.yml` and `pr-checks.yml`.\
**Update** the `publish` task command — it hardcodes `deno task publish:jsr && deno task publish:npm`.\
**Keep**: `build:binary`, `publish:jsr`.

> A CLI needs to write to stdout, so drop `no-console` from `lint.rules.include` in `deno.json` — it is enabled by
> default and will fail the lint check on your first `console.log`.

> You may also want to add cross-compilation targets and attach binaries to GitHub Releases as assets.

</details>

<details>
<summary><strong>Single-file browser bundle</strong></summary>

A minified JS file meant to be loaded via `<script>` tag or bundled into a larger app.

**Remove** from `deno.json` tasks: `build:binary`, `build:bundle:node`, `build:npm`, `publish:npm`, `check:publish:npm`
(also drop it from the `check:publish` dependency list).\
**Remove** the `publish-npm` job from both `release.yml` and `pr-checks.yml`.\
**Update** the `publish` task command — it hardcodes `deno task publish:jsr && deno task publish:npm`.\
**Keep**: `build:bundle:browser` (and optionally the obfuscated variant), `publish:jsr`.

> If you want the bundle available on CDNs like unpkg/jsdelivr, keep npm publish — those CDNs mirror npm.

</details>

<details>
<summary><strong>Deno-only library (JSR)</strong></summary>

The simplest setup — a library targeting only Deno consumers.

**Remove** from `deno.json` tasks: all `build:*` tasks, `publish:npm`, and `check:publish:npm` (also drop it from the
`check:publish` dependency list).\
**Remove** from `deno.json` imports: `@deno/dnt`.\
**Remove** from `Makefile`: all lines inside the `build` target except the recipe itself.\
**Remove** the `publish-npm` job from both `release.yml` and `pr-checks.yml`.\
**Update** the `publish` task command — it hardcodes `deno task publish:jsr && deno task publish:npm`.\
**Then** run `deno install` to regenerate `deno.lock` — removing an import leaves it stale and `deno ci` will fail.

</details>

## Configuration

| File             | Purpose                                                                            |
| ---------------- | ---------------------------------------------------------------------------------- |
| `deno.json`      | Project metadata, dependencies, tasks, compiler options, coverage thresholds       |
| `cog.toml`       | Cocogitto settings — version tag prefix, pre-bump hooks, changelog path, git hooks |
| `AGENTS.md`      | Working agreements for AI agents (commands, conventions, boundaries)               |
| `.gitattributes` | Forces LF line endings — keeps `deno fmt` consistent across platforms              |
| `.editorconfig`  | Cross-editor formatting (indent style, charset, line endings)                      |

## License

This project is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute.
