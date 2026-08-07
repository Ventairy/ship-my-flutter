// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_store_version_attributes_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppStoreVersionAttributesDto {

 ApplePlatform get platform; String get versionString; AppVersionState get appVersionState; AppStoreReleaseType get releaseType;
/// Create a copy of AppStoreVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStoreVersionAttributesDtoCopyWith<AppStoreVersionAttributesDto> get copyWith => _$AppStoreVersionAttributesDtoCopyWithImpl<AppStoreVersionAttributesDto>(this as AppStoreVersionAttributesDto, _$identity);

  /// Serializes this AppStoreVersionAttributesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStoreVersionAttributesDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.versionString, versionString) || other.versionString == versionString)&&(identical(other.appVersionState, appVersionState) || other.appVersionState == appVersionState)&&(identical(other.releaseType, releaseType) || other.releaseType == releaseType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,versionString,appVersionState,releaseType);

@override
String toString() {
  return 'AppStoreVersionAttributesDto(platform: $platform, versionString: $versionString, appVersionState: $appVersionState, releaseType: $releaseType)';
}


}

/// @nodoc
abstract mixin class $AppStoreVersionAttributesDtoCopyWith<$Res>  {
  factory $AppStoreVersionAttributesDtoCopyWith(AppStoreVersionAttributesDto value, $Res Function(AppStoreVersionAttributesDto) _then) = _$AppStoreVersionAttributesDtoCopyWithImpl;
@useResult
$Res call({
 ApplePlatform platform, String versionString, AppVersionState appVersionState, AppStoreReleaseType releaseType
});




}
/// @nodoc
class _$AppStoreVersionAttributesDtoCopyWithImpl<$Res>
    implements $AppStoreVersionAttributesDtoCopyWith<$Res> {
  _$AppStoreVersionAttributesDtoCopyWithImpl(this._self, this._then);

  final AppStoreVersionAttributesDto _self;
  final $Res Function(AppStoreVersionAttributesDto) _then;

/// Create a copy of AppStoreVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? versionString = null,Object? appVersionState = null,Object? releaseType = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ApplePlatform,versionString: null == versionString ? _self.versionString : versionString // ignore: cast_nullable_to_non_nullable
as String,appVersionState: null == appVersionState ? _self.appVersionState : appVersionState // ignore: cast_nullable_to_non_nullable
as AppVersionState,releaseType: null == releaseType ? _self.releaseType : releaseType // ignore: cast_nullable_to_non_nullable
as AppStoreReleaseType,
  ));
}

}


/// Adds pattern-matching-related methods to [AppStoreVersionAttributesDto].
extension AppStoreVersionAttributesDtoPatterns on AppStoreVersionAttributesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppStoreVersionAttributesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppStoreVersionAttributesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppStoreVersionAttributesDto value)  $default,){
final _that = this;
switch (_that) {
case _AppStoreVersionAttributesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppStoreVersionAttributesDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppStoreVersionAttributesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ApplePlatform platform,  String versionString,  AppVersionState appVersionState,  AppStoreReleaseType releaseType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppStoreVersionAttributesDto() when $default != null:
return $default(_that.platform,_that.versionString,_that.appVersionState,_that.releaseType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ApplePlatform platform,  String versionString,  AppVersionState appVersionState,  AppStoreReleaseType releaseType)  $default,) {final _that = this;
switch (_that) {
case _AppStoreVersionAttributesDto():
return $default(_that.platform,_that.versionString,_that.appVersionState,_that.releaseType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ApplePlatform platform,  String versionString,  AppVersionState appVersionState,  AppStoreReleaseType releaseType)?  $default,) {final _that = this;
switch (_that) {
case _AppStoreVersionAttributesDto() when $default != null:
return $default(_that.platform,_that.versionString,_that.appVersionState,_that.releaseType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _AppStoreVersionAttributesDto implements AppStoreVersionAttributesDto {
  const _AppStoreVersionAttributesDto({required this.platform, required this.versionString, required this.appVersionState, required this.releaseType});
  factory _AppStoreVersionAttributesDto.fromJson(Map<String, dynamic> json) => _$AppStoreVersionAttributesDtoFromJson(json);

@override final  ApplePlatform platform;
@override final  String versionString;
@override final  AppVersionState appVersionState;
@override final  AppStoreReleaseType releaseType;

/// Create a copy of AppStoreVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStoreVersionAttributesDtoCopyWith<_AppStoreVersionAttributesDto> get copyWith => __$AppStoreVersionAttributesDtoCopyWithImpl<_AppStoreVersionAttributesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppStoreVersionAttributesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppStoreVersionAttributesDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.versionString, versionString) || other.versionString == versionString)&&(identical(other.appVersionState, appVersionState) || other.appVersionState == appVersionState)&&(identical(other.releaseType, releaseType) || other.releaseType == releaseType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,versionString,appVersionState,releaseType);

@override
String toString() {
  return 'AppStoreVersionAttributesDto(platform: $platform, versionString: $versionString, appVersionState: $appVersionState, releaseType: $releaseType)';
}


}

/// @nodoc
abstract mixin class _$AppStoreVersionAttributesDtoCopyWith<$Res> implements $AppStoreVersionAttributesDtoCopyWith<$Res> {
  factory _$AppStoreVersionAttributesDtoCopyWith(_AppStoreVersionAttributesDto value, $Res Function(_AppStoreVersionAttributesDto) _then) = __$AppStoreVersionAttributesDtoCopyWithImpl;
@override @useResult
$Res call({
 ApplePlatform platform, String versionString, AppVersionState appVersionState, AppStoreReleaseType releaseType
});




}
/// @nodoc
class __$AppStoreVersionAttributesDtoCopyWithImpl<$Res>
    implements _$AppStoreVersionAttributesDtoCopyWith<$Res> {
  __$AppStoreVersionAttributesDtoCopyWithImpl(this._self, this._then);

  final _AppStoreVersionAttributesDto _self;
  final $Res Function(_AppStoreVersionAttributesDto) _then;

/// Create a copy of AppStoreVersionAttributesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? versionString = null,Object? appVersionState = null,Object? releaseType = null,}) {
  return _then(_AppStoreVersionAttributesDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ApplePlatform,versionString: null == versionString ? _self.versionString : versionString // ignore: cast_nullable_to_non_nullable
as String,appVersionState: null == appVersionState ? _self.appVersionState : appVersionState // ignore: cast_nullable_to_non_nullable
as AppVersionState,releaseType: null == releaseType ? _self.releaseType : releaseType // ignore: cast_nullable_to_non_nullable
as AppStoreReleaseType,
  ));
}


}

// dart format on
