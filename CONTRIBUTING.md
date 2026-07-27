# Contributing

Contributions are welcome through focused issues and pull requests.

## Development

Requirements:

- Dart 3.10 or newer
- Git
- macOS with Xcode only for real iOS signing/build integration

The workspace includes `very_good_analysis` 10.1.0 exactly. That is the newest
stable preset compatible with the Dart 3.10 floor and keeps every CI SDK on the
same lint rules.

```bash
dart pub get
dart run melos run generate --no-select
git diff --exit-code -- packages
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run melos run test --no-select
dart run melos run publish:dry-run --no-select
git diff --check
```

Freezed and json_serializable outputs are committed package source. Run the
generator after changing an annotated model or DTO, review both the authored
and generated diffs, and never edit generated files directly.

The workspace lockfile is intentionally ignored. CI resolves the newest
compatible graph on Dart 3.10 and stable, then separately runs
`dart pub downgrade`, analysis, and every package test to verify lower
dependency bounds. The companion Action owns its committed deployment
lockfile.

The test suites use disposable Git repositories, synthetic signing assets, and
mocked GitHub and Apple endpoints. They must not contact a production Apple
account.

Use Conventional Commits. A change limited to one delivery platform should use
that platform scope, for example `fix(ios): handle expired profiles`.

## Package boundaries

- `smf_hooks` owns the stable, lightweight repository hook SDK.
- `smf_engine` owns platform-neutral planning, state, and GitHub orchestration.
- `smf_apple` owns signing, upload, TestFlight, and App Store operations.
- `smf_cli` owns terminal parsing and composes core with adapters.

Dependencies flow from `smf_cli` to core/adapters, from adapters to core, and
from core to hooks. Core must never import a platform adapter. Keep the
companion Action as a thin adapter over the private `smf action` command.

CLI success output is one JSON value on stdout. Human diagnostics and errors go
to stderr. Never add a raw-secret argument; use a documented environment
variable or file path.

## Apple integration changes

Never add real `.p8`, `.p12`, `.mobileprovision`, App Store Connect IDs, or
repository tokens. Changes to App Store Connect requests should cite the
current Apple contract in the pull request. Changes to signing should describe
cleanup behavior and be tested on a disposable app/team before release.

## Pull requests

- Keep unrelated changes separate.
- Add or update tests for behavioral changes.
- Update schemas and documentation with configuration changes.
- Run every command in the development gate.
- Explain anything that could not be validated against a live Apple account.
