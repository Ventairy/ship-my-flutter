// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apple_ship_release_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppleShipReleaseResultDto {

 String get version; String get tag; String get artifactId; String get buildNumber; String get githubReleaseUrl; ReleasePlatform get platform; String? get appStoreVersionId; String? get reviewSubmissionId; String? get betaReviewSubmissionId;
/// Create a copy of AppleShipReleaseResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleShipReleaseResultDtoCopyWith<AppleShipReleaseResultDto> get copyWith => _$AppleShipReleaseResultDtoCopyWithImpl<AppleShipReleaseResultDto>(this as AppleShipReleaseResultDto, _$identity);

  /// Serializes this AppleShipReleaseResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleShipReleaseResultDto&&(identical(other.version, version) || other.version == version)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.githubReleaseUrl, githubReleaseUrl) || other.githubReleaseUrl == githubReleaseUrl)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appStoreVersionId, appStoreVersionId) || other.appStoreVersionId == appStoreVersionId)&&(identical(other.reviewSubmissionId, reviewSubmissionId) || other.reviewSubmissionId == reviewSubmissionId)&&(identical(other.betaReviewSubmissionId, betaReviewSubmissionId) || other.betaReviewSubmissionId == betaReviewSubmissionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,tag,artifactId,buildNumber,githubReleaseUrl,platform,appStoreVersionId,reviewSubmissionId,betaReviewSubmissionId);

@override
String toString() {
  return 'AppleShipReleaseResultDto(version: $version, tag: $tag, artifactId: $artifactId, buildNumber: $buildNumber, githubReleaseUrl: $githubReleaseUrl, platform: $platform, appStoreVersionId: $appStoreVersionId, reviewSubmissionId: $reviewSubmissionId, betaReviewSubmissionId: $betaReviewSubmissionId)';
}


}

/// @nodoc
abstract mixin class $AppleShipReleaseResultDtoCopyWith<$Res>  {
  factory $AppleShipReleaseResultDtoCopyWith(AppleShipReleaseResultDto value, $Res Function(AppleShipReleaseResultDto) _then) = _$AppleShipReleaseResultDtoCopyWithImpl;
@useResult
$Res call({
 String version, String tag, String artifactId, String buildNumber, String githubReleaseUrl, ReleasePlatform platform, String? appStoreVersionId, String? reviewSubmissionId, String? betaReviewSubmissionId
});




}
/// @nodoc
class _$AppleShipReleaseResultDtoCopyWithImpl<$Res>
    implements $AppleShipReleaseResultDtoCopyWith<$Res> {
  _$AppleShipReleaseResultDtoCopyWithImpl(this._self, this._then);

  final AppleShipReleaseResultDto _self;
  final $Res Function(AppleShipReleaseResultDto) _then;

/// Create a copy of AppleShipReleaseResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? tag = null,Object? artifactId = null,Object? buildNumber = null,Object? githubReleaseUrl = null,Object? platform = null,Object? appStoreVersionId = freezed,Object? reviewSubmissionId = freezed,Object? betaReviewSubmissionId = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,githubReleaseUrl: null == githubReleaseUrl ? _self.githubReleaseUrl : githubReleaseUrl // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,appStoreVersionId: freezed == appStoreVersionId ? _self.appStoreVersionId : appStoreVersionId // ignore: cast_nullable_to_non_nullable
as String?,reviewSubmissionId: freezed == reviewSubmissionId ? _self.reviewSubmissionId : reviewSubmissionId // ignore: cast_nullable_to_non_nullable
as String?,betaReviewSubmissionId: freezed == betaReviewSubmissionId ? _self.betaReviewSubmissionId : betaReviewSubmissionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleShipReleaseResultDto].
extension AppleShipReleaseResultDtoPatterns on AppleShipReleaseResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleShipReleaseResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleShipReleaseResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleShipReleaseResultDto value)  $default,){
final _that = this;
switch (_that) {
case _AppleShipReleaseResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleShipReleaseResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppleShipReleaseResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String tag,  String artifactId,  String buildNumber,  String githubReleaseUrl,  ReleasePlatform platform,  String? appStoreVersionId,  String? reviewSubmissionId,  String? betaReviewSubmissionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleShipReleaseResultDto() when $default != null:
return $default(_that.version,_that.tag,_that.artifactId,_that.buildNumber,_that.githubReleaseUrl,_that.platform,_that.appStoreVersionId,_that.reviewSubmissionId,_that.betaReviewSubmissionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String tag,  String artifactId,  String buildNumber,  String githubReleaseUrl,  ReleasePlatform platform,  String? appStoreVersionId,  String? reviewSubmissionId,  String? betaReviewSubmissionId)  $default,) {final _that = this;
switch (_that) {
case _AppleShipReleaseResultDto():
return $default(_that.version,_that.tag,_that.artifactId,_that.buildNumber,_that.githubReleaseUrl,_that.platform,_that.appStoreVersionId,_that.reviewSubmissionId,_that.betaReviewSubmissionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String tag,  String artifactId,  String buildNumber,  String githubReleaseUrl,  ReleasePlatform platform,  String? appStoreVersionId,  String? reviewSubmissionId,  String? betaReviewSubmissionId)?  $default,) {final _that = this;
switch (_that) {
case _AppleShipReleaseResultDto() when $default != null:
return $default(_that.version,_that.tag,_that.artifactId,_that.buildNumber,_that.githubReleaseUrl,_that.platform,_that.appStoreVersionId,_that.reviewSubmissionId,_that.betaReviewSubmissionId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, includeIfNull: false)
class _AppleShipReleaseResultDto implements AppleShipReleaseResultDto {
  const _AppleShipReleaseResultDto({required this.version, required this.tag, required this.artifactId, required this.buildNumber, required this.githubReleaseUrl, this.platform = ReleasePlatform.ios, this.appStoreVersionId, this.reviewSubmissionId, this.betaReviewSubmissionId});
  factory _AppleShipReleaseResultDto.fromJson(Map<String, dynamic> json) => _$AppleShipReleaseResultDtoFromJson(json);

@override final  String version;
@override final  String tag;
@override final  String artifactId;
@override final  String buildNumber;
@override final  String githubReleaseUrl;
@override@JsonKey() final  ReleasePlatform platform;
@override final  String? appStoreVersionId;
@override final  String? reviewSubmissionId;
@override final  String? betaReviewSubmissionId;

/// Create a copy of AppleShipReleaseResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleShipReleaseResultDtoCopyWith<_AppleShipReleaseResultDto> get copyWith => __$AppleShipReleaseResultDtoCopyWithImpl<_AppleShipReleaseResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppleShipReleaseResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleShipReleaseResultDto&&(identical(other.version, version) || other.version == version)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.githubReleaseUrl, githubReleaseUrl) || other.githubReleaseUrl == githubReleaseUrl)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appStoreVersionId, appStoreVersionId) || other.appStoreVersionId == appStoreVersionId)&&(identical(other.reviewSubmissionId, reviewSubmissionId) || other.reviewSubmissionId == reviewSubmissionId)&&(identical(other.betaReviewSubmissionId, betaReviewSubmissionId) || other.betaReviewSubmissionId == betaReviewSubmissionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,tag,artifactId,buildNumber,githubReleaseUrl,platform,appStoreVersionId,reviewSubmissionId,betaReviewSubmissionId);

@override
String toString() {
  return 'AppleShipReleaseResultDto(version: $version, tag: $tag, artifactId: $artifactId, buildNumber: $buildNumber, githubReleaseUrl: $githubReleaseUrl, platform: $platform, appStoreVersionId: $appStoreVersionId, reviewSubmissionId: $reviewSubmissionId, betaReviewSubmissionId: $betaReviewSubmissionId)';
}


}

/// @nodoc
abstract mixin class _$AppleShipReleaseResultDtoCopyWith<$Res> implements $AppleShipReleaseResultDtoCopyWith<$Res> {
  factory _$AppleShipReleaseResultDtoCopyWith(_AppleShipReleaseResultDto value, $Res Function(_AppleShipReleaseResultDto) _then) = __$AppleShipReleaseResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String version, String tag, String artifactId, String buildNumber, String githubReleaseUrl, ReleasePlatform platform, String? appStoreVersionId, String? reviewSubmissionId, String? betaReviewSubmissionId
});




}
/// @nodoc
class __$AppleShipReleaseResultDtoCopyWithImpl<$Res>
    implements _$AppleShipReleaseResultDtoCopyWith<$Res> {
  __$AppleShipReleaseResultDtoCopyWithImpl(this._self, this._then);

  final _AppleShipReleaseResultDto _self;
  final $Res Function(_AppleShipReleaseResultDto) _then;

/// Create a copy of AppleShipReleaseResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? tag = null,Object? artifactId = null,Object? buildNumber = null,Object? githubReleaseUrl = null,Object? platform = null,Object? appStoreVersionId = freezed,Object? reviewSubmissionId = freezed,Object? betaReviewSubmissionId = freezed,}) {
  return _then(_AppleShipReleaseResultDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,githubReleaseUrl: null == githubReleaseUrl ? _self.githubReleaseUrl : githubReleaseUrl // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as ReleasePlatform,appStoreVersionId: freezed == appStoreVersionId ? _self.appStoreVersionId : appStoreVersionId // ignore: cast_nullable_to_non_nullable
as String?,reviewSubmissionId: freezed == reviewSubmissionId ? _self.reviewSubmissionId : reviewSubmissionId // ignore: cast_nullable_to_non_nullable
as String?,betaReviewSubmissionId: freezed == betaReviewSubmissionId ? _self.betaReviewSubmissionId : betaReviewSubmissionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
