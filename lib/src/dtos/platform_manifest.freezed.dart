// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlatformManifest {

 String get version; String get baselineSha; bool get pendingRelease;
/// Create a copy of PlatformManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformManifestCopyWith<PlatformManifest> get copyWith => _$PlatformManifestCopyWithImpl<PlatformManifest>(this as PlatformManifest, _$identity);

  /// Serializes this PlatformManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformManifest&&(identical(other.version, version) || other.version == version)&&(identical(other.baselineSha, baselineSha) || other.baselineSha == baselineSha)&&(identical(other.pendingRelease, pendingRelease) || other.pendingRelease == pendingRelease));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,baselineSha,pendingRelease);

@override
String toString() {
  return 'PlatformManifest(version: $version, baselineSha: $baselineSha, pendingRelease: $pendingRelease)';
}


}

/// @nodoc
abstract mixin class $PlatformManifestCopyWith<$Res>  {
  factory $PlatformManifestCopyWith(PlatformManifest value, $Res Function(PlatformManifest) _then) = _$PlatformManifestCopyWithImpl;
@useResult
$Res call({
 String version, String baselineSha, bool pendingRelease
});




}
/// @nodoc
class _$PlatformManifestCopyWithImpl<$Res>
    implements $PlatformManifestCopyWith<$Res> {
  _$PlatformManifestCopyWithImpl(this._self, this._then);

  final PlatformManifest _self;
  final $Res Function(PlatformManifest) _then;

/// Create a copy of PlatformManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? baselineSha = null,Object? pendingRelease = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,baselineSha: null == baselineSha ? _self.baselineSha : baselineSha // ignore: cast_nullable_to_non_nullable
as String,pendingRelease: null == pendingRelease ? _self.pendingRelease : pendingRelease // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformManifest].
extension PlatformManifestPatterns on PlatformManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformManifest value)  $default,){
final _that = this;
switch (_that) {
case _PlatformManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformManifest value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String baselineSha,  bool pendingRelease)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformManifest() when $default != null:
return $default(_that.version,_that.baselineSha,_that.pendingRelease);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String baselineSha,  bool pendingRelease)  $default,) {final _that = this;
switch (_that) {
case _PlatformManifest():
return $default(_that.version,_that.baselineSha,_that.pendingRelease);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String baselineSha,  bool pendingRelease)?  $default,) {final _that = this;
switch (_that) {
case _PlatformManifest() when $default != null:
return $default(_that.version,_that.baselineSha,_that.pendingRelease);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _PlatformManifest implements PlatformManifest {
  const _PlatformManifest({required this.version, required this.baselineSha, required this.pendingRelease});
  factory _PlatformManifest.fromJson(Map<String, dynamic> json) => _$PlatformManifestFromJson(json);

@override final  String version;
@override final  String baselineSha;
@override final  bool pendingRelease;

/// Create a copy of PlatformManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformManifestCopyWith<_PlatformManifest> get copyWith => __$PlatformManifestCopyWithImpl<_PlatformManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformManifestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformManifest&&(identical(other.version, version) || other.version == version)&&(identical(other.baselineSha, baselineSha) || other.baselineSha == baselineSha)&&(identical(other.pendingRelease, pendingRelease) || other.pendingRelease == pendingRelease));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,baselineSha,pendingRelease);

@override
String toString() {
  return 'PlatformManifest(version: $version, baselineSha: $baselineSha, pendingRelease: $pendingRelease)';
}


}

/// @nodoc
abstract mixin class _$PlatformManifestCopyWith<$Res> implements $PlatformManifestCopyWith<$Res> {
  factory _$PlatformManifestCopyWith(_PlatformManifest value, $Res Function(_PlatformManifest) _then) = __$PlatformManifestCopyWithImpl;
@override @useResult
$Res call({
 String version, String baselineSha, bool pendingRelease
});




}
/// @nodoc
class __$PlatformManifestCopyWithImpl<$Res>
    implements _$PlatformManifestCopyWith<$Res> {
  __$PlatformManifestCopyWithImpl(this._self, this._then);

  final _PlatformManifest _self;
  final $Res Function(_PlatformManifest) _then;

/// Create a copy of PlatformManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? baselineSha = null,Object? pendingRelease = null,}) {
  return _then(_PlatformManifest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,baselineSha: null == baselineSha ? _self.baselineSha : baselineSha // ignore: cast_nullable_to_non_nullable
as String,pendingRelease: null == pendingRelease ? _self.pendingRelease : pendingRelease // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
