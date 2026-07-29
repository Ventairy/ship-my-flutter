// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_target_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseTargetDto {

 ReleasePlatform get platform; String get version;
/// Create a copy of ReleaseTargetDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseTargetDtoCopyWith<ReleaseTargetDto> get copyWith => _$ReleaseTargetDtoCopyWithImpl<ReleaseTargetDto>(this as ReleaseTargetDto, _$identity);

  /// Serializes this ReleaseTargetDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseTargetDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version);

@override
String toString() {
  return 'ReleaseTargetDto(platform: $platform, version: $version)';
}


}

/// @nodoc
abstract mixin class $ReleaseTargetDtoCopyWith<$Res>  {
  factory $ReleaseTargetDtoCopyWith(ReleaseTargetDto value, $Res Function(ReleaseTargetDto) _then) = _$ReleaseTargetDtoCopyWithImpl;
@useResult
$Res call({
 ReleasePlatform platform, String version
});




}
/// @nodoc
class _$ReleaseTargetDtoCopyWithImpl<$Res>
    implements $ReleaseTargetDtoCopyWith<$Res> {
  _$ReleaseTargetDtoCopyWithImpl(this._self, this._then);

  final ReleaseTargetDto _self;
  final $Res Function(ReleaseTargetDto) _then;

/// Create a copy of ReleaseTargetDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? version = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseTargetDto].
extension ReleaseTargetDtoPatterns on ReleaseTargetDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseTargetDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseTargetDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseTargetDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseTargetDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseTargetDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseTargetDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReleasePlatform platform,  String version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseTargetDto() when $default != null:
return $default(_that.platform,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReleasePlatform platform,  String version)  $default,) {final _that = this;
switch (_that) {
case _ReleaseTargetDto():
return $default(_that.platform,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReleasePlatform platform,  String version)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseTargetDto() when $default != null:
return $default(_that.platform,_that.version);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _ReleaseTargetDto implements ReleaseTargetDto {
  const _ReleaseTargetDto({required this.platform, required this.version});
  factory _ReleaseTargetDto.fromJson(Map<String, dynamic> json) => _$ReleaseTargetDtoFromJson(json);

@override final  ReleasePlatform platform;
@override final  String version;

/// Create a copy of ReleaseTargetDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseTargetDtoCopyWith<_ReleaseTargetDto> get copyWith => __$ReleaseTargetDtoCopyWithImpl<_ReleaseTargetDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseTargetDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseTargetDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version);

@override
String toString() {
  return 'ReleaseTargetDto(platform: $platform, version: $version)';
}


}

/// @nodoc
abstract mixin class _$ReleaseTargetDtoCopyWith<$Res> implements $ReleaseTargetDtoCopyWith<$Res> {
  factory _$ReleaseTargetDtoCopyWith(_ReleaseTargetDto value, $Res Function(_ReleaseTargetDto) _then) = __$ReleaseTargetDtoCopyWithImpl;
@override @useResult
$Res call({
 ReleasePlatform platform, String version
});




}
/// @nodoc
class __$ReleaseTargetDtoCopyWithImpl<$Res>
    implements _$ReleaseTargetDtoCopyWith<$Res> {
  __$ReleaseTargetDtoCopyWithImpl(this._self, this._then);

  final _ReleaseTargetDto _self;
  final $Res Function(_ReleaseTargetDto) _then;

/// Create a copy of ReleaseTargetDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? version = null,}) {
  return _then(_ReleaseTargetDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
