// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_candidate_receipt_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseCandidateReceiptDto {

 ReleasePlatform get platform;@JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson) String get version;@JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson) String get buildNumber;@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson) String get artifactId;@JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson) String get applicationId;@JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson) String get storeApplicationId;@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson) String get sourceCommitHash;@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson) String get sourceFingerprint;@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson) String get artifactSha256;@JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson) DateTime get uploadedAt;@JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson) List<String> get testingDestinations;@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson) String get processingState;@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson) int get schemaVersion;
/// Create a copy of ReleaseCandidateReceiptDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseCandidateReceiptDtoCopyWith<ReleaseCandidateReceiptDto> get copyWith => _$ReleaseCandidateReceiptDtoCopyWithImpl<ReleaseCandidateReceiptDto>(this as ReleaseCandidateReceiptDto, _$identity);

  /// Serializes this ReleaseCandidateReceiptDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseCandidateReceiptDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceCommitHash, sourceCommitHash) || other.sourceCommitHash == sourceCommitHash)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other.testingDestinations, testingDestinations)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,artifactId,applicationId,storeApplicationId,sourceCommitHash,sourceFingerprint,artifactSha256,uploadedAt,const DeepCollectionEquality().hash(testingDestinations),processingState,schemaVersion);

@override
String toString() {
  return 'ReleaseCandidateReceiptDto(platform: $platform, version: $version, buildNumber: $buildNumber, artifactId: $artifactId, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceCommitHash: $sourceCommitHash, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, uploadedAt: $uploadedAt, testingDestinations: $testingDestinations, processingState: $processingState, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ReleaseCandidateReceiptDtoCopyWith<$Res>  {
  factory $ReleaseCandidateReceiptDtoCopyWith(ReleaseCandidateReceiptDto value, $Res Function(ReleaseCandidateReceiptDto) _then) = _$ReleaseCandidateReceiptDtoCopyWithImpl;
@useResult
$Res call({
 ReleasePlatform platform,@JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson) String version,@JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson) String buildNumber,@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson) String artifactId,@JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson) String applicationId,@JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson) String storeApplicationId,@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson) String sourceCommitHash,@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson) String sourceFingerprint,@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson) String artifactSha256,@JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson) DateTime uploadedAt,@JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson) List<String> testingDestinations,@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson) String processingState,@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson) int schemaVersion
});




}
/// @nodoc
class _$ReleaseCandidateReceiptDtoCopyWithImpl<$Res>
    implements $ReleaseCandidateReceiptDtoCopyWith<$Res> {
  _$ReleaseCandidateReceiptDtoCopyWithImpl(this._self, this._then);

  final ReleaseCandidateReceiptDto _self;
  final $Res Function(ReleaseCandidateReceiptDto) _then;

/// Create a copy of ReleaseCandidateReceiptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? artifactId = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceCommitHash = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? uploadedAt = null,Object? testingDestinations = null,Object? processingState = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceCommitHash: null == sourceCommitHash ? _self.sourceCommitHash : sourceCommitHash // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,artifactSha256: null == artifactSha256 ? _self.artifactSha256 : artifactSha256 // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,testingDestinations: null == testingDestinations ? _self.testingDestinations : testingDestinations // ignore: cast_nullable_to_non_nullable
as List<String>,processingState: null == processingState ? _self.processingState : processingState // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseCandidateReceiptDto].
extension ReleaseCandidateReceiptDtoPatterns on ReleaseCandidateReceiptDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseCandidateReceiptDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseCandidateReceiptDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseCandidateReceiptDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidateReceiptDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseCandidateReceiptDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidateReceiptDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReleasePlatform platform, @JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson)  String version, @JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson)  String buildNumber, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson)  String artifactId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson)  String applicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson)  String storeApplicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson)  String sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson)  String sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson)  String artifactSha256, @JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson)  DateTime uploadedAt, @JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson)  List<String> testingDestinations, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson)  String processingState, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson)  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseCandidateReceiptDto() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.artifactId,_that.applicationId,_that.storeApplicationId,_that.sourceCommitHash,_that.sourceFingerprint,_that.artifactSha256,_that.uploadedAt,_that.testingDestinations,_that.processingState,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReleasePlatform platform, @JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson)  String version, @JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson)  String buildNumber, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson)  String artifactId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson)  String applicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson)  String storeApplicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson)  String sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson)  String sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson)  String artifactSha256, @JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson)  DateTime uploadedAt, @JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson)  List<String> testingDestinations, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson)  String processingState, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson)  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidateReceiptDto():
return $default(_that.platform,_that.version,_that.buildNumber,_that.artifactId,_that.applicationId,_that.storeApplicationId,_that.sourceCommitHash,_that.sourceFingerprint,_that.artifactSha256,_that.uploadedAt,_that.testingDestinations,_that.processingState,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReleasePlatform platform, @JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson)  String version, @JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson)  String buildNumber, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson)  String artifactId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson)  String applicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson)  String storeApplicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson)  String sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson)  String sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson)  String artifactSha256, @JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson)  DateTime uploadedAt, @JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson)  List<String> testingDestinations, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson)  String processingState, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson)  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidateReceiptDto() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.artifactId,_that.applicationId,_that.storeApplicationId,_that.sourceCommitHash,_that.sourceFingerprint,_that.artifactSha256,_that.uploadedAt,_that.testingDestinations,_that.processingState,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, dateTimeUtc: true, disallowUnrecognizedKeys: true)
class _ReleaseCandidateReceiptDto extends ReleaseCandidateReceiptDto {
  const _ReleaseCandidateReceiptDto({required this.platform, @JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson) required this.version, @JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson) required this.buildNumber, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson) required this.artifactId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson) required this.applicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson) required this.storeApplicationId, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson) required this.sourceCommitHash, @JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson) required this.sourceFingerprint, @JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson) required this.artifactSha256, @JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson) required this.uploadedAt, @JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson) required final  List<String> testingDestinations, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson) required this.processingState, @JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson) required this.schemaVersion}): _testingDestinations = testingDestinations,super._();
  factory _ReleaseCandidateReceiptDto.fromJson(Map<String, dynamic> json) => _$ReleaseCandidateReceiptDtoFromJson(json);

@override final  ReleasePlatform platform;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson) final  String version;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson) final  String buildNumber;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson) final  String artifactId;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson) final  String applicationId;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson) final  String storeApplicationId;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson) final  String sourceCommitHash;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson) final  String sourceFingerprint;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson) final  String artifactSha256;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson) final  DateTime uploadedAt;
 final  List<String> _testingDestinations;
@override@JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson) List<String> get testingDestinations {
  if (_testingDestinations is EqualUnmodifiableListView) return _testingDestinations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testingDestinations);
}

@override@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson) final  String processingState;
@override@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson) final  int schemaVersion;

/// Create a copy of ReleaseCandidateReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseCandidateReceiptDtoCopyWith<_ReleaseCandidateReceiptDto> get copyWith => __$ReleaseCandidateReceiptDtoCopyWithImpl<_ReleaseCandidateReceiptDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseCandidateReceiptDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseCandidateReceiptDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceCommitHash, sourceCommitHash) || other.sourceCommitHash == sourceCommitHash)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other._testingDestinations, _testingDestinations)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,artifactId,applicationId,storeApplicationId,sourceCommitHash,sourceFingerprint,artifactSha256,uploadedAt,const DeepCollectionEquality().hash(_testingDestinations),processingState,schemaVersion);

@override
String toString() {
  return 'ReleaseCandidateReceiptDto(platform: $platform, version: $version, buildNumber: $buildNumber, artifactId: $artifactId, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceCommitHash: $sourceCommitHash, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, uploadedAt: $uploadedAt, testingDestinations: $testingDestinations, processingState: $processingState, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ReleaseCandidateReceiptDtoCopyWith<$Res> implements $ReleaseCandidateReceiptDtoCopyWith<$Res> {
  factory _$ReleaseCandidateReceiptDtoCopyWith(_ReleaseCandidateReceiptDto value, $Res Function(_ReleaseCandidateReceiptDto) _then) = __$ReleaseCandidateReceiptDtoCopyWithImpl;
@override @useResult
$Res call({
 ReleasePlatform platform,@JsonKey(fromJson: ReleaseCandidateReceiptDto._versionFromJson) String version,@JsonKey(fromJson: ReleaseCandidateReceiptDto._buildNumberFromJson) String buildNumber,@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactIdFromJson) String artifactId,@JsonKey(fromJson: ReleaseCandidateReceiptDto._applicationIdFromJson) String applicationId,@JsonKey(fromJson: ReleaseCandidateReceiptDto._storeApplicationIdFromJson) String storeApplicationId,@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceCommitHashFromJson) String sourceCommitHash,@JsonKey(fromJson: ReleaseCandidateReceiptDto._sourceFingerprintFromJson) String sourceFingerprint,@JsonKey(fromJson: ReleaseCandidateReceiptDto._artifactSha256FromJson) String artifactSha256,@JsonKey(fromJson: ReleaseCandidateReceiptDto._uploadedAtFromJson) DateTime uploadedAt,@JsonKey(fromJson: ReleaseCandidateReceiptDto._testingDestinationsFromJson) List<String> testingDestinations,@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._processingStateFromJson) String processingState,@JsonKey(required: true, disallowNullValue: true, fromJson: ReleaseCandidateReceiptDto._schemaVersionFromJson) int schemaVersion
});




}
/// @nodoc
class __$ReleaseCandidateReceiptDtoCopyWithImpl<$Res>
    implements _$ReleaseCandidateReceiptDtoCopyWith<$Res> {
  __$ReleaseCandidateReceiptDtoCopyWithImpl(this._self, this._then);

  final _ReleaseCandidateReceiptDto _self;
  final $Res Function(_ReleaseCandidateReceiptDto) _then;

/// Create a copy of ReleaseCandidateReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? artifactId = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceCommitHash = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? uploadedAt = null,Object? testingDestinations = null,Object? processingState = null,Object? schemaVersion = null,}) {
  return _then(_ReleaseCandidateReceiptDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceCommitHash: null == sourceCommitHash ? _self.sourceCommitHash : sourceCommitHash // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,artifactSha256: null == artifactSha256 ? _self.artifactSha256 : artifactSha256 // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,testingDestinations: null == testingDestinations ? _self._testingDestinations : testingDestinations // ignore: cast_nullable_to_non_nullable
as List<String>,processingState: null == processingState ? _self.processingState : processingState // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
