// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppAttributes _$AppAttributesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AppAttributes', json, ($checkedConvert) {
      final val = _AppAttributes(
        name: $checkedConvert('name', (v) => v as String),
        bundleId: $checkedConvert('bundleId', (v) => v as String),
        sku: $checkedConvert('sku', (v) => v as String),
        primaryLocale: $checkedConvert('primaryLocale', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AppAttributesToJson(_AppAttributes instance) =>
    <String, dynamic>{
      'name': instance.name,
      'bundleId': instance.bundleId,
      'sku': instance.sku,
      'primaryLocale': instance.primaryLocale,
    };
