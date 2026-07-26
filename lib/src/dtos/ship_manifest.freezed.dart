// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ship_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShipManifest {

 int get schemaVersion; PlatformManifest get ios;
/// Create a copy of ShipManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipManifestCopyWith<ShipManifest> get copyWith => _$ShipManifestCopyWithImpl<ShipManifest>(this as ShipManifest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipManifest&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,ios);

@override
String toString() {
  return 'ShipManifest(schemaVersion: $schemaVersion, ios: $ios)';
}


}

/// @nodoc
abstract mixin class $ShipManifestCopyWith<$Res>  {
  factory $ShipManifestCopyWith(ShipManifest value, $Res Function(ShipManifest) _then) = _$ShipManifestCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, PlatformManifest ios
});


$PlatformManifestCopyWith<$Res> get ios;

}
/// @nodoc
class _$ShipManifestCopyWithImpl<$Res>
    implements $ShipManifestCopyWith<$Res> {
  _$ShipManifestCopyWithImpl(this._self, this._then);

  final ShipManifest _self;
  final $Res Function(ShipManifest) _then;

/// Create a copy of ShipManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? ios = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as PlatformManifest,
  ));
}
/// Create a copy of ShipManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestCopyWith<$Res> get ios {
  
  return $PlatformManifestCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShipManifest].
extension ShipManifestPatterns on ShipManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipManifest value)  $default,){
final _that = this;
switch (_that) {
case _ShipManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipManifest value)?  $default,){
final _that = this;
switch (_that) {
case _ShipManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  PlatformManifest ios)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipManifest() when $default != null:
return $default(_that.schemaVersion,_that.ios);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  PlatformManifest ios)  $default,) {final _that = this;
switch (_that) {
case _ShipManifest():
return $default(_that.schemaVersion,_that.ios);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  PlatformManifest ios)?  $default,) {final _that = this;
switch (_that) {
case _ShipManifest() when $default != null:
return $default(_that.schemaVersion,_that.ios);case _:
  return null;

}
}

}

/// @nodoc


class _ShipManifest extends ShipManifest {
  const _ShipManifest({this.schemaVersion = 1, required this.ios}): super._();
  

@override@JsonKey() final  int schemaVersion;
@override final  PlatformManifest ios;

/// Create a copy of ShipManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipManifestCopyWith<_ShipManifest> get copyWith => __$ShipManifestCopyWithImpl<_ShipManifest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipManifest&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,ios);

@override
String toString() {
  return 'ShipManifest(schemaVersion: $schemaVersion, ios: $ios)';
}


}

/// @nodoc
abstract mixin class _$ShipManifestCopyWith<$Res> implements $ShipManifestCopyWith<$Res> {
  factory _$ShipManifestCopyWith(_ShipManifest value, $Res Function(_ShipManifest) _then) = __$ShipManifestCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, PlatformManifest ios
});


@override $PlatformManifestCopyWith<$Res> get ios;

}
/// @nodoc
class __$ShipManifestCopyWithImpl<$Res>
    implements _$ShipManifestCopyWith<$Res> {
  __$ShipManifestCopyWithImpl(this._self, this._then);

  final _ShipManifest _self;
  final $Res Function(_ShipManifest) _then;

/// Create a copy of ShipManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? ios = null,}) {
  return _then(_ShipManifest(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as PlatformManifest,
  ));
}

/// Create a copy of ShipManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestCopyWith<$Res> get ios {
  
  return $PlatformManifestCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}

// dart format on
