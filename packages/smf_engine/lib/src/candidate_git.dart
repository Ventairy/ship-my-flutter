import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/models/github_context.dart';
import 'package:smf_engine/src/models/release_enums.dart';

Future<void> _pushCurrentBranch(String root, GitHubContext? github) async {
  final branch = await currentBranch(root);
  invariant(
    branch.isNotEmpty,
    'Candidate checkout must be on a branch.',
    'DETACHED_HEAD',
  );
  if (github == null) {
    await git(root, <String>['push', 'origin', branch]);
  } else {
    await authenticatedGit(root, <String>[
      'push',
      'origin',
      branch,
    ], github.token);
  }
}

/// Commits and pushes one platform candidate receipt.
Future<void> commitCandidateReceipt(
  String root,
  String receiptPath,
  Platform platform,
  String version,
  GitHubContext? github,
) async {
  await configureBotIdentity(root);
  await git(root, <String>['add', receiptPath]);
  final staged = await git(root, const <String>[
    'diff',
    '--cached',
    '--name-only',
  ]);
  if (staged.isEmpty) return;
  await git(root, <String>[
    'commit',
    '-m',
    'chore(${platform.value}): record store candidate $version',
  ]);
  await _pushCurrentBranch(root, github);
}

/// Commits and pushes deterministic changes made by a before-build hook.
Future<void> commitBeforeBuildChanges(
  String root,
  Platform platform,
  String version,
  String startingSha,
  GitHubContext? github,
) async {
  await configureBotIdentity(root);
  await git(root, const <String>['add', '.']);
  final staged = await git(root, const <String>[
    'diff',
    '--cached',
    '--name-only',
  ]);
  if (staged.isNotEmpty) {
    await git(root, <String>[
      'commit',
      '-m',
      'chore(${platform.value}): apply before_build hook for $version',
    ]);
  }
  if (await currentSha(root) == startingSha) return;
  await _pushCurrentBranch(root, github);
}
