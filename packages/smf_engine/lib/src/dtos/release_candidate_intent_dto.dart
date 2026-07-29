import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/enums/release_platform.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/json_file.dart';

part 'release_candidate_intent_dto.freezed.dart';
part 'release_candidate_intent_dto.g.dart';

/// Durable evidence written before SMF uploads a release candidate to a store.
///
/// The intent lets a fresh runner recover the exact build after an upload or
/// receipt-push failure without selecting an unrelated store artifact.
@freezed
abstract class ReleaseCandidateIntentDto with _$ReleaseCandidateIntentDto {
  /// Creates a release candidate upload intent.
  @JsonSerializable(
    checked: true,
    dateTimeUtc: true,
    disallowUnrecognizedKeys: true,
  )
  const factory ReleaseCandidateIntentDto({
    required ReleasePlatform platform,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._versionFromJson,
    )
    required String version,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._buildNumberFromJson,
    )
    required String buildNumber,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._applicationIdFromJson,
    )
    required String applicationId,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson,
    )
    required String storeApplicationId,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson,
    )
    required String sourceCommitHash,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson,
    )
    required String sourceFingerprint,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson,
    )
    required String artifactSha256,

    @JsonKey(
      fromJson: ReleaseCandidateIntentDto._preparedAtFromJson,
    )
    required DateTime preparedAt,

    @JsonKey(
      required: true,
      disallowNullValue: true,
      fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson,
    )
    required int schemaVersion,
  }) = _ReleaseCandidateIntentDto;

  const ReleaseCandidateIntentDto._();

  /// Decodes and validates a persisted release candidate intent.
  factory ReleaseCandidateIntentDto.fromJson(
    Map<String, Object?> json, {
    String source = 'release candidate intent',
  }) => (() {
    try {
      return _$ReleaseCandidateIntentDtoFromJson(json);
    } on CheckedFromJsonException catch (error) {
      final innerError = error.innerError;

      if (innerError is SmfError) {
        throw SmfError(
          '$source is invalid:\n${innerError.message}',
          innerError.code,
          cause: error,
        );
      }

      throw SmfError(
        '$source is invalid:\n$error',
        SmfErrorCode.invalidReleaseCandidateIntent,
        cause: error,
      );
    } on Object catch (error) {
      throw SmfError(
        '$source is invalid:\n$error',
        SmfErrorCode.invalidReleaseCandidateIntent,
        cause: error,
      );
    }
  })();

  /// Reads and validates release candidate intent JSON from [filePath].
  static Future<ReleaseCandidateIntentDto> fromJsonFile(
    String filePath,
  ) async {
    return ReleaseCandidateIntentDto.fromJson(
      await JsonFile(filePath).read(),
      source: filePath,
    );
  }

  static String _versionFromJson(String json) {
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(json)) {
      throw const SmfError(
        'version must be major.minor.patch',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static String _buildNumberFromJson(String json) {
    if (!RegExp(r'^\d+$').hasMatch(json)) {
      throw const SmfError(
        'buildNumber must contain only digits',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static String _applicationIdFromJson(String json) {
    if (!RegExp(r'\S').hasMatch(json)) {
      throw const SmfError(
        'applicationId must not be empty',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static String _storeApplicationIdFromJson(String json) {
    if (!RegExp(r'\S').hasMatch(json)) {
      throw const SmfError(
        'storeApplicationId must not be empty',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static String _sourceCommitHashFromJson(String json) {
    if (!RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(json)) {
      throw const SmfError(
        'sourceCommitHash must be a complete Git commit hash',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static String _sourceFingerprintFromJson(String json) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(json)) {
      throw const SmfError(
        'sourceFingerprint must be a SHA-256 digest',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static String _artifactSha256FromJson(String json) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(json)) {
      throw const SmfError(
        'artifactSha256 must be a SHA-256 digest',
        SmfErrorCode.invalidReleaseCandidateIntent,
      );
    }
    return json;
  }

  static DateTime _preparedAtFromJson(String json) {
    try {
      final value = DateTime.parse(json);
      if (value.isUtc) return value;
    } on FormatException {
      // The domain error below is more actionable than DateTime.parse output.
    }
    throw const SmfError(
      'preparedAt must be an ISO-8601 UTC timestamp',
      SmfErrorCode.invalidReleaseCandidateIntent,
    );
  }

  static int _schemaVersionFromJson(Object? json) {
    if (json == 1) return 1;
    throw const SmfError(
      'schemaVersion must be 1',
      SmfErrorCode.invalidReleaseCandidateIntent,
    );
  }
}
