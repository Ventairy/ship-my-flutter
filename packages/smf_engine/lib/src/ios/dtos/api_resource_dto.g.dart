// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_resource_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResourceDto<T> _$ApiResourceDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('_ApiResourceDto', json, ($checkedConvert) {
  final val = _ApiResourceDto<T>(
    type: $checkedConvert('type', (v) => v as String),
    id: $checkedConvert('id', (v) => v as String),
    attributes: $checkedConvert('attributes', (v) => fromJsonT(v)),
  );
  return val;
});

Map<String, dynamic> _$ApiResourceDtoToJson<T>(
  _ApiResourceDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'type': instance.type,
  'id': instance.id,
  'attributes': toJsonT(instance.attributes),
};
