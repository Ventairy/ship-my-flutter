import 'package:smf_engine/src/enums/release_platform.dart';

/// Stable Git references owned by one app's release lifecycle.
final class ReleaseReference {
  const ReleaseReference._();

  /// Branch containing [appId]'s pending platform releases.
  static String branch(String appId) => 'smf/$appId/release';

  /// Immutable tag identifying one released platform version.
  static String tag(String appId, ReleasePlatform platform, String version) => '$appId/${platform.value}-v$version';
}
