// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_pull_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitHubPullRequest {

 int get number;
/// Create a copy of GitHubPullRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitHubPullRequestCopyWith<GitHubPullRequest> get copyWith => _$GitHubPullRequestCopyWithImpl<GitHubPullRequest>(this as GitHubPullRequest, _$identity);

  /// Serializes this GitHubPullRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitHubPullRequest&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number);

@override
String toString() {
  return 'GitHubPullRequest(number: $number)';
}


}

/// @nodoc
abstract mixin class $GitHubPullRequestCopyWith<$Res>  {
  factory $GitHubPullRequestCopyWith(GitHubPullRequest value, $Res Function(GitHubPullRequest) _then) = _$GitHubPullRequestCopyWithImpl;
@useResult
$Res call({
 int number
});




}
/// @nodoc
class _$GitHubPullRequestCopyWithImpl<$Res>
    implements $GitHubPullRequestCopyWith<$Res> {
  _$GitHubPullRequestCopyWithImpl(this._self, this._then);

  final GitHubPullRequest _self;
  final $Res Function(GitHubPullRequest) _then;

/// Create a copy of GitHubPullRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GitHubPullRequest].
extension GitHubPullRequestPatterns on GitHubPullRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitHubPullRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitHubPullRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitHubPullRequest value)  $default,){
final _that = this;
switch (_that) {
case _GitHubPullRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitHubPullRequest value)?  $default,){
final _that = this;
switch (_that) {
case _GitHubPullRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitHubPullRequest() when $default != null:
return $default(_that.number);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number)  $default,) {final _that = this;
switch (_that) {
case _GitHubPullRequest():
return $default(_that.number);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number)?  $default,) {final _that = this;
switch (_that) {
case _GitHubPullRequest() when $default != null:
return $default(_that.number);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _GitHubPullRequest implements GitHubPullRequest {
  const _GitHubPullRequest({required this.number});
  factory _GitHubPullRequest.fromJson(Map<String, dynamic> json) => _$GitHubPullRequestFromJson(json);

@override final  int number;

/// Create a copy of GitHubPullRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitHubPullRequestCopyWith<_GitHubPullRequest> get copyWith => __$GitHubPullRequestCopyWithImpl<_GitHubPullRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitHubPullRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitHubPullRequest&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number);

@override
String toString() {
  return 'GitHubPullRequest(number: $number)';
}


}

/// @nodoc
abstract mixin class _$GitHubPullRequestCopyWith<$Res> implements $GitHubPullRequestCopyWith<$Res> {
  factory _$GitHubPullRequestCopyWith(_GitHubPullRequest value, $Res Function(_GitHubPullRequest) _then) = __$GitHubPullRequestCopyWithImpl;
@override @useResult
$Res call({
 int number
});




}
/// @nodoc
class __$GitHubPullRequestCopyWithImpl<$Res>
    implements _$GitHubPullRequestCopyWith<$Res> {
  __$GitHubPullRequestCopyWithImpl(this._self, this._then);

  final _GitHubPullRequest _self;
  final $Res Function(_GitHubPullRequest) _then;

/// Create a copy of GitHubPullRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,}) {
  return _then(_GitHubPullRequest(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
