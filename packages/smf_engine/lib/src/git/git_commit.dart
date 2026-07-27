import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_commit.freezed.dart';

/// A Git commit used for release planning.
@freezed
abstract class GitCommit with _$GitCommit {
  /// Creates a Git commit.
  const factory GitCommit({required String sha, required String message}) =
      _GitCommit;
}
