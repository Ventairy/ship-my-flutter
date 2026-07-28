import 'package:freezed_annotation/freezed_annotation.dart';

part 'signing_assets.freezed.dart';

/// A signing certificate registered with the Apple developer team.
@freezed
abstract class AppleSigningCertificate with _$AppleSigningCertificate {
  /// Creates an Apple signing-certificate resource.
  const factory AppleSigningCertificate({
    required String id,
    required String certificateType,
    required String displayName,
    required String serialNumber,
    required String certificateContent,
    required DateTime expirationDate,
    required bool activated,
  }) = _AppleSigningCertificate;
}

/// An App ID registered with the Apple developer team.
@freezed
abstract class AppleBundleIdentifier with _$AppleBundleIdentifier {
  /// Creates an Apple bundle-identifier resource.
  const factory AppleBundleIdentifier({
    required String id,
    required String identifier,
    required String platform,
  }) = _AppleBundleIdentifier;
}

/// An App Store Connect provisioning profile and its signing relationships.
@freezed
abstract class AppleProvisioningProfile with _$AppleProvisioningProfile {
  /// Creates an Apple provisioning-profile resource.
  const factory AppleProvisioningProfile({
    required String id,
    required String name,
    required String profileType,
    required String profileState,
    required String profileContent,
    required String uuid,
    required DateTime createdDate,
    required DateTime expirationDate,
    required String bundleIdId,
    required List<String> certificateIds,
  }) = _AppleProvisioningProfile;
}
