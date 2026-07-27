# Changelog

All notable changes to ship-my-flutter are documented here.

The project follows Semantic Versioning and Conventional Commits.

## Unreleased

### Changed

- Refactored immutable release state and Apple/GitHub response models with
  Freezed and json_serializable while preserving public constructors and wire
  formats.
- Defined the initial `config.yaml` schema with Flutter-style snake_case keys.
- Made IPA creation project-owned through `build_command` and
  `ipa_output_path`;
  ship-my-flutter now appends immutable version, build number, signing export
  options, and flavor arguments.
- Made `build_command` and `ipa_output_path` optional in generated
  configuration. The build command now detects repository FVM configuration
  automatically, while the output defaults to Flutter's standard IPA
  directory.
- Replaced the App Store delivery policy with three explicit modes: `upload`,
  `review`, and `auto`. Review mode waits for manual release after approval,
  while auto mode releases automatically after approval.
- Made `app_path` global so iOS and future Android delivery share the same
  Flutter application root.
- Added one optional global `flavor` shared by every platform build.
- Reduced initialization to the required configuration and GitHub workflow.
  Release manifests, changelogs, and candidate receipts are now generated only
  when needed, while absent store notes no longer create an empty file.

### Added

- Structured `before_create_pr` and `before_build` lifecycle hooks with
  default-on commits for generated release notes, code, environment inputs,
  and other hook output.

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
