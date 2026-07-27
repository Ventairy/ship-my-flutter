# Changelog

All notable changes to ship-my-flutter are documented here.

The project follows Semantic Versioning and Conventional Commits.

## Unreleased

### Changed

- Refactored immutable release state and Apple/GitHub response models with
  Freezed and json_serializable while preserving public constructors and wire
  formats.
- Migrated `config.yaml` to schema version 2 with Flutter-style snake_case keys.
- Made IPA creation project-owned through `build_command` and
  `ipa_output_path`;
  ship-my-flutter now appends immutable version, build number, signing export
  options, and flavor arguments.
- Made `build_command` and `ipa_output_path` optional in generated
  configuration. The build command now detects repository FVM configuration
  automatically, while the output defaults to Flutter's standard IPA
  directory.
- Simplified App Store delivery to `upload-only` or `submit-for-review`.
  Review submissions now always release automatically after Apple approval;
  configurable manual and scheduled release policies were removed.

### Added

- Shell-command `before_release_pr` and `before_candidate` lifecycle hooks for
  release-note generation, codegen, environment preparation, and custom
  workflows.

### Fixed

- Reject compound `build_command` values that could receive managed release
  arguments on the wrong shell command; hooks remain available for multi-step
  preparation.
- Aligned JSON Schema optional fields and defaults with runtime configuration
  parsing.

## 0.1.0 - 2026-07-26

### Added

- Dart package, public library API, JSON-emitting CLI, package-qualified
  executable aliases, and file/environment credential providers.
- Platform-scoped iOS release planning and release PR orchestration.
- TestFlight candidate signing, upload, localization, group assignment, and receipts.
- Exact-candidate App Store promotion and platform-prefixed GitHub Releases.
