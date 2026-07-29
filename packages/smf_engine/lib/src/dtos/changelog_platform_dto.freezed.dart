// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changelog_platform_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangelogPlatformDto {

@JsonKey(required: true, disallowNullValue: true) List<ChangelogPlatformReleaseVersionDto> get releases;
/// Create a copy of ChangelogPlatformDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogPlatformDtoCopyWith<ChangelogPlatformDto> get copyWith => _$ChangelogPlatformDtoCopyWithImpl<ChangelogPlatformDto>(this as ChangelogPlatformDto, _$identity);

  /// Serializes this ChangelogPlatformDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogPlatformDto&&const DeepCollectionEquality().equals(other.releases, releases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(releases));

@override
String toString() {
  return 'ChangelogPlatformDto(releases: $releases)';
}


}

/// @nodoc
abstract mixin class $ChangelogPlatformDtoCopyWith<$Res>  {
  factory $ChangelogPlatformDtoCopyWith(ChangelogPlatformDto value, $Res Function(ChangelogPlatformDto) _then) = _$ChangelogPlatformDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) List<ChangelogPlatformReleaseVersionDto> releases
});




}
/// @nodoc
class _$ChangelogPlatformDtoCopyWithImpl<$Res>
    implements $ChangelogPlatformDtoCopyWith<$Res> {
  _$ChangelogPlatformDtoCopyWithImpl(this._self, this._then);

  final ChangelogPlatformDto _self;
  final $Res Function(ChangelogPlatformDto) _then;

/// Create a copy of ChangelogPlatformDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? releases = null,}) {
  return _then(_self.copyWith(
releases: null == releases ? _self.releases : releases // ignore: cast_nullable_to_non_nullable
as List<ChangelogPlatformReleaseVersionDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogPlatformDto].
extension ChangelogPlatformDtoPatterns on ChangelogPlatformDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogPlatformDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogPlatformDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogPlatformDto value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogPlatformDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogPlatformDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogPlatformDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  List<ChangelogPlatformReleaseVersionDto> releases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogPlatformDto() when $default != null:
return $default(_that.releases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  List<ChangelogPlatformReleaseVersionDto> releases)  $default,) {final _that = this;
switch (_that) {
case _ChangelogPlatformDto():
return $default(_that.releases);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  List<ChangelogPlatformReleaseVersionDto> releases)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogPlatformDto() when $default != null:
return $default(_that.releases);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ChangelogPlatformDto extends ChangelogPlatformDto {
  const _ChangelogPlatformDto({@JsonKey(required: true, disallowNullValue: true) required final  List<ChangelogPlatformReleaseVersionDto> releases}): _releases = releases,super._();
  factory _ChangelogPlatformDto.fromJson(Map<String, dynamic> json) => _$ChangelogPlatformDtoFromJson(json);

 final  List<ChangelogPlatformReleaseVersionDto> _releases;
@override@JsonKey(required: true, disallowNullValue: true) List<ChangelogPlatformReleaseVersionDto> get releases {
  if (_releases is EqualUnmodifiableListView) return _releases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_releases);
}


/// Create a copy of ChangelogPlatformDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogPlatformDtoCopyWith<_ChangelogPlatformDto> get copyWith => __$ChangelogPlatformDtoCopyWithImpl<_ChangelogPlatformDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogPlatformDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogPlatformDto&&const DeepCollectionEquality().equals(other._releases, _releases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_releases));

@override
String toString() {
  return 'ChangelogPlatformDto(releases: $releases)';
}


}

/// @nodoc
abstract mixin class _$ChangelogPlatformDtoCopyWith<$Res> implements $ChangelogPlatformDtoCopyWith<$Res> {
  factory _$ChangelogPlatformDtoCopyWith(_ChangelogPlatformDto value, $Res Function(_ChangelogPlatformDto) _then) = __$ChangelogPlatformDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) List<ChangelogPlatformReleaseVersionDto> releases
});




}
/// @nodoc
class __$ChangelogPlatformDtoCopyWithImpl<$Res>
    implements _$ChangelogPlatformDtoCopyWith<$Res> {
  __$ChangelogPlatformDtoCopyWithImpl(this._self, this._then);

  final _ChangelogPlatformDto _self;
  final $Res Function(_ChangelogPlatformDto) _then;

/// Create a copy of ChangelogPlatformDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? releases = null,}) {
  return _then(_ChangelogPlatformDto(
releases: null == releases ? _self._releases : releases // ignore: cast_nullable_to_non_nullable
as List<ChangelogPlatformReleaseVersionDto>,
  ));
}


}

// dart format on
