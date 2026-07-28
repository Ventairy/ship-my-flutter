# AGENTS.md — SMF workspace

## Mission

SMF turns Flutter releases into a reviewed state transition: merge normal
Conventional Commits, review and test an automatically prepared platform
release PR, then merge that exact tested candidate into delivery.

Optimize for newcomer-friendly defaults, expert extensibility, deterministic
behavior, independent platform versions, Git-backed auditability, and safe
irreversible operations.

This file applies to the whole repository. Explicit user instructions and a
closer nested `AGENTS.md` take precedence.

## Workspace architecture

This is a Dart workspace managed with Melos:

```text
packages/
  smf_hooks/    Lightweight typed hook SDK
  smf_engine/   Platform-neutral planning, state, and orchestration
  smf_apple/    Apple signing and delivery adapter
  smf_android/  Android signing and Google Play delivery adapter
  smf_cli/      Globally installed `smf` command
doc/           Consumer guides
```

Required dependency direction:

```text
smf_cli -> smf_engine -> smf_hooks
smf_cli -> smf_apple -> smf_engine
smf_cli -> smf_android -> smf_engine
```

- Core never imports a platform adapter.
- Platform-specific implementation belongs in its adapter.
- Hooks must remain lightweight and independent of core.
- The CLI owns terminal parsing and contains the only public executable.
- Do not add a platform-interface package until two adapters prove core's
  contract needs one.
- The adjacent `smf-action` repository is a thin GitHub-native adapter over the
  public phased CLI; it must not reimplement Dart release logic.

## Product contracts

- Platforms own separate versions, changelogs, tags, candidates, and store
  notes. Never introduce one global app version.
- Every platform for one app shares `smf/<app-id>/release`; sibling apps have
  independent branches and PRs. App release tags are
  `<app-id>/<platform>-v<version>`.
- Candidate promotion verifies the exact recorded build, source fingerprint,
  bundle/app identity, version, and processing state. It never rebuilds.
- Identity or fingerprint mismatch is a hard failure.
- A release candidate with no `ship` target is the safe initializer default.
- Configuration and release state live under the Flutter app's `smf/`
  directory. Secrets never do.
- `app_id` is stable persisted identity. It namespaces workflows, branches,
  tags, GitHub Releases, concurrency, and GitHub Environments.
- A nested app always observes commits under its own directory.
  `release_trigger_paths` adds repository-relative shared paths.
- CLI success writes exactly one JSON value to stdout; diagnostics go to
  stderr.
- Credentials may be accepted as command-line values for local convenience,
  but help and consumer docs must recommend `SMF_*` environment variables for
  production because process arguments may be observable.
- `pubspec.yaml` is each package's version source of truth.

## Development gate

Use Dart 3.10 or newer. The current stable Dart SDK is the canonical formatter;
CI uses Dart 3.10 as a compatibility lane without enforcing its older formatter:

```bash
dart pub get
dart run melos run generate --no-select
git diff --exit-code -- packages
dart run tool/check_dart_format.dart
dart run tool/check_markdown_links.dart
dart analyze --fatal-infos
dart run melos run test --no-select
dart run melos run publish:dry-run --no-select
git diff --check
```

Static analysis inherits `very_good_analysis` 10.1.0 from the root
`analysis_options.yaml`. Keep the version exact so Dart 3.10 and stable enforce
the same rules. Project-level exceptions require a concrete architectural
reason beside the override.

After dependency changes, also run:

```bash
dart pub downgrade
dart analyze --fatal-infos
dart run melos run test --no-select
dart pub upgrade
```

The workspace lockfile is intentionally ignored. The Action owns a committed
deployment lockfile for its vendored workspace.

Generated `.freezed.dart` and `.g.dart` files are committed package source.
Never edit them directly. Use Freezed/json_serializable for non-secret value
models and DTOs; never generate value diagnostics for credentials or tokens.

## Public APIs and configuration

- `packages/smf_hooks/lib/smf_hooks.dart`,
  `packages/smf_engine/lib/smf_engine.dart`, and
  `packages/smf_apple/lib/smf_apple.dart`, and
  `packages/smf_android/lib/smf_android.dart` are deliberate export
  boundaries.
- New exports need consumer-first Dartdoc.
- Do not expose implementation solely for tests.
- Breaking exports, hook protocol, CLI output, error codes, or persisted schema
  require explicit authorization and a migration plan.

Configuration changes must keep these surfaces synchronized:

- `packages/smf_engine/lib/src/config.dart`;
- `packages/smf_engine/schemas/config.schema.json`;
- `packages/smf_engine/lib/src/templates.dart`;
- configuration tests, README, and `doc/configuration.md`.

Reject unknown fields, invalid combinations, path/symlink escapes, and secrets.
Generated templates are product code and require tests.

## Implementation and safety

- Prefer explicit, readable code, strong types, exhaustive enum switches, and
  guard clauses.
- Narrow `Object?` immediately at JSON, YAML, HTTP, process, and environment
  boundaries. Avoid `dynamic`.
- Use `SmfError` with stable uppercase codes for actionable domain failures.
- Keep network transport separate from planning and validation.
- Require clean worktrees before release mutations and restore the caller's
  branch after temporary branch work.
- Pass calculated values through typed contexts or environment variables.
  Never interpolate secret or remote values into shell source.
- Repository hooks and configured build commands are trusted consumer code;
  strip store and GitHub credentials before invoking them.

Never commit or log real Apple/Google keys, service-account JSON, keystores,
certificates, profiles, passwords, API IDs, or repository tokens. Tests use
synthetic assets and mocked APIs.
Temporary signing assets require restrictive permissions and `finally`
cleanup. Preserve pre-existing assets and delete only what SMF created.

## Testing and documentation

Every behavior change needs an observable test. Bug fixes need regression
coverage. Git tests use disposable local repositories; GitHub, Apple, and
Google Play tests use fakes or mocked HTTP; filesystem/security tests cover
escape, symlink, permissions, cleanup, and dirty-tree failures.

The entire `doc/` directory is the consumer product manual. It must contain
only information that helps someone install, configure, use, secure,
troubleshoot, or recover SMF. Never put repository/package architecture,
vendoring, internal classes or source paths, contributor test gates,
publication/tagging procedure, maintainer acceptance gates, or implementation
roadmaps in `doc/`.

Put maintainer material in the root files that own it:

- `ARCHITECTURE.md`: package ownership, dependency direction, internals, and
  implementation state machine;
- `CONTRIBUTING.md`: development setup and contributor validation;
- `RELEASING.md`: package and Action publication.

The root `README.md` is the canonical user-guide index and the repository's
single documentation front door. Do not add another index README under `doc/`.
Every focused user-facing guide must state the prerequisites, exact commands or
UI paths, expected result, relevant side effects, verification, recovery, and
links to the next related guide. Write for a first-time user who does not know
the repository architecture or Apple terminology. Prefer one canonical
explanation and cross-link it instead of duplicating partial procedures.

Keep these user surfaces synchronized:

- `README.md`: product overview, quick start, user-guide index, package
  selection, guarantees, and common questions;
- `doc/getting-started.md`: shortest safe setup path;
- `doc/apple-bootstrap.md`: beginner Apple and App Store Connect setup;
- `doc/android-bootstrap.md`: beginner Android and Google Play setup;
- `doc/configuration.md`: configuration fields and commit routing;
- `doc/hooks.md`: typed hook setup, behavior, verification, and recovery;
- `doc/how-it-works.md`: user-visible release lifecycle and state;
- `doc/operations.md`: review, delivery, retry, and recovery;
- `doc/cli.md`: commands, runners, credentials, outputs, and side effects;
- `doc/security.md`: consumer credential and workflow security;
- adjacent `smf-action/README.md`: route users to the canonical guide and never
  present a partial workflow example as a substitute for `smf init`.

## Agent and release discipline

Inspect owning code, tests, exports, docs, and external contracts before
changing them. Preserve user work, stay in scope, remove failed attempts, fix
lints instead of suppressing them, and stop when safe completion needs
credentials or authority beyond the task.

Use Conventional Commits. Testing and release preparation never authorize
tagging, publishing, pushing, TestFlight upload, App Review submission, or
production metadata changes.
