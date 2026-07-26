# Releasing ship-my-flutter

Publishing is intentionally separate from normal development.

## Dart package

1. Run the complete development gate from `CONTRIBUTING.md`.
2. Test the package through a path dependency in a clean Flutter fixture.
3. Update the version and changelog through a release PR.
4. Configure pub.dev automated publishing for `Ventairy/ship-my-flutter`.
5. Tag the immutable commit and publish to pub.dev.
6. Verify both `dart pub add --dev ship_my_flutter` and
   `dart pub global activate ship_my_flutter` in separate clean consumers.

## GitHub Action

1. Run the core gate and `npm run vendor-core` in the adjacent Action checkout.
2. In `ship-my-flutter-action`, run `npm ci`, resolve the vendored Dart
   lockfile, and run `npm run check`.
3. Regenerate `dist`, then verify a second build produces no diff in
   `dist` or `vendor`.
4. Test `plan`, candidate dispatch, and merged-release dispatch against a
   disposable Flutter repository. Do not use production Apple credentials.
5. Complete the separately tracked live Apple acceptance gate.
6. Create an immutable release tag such as `v1.0.0`.
7. Move the floating major tag `v1` only after the immutable release succeeds.
8. Confirm a clean external repository can use
   `Ventairy/ship-my-flutter-action@v1`.

Do not tag, publish, or move `v1` from an unvalidated working tree.
