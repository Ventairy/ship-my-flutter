// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hooks_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HooksConfig {

 String? get beforeReleasePr; String? get beforeCandidate;
/// Create a copy of HooksConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HooksConfigCopyWith<HooksConfig> get copyWith => _$HooksConfigCopyWithImpl<HooksConfig>(this as HooksConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HooksConfig&&(identical(other.beforeReleasePr, beforeReleasePr) || other.beforeReleasePr == beforeReleasePr)&&(identical(other.beforeCandidate, beforeCandidate) || other.beforeCandidate == beforeCandidate));
}


@override
int get hashCode => Object.hash(runtimeType,beforeReleasePr,beforeCandidate);

@override
String toString() {
  return 'HooksConfig(beforeReleasePr: $beforeReleasePr, beforeCandidate: $beforeCandidate)';
}


}

/// @nodoc
abstract mixin class $HooksConfigCopyWith<$Res>  {
  factory $HooksConfigCopyWith(HooksConfig value, $Res Function(HooksConfig) _then) = _$HooksConfigCopyWithImpl;
@useResult
$Res call({
 String? beforeReleasePr, String? beforeCandidate
});




}
/// @nodoc
class _$HooksConfigCopyWithImpl<$Res>
    implements $HooksConfigCopyWith<$Res> {
  _$HooksConfigCopyWithImpl(this._self, this._then);

  final HooksConfig _self;
  final $Res Function(HooksConfig) _then;

/// Create a copy of HooksConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? beforeReleasePr = freezed,Object? beforeCandidate = freezed,}) {
  return _then(_self.copyWith(
beforeReleasePr: freezed == beforeReleasePr ? _self.beforeReleasePr : beforeReleasePr // ignore: cast_nullable_to_non_nullable
as String?,beforeCandidate: freezed == beforeCandidate ? _self.beforeCandidate : beforeCandidate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HooksConfig].
extension HooksConfigPatterns on HooksConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HooksConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HooksConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HooksConfig value)  $default,){
final _that = this;
switch (_that) {
case _HooksConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HooksConfig value)?  $default,){
final _that = this;
switch (_that) {
case _HooksConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? beforeReleasePr,  String? beforeCandidate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HooksConfig() when $default != null:
return $default(_that.beforeReleasePr,_that.beforeCandidate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? beforeReleasePr,  String? beforeCandidate)  $default,) {final _that = this;
switch (_that) {
case _HooksConfig():
return $default(_that.beforeReleasePr,_that.beforeCandidate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? beforeReleasePr,  String? beforeCandidate)?  $default,) {final _that = this;
switch (_that) {
case _HooksConfig() when $default != null:
return $default(_that.beforeReleasePr,_that.beforeCandidate);case _:
  return null;

}
}

}

/// @nodoc


class _HooksConfig implements HooksConfig {
  const _HooksConfig({this.beforeReleasePr, this.beforeCandidate});
  

@override final  String? beforeReleasePr;
@override final  String? beforeCandidate;

/// Create a copy of HooksConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HooksConfigCopyWith<_HooksConfig> get copyWith => __$HooksConfigCopyWithImpl<_HooksConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HooksConfig&&(identical(other.beforeReleasePr, beforeReleasePr) || other.beforeReleasePr == beforeReleasePr)&&(identical(other.beforeCandidate, beforeCandidate) || other.beforeCandidate == beforeCandidate));
}


@override
int get hashCode => Object.hash(runtimeType,beforeReleasePr,beforeCandidate);

@override
String toString() {
  return 'HooksConfig(beforeReleasePr: $beforeReleasePr, beforeCandidate: $beforeCandidate)';
}


}

/// @nodoc
abstract mixin class _$HooksConfigCopyWith<$Res> implements $HooksConfigCopyWith<$Res> {
  factory _$HooksConfigCopyWith(_HooksConfig value, $Res Function(_HooksConfig) _then) = __$HooksConfigCopyWithImpl;
@override @useResult
$Res call({
 String? beforeReleasePr, String? beforeCandidate
});




}
/// @nodoc
class __$HooksConfigCopyWithImpl<$Res>
    implements _$HooksConfigCopyWith<$Res> {
  __$HooksConfigCopyWithImpl(this._self, this._then);

  final _HooksConfig _self;
  final $Res Function(_HooksConfig) _then;

/// Create a copy of HooksConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? beforeReleasePr = freezed,Object? beforeCandidate = freezed,}) {
  return _then(_HooksConfig(
beforeReleasePr: freezed == beforeReleasePr ? _self.beforeReleasePr : beforeReleasePr // ignore: cast_nullable_to_non_nullable
as String?,beforeCandidate: freezed == beforeCandidate ? _self.beforeCandidate : beforeCandidate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
