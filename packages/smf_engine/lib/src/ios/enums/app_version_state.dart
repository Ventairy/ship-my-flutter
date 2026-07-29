import 'package:json_annotation/json_annotation.dart';

/// Current lifecycle state of an App Store version.
enum AppVersionState {
  /// Apple accepted the version.
  @JsonValue('ACCEPTED')
  accepted,

  /// The developer removed the version from review.
  @JsonValue('DEVELOPER_REJECTED')
  developerRejected,

  /// App Review is actively reviewing the version.
  @JsonValue('IN_REVIEW')
  inReview,

  /// Apple rejected the uploaded binary.
  @JsonValue('INVALID_BINARY')
  invalidBinary,

  /// App Review rejected the version metadata.
  @JsonValue('METADATA_REJECTED')
  metadataRejected,

  /// Apple is waiting to publish an approved version.
  @JsonValue('PENDING_APPLE_RELEASE')
  pendingAppleRelease,

  /// The developer must manually release the approved version.
  @JsonValue('PENDING_DEVELOPER_RELEASE')
  pendingDeveloperRelease,

  /// The version can still be configured before submission.
  @JsonValue('PREPARE_FOR_SUBMISSION')
  prepareForSubmission,

  /// Apple is processing the approved version for distribution.
  @JsonValue('PROCESSING_FOR_DISTRIBUTION')
  processingForDistribution,

  /// The version is available for distribution.
  @JsonValue('READY_FOR_DISTRIBUTION')
  readyForDistribution,

  /// The version has all required submission items and can enter review.
  @JsonValue('READY_FOR_REVIEW')
  readyForReview,

  /// App Review rejected the version.
  @JsonValue('REJECTED')
  rejected,

  /// A newer App Store version replaced this version.
  @JsonValue('REPLACED_WITH_NEW_VERSION')
  replacedWithNewVersion,

  /// Apple requires export-compliance information.
  @JsonValue('WAITING_FOR_EXPORT_COMPLIANCE')
  waitingForExportCompliance,

  /// The isSubmitted version is waiting for App Review.
  @JsonValue('WAITING_FOR_REVIEW')
  waitingForReview;

  /// Whether metadata and build relationships can still be changed.
  bool get isEditable => switch (this) {
    AppVersionState.prepareForSubmission ||
    AppVersionState.readyForReview ||
    AppVersionState.waitingForExportCompliance => true,
    AppVersionState.accepted ||
    AppVersionState.developerRejected ||
    AppVersionState.inReview ||
    AppVersionState.invalidBinary ||
    AppVersionState.metadataRejected ||
    AppVersionState.pendingAppleRelease ||
    AppVersionState.pendingDeveloperRelease ||
    AppVersionState.processingForDistribution ||
    AppVersionState.readyForDistribution ||
    AppVersionState.rejected ||
    AppVersionState.replacedWithNewVersion ||
    AppVersionState.waitingForReview => false,
  };

  /// Whether this state requires a human correction before SMF can continue.
  bool get isRejected => switch (this) {
    AppVersionState.developerRejected ||
    AppVersionState.invalidBinary ||
    AppVersionState.metadataRejected ||
    AppVersionState.rejected ||
    AppVersionState.replacedWithNewVersion => true,
    AppVersionState.accepted ||
    AppVersionState.inReview ||
    AppVersionState.pendingAppleRelease ||
    AppVersionState.pendingDeveloperRelease ||
    AppVersionState.prepareForSubmission ||
    AppVersionState.processingForDistribution ||
    AppVersionState.readyForDistribution ||
    AppVersionState.readyForReview ||
    AppVersionState.waitingForExportCompliance ||
    AppVersionState.waitingForReview => false,
  };
}
