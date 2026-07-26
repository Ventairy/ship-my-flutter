# AGENTS.md — ship-my-flutter Core

## 0. Mission and core philosophy

You are working in the Dart core of **ship-my-flutter**, a release automation
tool whose goal is to make shipping a Flutter app feel like reviewing ordinary
code.

The product promise is:

> Merge normal Conventional Commits, review and test an automatically prepared
> platform release PR, then merge that exact tested candidate into delivery.

Optimize every change for these qualities:

- **Easy for a newcomer:** the standard GitHub Action path should require
  little release-tooling knowledge.
- **Powerful for an expert:** the Dart CLI and public library must expose the
  same capabilities for custom local and hosted workflows.
- **Safe by construction:** irreversible delivery follows review, exact-build
  verification, and explicit configuration.
- **Platform independent:** iOS and future platforms own separate versions,
  changelogs, branches, tags, candidates, and store notes.
- **Auditable:** release state belongs in Git; opaque portal state is recorded
  through typed receipts and IDs.
- **Boring and deterministic:** prefer explicit, readable code and reproducible
  inputs over clever abstractions or hidden automation.

The current production scope is iOS, TestFlight, and App Store Connect.
Android-shaped state exists to preserve the platform model, but Android
delivery is not implemented.

This file applies to the entire repository. A nested `AGENTS.md` may add
more specific rules for its directory; the closest file wins when instructions
conflict. Explicit user instructions always take precedence.

---

## 1. Repository and architecture boundaries

This is a single Dart package, not a monorepo.

```text
bin/                         Executable entrypoints and command aliases
lib/ship_my_flutter.dart     Deliberate public library surface
lib/src/                     Release engine and infrastructure
lib/src/apple/               Signing, build, upload, and Apple API behavior
schemas/                     JSON Schema for YAML configuration
templates/                   User-repository workflow template
example/                     Public Dart API example
test/                        Unit and integration-style tests
doc/                         Consumer-facing guides
```

The adjacent `Ventairy/ship-my-flutter-action` repository is a separate
product. It vendors this package and provides only GitHub-native adaptation:
Action inputs, secret masking, repository context, process execution, failures,
and outputs.

### Architectural ownership

- Dart owns every release decision and side effect.
- `ReleasePlanner` and the Conventional Commit parser own version decisions.
- `ReleaseOrchestrator` owns workflow-phase selection.
- GitHub branch/PR/release behavior belongs in the GitHub domain files.
- Apple signing and App Store Connect behavior belongs under `lib/src/apple/`.
- The CLI is an adapter over those domains, not a second implementation.
- The TypeScript Action must not reimplement release, GitHub, signing, or Apple
  logic.

When behavior must work in the CLI, public API, and Action, implement it once in
Dart and keep adapters thin.

Ignored local `dist/`, `node_modules/`, and `coverage/` directories are not
source for this package. Do not restore, edit, or publish the retired Node
implementation.

---

## 2. Non-negotiable product contracts

Preserve these invariants unless the human explicitly authorizes a product
redesign.

### Platform-scoped release state

- Never introduce one global app version.
- `feat(ios)` and `fix(ios)` affect only iOS.
- A recognized different platform scope such as `fix(android)` must not enter
  the iOS changelog or determine its bump.
- Unscoped commits and non-platform feature scopes apply to every enabled
  platform.
- Platform branches use `<releaseBranchPrefix>/<platform>`.
- Platform tags use `<platform>-v<version>`.
- `pubspec.yaml` is the package/application manifest, not a shared platform
  release manifest.

### Candidate and promotion integrity

- Candidate creation happens from the platform release branch.
- Promotion happens from the configured target branch.
- A candidate receipt identifies the platform version, Apple app/build IDs,
  build number, source SHA, deterministic source fingerprint, and IPA hash.
- Promotion verifies the configured bundle ID, App Store app, exact recorded
  build, marketing version, processing state, and merged-source fingerprint.
- Promotion never rebuilds a candidate that a human supposedly tested.
- A mismatch is a hard error, never a warning or fallback.
- `upload-only` remains the safe initializer default.
- App Review submission requires explicit `submit-for-review` configuration.

### Git as the audit trail

- Configuration and release state live under `.ship-my-flutter`.
- Secrets never belong in configuration, manifests, changelogs, notes, or
  candidate receipts.
- Release branches are updated from the latest target branch rather than
  recreated blindly.
- User-owned store notes and safe human edits must survive PR updates.
- Existing safe external resources are reused on retry; retryability must not
  weaken identity checks.

### Stable machine interfaces

- CLI success writes exactly one JSON value to stdout.
- Diagnostics and failures go to stderr.
- Do not print progress or debug text to stdout.
- Do not accept raw secrets in command-line flags.
- The Action machine protocol and public output fields are compatibility
  boundaries.
- `shipMyFlutterVersion` and `pubspec.yaml` must remain synchronized.

---

## 3. Environment and deterministic setup

Requirements:

- Dart `>=3.10.0 <4.0.0`
- Git
- macOS and compatible Xcode only for real signing/build integration

Resolve the newest compatible dependency graph:

```bash
dart pub get
dart run build_runner build
```

This is a shared package with a public library API, so its generated root
`pubspec.lock` is intentionally ignored. The core must support the dependency
ranges declared in `pubspec.yaml`; the companion Action owns a separately
generated and committed deployment lockfile. After an intentional dependency
change:

1. preserve the Dart 3.10 minimum;
2. update `pubspec.yaml`;
3. verify the newest compatible resolution on Dart 3.10 and stable;
4. on Dart 3.10, run `dart pub downgrade`, analysis, and tests for the lower
   bounds;
5. inspect transitive SDK floors and security advisories;
6. run the complete gate;
7. regenerate the companion Action's lockfile before its release.

Do not add a third-party dependency merely for convenience. First determine
whether the SDK or existing dependency set can solve the problem clearly. If a
new dependency is justified, document why its maintenance, supply-chain, and
SDK costs are acceptable.

The exact `test` pin and direct `frontend_server_client` development constraint
protect the declared Dart 3.10 floor and keep downgraded test tooling compatible
with the SDK layout. Do not change either without verifying both newest and
downgraded resolutions on Dart 3.10.

---

## 4. Development and validation commands

Auto-format Dart:

```bash
dart format .
```

Run the same complete gate expected before a pull request or commit:

```bash
dart pub get
dart run build_runner build
git diff --exit-code -- lib
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
git diff --check
```

Also verify the lower dependency bounds after changing dependencies or their
constraints:

```bash
dart pub downgrade
dart analyze --fatal-infos
dart test
dart pub upgrade
```

Useful focused test commands:

```bash
dart test test/release_plan_test.dart
dart test test/cli_test.dart
dart test --name "<descriptive test name>"
```

CI runs the newest compatible resolution, analyzer, and test suite on Dart 3.10
and stable; verifies the downgraded resolution on Dart 3.10; then performs a
separate publication dry run. Work is not complete merely because it passes on
the developer's current SDK.

Do not hide analyzer findings. Fix the cause. Add an ignore only for a proven,
documented false positive or an intentional pattern that cannot be expressed
cleanly, and explain the exception immediately beside it.

---

## 5. Dart coding conventions

### Clarity over cleverness

- Write explicit, readable production code.
- Prefer descriptive domain names over abbreviations.
- Avoid speculative abstractions, magic behavior, and condensed control flow.
- Delete dead code, unused imports, commented-out implementations, obsolete
  compatibility layers, and abandoned experiments.
- Prefer guard clauses and early returns over nested `if`/`else` chains.

### Names must match behavior

- A function's name, responsibility, and return value must describe the same
  operation.
- `validate...` and `verify...` functions validate or verify, return
  `void`/`Future<void>`, and throw a typed failure.
- Value-producing functions use honest verbs such as `load`, `read`, `find`,
  `create`, `parse`, or `resolve`.
- Keep verification and retrieval separate when combining them would make the
  call site misleading.

### Strong type safety

- Avoid `dynamic`.
- Accept `Object?` at untrusted JSON, YAML, HTTP, process, and environment
  boundaries, then narrow it immediately with explicit runtime checks.
- Do not pass loosely typed maps deeper into domain logic.
- Prefer immutable value objects with `final` fields and `const` constructors.
- Use named parameters when a function or constructor has multiple primitive
  arguments whose order is not self-evident.
- Prefer enums over magic strings for closed domain states.
- Switch exhaustively over enums. Never add a `default` or wildcard case that
  would hide a future enum value; `no_default_cases` is intentional.

### Generated models and DTOs

- Use Freezed for immutable, non-secret value models that need deep equality,
  collection immutability, or `copyWith` state transitions.
- Use json_serializable for persisted JSON and external API response DTOs.
  Keep domain-specific validation and stable `ShipError` translation at the
  untrusted boundary.
- Keep one DTO or independently meaningful generated model per authored file.
  Shared enums may live together in one dedicated enum file.
- Generated `.freezed.dart` and `.g.dart` files under `lib/` are committed
  package source. Consumers must never need `build_runner`; contributors must
  regenerate and review these files after changing annotations.
- Never edit generated files directly.
- Freezed 3.2.5 emits spaces on some otherwise blank generated lines.
  `.gitattributes` excludes only `*.freezed.dart` from Git's blank-at-EOL
  warning so generated output remains byte-for-byte reproducible. Do not
  normalize it by hand or weaken whitespace checks for authored files.
- Never apply generated value semantics to credentials, tokens, private keys,
  certificates, passwords, or other secret-bearing objects. Generated
  `toString` output must not create a credential-leak path.
- Prefer generated `copyWith` for immutable state changes instead of manually
  rebuilding every unchanged field.

### Files and ownership

- Keep one coherent domain responsibility per file.
- Do not split small value types into ceremonial files when they form one
  obvious schema, but split large independent clients or implementations.
- Keep Apple-only code under `lib/src/apple/`.
- Keep network transport separate from planning and domain validation.
- Reusable stateful behavior belongs in a class with explicit injected
  dependencies.
- Top-level functions are allowed when they are a deliberate part of this
  package's established functional API or a small cohesive domain operation.
  Do not refactor the public functional API into utility classes solely to
  satisfy a stylistic preference.
- Avoid single-use typedefs. Extract a function type only when the signature is
  reused or forms a meaningful test seam.

### Public API

- `lib/ship_my_flutter.dart` is the authoritative export boundary.
- Every newly exported declaration needs consumer-first `///` documentation:
  what it does, when to use it, side effects, prerequisites, and important
  guarantees.
- Internal declarations do not need ceremonial Dartdoc; clear names and small
  responsibilities are better.
- Do not expose an implementation merely to simplify a test.
- Before changing, renaming, or removing an export, search examples,
  executable aliases, tests, documentation, and the companion Action protocol.
- Breaking public or CLI changes require explicit authorization and a migration
  plan.

### Errors

- Use `ShipError` for actionable domain and validation failures.
- Error codes are stable machine-readable contracts. Keep them concise and
  uppercase with underscores.
- Preserve useful external status/context without leaking credentials,
  certificate material, private paths, or full sensitive response bodies.
- Never silently recover from identity, signing, fingerprint, permission, or
  configuration mismatches.

---

## 6. Configuration and persisted state

The user-facing configuration is
`.ship-my-flutter/config.yaml`. Its contract is mirrored by:

- typed parsing and validation in `lib/src/config.dart`;
- `schemas/config.schema.json`;
- generated defaults in `lib/src/templates.dart`;
- `doc/configuration.md` and relevant README examples;
- configuration tests.

Whenever configuration changes, update all applicable surfaces in the same
change. Schema autocomplete, runtime defaults, examples, and validation must
never disagree.

Configuration is strict:

- reject unknown fields;
- reject invalid combinations early;
- constrain repository-relative paths to the repository;
- reject symlink/path escapes;
- never allow secrets in build arguments or persisted state;
- preserve `schemaVersion` and provide an explicit migration strategy before a
  breaking schema change.

`manifest.json`, `changelog.json`, `store-release-notes.json`, and candidate
receipts remain versioned JSON because they are machine-owned or audit-oriented
state. Do not convert them to YAML merely because configuration uses YAML.

Generated templates are product code. A template change requires tests and
consumer documentation just like a public Dart API change.

---

## 7. CLI and custom workflow rules

The main CLI and package-qualified aliases must remain behaviorally aligned:

- `open-pr` and `release`
- `candidate` and `testflight`
- `promote` and `app-store`

When adding or changing a command:

1. update argument parsing and top-level help;
2. keep secrets in environment variables or file inputs;
3. preserve the single-JSON stdout contract;
4. document branch, runner, credential, full-history, and clean-tree
   requirements;
5. document every mutation and external side effect;
6. update executable aliases when applicable;
7. add CLI-level tests, not only domain-unit tests;
8. update the Action only when the machine protocol is affected.

The internal `action` command is a machine adapter. Do not encourage consumers
to depend on undocumented protocol details.

Repository hooks execute untrusted repository-owned code from the release
checkout. Pass only the documented non-secret context and strip credential
environment variables before invoking hooks, Git, Flutter, Dart, Xcode, or
other subprocesses.

---

## 8. GitHub and process execution rules

- Use full Git history and tags for release calculations.
- Require a clean worktree before release-branch, candidate, or promotion
  mutations.
- Keep authenticated Git credentials scoped to the individual fetch or push.
- Do not persist checkout credentials for later build tooling to reuse.
- Encode owner, repository, branch, label, and tag values at API boundaries.
- Validate GitHub response shapes before creating domain objects.
- Preserve the caller's starting branch after temporary release-branch work.
- Keep subprocess invocation argument-based; do not construct shell command
  strings from repository or user input.
- Fail with the command's relevant stderr while excluding secret-bearing
  arguments.
- Do not introduce shell scripts for release-domain behavior. Implement
  portable orchestration in Dart; platform-native tools remain subprocesses.

Changes to GitHub permissions or token behavior must account for GitHub's
`GITHUB_TOKEN` event-recursion rules and organization policies. Do not claim
that token-created PR events trigger independent workflows unless verified by
the actual authentication path.

---

## 9. Apple, signing, and secret safety

Release credentials are high-value secrets.

- Never commit or log real `.p8`, `.p12`, `.mobileprovision`, API IDs, issuer
  IDs, certificate passwords, repository tokens, or decoded secret material.
- Tests use synthetic signing data and mocked Apple/GitHub endpoints.
- Temporary secret files use owner-only permissions where supported.
- Signing uses a dedicated temporary keychain.
- Installed profiles, generated export options, API keys, temporary keychains,
  and temporary directories are cleaned in `finally` paths.
- Preserve assets that existed before the process; delete only assets created
  by ship-my-flutter.
- Do not pass secrets to repository hooks, Flutter builds, or unrelated child
  processes.
- Prefer ephemeral macOS runners. Treat cleanup on a persistent self-hosted
  runner as a security boundary, not housekeeping.

Apple integration code must distinguish:

- what is proven by unit tests and mocked HTTP contracts;
- what is proven by a disposable real app/team;
- what remains unverified in App Store Connect.

Changes to App Store Connect endpoints must be checked against current
authoritative Apple documentation. Changes to certificate/profile handling
must include cleanup and mismatch tests. Never use a production app/team to
make an automated test pass.

---

## 10. Testing protocol

Untested release behavior is broken behavior.

### Required test behavior

- Every behavioral change adds or updates tests.
- Every bug fix includes a regression test that reproduces the failure.
- When the root cause is clear, write the regression test first, confirm it
  fails for the right reason, implement the fix, then confirm it passes.
- When the cause is unclear, investigate and collect evidence before changing
  production code. Do not guess.
- Test names describe the condition/action and observable outcome. Prefer
  `when ..., it should ...` where it reads naturally.
- Keep assertions for one coherent behavior together; split tests when failures
  would otherwise be ambiguous.
- Use explicit fixed timestamps and injected dependencies for time-sensitive
  behavior.

### Test ownership

- Conventional Commit parsing and bump routing belong in planner/parser tests.
- Git behavior uses disposable local repositories.
- GitHub behavior uses mocked HTTP or a fake `GitHubApi`.
- Apple behavior uses a fake `AppStoreConnectApi` and synthetic artifacts.
- CLI tests verify exit codes, stdout JSON, stderr, alias behavior, and secret
  rejection.
- Filesystem/security tests cover path escape, symlink, permissions, cleanup,
  and dirty-tree failures where relevant.

Avoid mocks that merely restate implementation calls. Prefer testing the
observable state transition, serialized contract, Git tree, HTTP request, or
failure code.

Real hosted-repository tests belong in a disposable repository. Real Apple
acceptance is a separate, explicitly authorized gate and must be reported as
such.

---

## 11. Documentation ownership

- `README.md` is the product-first onboarding path and requirements summary.
- `doc/` is consumer-facing: configuration, CLI use, operations, security, and
  Apple bootstrap.
- `CONTRIBUTING.md` is the concise human contribution guide.
- `AGENTS.md` contains detailed agent-specific engineering rules.
- `RELEASING.md` is the maintainer contract for publishing this package and
  coordinating the companion Action.
- `SECURITY.md` owns vulnerability reporting.

Keep documentation synchronized with behavior:

- setup/tooling/dependency changes update README and AGENTS when applicable;
- configuration changes update schema, generated defaults, tests, and consumer
  docs;
- CLI changes update help, CLI reference, examples, and tests;
- security-boundary changes update `doc/security.md`;
- release/provenance changes update `RELEASING.md`;
- Apple capability changes state the verified/unverified live boundary.

Do not place contributor or release-maintainer procedures in `doc/`; keep that
directory focused on package consumers.

---

## 12. Agent operational constraints

1. **Inspect before changing.** Read the owning implementation, tests, exports,
   docs, and relevant external contract before editing.
2. **Stay in scope.** Do not perform adjacent cleanups or change the companion
   Action unless directly required by the request.
3. **Preserve user work.** Treat existing worktree changes as user-owned. Never
   discard them or use destructive Git commands without explicit authority.
4. **No speculative fixes.** Establish the root cause with tests, logs, typed
   responses, or repository evidence before modifying production code.
5. **Revert failed attempts.** If an agent-owned attempted fix does not solve
   the issue, remove only that attempt before trying another approach.
6. **No dead code.** Do not leave temporary flags, debug output, commented
   implementations, unused compatibility shims, or untracked generated files.
7. **No silent contracts.** Analyze downstream effects before changing public
   exports, CLI JSON, error codes, configuration/state schemas, branch/tag
   conventions, or receipt fields.
8. **Fix lints, do not suppress them.** Suppression is the documented last
   resort for a genuine analyzer limitation.
9. **Fail safely.** Stop and explain the exact blocker when safe completion
   needs credentials, live Apple state, human judgment, or authority beyond the
   task.
10. **Separate preparation from release authority.** Testing or preparing a
    release never authorizes tagging, publishing, moving `v1`, uploading to
    TestFlight, submitting to App Review, or changing production metadata.

For unstable external behavior—Apple APIs, GitHub Actions permissions, Dart
package constraints—verify current primary documentation instead of relying on
memory.

---

## 13. Pull requests, commits, and definition of done

Use Conventional Commits:

- `feat(ios): ...` for iOS-only features;
- `fix(ios): ...` for iOS-only fixes;
- `feat: ...` or `fix: ...` for behavior that applies to every platform;
- `docs: ...`, `test: ...`, `refactor: ...`, and `chore: ...` when no release
  bump should be created by this package's planner.

Keep unrelated work separate. Pull requests must explain:

- the user-visible or operator-visible behavior;
- why the change belongs in the core rather than an adapter;
- configuration, public API, CLI, security, or migration impact;
- tests performed;
- whether Apple behavior was mocked, tested with a disposable app, or not
  exercised live.

Before declaring work complete:

- [ ] Requested behavior is implemented without unrelated changes.
- [ ] Public API, CLI, schema, templates, and docs are synchronized.
- [ ] Regression/behavior tests cover the change.
- [ ] Dart 3.10 compatibility is preserved.
- [ ] The complete local gate passes.
- [ ] No credential, production identifier, or secret-bearing output exists.
- [ ] Apple and hosted-repository validation boundaries are stated honestly.
- [ ] Companion Action impact is identified when the machine protocol or
      vendored source changes.
- [ ] No tag, publication, release, or store operation was performed without
      explicit authorization.
