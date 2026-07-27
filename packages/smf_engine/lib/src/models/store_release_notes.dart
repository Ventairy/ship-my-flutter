import 'package:smf_engine/src/models/release_enums.dart';

/// Store release notes keyed by platform, version, and locale.
typedef StoreReleaseNotes = Map<Platform, Map<String, Map<String, String>>>;
