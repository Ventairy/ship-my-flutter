import 'package:freezed_annotation/freezed_annotation.dart';

part 'signing_assets_dtos.freezed.dart';

/// A signing certificate registered with the Apple developer team.
@freezed
abstract class AppleSigningCertificateDto with _$AppleSigningCertificateDto {
  /// Creates an Apple signing-certificate resource.
  const factory AppleSigningCertificateDto({
    required String id,
    required String certificateType,
    required String displayName,
    required String serialNumber,
    required String certificateContent,
    required DateTime expirationDate,
    required bool isActivated,
  }) = _AppleSigningCertificateDto;
}

/// An App ID registered with the Apple developer team.
@freezed
abstract class AppleBundleIdentifierDto with _$AppleBundleIdentifierDto {
  /// Creates an Apple bundle-identifier resource.
  const factory AppleBundleIdentifierDto({
    required String id,
    required String identifier,
    required String platform,
  }) = _AppleBundleIdentifierDto;
}

/// An App Store Connect provisioning profile and its signing relationships.
@freezed
abstract class AppleProvisioningProfileDto with _$AppleProvisioningProfileDto {
  /// Creates an Apple provisioning-profile resource.
  const factory AppleProvisioningProfileDto({
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
  }) = _AppleProvisioningProfileDto;
}
