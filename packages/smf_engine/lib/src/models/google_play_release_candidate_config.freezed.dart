// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_play_release_candidate_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GooglePlayReleaseCandidateConfig {

 GooglePlayReleaseCandidateTarget get target; List<String> get tracks;
/// Create a copy of GooglePlayReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GooglePlayReleaseCandidateConfigCopyWith<GooglePlayReleaseCandidateConfig> get copyWith => _$GooglePlayReleaseCandidateConfigCopyWithImpl<GooglePlayReleaseCandidateConfig>(this as GooglePlayReleaseCandidateConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GooglePlayReleaseCandidateConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.tracks, tracks));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(tracks));

@override
String toString() {
  return 'GooglePlayReleaseCandidateConfig(target: $target, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $GooglePlayReleaseCandidateConfigCopyWith<$Res>  {
  factory $GooglePlayReleaseCandidateConfigCopyWith(GooglePlayReleaseCandidateConfig value, $Res Function(GooglePlayReleaseCandidateConfig) _then) = _$GooglePlayReleaseCandidateConfigCopyWithImpl;
@useResult
$Res call({
 GooglePlayReleaseCandidateTarget target, List<String> tracks
});




}
/// @nodoc
class _$GooglePlayReleaseCandidateConfigCopyWithImpl<$Res>
    implements $GooglePlayReleaseCandidateConfigCopyWith<$Res> {
  _$GooglePlayReleaseCandidateConfigCopyWithImpl(this._self, this._then);

  final GooglePlayReleaseCandidateConfig _self;
  final $Res Function(GooglePlayReleaseCandidateConfig) _then;

/// Create a copy of GooglePlayReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? tracks = null,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as GooglePlayReleaseCandidateTarget,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GooglePlayReleaseCandidateConfig].
extension GooglePlayReleaseCandidateConfigPatterns on GooglePlayReleaseCandidateConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GooglePlayReleaseCandidateConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GooglePlayReleaseCandidateConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GooglePlayReleaseCandidateConfig value)  $default,){
final _that = this;
switch (_that) {
case _GooglePlayReleaseCandidateConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GooglePlayReleaseCandidateConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GooglePlayReleaseCandidateConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GooglePlayReleaseCandidateTarget target,  List<String> tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GooglePlayReleaseCandidateConfig() when $default != null:
return $default(_that.target,_that.tracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GooglePlayReleaseCandidateTarget target,  List<String> tracks)  $default,) {final _that = this;
switch (_that) {
case _GooglePlayReleaseCandidateConfig():
return $default(_that.target,_that.tracks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GooglePlayReleaseCandidateTarget target,  List<String> tracks)?  $default,) {final _that = this;
switch (_that) {
case _GooglePlayReleaseCandidateConfig() when $default != null:
return $default(_that.target,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc


class _GooglePlayReleaseCandidateConfig implements GooglePlayReleaseCandidateConfig {
  const _GooglePlayReleaseCandidateConfig({this.target = GooglePlayReleaseCandidateTarget.internalTesting, final  List<String> tracks = const <String>[]}): _tracks = tracks;
  

@override@JsonKey() final  GooglePlayReleaseCandidateTarget target;
 final  List<String> _tracks;
@override@JsonKey() List<String> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}


/// Create a copy of GooglePlayReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GooglePlayReleaseCandidateConfigCopyWith<_GooglePlayReleaseCandidateConfig> get copyWith => __$GooglePlayReleaseCandidateConfigCopyWithImpl<_GooglePlayReleaseCandidateConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GooglePlayReleaseCandidateConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._tracks, _tracks));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(_tracks));

@override
String toString() {
  return 'GooglePlayReleaseCandidateConfig(target: $target, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$GooglePlayReleaseCandidateConfigCopyWith<$Res> implements $GooglePlayReleaseCandidateConfigCopyWith<$Res> {
  factory _$GooglePlayReleaseCandidateConfigCopyWith(_GooglePlayReleaseCandidateConfig value, $Res Function(_GooglePlayReleaseCandidateConfig) _then) = __$GooglePlayReleaseCandidateConfigCopyWithImpl;
@override @useResult
$Res call({
 GooglePlayReleaseCandidateTarget target, List<String> tracks
});




}
/// @nodoc
class __$GooglePlayReleaseCandidateConfigCopyWithImpl<$Res>
    implements _$GooglePlayReleaseCandidateConfigCopyWith<$Res> {
  __$GooglePlayReleaseCandidateConfigCopyWithImpl(this._self, this._then);

  final _GooglePlayReleaseCandidateConfig _self;
  final $Res Function(_GooglePlayReleaseCandidateConfig) _then;

/// Create a copy of GooglePlayReleaseCandidateConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? tracks = null,}) {
  return _then(_GooglePlayReleaseCandidateConfig(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as GooglePlayReleaseCandidateTarget,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
