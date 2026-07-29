import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/enums/release_platform.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/json_file.dart';

part 'release_candidate_receipt_dto.freezed.dart';
part 'release_candidate_receipt_dto.g.dart';

/// Evidence identifying an exact tested store artifact and source tree.
@freezed
abstract class ReleaseCandidateReceiptDto with _$ReleaseCandidateReceiptDto {
  /// Creates release candidate evidence.
  @JsonSerializable(
    checked: true,
    dateTimeUtc: true,
    disallowUnrecognizedKeys: true,
  )
  const factory ReleaseCandidateReceiptDto({
    required ReleasePlatform platform,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._versionFromJson,
    )
    required String version,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson,
    )
    required String buildNumber,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson,
    )
    required String artifactId,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson,
    )
    required String applicationId,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson,
    )
    required String storeApplicationId,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson,
    )
    required String sourceCommitHash,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson,
    )
    required String sourceFingerprint,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson,
    )
    required String artifactSha256,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson,
    )
    required DateTime uploadedAt,

    @JsonKey(
      fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson,
    )
    required List<String> testingDestinations,

    @JsonKey(
      required: true,
      disallowNullValue: true,
      fromJson: ReleaseCandidateReceiptDto._processingStateFromJson,
    )
    required String processingState,

    @JsonKey(
      required: true,
      disallowNullValue: true,
      fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson,
    )
    required int schemaVersion,
  }) = _ReleaseCandidateReceiptDto;

  const ReleaseCandidateReceiptDto._();

  /// Decodes and validates release candidate evidence from persisted JSON.
  factory ReleaseCandidateReceiptDto.fromJson(
    Map<String, Object?> json, {
    String source = 'release candidate receipt',
  }) => (() {
    try {
      return _$ReleaseCandidateReceiptDtoFromJson(json);
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
        SmfErrorCode.invalidReleaseCandidateReceipt,
        cause: error,
      );
    } on Object catch (error) {
      throw SmfError(
        '$source is invalid:\n$error',
        SmfErrorCode.invalidReleaseCandidateReceipt,
        cause: error,
      );
    }
  })();

  /// Reads and validates release candidate evidence from [filePath].
  static Future<ReleaseCandidateReceiptDto> fromJsonFilePath(
    String filePath,
  ) async {
    return ReleaseCandidateReceiptDto.fromJson(
      await JsonFile(filePath).read(),
      source: filePath,
    );
  }

  static String _versionFromJson(String json) {
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(json)) {
      throw const SmfError(
        'version must be major.minor.patch',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _buildNumberFromJson(String json) {
    if (!RegExp(r'^\d+$').hasMatch(json)) {
      throw const SmfError(
        'buildNumber must contain only digits',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _artifactIdFromJson(String json) {
    if (!RegExp(r'\S').hasMatch(json)) {
      throw const SmfError(
        'artifactId must not be empty',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _applicationIdFromJson(String json) {
    if (!RegExp(r'\S').hasMatch(json)) {
      throw const SmfError(
        'applicationId must not be empty',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _storeApplicationIdFromJson(String json) {
    if (!RegExp(r'\S').hasMatch(json)) {
      throw const SmfError(
        'storeApplicationId must not be empty',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _sourceCommitHashFromJson(String json) {
    if (!RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(json)) {
      throw const SmfError(
        'sourceCommitHash must be a complete Git commit hash',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _sourceFingerprintFromJson(String json) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(json)) {
      throw const SmfError(
        'sourceFingerprint must be a SHA-256 digest',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static String _artifactSha256FromJson(String json) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(json)) {
      throw const SmfError(
        'artifactSha256 must be a SHA-256 digest',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return json;
  }

  static DateTime _uploadedAtFromJson(String json) {
    try {
      final value = DateTime.parse(json);
      if (value.isUtc) return value;
    } on FormatException {
      // The domain error below is more actionable than DateTime.parse output.
    }
    throw const SmfError(
      'uploadedAt must be an ISO-8601 UTC timestamp',
      SmfErrorCode.invalidReleaseCandidateReceipt,
    );
  }

  static List<String> _testingDestinationsFromJson(List<Object?> json) {
    final testingDestinations = <String>[];
    for (final destination in json) {
      if (destination is! String || !RegExp(r'\S').hasMatch(destination)) {
        throw const SmfError(
          'testingDestinations must contain only non-empty strings',
          SmfErrorCode.invalidReleaseCandidateReceipt,
        );
      }
      testingDestinations.add(destination);
    }
    if (testingDestinations.toSet().length != testingDestinations.length) {
      throw const SmfError(
        'testingDestinations must not contain duplicates',
        SmfErrorCode.invalidReleaseCandidateReceipt,
      );
    }
    return testingDestinations;
  }

  static String _processingStateFromJson(String json) {
    if (json == 'VALID') return json;
    throw const SmfError(
      'processingState must be VALID',
      SmfErrorCode.invalidReleaseCandidateReceipt,
    );
  }

  static int _schemaVersionFromJson(Object? json) {
    if (json == 1) return 1;
    throw const SmfError(
      'schemaVersion must be 1',
      SmfErrorCode.invalidReleaseCandidateReceipt,
    );
  }
}
