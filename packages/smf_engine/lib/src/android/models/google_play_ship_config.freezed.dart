// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_play_ship_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GooglePlayShipConfig {

 GooglePlayShipTarget get target; List<String> get tracks;
/// Create a copy of GooglePlayShipConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GooglePlayShipConfigCopyWith<GooglePlayShipConfig> get copyWith => _$GooglePlayShipConfigCopyWithImpl<GooglePlayShipConfig>(this as GooglePlayShipConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GooglePlayShipConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.tracks, tracks));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(tracks));

@override
String toString() {
  return 'GooglePlayShipConfig(target: $target, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $GooglePlayShipConfigCopyWith<$Res>  {
  factory $GooglePlayShipConfigCopyWith(GooglePlayShipConfig value, $Res Function(GooglePlayShipConfig) _then) = _$GooglePlayShipConfigCopyWithImpl;
@useResult
$Res call({
 GooglePlayShipTarget target, List<String> tracks
});




}
/// @nodoc
class _$GooglePlayShipConfigCopyWithImpl<$Res>
    implements $GooglePlayShipConfigCopyWith<$Res> {
  _$GooglePlayShipConfigCopyWithImpl(this._self, this._then);

  final GooglePlayShipConfig _self;
  final $Res Function(GooglePlayShipConfig) _then;

/// Create a copy of GooglePlayShipConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? tracks = null,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as GooglePlayShipTarget,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GooglePlayShipConfig].
extension GooglePlayShipConfigPatterns on GooglePlayShipConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GooglePlayShipConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GooglePlayShipConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GooglePlayShipConfig value)  $default,){
final _that = this;
switch (_that) {
case _GooglePlayShipConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GooglePlayShipConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GooglePlayShipConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GooglePlayShipTarget target,  List<String> tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GooglePlayShipConfig() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GooglePlayShipTarget target,  List<String> tracks)  $default,) {final _that = this;
switch (_that) {
case _GooglePlayShipConfig():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GooglePlayShipTarget target,  List<String> tracks)?  $default,) {final _that = this;
switch (_that) {
case _GooglePlayShipConfig() when $default != null:
return $default(_that.target,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc


class _GooglePlayShipConfig implements GooglePlayShipConfig {
  const _GooglePlayShipConfig({required this.target, final  List<String> tracks = const <String>[]}): _tracks = tracks;
  

@override final  GooglePlayShipTarget target;
 final  List<String> _tracks;
@override@JsonKey() List<String> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}


/// Create a copy of GooglePlayShipConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GooglePlayShipConfigCopyWith<_GooglePlayShipConfig> get copyWith => __$GooglePlayShipConfigCopyWithImpl<_GooglePlayShipConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GooglePlayShipConfig&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._tracks, _tracks));
}


@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(_tracks));

@override
String toString() {
  return 'GooglePlayShipConfig(target: $target, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$GooglePlayShipConfigCopyWith<$Res> implements $GooglePlayShipConfigCopyWith<$Res> {
  factory _$GooglePlayShipConfigCopyWith(_GooglePlayShipConfig value, $Res Function(_GooglePlayShipConfig) _then) = __$GooglePlayShipConfigCopyWithImpl;
@override @useResult
$Res call({
 GooglePlayShipTarget target, List<String> tracks
});




}
/// @nodoc
class __$GooglePlayShipConfigCopyWithImpl<$Res>
    implements _$GooglePlayShipConfigCopyWith<$Res> {
  __$GooglePlayShipConfigCopyWithImpl(this._self, this._then);

  final _GooglePlayShipConfig _self;
  final $Res Function(_GooglePlayShipConfig) _then;

/// Create a copy of GooglePlayShipConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? tracks = null,}) {
  return _then(_GooglePlayShipConfig(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as GooglePlayShipTarget,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
