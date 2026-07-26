// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_store_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppStoreConfig {

 ReleaseMode get mode; StoreReleaseType get releaseType; DateTime? get earliestReleaseDate;
/// Create a copy of AppStoreConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStoreConfigCopyWith<AppStoreConfig> get copyWith => _$AppStoreConfigCopyWithImpl<AppStoreConfig>(this as AppStoreConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStoreConfig&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.releaseType, releaseType) || other.releaseType == releaseType)&&(identical(other.earliestReleaseDate, earliestReleaseDate) || other.earliestReleaseDate == earliestReleaseDate));
}


@override
int get hashCode => Object.hash(runtimeType,mode,releaseType,earliestReleaseDate);

@override
String toString() {
  return 'AppStoreConfig(mode: $mode, releaseType: $releaseType, earliestReleaseDate: $earliestReleaseDate)';
}


}

/// @nodoc
abstract mixin class $AppStoreConfigCopyWith<$Res>  {
  factory $AppStoreConfigCopyWith(AppStoreConfig value, $Res Function(AppStoreConfig) _then) = _$AppStoreConfigCopyWithImpl;
@useResult
$Res call({
 ReleaseMode mode, StoreReleaseType releaseType, DateTime? earliestReleaseDate
});




}
/// @nodoc
class _$AppStoreConfigCopyWithImpl<$Res>
    implements $AppStoreConfigCopyWith<$Res> {
  _$AppStoreConfigCopyWithImpl(this._self, this._then);

  final AppStoreConfig _self;
  final $Res Function(AppStoreConfig) _then;

/// Create a copy of AppStoreConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? releaseType = null,Object? earliestReleaseDate = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ReleaseMode,releaseType: null == releaseType ? _self.releaseType : releaseType // ignore: cast_nullable_to_non_nullable
as StoreReleaseType,earliestReleaseDate: freezed == earliestReleaseDate ? _self.earliestReleaseDate : earliestReleaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppStoreConfig].
extension AppStoreConfigPatterns on AppStoreConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppStoreConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppStoreConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppStoreConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppStoreConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppStoreConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppStoreConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReleaseMode mode,  StoreReleaseType releaseType,  DateTime? earliestReleaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppStoreConfig() when $default != null:
return $default(_that.mode,_that.releaseType,_that.earliestReleaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReleaseMode mode,  StoreReleaseType releaseType,  DateTime? earliestReleaseDate)  $default,) {final _that = this;
switch (_that) {
case _AppStoreConfig():
return $default(_that.mode,_that.releaseType,_that.earliestReleaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReleaseMode mode,  StoreReleaseType releaseType,  DateTime? earliestReleaseDate)?  $default,) {final _that = this;
switch (_that) {
case _AppStoreConfig() when $default != null:
return $default(_that.mode,_that.releaseType,_that.earliestReleaseDate);case _:
  return null;

}
}

}

/// @nodoc


class _AppStoreConfig implements AppStoreConfig {
  const _AppStoreConfig({this.mode = ReleaseMode.uploadOnly, this.releaseType = StoreReleaseType.manual, this.earliestReleaseDate});
  

@override@JsonKey() final  ReleaseMode mode;
@override@JsonKey() final  StoreReleaseType releaseType;
@override final  DateTime? earliestReleaseDate;

/// Create a copy of AppStoreConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStoreConfigCopyWith<_AppStoreConfig> get copyWith => __$AppStoreConfigCopyWithImpl<_AppStoreConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppStoreConfig&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.releaseType, releaseType) || other.releaseType == releaseType)&&(identical(other.earliestReleaseDate, earliestReleaseDate) || other.earliestReleaseDate == earliestReleaseDate));
}


@override
int get hashCode => Object.hash(runtimeType,mode,releaseType,earliestReleaseDate);

@override
String toString() {
  return 'AppStoreConfig(mode: $mode, releaseType: $releaseType, earliestReleaseDate: $earliestReleaseDate)';
}


}

/// @nodoc
abstract mixin class _$AppStoreConfigCopyWith<$Res> implements $AppStoreConfigCopyWith<$Res> {
  factory _$AppStoreConfigCopyWith(_AppStoreConfig value, $Res Function(_AppStoreConfig) _then) = __$AppStoreConfigCopyWithImpl;
@override @useResult
$Res call({
 ReleaseMode mode, StoreReleaseType releaseType, DateTime? earliestReleaseDate
});




}
/// @nodoc
class __$AppStoreConfigCopyWithImpl<$Res>
    implements _$AppStoreConfigCopyWith<$Res> {
  __$AppStoreConfigCopyWithImpl(this._self, this._then);

  final _AppStoreConfig _self;
  final $Res Function(_AppStoreConfig) _then;

/// Create a copy of AppStoreConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? releaseType = null,Object? earliestReleaseDate = freezed,}) {
  return _then(_AppStoreConfig(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ReleaseMode,releaseType: null == releaseType ? _self.releaseType : releaseType // ignore: cast_nullable_to_non_nullable
as StoreReleaseType,earliestReleaseDate: freezed == earliestReleaseDate ? _self.earliestReleaseDate : earliestReleaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
