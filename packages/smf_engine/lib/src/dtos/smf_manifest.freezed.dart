// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smf_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SmfManifest {

 int get schemaVersion; PlatformManifest get ios;
/// Create a copy of SmfManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SmfManifestCopyWith<SmfManifest> get copyWith => _$SmfManifestCopyWithImpl<SmfManifest>(this as SmfManifest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmfManifest&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,ios);

@override
String toString() {
  return 'SmfManifest(schemaVersion: $schemaVersion, ios: $ios)';
}


}

/// @nodoc
abstract mixin class $SmfManifestCopyWith<$Res>  {
  factory $SmfManifestCopyWith(SmfManifest value, $Res Function(SmfManifest) _then) = _$SmfManifestCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, PlatformManifest ios
});


$PlatformManifestCopyWith<$Res> get ios;

}
/// @nodoc
class _$SmfManifestCopyWithImpl<$Res>
    implements $SmfManifestCopyWith<$Res> {
  _$SmfManifestCopyWithImpl(this._self, this._then);

  final SmfManifest _self;
  final $Res Function(SmfManifest) _then;

/// Create a copy of SmfManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? ios = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as PlatformManifest,
  ));
}
/// Create a copy of SmfManifest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformManifestCopyWith<$Res> get ios {
  
  return $PlatformManifestCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}


/// Adds pattern-matching-related methods to [SmfManifest].
extension SmfManifestPatterns on SmfManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SmfManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SmfManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SmfManifest value)  $default,){
final _that = this;
switch (_that) {
case _SmfManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SmfManifest value)?  $default,){
final _that = this;
switch (_that) {
case _SmfManifest() when $default != null:
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
case _SmfManifest() when $default != null:
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
case _SmfManifest():
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
case _SmfManifest() when $default != null:
return $default(_that.schemaVersion,_that.ios);case _:
  return null;

}
}

}

/// @nodoc


class _SmfManifest extends SmfManifest {
  const _SmfManifest({this.schemaVersion = 1, required this.ios}): super._();
  

@override@JsonKey() final  int schemaVersion;
@override final  PlatformManifest ios;

/// Create a copy of SmfManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SmfManifestCopyWith<_SmfManifest> get copyWith => __$SmfManifestCopyWithImpl<_SmfManifest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SmfManifest&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.ios, ios) || other.ios == ios));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,ios);

@override
String toString() {
  return 'SmfManifest(schemaVersion: $schemaVersion, ios: $ios)';
}


}

/// @nodoc
abstract mixin class _$SmfManifestCopyWith<$Res> implements $SmfManifestCopyWith<$Res> {
  factory _$SmfManifestCopyWith(_SmfManifest value, $Res Function(_SmfManifest) _then) = __$SmfManifestCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, PlatformManifest ios
});


@override $PlatformManifestCopyWith<$Res> get ios;

}
/// @nodoc
class __$SmfManifestCopyWithImpl<$Res>
    implements _$SmfManifestCopyWith<$Res> {
  __$SmfManifestCopyWithImpl(this._self, this._then);

  final _SmfManifest _self;
  final $Res Function(_SmfManifest) _then;

/// Create a copy of SmfManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? ios = null,}) {
  return _then(_SmfManifest(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as PlatformManifest,
  ));
}

/// Create a copy of SmfManifest
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
