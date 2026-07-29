// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_plan_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleasePlanDto {

 ReleasePlatform get platform; String get currentVersion; String get nextVersion; VersionBumpType get versionBumpType; String get baseCommitHash; String get endCommitHash; List<ConventionalChangeDto> get changes;
/// Create a copy of ReleasePlanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleasePlanDtoCopyWith<ReleasePlanDto> get copyWith => _$ReleasePlanDtoCopyWithImpl<ReleasePlanDto>(this as ReleasePlanDto, _$identity);

  /// Serializes this ReleasePlanDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleasePlanDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.nextVersion, nextVersion) || other.nextVersion == nextVersion)&&(identical(other.versionBumpType, versionBumpType) || other.versionBumpType == versionBumpType)&&(identical(other.baseCommitHash, baseCommitHash) || other.baseCommitHash == baseCommitHash)&&(identical(other.endCommitHash, endCommitHash) || other.endCommitHash == endCommitHash)&&const DeepCollectionEquality().equals(other.changes, changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,currentVersion,nextVersion,versionBumpType,baseCommitHash,endCommitHash,const DeepCollectionEquality().hash(changes));

@override
String toString() {
  return 'ReleasePlanDto(platform: $platform, currentVersion: $currentVersion, nextVersion: $nextVersion, versionBumpType: $versionBumpType, baseCommitHash: $baseCommitHash, endCommitHash: $endCommitHash, changes: $changes)';
}


}

/// @nodoc
abstract mixin class $ReleasePlanDtoCopyWith<$Res>  {
  factory $ReleasePlanDtoCopyWith(ReleasePlanDto value, $Res Function(ReleasePlanDto) _then) = _$ReleasePlanDtoCopyWithImpl;
@useResult
$Res call({
 ReleasePlatform platform, String currentVersion, String nextVersion, VersionBumpType versionBumpType, String baseCommitHash, String endCommitHash, List<ConventionalChangeDto> changes
});




}
/// @nodoc
class _$ReleasePlanDtoCopyWithImpl<$Res>
    implements $ReleasePlanDtoCopyWith<$Res> {
  _$ReleasePlanDtoCopyWithImpl(this._self, this._then);

  final ReleasePlanDto _self;
  final $Res Function(ReleasePlanDto) _then;

/// Create a copy of ReleasePlanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? currentVersion = null,Object? nextVersion = null,Object? versionBumpType = null,Object? baseCommitHash = null,Object? endCommitHash = null,Object? changes = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,nextVersion: null == nextVersion ? _self.nextVersion : nextVersion // ignore: cast_nullable_to_non_nullable
as String,versionBumpType: null == versionBumpType ? _self.versionBumpType : versionBumpType // ignore: cast_nullable_to_non_nullable
as VersionBumpType,baseCommitHash: null == baseCommitHash ? _self.baseCommitHash : baseCommitHash // ignore: cast_nullable_to_non_nullable
as String,endCommitHash: null == endCommitHash ? _self.endCommitHash : endCommitHash // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChangeDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleasePlanDto].
extension ReleasePlanDtoPatterns on ReleasePlanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleasePlanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleasePlanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleasePlanDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleasePlanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleasePlanDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleasePlanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReleasePlatform platform,  String currentVersion,  String nextVersion,  VersionBumpType versionBumpType,  String baseCommitHash,  String endCommitHash,  List<ConventionalChangeDto> changes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleasePlanDto() when $default != null:
return $default(_that.platform,_that.currentVersion,_that.nextVersion,_that.versionBumpType,_that.baseCommitHash,_that.endCommitHash,_that.changes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReleasePlatform platform,  String currentVersion,  String nextVersion,  VersionBumpType versionBumpType,  String baseCommitHash,  String endCommitHash,  List<ConventionalChangeDto> changes)  $default,) {final _that = this;
switch (_that) {
case _ReleasePlanDto():
return $default(_that.platform,_that.currentVersion,_that.nextVersion,_that.versionBumpType,_that.baseCommitHash,_that.endCommitHash,_that.changes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReleasePlatform platform,  String currentVersion,  String nextVersion,  VersionBumpType versionBumpType,  String baseCommitHash,  String endCommitHash,  List<ConventionalChangeDto> changes)?  $default,) {final _that = this;
switch (_that) {
case _ReleasePlanDto() when $default != null:
return $default(_that.platform,_that.currentVersion,_that.nextVersion,_that.versionBumpType,_that.baseCommitHash,_that.endCommitHash,_that.changes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ReleasePlanDto implements ReleasePlanDto {
  const _ReleasePlanDto({required this.platform, required this.currentVersion, required this.nextVersion, required this.versionBumpType, required this.baseCommitHash, required this.endCommitHash, required final  List<ConventionalChangeDto> changes}): _changes = changes;
  factory _ReleasePlanDto.fromJson(Map<String, dynamic> json) => _$ReleasePlanDtoFromJson(json);

@override final  ReleasePlatform platform;
@override final  String currentVersion;
@override final  String nextVersion;
@override final  VersionBumpType versionBumpType;
@override final  String baseCommitHash;
@override final  String endCommitHash;
 final  List<ConventionalChangeDto> _changes;
@override List<ConventionalChangeDto> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}


/// Create a copy of ReleasePlanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleasePlanDtoCopyWith<_ReleasePlanDto> get copyWith => __$ReleasePlanDtoCopyWithImpl<_ReleasePlanDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleasePlanDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleasePlanDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.nextVersion, nextVersion) || other.nextVersion == nextVersion)&&(identical(other.versionBumpType, versionBumpType) || other.versionBumpType == versionBumpType)&&(identical(other.baseCommitHash, baseCommitHash) || other.baseCommitHash == baseCommitHash)&&(identical(other.endCommitHash, endCommitHash) || other.endCommitHash == endCommitHash)&&const DeepCollectionEquality().equals(other._changes, _changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,currentVersion,nextVersion,versionBumpType,baseCommitHash,endCommitHash,const DeepCollectionEquality().hash(_changes));

@override
String toString() {
  return 'ReleasePlanDto(platform: $platform, currentVersion: $currentVersion, nextVersion: $nextVersion, versionBumpType: $versionBumpType, baseCommitHash: $baseCommitHash, endCommitHash: $endCommitHash, changes: $changes)';
}


}

/// @nodoc
abstract mixin class _$ReleasePlanDtoCopyWith<$Res> implements $ReleasePlanDtoCopyWith<$Res> {
  factory _$ReleasePlanDtoCopyWith(_ReleasePlanDto value, $Res Function(_ReleasePlanDto) _then) = __$ReleasePlanDtoCopyWithImpl;
@override @useResult
$Res call({
 ReleasePlatform platform, String currentVersion, String nextVersion, VersionBumpType versionBumpType, String baseCommitHash, String endCommitHash, List<ConventionalChangeDto> changes
});




}
/// @nodoc
class __$ReleasePlanDtoCopyWithImpl<$Res>
    implements _$ReleasePlanDtoCopyWith<$Res> {
  __$ReleasePlanDtoCopyWithImpl(this._self, this._then);

  final _ReleasePlanDto _self;
  final $Res Function(_ReleasePlanDto) _then;

/// Create a copy of ReleasePlanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? currentVersion = null,Object? nextVersion = null,Object? versionBumpType = null,Object? baseCommitHash = null,Object? endCommitHash = null,Object? changes = null,}) {
  return _then(_ReleasePlanDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,nextVersion: null == nextVersion ? _self.nextVersion : nextVersion // ignore: cast_nullable_to_non_nullable
as String,versionBumpType: null == versionBumpType ? _self.versionBumpType : versionBumpType // ignore: cast_nullable_to_non_nullable
as VersionBumpType,baseCommitHash: null == baseCommitHash ? _self.baseCommitHash : baseCommitHash // ignore: cast_nullable_to_non_nullable
as String,endCommitHash: null == endCommitHash ? _self.endCommitHash : endCommitHash // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChangeDto>,
  ));
}


}

// dart format on
