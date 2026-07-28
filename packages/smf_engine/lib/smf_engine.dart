/// Flutter release automation with platform-scoped release planning.
library;

export 'src/candidate_git.dart' show CandidateGit;
export 'src/changelog.dart' show ReleaseChangelog;
export 'src/config.dart' show SmfState;
export 'src/conventional_commit.dart' show ConventionalCommit;
export 'src/error.dart' show SmfError;
export 'src/fingerprint.dart' show FileDigest, SourceFingerprint;
export 'src/flutter_toolchain.dart' show FlutterToolchain;
export 'src/git.dart' show GitClient, GitCommit;
export 'src/github.dart' show ReleasePullRequest, ReleasePullRequestResult;
export 'src/github_api.dart' show GitHubApi, GitHubApiException, GitHubPullRequest, GitHubRelease, GitHubRestApi;
export 'src/hooks.dart' show RepositoryHooks;
export 'src/init.dart' show InitOptions, RepositoryInitializer;
export 'src/manifest_files.dart' show ReleaseRegistry;
export 'src/migration.dart' show MigrationOptions, MigrationResult, MigrationTarget, SmfMigration;
export 'src/model.dart';
export 'src/orchestrator.dart' show ReleaseOrchestrator;
export 'src/paths.dart' show SmfPaths;
export 'src/process_runner.dart' show ProcessRunner, RunOptions, RunResult, SystemProcessRunner;
export 'src/release_branch.dart' show ReleaseReference;
export 'src/release_plan.dart' show ReleasePlanner;
export 'src/serialization.dart' show SmfFileSystem;
export 'src/validate.dart' show RepositoryValidator;
