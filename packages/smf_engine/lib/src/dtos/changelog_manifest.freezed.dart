// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changelog_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangelogManifest {

 Map<String, ChangelogRelease> get iosReleases; int get schemaVersion;
/// Create a copy of ChangelogManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogManifestCopyWith<ChangelogManifest> get copyWith => _$ChangelogManifestCopyWithImpl<ChangelogManifest>(this as ChangelogManifest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogManifest&&const DeepCollectionEquality().equals(other.iosReleases, iosReleases)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(iosReleases),schemaVersion);

@override
String toString() {
  return 'ChangelogManifest(iosReleases: $iosReleases, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ChangelogManifestCopyWith<$Res>  {
  factory $ChangelogManifestCopyWith(ChangelogManifest value, $Res Function(ChangelogManifest) _then) = _$ChangelogManifestCopyWithImpl;
@useResult
$Res call({
 Map<String, ChangelogRelease> iosReleases, int schemaVersion
});




}
/// @nodoc
class _$ChangelogManifestCopyWithImpl<$Res>
    implements $ChangelogManifestCopyWith<$Res> {
  _$ChangelogManifestCopyWithImpl(this._self, this._then);

  final ChangelogManifest _self;
  final $Res Function(ChangelogManifest) _then;

/// Create a copy of ChangelogManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iosReleases = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
iosReleases: null == iosReleases ? _self.iosReleases : iosReleases // ignore: cast_nullable_to_non_nullable
as Map<String, ChangelogRelease>,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogManifest].
extension ChangelogManifestPatterns on ChangelogManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogManifest value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogManifest value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, ChangelogRelease> iosReleases,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogManifest() when $default != null:
return $default(_that.iosReleases,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, ChangelogRelease> iosReleases,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ChangelogManifest():
return $default(_that.iosReleases,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, ChangelogRelease> iosReleases,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogManifest() when $default != null:
return $default(_that.iosReleases,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc


class _ChangelogManifest extends ChangelogManifest {
  const _ChangelogManifest({required final  Map<String, ChangelogRelease> iosReleases, this.schemaVersion = 1}): _iosReleases = iosReleases,super._();
  

 final  Map<String, ChangelogRelease> _iosReleases;
@override Map<String, ChangelogRelease> get iosReleases {
  if (_iosReleases is EqualUnmodifiableMapView) return _iosReleases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_iosReleases);
}

@override@JsonKey() final  int schemaVersion;

/// Create a copy of ChangelogManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogManifestCopyWith<_ChangelogManifest> get copyWith => __$ChangelogManifestCopyWithImpl<_ChangelogManifest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogManifest&&const DeepCollectionEquality().equals(other._iosReleases, _iosReleases)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_iosReleases),schemaVersion);

@override
String toString() {
  return 'ChangelogManifest(iosReleases: $iosReleases, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ChangelogManifestCopyWith<$Res> implements $ChangelogManifestCopyWith<$Res> {
  factory _$ChangelogManifestCopyWith(_ChangelogManifest value, $Res Function(_ChangelogManifest) _then) = __$ChangelogManifestCopyWithImpl;
@override @useResult
$Res call({
 Map<String, ChangelogRelease> iosReleases, int schemaVersion
});




}
/// @nodoc
class __$ChangelogManifestCopyWithImpl<$Res>
    implements _$ChangelogManifestCopyWith<$Res> {
  __$ChangelogManifestCopyWithImpl(this._self, this._then);

  final _ChangelogManifest _self;
  final $Res Function(_ChangelogManifest) _then;

/// Create a copy of ChangelogManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iosReleases = null,Object? schemaVersion = null,}) {
  return _then(_ChangelogManifest(
iosReleases: null == iosReleases ? _self._iosReleases : iosReleases // ignore: cast_nullable_to_non_nullable
as Map<String, ChangelogRelease>,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
