// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_attributes_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuildAttributesDto {

 String get version; BuildProcessingState get processingState; String? get uploadedDate;@JsonKey(name: 'expired') bool get isExpired;@JsonKey(name: 'usesNonExemptEncryption') bool? get doesUseNonExemptEncryption;
/// Create a copy of BuildAttributesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildAttributesDtoCopyWith<BuildAttributesDto> get copyWith => _$BuildAttributesDtoCopyWithImpl<BuildAttributesDto>(this as BuildAttributesDto, _$identity);

  /// Serializes this BuildAttributesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildAttributesDto&&(identical(other.version, version) || other.version == version)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.uploadedDate, uploadedDate) || other.uploadedDate == uploadedDate)&&(identical(other.isExpired, isExpired) || other.isExpired == isExpired)&&(identical(other.doesUseNonExemptEncryption, doesUseNonExemptEncryption) || other.doesUseNonExemptEncryption == doesUseNonExemptEncryption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,processingState,uploadedDate,isExpired,doesUseNonExemptEncryption);

@override
String toString() {
  return 'BuildAttributesDto(version: $version, processingState: $processingState, uploadedDate: $uploadedDate, isExpired: $isExpired, doesUseNonExemptEncryption: $doesUseNonExemptEncryption)';
}


}

/// @nodoc
abstract mixin class $BuildAttributesDtoCopyWith<$Res>  {
  factory $BuildAttributesDtoCopyWith(BuildAttributesDto value, $Res Function(BuildAttributesDto) _then) = _$BuildAttributesDtoCopyWithImpl;
@useResult
$Res call({
 String version, BuildProcessingState processingState, String? uploadedDate,@JsonKey(name: 'expired') bool isExpired,@JsonKey(name: 'usesNonExemptEncryption') bool? doesUseNonExemptEncryption
});




}
/// @nodoc
class _$BuildAttributesDtoCopyWithImpl<$Res>
    implements $BuildAttributesDtoCopyWith<$Res> {
  _$BuildAttributesDtoCopyWithImpl(this._self, this._then);

  final BuildAttributesDto _self;
  final $Res Function(BuildAttributesDto) _then;

/// Create a copy of BuildAttributesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? processingState = null,Object? uploadedDate = freezed,Object? isExpired = null,Object? doesUseNonExemptEncryption = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,processingState: null == processingState ? _self.processingState : processingState // ignore: cast_nullable_to_non_nullable
as BuildProcessingState,uploadedDate: freezed == uploadedDate ? _self.uploadedDate : uploadedDate // ignore: cast_nullable_to_non_nullable
as String?,isExpired: null == isExpired ? _self.isExpired : isExpired // ignore: cast_nullable_to_non_nullable
as bool,doesUseNonExemptEncryption: freezed == doesUseNonExemptEncryption ? _self.doesUseNonExemptEncryption : doesUseNonExemptEncryption // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [BuildAttributesDto].
extension BuildAttributesDtoPatterns on BuildAttributesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuildAttributesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuildAttributesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuildAttributesDto value)  $default,){
final _that = this;
switch (_that) {
case _BuildAttributesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuildAttributesDto value)?  $default,){
final _that = this;
switch (_that) {
case _BuildAttributesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  BuildProcessingState processingState,  String? uploadedDate, @JsonKey(name: 'expired')  bool isExpired, @JsonKey(name: 'usesNonExemptEncryption')  bool? doesUseNonExemptEncryption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuildAttributesDto() when $default != null:
return $default(_that.version,_that.processingState,_that.uploadedDate,_that.isExpired,_that.doesUseNonExemptEncryption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  BuildProcessingState processingState,  String? uploadedDate, @JsonKey(name: 'expired')  bool isExpired, @JsonKey(name: 'usesNonExemptEncryption')  bool? doesUseNonExemptEncryption)  $default,) {final _that = this;
switch (_that) {
case _BuildAttributesDto():
return $default(_that.version,_that.processingState,_that.uploadedDate,_that.isExpired,_that.doesUseNonExemptEncryption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  BuildProcessingState processingState,  String? uploadedDate, @JsonKey(name: 'expired')  bool isExpired, @JsonKey(name: 'usesNonExemptEncryption')  bool? doesUseNonExemptEncryption)?  $default,) {final _that = this;
switch (_that) {
case _BuildAttributesDto() when $default != null:
return $default(_that.version,_that.processingState,_that.uploadedDate,_that.isExpired,_that.doesUseNonExemptEncryption);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _BuildAttributesDto implements BuildAttributesDto {
  const _BuildAttributesDto({required this.version, required this.processingState, this.uploadedDate, @JsonKey(name: 'expired') this.isExpired = false, @JsonKey(name: 'usesNonExemptEncryption') this.doesUseNonExemptEncryption});
  factory _BuildAttributesDto.fromJson(Map<String, dynamic> json) => _$BuildAttributesDtoFromJson(json);

@override final  String version;
@override final  BuildProcessingState processingState;
@override final  String? uploadedDate;
@override@JsonKey(name: 'expired') final  bool isExpired;
@override@JsonKey(name: 'usesNonExemptEncryption') final  bool? doesUseNonExemptEncryption;

/// Create a copy of BuildAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildAttributesDtoCopyWith<_BuildAttributesDto> get copyWith => __$BuildAttributesDtoCopyWithImpl<_BuildAttributesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuildAttributesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildAttributesDto&&(identical(other.version, version) || other.version == version)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.uploadedDate, uploadedDate) || other.uploadedDate == uploadedDate)&&(identical(other.isExpired, isExpired) || other.isExpired == isExpired)&&(identical(other.doesUseNonExemptEncryption, doesUseNonExemptEncryption) || other.doesUseNonExemptEncryption == doesUseNonExemptEncryption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,processingState,uploadedDate,isExpired,doesUseNonExemptEncryption);

@override
String toString() {
  return 'BuildAttributesDto(version: $version, processingState: $processingState, uploadedDate: $uploadedDate, isExpired: $isExpired, doesUseNonExemptEncryption: $doesUseNonExemptEncryption)';
}


}

/// @nodoc
abstract mixin class _$BuildAttributesDtoCopyWith<$Res> implements $BuildAttributesDtoCopyWith<$Res> {
  factory _$BuildAttributesDtoCopyWith(_BuildAttributesDto value, $Res Function(_BuildAttributesDto) _then) = __$BuildAttributesDtoCopyWithImpl;
@override @useResult
$Res call({
 String version, BuildProcessingState processingState, String? uploadedDate,@JsonKey(name: 'expired') bool isExpired,@JsonKey(name: 'usesNonExemptEncryption') bool? doesUseNonExemptEncryption
});




}
/// @nodoc
class __$BuildAttributesDtoCopyWithImpl<$Res>
    implements _$BuildAttributesDtoCopyWith<$Res> {
  __$BuildAttributesDtoCopyWithImpl(this._self, this._then);

  final _BuildAttributesDto _self;
  final $Res Function(_BuildAttributesDto) _then;

/// Create a copy of BuildAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? processingState = null,Object? uploadedDate = freezed,Object? isExpired = null,Object? doesUseNonExemptEncryption = freezed,}) {
  return _then(_BuildAttributesDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,processingState: null == processingState ? _self.processingState : processingState // ignore: cast_nullable_to_non_nullable
as BuildProcessingState,uploadedDate: freezed == uploadedDate ? _self.uploadedDate : uploadedDate // ignore: cast_nullable_to_non_nullable
as String?,isExpired: null == isExpired ? _self.isExpired : isExpired // ignore: cast_nullable_to_non_nullable
as bool,doesUseNonExemptEncryption: freezed == doesUseNonExemptEncryption ? _self.doesUseNonExemptEncryption : doesUseNonExemptEncryption // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
