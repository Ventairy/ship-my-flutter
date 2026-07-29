// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manifest_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManifestDto {

@JsonKey(required: true, disallowNullValue: true) ManifestPlatformsDto get platforms;@JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson) int get schemaVersion;
/// Create a copy of ManifestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManifestDtoCopyWith<ManifestDto> get copyWith => _$ManifestDtoCopyWithImpl<ManifestDto>(this as ManifestDto, _$identity);

  /// Serializes this ManifestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManifestDto&&(identical(other.platforms, platforms) || other.platforms == platforms)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platforms,schemaVersion);

@override
String toString() {
  return 'ManifestDto(platforms: $platforms, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ManifestDtoCopyWith<$Res>  {
  factory $ManifestDtoCopyWith(ManifestDto value, $Res Function(ManifestDto) _then) = _$ManifestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) ManifestPlatformsDto platforms,@JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson) int schemaVersion
});


$ManifestPlatformsDtoCopyWith<$Res> get platforms;

}
/// @nodoc
class _$ManifestDtoCopyWithImpl<$Res>
    implements $ManifestDtoCopyWith<$Res> {
  _$ManifestDtoCopyWithImpl(this._self, this._then);

  final ManifestDto _self;
  final $Res Function(ManifestDto) _then;

/// Create a copy of ManifestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platforms = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as ManifestPlatformsDto,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ManifestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManifestPlatformsDtoCopyWith<$Res> get platforms {
  
  return $ManifestPlatformsDtoCopyWith<$Res>(_self.platforms, (value) {
    return _then(_self.copyWith(platforms: value));
  });
}
}


/// Adds pattern-matching-related methods to [ManifestDto].
extension ManifestDtoPatterns on ManifestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManifestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManifestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManifestDto value)  $default,){
final _that = this;
switch (_that) {
case _ManifestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManifestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ManifestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  ManifestPlatformsDto platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson)  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManifestDto() when $default != null:
return $default(_that.platforms,_that.schemaVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  ManifestPlatformsDto platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson)  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ManifestDto():
return $default(_that.platforms,_that.schemaVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  ManifestPlatformsDto platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson)  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ManifestDto() when $default != null:
return $default(_that.platforms,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ManifestDto extends ManifestDto {
  const _ManifestDto({@JsonKey(required: true, disallowNullValue: true) required this.platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson) required this.schemaVersion}): super._();
  factory _ManifestDto.fromJson(Map<String, dynamic> json) => _$ManifestDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  ManifestPlatformsDto platforms;
@override@JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson) final  int schemaVersion;

/// Create a copy of ManifestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManifestDtoCopyWith<_ManifestDto> get copyWith => __$ManifestDtoCopyWithImpl<_ManifestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManifestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManifestDto&&(identical(other.platforms, platforms) || other.platforms == platforms)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platforms,schemaVersion);

@override
String toString() {
  return 'ManifestDto(platforms: $platforms, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ManifestDtoCopyWith<$Res> implements $ManifestDtoCopyWith<$Res> {
  factory _$ManifestDtoCopyWith(_ManifestDto value, $Res Function(_ManifestDto) _then) = __$ManifestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) ManifestPlatformsDto platforms,@JsonKey(required: true, disallowNullValue: true, fromJson: ManifestDto._schemaVersionFromJson) int schemaVersion
});


@override $ManifestPlatformsDtoCopyWith<$Res> get platforms;

}
/// @nodoc
class __$ManifestDtoCopyWithImpl<$Res>
    implements _$ManifestDtoCopyWith<$Res> {
  __$ManifestDtoCopyWithImpl(this._self, this._then);

  final _ManifestDto _self;
  final $Res Function(_ManifestDto) _then;

/// Create a copy of ManifestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platforms = null,Object? schemaVersion = null,}) {
  return _then(_ManifestDto(
platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as ManifestPlatformsDto,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ManifestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManifestPlatformsDtoCopyWith<$Res> get platforms {
  
  return $ManifestPlatformsDtoCopyWith<$Res>(_self.platforms, (value) {
    return _then(_self.copyWith(platforms: value));
  });
}
}

// dart format on
