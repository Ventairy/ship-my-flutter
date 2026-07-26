import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/release_enums.dart';
import 'changelog_release.dart';

part 'changelog_manifest.freezed.dart';

/// Versioned changelog state for every release platform.
@freezed
abstract class ChangelogManifest with _$ChangelogManifest {
  /// Creates changelog state.
  const factory ChangelogManifest({
    @Default(1) int schemaVersion,
    required Map<String, ChangelogRelease> iosReleases,
  }) = _ChangelogManifest;

  const ChangelogManifest._();

  /// Returns changelog releases for [platform].
  Map<String, ChangelogRelease> releasesFor(Platform platform) =>
      switch (platform) {
        Platform.ios => iosReleases,
      };

  /// Encodes the stable changelog wire format.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platforms': <String, Object?>{
      'ios': <String, Object?>{
        'releases': iosReleases.map(
          (String key, ChangelogRelease value) =>
              MapEntry<String, Object?>(key, value.toJson()),
        ),
      },
    },
  };
}
