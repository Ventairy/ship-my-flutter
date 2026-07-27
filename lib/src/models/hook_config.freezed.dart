// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hook_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HookConfig {

 String get run; bool get commit;
/// Create a copy of HookConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HookConfigCopyWith<HookConfig> get copyWith => _$HookConfigCopyWithImpl<HookConfig>(this as HookConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HookConfig&&(identical(other.run, run) || other.run == run)&&(identical(other.commit, commit) || other.commit == commit));
}


@override
int get hashCode => Object.hash(runtimeType,run,commit);

@override
String toString() {
  return 'HookConfig(run: $run, commit: $commit)';
}


}

/// @nodoc
abstract mixin class $HookConfigCopyWith<$Res>  {
  factory $HookConfigCopyWith(HookConfig value, $Res Function(HookConfig) _then) = _$HookConfigCopyWithImpl;
@useResult
$Res call({
 String run, bool commit
});




}
/// @nodoc
class _$HookConfigCopyWithImpl<$Res>
    implements $HookConfigCopyWith<$Res> {
  _$HookConfigCopyWithImpl(this._self, this._then);

  final HookConfig _self;
  final $Res Function(HookConfig) _then;

/// Create a copy of HookConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? run = null,Object? commit = null,}) {
  return _then(_self.copyWith(
run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as String,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HookConfig].
extension HookConfigPatterns on HookConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HookConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HookConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HookConfig value)  $default,){
final _that = this;
switch (_that) {
case _HookConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HookConfig value)?  $default,){
final _that = this;
switch (_that) {
case _HookConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String run,  bool commit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HookConfig() when $default != null:
return $default(_that.run,_that.commit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String run,  bool commit)  $default,) {final _that = this;
switch (_that) {
case _HookConfig():
return $default(_that.run,_that.commit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String run,  bool commit)?  $default,) {final _that = this;
switch (_that) {
case _HookConfig() when $default != null:
return $default(_that.run,_that.commit);case _:
  return null;

}
}

}

/// @nodoc


class _HookConfig implements HookConfig {
  const _HookConfig({required this.run, this.commit = true});
  

@override final  String run;
@override@JsonKey() final  bool commit;

/// Create a copy of HookConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HookConfigCopyWith<_HookConfig> get copyWith => __$HookConfigCopyWithImpl<_HookConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HookConfig&&(identical(other.run, run) || other.run == run)&&(identical(other.commit, commit) || other.commit == commit));
}


@override
int get hashCode => Object.hash(runtimeType,run,commit);

@override
String toString() {
  return 'HookConfig(run: $run, commit: $commit)';
}


}

/// @nodoc
abstract mixin class _$HookConfigCopyWith<$Res> implements $HookConfigCopyWith<$Res> {
  factory _$HookConfigCopyWith(_HookConfig value, $Res Function(_HookConfig) _then) = __$HookConfigCopyWithImpl;
@override @useResult
$Res call({
 String run, bool commit
});




}
/// @nodoc
class __$HookConfigCopyWithImpl<$Res>
    implements _$HookConfigCopyWith<$Res> {
  __$HookConfigCopyWithImpl(this._self, this._then);

  final _HookConfig _self;
  final $Res Function(_HookConfig) _then;

/// Create a copy of HookConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? run = null,Object? commit = null,}) {
  return _then(_HookConfig(
run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as String,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
