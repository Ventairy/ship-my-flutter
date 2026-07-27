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

 int get schemaVersion; String? get flavor; String get targetBranch; IosConfig get ios;
/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SmfConfigCopyWith<SmfConfig> get copyWith => _$SmfConfigCopyWithImpl<SmfConfig>(this as SmfConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmfConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.flavor, flavor) || other.flavor == flavor)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,flavor,targetBranch,ios);

@override
String toString() {
  return 'SmfConfig(schemaVersion: $schemaVersion, flavor: $flavor, targetBranch: $targetBranch, ios: $ios)';
}


}

/// @nodoc
abstract mixin class $SmfConfigCopyWith<$Res>  {
  factory $SmfConfigCopyWith(SmfConfig value, $Res Function(SmfConfig) _then) = _$SmfConfigCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String? flavor, String targetBranch, IosConfig ios
});


$IosConfigCopyWith<$Res> get ios;

}
/// @nodoc
class _$SmfConfigCopyWithImpl<$Res>
    implements $SmfConfigCopyWith<$Res> {
  _$SmfConfigCopyWithImpl(this._self, this._then);

  final SmfConfig _self;
  final $Res Function(SmfConfig) _then;

/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? flavor = freezed,Object? targetBranch = null,Object? ios = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,flavor: freezed == flavor ? _self.flavor : flavor // ignore: cast_nullable_to_non_nullable
as String?,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as IosConfig,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String? flavor,  String targetBranch,  IosConfig ios)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SmfConfig() when $default != null:
return $default(_that.schemaVersion,_that.flavor,_that.targetBranch,_that.ios);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String? flavor,  String targetBranch,  IosConfig ios)  $default,) {final _that = this;
switch (_that) {
case _SmfConfig():
return $default(_that.schemaVersion,_that.flavor,_that.targetBranch,_that.ios);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String? flavor,  String targetBranch,  IosConfig ios)?  $default,) {final _that = this;
switch (_that) {
case _SmfConfig() when $default != null:
return $default(_that.schemaVersion,_that.flavor,_that.targetBranch,_that.ios);case _:
  return null;

}
}

}

/// @nodoc


class _SmfConfig implements SmfConfig {
  const _SmfConfig({this.schemaVersion = 1, this.flavor, this.targetBranch = 'main', required this.ios});
  

@override@JsonKey() final  int schemaVersion;
@override final  String? flavor;
@override@JsonKey() final  String targetBranch;
@override final  IosConfig ios;

/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SmfConfigCopyWith<_SmfConfig> get copyWith => __$SmfConfigCopyWithImpl<_SmfConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SmfConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.flavor, flavor) || other.flavor == flavor)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,flavor,targetBranch,ios);

@override
String toString() {
  return 'SmfConfig(schemaVersion: $schemaVersion, flavor: $flavor, targetBranch: $targetBranch, ios: $ios)';
}


}

/// @nodoc
abstract mixin class _$SmfConfigCopyWith<$Res> implements $SmfConfigCopyWith<$Res> {
  factory _$SmfConfigCopyWith(_SmfConfig value, $Res Function(_SmfConfig) _then) = __$SmfConfigCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String? flavor, String targetBranch, IosConfig ios
});


@override $IosConfigCopyWith<$Res> get ios;

}
/// @nodoc
class __$SmfConfigCopyWithImpl<$Res>
    implements _$SmfConfigCopyWith<$Res> {
  __$SmfConfigCopyWithImpl(this._self, this._then);

  final _SmfConfig _self;
  final $Res Function(_SmfConfig) _then;

/// Create a copy of SmfConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? flavor = freezed,Object? targetBranch = null,Object? ios = null,}) {
  return _then(_SmfConfig(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,flavor: freezed == flavor ? _self.flavor : flavor // ignore: cast_nullable_to_non_nullable
as String?,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as IosConfig,
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
}
}

// dart format on
