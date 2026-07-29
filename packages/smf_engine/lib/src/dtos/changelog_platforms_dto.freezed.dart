// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changelog_platforms_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangelogPlatformsDto {

@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformDto get ios;@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformDto get android;
/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogPlatformsDtoCopyWith<ChangelogPlatformsDto> get copyWith => _$ChangelogPlatformsDtoCopyWithImpl<ChangelogPlatformsDto>(this as ChangelogPlatformsDto, _$identity);

  /// Serializes this ChangelogPlatformsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogPlatformsDto&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ios,android);

@override
String toString() {
  return 'ChangelogPlatformsDto(ios: $ios, android: $android)';
}


}

/// @nodoc
abstract mixin class $ChangelogPlatformsDtoCopyWith<$Res>  {
  factory $ChangelogPlatformsDtoCopyWith(ChangelogPlatformsDto value, $Res Function(ChangelogPlatformsDto) _then) = _$ChangelogPlatformsDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformDto ios,@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformDto android
});


$ChangelogPlatformDtoCopyWith<$Res> get ios;$ChangelogPlatformDtoCopyWith<$Res> get android;

}
/// @nodoc
class _$ChangelogPlatformsDtoCopyWithImpl<$Res>
    implements $ChangelogPlatformsDtoCopyWith<$Res> {
  _$ChangelogPlatformsDtoCopyWithImpl(this._self, this._then);

  final ChangelogPlatformsDto _self;
  final $Res Function(ChangelogPlatformsDto) _then;

/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ios = null,Object? android = null,}) {
  return _then(_self.copyWith(
ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as ChangelogPlatformDto,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as ChangelogPlatformDto,
  ));
}
/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangelogPlatformDtoCopyWith<$Res> get ios {
  
  return $ChangelogPlatformDtoCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangelogPlatformDtoCopyWith<$Res> get android {
  
  return $ChangelogPlatformDtoCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChangelogPlatformsDto].
extension ChangelogPlatformsDtoPatterns on ChangelogPlatformsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogPlatformsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogPlatformsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogPlatformsDto value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogPlatformsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogPlatformsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogPlatformsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformDto ios, @JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformDto android)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogPlatformsDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformDto ios, @JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformDto android)  $default,) {final _that = this;
switch (_that) {
case _ChangelogPlatformsDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformDto ios, @JsonKey(required: true, disallowNullValue: true)  ChangelogPlatformDto android)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogPlatformsDto() when $default != null:
return $default(_that.ios,_that.android);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ChangelogPlatformsDto extends ChangelogPlatformsDto {
  const _ChangelogPlatformsDto({@JsonKey(required: true, disallowNullValue: true) required this.ios, @JsonKey(required: true, disallowNullValue: true) required this.android}): super._();
  factory _ChangelogPlatformsDto.fromJson(Map<String, dynamic> json) => _$ChangelogPlatformsDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  ChangelogPlatformDto ios;
@override@JsonKey(required: true, disallowNullValue: true) final  ChangelogPlatformDto android;

/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogPlatformsDtoCopyWith<_ChangelogPlatformsDto> get copyWith => __$ChangelogPlatformsDtoCopyWithImpl<_ChangelogPlatformsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogPlatformsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogPlatformsDto&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ios,android);

@override
String toString() {
  return 'ChangelogPlatformsDto(ios: $ios, android: $android)';
}


}

/// @nodoc
abstract mixin class _$ChangelogPlatformsDtoCopyWith<$Res> implements $ChangelogPlatformsDtoCopyWith<$Res> {
  factory _$ChangelogPlatformsDtoCopyWith(_ChangelogPlatformsDto value, $Res Function(_ChangelogPlatformsDto) _then) = __$ChangelogPlatformsDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformDto ios,@JsonKey(required: true, disallowNullValue: true) ChangelogPlatformDto android
});


@override $ChangelogPlatformDtoCopyWith<$Res> get ios;@override $ChangelogPlatformDtoCopyWith<$Res> get android;

}
/// @nodoc
class __$ChangelogPlatformsDtoCopyWithImpl<$Res>
    implements _$ChangelogPlatformsDtoCopyWith<$Res> {
  __$ChangelogPlatformsDtoCopyWithImpl(this._self, this._then);

  final _ChangelogPlatformsDto _self;
  final $Res Function(_ChangelogPlatformsDto) _then;

/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ios = null,Object? android = null,}) {
  return _then(_ChangelogPlatformsDto(
ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as ChangelogPlatformDto,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as ChangelogPlatformDto,
  ));
}

/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangelogPlatformDtoCopyWith<$Res> get ios {
  
  return $ChangelogPlatformDtoCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of ChangelogPlatformsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangelogPlatformDtoCopyWith<$Res> get android {
  
  return $ChangelogPlatformDtoCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}

// dart format on
