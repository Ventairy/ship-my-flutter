// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitHubRelease {

@JsonKey(name: 'html_url') String get htmlUrl;
/// Create a copy of GitHubRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitHubReleaseCopyWith<GitHubRelease> get copyWith => _$GitHubReleaseCopyWithImpl<GitHubRelease>(this as GitHubRelease, _$identity);

  /// Serializes this GitHubRelease to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitHubRelease&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,htmlUrl);

@override
String toString() {
  return 'GitHubRelease(htmlUrl: $htmlUrl)';
}


}

/// @nodoc
abstract mixin class $GitHubReleaseCopyWith<$Res>  {
  factory $GitHubReleaseCopyWith(GitHubRelease value, $Res Function(GitHubRelease) _then) = _$GitHubReleaseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'html_url') String htmlUrl
});




}
/// @nodoc
class _$GitHubReleaseCopyWithImpl<$Res>
    implements $GitHubReleaseCopyWith<$Res> {
  _$GitHubReleaseCopyWithImpl(this._self, this._then);

  final GitHubRelease _self;
  final $Res Function(GitHubRelease) _then;

/// Create a copy of GitHubRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? htmlUrl = null,}) {
  return _then(_self.copyWith(
htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GitHubRelease].
extension GitHubReleasePatterns on GitHubRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitHubRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitHubRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitHubRelease value)  $default,){
final _that = this;
switch (_that) {
case _GitHubRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitHubRelease value)?  $default,){
final _that = this;
switch (_that) {
case _GitHubRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'html_url')  String htmlUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitHubRelease() when $default != null:
return $default(_that.htmlUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'html_url')  String htmlUrl)  $default,) {final _that = this;
switch (_that) {
case _GitHubRelease():
return $default(_that.htmlUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'html_url')  String htmlUrl)?  $default,) {final _that = this;
switch (_that) {
case _GitHubRelease() when $default != null:
return $default(_that.htmlUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _GitHubRelease implements GitHubRelease {
  const _GitHubRelease({@JsonKey(name: 'html_url') required this.htmlUrl});
  factory _GitHubRelease.fromJson(Map<String, dynamic> json) => _$GitHubReleaseFromJson(json);

@override@JsonKey(name: 'html_url') final  String htmlUrl;

/// Create a copy of GitHubRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitHubReleaseCopyWith<_GitHubRelease> get copyWith => __$GitHubReleaseCopyWithImpl<_GitHubRelease>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitHubReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitHubRelease&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,htmlUrl);

@override
String toString() {
  return 'GitHubRelease(htmlUrl: $htmlUrl)';
}


}

/// @nodoc
abstract mixin class _$GitHubReleaseCopyWith<$Res> implements $GitHubReleaseCopyWith<$Res> {
  factory _$GitHubReleaseCopyWith(_GitHubRelease value, $Res Function(_GitHubRelease) _then) = __$GitHubReleaseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'html_url') String htmlUrl
});




}
/// @nodoc
class __$GitHubReleaseCopyWithImpl<$Res>
    implements _$GitHubReleaseCopyWith<$Res> {
  __$GitHubReleaseCopyWithImpl(this._self, this._then);

  final _GitHubRelease _self;
  final $Res Function(_GitHubRelease) _then;

/// Create a copy of GitHubRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? htmlUrl = null,}) {
  return _then(_GitHubRelease(
htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
