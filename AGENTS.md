# AGENTS.md

Guidance for AI agents working in this repository.

## Project

Deno 2.x library. Source in `src/`, tests in `tests/`, benchmarks in `benchmarks/`. Entry point: `src/mod.ts`.

## Setup

Run `make setup` once — installs dependencies and the Cog git hooks (commit-message validation, pre-commit format/lint,
pre-push checks).

For AI-assisted work, the official [denoland/skills](https://github.com/denoland/skills) plugin is recommended
(`/plugin marketplace add denoland/skills`, then `/plugin install deno-skills@denoland-skills` in Claude Code).

## Commands

- `make check` — format, lint, type, docs, example and dependency checks
- `make test` — test suite with enforced coverage thresholds
- `make ci` — every check CI runs: `make check`, tests, security and both publish dry-runs
- `make security` — secret scan (gitleaks) and vulnerability audit
- `make build` — browser/node bundles, npm package (dnt) and standalone binary
- `make format` — apply formatting

Individual tasks worth knowing: `deno task check:examples` runs the JSDoc and README code blocks as tests, and
`deno task test:fast` stops at the first failing test — the pre-push hook uses it, while CI runs the full `test` task so
every failure is reported at once.

## Conventions

- **Conventional Commits**, enforced by the Cog `commit-msg` hook locally and by commitlint in CI.
- **All dependencies live in the `deno.json` `imports` map** — source files use bare specifiers only; never write inline
  `npm:`/`jsr:` specifiers in code.
- **Avoid `node_modules` in every possible case** — prefer `jsr:` packages, use `npm:` only when no JSR alternative
  exists, and never set `nodeModulesDir`.
- **Coverage thresholds** are configured in `deno.json`: 80% lines, 80% branches, 100% functions — every function must
  be exercised by tests.
- Formatting and linting follow `deno fmt` / `deno lint` (line width 120).
- Every exported symbol needs JSDoc; public functions ship a runnable `@example` — doc examples are executed as real
  tests in CI.
- The npm package is type-checked against Node's type environment by `build:npm` (dnt `typeCheck`). A browser-targeted
  fork that needs DOM globals adds `compilerOptions: { lib: ['ESNext', 'DOM'] }` to the dnt build options rather than
  disabling the check.
- Tests and benchmarks run sandboxed — the `test`, `test:fast` and `benchmark` tasks pass no permission flags. A test
  that needs I/O adds the narrowest flag to the task itself (e.g. `--allow-read=./tests/fixtures`);
  `Deno.test({ permissions: ... })` can only narrow what the task already grants, never add to it. Never re-add
  `--allow-all`.

## Boundaries

Always:

- Run `make check` and `make test` before preparing a commit, and `make ci` before pushing — the pre-push hook runs
  `check`, `test:fast` and `security`.
- Keep `deno.lock` in sync — `deno task check:dependencies` verifies it.
- Treat a clean `deno audit` as evidence about npm dependencies only — it queries the npm registry and does not inspect
  `jsr:` packages, so on a JSR-only dependency tree it reports success without checking anything.

Ask first:

- Adding or updating a dependency.
- Changing CI workflows or `cog.toml`.
- Raising or lowering coverage thresholds.

Never:

- Commit secrets — gitleaks scans every PR and the full Git history.
- Skip, delete, or weaken failing tests, or bypass hooks with `--no-verify`.
- Edit `version` in `deno.json` by hand — `cog bump` owns it.
- Commit generated artifacts: `target/`, `docs/`, `.coverage/`.
