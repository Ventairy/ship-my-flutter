# Changelog

All notable changes to smf are documented here.

The project follows Semantic Versioning and Conventional Commits.

## Unreleased

### Changed

- Refactored immutable release state and Apple/GitHub response models with
  Freezed and json_serializable while preserving public constructors and wire
  formats.
- Defined the initial `config.yaml` schema with Flutter-style snake_case keys.
- Made IPA creation project-owned through `build_command` and
  `ipa_output_path`;
  smf now appends immutable version, build number, signing export
  options, and flavor arguments.
- Made `build_command` and `ipa_output_path` optional in generated
  configuration. The build command now detects repository FVM configuration
  automatically, while the output defaults to Flutter's standard IPA
  directory.
- Replaced the App Store delivery policy with three explicit modes: `upload`,
  `review`, and `auto`. Review mode waits for manual release after approval,
  while auto mode releases automatically after approval.
- Established one Flutter application root shared by iOS and future Android
  delivery.
- Added one optional global `flavor` shared by every platform build.
- Reduced initialization to the required configuration and GitHub workflow.
  Release manifests, changelogs, and candidate receipts are now generated only
  when needed, while absent store notes no longer create an empty file.
- Made the `smf/<platform>` release branch convention internal and
  removed the unnecessary `release_branch_prefix` configuration field.
- Renamed the GitHub Action phases to `pull-request`, `release-candidate`, and
  `ship` so the workflow contract describes each outcome directly.

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

## [1.0.0](https://github.com/Ventairy/smf/compare/v0.1.0...v1.0.0) (2026-07-27)


### ⚠ BREAKING CHANGES

* replace unified CLI with package executables
* rename project to SMF
* make Flutter flavor global
* restructure app and hook configuration
* add explicit App Store delivery modes
* simplify App Store delivery modes
* config.yaml now requires schema_version 2 and snake_case keys; buildArgs is replaced by build_command and artifact_path.

### Features

* add explicit App Store delivery modes ([b2a7ed6](https://github.com/Ventairy/smf/commit/b2a7ed6e95baed44709bcb4bf9abcfb6fb456118))
* auto-detect FVM for iOS builds ([69b2b3d](https://github.com/Ventairy/smf/commit/69b2b3d57870e5e4c019598491247d4acf9a040e))
* default standard Flutter IPA builds ([db35d16](https://github.com/Ventairy/smf/commit/db35d160e9d6f53061e8193479a0083593f0d3b0))
* generate release state only when needed ([065eebe](https://github.com/Ventairy/smf/commit/065eebe9fa8ce92ac2b0adb18e0d1220acb658f8))
* make app builds project-owned ([920de25](https://github.com/Ventairy/smf/commit/920de25adc4f6241d7147ae9d7964d7a0bde1b44))
* make Flutter flavor global ([2b824bd](https://github.com/Ventairy/smf/commit/2b824bd315a73eaebf72ab444fde7de3c0bf4ced))
* rename project to SMF ([7fa60bf](https://github.com/Ventairy/smf/commit/7fa60bfff690b78a9e049e0c277ca8a12358e91b))
* restructure app and hook configuration ([8bb5ecd](https://github.com/Ventairy/smf/commit/8bb5ecd905b171c527a34c6936ecdaed33a8be64))
* simplify App Store delivery modes ([5129a98](https://github.com/Ventairy/smf/commit/5129a9830e3b478acbc32276d8158b886e4781af))


### Bug Fixes

* automate core releases ([f717ea9](https://github.com/Ventairy/smf/commit/f717ea971f9b657f24410f08cfd82fbae33eeae5))
* close quoted build command bypasses ([056194a](https://github.com/Ventairy/smf/commit/056194a92342b43b8aba8034fdb0c34264291341))
* gate releases on dedicated credentials ([70e9841](https://github.com/Ventairy/smf/commit/70e984167eaed361a4679bb84a0ae2bc037cd945))
* keep managed build arguments on one command ([2f02664](https://github.com/Ventairy/smf/commit/2f026644155c79e3646e7c0fc01ab8ece342d533))
* keep pre-release config schema at version 1 ([4135293](https://github.com/Ventairy/smf/commit/4135293993f69c93c59ef959eb38676d7ef7254e))
* make generated workflows app-aware ([cf826cb](https://github.com/Ventairy/smf/commit/cf826cb13267a4795b036b28c4168e4c56c34287))
* prepare core Apple release workflow ([9456fcb](https://github.com/Ventairy/smf/commit/9456fcbc655f05db8a14b5afd04aeb330d2f7f30))


### Code Refactoring

* replace unified CLI with package executables ([56b0fbe](https://github.com/Ventairy/smf/commit/56b0fbe74ab269a5fd9461bafa42ab91f4d46a26))

## 0.1.0 - 2026-07-26

### Added

- Dart package, public library API, JSON-emitting CLI, package-qualified
  executable aliases, and file/environment credential providers.
- Platform-scoped iOS release planning and release PR orchestration.
- TestFlight candidate signing, upload, localization, group assignment, and receipts.
- Exact-candidate App Store promotion and platform-prefixed GitHub Releases.
