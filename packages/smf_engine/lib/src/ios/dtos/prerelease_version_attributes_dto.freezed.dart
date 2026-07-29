// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prerelease_version_attributes_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrereleaseVersionAttributesDto {

 String get version; ApplePlatform get platform;
/// Create a copy of PrereleaseVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrereleaseVersionAttributesDtoCopyWith<PrereleaseVersionAttributesDto> get copyWith => _$PrereleaseVersionAttributesDtoCopyWithImpl<PrereleaseVersionAttributesDto>(this as PrereleaseVersionAttributesDto, _$identity);

  /// Serializes this PrereleaseVersionAttributesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrereleaseVersionAttributesDto&&(identical(other.version, version) || other.version == version)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,platform);

@override
String toString() {
  return 'PrereleaseVersionAttributesDto(version: $version, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $PrereleaseVersionAttributesDtoCopyWith<$Res>  {
  factory $PrereleaseVersionAttributesDtoCopyWith(PrereleaseVersionAttributesDto value, $Res Function(PrereleaseVersionAttributesDto) _then) = _$PrereleaseVersionAttributesDtoCopyWithImpl;
@useResult
$Res call({
 String version, ApplePlatform platform
});




}
/// @nodoc
class _$PrereleaseVersionAttributesDtoCopyWithImpl<$Res>
    implements $PrereleaseVersionAttributesDtoCopyWith<$Res> {
  _$PrereleaseVersionAttributesDtoCopyWithImpl(this._self, this._then);

  final PrereleaseVersionAttributesDto _self;
  final $Res Function(PrereleaseVersionAttributesDto) _then;

/// Create a copy of PrereleaseVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? platform = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ApplePlatform,
  ));
}

}


/// Adds pattern-matching-related methods to [PrereleaseVersionAttributesDto].
extension PrereleaseVersionAttributesDtoPatterns on PrereleaseVersionAttributesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrereleaseVersionAttributesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrereleaseVersionAttributesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrereleaseVersionAttributesDto value)  $default,){
final _that = this;
switch (_that) {
case _PrereleaseVersionAttributesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrereleaseVersionAttributesDto value)?  $default,){
final _that = this;
switch (_that) {
case _PrereleaseVersionAttributesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  ApplePlatform platform)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrereleaseVersionAttributesDto() when $default != null:
return $default(_that.version,_that.platform);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  ApplePlatform platform)  $default,) {final _that = this;
switch (_that) {
case _PrereleaseVersionAttributesDto():
return $default(_that.version,_that.platform);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  ApplePlatform platform)?  $default,) {final _that = this;
switch (_that) {
case _PrereleaseVersionAttributesDto() when $default != null:
return $default(_that.version,_that.platform);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _PrereleaseVersionAttributesDto implements PrereleaseVersionAttributesDto {
  const _PrereleaseVersionAttributesDto({required this.version, required this.platform});
  factory _PrereleaseVersionAttributesDto.fromJson(Map<String, dynamic> json) => _$PrereleaseVersionAttributesDtoFromJson(json);

@override final  String version;
@override final  ApplePlatform platform;

/// Create a copy of PrereleaseVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrereleaseVersionAttributesDtoCopyWith<_PrereleaseVersionAttributesDto> get copyWith => __$PrereleaseVersionAttributesDtoCopyWithImpl<_PrereleaseVersionAttributesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrereleaseVersionAttributesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrereleaseVersionAttributesDto&&(identical(other.version, version) || other.version == version)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,platform);

@override
String toString() {
  return 'PrereleaseVersionAttributesDto(version: $version, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$PrereleaseVersionAttributesDtoCopyWith<$Res> implements $PrereleaseVersionAttributesDtoCopyWith<$Res> {
  factory _$PrereleaseVersionAttributesDtoCopyWith(_PrereleaseVersionAttributesDto value, $Res Function(_PrereleaseVersionAttributesDto) _then) = __$PrereleaseVersionAttributesDtoCopyWithImpl;
@override @useResult
$Res call({
 String version, ApplePlatform platform
});




}
/// @nodoc
class __$PrereleaseVersionAttributesDtoCopyWithImpl<$Res>
    implements _$PrereleaseVersionAttributesDtoCopyWith<$Res> {
  __$PrereleaseVersionAttributesDtoCopyWithImpl(this._self, this._then);

  final _PrereleaseVersionAttributesDto _self;
  final $Res Function(_PrereleaseVersionAttributesDto) _then;

/// Create a copy of PrereleaseVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? platform = null,}) {
  return _then(_PrereleaseVersionAttributesDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ApplePlatform,
  ));
}


}

// dart format on
