// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_play_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GooglePlayConfig {

 GooglePlayReleaseCandidateConfig get releaseCandidate; GooglePlayShipConfig? get ship;
/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GooglePlayConfigCopyWith<GooglePlayConfig> get copyWith => _$GooglePlayConfigCopyWithImpl<GooglePlayConfig>(this as GooglePlayConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GooglePlayConfig&&(identical(other.releaseCandidate, releaseCandidate) || other.releaseCandidate == releaseCandidate)&&(identical(other.ship, ship) || other.ship == ship));
}


@override
int get hashCode => Object.hash(runtimeType,releaseCandidate,ship);

@override
String toString() {
  return 'GooglePlayConfig(releaseCandidate: $releaseCandidate, ship: $ship)';
}


}

/// @nodoc
abstract mixin class $GooglePlayConfigCopyWith<$Res>  {
  factory $GooglePlayConfigCopyWith(GooglePlayConfig value, $Res Function(GooglePlayConfig) _then) = _$GooglePlayConfigCopyWithImpl;
@useResult
$Res call({
 GooglePlayReleaseCandidateConfig releaseCandidate, GooglePlayShipConfig? ship
});


$GooglePlayReleaseCandidateConfigCopyWith<$Res> get releaseCandidate;$GooglePlayShipConfigCopyWith<$Res>? get ship;

}
/// @nodoc
class _$GooglePlayConfigCopyWithImpl<$Res>
    implements $GooglePlayConfigCopyWith<$Res> {
  _$GooglePlayConfigCopyWithImpl(this._self, this._then);

  final GooglePlayConfig _self;
  final $Res Function(GooglePlayConfig) _then;

/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? releaseCandidate = null,Object? ship = freezed,}) {
  return _then(_self.copyWith(
releaseCandidate: null == releaseCandidate ? _self.releaseCandidate : releaseCandidate // ignore: cast_nullable_to_non_nullable
as GooglePlayReleaseCandidateConfig,ship: freezed == ship ? _self.ship : ship // ignore: cast_nullable_to_non_nullable
as GooglePlayShipConfig?,
  ));
}
/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GooglePlayReleaseCandidateConfigCopyWith<$Res> get releaseCandidate {
  
  return $GooglePlayReleaseCandidateConfigCopyWith<$Res>(_self.releaseCandidate, (value) {
    return _then(_self.copyWith(releaseCandidate: value));
  });
}/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GooglePlayShipConfigCopyWith<$Res>? get ship {
    if (_self.ship == null) {
    return null;
  }

  return $GooglePlayShipConfigCopyWith<$Res>(_self.ship!, (value) {
    return _then(_self.copyWith(ship: value));
  });
}
}


/// Adds pattern-matching-related methods to [GooglePlayConfig].
extension GooglePlayConfigPatterns on GooglePlayConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GooglePlayConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GooglePlayConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GooglePlayConfig value)  $default,){
final _that = this;
switch (_that) {
case _GooglePlayConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GooglePlayConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GooglePlayConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GooglePlayReleaseCandidateConfig releaseCandidate,  GooglePlayShipConfig? ship)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GooglePlayConfig() when $default != null:
return $default(_that.releaseCandidate,_that.ship);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GooglePlayReleaseCandidateConfig releaseCandidate,  GooglePlayShipConfig? ship)  $default,) {final _that = this;
switch (_that) {
case _GooglePlayConfig():
return $default(_that.releaseCandidate,_that.ship);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GooglePlayReleaseCandidateConfig releaseCandidate,  GooglePlayShipConfig? ship)?  $default,) {final _that = this;
switch (_that) {
case _GooglePlayConfig() when $default != null:
return $default(_that.releaseCandidate,_that.ship);case _:
  return null;

}
}

}

/// @nodoc


class _GooglePlayConfig implements GooglePlayConfig {
  const _GooglePlayConfig({this.releaseCandidate = const GooglePlayReleaseCandidateConfig(), this.ship});
  

@override@JsonKey() final  GooglePlayReleaseCandidateConfig releaseCandidate;
@override final  GooglePlayShipConfig? ship;

/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GooglePlayConfigCopyWith<_GooglePlayConfig> get copyWith => __$GooglePlayConfigCopyWithImpl<_GooglePlayConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GooglePlayConfig&&(identical(other.releaseCandidate, releaseCandidate) || other.releaseCandidate == releaseCandidate)&&(identical(other.ship, ship) || other.ship == ship));
}


@override
int get hashCode => Object.hash(runtimeType,releaseCandidate,ship);

@override
String toString() {
  return 'GooglePlayConfig(releaseCandidate: $releaseCandidate, ship: $ship)';
}


}

/// @nodoc
abstract mixin class _$GooglePlayConfigCopyWith<$Res> implements $GooglePlayConfigCopyWith<$Res> {
  factory _$GooglePlayConfigCopyWith(_GooglePlayConfig value, $Res Function(_GooglePlayConfig) _then) = __$GooglePlayConfigCopyWithImpl;
@override @useResult
$Res call({
 GooglePlayReleaseCandidateConfig releaseCandidate, GooglePlayShipConfig? ship
});


@override $GooglePlayReleaseCandidateConfigCopyWith<$Res> get releaseCandidate;@override $GooglePlayShipConfigCopyWith<$Res>? get ship;

}
/// @nodoc
class __$GooglePlayConfigCopyWithImpl<$Res>
    implements _$GooglePlayConfigCopyWith<$Res> {
  __$GooglePlayConfigCopyWithImpl(this._self, this._then);

  final _GooglePlayConfig _self;
  final $Res Function(_GooglePlayConfig) _then;

/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? releaseCandidate = null,Object? ship = freezed,}) {
  return _then(_GooglePlayConfig(
releaseCandidate: null == releaseCandidate ? _self.releaseCandidate : releaseCandidate // ignore: cast_nullable_to_non_nullable
as GooglePlayReleaseCandidateConfig,ship: freezed == ship ? _self.ship : ship // ignore: cast_nullable_to_non_nullable
as GooglePlayShipConfig?,
  ));
}

/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GooglePlayReleaseCandidateConfigCopyWith<$Res> get releaseCandidate {
  
  return $GooglePlayReleaseCandidateConfigCopyWith<$Res>(_self.releaseCandidate, (value) {
    return _then(_self.copyWith(releaseCandidate: value));
  });
}/// Create a copy of GooglePlayConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GooglePlayShipConfigCopyWith<$Res>? get ship {
    if (_self.ship == null) {
    return null;
  }

  return $GooglePlayShipConfigCopyWith<$Res>(_self.ship!, (value) {
    return _then(_self.copyWith(ship: value));
  });
}
}

// dart format on
