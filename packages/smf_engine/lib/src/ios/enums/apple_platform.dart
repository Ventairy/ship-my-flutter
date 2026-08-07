import 'package:json_annotation/json_annotation.dart';

/// Apple platform returned for prerelease and App Store versions.
enum ApplePlatform {
  /// iPhone and iPad apps.
  @JsonValue('IOS')
  ios,

  /// macOS apps.
  @JsonValue('MAC_OS')
  macOs,

  /// Apple TV apps.
  @JsonValue('TV_OS')
  tvOs,

  /// Apple Vision apps.
  @JsonValue('VISION_OS')
  visionOs,
}
