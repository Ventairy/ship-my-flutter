# AGENTS.md — SMF workspace

These instructions apply to the entire repository. A closer `AGENTS.md` takes
precedence for files in its directory.

Apply structural conventions to new and materially changed code. Do not churn
unrelated existing files solely to make them conform.

## Start here

- Inspect `git status` before editing. Preserve unrelated and pre-existing
  changes.
- Treat `pubspec.yaml`, package manifests, and workflow files as authoritative
  for toolchain versions, dependencies, workspace membership, and CI setup.
- Read `ARCHITECTURE.md` before changing package boundaries, release state,
  release candidate identity, or delivery behavior.
- Use `CONTRIBUTING.md` for contributor setup and `RELEASING.md` for the
  maintainer release procedure.
- Keep changes focused. Do not modify, rename, delete, or create unrelated
  files. Ask before expanding the requested scope.

## How to work

- Write explicit, boring, readable production code. Prefer clear names, strong
  types, guard clauses, and small responsibilities over cleverness or
  speculative abstractions.
- Diagnose before fixing. Reproduce the failure and identify the root cause
  from code, tests, logs, or remote contracts before changing production code.
  Add temporary diagnostics when needed, but do not leave noisy or
  credential-bearing logging behind.
- When a bug is environment-specific and cannot be reproduced locally, ask for
  the smallest useful diagnostic evidence instead of guessing.
- If an attempted fix fails, remove only the changes from that attempt before
  trying another approach. Never discard pre-existing user work.
- Leave no commented-out logic, unused imports, abandoned experiments, or
  speculative code.
- Do not add a third-party dependency unless the requested change genuinely
  requires it and the existing SDK or dependencies cannot meet the need.
- Fix analyzer findings at their source. Suppress a lint only for a documented
  false positive or intentional exception, with a nearby explanation.
- If safe completion requires a breaking design decision, credentials, a live
  service, or authority outside the request, stop and explain the exact
  blocker and trade-off.

## Package ownership

- `smf_hooks` owns the lightweight typed hook SDK.
- `smf_engine` owns the complete release implementation. Shared planning,
  persisted state, fingerprints, Git/GitHub orchestration, and workflow
  behavior live in its core source. Apple implementation belongs under
  `lib/src/ios` and is exposed through `package:smf_engine/apple.dart`.
  Android implementation belongs under `lib/src/android` and is exposed
  through `package:smf_engine/android.dart`.
- `smf_cli` owns argument parsing, terminal behavior, and composition of the
  engine libraries. It is the only public executable.

Dependencies flow from the CLI to the engine and from the engine to hooks.
Apple and Android code must remain inside their corresponding engine folders;
shared code must not depend on one platform implementation to run another.

The adjacent `smf-action` repository is a thin GitHub Actions adapter over the
CLI. Keep release decisions and store behavior in this Dart workspace.

Use the root Melos scripts for workspace-wide operations. Run focused package
commands from the owning package directory.

## Dart conventions

### Names and responsibilities

- Names must describe actual behavior and returned values. Avoid abbreviated
  names when a domain name is clearer.
- Prefer highly explicit domain names over shorthand. Include the complete
  concept in identifiers and prose; for example, use `ReleaseCandidate`
  instead of `Candidate`.
- Name every boolean field, parameter, local variable, and getter as a
  predicate. Start it with an auxiliary verb such as `is`, `are`, `has`,
  `can`, `should`, or `must`; for example, use `isBreaking` instead of
  `breaking`. Boolean-returning action methods may keep a verb phrase that
  describes the operation they perform.
- Use the same predicate name for boolean fields in SMF-owned serialized data,
  including manifests, changelogs, hook payloads, and CLI JSON output; do not
  map `isReleasePending` back to `pendingRelease`. User-authored configuration
  files such as `config.yaml` and their schemas may use configuration-style
  keys such as `enabled`, which must map to predicate names at the parsing
  boundary. Third-party wire fields must continue to match their upstream API.
- A `verify...` method only verifies: it returns `void` or `Future<void>` and
  throws on failure. It must not also retrieve or return data.
- Name value-producing operations for what they produce, using verbs such as
  `read`, `get`, `find`, `create`, `resolve`, or `parse`.
- Keep verification and value retrieval separate so call sites state what work
  they perform.

### Types and parameters

- Avoid `dynamic`. Accept unknown data as `Object?` and narrow it immediately
  at JSON, YAML, HTTP, process, environment, and filesystem boundaries.
- Prefer DTOs, immutable value objects, sealed types, and exhaustive enums over
  loosely typed maps or magic strings.
- Every DTO class name must end in `Dto`, and its source filename must end in
  `_dto.dart` (or `_dtos.dart` when one file intentionally owns several
  closely related DTOs). Supporting enums and converters are not DTOs and keep
  their domain names.
- DTO fields must mirror the real JSON object they encode. Represent every
  nested JSON object with its own DTO, including objects stored behind dynamic
  `Map<String, NestedDto>` keys; do not flatten nested fields or hand-build a
  different wire shape in `toJson`.
- Use named parameters when a function or constructor takes more than one
  primitive value. Positional parameters are acceptable when their order is an
  established, unmistakable API convention.
- Keep domain models immutable. Express state transitions by constructing a new
  value or using generated `copyWith` support.

### Enums and switches

- Use Dart enums for closed domain states, variants, and machine-readable
  categories.
- Do not use `default` or wildcard cases when switching over an enum. List
  every variant so new values produce compile-time failures at all affected
  call sites.
- Put behavior determined solely by an enum value on the enum as a getter or
  method instead of duplicating switch helpers across consumers.
- Represent every `SmfError` category with `SmfErrorCode`; never pass or
  compare an arbitrary string error code. Preserve the enum value as the
  stable uppercase machine-readable code printed by the CLI.
- Keep exactly one enum per file. Name the file after the enum using Dart's
  `snake_case` convention; for example, `ReleasePlatform` belongs in
  `release_platform.dart`. Store enum files in a dedicated `enums/` directory
  within their owning package or feature; never place enums in `models/`,
  `dtos/`, or general implementation directories. Do not group enums in
  `*_enums.dart` files or colocate an enum with another declaration.

### Files and declarations

- Give every hand-authored Dart class, enum, mixin, and extension its own file
  named after that declaration using `snake_case`; for example,
  `ReleaseChangelog` belongs in `release_changelog.dart`. Keep the declaration
  and filename aligned when either is renamed.
- Keep exactly one class, enum, mixin, or extension per hand-authored source
  file. Split related interfaces, implementations, and value types into their
  own matching files instead of colocating them.
- Keep required Dart entrypoints such as `main` at top level. Existing
  deliberate public functional APIs may remain top level; new domain logic
  should normally be owned by a class, enum, or extension.
- Extract a typedef only when the same signature is used in more than one
  place. Put reusable public callback and function types in an owner-named
  `*_types.dart` file.
- Keep all extensions on the same type together in one discoverable extension
  file instead of creating one extension per feature.
- When a subject grows into several hand-authored companion files, group them
  in a directory named for that subject. Follow the surrounding package
  structure for generated DTO companions.

### Constants and control flow

- Inline a single-use value when its meaning is obvious from the call site.
- Name operands in non-obvious calculations so the expression communicates
  intent.
- Define a shared logical value once on the class or enum that owns it. Do not
  duplicate independent constants across files or introduce ownerless
  top-level constants.
- Prefer early returns and guard clauses over nested `if`/`else` chains.
- Use exhaustive switches for genuine multi-way domain choices.

### Class member order

Keep class members in a predictable order:

1. constructor and constructor inputs, with public fields before private ones;
2. static public members;
3. static private members;
4. other instance fields;
5. public instance methods and getters;
6. private instance methods and getters;
7. overrides.

Keep closely related methods together within those groups. Do not make a helper
`static` merely because it can be; keep a sole-caller helper as an instance
method when it belongs to that instance's workflow.

### Dartdoc

- Every exported public class, member, typedef, and function needs
  consumer-focused Dartdoc explaining what it does, when to use it, and any
  guarantee or side effect callers must understand.
- Private declarations and symbols unreachable through a package's public
  exports do not need boilerplate Dartdoc. Clear names and focused code are
  their documentation.
- Confirm public reachability through the package entrypoint before deciding
  that a declaration is public API.

## SMF implementation contracts

- Put behavior in the package that owns it; do not expose implementation only
  to make tests convenient.
- Treat each package's top-level library file as an intentional public export
  boundary.
- Breaking public APIs, hook contracts, persisted schemas, CLI output, or error
  codes require explicit authorization, downstream-impact analysis, and a
  migration plan.
- Preserve the CLI output contract: successful machine output is exactly one
  JSON value on stdout; diagnostics and errors go to stderr.
- Use stable `SmfError` codes for actionable domain failures.
- Keep network transport separate from planning and validation.
- Reject unknown configuration fields, invalid combinations, secrets in
  persisted state, and path or symlink escapes.
- Release candidate promotion must validate and reuse the recorded artifact. Never
  rebuild during promotion.
- Release mutations must require the expected clean repository state and must
  restore the caller's branch after temporary branch work.

When configuration changes, update all affected representations together:

- parsing and validation;
- the JSON schema;
- generated templates;
- tests;
- consumer documentation.

Freezed and json_serializable outputs are committed. Change the authored model
or DTO, run generation, and review the generated diff. Never edit
`*.freezed.dart` or `*.g.dart` directly.

## Testing conventions

- Every behavior change needs observable test coverage. Every bug fix needs a
  regression test that fails without the fix.
- When the cause is understood, write and run the failing regression test
  before changing production code. If discovery must come first, add the
  regression test as soon as the behavior is understood.
- Give each source owner a dedicated test file with a corresponding path. Add
  coverage for an existing source file to its existing test file rather than a
  catch-all suite.
- Each new test case should contain exactly one `expect` or assertion call.
  Split distinct outcomes into separately named cases.
- Name tests `when <condition or action>, it should <observable result>`.
  Descriptions must explain domain behavior without relying on private field or
  implementation-state names.
- When a fixture field is under test, override that field explicitly instead
  of relying on the fixture's default.
- Pin the clock and set timestamps explicitly in tests involving elapsed time,
  release dates, or other `DateTime.now()`-dependent behavior.
- Run focused tests from the owning package directory. Some suites rely on that
  package-relative working directory.
- Use disposable repositories and synthetic signing assets.
- Mock GitHub, Apple, and Google Play APIs. Normal tests must not contact live
  services or production accounts.
- Cover cleanup and failure paths for filesystem, credential, signing, process,
  Git, and remote-operation changes.

Run the complete repository gate before handing off a change:

```bash
dart pub get
dart run melos run gen --no-select
dart run melos run format:check
dart run melos run docs:check
dart run melos run analyze
dart run melos run test --no-select
dart run melos run publish:dry-run --no-select
git diff --check
```

After dependency-constraint changes, also verify the minimum and current
resolutions:

```bash
dart pub downgrade
dart run melos run analyze
dart run melos run test --no-select
dart pub upgrade
```

If a gate cannot run because it needs credentials, platform tooling, or a live
service, report that boundary explicitly. Do not present local or mocked
coverage as live acceptance.

## Documentation

- `doc/` is the consumer manual. Keep contributor workflow, internal package
  architecture, publication procedure, and implementation roadmaps out of it.
- Put architecture and internal state-machine details in `ARCHITECTURE.md`.
- Put contributor setup and validation in `CONTRIBUTING.md`.
- Put publication and tagging procedure in `RELEASING.md`.
- Keep the root `README.md` as the user-facing entry point.
- Update `README.md`, `CONTRIBUTING.md`, and this file when tooling or setup
  changes alter contributor onboarding.
- Give every documented contract, instruction set, option list, credential
  table, and behavior exactly one canonical source of truth. Other documents
  must link to that source instead of copying or independently restating it.
- Run the Markdown link checker after changing documentation.

## Security and releases

- Never commit or log real store credentials, keys, certificates, profiles,
  keystores, passwords, tokens, API identifiers, or service-account JSON.
- Avoid logging full remote URLs when credentials may appear in query strings.
  Log the minimum structured, non-secret detail needed for diagnosis.
- Pass secrets through typed values or environment variables, not generated
  shell source. Remove store and GitHub credentials before invoking
  repository-owned hooks or build commands.
- Restrict temporary credential-file permissions and clean up only assets SMF
  created, using `finally` where appropriate.
- Use Conventional Commits.
- Do not commit, push, merge, tag, publish, upload artifacts, submit store
  changes, change production metadata, or create releases unless the user
  explicitly authorizes that action.
- Never create, reuse, or move release tags manually; follow `RELEASING.md`.
