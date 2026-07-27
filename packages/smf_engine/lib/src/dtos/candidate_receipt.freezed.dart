// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'candidate_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CandidateReceipt {

 Platform get platform; String get version; String get buildNumber; String get artifactId; String get applicationId; String get storeApplicationId; String get sourceSha; String get sourceFingerprint; String get artifactSha256; DateTime get uploadedAt; List<String> get testingDestinations; String get processingState; int get schemaVersion;
/// Create a copy of CandidateReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CandidateReceiptCopyWith<CandidateReceipt> get copyWith => _$CandidateReceiptCopyWithImpl<CandidateReceipt>(this as CandidateReceipt, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CandidateReceipt&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceSha, sourceSha) || other.sourceSha == sourceSha)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other.testingDestinations, testingDestinations)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}


@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,artifactId,applicationId,storeApplicationId,sourceSha,sourceFingerprint,artifactSha256,uploadedAt,const DeepCollectionEquality().hash(testingDestinations),processingState,schemaVersion);

@override
String toString() {
  return 'CandidateReceipt(platform: $platform, version: $version, buildNumber: $buildNumber, artifactId: $artifactId, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceSha: $sourceSha, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, uploadedAt: $uploadedAt, testingDestinations: $testingDestinations, processingState: $processingState, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $CandidateReceiptCopyWith<$Res>  {
  factory $CandidateReceiptCopyWith(CandidateReceipt value, $Res Function(CandidateReceipt) _then) = _$CandidateReceiptCopyWithImpl;
@useResult
$Res call({
 Platform platform, String version, String buildNumber, String artifactId, String applicationId, String storeApplicationId, String sourceSha, String sourceFingerprint, String artifactSha256, DateTime uploadedAt, List<String> testingDestinations, String processingState, int schemaVersion
});




}
/// @nodoc
class _$CandidateReceiptCopyWithImpl<$Res>
    implements $CandidateReceiptCopyWith<$Res> {
  _$CandidateReceiptCopyWithImpl(this._self, this._then);

  final CandidateReceipt _self;
  final $Res Function(CandidateReceipt) _then;

/// Create a copy of CandidateReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? artifactId = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceSha = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? uploadedAt = null,Object? testingDestinations = null,Object? processingState = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceSha: null == sourceSha ? _self.sourceSha : sourceSha // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [CandidateReceipt].
extension CandidateReceiptPatterns on CandidateReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CandidateReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CandidateReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CandidateReceipt value)  $default,){
final _that = this;
switch (_that) {
case _CandidateReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CandidateReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _CandidateReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Platform platform,  String version,  String buildNumber,  String artifactId,  String applicationId,  String storeApplicationId,  String sourceSha,  String sourceFingerprint,  String artifactSha256,  DateTime uploadedAt,  List<String> testingDestinations,  String processingState,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CandidateReceipt() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.artifactId,_that.applicationId,_that.storeApplicationId,_that.sourceSha,_that.sourceFingerprint,_that.artifactSha256,_that.uploadedAt,_that.testingDestinations,_that.processingState,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Platform platform,  String version,  String buildNumber,  String artifactId,  String applicationId,  String storeApplicationId,  String sourceSha,  String sourceFingerprint,  String artifactSha256,  DateTime uploadedAt,  List<String> testingDestinations,  String processingState,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _CandidateReceipt():
return $default(_that.platform,_that.version,_that.buildNumber,_that.artifactId,_that.applicationId,_that.storeApplicationId,_that.sourceSha,_that.sourceFingerprint,_that.artifactSha256,_that.uploadedAt,_that.testingDestinations,_that.processingState,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Platform platform,  String version,  String buildNumber,  String artifactId,  String applicationId,  String storeApplicationId,  String sourceSha,  String sourceFingerprint,  String artifactSha256,  DateTime uploadedAt,  List<String> testingDestinations,  String processingState,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _CandidateReceipt() when $default != null:
return $default(_that.platform,_that.version,_that.buildNumber,_that.artifactId,_that.applicationId,_that.storeApplicationId,_that.sourceSha,_that.sourceFingerprint,_that.artifactSha256,_that.uploadedAt,_that.testingDestinations,_that.processingState,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc


class _CandidateReceipt extends CandidateReceipt {
  const _CandidateReceipt({required this.platform, required this.version, required this.buildNumber, required this.artifactId, required this.applicationId, required this.storeApplicationId, required this.sourceSha, required this.sourceFingerprint, required this.artifactSha256, required this.uploadedAt, required final  List<String> testingDestinations, this.processingState = 'VALID', this.schemaVersion = 2}): _testingDestinations = testingDestinations,super._();
  

@override final  Platform platform;
@override final  String version;
@override final  String buildNumber;
@override final  String artifactId;
@override final  String applicationId;
@override final  String storeApplicationId;
@override final  String sourceSha;
@override final  String sourceFingerprint;
@override final  String artifactSha256;
@override final  DateTime uploadedAt;
 final  List<String> _testingDestinations;
@override List<String> get testingDestinations {
  if (_testingDestinations is EqualUnmodifiableListView) return _testingDestinations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testingDestinations);
}

@override@JsonKey() final  String processingState;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of CandidateReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CandidateReceiptCopyWith<_CandidateReceipt> get copyWith => __$CandidateReceiptCopyWithImpl<_CandidateReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CandidateReceipt&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.storeApplicationId, storeApplicationId) || other.storeApplicationId == storeApplicationId)&&(identical(other.sourceSha, sourceSha) || other.sourceSha == sourceSha)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.artifactSha256, artifactSha256) || other.artifactSha256 == artifactSha256)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other._testingDestinations, _testingDestinations)&&(identical(other.processingState, processingState) || other.processingState == processingState)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}


@override
int get hashCode => Object.hash(runtimeType,platform,version,buildNumber,artifactId,applicationId,storeApplicationId,sourceSha,sourceFingerprint,artifactSha256,uploadedAt,const DeepCollectionEquality().hash(_testingDestinations),processingState,schemaVersion);

@override
String toString() {
  return 'CandidateReceipt(platform: $platform, version: $version, buildNumber: $buildNumber, artifactId: $artifactId, applicationId: $applicationId, storeApplicationId: $storeApplicationId, sourceSha: $sourceSha, sourceFingerprint: $sourceFingerprint, artifactSha256: $artifactSha256, uploadedAt: $uploadedAt, testingDestinations: $testingDestinations, processingState: $processingState, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$CandidateReceiptCopyWith<$Res> implements $CandidateReceiptCopyWith<$Res> {
  factory _$CandidateReceiptCopyWith(_CandidateReceipt value, $Res Function(_CandidateReceipt) _then) = __$CandidateReceiptCopyWithImpl;
@override @useResult
$Res call({
 Platform platform, String version, String buildNumber, String artifactId, String applicationId, String storeApplicationId, String sourceSha, String sourceFingerprint, String artifactSha256, DateTime uploadedAt, List<String> testingDestinations, String processingState, int schemaVersion
});




}
/// @nodoc
class __$CandidateReceiptCopyWithImpl<$Res>
    implements _$CandidateReceiptCopyWith<$Res> {
  __$CandidateReceiptCopyWithImpl(this._self, this._then);

  final _CandidateReceipt _self;
  final $Res Function(_CandidateReceipt) _then;

/// Create a copy of CandidateReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? version = null,Object? buildNumber = null,Object? artifactId = null,Object? applicationId = null,Object? storeApplicationId = null,Object? sourceSha = null,Object? sourceFingerprint = null,Object? artifactSha256 = null,Object? uploadedAt = null,Object? testingDestinations = null,Object? processingState = null,Object? schemaVersion = null,}) {
  return _then(_CandidateReceipt(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,storeApplicationId: null == storeApplicationId ? _self.storeApplicationId : storeApplicationId // ignore: cast_nullable_to_non_nullable
as String,sourceSha: null == sourceSha ? _self.sourceSha : sourceSha // ignore: cast_nullable_to_non_nullable
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
