# Changelog

All notable changes to ship-my-flutter are documented here.

The project follows Semantic Versioning and Conventional Commits.

## Unreleased

### Changed

- Refactored immutable release state and Apple/GitHub response models with
  Freezed and json_serializable while preserving public constructors and wire
  formats.

## 0.1.0 - 2026-07-26

### Added

- Dart package, public library API, JSON-emitting CLI, package-qualified
  executable aliases, and file/environment credential providers.
- Platform-scoped iOS release planning and release PR orchestration.
- TestFlight candidate signing, upload, localization, group assignment, and receipts.
- Exact-candidate App Store promotion and platform-prefixed GitHub Releases.
