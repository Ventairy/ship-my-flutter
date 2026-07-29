// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apple_release_candidate_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppleReleaseCandidateConfig {

 AppleReleaseCandidateTarget get target; List<String> get groups; int get waitTimeoutMinutes;
/// Create a copy of AppleReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleReleaseCandidateConfigCopyWith<AppleReleaseCandidateConfig> get copyWith => _$AppleReleaseCandidateConfigCopyWithImpl<AppleReleaseCandidateConfig>(this as AppleReleaseCandidateConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleReleaseCandidateConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.waitTimeoutMinutes, waitTimeoutMinutes) || other.waitTimeoutMinutes == waitTimeoutMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(groups),waitTimeoutMinutes);

@override
String toString() {
  return 'AppleReleaseCandidateConfig(target: $target, groups: $groups, waitTimeoutMinutes: $waitTimeoutMinutes)';
}


}

/// @nodoc
abstract mixin class $AppleReleaseCandidateConfigCopyWith<$Res>  {
  factory $AppleReleaseCandidateConfigCopyWith(AppleReleaseCandidateConfig value, $Res Function(AppleReleaseCandidateConfig) _then) = _$AppleReleaseCandidateConfigCopyWithImpl;
@useResult
$Res call({
 AppleReleaseCandidateTarget target, List<String> groups, int waitTimeoutMinutes
});




}
/// @nodoc
class _$AppleReleaseCandidateConfigCopyWithImpl<$Res>
    implements $AppleReleaseCandidateConfigCopyWith<$Res> {
  _$AppleReleaseCandidateConfigCopyWithImpl(this._self, this._then);

  final AppleReleaseCandidateConfig _self;
  final $Res Function(AppleReleaseCandidateConfig) _then;

/// Create a copy of AppleReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? groups = null,Object? waitTimeoutMinutes = null,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as AppleReleaseCandidateTarget,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,waitTimeoutMinutes: null == waitTimeoutMinutes ? _self.waitTimeoutMinutes : waitTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleReleaseCandidateConfig].
extension AppleReleaseCandidateConfigPatterns on AppleReleaseCandidateConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleReleaseCandidateConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleReleaseCandidateConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleReleaseCandidateConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppleReleaseCandidateConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleReleaseCandidateConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppleReleaseCandidateConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppleReleaseCandidateTarget target,  List<String> groups,  int waitTimeoutMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleReleaseCandidateConfig() when $default != null:
return $default(_that.target,_that.groups,_that.waitTimeoutMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppleReleaseCandidateTarget target,  List<String> groups,  int waitTimeoutMinutes)  $default,) {final _that = this;
switch (_that) {
case _AppleReleaseCandidateConfig():
return $default(_that.target,_that.groups,_that.waitTimeoutMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppleReleaseCandidateTarget target,  List<String> groups,  int waitTimeoutMinutes)?  $default,) {final _that = this;
switch (_that) {
case _AppleReleaseCandidateConfig() when $default != null:
return $default(_that.target,_that.groups,_that.waitTimeoutMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _AppleReleaseCandidateConfig implements AppleReleaseCandidateConfig {
  const _AppleReleaseCandidateConfig({this.target = AppleReleaseCandidateTarget.internalTesting, final  List<String> groups = const <String>[], this.waitTimeoutMinutes = 45}): _groups = groups;
  

@override@JsonKey() final  AppleReleaseCandidateTarget target;
 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  int waitTimeoutMinutes;

/// Create a copy of AppleReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleReleaseCandidateConfigCopyWith<_AppleReleaseCandidateConfig> get copyWith => __$AppleReleaseCandidateConfigCopyWithImpl<_AppleReleaseCandidateConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleReleaseCandidateConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.waitTimeoutMinutes, waitTimeoutMinutes) || other.waitTimeoutMinutes == waitTimeoutMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(_groups),waitTimeoutMinutes);

@override
String toString() {
  return 'AppleReleaseCandidateConfig(target: $target, groups: $groups, waitTimeoutMinutes: $waitTimeoutMinutes)';
}


}

/// @nodoc
abstract mixin class _$AppleReleaseCandidateConfigCopyWith<$Res> implements $AppleReleaseCandidateConfigCopyWith<$Res> {
  factory _$AppleReleaseCandidateConfigCopyWith(_AppleReleaseCandidateConfig value, $Res Function(_AppleReleaseCandidateConfig) _then) = __$AppleReleaseCandidateConfigCopyWithImpl;
@override @useResult
$Res call({
 AppleReleaseCandidateTarget target, List<String> groups, int waitTimeoutMinutes
});




}
/// @nodoc
class __$AppleReleaseCandidateConfigCopyWithImpl<$Res>
    implements _$AppleReleaseCandidateConfigCopyWith<$Res> {
  __$AppleReleaseCandidateConfigCopyWithImpl(this._self, this._then);

  final _AppleReleaseCandidateConfig _self;
  final $Res Function(_AppleReleaseCandidateConfig) _then;

/// Create a copy of AppleReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? groups = null,Object? waitTimeoutMinutes = null,}) {
  return _then(_AppleReleaseCandidateConfig(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as AppleReleaseCandidateTarget,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,waitTimeoutMinutes: null == waitTimeoutMinutes ? _self.waitTimeoutMinutes : waitTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
