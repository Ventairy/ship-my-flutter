// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changelog_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangelogDto {

@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformsDto get platforms;@JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson) int get schemaVersion;
/// Create a copy of ChangelogDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogDtoCopyWith<ChangelogDto> get copyWith => _$ChangelogDtoCopyWithImpl<ChangelogDto>(this as ChangelogDto, _$identity);

  /// Serializes this ChangelogDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogDto&&(identical(other.platforms, platforms) || other.platforms == platforms)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platforms,schemaVersion);

@override
String toString() {
  return 'ChangelogDto(platforms: $platforms, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ChangelogDtoCopyWith<$Res>  {
  factory $ChangelogDtoCopyWith(ChangelogDto value, $Res Function(ChangelogDto) _then) = _$ChangelogDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformsDto platforms,@JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson) int schemaVersion
});


$ChangelogPlatformsDtoCopyWith<$Res> get platforms;

}
/// @nodoc
class _$ChangelogDtoCopyWithImpl<$Res>
    implements $ChangelogDtoCopyWith<$Res> {
  _$ChangelogDtoCopyWithImpl(this._self, this._then);

  final ChangelogDto _self;
  final $Res Function(ChangelogDto) _then;

/// Create a copy of ChangelogDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platforms = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as ChangelogPlatformsDto,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ChangelogDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangelogPlatformsDtoCopyWith<$Res> get platforms {
  
  return $ChangelogPlatformsDtoCopyWith<$Res>(_self.platforms, (value) {
    return _then(_self.copyWith(platforms: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChangelogDto].
extension ChangelogDtoPatterns on ChangelogDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogDto value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformsDto platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson)  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformsDto platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson)  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ChangelogDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformsDto platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson)  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogDto() when $default != null:
return $default(_that.platforms,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ChangelogDto extends ChangelogDto {
  const _ChangelogDto({@JsonKey(required: true, disallowNullValue: true) required this.platforms, @JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson) required this.schemaVersion}): super._();
  factory _ChangelogDto.fromJson(Map<String, dynamic> json) => _$ChangelogDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  ChangelogPlatformsDto platforms;
@override@JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson) final  int schemaVersion;

/// Create a copy of ChangelogDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogDtoCopyWith<_ChangelogDto> get copyWith => __$ChangelogDtoCopyWithImpl<_ChangelogDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogDto&&(identical(other.platforms, platforms) || other.platforms == platforms)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platforms,schemaVersion);

@override
String toString() {
  return 'ChangelogDto(platforms: $platforms, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ChangelogDtoCopyWith<$Res> implements $ChangelogDtoCopyWith<$Res> {
  factory _$ChangelogDtoCopyWith(_ChangelogDto value, $Res Function(_ChangelogDto) _then) = __$ChangelogDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformsDto platforms,@JsonKey(required: true, disallowNullValue: true, fromJson: ChangelogDto._schemaVersionFromJson) int schemaVersion
});


@override $ChangelogPlatformsDtoCopyWith<$Res> get platforms;

}
/// @nodoc
class __$ChangelogDtoCopyWithImpl<$Res>
    implements _$ChangelogDtoCopyWith<$Res> {
  __$ChangelogDtoCopyWithImpl(this._self, this._then);

  final _ChangelogDto _self;
  final $Res Function(_ChangelogDto) _then;

/// Create a copy of ChangelogDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platforms = null,Object? schemaVersion = null,}) {
  return _then(_ChangelogDto(
platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as ChangelogPlatformsDto,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ChangelogDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangelogPlatformsDtoCopyWith<$Res> get platforms {
  
  return $ChangelogPlatformsDtoCopyWith<$Res>(_self.platforms, (value) {
    return _then(_self.copyWith(platforms: value));
  });
}
}

// dart format on
