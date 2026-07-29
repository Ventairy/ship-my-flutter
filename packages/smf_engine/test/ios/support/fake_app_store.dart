import 'package:smf_engine/apple.dart';
import 'package:smf_engine/smf_engine.dart';

final class FakeAppStoreConnectApi implements AppStoreConnectApi {
  FakeAppStoreConnectApi({
    this.app = const ApiResourceDto<AppAttributesDto>(
      type: 'apps',
      id: 'app-1',
      attributes: AppAttributesDto(
        name: 'Example',
        bundleId: 'dev.example.app',
        sku: 'example',
        primaryLocale: 'en-US',
      ),
    ),
    this.builds = const <ApiResourceDto<BuildAttributesDto>>[],
    this.directBuild,
    this.appStoreVersion,
    this.signingCertificates = const <AppleSigningCertificateDto>[],
    this.bundleIds = const <AppleBundleIdentifierDto>[],
    List<AppleProvisioningProfileDto> profiles = const <AppleProvisioningProfileDto>[],
    this.createdProfile,
    this.profileCreationError,
    this.profileCreatedBeforeError,
  }) : profiles = List<AppleProvisioningProfileDto>.of(profiles);

  final ApiResourceDto<AppAttributesDto> app;
  final List<ApiResourceDto<BuildAttributesDto>> builds;
  final ApiResourceDto<BuildAttributesDto>? directBuild;
  final ApiResourceDto<AppStoreVersionAttributesDto>? appStoreVersion;
  final List<AppleSigningCertificateDto> signingCertificates;
  final List<AppleBundleIdentifierDto> bundleIds;
  final List<AppleProvisioningProfileDto> profiles;
  final AppleProvisioningProfileDto? createdProfile;
  final SmfError? profileCreationError;
  final AppleProvisioningProfileDto? profileCreatedBeforeError;
  final List<({String name, String bundleIdId, String certificateId})> createdProfiles =
      <({String name, String bundleIdId, String certificateId})>[];
  final List<({String buildId, String locale, String whatsNew})> betaNotes =
      <({String buildId, String locale, String whatsNew})>[];
  final List<({String buildId, List<String> groups})> groupAssignments = <({String buildId, List<String> groups})>[];
  final List<({String versionId, String locale, String whatsNew})> storeNotes =
      <({String versionId, String locale, String whatsNew})>[];
  String? attachedBuildId;
  bool? shouldReleaseAutomatically;
  bool isSubmitted = false;
  bool isBetaSubmitted = false;
  bool isClosed = false;

  @override
  Future<void> addBuildToGroups({
    required String appId,
    required String buildId,
    required List<String> names,
    required bool isInternal,
  }) async {
    groupAssignments.add((buildId: buildId, groups: List<String>.of(names)));
  }

  @override
  Future<String> submitBuildForBetaReview(String buildId) async {
    isBetaSubmitted = true;
    return 'beta-submission-1';
  }

  @override
  Future<String?> appStoreVersionBuildId(String appStoreVersionId) async => attachedBuildId;

  @override
  Future<void> attachBuildToVersion({
    required String appStoreVersionId,
    required String buildId,
  }) async {
    attachedBuildId = buildId;
  }

  @override
  void close() {
    isClosed = true;
  }

  @override
  Future<List<ApiResourceDto<BuildAttributesDto>>> buildsForVersion({
    required String appId,
    required String version,
  }) async => builds;

  @override
  Future<ApiResourceDto<AppStoreVersionAttributesDto>> findOrCreateAppStoreVersion({
    required String appId,
    required String version,
    required bool shouldReleaseAutomatically,
  }) async {
    this.shouldReleaseAutomatically = shouldReleaseAutomatically;
    final value = appStoreVersion;
    if (value == null) throw StateError('No fake App Store version');
    return value;
  }

  @override
  Future<ApiResourceDto<AppAttributesDto>> findApp(String bundleId) async => app;

  @override
  Future<List<AppleSigningCertificateDto>> listSigningCertificates() async => signingCertificates;

  @override
  Future<List<AppleBundleIdentifierDto>> listIosBundleIds() async => bundleIds;

  @override
  Future<List<AppleProvisioningProfileDto>> listAppStoreProfiles() async => profiles;

  @override
  Future<AppleProvisioningProfileDto> createAppStoreProfile({
    required String name,
    required String bundleIdId,
    required String certificateId,
  }) async {
    createdProfiles.add((
      name: name,
      bundleIdId: bundleIdId,
      certificateId: certificateId,
    ));
    final creationError = profileCreationError;
    if (creationError != null) {
      final racedProfile = profileCreatedBeforeError;
      if (racedProfile != null) profiles.add(racedProfile);
      throw creationError;
    }
    final value = createdProfile;
    if (value == null) throw StateError('No fake profile creation result');
    return value;
  }

  @override
  Future<String> nextBuildNumber({
    required String appId,
    required String version,
  }) async => '1';

  @override
  Future<void> setAppStoreReleaseNotes({
    required String appStoreVersionId,
    required String locale,
    required String whatsNew,
  }) async {
    storeNotes.add((
      versionId: appStoreVersionId,
      locale: locale,
      whatsNew: whatsNew,
    ));
  }

  @override
  Future<void> setBetaBuildLocalization({
    required String buildId,
    required String locale,
    required String whatsNew,
  }) async {
    betaNotes.add((buildId: buildId, locale: locale, whatsNew: whatsNew));
  }

  @override
  Future<String> submitVersionForReview({
    required String appId,
    required String appStoreVersionId,
  }) async {
    isSubmitted = true;
    return 'submission-1';
  }

  @override
  Future<ApiResourceDto<BuildAttributesDto>> waitForBuild({
    required String appId,
    required String version,
    required String buildNumber,
    required int timeoutMinutes,
    Duration interval = const Duration(seconds: 30),
  }) async {
    final value = directBuild;
    if (value == null) throw StateError('No fake build');
    return value;
  }
}
