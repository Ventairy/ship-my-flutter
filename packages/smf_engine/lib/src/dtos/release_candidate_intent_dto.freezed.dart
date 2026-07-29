// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_candidate_intent_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseCandidateIntentDto {

 ReleasePlatform get platform;@JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson) String get version;@JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson) String get buildNumber;@JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson) String get applicationId;@JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson) String get storeApplicationId;@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson) String get sourceCommitHash;@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson) String get sourceFingerprint;@JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson) String get artifactSha256;@JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson) DateTime get preparedAt;@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson) int get schemaVersion;
/// Create a copy of ReleaseCandidateIntentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseCandidateIntentDtoCopyWith<ReleaseCandidateIntentDto> get copyWith => _$ReleaseCandidateIntentDtoCopyWithImpl<ReleaseCandidateIntentDto>(this as ReleaseCandidateIntentDto, _$identity);

  /// Serializes this ReleaseCandidateIntentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseCandidateIntentDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceCommitHash, sourceCommitHash) || other.sourceCommitHash == sourceCommitHash)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,applicationId,storeApplicationId,sourceCommitHash,sourceFingerprint,artifactSha256,preparedAt,schemaVersion);

@override
String toString() {
  return 'ReleaseCandidateIntentDto(platform: $platform, version: $version, buildNumber: $buildNumber, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceCommitHash: $sourceCommitHash, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, preparedAt: $preparedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ReleaseCandidateIntentDtoCopyWith<$Res>  {
  factory $ReleaseCandidateIntentDtoCopyWith(ReleaseCandidateIntentDto value, $Res Function(ReleaseCandidateIntentDto) _then) = _$ReleaseCandidateIntentDtoCopyWithImpl;
@useResult
$Res call({
 ReleasePlatform platform,@JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson) String version,@JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson) String buildNumber,@JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson) String applicationId,@JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson) String storeApplicationId,@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson) String sourceCommitHash,@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson) String sourceFingerprint,@JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson) String artifactSha256,@JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson) DateTime preparedAt,@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson) int schemaVersion
});




}
/// @nodoc
class _$ReleaseCandidateIntentDtoCopyWithImpl<$Res>
    implements $ReleaseCandidateIntentDtoCopyWith<$Res> {
  _$ReleaseCandidateIntentDtoCopyWithImpl(this._self, this._then);

  final ReleaseCandidateIntentDto _self;
  final $Res Function(ReleaseCandidateIntentDto) _then;

/// Create a copy of ReleaseCandidateIntentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceCommitHash = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? preparedAt = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceCommitHash: null == sourceCommitHash ? _self.sourceCommitHash : sourceCommitHash // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,artifactSha256: null == artifactSha256 ? _self.artifactSha256 : artifactSha256 // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseCandidateIntentDto].
extension ReleaseCandidateIntentDtoPatterns on ReleaseCandidateIntentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseCandidateIntentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseCandidateIntentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseCandidateIntentDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidateIntentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseCandidateIntentDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidateIntentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReleasePlatform platform, @JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson)  String version, @JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson)  String buildNumber, @JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson)  String applicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson)  String storeApplicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson)  String sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson)  String sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson)  String artifactSha256, @JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson)  DateTime preparedAt, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson)  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseCandidateIntentDto() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.applicationId,_that.storeApplicationId,_that.sourceCommitHash,_that.sourceFingerprint,_that.artifactSha256,_that.preparedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReleasePlatform platform, @JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson)  String version, @JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson)  String buildNumber, @JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson)  String applicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson)  String storeApplicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson)  String sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson)  String sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson)  String artifactSha256, @JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson)  DateTime preparedAt, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson)  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidateIntentDto():
return $default(_that.platform,_that.version,_that.buildNumber,_that.applicationId,_that.storeApplicationId,_that.sourceCommitHash,_that.sourceFingerprint,_that.artifactSha256,_that.preparedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReleasePlatform platform, @JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson)  String version, @JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson)  String buildNumber, @JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson)  String applicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson)  String storeApplicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson)  String sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson)  String sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson)  String artifactSha256, @JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson)  DateTime preparedAt, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson)  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidateIntentDto() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.applicationId,_that.storeApplicationId,_that.sourceCommitHash,_that.sourceFingerprint,_that.artifactSha256,_that.preparedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, dateTimeUtc: true, disallowUnrecognizedKeys: true)
class _ReleaseCandidateIntentDto extends ReleaseCandidateIntentDto {
  const _ReleaseCandidateIntentDto({required this.platform, @JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson) required this.version, @JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson) required this.buildNumber, @JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson) required this.applicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson) required this.storeApplicationId, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson) required this.sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson) required this.sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson) required this.artifactSha256, @JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson) required this.preparedAt, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson) required this.schemaVersion}): super._();
  factory _ReleaseCandidateIntentDto.fromJson(Map<String, dynamic> json) => _$ReleaseCandidateIntentDtoFromJson(json);

@override final  ReleasePlatform platform;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson) final  String version;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson) final  String buildNumber;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson) final  String applicationId;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson) final  String storeApplicationId;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson) final  String sourceCommitHash;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson) final  String sourceFingerprint;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson) final  String artifactSha256;
@override@JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson) final  DateTime preparedAt;
@override@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson) final  int schemaVersion;

/// Create a copy of ReleaseCandidateIntentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseCandidateIntentDtoCopyWith<_ReleaseCandidateIntentDto> get copyWith => __$ReleaseCandidateIntentDtoCopyWithImpl<_ReleaseCandidateIntentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseCandidateIntentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseCandidateIntentDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceCommitHash, sourceCommitHash) || other.sourceCommitHash == sourceCommitHash)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,applicationId,storeApplicationId,sourceCommitHash,sourceFingerprint,artifactSha256,preparedAt,schemaVersion);

@override
String toString() {
  return 'ReleaseCandidateIntentDto(platform: $platform, version: $version, buildNumber: $buildNumber, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceCommitHash: $sourceCommitHash, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, preparedAt: $preparedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ReleaseCandidateIntentDtoCopyWith<$Res> implements $ReleaseCandidateIntentDtoCopyWith<$Res> {
  factory _$ReleaseCandidateIntentDtoCopyWith(_ReleaseCandidateIntentDto value, $Res Function(_ReleaseCandidateIntentDto) _then) = __$ReleaseCandidateIntentDtoCopyWithImpl;
@override @useResult
$Res call({
 ReleasePlatform platform,@JsonKey(fromJson: ReleaseCandidateIntentDto._versionFromJson) String version,@JsonKey(fromJson: ReleaseCandidateIntentDto._buildNumberFromJson) String buildNumber,@JsonKey(fromJson: ReleaseCandidateIntentDto._applicationIdFromJson) String applicationId,@JsonKey(fromJson: ReleaseCandidateIntentDto._storeApplicationIdFromJson) String storeApplicationId,@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceCommitHashFromJson) String sourceCommitHash,@JsonKey(fromJson: ReleaseCandidateIntentDto._sourceFingerprintFromJson) String sourceFingerprint,@JsonKey(fromJson: ReleaseCandidateIntentDto._artifactSha256FromJson) String artifactSha256,@JsonKey(fromJson: ReleaseCandidateIntentDto._preparedAtFromJson) DateTime preparedAt,@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateIntentDto._schemaVersionFromJson) int schemaVersion
});




}
/// @nodoc
class __$ReleaseCandidateIntentDtoCopyWithImpl<$Res>
    implements _$ReleaseCandidateIntentDtoCopyWith<$Res> {
  __$ReleaseCandidateIntentDtoCopyWithImpl(this._self, this._then);

  final _ReleaseCandidateIntentDto _self;
  final $Res Function(_ReleaseCandidateIntentDto) _then;

/// Create a copy of ReleaseCandidateIntentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceCommitHash = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? preparedAt = null,Object? schemaVersion = null,}) {
  return _then(_ReleaseCandidateIntentDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceCommitHash: null == sourceCommitHash ? _self.sourceCommitHash : sourceCommitHash // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,artifactSha256: null == artifactSha256 ? _self.artifactSha256 : artifactSha256 // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
