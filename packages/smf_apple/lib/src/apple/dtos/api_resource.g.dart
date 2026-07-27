// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResource<T> _$ApiResourceFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('_ApiResource', json, ($checkedConvert) {
  final val = _ApiResource<T>(
    type: $checkedConvert('type', (v) => v as String),
    id: $checkedConvert('id', (v) => v as String),
    attributes: $checkedConvert('attributes', (v) => fromJsonT(v)),
  );
  return val;
});

Map<String, dynamic> _$ApiResourceToJson<T>(
  _ApiResource<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'type': instance.type,
  'id': instance.id,
  'attributes': toJsonT(instance.attributes),
};
