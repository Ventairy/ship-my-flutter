import 'package:smf_engine/src/enums/release_platform.dart';

/// Validated localized store notes keyed by platform, version, and locale.
final class StoreReleaseNotes {
  /// Creates an immutable store-release-note collection.
  StoreReleaseNotes({
    required Map<ReleasePlatform, Map<String, Map<String, String>>> values,
  }) : _values = Map<ReleasePlatform, Map<String, Map<String, String>>>.unmodifiable(
         values.map(
           (platform, versions) => MapEntry(
             platform,
             Map<String, Map<String, String>>.unmodifiable(
               versions.map(
                 (version, localizations) => MapEntry(
                   version,
                   Map<String, String>.unmodifiable(localizations),
                 ),
               ),
             ),
           ),
         ),
       );

  /// Creates an empty collection.
  const StoreReleaseNotes.empty() : _values = const <ReleasePlatform, Map<String, Map<String, String>>>{};

  final Map<ReleasePlatform, Map<String, Map<String, String>>> _values;

  /// Whether no platform has localized release notes.
  bool get isEmpty => _values.isEmpty;

  /// Returns localized notes for one exact platform release.
  Map<String, String> forRelease({
    required ReleasePlatform platform,
    required String version,
  }) {
    return _values[platform]?[version] ?? const <String, String>{};
  }

  /// Encodes the persisted store-release-note contract.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      for (final platform in ReleasePlatform.values)
        if (_values[platform] case final versions?)
          platform.value: <String, Object?>{
            for (final entry in versions.entries) entry.key: entry.value,
          },
    };
  }
}
