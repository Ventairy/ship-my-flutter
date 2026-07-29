// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_manifest_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlatformManifestDto {

@JsonKey(required: true, disallowNullValue: true) String get version;@JsonKey(required: true, disallowNullValue: true) String get endCommitHash;@JsonKey(required: true, disallowNullValue: true) bool get isReleasePending;
/// Create a copy of PlatformManifestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformManifestDtoCopyWith<PlatformManifestDto> get copyWith => _$PlatformManifestDtoCopyWithImpl<PlatformManifestDto>(this as PlatformManifestDto, _$identity);

  /// Serializes this PlatformManifestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformManifestDto&&(identical(other.version, version) || other.version == version)&&(identical(other.endCommitHash, endCommitHash) || other.endCommitHash == endCommitHash)&&(identical(other.isReleasePending, isReleasePending) || other.isReleasePending == isReleasePending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,endCommitHash,isReleasePending);

@override
String toString() {
  return 'PlatformManifestDto(version: $version, endCommitHash: $endCommitHash, isReleasePending: $isReleasePending)';
}


}

/// @nodoc
abstract mixin class $PlatformManifestDtoCopyWith<$Res>  {
  factory $PlatformManifestDtoCopyWith(PlatformManifestDto value, $Res Function(PlatformManifestDto) _then) = _$PlatformManifestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String version,@JsonKey(required: true, disallowNullValue: true) String endCommitHash,@JsonKey(required: true, disallowNullValue: true) bool isReleasePending
});




}
/// @nodoc
class _$PlatformManifestDtoCopyWithImpl<$Res>
    implements $PlatformManifestDtoCopyWith<$Res> {
  _$PlatformManifestDtoCopyWithImpl(this._self, this._then);

  final PlatformManifestDto _self;
  final $Res Function(PlatformManifestDto) _then;

/// Create a copy of PlatformManifestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? endCommitHash = null,Object? isReleasePending = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,endCommitHash: null == endCommitHash ? _self.endCommitHash : endCommitHash // ignore: cast_nullable_to_non_nullable
as String,isReleasePending: null == isReleasePending ? _self.isReleasePending : isReleasePending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformManifestDto].
extension PlatformManifestDtoPatterns on PlatformManifestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformManifestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformManifestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformManifestDto value)  $default,){
final _that = this;
switch (_that) {
case _PlatformManifestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformManifestDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformManifestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  String version, @JsonKey(required: true, disallowNullValue: true)  String endCommitHash, @JsonKey(required: true, disallowNullValue: true)  bool isReleasePending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformManifestDto() when $default != null:
return $default(_that.version,_that.endCommitHash,_that.isReleasePending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  String version, @JsonKey(required: true, disallowNullValue: true)  String endCommitHash, @JsonKey(required: true, disallowNullValue: true)  bool isReleasePending)  $default,) {final _that = this;
switch (_that) {
case _PlatformManifestDto():
return $default(_that.version,_that.endCommitHash,_that.isReleasePending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  String version, @JsonKey(required: true, disallowNullValue: true)  String endCommitHash, @JsonKey(required: true, disallowNullValue: true)  bool isReleasePending)?  $default,) {final _that = this;
switch (_that) {
case _PlatformManifestDto() when $default != null:
return $default(_that.version,_that.endCommitHash,_that.isReleasePending);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class _PlatformManifestDto implements PlatformManifestDto {
  const _PlatformManifestDto({@JsonKey(required: true, disallowNullValue: true) required this.version, @JsonKey(required: true, disallowNullValue: true) required this.endCommitHash, @JsonKey(required: true, disallowNullValue: true) required this.isReleasePending});
  factory _PlatformManifestDto.fromJson(Map<String, dynamic> json) => _$PlatformManifestDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  String version;
@override@JsonKey(required: true, disallowNullValue: true) final  String endCommitHash;
@override@JsonKey(required: true, disallowNullValue: true) final  bool isReleasePending;

/// Create a copy of PlatformManifestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformManifestDtoCopyWith<_PlatformManifestDto> get copyWith => __$PlatformManifestDtoCopyWithImpl<_PlatformManifestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformManifestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformManifestDto&&(identical(other.version, version) || other.version == version)&&(identical(other.endCommitHash, endCommitHash) || other.endCommitHash == endCommitHash)&&(identical(other.isReleasePending, isReleasePending) || other.isReleasePending == isReleasePending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,endCommitHash,isReleasePending);

@override
String toString() {
  return 'PlatformManifestDto(version: $version, endCommitHash: $endCommitHash, isReleasePending: $isReleasePending)';
}


}

/// @nodoc
abstract mixin class _$PlatformManifestDtoCopyWith<$Res> implements $PlatformManifestDtoCopyWith<$Res> {
  factory _$PlatformManifestDtoCopyWith(_PlatformManifestDto value, $Res Function(_PlatformManifestDto) _then) = __$PlatformManifestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String version,@JsonKey(required: true, disallowNullValue: true) String endCommitHash,@JsonKey(required: true, disallowNullValue: true) bool isReleasePending
});




}
/// @nodoc
class __$PlatformManifestDtoCopyWithImpl<$Res>
    implements _$PlatformManifestDtoCopyWith<$Res> {
  __$PlatformManifestDtoCopyWithImpl(this._self, this._then);

  final _PlatformManifestDto _self;
  final $Res Function(_PlatformManifestDto) _then;

/// Create a copy of PlatformManifestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? endCommitHash = null,Object? isReleasePending = null,}) {
  return _then(_PlatformManifestDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,endCommitHash: null == endCommitHash ? _self.endCommitHash : endCommitHash // ignore: cast_nullable_to_non_nullable
as String,isReleasePending: null == isReleasePending ? _self.isReleasePending : isReleasePending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
