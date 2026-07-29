// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_pull_request_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReleasePullRequestResultDto {

 String get branch; int get pullRequestNumber;
/// Create a copy of ReleasePullRequestResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleasePullRequestResultDtoCopyWith<ReleasePullRequestResultDto> get copyWith => _$ReleasePullRequestResultDtoCopyWithImpl<ReleasePullRequestResultDto>(this as ReleasePullRequestResultDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleasePullRequestResultDto&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.pullRequestNumber, pullRequestNumber) || other.pullRequestNumber == pullRequestNumber));
}


@override
int get hashCode => Object.hash(runtimeType,branch,pullRequestNumber);

@override
String toString() {
  return 'ReleasePullRequestResultDto(branch: $branch, pullRequestNumber: $pullRequestNumber)';
}


}

/// @nodoc
abstract mixin class $ReleasePullRequestResultDtoCopyWith<$Res>  {
  factory $ReleasePullRequestResultDtoCopyWith(ReleasePullRequestResultDto value, $Res Function(ReleasePullRequestResultDto) _then) = _$ReleasePullRequestResultDtoCopyWithImpl;
@useResult
$Res call({
 String branch, int pullRequestNumber
});




}
/// @nodoc
class _$ReleasePullRequestResultDtoCopyWithImpl<$Res>
    implements $ReleasePullRequestResultDtoCopyWith<$Res> {
  _$ReleasePullRequestResultDtoCopyWithImpl(this._self, this._then);

  final ReleasePullRequestResultDto _self;
  final $Res Function(ReleasePullRequestResultDto) _then;

/// Create a copy of ReleasePullRequestResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = null,Object? pullRequestNumber = null,}) {
  return _then(_self.copyWith(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,pullRequestNumber: null == pullRequestNumber ? _self.pullRequestNumber : pullRequestNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleasePullRequestResultDto].
extension ReleasePullRequestResultDtoPatterns on ReleasePullRequestResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleasePullRequestResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleasePullRequestResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleasePullRequestResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleasePullRequestResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleasePullRequestResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleasePullRequestResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String branch,  int pullRequestNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleasePullRequestResultDto() when $default != null:
return $default(_that.branch,_that.pullRequestNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String branch,  int pullRequestNumber)  $default,) {final _that = this;
switch (_that) {
case _ReleasePullRequestResultDto():
return $default(_that.branch,_that.pullRequestNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String branch,  int pullRequestNumber)?  $default,) {final _that = this;
switch (_that) {
case _ReleasePullRequestResultDto() when $default != null:
return $default(_that.branch,_that.pullRequestNumber);case _:
  return null;

}
}

}

/// @nodoc


class _ReleasePullRequestResultDto implements ReleasePullRequestResultDto {
  const _ReleasePullRequestResultDto({required this.branch, required this.pullRequestNumber});
  

@override final  String branch;
@override final  int pullRequestNumber;

/// Create a copy of ReleasePullRequestResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleasePullRequestResultDtoCopyWith<_ReleasePullRequestResultDto> get copyWith => __$ReleasePullRequestResultDtoCopyWithImpl<_ReleasePullRequestResultDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleasePullRequestResultDto&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.pullRequestNumber, pullRequestNumber) || other.pullRequestNumber == pullRequestNumber));
}


@override
int get hashCode => Object.hash(runtimeType,branch,pullRequestNumber);

@override
String toString() {
  return 'ReleasePullRequestResultDto(branch: $branch, pullRequestNumber: $pullRequestNumber)';
}


}

/// @nodoc
abstract mixin class _$ReleasePullRequestResultDtoCopyWith<$Res> implements $ReleasePullRequestResultDtoCopyWith<$Res> {
  factory _$ReleasePullRequestResultDtoCopyWith(_ReleasePullRequestResultDto value, $Res Function(_ReleasePullRequestResultDto) _then) = __$ReleasePullRequestResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String branch, int pullRequestNumber
});




}
/// @nodoc
class __$ReleasePullRequestResultDtoCopyWithImpl<$Res>
    implements _$ReleasePullRequestResultDtoCopyWith<$Res> {
  __$ReleasePullRequestResultDtoCopyWithImpl(this._self, this._then);

  final _ReleasePullRequestResultDto _self;
  final $Res Function(_ReleasePullRequestResultDto) _then;

/// Create a copy of ReleasePullRequestResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = null,Object? pullRequestNumber = null,}) {
  return _then(_ReleasePullRequestResultDto(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,pullRequestNumber: null == pullRequestNumber ? _self.pullRequestNumber : pullRequestNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
