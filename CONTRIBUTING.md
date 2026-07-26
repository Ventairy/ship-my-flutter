# Contributing

Contributions are welcome through focused issues and pull requests.

## Development

Requirements:

- Dart 3.10 or newer
- Git
- macOS with Xcode only for real iOS signing/build integration

```bash
dart pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
```

The test suite uses local Git repositories, synthetic signing assets, and
mocked GitHub and Apple endpoints. It must not contact a production Apple
account.

Use Conventional Commits. A change limited to an app delivery platform should
use its platform scope, for example
`fix(ios): handle expired profiles`.

## Public API and CLI

The Dart library is the product. Keep release decisions, GitHub behavior,
signing, and store delivery in `lib/`; the companion Action is only an adapter
that invokes the CLI.

CLI success output is one JSON value on stdout. Human diagnostics and errors go
to stderr. Never add a command-line flag that accepts a raw secret—use a
documented environment variable or file path.

## Apple integration changes

Unit tests must use synthetic credentials and mocked endpoints. Never add real
`.p8`, `.p12`, `.mobileprovision`, App Store Connect IDs, or repository tokens.

Changes to App Store Connect requests should cite the current Apple endpoint
contract in the pull request. Changes to signing should describe cleanup
behavior and be tested on a disposable app/team before release.

## Pull requests

- Keep unrelated changes separate.
- Add or update tests for behavioral changes.
- Update schemas and documentation with configuration changes.
- Run every command in the development gate.
- Explain any part that could not be validated against a live Apple account.
