// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ship_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShipConfig {

 int get schemaVersion; String get targetBranch; String get releaseBranchPrefix; HooksConfig get hooks; IosConfig get ios;
/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipConfigCopyWith<ShipConfig> get copyWith => _$ShipConfigCopyWithImpl<ShipConfig>(this as ShipConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&(identical(other.releaseBranchPrefix, releaseBranchPrefix) || other.releaseBranchPrefix == releaseBranchPrefix)&&(identical(other.hooks, hooks) || other.hooks == hooks)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,targetBranch,releaseBranchPrefix,hooks,ios);

@override
String toString() {
  return 'ShipConfig(schemaVersion: $schemaVersion, targetBranch: $targetBranch, releaseBranchPrefix: $releaseBranchPrefix, hooks: $hooks, ios: $ios)';
}


}

/// @nodoc
abstract mixin class $ShipConfigCopyWith<$Res>  {
  factory $ShipConfigCopyWith(ShipConfig value, $Res Function(ShipConfig) _then) = _$ShipConfigCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String targetBranch, String releaseBranchPrefix, HooksConfig hooks, IosConfig ios
});


$HooksConfigCopyWith<$Res> get hooks;$IosConfigCopyWith<$Res> get ios;

}
/// @nodoc
class _$ShipConfigCopyWithImpl<$Res>
    implements $ShipConfigCopyWith<$Res> {
  _$ShipConfigCopyWithImpl(this._self, this._then);

  final ShipConfig _self;
  final $Res Function(ShipConfig) _then;

/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? targetBranch = null,Object? releaseBranchPrefix = null,Object? hooks = null,Object? ios = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,releaseBranchPrefix: null == releaseBranchPrefix ? _self.releaseBranchPrefix : releaseBranchPrefix // ignore: cast_nullable_to_non_nullable
as String,hooks: null == hooks ? _self.hooks : hooks // ignore: cast_nullable_to_non_nullable
as HooksConfig,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as IosConfig,
  ));
}
/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HooksConfigCopyWith<$Res> get hooks {
  
  return $HooksConfigCopyWith<$Res>(_self.hooks, (value) {
    return _then(_self.copyWith(hooks: value));
  });
}/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IosConfigCopyWith<$Res> get ios {
  
  return $IosConfigCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShipConfig].
extension ShipConfigPatterns on ShipConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipConfig value)  $default,){
final _that = this;
switch (_that) {
case _ShipConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ShipConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String targetBranch,  String releaseBranchPrefix,  HooksConfig hooks,  IosConfig ios)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipConfig() when $default != null:
return $default(_that.schemaVersion,_that.targetBranch,_that.releaseBranchPrefix,_that.hooks,_that.ios);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String targetBranch,  String releaseBranchPrefix,  HooksConfig hooks,  IosConfig ios)  $default,) {final _that = this;
switch (_that) {
case _ShipConfig():
return $default(_that.schemaVersion,_that.targetBranch,_that.releaseBranchPrefix,_that.hooks,_that.ios);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String targetBranch,  String releaseBranchPrefix,  HooksConfig hooks,  IosConfig ios)?  $default,) {final _that = this;
switch (_that) {
case _ShipConfig() when $default != null:
return $default(_that.schemaVersion,_that.targetBranch,_that.releaseBranchPrefix,_that.hooks,_that.ios);case _:
  return null;

}
}

}

/// @nodoc


class _ShipConfig implements ShipConfig {
  const _ShipConfig({this.schemaVersion = 1, this.targetBranch = 'main', this.releaseBranchPrefix = 'ship-my-flutter', this.hooks = const HooksConfig(), required this.ios});
  

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  String targetBranch;
@override@JsonKey() final  String releaseBranchPrefix;
@override@JsonKey() final  HooksConfig hooks;
@override final  IosConfig ios;

/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipConfigCopyWith<_ShipConfig> get copyWith => __$ShipConfigCopyWithImpl<_ShipConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&(identical(other.releaseBranchPrefix, releaseBranchPrefix) || other.releaseBranchPrefix == releaseBranchPrefix)&&(identical(other.hooks, hooks) || other.hooks == hooks)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,targetBranch,releaseBranchPrefix,hooks,ios);

@override
String toString() {
  return 'ShipConfig(schemaVersion: $schemaVersion, targetBranch: $targetBranch, releaseBranchPrefix: $releaseBranchPrefix, hooks: $hooks, ios: $ios)';
}


}

/// @nodoc
abstract mixin class _$ShipConfigCopyWith<$Res> implements $ShipConfigCopyWith<$Res> {
  factory _$ShipConfigCopyWith(_ShipConfig value, $Res Function(_ShipConfig) _then) = __$ShipConfigCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String targetBranch, String releaseBranchPrefix, HooksConfig hooks, IosConfig ios
});


@override $HooksConfigCopyWith<$Res> get hooks;@override $IosConfigCopyWith<$Res> get ios;

}
/// @nodoc
class __$ShipConfigCopyWithImpl<$Res>
    implements _$ShipConfigCopyWith<$Res> {
  __$ShipConfigCopyWithImpl(this._self, this._then);

  final _ShipConfig _self;
  final $Res Function(_ShipConfig) _then;

/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? targetBranch = null,Object? releaseBranchPrefix = null,Object? hooks = null,Object? ios = null,}) {
  return _then(_ShipConfig(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,releaseBranchPrefix: null == releaseBranchPrefix ? _self.releaseBranchPrefix : releaseBranchPrefix // ignore: cast_nullable_to_non_nullable
as String,hooks: null == hooks ? _self.hooks : hooks // ignore: cast_nullable_to_non_nullable
as HooksConfig,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as IosConfig,
  ));
}

/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HooksConfigCopyWith<$Res> get hooks {
  
  return $HooksConfigCopyWith<$Res>(_self.hooks, (value) {
    return _then(_self.copyWith(hooks: value));
  });
}/// Create a copy of ShipConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IosConfigCopyWith<$Res> get ios {
  
  return $IosConfigCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}

// dart format on
