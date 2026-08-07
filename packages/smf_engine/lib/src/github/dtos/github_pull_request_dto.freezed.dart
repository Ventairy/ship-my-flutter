// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_pull_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitHubPullRequestDto {

 int get number;
/// Create a copy of GitHubPullRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitHubPullRequestDtoCopyWith<GitHubPullRequestDto> get copyWith => _$GitHubPullRequestDtoCopyWithImpl<GitHubPullRequestDto>(this as GitHubPullRequestDto, _$identity);

  /// Serializes this GitHubPullRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitHubPullRequestDto&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number);

@override
String toString() {
  return 'GitHubPullRequestDto(number: $number)';
}


}

/// @nodoc
abstract mixin class $GitHubPullRequestDtoCopyWith<$Res>  {
  factory $GitHubPullRequestDtoCopyWith(GitHubPullRequestDto value, $Res Function(GitHubPullRequestDto) _then) = _$GitHubPullRequestDtoCopyWithImpl;
@useResult
$Res call({
 int number
});




}
/// @nodoc
class _$GitHubPullRequestDtoCopyWithImpl<$Res>
    implements $GitHubPullRequestDtoCopyWith<$Res> {
  _$GitHubPullRequestDtoCopyWithImpl(this._self, this._then);

  final GitHubPullRequestDto _self;
  final $Res Function(GitHubPullRequestDto) _then;

/// Create a copy of GitHubPullRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GitHubPullRequestDto].
extension GitHubPullRequestDtoPatterns on GitHubPullRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitHubPullRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitHubPullRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitHubPullRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _GitHubPullRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitHubPullRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _GitHubPullRequestDto() when $default != null:
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
case _GitHubPullRequestDto() when $default != null:
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
case _GitHubPullRequestDto():
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
case _GitHubPullRequestDto() when $default != null:
return $default(_that.number);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _GitHubPullRequestDto implements GitHubPullRequestDto {
  const _GitHubPullRequestDto({required this.number});
  factory _GitHubPullRequestDto.fromJson(Map<String, dynamic> json) => _$GitHubPullRequestDtoFromJson(json);

@override final  int number;

/// Create a copy of GitHubPullRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitHubPullRequestDtoCopyWith<_GitHubPullRequestDto> get copyWith => __$GitHubPullRequestDtoCopyWithImpl<_GitHubPullRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitHubPullRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitHubPullRequestDto&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number);

@override
String toString() {
  return 'GitHubPullRequestDto(number: $number)';
}


}

/// @nodoc
abstract mixin class _$GitHubPullRequestDtoCopyWith<$Res> implements $GitHubPullRequestDtoCopyWith<$Res> {
  factory _$GitHubPullRequestDtoCopyWith(_GitHubPullRequestDto value, $Res Function(_GitHubPullRequestDto) _then) = __$GitHubPullRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 int number
});




}
/// @nodoc
class __$GitHubPullRequestDtoCopyWithImpl<$Res>
    implements _$GitHubPullRequestDtoCopyWith<$Res> {
  __$GitHubPullRequestDtoCopyWithImpl(this._self, this._then);

  final _GitHubPullRequestDto _self;
  final $Res Function(_GitHubPullRequestDto) _then;

/// Create a copy of GitHubPullRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,}) {
  return _then(_GitHubPullRequestDto(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
