import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/models/release_enums.dart';

part 'candidate_receipt.freezed.dart';

/// Evidence identifying an exact tested store artifact and source tree.
@freezed
abstract class CandidateReceipt with _$CandidateReceipt {
  /// Creates candidate evidence.
  const factory CandidateReceipt({
    required Platform platform,
    required String version,
    required String buildNumber,
    required String artifactId,
    required String applicationId,
    required String storeApplicationId,
    required String sourceSha,
    required String sourceFingerprint,
    required String artifactSha256,
    required DateTime uploadedAt,
    required List<String> testingDestinations,
    @Default('VALID') String processingState,
    @Default(2) int schemaVersion,
  }) = _CandidateReceipt;

  const CandidateReceipt._();

  /// Encodes the immutable candidate receipt contract.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platform': platform.value,
    'version': version,
    'buildNumber': buildNumber,
    'artifactId': artifactId,
    'applicationId': applicationId,
    'storeApplicationId': storeApplicationId,
    'sourceSha': sourceSha,
    'sourceFingerprint': sourceFingerprint,
    'artifactSha256': artifactSha256,
    'uploadedAt': uploadedAt.toUtc().toIso8601String(),
    'processingState': processingState,
    'testingDestinations': testingDestinations,
  };
}
