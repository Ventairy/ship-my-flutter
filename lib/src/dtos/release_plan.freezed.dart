// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleasePlan {

 Platform get platform; String get currentVersion; String get nextVersion; Bump get bump; String get baseSha; String get headSha; List<ConventionalChange> get changes;
/// Create a copy of ReleasePlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleasePlanCopyWith<ReleasePlan> get copyWith => _$ReleasePlanCopyWithImpl<ReleasePlan>(this as ReleasePlan, _$identity);

  /// Serializes this ReleasePlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleasePlan&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.nextVersion, nextVersion) || other.nextVersion == nextVersion)&&(identical(other.bump, bump) || other.bump == bump)&&(identical(other.baseSha, baseSha) || other.baseSha == baseSha)&&(identical(other.headSha, headSha) || other.headSha == headSha)&&const DeepCollectionEquality().equals(other.changes, changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,currentVersion,nextVersion,bump,baseSha,headSha,const DeepCollectionEquality().hash(changes));

@override
String toString() {
  return 'ReleasePlan(platform: $platform, currentVersion: $currentVersion, nextVersion: $nextVersion, bump: $bump, baseSha: $baseSha, headSha: $headSha, changes: $changes)';
}


}

/// @nodoc
abstract mixin class $ReleasePlanCopyWith<$Res>  {
  factory $ReleasePlanCopyWith(ReleasePlan value, $Res Function(ReleasePlan) _then) = _$ReleasePlanCopyWithImpl;
@useResult
$Res call({
 Platform platform, String currentVersion, String nextVersion, Bump bump, String baseSha, String headSha, List<ConventionalChange> changes
});




}
/// @nodoc
class _$ReleasePlanCopyWithImpl<$Res>
    implements $ReleasePlanCopyWith<$Res> {
  _$ReleasePlanCopyWithImpl(this._self, this._then);

  final ReleasePlan _self;
  final $Res Function(ReleasePlan) _then;

/// Create a copy of ReleasePlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? currentVersion = null,Object? nextVersion = null,Object? bump = null,Object? baseSha = null,Object? headSha = null,Object? changes = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,nextVersion: null == nextVersion ? _self.nextVersion : nextVersion // ignore: cast_nullable_to_non_nullable
as String,bump: null == bump ? _self.bump : bump // ignore: cast_nullable_to_non_nullable
as Bump,baseSha: null == baseSha ? _self.baseSha : baseSha // ignore: cast_nullable_to_non_nullable
as String,headSha: null == headSha ? _self.headSha : headSha // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChange>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleasePlan].
extension ReleasePlanPatterns on ReleasePlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleasePlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleasePlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleasePlan value)  $default,){
final _that = this;
switch (_that) {
case _ReleasePlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleasePlan value)?  $default,){
final _that = this;
switch (_that) {
case _ReleasePlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Platform platform,  String currentVersion,  String nextVersion,  Bump bump,  String baseSha,  String headSha,  List<ConventionalChange> changes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleasePlan() when $default != null:
return $default(_that.platform,_that.currentVersion,_that.nextVersion,_that.bump,_that.baseSha,_that.headSha,_that.changes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Platform platform,  String currentVersion,  String nextVersion,  Bump bump,  String baseSha,  String headSha,  List<ConventionalChange> changes)  $default,) {final _that = this;
switch (_that) {
case _ReleasePlan():
return $default(_that.platform,_that.currentVersion,_that.nextVersion,_that.bump,_that.baseSha,_that.headSha,_that.changes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Platform platform,  String currentVersion,  String nextVersion,  Bump bump,  String baseSha,  String headSha,  List<ConventionalChange> changes)?  $default,) {final _that = this;
switch (_that) {
case _ReleasePlan() when $default != null:
return $default(_that.platform,_that.currentVersion,_that.nextVersion,_that.bump,_that.baseSha,_that.headSha,_that.changes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ReleasePlan implements ReleasePlan {
  const _ReleasePlan({required this.platform, required this.currentVersion, required this.nextVersion, required this.bump, required this.baseSha, required this.headSha, required final  List<ConventionalChange> changes}): _changes = changes;
  factory _ReleasePlan.fromJson(Map<String, dynamic> json) => _$ReleasePlanFromJson(json);

@override final  Platform platform;
@override final  String currentVersion;
@override final  String nextVersion;
@override final  Bump bump;
@override final  String baseSha;
@override final  String headSha;
 final  List<ConventionalChange> _changes;
@override List<ConventionalChange> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}


/// Create a copy of ReleasePlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleasePlanCopyWith<_ReleasePlan> get copyWith => __$ReleasePlanCopyWithImpl<_ReleasePlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleasePlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleasePlan&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.nextVersion, nextVersion) || other.nextVersion == nextVersion)&&(identical(other.bump, bump) || other.bump == bump)&&(identical(other.baseSha, baseSha) || other.baseSha == baseSha)&&(identical(other.headSha, headSha) || other.headSha == headSha)&&const DeepCollectionEquality().equals(other._changes, _changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,currentVersion,nextVersion,bump,baseSha,headSha,const DeepCollectionEquality().hash(_changes));

@override
String toString() {
  return 'ReleasePlan(platform: $platform, currentVersion: $currentVersion, nextVersion: $nextVersion, bump: $bump, baseSha: $baseSha, headSha: $headSha, changes: $changes)';
}


}

/// @nodoc
abstract mixin class _$ReleasePlanCopyWith<$Res> implements $ReleasePlanCopyWith<$Res> {
  factory _$ReleasePlanCopyWith(_ReleasePlan value, $Res Function(_ReleasePlan) _then) = __$ReleasePlanCopyWithImpl;
@override @useResult
$Res call({
 Platform platform, String currentVersion, String nextVersion, Bump bump, String baseSha, String headSha, List<ConventionalChange> changes
});




}
/// @nodoc
class __$ReleasePlanCopyWithImpl<$Res>
    implements _$ReleasePlanCopyWith<$Res> {
  __$ReleasePlanCopyWithImpl(this._self, this._then);

  final _ReleasePlan _self;
  final $Res Function(_ReleasePlan) _then;

/// Create a copy of ReleasePlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? currentVersion = null,Object? nextVersion = null,Object? bump = null,Object? baseSha = null,Object? headSha = null,Object? changes = null,}) {
  return _then(_ReleasePlan(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,nextVersion: null == nextVersion ? _self.nextVersion : nextVersion // ignore: cast_nullable_to_non_nullable
as String,bump: null == bump ? _self.bump : bump // ignore: cast_nullable_to_non_nullable
as Bump,baseSha: null == baseSha ? _self.baseSha : baseSha // ignore: cast_nullable_to_non_nullable
as String,headSha: null == headSha ? _self.headSha : headSha // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChange>,
  ));
}


}

// dart format on
