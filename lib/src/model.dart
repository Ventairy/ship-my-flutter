enum Platform {
  ios;

  String get value => name;

  static Platform parse(String value) => switch (value) {
    'ios' => Platform.ios,
    _ => throw FormatException('Unsupported platform "$value".'),
  };
}

enum Bump {
  patch,
  minor,
  major;

  String get value => name;

  static Bump? maybeParse(Object? value) => switch (value) {
    null => null,
    'patch' => Bump.patch,
    'minor' => Bump.minor,
    'major' => Bump.major,
    _ => throw FormatException('Unsupported version bump "$value".'),
  };
}

enum ReleaseMode {
  submitForReview('submit-for-review'),
  uploadOnly('upload-only');

  const ReleaseMode(this.value);
  final String value;
}

enum StoreReleaseType {
  manual('manual'),
  automatic('automatic'),
  scheduled('scheduled');

  const StoreReleaseType(this.value);
  final String value;
}

final class TestflightConfig {
  const TestflightConfig({
    this.groups = const <String>[],
    this.waitTimeoutMinutes = 45,
  });

  final List<String> groups;
  final int waitTimeoutMinutes;
}

final class AppStoreConfig {
  const AppStoreConfig({
    this.mode = ReleaseMode.uploadOnly,
    this.releaseType = StoreReleaseType.manual,
    this.earliestReleaseDate,
  });

  final ReleaseMode mode;
  final StoreReleaseType releaseType;
  final DateTime? earliestReleaseDate;
}

final class IosConfig {
  const IosConfig({
    this.enabled = true,
    this.projectPath = '.',
    this.bundleId,
    this.scheme,
    this.buildArgs = const <String>[],
    this.testflight = const TestflightConfig(),
    this.appStore = const AppStoreConfig(),
  });

  final bool enabled;
  final String projectPath;
  final String? bundleId;
  final String? scheme;
  final List<String> buildArgs;
  final TestflightConfig testflight;
  final AppStoreConfig appStore;
}

final class HooksConfig {
  const HooksConfig({this.beforeReleasePr});

  final String? beforeReleasePr;
}

final class ShipConfig {
  const ShipConfig({
    this.schemaVersion = 1,
    this.targetBranch = 'main',
    this.releaseBranchPrefix = 'ship-my-flutter',
    this.hooks = const HooksConfig(),
    required this.ios,
  });

  final int schemaVersion;
  final String targetBranch;
  final String releaseBranchPrefix;
  final HooksConfig hooks;
  final IosConfig ios;
}

final class PlatformManifest {
  const PlatformManifest({
    required this.version,
    required this.baselineSha,
    required this.pendingRelease,
  });

  final String version;
  final String baselineSha;
  final bool pendingRelease;

  Map<String, Object?> toJson() => <String, Object?>{
    'version': version,
    'baselineSha': baselineSha,
    'pendingRelease': pendingRelease,
  };
}

final class ShipManifest {
  const ShipManifest({this.schemaVersion = 1, required this.ios});

  final int schemaVersion;
  final PlatformManifest ios;

  PlatformManifest forPlatform(Platform platform) => switch (platform) {
    Platform.ios => ios,
  };

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platforms': <String, Object?>{'ios': ios.toJson()},
  };
}

final class ConventionalChange {
  const ConventionalChange({
    required this.sha,
    required this.type,
    required this.scope,
    required this.description,
    required this.body,
    required this.breaking,
    required this.bump,
    required this.platforms,
    this.releaseAs,
  });

  final String sha;
  final String type;
  final String? scope;
  final String description;
  final String? body;
  final bool breaking;
  final Bump? bump;
  final List<Platform> platforms;
  final String? releaseAs;

  Map<String, Object?> toJson() => <String, Object?>{
    'sha': sha,
    'type': type,
    'scope': scope,
    'description': description,
    'body': body,
    'breaking': breaking,
    'bump': bump?.value,
    'platforms': platforms.map((Platform value) => value.value).toList(),
    if (releaseAs != null) 'releaseAs': releaseAs,
  };
}

final class ChangelogRelease {
  const ChangelogRelease({
    required this.version,
    required this.preparedAt,
    required this.baseSha,
    required this.headSha,
    required this.changes,
  });

  final String version;
  final DateTime preparedAt;
  final String baseSha;
  final String headSha;
  final List<ConventionalChange> changes;

  Map<String, Object?> toJson() => <String, Object?>{
    'version': version,
    'preparedAt': preparedAt.toUtc().toIso8601String(),
    'baseSha': baseSha,
    'headSha': headSha,
    'changes': changes
        .map((ConventionalChange change) => change.toJson())
        .toList(),
  };
}

final class ChangelogManifest {
  const ChangelogManifest({this.schemaVersion = 1, required this.iosReleases});

  final int schemaVersion;
  final Map<String, ChangelogRelease> iosReleases;

  Map<String, ChangelogRelease> releasesFor(Platform platform) =>
      switch (platform) {
        Platform.ios => iosReleases,
      };

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platforms': <String, Object?>{
      'ios': <String, Object?>{
        'releases': iosReleases.map(
          (String key, ChangelogRelease value) =>
              MapEntry<String, Object?>(key, value.toJson()),
        ),
      },
    },
  };
}

typedef StoreReleaseNotes = Map<Platform, Map<String, Map<String, String>>>;

final class ReleasePlan {
  const ReleasePlan({
    required this.platform,
    required this.currentVersion,
    required this.nextVersion,
    required this.bump,
    required this.baseSha,
    required this.headSha,
    required this.changes,
  });

  final Platform platform;
  final String currentVersion;
  final String nextVersion;
  final Bump bump;
  final String baseSha;
  final String headSha;
  final List<ConventionalChange> changes;

  Map<String, Object?> toJson() => <String, Object?>{
    'platform': platform.value,
    'currentVersion': currentVersion,
    'nextVersion': nextVersion,
    'bump': bump.value,
    'baseSha': baseSha,
    'headSha': headSha,
    'changes': changes
        .map((ConventionalChange change) => change.toJson())
        .toList(),
  };
}

final class CandidateReceipt {
  const CandidateReceipt({
    this.schemaVersion = 1,
    this.platform = Platform.ios,
    required this.version,
    required this.buildNumber,
    required this.buildId,
    required this.appId,
    required this.bundleId,
    required this.sourceSha,
    required this.sourceFingerprint,
    required this.ipaSha256,
    required this.uploadedAt,
    required this.testflightGroups,
  });

  final int schemaVersion;
  final Platform platform;
  final String version;
  final String buildNumber;
  final String buildId;
  final String appId;
  final String bundleId;
  final String sourceSha;
  final String sourceFingerprint;
  final String ipaSha256;
  final DateTime uploadedAt;
  final List<String> testflightGroups;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platform': platform.value,
    'version': version,
    'buildNumber': buildNumber,
    'buildId': buildId,
    'appId': appId,
    'bundleId': bundleId,
    'sourceSha': sourceSha,
    'sourceFingerprint': sourceFingerprint,
    'ipaSha256': ipaSha256,
    'uploadedAt': uploadedAt.toUtc().toIso8601String(),
    'processingState': 'VALID',
    'testflightGroups': testflightGroups,
  };
}

final class GitHubContext {
  const GitHubContext({
    required this.owner,
    required this.repo,
    required this.token,
  });

  final String owner;
  final String repo;
  final String token;
}

final class AppleCredentials {
  const AppleCredentials({
    required this.keyId,
    required this.issuerId,
    required this.privateKey,
  });

  final String keyId;
  final String issuerId;
  final String privateKey;
}

final class SigningCredentials {
  const SigningCredentials({
    required this.certificateBase64,
    required this.certificatePassword,
    required this.provisioningProfiles,
  });

  final String certificateBase64;
  final String certificatePassword;
  final String provisioningProfiles;
}

final class CommandResult {
  const CommandResult({
    required this.phase,
    this.platform,
    this.version,
    this.branch,
    this.pullRequestNumber,
  });

  final String phase;
  final Platform? platform;
  final String? version;
  final String? branch;
  final int? pullRequestNumber;

  Map<String, Object?> toJson() => <String, Object?>{
    'phase': phase,
    if (platform != null) 'platform': platform?.value,
    if (version != null) 'version': version,
    if (branch != null) 'branch': branch,
    if (pullRequestNumber != null) 'pullRequestNumber': pullRequestNumber,
  };
}
