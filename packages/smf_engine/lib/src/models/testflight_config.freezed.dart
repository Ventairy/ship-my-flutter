// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'testflight_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TestflightConfig {

 List<String> get groups; int get waitTimeoutMinutes;
/// Create a copy of TestflightConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestflightConfigCopyWith<TestflightConfig> get copyWith => _$TestflightConfigCopyWithImpl<TestflightConfig>(this as TestflightConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestflightConfig&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.waitTimeoutMinutes, waitTimeoutMinutes) || other.waitTimeoutMinutes == waitTimeoutMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),waitTimeoutMinutes);

@override
String toString() {
  return 'TestflightConfig(groups: $groups, waitTimeoutMinutes: $waitTimeoutMinutes)';
}


}

/// @nodoc
abstract mixin class $TestflightConfigCopyWith<$Res>  {
  factory $TestflightConfigCopyWith(TestflightConfig value, $Res Function(TestflightConfig) _then) = _$TestflightConfigCopyWithImpl;
@useResult
$Res call({
 List<String> groups, int waitTimeoutMinutes
});




}
/// @nodoc
class _$TestflightConfigCopyWithImpl<$Res>
    implements $TestflightConfigCopyWith<$Res> {
  _$TestflightConfigCopyWithImpl(this._self, this._then);

  final TestflightConfig _self;
  final $Res Function(TestflightConfig) _then;

/// Create a copy of TestflightConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? waitTimeoutMinutes = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,waitTimeoutMinutes: null == waitTimeoutMinutes ? _self.waitTimeoutMinutes : waitTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TestflightConfig].
extension TestflightConfigPatterns on TestflightConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestflightConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestflightConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestflightConfig value)  $default,){
final _that = this;
switch (_that) {
case _TestflightConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestflightConfig value)?  $default,){
final _that = this;
switch (_that) {
case _TestflightConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> groups,  int waitTimeoutMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestflightConfig() when $default != null:
return $default(_that.groups,_that.waitTimeoutMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> groups,  int waitTimeoutMinutes)  $default,) {final _that = this;
switch (_that) {
case _TestflightConfig():
return $default(_that.groups,_that.waitTimeoutMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> groups,  int waitTimeoutMinutes)?  $default,) {final _that = this;
switch (_that) {
case _TestflightConfig() when $default != null:
return $default(_that.groups,_that.waitTimeoutMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _TestflightConfig implements TestflightConfig {
  const _TestflightConfig({final  List<String> groups = const <String>[], this.waitTimeoutMinutes = 45}): _groups = groups;
  

 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  int waitTimeoutMinutes;

/// Create a copy of TestflightConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestflightConfigCopyWith<_TestflightConfig> get copyWith => __$TestflightConfigCopyWithImpl<_TestflightConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestflightConfig&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.waitTimeoutMinutes, waitTimeoutMinutes) || other.waitTimeoutMinutes == waitTimeoutMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),waitTimeoutMinutes);

@override
String toString() {
  return 'TestflightConfig(groups: $groups, waitTimeoutMinutes: $waitTimeoutMinutes)';
}


}

/// @nodoc
abstract mixin class _$TestflightConfigCopyWith<$Res> implements $TestflightConfigCopyWith<$Res> {
  factory _$TestflightConfigCopyWith(_TestflightConfig value, $Res Function(_TestflightConfig) _then) = __$TestflightConfigCopyWithImpl;
@override @useResult
$Res call({
 List<String> groups, int waitTimeoutMinutes
});




}
/// @nodoc
class __$TestflightConfigCopyWithImpl<$Res>
    implements _$TestflightConfigCopyWith<$Res> {
  __$TestflightConfigCopyWithImpl(this._self, this._then);

  final _TestflightConfig _self;
  final $Res Function(_TestflightConfig) _then;

/// Create a copy of TestflightConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? waitTimeoutMinutes = null,}) {
  return _then(_TestflightConfig(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,waitTimeoutMinutes: null == waitTimeoutMinutes ? _self.waitTimeoutMinutes : waitTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
