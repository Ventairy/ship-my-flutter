// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'android_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AndroidConfig {

 bool get isEnabled; String get initialVersion; String? get packageName; String? get buildCommand; String get aabOutputPath; GooglePlayConfig get googlePlay;
/// Create a copy of AndroidConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AndroidConfigCopyWith<AndroidConfig> get copyWith => _$AndroidConfigCopyWithImpl<AndroidConfig>(this as AndroidConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AndroidConfig&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.initialVersion, initialVersion) || other.initialVersion == initialVersion)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.buildCommand, buildCommand) || other.buildCommand == buildCommand)&&(identical(other.aabOutputPath, aabOutputPath) || other.aabOutputPath == aabOutputPath)&&(identical(other.googlePlay, googlePlay) || other.googlePlay == googlePlay));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled,initialVersion,packageName,buildCommand,aabOutputPath,googlePlay);

@override
String toString() {
  return 'AndroidConfig(isEnabled: $isEnabled, initialVersion: $initialVersion, packageName: $packageName, buildCommand: $buildCommand, aabOutputPath: $aabOutputPath, googlePlay: $googlePlay)';
}


}

/// @nodoc
abstract mixin class $AndroidConfigCopyWith<$Res>  {
  factory $AndroidConfigCopyWith(AndroidConfig value, $Res Function(AndroidConfig) _then) = _$AndroidConfigCopyWithImpl;
@useResult
$Res call({
 bool isEnabled, String initialVersion, String? packageName, String? buildCommand, String aabOutputPath, GooglePlayConfig googlePlay
});


$GooglePlayConfigCopyWith<$Res> get googlePlay;

}
/// @nodoc
class _$AndroidConfigCopyWithImpl<$Res>
    implements $AndroidConfigCopyWith<$Res> {
  _$AndroidConfigCopyWithImpl(this._self, this._then);

  final AndroidConfig _self;
  final $Res Function(AndroidConfig) _then;

/// Create a copy of AndroidConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEnabled = null,Object? initialVersion = null,Object? packageName = freezed,Object? buildCommand = freezed,Object? aabOutputPath = null,Object? googlePlay = null,}) {
  return _then(_self.copyWith(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,initialVersion: null == initialVersion ? _self.initialVersion : initialVersion // ignore: cast_nullable_to_non_nullable
as String,packageName: freezed == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String?,buildCommand: freezed == buildCommand ? _self.buildCommand : buildCommand // ignore: cast_nullable_to_non_nullable
as String?,aabOutputPath: null == aabOutputPath ? _self.aabOutputPath : aabOutputPath // ignore: cast_nullable_to_non_nullable
as String,googlePlay: null == googlePlay ? _self.googlePlay : googlePlay // ignore: cast_nullable_to_non_nullable
as GooglePlayConfig,
  ));
}
/// Create a copy of AndroidConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GooglePlayConfigCopyWith<$Res> get googlePlay {
  
  return $GooglePlayConfigCopyWith<$Res>(_self.googlePlay, (value) {
    return _then(_self.copyWith(googlePlay: value));
  });
}
}


/// Adds pattern-matching-related methods to [AndroidConfig].
extension AndroidConfigPatterns on AndroidConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AndroidConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AndroidConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AndroidConfig value)  $default,){
final _that = this;
switch (_that) {
case _AndroidConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AndroidConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AndroidConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEnabled,  String initialVersion,  String? packageName,  String? buildCommand,  String aabOutputPath,  GooglePlayConfig googlePlay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AndroidConfig() when $default != null:
return $default(_that.isEnabled,_that.initialVersion,_that.packageName,_that.buildCommand,_that.aabOutputPath,_that.googlePlay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEnabled,  String initialVersion,  String? packageName,  String? buildCommand,  String aabOutputPath,  GooglePlayConfig googlePlay)  $default,) {final _that = this;
switch (_that) {
case _AndroidConfig():
return $default(_that.isEnabled,_that.initialVersion,_that.packageName,_that.buildCommand,_that.aabOutputPath,_that.googlePlay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEnabled,  String initialVersion,  String? packageName,  String? buildCommand,  String aabOutputPath,  GooglePlayConfig googlePlay)?  $default,) {final _that = this;
switch (_that) {
case _AndroidConfig() when $default != null:
return $default(_that.isEnabled,_that.initialVersion,_that.packageName,_that.buildCommand,_that.aabOutputPath,_that.googlePlay);case _:
  return null;

}
}

}

/// @nodoc


class _AndroidConfig implements AndroidConfig {
  const _AndroidConfig({this.isEnabled = false, this.initialVersion = '0.0.0', this.packageName, this.buildCommand, this.aabOutputPath = 'build/app/outputs/bundle/release', this.googlePlay = const GooglePlayConfig()});
  

@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  String initialVersion;
@override final  String? packageName;
@override final  String? buildCommand;
@override@JsonKey() final  String aabOutputPath;
@override@JsonKey() final  GooglePlayConfig googlePlay;

/// Create a copy of AndroidConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AndroidConfigCopyWith<_AndroidConfig> get copyWith => __$AndroidConfigCopyWithImpl<_AndroidConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AndroidConfig&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.initialVersion, initialVersion) || other.initialVersion == initialVersion)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.buildCommand, buildCommand) || other.buildCommand == buildCommand)&&(identical(other.aabOutputPath, aabOutputPath) || other.aabOutputPath == aabOutputPath)&&(identical(other.googlePlay, googlePlay) || other.googlePlay == googlePlay));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled,initialVersion,packageName,buildCommand,aabOutputPath,googlePlay);

@override
String toString() {
  return 'AndroidConfig(isEnabled: $isEnabled, initialVersion: $initialVersion, packageName: $packageName, buildCommand: $buildCommand, aabOutputPath: $aabOutputPath, googlePlay: $googlePlay)';
}


}

/// @nodoc
abstract mixin class _$AndroidConfigCopyWith<$Res> implements $AndroidConfigCopyWith<$Res> {
  factory _$AndroidConfigCopyWith(_AndroidConfig value, $Res Function(_AndroidConfig) _then) = __$AndroidConfigCopyWithImpl;
@override @useResult
$Res call({
 bool isEnabled, String initialVersion, String? packageName, String? buildCommand, String aabOutputPath, GooglePlayConfig googlePlay
});


@override $GooglePlayConfigCopyWith<$Res> get googlePlay;

}
/// @nodoc
class __$AndroidConfigCopyWithImpl<$Res>
    implements _$AndroidConfigCopyWith<$Res> {
  __$AndroidConfigCopyWithImpl(this._self, this._then);

  final _AndroidConfig _self;
  final $Res Function(_AndroidConfig) _then;

/// Create a copy of AndroidConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,Object? initialVersion = null,Object? packageName = freezed,Object? buildCommand = freezed,Object? aabOutputPath = null,Object? googlePlay = null,}) {
  return _then(_AndroidConfig(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,initialVersion: null == initialVersion ? _self.initialVersion : initialVersion // ignore: cast_nullable_to_non_nullable
as String,packageName: freezed == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String?,buildCommand: freezed == buildCommand ? _self.buildCommand : buildCommand // ignore: cast_nullable_to_non_nullable
as String?,aabOutputPath: null == aabOutputPath ? _self.aabOutputPath : aabOutputPath // ignore: cast_nullable_to_non_nullable
as String,googlePlay: null == googlePlay ? _self.googlePlay : googlePlay // ignore: cast_nullable_to_non_nullable
as GooglePlayConfig,
  ));
}

/// Create a copy of AndroidConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GooglePlayConfigCopyWith<$Res> get googlePlay {
  
  return $GooglePlayConfigCopyWith<$Res>(_self.googlePlay, (value) {
    return _then(_self.copyWith(googlePlay: value));
  });
}
}

// dart format on
