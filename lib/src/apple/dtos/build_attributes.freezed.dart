// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuildAttributes {

 String get version; String get processingState; String? get uploadedDate; bool get expired; bool? get usesNonExemptEncryption;
/// Create a copy of BuildAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildAttributesCopyWith<BuildAttributes> get copyWith => _$BuildAttributesCopyWithImpl<BuildAttributes>(this as BuildAttributes, _$identity);

  /// Serializes this BuildAttributes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildAttributes&&(identical(other.version, version) || other.version == version)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.uploadedDate, uploadedDate) || other.uploadedDate == uploadedDate)&&(identical(other.expired, expired) || other.expired == expired)&&(identical(other.usesNonExemptEncryption, usesNonExemptEncryption) || other.usesNonExemptEncryption == usesNonExemptEncryption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,processingState,uploadedDate,expired,usesNonExemptEncryption);

@override
String toString() {
  return 'BuildAttributes(version: $version, processingState: $processingState, uploadedDate: $uploadedDate, expired: $expired, usesNonExemptEncryption: $usesNonExemptEncryption)';
}


}

/// @nodoc
abstract mixin class $BuildAttributesCopyWith<$Res>  {
  factory $BuildAttributesCopyWith(BuildAttributes value, $Res Function(BuildAttributes) _then) = _$BuildAttributesCopyWithImpl;
@useResult
$Res call({
 String version, String processingState, String? uploadedDate, bool expired, bool? usesNonExemptEncryption
});




}
/// @nodoc
class _$BuildAttributesCopyWithImpl<$Res>
    implements $BuildAttributesCopyWith<$Res> {
  _$BuildAttributesCopyWithImpl(this._self, this._then);

  final BuildAttributes _self;
  final $Res Function(BuildAttributes) _then;

/// Create a copy of BuildAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? processingState = null,Object? uploadedDate = freezed,Object? expired = null,Object? usesNonExemptEncryption = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,processingState: null == processingState ? _self.processingState : processingState // ignore: cast_nullable_to_non_nullable
as String,uploadedDate: freezed == uploadedDate ? _self.uploadedDate : uploadedDate // ignore: cast_nullable_to_non_nullable
as String?,expired: null == expired ? _self.expired : expired // ignore: cast_nullable_to_non_nullable
as bool,usesNonExemptEncryption: freezed == usesNonExemptEncryption ? _self.usesNonExemptEncryption : usesNonExemptEncryption // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [BuildAttributes].
extension BuildAttributesPatterns on BuildAttributes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuildAttributes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuildAttributes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuildAttributes value)  $default,){
final _that = this;
switch (_that) {
case _BuildAttributes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuildAttributes value)?  $default,){
final _that = this;
switch (_that) {
case _BuildAttributes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String processingState,  String? uploadedDate,  bool expired,  bool? usesNonExemptEncryption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuildAttributes() when $default != null:
return $default(_that.version,_that.processingState,_that.uploadedDate,_that.expired,_that.usesNonExemptEncryption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String processingState,  String? uploadedDate,  bool expired,  bool? usesNonExemptEncryption)  $default,) {final _that = this;
switch (_that) {
case _BuildAttributes():
return $default(_that.version,_that.processingState,_that.uploadedDate,_that.expired,_that.usesNonExemptEncryption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String processingState,  String? uploadedDate,  bool expired,  bool? usesNonExemptEncryption)?  $default,) {final _that = this;
switch (_that) {
case _BuildAttributes() when $default != null:
return $default(_that.version,_that.processingState,_that.uploadedDate,_that.expired,_that.usesNonExemptEncryption);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _BuildAttributes implements BuildAttributes {
  const _BuildAttributes({required this.version, required this.processingState, this.uploadedDate, this.expired = false, this.usesNonExemptEncryption});
  factory _BuildAttributes.fromJson(Map<String, dynamic> json) => _$BuildAttributesFromJson(json);

@override final  String version;
@override final  String processingState;
@override final  String? uploadedDate;
@override@JsonKey() final  bool expired;
@override final  bool? usesNonExemptEncryption;

/// Create a copy of BuildAttributes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildAttributesCopyWith<_BuildAttributes> get copyWith => __$BuildAttributesCopyWithImpl<_BuildAttributes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuildAttributesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildAttributes&&(identical(other.version, version) || other.version == version)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.uploadedDate, uploadedDate) || other.uploadedDate == uploadedDate)&&(identical(other.expired, expired) || other.expired == expired)&&(identical(other.usesNonExemptEncryption, usesNonExemptEncryption) || other.usesNonExemptEncryption == usesNonExemptEncryption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,processingState,uploadedDate,expired,usesNonExemptEncryption);

@override
String toString() {
  return 'BuildAttributes(version: $version, processingState: $processingState, uploadedDate: $uploadedDate, expired: $expired, usesNonExemptEncryption: $usesNonExemptEncryption)';
}


}

/// @nodoc
abstract mixin class _$BuildAttributesCopyWith<$Res> implements $BuildAttributesCopyWith<$Res> {
  factory _$BuildAttributesCopyWith(_BuildAttributes value, $Res Function(_BuildAttributes) _then) = __$BuildAttributesCopyWithImpl;
@override @useResult
$Res call({
 String version, String processingState, String? uploadedDate, bool expired, bool? usesNonExemptEncryption
});




}
/// @nodoc
class __$BuildAttributesCopyWithImpl<$Res>
    implements _$BuildAttributesCopyWith<$Res> {
  __$BuildAttributesCopyWithImpl(this._self, this._then);

  final _BuildAttributes _self;
  final $Res Function(_BuildAttributes) _then;

/// Create a copy of BuildAttributes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? processingState = null,Object? uploadedDate = freezed,Object? expired = null,Object? usesNonExemptEncryption = freezed,}) {
  return _then(_BuildAttributes(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,processingState: null == processingState ? _self.processingState : processingState // ignore: cast_nullable_to_non_nullable
as String,uploadedDate: freezed == uploadedDate ? _self.uploadedDate : uploadedDate // ignore: cast_nullable_to_non_nullable
as String?,expired: null == expired ? _self.expired : expired // ignore: cast_nullable_to_non_nullable
as bool,usesNonExemptEncryption: freezed == usesNonExemptEncryption ? _self.usesNonExemptEncryption : usesNonExemptEncryption // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
