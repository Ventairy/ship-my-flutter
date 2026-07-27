import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/release_enums.dart';

part 'candidate_receipt.freezed.dart';

/// Evidence identifying an exact tested App Store build and source tree.
@freezed
abstract class CandidateReceipt with _$CandidateReceipt {
  /// Creates candidate evidence.
  const factory CandidateReceipt({
    @Default(1) int schemaVersion,
    @Default(Platform.ios) Platform platform,
    required String version,
    required String buildNumber,
    required String buildId,
    required String appId,
    required String bundleId,
    required String sourceSha,
    required String sourceFingerprint,
    required String ipaSha256,
    required DateTime uploadedAt,
    required List<String> testflightGroups,
  }) = _CandidateReceipt;

  const CandidateReceipt._();

  /// Encodes the immutable candidate receipt contract.
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
