# Deno Project Template

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Deno 2.x library template: one codebase, published to JSR and npm, bundled for browsers, compiled to a binary.

## Features

- **Publishes to four targets**: JSR and npm from one codebase via [dnt](https://github.com/denoland/dnt), plus browser
  and Node bundles (optionally obfuscated) and a `deno compile` binary
- **Quality gates**: formatting, linting, type checking, and doc examples executed as real tests
- **Enforced coverage**: 80% lines, 80% branches, 100% functions, configured in `deno.json`
- **Security scanning**: npm dependency audit (`deno audit`) and secret detection
  ([gitleaks](https://github.com/gitleaks/gitleaks))
- **Releases itself**: [Conventional Commits](https://www.conventionalcommits.org/) drive the version bump, changelog,
  GitHub Release and publish on merge to `master`, via [Cocogitto](https://docs.cocogitto.io/) hooks locally and
  commitlint in CI
- **AI-ready**: agent guidance in [`AGENTS.md`](AGENTS.md), imported by `CLAUDE.md`
- **Cross-platform**: the whole task suite runs on Linux, macOS, and Windows

## Prerequisites

| Tool                                             | Purpose                                 | macOS / Linux            | Windows                            |
| ------------------------------------------------ | --------------------------------------- | ------------------------ | ---------------------------------- |
| [Deno](https://docs.deno.com/runtime/) ≥ 2.9     | Runtime, toolchain, and task runner     | `brew install deno`      | `winget install DenoLand.Deno`     |
| [Cocogitto](https://docs.cocogitto.io/)          | Git hooks and commit validation         | `brew install cocogitto` | `cargo install cocogitto`          |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Local secret scanning (`make security`) | `brew install gitleaks`  | `scoop install gitleaks`           |
| [Node.js](https://nodejs.org/) + npm             | npm package verification and publishing | `brew install node`      | `winget install OpenJS.NodeJS.LTS` |
| make _(optional)_                                | Shorthand for `deno task` commands      | preinstalled             | `scoop install make`               |
| [gh](https://cli.github.com/) _(optional)_       | Creating a repository from the template | `brew install gh`        | `winget install GitHub.cli`        |

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

After creating a project from the template: change `name`, `description` and `repository` in `deno.json`. Leave
`version` alone, since `cog bump` owns it, and note that `description` is copied verbatim into the published package.
Then update the matching import specifier in the `src/mod.ts` JSDoc `@example` blocks (they are compiled and executed as
tests), claim your JSR scope before the first release, and enable branch protection on `master`.

## Project Structure

Library code lives in `src/` (`src/mod.ts` is the entrypoint declared in `exports`), tests in `tests/`, benchmarks in
`benchmarks/`. Build output goes to `target/` and is git-ignored. Everything else at the root is configuration:

| File             | Purpose                                                                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| `deno.json`      | Project metadata, dependencies, tasks, compiler options, lint rules, coverage thresholds                     |
| `deno.lock`      | Locked dependency versions; CI installs strictly from it (`deno ci`)                                         |
| `cog.toml`       | Cocogitto settings: version tag prefix, pre-bump hooks, changelog path, git hooks                            |
| `AGENTS.md`      | Working agreements for humans and AI agents; `CLAUDE.md` only imports it                                     |
| `Makefile`       | Shorthand over `deno task`, using Deno's cross-platform shell, a convenience rather than a requirement       |
| `.github/`       | `pr-checks.yml` (PR gates), `release.yml` (version, tag, publish), `dependabot.yml` (Deno + Actions updates) |
| `.gitattributes` | Forces LF line endings, keeping `deno fmt` consistent across platforms                                       |
| `.editorconfig`  | Cross-editor formatting (indent style, charset, line endings)                                                |

## Commands

| Command          | Description                                                                  |
| ---------------- | ---------------------------------------------------------------------------- |
| `make setup`     | Install dependencies and the Cog git hooks; run once after creating the repo |
| `make format`    | Apply formatting                                                             |
| `make check`     | Inner loop: lockfile, format, lint, types, JSDoc, doc examples. No tests.    |
| `make test`      | Run the suite and enforce the coverage thresholds                            |
| `make ci`        | Before pushing: every PR check except commit-message validation              |
| `make security`  | Secret scan and npm vulnerability audit                                      |
| `make build`     | Build all four targets                                                       |
| `make benchmark` | Run benchmarks                                                               |
| `make docs`      | Generate HTML docs                                                           |
| `make publish`   | Publish to JSR and npm                                                       |
| `make update`    | Update dependencies                                                          |
| `make clean`     | Remove artifacts **and the machine-global Deno cache**                       |
| `make version`   | Print package metadata                                                       |
| `make help`      | List all targets                                                             |

`deno task` with no arguments lists the underlying tasks, which are more granular. `make build` writes to `target/`: the
npm package in `target/npm/`, browser and Node bundles in `target/bundle/`, and a standalone executable in
`target/binary/`.

## Conventions

Spelled out in full in [`AGENTS.md`](AGENTS.md), which applies to humans and agents alike. Three catch people out:

- **All dependencies live in the `deno.json` `imports` map**: source files use bare specifiers only, never inline
  `npm:`/`jsr:` specifiers. Prefer `jsr:` packages; use `npm:` only when no JSR alternative exists.
- **Every exported symbol needs JSDoc**, enforced by `deno doc --lint`. A runnable `@example` is strongly encouraged but
  not enforced, but any you write are compiled and executed as tests.
- **Never edit `version` in `deno.json`**: `cog bump` owns it.

## CI/CD

### PR Checks

Every pull request runs [`pr-checks.yml`](.github/workflows/pr-checks.yml). Each gate is its own job, so a red check
names its own failure: commits, dependencies, format, lint, types, docs, examples, test, JSR and npm publish dry-runs,
audit, and a gitleaks scan of the full Git history.

Four are easy to miss:

- Code blocks in JSDoc **and in this README** are compiled and executed as tests (`deno test --doc src/ README.md`). A
  stale example fails the build; tag a fence `` ```ts ignore `` to skip it.
- `deno audit` queries the npm registry only, so it does not inspect `jsr:` packages, so a clean audit on a JSR-only
  dependency tree means nothing was checked.
- Repositories owned by a GitHub **organization** must supply a `GITLEAKS_LICENSE` secret; without it the gitleaks
  action exits before scanning. Personal accounts need no license.
- The coverage report only covers modules the tests load, so a source file nothing imports is invisible to it.

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

Nothing is published unless the full PR check suite passes first: `release.yml` invokes `pr-checks.yml` via
`workflow_call` and the release job depends on it.

Non-releasable commits (`chore:`, `docs:`, etc.) are silently skipped. The template repository itself never releases;
the release job is guarded by `github.event.repository.is_template`.

## Customization Recipes

This template ships **everything**. No real project needs all of it at once. Strip it down to your use case.

<details>
<summary><strong>TypeScript library (JSR + npm)</strong></summary>

The most common case: a reusable package published to both registries.

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
**Update** the `publish` task command, which hardcodes `deno task publish:jsr && deno task publish:npm`.\
**Keep**: `build:binary`, `publish:jsr`.

> A CLI needs to write to stdout, so drop `no-console` from `lint.rules.include` in `deno.json`, where it is enabled by
> default and will fail the lint check on your first `console.log`.

> You may also want to add cross-compilation targets and attach binaries to GitHub Releases as assets.

</details>

<details>
<summary><strong>Single-file browser bundle</strong></summary>

A minified JS file meant to be loaded via `<script>` tag or bundled into a larger app.

**Remove** from `deno.json` tasks: `build:binary`, `build:bundle:node`, `build:npm`, `publish:npm`, `check:publish:npm`
(also drop it from the `check:publish` dependency list).\
**Remove** the `publish-npm` job from both `release.yml` and `pr-checks.yml`.\
**Update** the `publish` task command, which hardcodes `deno task publish:jsr && deno task publish:npm`.\
**Keep**: `build:bundle:browser` (and optionally the obfuscated variant), `publish:jsr`.

> If you want the bundle available on CDNs like unpkg/jsdelivr, keep npm publish, since those CDNs mirror npm.

</details>

<details>
<summary><strong>Deno-only library (JSR)</strong></summary>

The simplest setup: a library targeting only Deno consumers.

**Remove** from `deno.json` tasks: all `build:*` tasks, `publish:npm`, and `check:publish:npm` (also drop it from the
`check:publish` dependency list).\
**Remove** from `deno.json` imports: `@deno/dnt`.\
**Remove** from `Makefile`: all lines inside the `build` target except the recipe itself.\
**Remove** the `publish-npm` job from both `release.yml` and `pr-checks.yml`.\
**Update** the `publish` task command, which hardcodes `deno task publish:jsr && deno task publish:npm`.\
**Then** run `deno install` to regenerate `deno.lock`, since removing an import leaves it stale and `deno ci` will fail.

</details>

## License

This project is licensed under the [MIT License](LICENSE): free to use, modify, and distribute.
