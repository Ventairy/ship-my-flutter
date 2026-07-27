import 'release_enums.dart';

/// Store release notes keyed by platform, version, and locale.
typedef StoreReleaseNotes = Map<Platform, Map<String, Map<String, String>>>;
