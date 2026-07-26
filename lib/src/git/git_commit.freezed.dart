// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_commit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitCommit {

 String get sha; String get message;
/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitCommitCopyWith<GitCommit> get copyWith => _$GitCommitCopyWithImpl<GitCommit>(this as GitCommit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitCommit&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,sha,message);

@override
String toString() {
  return 'GitCommit(sha: $sha, message: $message)';
}


}

/// @nodoc
abstract mixin class $GitCommitCopyWith<$Res>  {
  factory $GitCommitCopyWith(GitCommit value, $Res Function(GitCommit) _then) = _$GitCommitCopyWithImpl;
@useResult
$Res call({
 String sha, String message
});




}
/// @nodoc
class _$GitCommitCopyWithImpl<$Res>
    implements $GitCommitCopyWith<$Res> {
  _$GitCommitCopyWithImpl(this._self, this._then);

  final GitCommit _self;
  final $Res Function(GitCommit) _then;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? message = null,}) {
  return _then(_self.copyWith(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GitCommit].
extension GitCommitPatterns on GitCommit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitCommit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitCommit value)  $default,){
final _that = this;
switch (_that) {
case _GitCommit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitCommit value)?  $default,){
final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sha,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
return $default(_that.sha,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sha,  String message)  $default,) {final _that = this;
switch (_that) {
case _GitCommit():
return $default(_that.sha,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sha,  String message)?  $default,) {final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
return $default(_that.sha,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GitCommit implements GitCommit {
  const _GitCommit({required this.sha, required this.message});
  

@override final  String sha;
@override final  String message;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitCommitCopyWith<_GitCommit> get copyWith => __$GitCommitCopyWithImpl<_GitCommit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitCommit&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,sha,message);

@override
String toString() {
  return 'GitCommit(sha: $sha, message: $message)';
}


}

/// @nodoc
abstract mixin class _$GitCommitCopyWith<$Res> implements $GitCommitCopyWith<$Res> {
  factory _$GitCommitCopyWith(_GitCommit value, $Res Function(_GitCommit) _then) = __$GitCommitCopyWithImpl;
@override @useResult
$Res call({
 String sha, String message
});




}
/// @nodoc
class __$GitCommitCopyWithImpl<$Res>
    implements _$GitCommitCopyWith<$Res> {
  __$GitCommitCopyWithImpl(this._self, this._then);

  final _GitCommit _self;
  final $Res Function(_GitCommit) _then;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? message = null,}) {
  return _then(_GitCommit(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
