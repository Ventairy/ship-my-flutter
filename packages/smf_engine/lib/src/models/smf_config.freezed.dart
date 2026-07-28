// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smf_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SmfConfig {

 String get appId; IosConfig get ios; AndroidConfig get android; int get schemaVersion; String? get flavor; String get targetBranch; List<String> get releaseTriggerPaths;
/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SmfConfigCopyWith<SmfConfig> get copyWith => _$SmfConfigCopyWithImpl<SmfConfig>(this as SmfConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmfConfig&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.flavor, flavor) || other.flavor == flavor)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&const DeepCollectionEquality().equals(other.releaseTriggerPaths, releaseTriggerPaths));
}


@override
int get hashCode => Object.hash(runtimeType,appId,ios,android,schemaVersion,flavor,targetBranch,const DeepCollectionEquality().hash(releaseTriggerPaths));

@override
String toString() {
  return 'SmfConfig(appId: $appId, ios: $ios, android: $android, schemaVersion: $schemaVersion, flavor: $flavor, targetBranch: $targetBranch, releaseTriggerPaths: $releaseTriggerPaths)';
}


}

/// @nodoc
abstract mixin class $SmfConfigCopyWith<$Res>  {
  factory $SmfConfigCopyWith(SmfConfig value, $Res Function(SmfConfig) _then) = _$SmfConfigCopyWithImpl;
@useResult
$Res call({
 String appId, IosConfig ios, AndroidConfig android, int schemaVersion, String? flavor, String targetBranch, List<String> releaseTriggerPaths
});


$IosConfigCopyWith<$Res> get ios;$AndroidConfigCopyWith<$Res> get android;

}
/// @nodoc
class _$SmfConfigCopyWithImpl<$Res>
    implements $SmfConfigCopyWith<$Res> {
  _$SmfConfigCopyWithImpl(this._self, this._then);

  final SmfConfig _self;
  final $Res Function(SmfConfig) _then;

/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? ios = null,Object? android = null,Object? schemaVersion = null,Object? flavor = freezed,Object? targetBranch = null,Object? releaseTriggerPaths = null,}) {
  return _then(_self.copyWith(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as IosConfig,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as AndroidConfig,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,flavor: freezed == flavor ? _self.flavor : flavor // ignore: cast_nullable_to_non_nullable
as String?,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,releaseTriggerPaths: null == releaseTriggerPaths ? _self.releaseTriggerPaths : releaseTriggerPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IosConfigCopyWith<$Res> get ios {
  
  return $IosConfigCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AndroidConfigCopyWith<$Res> get android {
  
  return $AndroidConfigCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}


/// Adds pattern-matching-related methods to [SmfConfig].
extension SmfConfigPatterns on SmfConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SmfConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SmfConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SmfConfig value)  $default,){
final _that = this;
switch (_that) {
case _SmfConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SmfConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SmfConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appId,  IosConfig ios,  AndroidConfig android,  int schemaVersion,  String? flavor,  String targetBranch,  List<String> releaseTriggerPaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SmfConfig() when $default != null:
return $default(_that.appId,_that.ios,_that.android,_that.schemaVersion,_that.flavor,_that.targetBranch,_that.releaseTriggerPaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appId,  IosConfig ios,  AndroidConfig android,  int schemaVersion,  String? flavor,  String targetBranch,  List<String> releaseTriggerPaths)  $default,) {final _that = this;
switch (_that) {
case _SmfConfig():
return $default(_that.appId,_that.ios,_that.android,_that.schemaVersion,_that.flavor,_that.targetBranch,_that.releaseTriggerPaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appId,  IosConfig ios,  AndroidConfig android,  int schemaVersion,  String? flavor,  String targetBranch,  List<String> releaseTriggerPaths)?  $default,) {final _that = this;
switch (_that) {
case _SmfConfig() when $default != null:
return $default(_that.appId,_that.ios,_that.android,_that.schemaVersion,_that.flavor,_that.targetBranch,_that.releaseTriggerPaths);case _:
  return null;

}
}

}

/// @nodoc


class _SmfConfig extends SmfConfig {
  const _SmfConfig({required this.appId, this.ios = const IosConfig(enabled: false), this.android = const AndroidConfig(), this.schemaVersion = 3, this.flavor, this.targetBranch = 'main', final  List<String> releaseTriggerPaths = const <String>[]}): _releaseTriggerPaths = releaseTriggerPaths,super._();
  

@override final  String appId;
@override@JsonKey() final  IosConfig ios;
@override@JsonKey() final  AndroidConfig android;
@override@JsonKey() final  int schemaVersion;
@override final  String? flavor;
@override@JsonKey() final  String targetBranch;
 final  List<String> _releaseTriggerPaths;
@override@JsonKey() List<String> get releaseTriggerPaths {
  if (_releaseTriggerPaths is EqualUnmodifiableListView) return _releaseTriggerPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_releaseTriggerPaths);
}


/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SmfConfigCopyWith<_SmfConfig> get copyWith => __$SmfConfigCopyWithImpl<_SmfConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SmfConfig&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.flavor, flavor) || other.flavor == flavor)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&const DeepCollectionEquality().equals(other._releaseTriggerPaths, _releaseTriggerPaths));
}


@override
int get hashCode => Object.hash(runtimeType,appId,ios,android,schemaVersion,flavor,targetBranch,const DeepCollectionEquality().hash(_releaseTriggerPaths));

@override
String toString() {
  return 'SmfConfig(appId: $appId, ios: $ios, android: $android, schemaVersion: $schemaVersion, flavor: $flavor, targetBranch: $targetBranch, releaseTriggerPaths: $releaseTriggerPaths)';
}


}

/// @nodoc
abstract mixin class _$SmfConfigCopyWith<$Res> implements $SmfConfigCopyWith<$Res> {
  factory _$SmfConfigCopyWith(_SmfConfig value, $Res Function(_SmfConfig) _then) = __$SmfConfigCopyWithImpl;
@override @useResult
$Res call({
 String appId, IosConfig ios, AndroidConfig android, int schemaVersion, String? flavor, String targetBranch, List<String> releaseTriggerPaths
});


@override $IosConfigCopyWith<$Res> get ios;@override $AndroidConfigCopyWith<$Res> get android;

}
/// @nodoc
class __$SmfConfigCopyWithImpl<$Res>
    implements _$SmfConfigCopyWith<$Res> {
  __$SmfConfigCopyWithImpl(this._self, this._then);

  final _SmfConfig _self;
  final $Res Function(_SmfConfig) _then;

/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appId = null,Object? ios = null,Object? android = null,Object? schemaVersion = null,Object? flavor = freezed,Object? targetBranch = null,Object? releaseTriggerPaths = null,}) {
  return _then(_SmfConfig(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as IosConfig,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as AndroidConfig,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,flavor: freezed == flavor ? _self.flavor : flavor // ignore: cast_nullable_to_non_nullable
as String?,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,releaseTriggerPaths: null == releaseTriggerPaths ? _self._releaseTriggerPaths : releaseTriggerPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IosConfigCopyWith<$Res> get ios {
  
  return $IosConfigCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AndroidConfigCopyWith<$Res> get android {
  
  return $AndroidConfigCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}

// dart format on
