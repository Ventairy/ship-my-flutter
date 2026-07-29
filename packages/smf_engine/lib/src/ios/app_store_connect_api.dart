import 'package:smf_engine/src/ios/dtos/api_resource_dto.dart';
import 'package:smf_engine/src/ios/dtos/app_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/app_store_version_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/build_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/signing_assets_dtos.dart';

/// App Store Connect operations required by SMF delivery workflows.
abstract interface class AppStoreConnectApi {
  /// Finds the app whose bundle identifier exactly matches [bundleId].
  Future<ApiResourceDto<AppAttributesDto>> findApp(String bundleId);

  /// Lists signing certificates registered with the developer team.
  Future<List<AppleSigningCertificateDto>> listSigningCertificates();

  /// Lists iOS bundle identifiers registered with the developer team.
  Future<List<AppleBundleIdentifierDto>> listIosBundleIds();

  /// Lists App Store provisioning profiles registered with the developer team.
  Future<List<AppleProvisioningProfileDto>> listAppStoreProfiles();

  /// Creates an App Store profile for one bundle identifier and certificate.
  Future<AppleProvisioningProfileDto> createAppStoreProfile({
    required String name,
    required String bundleIdId,
    required String certificateId,
  });

  /// Lists builds uploaded for one app marketing version.
  Future<List<ApiResourceDto<BuildAttributesDto>>> buildsForVersion({
    required String appId,
    required String version,
  });

  /// Returns the next unused build number for one app marketing version.
  Future<String> nextBuildNumber({
    required String appId,
    required String version,
  });

  /// Waits for an exact uploaded build to finish App Store processing.
  Future<ApiResourceDto<BuildAttributesDto>> waitForBuild({
    required String appId,
    required String version,
    required String buildNumber,
    required int timeoutMinutes,
    Duration interval = const Duration(seconds: 30),
  });

  /// Creates or updates localized TestFlight "What to Test" text.
  Future<void> setBetaBuildLocalization({
    required String buildId,
    required String locale,
    required String whatsNew,
  });

  /// Adds an exact build to the named internal or external TestFlight groups.
  Future<void> addBuildToGroups({
    required String appId,
    required String buildId,
    required List<String> names,
    required bool isInternal,
  });

  /// Submits an exact build for TestFlight beta review.
  Future<String> submitBuildForBetaReview(String buildId);

  /// Finds or creates the editable App Store version for a marketing version.
  Future<ApiResourceDto<AppStoreVersionAttributesDto>> findOrCreateAppStoreVersion({
    required String appId,
    required String version,
    required bool shouldReleaseAutomatically,
  });

  /// Attaches an exact build to an App Store version.
  Future<void> attachBuildToVersion({
    required String appStoreVersionId,
    required String buildId,
  });

  /// Returns the build currently attached to an App Store version.
  Future<String?> appStoreVersionBuildId(String appStoreVersionId);

  /// Creates or updates localized App Store "What's New" text.
  Future<void> setAppStoreReleaseNotes({
    required String appStoreVersionId,
    required String locale,
    required String whatsNew,
  });

  /// Creates or reuses the review submission for an App Store version.
  Future<String> submitVersionForReview({
    required String appId,
    required String appStoreVersionId,
  });

  /// Releases authentication and transport resources.
  void close();
}
