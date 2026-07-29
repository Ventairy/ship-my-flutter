// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_release_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitHubReleaseDto {

@JsonKey(name: 'html_url') String get htmlUrl;@JsonKey(name: 'tag_name') String get tagName;@JsonKey(name: 'target_commitish') String get targetCommitish;
/// Create a copy of GitHubReleaseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitHubReleaseDtoCopyWith<GitHubReleaseDto> get copyWith => _$GitHubReleaseDtoCopyWithImpl<GitHubReleaseDto>(this as GitHubReleaseDto, _$identity);

  /// Serializes this GitHubReleaseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitHubReleaseDto&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.targetCommitish, targetCommitish) || other.targetCommitish == targetCommitish));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,htmlUrl,tagName,targetCommitish);

@override
String toString() {
  return 'GitHubReleaseDto(htmlUrl: $htmlUrl, tagName: $tagName, targetCommitish: $targetCommitish)';
}


}

/// @nodoc
abstract mixin class $GitHubReleaseDtoCopyWith<$Res>  {
  factory $GitHubReleaseDtoCopyWith(GitHubReleaseDto value, $Res Function(GitHubReleaseDto) _then) = _$GitHubReleaseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'html_url') String htmlUrl,@JsonKey(name: 'tag_name') String tagName,@JsonKey(name: 'target_commitish') String targetCommitish
});




}
/// @nodoc
class _$GitHubReleaseDtoCopyWithImpl<$Res>
    implements $GitHubReleaseDtoCopyWith<$Res> {
  _$GitHubReleaseDtoCopyWithImpl(this._self, this._then);

  final GitHubReleaseDto _self;
  final $Res Function(GitHubReleaseDto) _then;

/// Create a copy of GitHubReleaseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? htmlUrl = null,Object? tagName = null,Object? targetCommitish = null,}) {
  return _then(_self.copyWith(
htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,targetCommitish: null == targetCommitish ? _self.targetCommitish : targetCommitish // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GitHubReleaseDto].
extension GitHubReleaseDtoPatterns on GitHubReleaseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitHubReleaseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitHubReleaseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitHubReleaseDto value)  $default,){
final _that = this;
switch (_that) {
case _GitHubReleaseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitHubReleaseDto value)?  $default,){
final _that = this;
switch (_that) {
case _GitHubReleaseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'html_url')  String htmlUrl, @JsonKey(name: 'tag_name')  String tagName, @JsonKey(name: 'target_commitish')  String targetCommitish)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitHubReleaseDto() when $default != null:
return $default(_that.htmlUrl,_that.tagName,_that.targetCommitish);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'html_url')  String htmlUrl, @JsonKey(name: 'tag_name')  String tagName, @JsonKey(name: 'target_commitish')  String targetCommitish)  $default,) {final _that = this;
switch (_that) {
case _GitHubReleaseDto():
return $default(_that.htmlUrl,_that.tagName,_that.targetCommitish);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'html_url')  String htmlUrl, @JsonKey(name: 'tag_name')  String tagName, @JsonKey(name: 'target_commitish')  String targetCommitish)?  $default,) {final _that = this;
switch (_that) {
case _GitHubReleaseDto() when $default != null:
return $default(_that.htmlUrl,_that.tagName,_that.targetCommitish);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _GitHubReleaseDto implements GitHubReleaseDto {
  const _GitHubReleaseDto({@JsonKey(name: 'html_url') required this.htmlUrl, @JsonKey(name: 'tag_name') required this.tagName, @JsonKey(name: 'target_commitish') required this.targetCommitish});
  factory _GitHubReleaseDto.fromJson(Map<String, dynamic> json) => _$GitHubReleaseDtoFromJson(json);

@override@JsonKey(name: 'html_url') final  String htmlUrl;
@override@JsonKey(name: 'tag_name') final  String tagName;
@override@JsonKey(name: 'target_commitish') final  String targetCommitish;

/// Create a copy of GitHubReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitHubReleaseDtoCopyWith<_GitHubReleaseDto> get copyWith => __$GitHubReleaseDtoCopyWithImpl<_GitHubReleaseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitHubReleaseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitHubReleaseDto&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.targetCommitish, targetCommitish) || other.targetCommitish == targetCommitish));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,htmlUrl,tagName,targetCommitish);

@override
String toString() {
  return 'GitHubReleaseDto(htmlUrl: $htmlUrl, tagName: $tagName, targetCommitish: $targetCommitish)';
}


}

/// @nodoc
abstract mixin class _$GitHubReleaseDtoCopyWith<$Res> implements $GitHubReleaseDtoCopyWith<$Res> {
  factory _$GitHubReleaseDtoCopyWith(_GitHubReleaseDto value, $Res Function(_GitHubReleaseDto) _then) = __$GitHubReleaseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'html_url') String htmlUrl,@JsonKey(name: 'tag_name') String tagName,@JsonKey(name: 'target_commitish') String targetCommitish
});




}
/// @nodoc
class __$GitHubReleaseDtoCopyWithImpl<$Res>
    implements _$GitHubReleaseDtoCopyWith<$Res> {
  __$GitHubReleaseDtoCopyWithImpl(this._self, this._then);

  final _GitHubReleaseDto _self;
  final $Res Function(_GitHubReleaseDto) _then;

/// Create a copy of GitHubReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? htmlUrl = null,Object? tagName = null,Object? targetCommitish = null,}) {
  return _then(_GitHubReleaseDto(
htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,targetCommitish: null == targetCommitish ? _self.targetCommitish : targetCommitish // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
