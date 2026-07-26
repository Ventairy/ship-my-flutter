# Releasing ship-my-flutter

Publishing is intentionally separate from normal development.

## Core package

1. Run `npm ci && npm run check && npm pack --dry-run`.
2. Test the packed tarball in a clean consumer fixture.
3. Update the version and changelog through a release PR.
4. Configure npm trusted publishing for `Ventairy/ship-my-flutter`.
5. Tag the immutable commit and publish with provenance.
6. Verify the hosted package by installing it in a second clean consumer.

## GitHub Action

1. Run the core check and rebuild the vendored snapshot.
2. In `ship-my-flutter-action`, run `npm ci && npm run check`.
3. Verify `git diff --exit-code -- dist vendor` after the build.
4. Test `plan`, `candidate`, and `promote` against a disposable Flutter/App Store Connect fixture.
5. Create an immutable release tag such as `v1.0.0`.
6. Move the floating major tag `v1` only after the immutable release succeeds.
7. Confirm a clean external repository can use `Ventairy/ship-my-flutter-action@v1`.

Do not tag, publish, or move `v1` from an unvalidated working tree.
