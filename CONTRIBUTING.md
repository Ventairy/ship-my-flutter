# Contributing to SMF

Thank you for helping improve SMF. Contributions are welcome as focused issues
and pull requests.

For usage questions and confirmed bugs, open a
[GitHub issue](https://github.com/Ventairy/smf/issues/new). Discuss substantial
features, breaking changes, and new dependencies in an issue before investing
in an implementation. Report vulnerabilities privately by following
[SECURITY.md](SECURITY.md).

## Set up the workspace

Install Git and a Dart SDK that satisfies the constraint in `pubspec.yaml`.
Platform tooling is needed only when a change must exercise a real Apple or
Android build.

Clone your fork, enter the repository, and resolve the workspace:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/smf.git
cd smf
dart pub get
```

Create a branch for one focused change:

```bash
git switch -c fix/short-description
```

## Find the right package

SMF is a Dart workspace with clear package ownership:

| Location                               | Contribute here when changing                   |
| -------------------------------------- | ----------------------------------------------- |
| `packages/smf_hooks`                   | The typed repository hook SDK                   |
| `packages/smf_engine/lib/src`          | Shared planning, state, and Git/GitHub behavior |
| `packages/smf_engine/lib/src/ios`    | Apple signing or App Store Connect delivery     |
| `packages/smf_engine/lib/src/android`  | Android signing or Google Play delivery         |
| `packages/smf_cli`                     | Commands, arguments, and terminal output        |

Read [ARCHITECTURE.md](ARCHITECTURE.md) before changing package boundaries or
release behavior. Follow [AGENTS.md](AGENTS.md) for coding, testing, security,
and repository-operation conventions.

## Make the change

- Keep the pull request limited to one problem.
- Add or update tests for behavior changes. A bug fix needs a regression test.
- Run focused tests from the package that owns them:

  ```bash
  cd packages/smf_engine
  dart test test/config_test.dart
  cd ../..
  ```

- Change annotated models or DTOs at their authored source, then regenerate
  committed `*.freezed.dart` and `*.g.dart` files. Never edit generated files
  directly.
- Update parsing, validation, schema, templates, tests, and consumer
  documentation together when configuration behavior changes.
- Keep user documentation in `README.md` and `doc/`; keep contributor,
  architecture, and release material in the corresponding root documents.
- Never include real credentials, signing assets, store identifiers, tokens, or
  service-account files.

Normal tests use mocks, disposable repositories, and synthetic signing assets.
They must not contact production Apple, Google Play, or GitHub resources.

## Validate the change

Run the complete gate from the repository root before opening a pull request:

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

Review generated and formatted changes before including them. Do not commit
unrelated output.

When changing dependency constraints, also verify the minimum supported
resolution:

```bash
dart pub downgrade
dart run melos run analyze
dart run melos run test --no-select
dart pub upgrade
```

If a credentialed or platform-specific check is relevant but unavailable,
state exactly what remains unverified. Mocked coverage is not live store
acceptance.

## Commit the change

Use a [Conventional Commit](https://www.conventionalcommits.org/) message:

```text
<type>[optional scope][optional !]: <description>
```

Examples:

```text
fix(android): reject an unsigned app bundle
feat(cli): add release candidate inspection
docs: clarify hook recovery
```

Use `!` and explain the migration in the commit body or a `BREAKING CHANGE:`
footer when the change intentionally breaks a public contract.

## Open the pull request

Complete the pull request template and include:

- the problem and user-visible result;
- the issue it resolves, when applicable;
- tests added or updated;
- documentation or schema changes;
- the commands you ran;
- any platform or live-service validation that remains unverified.

Before submitting, review the complete diff for unrelated files, generated
noise, credentials, and accidental public API changes. CI must pass before the
pull request is ready to merge.

Preparing a contribution does not authorize tagging, publishing, uploading
artifacts, or changing a live store. Maintainers perform releases according to
[RELEASING.md](RELEASING.md).
