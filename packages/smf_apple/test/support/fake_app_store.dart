import 'package:smf_apple/smf_apple.dart';
import 'package:smf_engine/smf_engine.dart';

final class FakeAppStoreConnectApi implements AppStoreConnectApi {
  FakeAppStoreConnectApi({
    this.app = const ApiResource<AppAttributes>(
      type: 'apps',
      id: 'app-1',
      attributes: AppAttributes(
        name: 'Example',
        bundleId: 'dev.example.app',
        sku: 'example',
        primaryLocale: 'en-US',
      ),
    ),
    this.builds = const <ApiResource<BuildAttributes>>[],
    this.directBuild,
    this.appStoreVersion,
    this.signingCertificates = const <AppleSigningCertificate>[],
    this.bundleIds = const <AppleBundleIdentifier>[],
    List<AppleProvisioningProfile> profiles = const <AppleProvisioningProfile>[],
    this.createdProfile,
    this.profileCreationError,
    this.profileCreatedBeforeError,
  }) : profiles = List<AppleProvisioningProfile>.of(profiles);

  final ApiResource<AppAttributes> app;
  final List<ApiResource<BuildAttributes>> builds;
  final ApiResource<BuildAttributes>? directBuild;
  final ApiResource<AppStoreVersionAttributes>? appStoreVersion;
  final List<AppleSigningCertificate> signingCertificates;
  final List<AppleBundleIdentifier> bundleIds;
  final List<AppleProvisioningProfile> profiles;
  final AppleProvisioningProfile? createdProfile;
  final SmfError? profileCreationError;
  final AppleProvisioningProfile? profileCreatedBeforeError;
  final List<({String name, String bundleIdId, String certificateId})> createdProfiles =
      <({String name, String bundleIdId, String certificateId})>[];
  final List<({String buildId, String locale, String whatsNew})> betaNotes =
      <({String buildId, String locale, String whatsNew})>[];
  final List<({String buildId, List<String> groups})> groupAssignments = <({String buildId, List<String> groups})>[];
  final List<({String versionId, String locale, String whatsNew})> storeNotes =
      <({String versionId, String locale, String whatsNew})>[];
  String? attachedBuildId;
  bool? releaseAutomatically;
  bool submitted = false;
  bool betaSubmitted = false;
  bool closed = false;

  @override
  Future<void> addBuildToGroups({
    required String appId,
    required String buildId,
    required List<String> names,
    required bool internal,
  }) async {
    groupAssignments.add((buildId: buildId, groups: List<String>.of(names)));
  }

  @override
  Future<String> submitBuildForBetaReview(String buildId) async {
    betaSubmitted = true;
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
    closed = true;
  }

  @override
  Future<List<ApiResource<BuildAttributes>>> buildsForVersion({
    required String appId,
    required String version,
  }) async => builds;

  @override
  Future<ApiResource<AppStoreVersionAttributes>> findOrCreateAppStoreVersion({
    required String appId,
    required String version,
    required bool releaseAutomatically,
  }) async {
    this.releaseAutomatically = releaseAutomatically;
    final value = appStoreVersion;
    if (value == null) throw StateError('No fake App Store version');
    return value;
  }

  @override
  Future<ApiResource<AppAttributes>> findApp(String bundleId) async => app;

  @override
  Future<List<AppleSigningCertificate>> listSigningCertificates() async => signingCertificates;

  @override
  Future<List<AppleBundleIdentifier>> listIosBundleIds() async => bundleIds;

  @override
  Future<List<AppleProvisioningProfile>> listAppStoreProfiles() async => profiles;

  @override
  Future<AppleProvisioningProfile> createAppStoreProfile({
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
    submitted = true;
    return 'submission-1';
  }

  @override
  Future<ApiResource<BuildAttributes>> waitForBuild({
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
