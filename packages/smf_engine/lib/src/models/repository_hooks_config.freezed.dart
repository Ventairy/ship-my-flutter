// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository_hooks_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RepositoryHooksConfig {

 List<String> get beforeCreatePullRequestSecrets; List<String> get beforeBuildSecrets;
/// Create a copy of RepositoryHooksConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepositoryHooksConfigCopyWith<RepositoryHooksConfig> get copyWith => _$RepositoryHooksConfigCopyWithImpl<RepositoryHooksConfig>(this as RepositoryHooksConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepositoryHooksConfig&&const DeepCollectionEquality().equals(other.beforeCreatePullRequestSecrets, beforeCreatePullRequestSecrets)&&const DeepCollectionEquality().equals(other.beforeBuildSecrets, beforeBuildSecrets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(beforeCreatePullRequestSecrets),const DeepCollectionEquality().hash(beforeBuildSecrets));

@override
String toString() {
  return 'RepositoryHooksConfig(beforeCreatePullRequestSecrets: $beforeCreatePullRequestSecrets, beforeBuildSecrets: $beforeBuildSecrets)';
}


}

/// @nodoc
abstract mixin class $RepositoryHooksConfigCopyWith<$Res>  {
  factory $RepositoryHooksConfigCopyWith(RepositoryHooksConfig value, $Res Function(RepositoryHooksConfig) _then) = _$RepositoryHooksConfigCopyWithImpl;
@useResult
$Res call({
 List<String> beforeCreatePullRequestSecrets, List<String> beforeBuildSecrets
});




}
/// @nodoc
class _$RepositoryHooksConfigCopyWithImpl<$Res>
    implements $RepositoryHooksConfigCopyWith<$Res> {
  _$RepositoryHooksConfigCopyWithImpl(this._self, this._then);

  final RepositoryHooksConfig _self;
  final $Res Function(RepositoryHooksConfig) _then;

/// Create a copy of RepositoryHooksConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? beforeCreatePullRequestSecrets = null,Object? beforeBuildSecrets = null,}) {
  return _then(_self.copyWith(
beforeCreatePullRequestSecrets: null == beforeCreatePullRequestSecrets ? _self.beforeCreatePullRequestSecrets : beforeCreatePullRequestSecrets // ignore: cast_nullable_to_non_nullable
as List<String>,beforeBuildSecrets: null == beforeBuildSecrets ? _self.beforeBuildSecrets : beforeBuildSecrets // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RepositoryHooksConfig].
extension RepositoryHooksConfigPatterns on RepositoryHooksConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepositoryHooksConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepositoryHooksConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepositoryHooksConfig value)  $default,){
final _that = this;
switch (_that) {
case _RepositoryHooksConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepositoryHooksConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RepositoryHooksConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> beforeCreatePullRequestSecrets,  List<String> beforeBuildSecrets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepositoryHooksConfig() when $default != null:
return $default(_that.beforeCreatePullRequestSecrets,_that.beforeBuildSecrets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> beforeCreatePullRequestSecrets,  List<String> beforeBuildSecrets)  $default,) {final _that = this;
switch (_that) {
case _RepositoryHooksConfig():
return $default(_that.beforeCreatePullRequestSecrets,_that.beforeBuildSecrets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> beforeCreatePullRequestSecrets,  List<String> beforeBuildSecrets)?  $default,) {final _that = this;
switch (_that) {
case _RepositoryHooksConfig() when $default != null:
return $default(_that.beforeCreatePullRequestSecrets,_that.beforeBuildSecrets);case _:
  return null;

}
}

}

/// @nodoc


class _RepositoryHooksConfig implements RepositoryHooksConfig {
  const _RepositoryHooksConfig({final  List<String> beforeCreatePullRequestSecrets = const <String>[], final  List<String> beforeBuildSecrets = const <String>[]}): _beforeCreatePullRequestSecrets = beforeCreatePullRequestSecrets,_beforeBuildSecrets = beforeBuildSecrets;
  

 final  List<String> _beforeCreatePullRequestSecrets;
@override@JsonKey() List<String> get beforeCreatePullRequestSecrets {
  if (_beforeCreatePullRequestSecrets is EqualUnmodifiableListView) return _beforeCreatePullRequestSecrets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beforeCreatePullRequestSecrets);
}

 final  List<String> _beforeBuildSecrets;
@override@JsonKey() List<String> get beforeBuildSecrets {
  if (_beforeBuildSecrets is EqualUnmodifiableListView) return _beforeBuildSecrets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beforeBuildSecrets);
}


/// Create a copy of RepositoryHooksConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepositoryHooksConfigCopyWith<_RepositoryHooksConfig> get copyWith => __$RepositoryHooksConfigCopyWithImpl<_RepositoryHooksConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepositoryHooksConfig&&const DeepCollectionEquality().equals(other._beforeCreatePullRequestSecrets, _beforeCreatePullRequestSecrets)&&const DeepCollectionEquality().equals(other._beforeBuildSecrets, _beforeBuildSecrets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_beforeCreatePullRequestSecrets),const DeepCollectionEquality().hash(_beforeBuildSecrets));

@override
String toString() {
  return 'RepositoryHooksConfig(beforeCreatePullRequestSecrets: $beforeCreatePullRequestSecrets, beforeBuildSecrets: $beforeBuildSecrets)';
}


}

/// @nodoc
abstract mixin class _$RepositoryHooksConfigCopyWith<$Res> implements $RepositoryHooksConfigCopyWith<$Res> {
  factory _$RepositoryHooksConfigCopyWith(_RepositoryHooksConfig value, $Res Function(_RepositoryHooksConfig) _then) = __$RepositoryHooksConfigCopyWithImpl;
@override @useResult
$Res call({
 List<String> beforeCreatePullRequestSecrets, List<String> beforeBuildSecrets
});




}
/// @nodoc
class __$RepositoryHooksConfigCopyWithImpl<$Res>
    implements _$RepositoryHooksConfigCopyWith<$Res> {
  __$RepositoryHooksConfigCopyWithImpl(this._self, this._then);

  final _RepositoryHooksConfig _self;
  final $Res Function(_RepositoryHooksConfig) _then;

/// Create a copy of RepositoryHooksConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? beforeCreatePullRequestSecrets = null,Object? beforeBuildSecrets = null,}) {
  return _then(_RepositoryHooksConfig(
beforeCreatePullRequestSecrets: null == beforeCreatePullRequestSecrets ? _self._beforeCreatePullRequestSecrets : beforeCreatePullRequestSecrets // ignore: cast_nullable_to_non_nullable
as List<String>,beforeBuildSecrets: null == beforeBuildSecrets ? _self._beforeBuildSecrets : beforeBuildSecrets // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
