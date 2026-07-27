// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promotion_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromotionResult {

 String get version; String get tag; String get artifactId; String get buildNumber; String get githubReleaseUrl; Platform get platform; String? get appStoreVersionId; String? get reviewSubmissionId;
/// Create a copy of PromotionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromotionResultCopyWith<PromotionResult> get copyWith => _$PromotionResultCopyWithImpl<PromotionResult>(this as PromotionResult, _$identity);

  /// Serializes this PromotionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromotionResult&&(identical(other.version, version) || other.version == version)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.githubReleaseUrl, githubReleaseUrl) || other.githubReleaseUrl == githubReleaseUrl)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appStoreVersionId, appStoreVersionId) || other.appStoreVersionId == appStoreVersionId)&&(identical(other.reviewSubmissionId, reviewSubmissionId) || other.reviewSubmissionId == reviewSubmissionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,tag,artifactId,buildNumber,githubReleaseUrl,platform,appStoreVersionId,reviewSubmissionId);

@override
String toString() {
  return 'PromotionResult(version: $version, tag: $tag, artifactId: $artifactId, buildNumber: $buildNumber, githubReleaseUrl: $githubReleaseUrl, platform: $platform, appStoreVersionId: $appStoreVersionId, reviewSubmissionId: $reviewSubmissionId)';
}


}

/// @nodoc
abstract mixin class $PromotionResultCopyWith<$Res>  {
  factory $PromotionResultCopyWith(PromotionResult value, $Res Function(PromotionResult) _then) = _$PromotionResultCopyWithImpl;
@useResult
$Res call({
 String version, String tag, String artifactId, String buildNumber, String githubReleaseUrl, Platform platform, String? appStoreVersionId, String? reviewSubmissionId
});




}
/// @nodoc
class _$PromotionResultCopyWithImpl<$Res>
    implements $PromotionResultCopyWith<$Res> {
  _$PromotionResultCopyWithImpl(this._self, this._then);

  final PromotionResult _self;
  final $Res Function(PromotionResult) _then;

/// Create a copy of PromotionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? tag = null,Object? artifactId = null,Object? buildNumber = null,Object? githubReleaseUrl = null,Object? platform = null,Object? appStoreVersionId = freezed,Object? reviewSubmissionId = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,githubReleaseUrl: null == githubReleaseUrl ? _self.githubReleaseUrl : githubReleaseUrl // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,appStoreVersionId: freezed == appStoreVersionId ? _self.appStoreVersionId : appStoreVersionId // ignore: cast_nullable_to_non_nullable
as String?,reviewSubmissionId: freezed == reviewSubmissionId ? _self.reviewSubmissionId : reviewSubmissionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PromotionResult].
extension PromotionResultPatterns on PromotionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromotionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromotionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromotionResult value)  $default,){
final _that = this;
switch (_that) {
case _PromotionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromotionResult value)?  $default,){
final _that = this;
switch (_that) {
case _PromotionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String tag,  String artifactId,  String buildNumber,  String githubReleaseUrl,  Platform platform,  String? appStoreVersionId,  String? reviewSubmissionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromotionResult() when $default != null:
return $default(_that.version,_that.tag,_that.artifactId,_that.buildNumber,_that.githubReleaseUrl,_that.platform,_that.appStoreVersionId,_that.reviewSubmissionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String tag,  String artifactId,  String buildNumber,  String githubReleaseUrl,  Platform platform,  String? appStoreVersionId,  String? reviewSubmissionId)  $default,) {final _that = this;
switch (_that) {
case _PromotionResult():
return $default(_that.version,_that.tag,_that.artifactId,_that.buildNumber,_that.githubReleaseUrl,_that.platform,_that.appStoreVersionId,_that.reviewSubmissionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String tag,  String artifactId,  String buildNumber,  String githubReleaseUrl,  Platform platform,  String? appStoreVersionId,  String? reviewSubmissionId)?  $default,) {final _that = this;
switch (_that) {
case _PromotionResult() when $default != null:
return $default(_that.version,_that.tag,_that.artifactId,_that.buildNumber,_that.githubReleaseUrl,_that.platform,_that.appStoreVersionId,_that.reviewSubmissionId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, includeIfNull: false)
class _PromotionResult implements PromotionResult {
  const _PromotionResult({required this.version, required this.tag, required this.artifactId, required this.buildNumber, required this.githubReleaseUrl, this.platform = Platform.ios, this.appStoreVersionId, this.reviewSubmissionId});
  factory _PromotionResult.fromJson(Map<String, dynamic> json) => _$PromotionResultFromJson(json);

@override final  String version;
@override final  String tag;
@override final  String artifactId;
@override final  String buildNumber;
@override final  String githubReleaseUrl;
@override@JsonKey() final  Platform platform;
@override final  String? appStoreVersionId;
@override final  String? reviewSubmissionId;

/// Create a copy of PromotionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromotionResultCopyWith<_PromotionResult> get copyWith => __$PromotionResultCopyWithImpl<_PromotionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromotionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromotionResult&&(identical(other.version, version) || other.version == version)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.artifactId, artifactId) || other.artifactId == artifactId)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.githubReleaseUrl, githubReleaseUrl) || other.githubReleaseUrl == githubReleaseUrl)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appStoreVersionId, appStoreVersionId) || other.appStoreVersionId == appStoreVersionId)&&(identical(other.reviewSubmissionId, reviewSubmissionId) || other.reviewSubmissionId == reviewSubmissionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,tag,artifactId,buildNumber,githubReleaseUrl,platform,appStoreVersionId,reviewSubmissionId);

@override
String toString() {
  return 'PromotionResult(version: $version, tag: $tag, artifactId: $artifactId, buildNumber: $buildNumber, githubReleaseUrl: $githubReleaseUrl, platform: $platform, appStoreVersionId: $appStoreVersionId, reviewSubmissionId: $reviewSubmissionId)';
}


}

/// @nodoc
abstract mixin class _$PromotionResultCopyWith<$Res> implements $PromotionResultCopyWith<$Res> {
  factory _$PromotionResultCopyWith(_PromotionResult value, $Res Function(_PromotionResult) _then) = __$PromotionResultCopyWithImpl;
@override @useResult
$Res call({
 String version, String tag, String artifactId, String buildNumber, String githubReleaseUrl, Platform platform, String? appStoreVersionId, String? reviewSubmissionId
});




}
/// @nodoc
class __$PromotionResultCopyWithImpl<$Res>
    implements _$PromotionResultCopyWith<$Res> {
  __$PromotionResultCopyWithImpl(this._self, this._then);

  final _PromotionResult _self;
  final $Res Function(_PromotionResult) _then;

/// Create a copy of PromotionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? tag = null,Object? artifactId = null,Object? buildNumber = null,Object? githubReleaseUrl = null,Object? platform = null,Object? appStoreVersionId = freezed,Object? reviewSubmissionId = freezed,}) {
  return _then(_PromotionResult(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,artifactId: null == artifactId ? _self.artifactId : artifactId // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
as String,githubReleaseUrl: null == githubReleaseUrl ? _self.githubReleaseUrl : githubReleaseUrl // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform,appStoreVersionId: freezed == appStoreVersionId ? _self.appStoreVersionId : appStoreVersionId // ignore: cast_nullable_to_non_nullable
as String?,reviewSubmissionId: freezed == reviewSubmissionId ? _self.reviewSubmissionId : reviewSubmissionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
