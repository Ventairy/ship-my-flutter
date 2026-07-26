// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changelog_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangelogRelease {

 String get version;@UtcDateTimeConverter() DateTime get preparedAt; String get baseSha; String get headSha; List<ConventionalChange> get changes;
/// Create a copy of ChangelogRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogReleaseCopyWith<ChangelogRelease> get copyWith => _$ChangelogReleaseCopyWithImpl<ChangelogRelease>(this as ChangelogRelease, _$identity);

  /// Serializes this ChangelogRelease to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogRelease&&(identical(other.version, version) || other.version == version)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.baseSha, baseSha) || other.baseSha == baseSha)&&(identical(other.headSha, headSha) || other.headSha == headSha)&&const DeepCollectionEquality().equals(other.changes, changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,preparedAt,baseSha,headSha,const DeepCollectionEquality().hash(changes));

@override
String toString() {
  return 'ChangelogRelease(version: $version, preparedAt: $preparedAt, baseSha: $baseSha, headSha: $headSha, changes: $changes)';
}


}

/// @nodoc
abstract mixin class $ChangelogReleaseCopyWith<$Res>  {
  factory $ChangelogReleaseCopyWith(ChangelogRelease value, $Res Function(ChangelogRelease) _then) = _$ChangelogReleaseCopyWithImpl;
@useResult
$Res call({
 String version,@UtcDateTimeConverter() DateTime preparedAt, String baseSha, String headSha, List<ConventionalChange> changes
});




}
/// @nodoc
class _$ChangelogReleaseCopyWithImpl<$Res>
    implements $ChangelogReleaseCopyWith<$Res> {
  _$ChangelogReleaseCopyWithImpl(this._self, this._then);

  final ChangelogRelease _self;
  final $Res Function(ChangelogRelease) _then;

/// Create a copy of ChangelogRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? preparedAt = null,Object? baseSha = null,Object? headSha = null,Object? changes = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseSha: null == baseSha ? _self.baseSha : baseSha // ignore: cast_nullable_to_non_nullable
as String,headSha: null == headSha ? _self.headSha : headSha // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChange>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogRelease].
extension ChangelogReleasePatterns on ChangelogRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogRelease value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogRelease value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version, @UtcDateTimeConverter()  DateTime preparedAt,  String baseSha,  String headSha,  List<ConventionalChange> changes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogRelease() when $default != null:
return $default(_that.version,_that.preparedAt,_that.baseSha,_that.headSha,_that.changes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version, @UtcDateTimeConverter()  DateTime preparedAt,  String baseSha,  String headSha,  List<ConventionalChange> changes)  $default,) {final _that = this;
switch (_that) {
case _ChangelogRelease():
return $default(_that.version,_that.preparedAt,_that.baseSha,_that.headSha,_that.changes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version, @UtcDateTimeConverter()  DateTime preparedAt,  String baseSha,  String headSha,  List<ConventionalChange> changes)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogRelease() when $default != null:
return $default(_that.version,_that.preparedAt,_that.baseSha,_that.headSha,_that.changes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ChangelogRelease implements ChangelogRelease {
  const _ChangelogRelease({required this.version, @UtcDateTimeConverter() required this.preparedAt, required this.baseSha, required this.headSha, required final  List<ConventionalChange> changes}): _changes = changes;
  factory _ChangelogRelease.fromJson(Map<String, dynamic> json) => _$ChangelogReleaseFromJson(json);

@override final  String version;
@override@UtcDateTimeConverter() final  DateTime preparedAt;
@override final  String baseSha;
@override final  String headSha;
 final  List<ConventionalChange> _changes;
@override List<ConventionalChange> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}


/// Create a copy of ChangelogRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogReleaseCopyWith<_ChangelogRelease> get copyWith => __$ChangelogReleaseCopyWithImpl<_ChangelogRelease>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogRelease&&(identical(other.version, version) || other.version == version)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.baseSha, baseSha) || other.baseSha == baseSha)&&(identical(other.headSha, headSha) || other.headSha == headSha)&&const DeepCollectionEquality().equals(other._changes, _changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,preparedAt,baseSha,headSha,const DeepCollectionEquality().hash(_changes));

@override
String toString() {
  return 'ChangelogRelease(version: $version, preparedAt: $preparedAt, baseSha: $baseSha, headSha: $headSha, changes: $changes)';
}


}

/// @nodoc
abstract mixin class _$ChangelogReleaseCopyWith<$Res> implements $ChangelogReleaseCopyWith<$Res> {
  factory _$ChangelogReleaseCopyWith(_ChangelogRelease value, $Res Function(_ChangelogRelease) _then) = __$ChangelogReleaseCopyWithImpl;
@override @useResult
$Res call({
 String version,@UtcDateTimeConverter() DateTime preparedAt, String baseSha, String headSha, List<ConventionalChange> changes
});




}
/// @nodoc
class __$ChangelogReleaseCopyWithImpl<$Res>
    implements _$ChangelogReleaseCopyWith<$Res> {
  __$ChangelogReleaseCopyWithImpl(this._self, this._then);

  final _ChangelogRelease _self;
  final $Res Function(_ChangelogRelease) _then;

/// Create a copy of ChangelogRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? preparedAt = null,Object? baseSha = null,Object? headSha = null,Object? changes = null,}) {
  return _then(_ChangelogRelease(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseSha: null == baseSha ? _self.baseSha : baseSha // ignore: cast_nullable_to_non_nullable
as String,headSha: null == headSha ? _self.headSha : headSha // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChange>,
  ));
}


}

// dart format on
