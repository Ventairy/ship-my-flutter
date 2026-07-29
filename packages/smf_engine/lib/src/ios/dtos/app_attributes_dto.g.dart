// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_attributes_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppAttributesDto _$AppAttributesDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AppAttributesDto', json, ($checkedConvert) {
      final val = _AppAttributesDto(
        name: $checkedConvert('name', (v) => v as String),
        bundleId: $checkedConvert('bundleId', (v) => v as String),
        sku: $checkedConvert('sku', (v) => v as String),
        primaryLocale: $checkedConvert('primaryLocale', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AppAttributesDtoToJson(_AppAttributesDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'bundleId': instance.bundleId,
      'sku': instance.sku,
      'primaryLocale': instance.primaryLocale,
    };
