// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_attributes_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppAttributesDto {

 String get name; String get bundleId; String get sku; String get primaryLocale;
/// Create a copy of AppAttributesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppAttributesDtoCopyWith<AppAttributesDto> get copyWith => _$AppAttributesDtoCopyWithImpl<AppAttributesDto>(this as AppAttributesDto, _$identity);

  /// Serializes this AppAttributesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAttributesDto&&(identical(other.name, name) || other.name == name)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.primaryLocale, primaryLocale) || other.primaryLocale == primaryLocale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,bundleId,sku,primaryLocale);

@override
String toString() {
  return 'AppAttributesDto(name: $name, bundleId: $bundleId, sku: $sku, primaryLocale: $primaryLocale)';
}


}

/// @nodoc
abstract mixin class $AppAttributesDtoCopyWith<$Res>  {
  factory $AppAttributesDtoCopyWith(AppAttributesDto value, $Res Function(AppAttributesDto) _then) = _$AppAttributesDtoCopyWithImpl;
@useResult
$Res call({
 String name, String bundleId, String sku, String primaryLocale
});




}
/// @nodoc
class _$AppAttributesDtoCopyWithImpl<$Res>
    implements $AppAttributesDtoCopyWith<$Res> {
  _$AppAttributesDtoCopyWithImpl(this._self, this._then);

  final AppAttributesDto _self;
  final $Res Function(AppAttributesDto) _then;

/// Create a copy of AppAttributesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? bundleId = null,Object? sku = null,Object? primaryLocale = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,primaryLocale: null == primaryLocale ? _self.primaryLocale : primaryLocale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppAttributesDto].
extension AppAttributesDtoPatterns on AppAttributesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppAttributesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppAttributesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppAttributesDto value)  $default,){
final _that = this;
switch (_that) {
case _AppAttributesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppAttributesDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppAttributesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String bundleId,  String sku,  String primaryLocale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppAttributesDto() when $default != null:
return $default(_that.name,_that.bundleId,_that.sku,_that.primaryLocale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String bundleId,  String sku,  String primaryLocale)  $default,) {final _that = this;
switch (_that) {
case _AppAttributesDto():
return $default(_that.name,_that.bundleId,_that.sku,_that.primaryLocale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String bundleId,  String sku,  String primaryLocale)?  $default,) {final _that = this;
switch (_that) {
case _AppAttributesDto() when $default != null:
return $default(_that.name,_that.bundleId,_that.sku,_that.primaryLocale);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _AppAttributesDto implements AppAttributesDto {
  const _AppAttributesDto({required this.name, required this.bundleId, required this.sku, required this.primaryLocale});
  factory _AppAttributesDto.fromJson(Map<String, dynamic> json) => _$AppAttributesDtoFromJson(json);

@override final  String name;
@override final  String bundleId;
@override final  String sku;
@override final  String primaryLocale;

/// Create a copy of AppAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppAttributesDtoCopyWith<_AppAttributesDto> get copyWith => __$AppAttributesDtoCopyWithImpl<_AppAttributesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppAttributesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppAttributesDto&&(identical(other.name, name) || other.name == name)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.primaryLocale, primaryLocale) || other.primaryLocale == primaryLocale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,bundleId,sku,primaryLocale);

@override
String toString() {
  return 'AppAttributesDto(name: $name, bundleId: $bundleId, sku: $sku, primaryLocale: $primaryLocale)';
}


}

/// @nodoc
abstract mixin class _$AppAttributesDtoCopyWith<$Res> implements $AppAttributesDtoCopyWith<$Res> {
  factory _$AppAttributesDtoCopyWith(_AppAttributesDto value, $Res Function(_AppAttributesDto) _then) = __$AppAttributesDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String bundleId, String sku, String primaryLocale
});




}
/// @nodoc
class __$AppAttributesDtoCopyWithImpl<$Res>
    implements _$AppAttributesDtoCopyWith<$Res> {
  __$AppAttributesDtoCopyWithImpl(this._self, this._then);

  final _AppAttributesDto _self;
  final $Res Function(_AppAttributesDto) _then;

/// Create a copy of AppAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? bundleId = null,Object? sku = null,Object? primaryLocale = null,}) {
  return _then(_AppAttributesDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,primaryLocale: null == primaryLocale ? _self.primaryLocale : primaryLocale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
