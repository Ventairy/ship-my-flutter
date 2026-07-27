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

 String get version; String get buildNumber; String get buildId; String get appId; String get bundleId; String get sourceSha; String get sourceFingerprint; String get ipaSha256; DateTime get uploadedAt; List<String> get testflightGroups; int get schemaVersion; Platform get platform;
/// Create a copy of CandidateReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CandidateReceiptCopyWith<CandidateReceipt> get copyWith => _$CandidateReceiptCopyWithImpl<CandidateReceipt>(this as CandidateReceipt, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CandidateReceipt&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.buildId, buildId) || other.buildId == buildId)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.sourceSha, sourceSha) || other.sourceSha == sourceSha)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.ipaSha256, ipaSha256) || other.ipaSha256 == ipaSha256)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other.testflightGroups, testflightGroups)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.platform, platform) || other.platform == platform));
}


@override
int get hashCode => Object.hash(runtimeType,version,buildNumber,buildId,appId,bundleId,sourceSha,sourceFingerprint,ipaSha256,uploadedAt,const DeepCollectionEquality().hash(testflightGroups),schemaVersion,platform);

@override
String toString() {
  return 'CandidateReceipt(version: $version, buildNumber: $buildNumber, buildId: $buildId, appId: $appId, bundleId: $bundleId, sourceSha: $sourceSha, sourceFingerprint: $sourceFingerprint, ipaSha256: $ipaSha256, uploadedAt: $uploadedAt, testflightGroups: $testflightGroups, schemaVersion: $schemaVersion, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $CandidateReceiptCopyWith<$Res>  {
  factory $CandidateReceiptCopyWith(CandidateReceipt value, $Res Function(CandidateReceipt) _then) = _$CandidateReceiptCopyWithImpl;
@useResult
$Res call({
 String version, String buildNumber, String buildId, String appId, String bundleId, String sourceSha, String sourceFingerprint, String ipaSha256, DateTime uploadedAt, List<String> testflightGroups, int schemaVersion, Platform platform
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
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? buildNumber = null,Object? buildId = null,Object? appId = null,Object? bundleId = null,Object? sourceSha = null,Object? sourceFingerprint = null,Object? ipaSha256 = null,Object? uploadedAt = null,Object? testflightGroups = null,Object? schemaVersion = null,Object? platform = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,buildId: null == buildId ? _self.buildId : buildId // ignore: cast_nullable_to_non_nullable
as String,appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,sourceSha: null == sourceSha ? _self.sourceSha : sourceSha // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,ipaSha256: null == ipaSha256 ? _self.ipaSha256 : ipaSha256 // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,testflightGroups: null == testflightGroups ? _self.testflightGroups : testflightGroups // ignore: cast_nullable_to_non_nullable
as List<String>,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String buildNumber,  String buildId,  String appId,  String bundleId,  String sourceSha,  String sourceFingerprint,  String ipaSha256,  DateTime uploadedAt,  List<String> testflightGroups,  int schemaVersion,  Platform platform)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CandidateReceipt() when $default != null:
return $default(_that.version,_that.buildNumber,_that.buildId,_that.appId,_that.bundleId,_that.sourceSha,_that.sourceFingerprint,_that.ipaSha256,_that.uploadedAt,_that.testflightGroups,_that.schemaVersion,_that.platform);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String buildNumber,  String buildId,  String appId,  String bundleId,  String sourceSha,  String sourceFingerprint,  String ipaSha256,  DateTime uploadedAt,  List<String> testflightGroups,  int schemaVersion,  Platform platform)  $default,) {final _that = this;
switch (_that) {
case _CandidateReceipt():
return $default(_that.version,_that.buildNumber,_that.buildId,_that.appId,_that.bundleId,_that.sourceSha,_that.sourceFingerprint,_that.ipaSha256,_that.uploadedAt,_that.testflightGroups,_that.schemaVersion,_that.platform);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String buildNumber,  String buildId,  String appId,  String bundleId,  String sourceSha,  String sourceFingerprint,  String ipaSha256,  DateTime uploadedAt,  List<String> testflightGroups,  int schemaVersion,  Platform platform)?  $default,) {final _that = this;
switch (_that) {
case _CandidateReceipt() when $default != null:
return $default(_that.version,_that.buildNumber,_that.buildId,_that.appId,_that.bundleId,_that.sourceSha,_that.sourceFingerprint,_that.ipaSha256,_that.uploadedAt,_that.testflightGroups,_that.schemaVersion,_that.platform);case _:
  return null;

}
}

}

/// @nodoc


class _CandidateReceipt extends CandidateReceipt {
  const _CandidateReceipt({required this.version, required this.buildNumber, required this.buildId, required this.appId, required this.bundleId, required this.sourceSha, required this.sourceFingerprint, required this.ipaSha256, required this.uploadedAt, required final  List<String> testflightGroups, this.schemaVersion = 1, this.platform = Platform.ios}): _testflightGroups = testflightGroups,super._();
  

@override final  String version;
@override final  String buildNumber;
@override final  String buildId;
@override final  String appId;
@override final  String bundleId;
@override final  String sourceSha;
@override final  String sourceFingerprint;
@override final  String ipaSha256;
@override final  DateTime uploadedAt;
 final  List<String> _testflightGroups;
@override List<String> get testflightGroups {
  if (_testflightGroups is EqualUnmodifiableListView) return _testflightGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testflightGroups);
}

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  Platform platform;

/// Create a copy of CandidateReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CandidateReceiptCopyWith<_CandidateReceipt> get copyWith => __$CandidateReceiptCopyWithImpl<_CandidateReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CandidateReceipt&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.buildId, buildId) || other.buildId == buildId)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.sourceSha, sourceSha) || other.sourceSha == sourceSha)&&(identical(other.sourceFingerprint, sourceFingerprint) || other.sourceFingerprint == sourceFingerprint)&&(identical(other.ipaSha256, ipaSha256) || other.ipaSha256 == ipaSha256)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other._testflightGroups, _testflightGroups)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.platform, platform) || other.platform == platform));
}


@override
int get hashCode => Object.hash(runtimeType,version,buildNumber,buildId,appId,bundleId,sourceSha,sourceFingerprint,ipaSha256,uploadedAt,const DeepCollectionEquality().hash(_testflightGroups),schemaVersion,platform);

@override
String toString() {
  return 'CandidateReceipt(version: $version, buildNumber: $buildNumber, buildId: $buildId, appId: $appId, bundleId: $bundleId, sourceSha: $sourceSha, sourceFingerprint: $sourceFingerprint, ipaSha256: $ipaSha256, uploadedAt: $uploadedAt, testflightGroups: $testflightGroups, schemaVersion: $schemaVersion, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$CandidateReceiptCopyWith<$Res> implements $CandidateReceiptCopyWith<$Res> {
  factory _$CandidateReceiptCopyWith(_CandidateReceipt value, $Res Function(_CandidateReceipt) _then) = __$CandidateReceiptCopyWithImpl;
@override @useResult
$Res call({
 String version, String buildNumber, String buildId, String appId, String bundleId, String sourceSha, String sourceFingerprint, String ipaSha256, DateTime uploadedAt, List<String> testflightGroups, int schemaVersion, Platform platform
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
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? buildNumber = null,Object? buildId = null,Object? appId = null,Object? bundleId = null,Object? sourceSha = null,Object? sourceFingerprint = null,Object? ipaSha256 = null,Object? uploadedAt = null,Object? testflightGroups = null,Object? schemaVersion = null,Object? platform = null,}) {
  return _then(_CandidateReceipt(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,buildId: null == buildId ? _self.buildId : buildId // ignore: cast_nullable_to_non_nullable
as String,appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,sourceSha: null == sourceSha ? _self.sourceSha : sourceSha // ignore: cast_nullable_to_non_nullable
as String,sourceFingerprint: null == sourceFingerprint ? _self.sourceFingerprint : sourceFingerprint // ignore: cast_nullable_to_non_nullable
as String,ipaSha256: null == ipaSha256 ? _self.ipaSha256 : ipaSha256 // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,testflightGroups: null == testflightGroups ? _self._testflightGroups : testflightGroups // ignore: cast_nullable_to_non_nullable
as List<String>,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,
  ));
}


}

// dart format on
