# Changelog

All notable changes to ship-my-flutter are documented here.

The project follows Semantic Versioning and Conventional Commits.

## Unreleased

### Changed

- Refactored immutable release state and Apple/GitHub response models with
  Freezed and json_serializable while preserving public constructors and wire
  formats.
- Migrated `config.yaml` to schema version 2 with Flutter-style snake_case keys.
- Made IPA creation project-owned through `build_command` and `artifact_path`;
  ship-my-flutter now appends immutable version, build number, signing export
  options, and flavor arguments.

### Added

- Shell-command `before_release_pr` and `before_candidate` lifecycle hooks for
  release-note generation, codegen, environment preparation, and custom
  workflows.

## [1.0.0](https://github.com/Ventairy/ship-my-flutter/compare/v0.1.0...v1.0.0) (2026-07-26)


### ⚠ BREAKING CHANGES

* config.yaml now requires schema_version 2 and snake_case keys; buildArgs is replaced by build_command and artifact_path.

### Features

* make app builds project-owned ([920de25](https://github.com/Ventairy/ship-my-flutter/commit/920de25adc4f6241d7147ae9d7964d7a0bde1b44))


### Bug Fixes

* automate core releases ([f717ea9](https://github.com/Ventairy/ship-my-flutter/commit/f717ea971f9b657f24410f08cfd82fbae33eeae5))
* prepare core Apple release workflow ([9456fcb](https://github.com/Ventairy/ship-my-flutter/commit/9456fcbc655f05db8a14b5afd04aeb330d2f7f30))

## 0.1.0 - 2026-07-26

### Added

- Dart package, public library API, JSON-emitting CLI, package-qualified
  executable aliases, and file/environment credential providers.
- Platform-scoped iOS release planning and release PR orchestration.
- TestFlight candidate signing, upload, localization, group assignment, and receipts.
- Exact-candidate App Store promotion and platform-prefixed GitHub Releases.
