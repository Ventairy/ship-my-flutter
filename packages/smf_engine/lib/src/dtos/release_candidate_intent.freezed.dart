// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_candidate_intent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseCandidateIntent {

 Platform get platform; String get version; String get buildNumber; String get applicationId; String get storeApplicationId; String get sourceSha; String get sourceFingerprint; String get artifactSha256; DateTime get preparedAt;@JsonKey(required: true) int get schemaVersion;
/// Create a copy of ReleaseCandidateIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseCandidateIntentCopyWith<ReleaseCandidateIntent> get copyWith => _$ReleaseCandidateIntentCopyWithImpl<ReleaseCandidateIntent>(this as ReleaseCandidateIntent, _$identity);

  /// Serializes this ReleaseCandidateIntent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseCandidateIntent&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceSha, sourceSha) || other.sourceSha == sourceSha)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,applicationId,storeApplicationId,sourceSha,sourceFingerprint,artifactSha256,preparedAt,schemaVersion);

@override
String toString() {
  return 'ReleaseCandidateIntent(platform: $platform, version: $version, buildNumber: $buildNumber, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceSha: $sourceSha, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, preparedAt: $preparedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ReleaseCandidateIntentCopyWith<$Res>  {
  factory $ReleaseCandidateIntentCopyWith(ReleaseCandidateIntent value, $Res Function(ReleaseCandidateIntent) _then) = _$ReleaseCandidateIntentCopyWithImpl;
@useResult
$Res call({
 Platform platform, String version, String buildNumber, String applicationId, String storeApplicationId, String sourceSha, String sourceFingerprint, String artifactSha256, DateTime preparedAt,@JsonKey(required: true) int schemaVersion
});




}
/// @nodoc
class _$ReleaseCandidateIntentCopyWithImpl<$Res>
    implements $ReleaseCandidateIntentCopyWith<$Res> {
  _$ReleaseCandidateIntentCopyWithImpl(this._self, this._then);

  final ReleaseCandidateIntent _self;
  final $Res Function(ReleaseCandidateIntent) _then;

/// Create a copy of ReleaseCandidateIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceSha = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? preparedAt = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceSha: null == sourceSha ? _self.sourceSha : sourceSha // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,artifactSha256: null == artifactSha256 ? _self.artifactSha256 : artifactSha256 // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseCandidateIntent].
extension ReleaseCandidateIntentPatterns on ReleaseCandidateIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseCandidateIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseCandidateIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseCandidateIntent value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidateIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseCandidateIntent value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidateIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Platform platform,  String version,  String buildNumber,  String applicationId,  String storeApplicationId,  String sourceSha,  String sourceFingerprint,  String artifactSha256,  DateTime preparedAt, @JsonKey(required: true)  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseCandidateIntent() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.applicationId,_that.storeApplicationId,_that.sourceSha,_that.sourceFingerprint,_that.artifactSha256,_that.preparedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Platform platform,  String version,  String buildNumber,  String applicationId,  String storeApplicationId,  String sourceSha,  String sourceFingerprint,  String artifactSha256,  DateTime preparedAt, @JsonKey(required: true)  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidateIntent():
return $default(_that.platform,_that.version,_that.buildNumber,_that.applicationId,_that.storeApplicationId,_that.sourceSha,_that.sourceFingerprint,_that.artifactSha256,_that.preparedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Platform platform,  String version,  String buildNumber,  String applicationId,  String storeApplicationId,  String sourceSha,  String sourceFingerprint,  String artifactSha256,  DateTime preparedAt, @JsonKey(required: true)  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidateIntent() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.applicationId,_that.storeApplicationId,_that.sourceSha,_that.sourceFingerprint,_that.artifactSha256,_that.preparedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, dateTimeUtc: true, disallowUnrecognizedKeys: true)
class _ReleaseCandidateIntent extends ReleaseCandidateIntent {
  const _ReleaseCandidateIntent({required this.platform, required this.version, required this.buildNumber, required this.applicationId, required this.storeApplicationId, required this.sourceSha, required this.sourceFingerprint, required this.artifactSha256, required this.preparedAt, @JsonKey(required: true) this.schemaVersion = 1}): super._();
  factory _ReleaseCandidateIntent.fromJson(Map<String, dynamic> json) => _$ReleaseCandidateIntentFromJson(json);

@override final  Platform platform;
@override final  String version;
@override final  String buildNumber;
@override final  String applicationId;
@override final  String storeApplicationId;
@override final  String sourceSha;
@override final  String sourceFingerprint;
@override final  String artifactSha256;
@override final  DateTime preparedAt;
@override@JsonKey(required: true) final  int schemaVersion;

/// Create a copy of ReleaseCandidateIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseCandidateIntentCopyWith<_ReleaseCandidateIntent> get copyWith => __$ReleaseCandidateIntentCopyWithImpl<_ReleaseCandidateIntent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseCandidateIntentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseCandidateIntent&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceSha, sourceSha) || other.sourceSha == sourceSha)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,applicationId,storeApplicationId,sourceSha,sourceFingerprint,artifactSha256,preparedAt,schemaVersion);

@override
String toString() {
  return 'ReleaseCandidateIntent(platform: $platform, version: $version, buildNumber: $buildNumber, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceSha: $sourceSha, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, preparedAt: $preparedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ReleaseCandidateIntentCopyWith<$Res> implements $ReleaseCandidateIntentCopyWith<$Res> {
  factory _$ReleaseCandidateIntentCopyWith(_ReleaseCandidateIntent value, $Res Function(_ReleaseCandidateIntent) _then) = __$ReleaseCandidateIntentCopyWithImpl;
@override @useResult
$Res call({
 Platform platform, String version, String buildNumber, String applicationId, String storeApplicationId, String sourceSha, String sourceFingerprint, String artifactSha256, DateTime preparedAt,@JsonKey(required: true) int schemaVersion
});




}
/// @nodoc
class __$ReleaseCandidateIntentCopyWithImpl<$Res>
    implements _$ReleaseCandidateIntentCopyWith<$Res> {
  __$ReleaseCandidateIntentCopyWithImpl(this._self, this._then);

  final _ReleaseCandidateIntent _self;
  final $Res Function(_ReleaseCandidateIntent) _then;

/// Create a copy of ReleaseCandidateIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceSha = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? preparedAt = null,Object? schemaVersion = null,}) {
  return _then(_ReleaseCandidateIntent(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceSha: null == sourceSha ? _self.sourceSha : sourceSha // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,artifactSha256: null == artifactSha256 ? _self.artifactSha256 : artifactSha256 // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
