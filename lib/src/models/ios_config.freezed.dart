// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ios_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IosConfig {

 bool get enabled; String? get bundleId; String? get scheme; String? get buildCommand; String get ipaOutputPath; TestflightConfig get testflight; AppStoreConfig get appStore;
/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IosConfigCopyWith<IosConfig> get copyWith => _$IosConfigCopyWithImpl<IosConfig>(this as IosConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IosConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.buildCommand, buildCommand) || other.buildCommand == buildCommand)&&(identical(other.ipaOutputPath, ipaOutputPath) || other.ipaOutputPath == ipaOutputPath)&&(identical(other.testflight, testflight) || other.testflight == testflight)&&(identical(other.appStore, appStore) || other.appStore == appStore));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,bundleId,scheme,buildCommand,ipaOutputPath,testflight,appStore);

@override
String toString() {
  return 'IosConfig(enabled: $enabled, bundleId: $bundleId, scheme: $scheme, buildCommand: $buildCommand, ipaOutputPath: $ipaOutputPath, testflight: $testflight, appStore: $appStore)';
}


}

/// @nodoc
abstract mixin class $IosConfigCopyWith<$Res>  {
  factory $IosConfigCopyWith(IosConfig value, $Res Function(IosConfig) _then) = _$IosConfigCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? bundleId, String? scheme, String? buildCommand, String ipaOutputPath, TestflightConfig testflight, AppStoreConfig appStore
});


$TestflightConfigCopyWith<$Res> get testflight;$AppStoreConfigCopyWith<$Res> get appStore;

}
/// @nodoc
class _$IosConfigCopyWithImpl<$Res>
    implements $IosConfigCopyWith<$Res> {
  _$IosConfigCopyWithImpl(this._self, this._then);

  final IosConfig _self;
  final $Res Function(IosConfig) _then;

/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? bundleId = freezed,Object? scheme = freezed,Object? buildCommand = freezed,Object? ipaOutputPath = null,Object? testflight = null,Object? appStore = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,bundleId: freezed == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String?,scheme: freezed == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as String?,buildCommand: freezed == buildCommand ? _self.buildCommand : buildCommand // ignore: cast_nullable_to_non_nullable
as String?,ipaOutputPath: null == ipaOutputPath ? _self.ipaOutputPath : ipaOutputPath // ignore: cast_nullable_to_non_nullable
as String,testflight: null == testflight ? _self.testflight : testflight // ignore: cast_nullable_to_non_nullable
as TestflightConfig,appStore: null == appStore ? _self.appStore : appStore // ignore: cast_nullable_to_non_nullable
as AppStoreConfig,
  ));
}
/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestflightConfigCopyWith<$Res> get testflight {
  
  return $TestflightConfigCopyWith<$Res>(_self.testflight, (value) {
    return _then(_self.copyWith(testflight: value));
  });
}/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppStoreConfigCopyWith<$Res> get appStore {
  
  return $AppStoreConfigCopyWith<$Res>(_self.appStore, (value) {
    return _then(_self.copyWith(appStore: value));
  });
}
}


/// Adds pattern-matching-related methods to [IosConfig].
extension IosConfigPatterns on IosConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IosConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IosConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IosConfig value)  $default,){
final _that = this;
switch (_that) {
case _IosConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IosConfig value)?  $default,){
final _that = this;
switch (_that) {
case _IosConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? bundleId,  String? scheme,  String? buildCommand,  String ipaOutputPath,  TestflightConfig testflight,  AppStoreConfig appStore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IosConfig() when $default != null:
return $default(_that.enabled,_that.bundleId,_that.scheme,_that.buildCommand,_that.ipaOutputPath,_that.testflight,_that.appStore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? bundleId,  String? scheme,  String? buildCommand,  String ipaOutputPath,  TestflightConfig testflight,  AppStoreConfig appStore)  $default,) {final _that = this;
switch (_that) {
case _IosConfig():
return $default(_that.enabled,_that.bundleId,_that.scheme,_that.buildCommand,_that.ipaOutputPath,_that.testflight,_that.appStore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? bundleId,  String? scheme,  String? buildCommand,  String ipaOutputPath,  TestflightConfig testflight,  AppStoreConfig appStore)?  $default,) {final _that = this;
switch (_that) {
case _IosConfig() when $default != null:
return $default(_that.enabled,_that.bundleId,_that.scheme,_that.buildCommand,_that.ipaOutputPath,_that.testflight,_that.appStore);case _:
  return null;

}
}

}

/// @nodoc


class _IosConfig implements IosConfig {
  const _IosConfig({this.enabled = true, this.bundleId, this.scheme, this.buildCommand, this.ipaOutputPath = 'build/ios/ipa', this.testflight = const TestflightConfig(), this.appStore = const AppStoreConfig()});
  

@override@JsonKey() final  bool enabled;
@override final  String? bundleId;
@override final  String? scheme;
@override final  String? buildCommand;
@override@JsonKey() final  String ipaOutputPath;
@override@JsonKey() final  TestflightConfig testflight;
@override@JsonKey() final  AppStoreConfig appStore;

/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IosConfigCopyWith<_IosConfig> get copyWith => __$IosConfigCopyWithImpl<_IosConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IosConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.buildCommand, buildCommand) || other.buildCommand == buildCommand)&&(identical(other.ipaOutputPath, ipaOutputPath) || other.ipaOutputPath == ipaOutputPath)&&(identical(other.testflight, testflight) || other.testflight == testflight)&&(identical(other.appStore, appStore) || other.appStore == appStore));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,bundleId,scheme,buildCommand,ipaOutputPath,testflight,appStore);

@override
String toString() {
  return 'IosConfig(enabled: $enabled, bundleId: $bundleId, scheme: $scheme, buildCommand: $buildCommand, ipaOutputPath: $ipaOutputPath, testflight: $testflight, appStore: $appStore)';
}


}

/// @nodoc
abstract mixin class _$IosConfigCopyWith<$Res> implements $IosConfigCopyWith<$Res> {
  factory _$IosConfigCopyWith(_IosConfig value, $Res Function(_IosConfig) _then) = __$IosConfigCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? bundleId, String? scheme, String? buildCommand, String ipaOutputPath, TestflightConfig testflight, AppStoreConfig appStore
});


@override $TestflightConfigCopyWith<$Res> get testflight;@override $AppStoreConfigCopyWith<$Res> get appStore;

}
/// @nodoc
class __$IosConfigCopyWithImpl<$Res>
    implements _$IosConfigCopyWith<$Res> {
  __$IosConfigCopyWithImpl(this._self, this._then);

  final _IosConfig _self;
  final $Res Function(_IosConfig) _then;

/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? bundleId = freezed,Object? scheme = freezed,Object? buildCommand = freezed,Object? ipaOutputPath = null,Object? testflight = null,Object? appStore = null,}) {
  return _then(_IosConfig(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,bundleId: freezed == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String?,scheme: freezed == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as String?,buildCommand: freezed == buildCommand ? _self.buildCommand : buildCommand // ignore: cast_nullable_to_non_nullable
as String?,ipaOutputPath: null == ipaOutputPath ? _self.ipaOutputPath : ipaOutputPath // ignore: cast_nullable_to_non_nullable
as String,testflight: null == testflight ? _self.testflight : testflight // ignore: cast_nullable_to_non_nullable
as TestflightConfig,appStore: null == appStore ? _self.appStore : appStore // ignore: cast_nullable_to_non_nullable
as AppStoreConfig,
  ));
}

/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TestflightConfigCopyWith<$Res> get testflight {
  
  return $TestflightConfigCopyWith<$Res>(_self.testflight, (value) {
    return _then(_self.copyWith(testflight: value));
  });
}/// Create a copy of IosConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppStoreConfigCopyWith<$Res> get appStore {
  
  return $AppStoreConfigCopyWith<$Res>(_self.appStore, (value) {
    return _then(_self.copyWith(appStore: value));
  });
}
}

// dart format on
