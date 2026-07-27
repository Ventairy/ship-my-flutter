import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/changelog_release.dart';
import 'package:smf_engine/src/models/release_enums.dart';

part 'changelog_manifest.freezed.dart';

/// Versioned changelog state for every release platform.
@freezed
abstract class ChangelogManifest with _$ChangelogManifest {
  /// Creates changelog state.
  const factory ChangelogManifest({
    required Map<String, ChangelogRelease> iosReleases,
    @Default(<String, ChangelogRelease>{})
    Map<String, ChangelogRelease> androidReleases,
    @Default(1) int schemaVersion,
  }) = _ChangelogManifest;

  const ChangelogManifest._();

  /// Returns changelog releases for [platform].
  Map<String, ChangelogRelease> releasesFor(Platform platform) =>
      switch (platform) {
        Platform.ios => iosReleases,
        Platform.android => androidReleases,
      };

  /// Encodes the stable changelog wire format.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platforms': <String, Object?>{
      'ios': <String, Object?>{
        'releases': iosReleases.map(
          (key, value) => MapEntry<String, Object?>(key, value.toJson()),
        ),
      },
      'android': <String, Object?>{
        'releases': androidReleases.map(
          (key, value) => MapEntry<String, Object?>(key, value.toJson()),
        ),
      },
    },
  };
}
