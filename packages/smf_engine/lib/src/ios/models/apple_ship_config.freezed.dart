// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apple_ship_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppleShipConfig {

 AppleShipTarget get target; List<String> get groups;
/// Create a copy of AppleShipConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleShipConfigCopyWith<AppleShipConfig> get copyWith => _$AppleShipConfigCopyWithImpl<AppleShipConfig>(this as AppleShipConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleShipConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.groups, groups));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'AppleShipConfig(target: $target, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $AppleShipConfigCopyWith<$Res>  {
  factory $AppleShipConfigCopyWith(AppleShipConfig value, $Res Function(AppleShipConfig) _then) = _$AppleShipConfigCopyWithImpl;
@useResult
$Res call({
 AppleShipTarget target, List<String> groups
});




}
/// @nodoc
class _$AppleShipConfigCopyWithImpl<$Res>
    implements $AppleShipConfigCopyWith<$Res> {
  _$AppleShipConfigCopyWithImpl(this._self, this._then);

  final AppleShipConfig _self;
  final $Res Function(AppleShipConfig) _then;

/// Create a copy of AppleShipConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? groups = null,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as AppleShipTarget,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleShipConfig].
extension AppleShipConfigPatterns on AppleShipConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleShipConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleShipConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleShipConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppleShipConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleShipConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppleShipConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppleShipTarget target,  List<String> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleShipConfig() when $default != null:
return $default(_that.target,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppleShipTarget target,  List<String> groups)  $default,) {final _that = this;
switch (_that) {
case _AppleShipConfig():
return $default(_that.target,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppleShipTarget target,  List<String> groups)?  $default,) {final _that = this;
switch (_that) {
case _AppleShipConfig() when $default != null:
return $default(_that.target,_that.groups);case _:
  return null;

}
}

}

/// @nodoc


class _AppleShipConfig implements AppleShipConfig {
  const _AppleShipConfig({required this.target, final  List<String> groups = const <String>[]}): _groups = groups;
  

@override final  AppleShipTarget target;
 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of AppleShipConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleShipConfigCopyWith<_AppleShipConfig> get copyWith => __$AppleShipConfigCopyWithImpl<_AppleShipConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleShipConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._groups, _groups));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'AppleShipConfig(target: $target, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$AppleShipConfigCopyWith<$Res> implements $AppleShipConfigCopyWith<$Res> {
  factory _$AppleShipConfigCopyWith(_AppleShipConfig value, $Res Function(_AppleShipConfig) _then) = __$AppleShipConfigCopyWithImpl;
@override @useResult
$Res call({
 AppleShipTarget target, List<String> groups
});




}
/// @nodoc
class __$AppleShipConfigCopyWithImpl<$Res>
    implements _$AppleShipConfigCopyWith<$Res> {
  __$AppleShipConfigCopyWithImpl(this._self, this._then);

  final _AppleShipConfig _self;
  final $Res Function(_AppleShipConfig) _then;

/// Create a copy of AppleShipConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? groups = null,}) {
  return _then(_AppleShipConfig(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as AppleShipTarget,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
