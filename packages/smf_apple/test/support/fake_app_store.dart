import 'package:smf_apple/smf_apple.dart';

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
  });

  final ApiResource<AppAttributes> app;
  final List<ApiResource<BuildAttributes>> builds;
  final ApiResource<BuildAttributes>? directBuild;
  final ApiResource<AppStoreVersionAttributes>? appStoreVersion;
  final List<({String buildId, String locale, String whatsNew})> betaNotes =
      <({String buildId, String locale, String whatsNew})>[];
  final List<({String buildId, List<String> groups})> groupAssignments =
      <({String buildId, List<String> groups})>[];
  final List<({String versionId, String locale, String whatsNew})> storeNotes =
      <({String versionId, String locale, String whatsNew})>[];
  String? attachedBuildId;
  bool? releaseAutomatically;
  var submitted = false;

  @override
  Future<void> addBuildToGroups(
    String appId,
    String buildId,
    List<String> names,
  ) async {
    groupAssignments.add((buildId: buildId, groups: List<String>.of(names)));
  }

  @override
  Future<String?> appStoreVersionBuildId(String appStoreVersionId) async =>
      attachedBuildId;

  @override
  Future<void> attachBuildToVersion(
    String appStoreVersionId,
    String buildId,
  ) async {
    attachedBuildId = buildId;
  }

  @override
  Future<List<ApiResource<BuildAttributes>>> buildsForVersion(
    String appId,
    String version,
  ) async => builds;

  @override
  Future<ApiResource<AppStoreVersionAttributes>> findOrCreateAppStoreVersion(
    String appId,
    String version, {
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
  Future<ApiResource<BuildAttributes>> getBuild(String buildId) async {
    final value = directBuild;
    if (value == null) throw StateError('No fake direct build');
    return value;
  }

  @override
  Future<String> nextBuildNumber(String appId, String version) async => '1';

  @override
  Future<void> setAppStoreReleaseNotes(
    String appStoreVersionId,
    String locale,
    String whatsNew,
  ) async {
    storeNotes.add((
      versionId: appStoreVersionId,
      locale: locale,
      whatsNew: whatsNew,
    ));
  }

  @override
  Future<void> setBetaBuildLocalization(
    String buildId,
    String locale,
    String whatsNew,
  ) async {
    betaNotes.add((buildId: buildId, locale: locale, whatsNew: whatsNew));
  }

  @override
  Future<String> submitVersionForReview(
    String appId,
    String appStoreVersionId,
  ) async {
    submitted = true;
    return 'submission-1';
  }

  @override
  Future<ApiResource<BuildAttributes>> waitForBuild(
    String appId,
    String version,
    String buildNumber,
    int timeoutMinutes, {
    Duration interval = const Duration(seconds: 30),
  }) async {
    final value = directBuild;
    if (value == null) throw StateError('No fake build');
    return value;
  }
}
