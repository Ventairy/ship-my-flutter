# Contributing

Contributions are welcome through focused issues and pull requests.

## Development

Requirements:

- Node.js 20, 22, or 24
- npm
- Git
- macOS with Xcode only for real iOS signing/build integration

```bash
npm ci
npm run check
```

`npm run check` verifies formatting, lint, types, unit tests, and the distributable build.

Use Conventional Commits. A change limited to an app delivery platform should use its platform scope, for example `fix(ios): handle expired profiles`.

## Apple integration changes

Unit tests must use synthetic credentials and mocked endpoints. Never add real `.p8`, `.p12`, `.mobileprovision`, App Store Connect IDs, or repository tokens.

Changes to App Store Connect requests should cite the current Apple endpoint contract in the pull request. Changes to signing should describe cleanup behavior and be tested on a disposable app/team before release.

## Pull requests

- Keep unrelated changes separate.
- Add or update tests for behavioral changes.
- Update schemas and documentation with configuration changes.
- Run `npm run check`.
- Explain any part that could not be validated against a live Apple account.
