// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_store_version_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppStoreVersionAttributes _$AppStoreVersionAttributesFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AppStoreVersionAttributes', json, ($checkedConvert) {
  final val = _AppStoreVersionAttributes(
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$ApplePlatformEnumMap, v),
    ),
    versionString: $checkedConvert('versionString', (v) => v as String),
    appVersionState: $checkedConvert(
      'appVersionState',
      (v) => $enumDecode(_$AppVersionStateEnumMap, v),
    ),
    releaseType: $checkedConvert(
      'releaseType',
      (v) => $enumDecode(_$AppStoreReleaseTypeEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$AppStoreVersionAttributesToJson(
  _AppStoreVersionAttributes instance,
) => <String, dynamic>{
  'platform': _$ApplePlatformEnumMap[instance.platform]!,
  'versionString': instance.versionString,
  'appVersionState': _$AppVersionStateEnumMap[instance.appVersionState]!,
  'releaseType': _$AppStoreReleaseTypeEnumMap[instance.releaseType]!,
};

const _$ApplePlatformEnumMap = {
  ApplePlatform.ios: 'IOS',
  ApplePlatform.macOs: 'MAC_OS',
  ApplePlatform.tvOs: 'TV_OS',
  ApplePlatform.visionOs: 'VISION_OS',
};

const _$AppVersionStateEnumMap = {
  AppVersionState.accepted: 'ACCEPTED',
  AppVersionState.developerRejected: 'DEVELOPER_REJECTED',
  AppVersionState.inReview: 'IN_REVIEW',
  AppVersionState.invalidBinary: 'INVALID_BINARY',
  AppVersionState.metadataRejected: 'METADATA_REJECTED',
  AppVersionState.pendingAppleRelease: 'PENDING_APPLE_RELEASE',
  AppVersionState.pendingDeveloperRelease: 'PENDING_DEVELOPER_RELEASE',
  AppVersionState.prepareForSubmission: 'PREPARE_FOR_SUBMISSION',
  AppVersionState.processingForDistribution: 'PROCESSING_FOR_DISTRIBUTION',
  AppVersionState.readyForDistribution: 'READY_FOR_DISTRIBUTION',
  AppVersionState.readyForReview: 'READY_FOR_REVIEW',
  AppVersionState.rejected: 'REJECTED',
  AppVersionState.replacedWithNewVersion: 'REPLACED_WITH_NEW_VERSION',
  AppVersionState.waitingForExportCompliance: 'WAITING_FOR_EXPORT_COMPLIANCE',
  AppVersionState.waitingForReview: 'WAITING_FOR_REVIEW',
};

const _$AppStoreReleaseTypeEnumMap = {
  AppStoreReleaseType.manual: 'MANUAL',
  AppStoreReleaseType.afterApproval: 'AFTER_APPROVAL',
  AppStoreReleaseType.scheduled: 'SCHEDULED',
};
