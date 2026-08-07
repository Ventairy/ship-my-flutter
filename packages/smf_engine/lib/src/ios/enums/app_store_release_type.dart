import 'package:json_annotation/json_annotation.dart';

/// Release policy configured for an App Store version.
@JsonEnum(valueField: 'value')
enum AppStoreReleaseType {
  /// The developer manually releases the version after approval.
  manual('MANUAL'),

  /// Apple releases the version automatically after approval.
  afterApproval('AFTER_APPROVAL'),

  /// Apple releases the version at a configured date.
  scheduled('SCHEDULED');

  const AppStoreReleaseType(this.value);

  /// Stable App Store Connect API value.
  final String value;
}
