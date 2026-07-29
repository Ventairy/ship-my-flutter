// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manifest_platforms_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManifestPlatformsDto {

@JsonKey(required: true, disallowNullValue: true) PlatformManifestDto get ios;@JsonKey(required: true, disallowNullValue: true) PlatformManifestDto get android;
/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManifestPlatformsDtoCopyWith<ManifestPlatformsDto> get copyWith => _$ManifestPlatformsDtoCopyWithImpl<ManifestPlatformsDto>(this as ManifestPlatformsDto, _$identity);

  /// Serializes this ManifestPlatformsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManifestPlatformsDto&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ios,android);

@override
String toString() {
  return 'ManifestPlatformsDto(ios: $ios, android: $android)';
}


}

/// @nodoc
abstract mixin class $ManifestPlatformsDtoCopyWith<$Res>  {
  factory $ManifestPlatformsDtoCopyWith(ManifestPlatformsDto value, $Res Function(ManifestPlatformsDto) _then) = _$ManifestPlatformsDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) PlatformManifestDto ios,@JsonKey(required: true, disallowNullValue: true) PlatformManifestDto android
});


$PlatformManifestDtoCopyWith<$Res> get ios;$PlatformManifestDtoCopyWith<$Res> get android;

}
/// @nodoc
class _$ManifestPlatformsDtoCopyWithImpl<$Res>
    implements $ManifestPlatformsDtoCopyWith<$Res> {
  _$ManifestPlatformsDtoCopyWithImpl(this._self, this._then);

  final ManifestPlatformsDto _self;
  final $Res Function(ManifestPlatformsDto) _then;

/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ios = null,Object? android = null,}) {
  return _then(_self.copyWith(
ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as PlatformManifestDto,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as PlatformManifestDto,
  ));
}
/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestDtoCopyWith<$Res> get ios {
  
  return $PlatformManifestDtoCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestDtoCopyWith<$Res> get android {
  
  return $PlatformManifestDtoCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}


/// Adds pattern-matching-related methods to [ManifestPlatformsDto].
extension ManifestPlatformsDtoPatterns on ManifestPlatformsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManifestPlatformsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManifestPlatformsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManifestPlatformsDto value)  $default,){
final _that = this;
switch (_that) {
case _ManifestPlatformsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManifestPlatformsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ManifestPlatformsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  PlatformManifestDto ios, @JsonKey(required: true, disallowNullValue: true)  PlatformManifestDto android)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManifestPlatformsDto() when $default != null:
return $default(_that.ios,_that.android);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  PlatformManifestDto ios, @JsonKey(required: true, disallowNullValue: true)  PlatformManifestDto android)  $default,) {final _that = this;
switch (_that) {
case _ManifestPlatformsDto():
return $default(_that.ios,_that.android);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  PlatformManifestDto ios, @JsonKey(required: true, disallowNullValue: true)  PlatformManifestDto android)?  $default,) {final _that = this;
switch (_that) {
case _ManifestPlatformsDto() when $default != null:
return $default(_that.ios,_that.android);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ManifestPlatformsDto extends ManifestPlatformsDto {
  const _ManifestPlatformsDto({@JsonKey(required: true, disallowNullValue: true) required this.ios, @JsonKey(required: true, disallowNullValue: true) required this.android}): super._();
  factory _ManifestPlatformsDto.fromJson(Map<String, dynamic> json) => _$ManifestPlatformsDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  PlatformManifestDto ios;
@override@JsonKey(required: true, disallowNullValue: true) final  PlatformManifestDto android;

/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManifestPlatformsDtoCopyWith<_ManifestPlatformsDto> get copyWith => __$ManifestPlatformsDtoCopyWithImpl<_ManifestPlatformsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManifestPlatformsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManifestPlatformsDto&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ios,android);

@override
String toString() {
  return 'ManifestPlatformsDto(ios: $ios, android: $android)';
}


}

/// @nodoc
abstract mixin class _$ManifestPlatformsDtoCopyWith<$Res> implements $ManifestPlatformsDtoCopyWith<$Res> {
  factory _$ManifestPlatformsDtoCopyWith(_ManifestPlatformsDto value, $Res Function(_ManifestPlatformsDto) _then) = __$ManifestPlatformsDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) PlatformManifestDto ios,@JsonKey(required: true, disallowNullValue: true) PlatformManifestDto android
});


@override $PlatformManifestDtoCopyWith<$Res> get ios;@override $PlatformManifestDtoCopyWith<$Res> get android;

}
/// @nodoc
class __$ManifestPlatformsDtoCopyWithImpl<$Res>
    implements _$ManifestPlatformsDtoCopyWith<$Res> {
  __$ManifestPlatformsDtoCopyWithImpl(this._self, this._then);

  final _ManifestPlatformsDto _self;
  final $Res Function(_ManifestPlatformsDto) _then;

/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ios = null,Object? android = null,}) {
  return _then(_ManifestPlatformsDto(
ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as PlatformManifestDto,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as PlatformManifestDto,
  ));
}

/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestDtoCopyWith<$Res> get ios {
  
  return $PlatformManifestDtoCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of ManifestPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestDtoCopyWith<$Res> get android {
  
  return $PlatformManifestDtoCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}

// dart format on
