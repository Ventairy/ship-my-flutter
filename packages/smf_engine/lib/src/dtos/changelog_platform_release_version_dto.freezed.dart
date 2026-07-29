// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changelog_platform_release_version_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangelogPlatformReleaseVersionDto {

@JsonKey(required: true, disallowNullValue: true) String get version;@JsonKey(required: true, disallowNullValue: true) DateTime get preparedAt;@JsonKey(required: true, disallowNullValue: true) String get baseCommitHash;@JsonKey(required: true, disallowNullValue: true) String get endCommitHash;@JsonKey(required: true, disallowNullValue: true) List<ConventionalChangeDto> get changes;
/// Create a copy of ChangelogPlatformReleaseVersionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogPlatformReleaseVersionDtoCopyWith<ChangelogPlatformReleaseVersionDto> get copyWith => _$ChangelogPlatformReleaseVersionDtoCopyWithImpl<ChangelogPlatformReleaseVersionDto>(this as ChangelogPlatformReleaseVersionDto, _$identity);

  /// Serializes this ChangelogPlatformReleaseVersionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogPlatformReleaseVersionDto&&(identical(other.version, version) || other.version == version)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.baseCommitHash, baseCommitHash) || other.baseCommitHash == baseCommitHash)&&(identical(other.endCommitHash, endCommitHash) || other.endCommitHash == endCommitHash)&&const DeepCollectionEquality().equals(other.changes, changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,preparedAt,baseCommitHash,endCommitHash,const DeepCollectionEquality().hash(changes));

@override
String toString() {
  return 'ChangelogPlatformReleaseVersionDto(version: $version, preparedAt: $preparedAt, baseCommitHash: $baseCommitHash, endCommitHash: $endCommitHash, changes: $changes)';
}


}

/// @nodoc
abstract mixin class $ChangelogPlatformReleaseVersionDtoCopyWith<$Res>  {
  factory $ChangelogPlatformReleaseVersionDtoCopyWith(ChangelogPlatformReleaseVersionDto value, $Res Function(ChangelogPlatformReleaseVersionDto) _then) = _$ChangelogPlatformReleaseVersionDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String version,@JsonKey(required: true, disallowNullValue: true) DateTime preparedAt,@JsonKey(required: true, disallowNullValue: true) String baseCommitHash,@JsonKey(required: true, disallowNullValue: true) String endCommitHash,@JsonKey(required: true, disallowNullValue: true) List<ConventionalChangeDto> changes
});




}
/// @nodoc
class _$ChangelogPlatformReleaseVersionDtoCopyWithImpl<$Res>
    implements $ChangelogPlatformReleaseVersionDtoCopyWith<$Res> {
  _$ChangelogPlatformReleaseVersionDtoCopyWithImpl(this._self, this._then);

  final ChangelogPlatformReleaseVersionDto _self;
  final $Res Function(ChangelogPlatformReleaseVersionDto) _then;

/// Create a copy of ChangelogPlatformReleaseVersionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? preparedAt = null,Object? baseCommitHash = null,Object? endCommitHash = null,Object? changes = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseCommitHash: null == baseCommitHash ? _self.baseCommitHash : baseCommitHash // ignore: cast_nullable_to_non_nullable
as String,endCommitHash: null == endCommitHash ? _self.endCommitHash : endCommitHash // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChangeDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogPlatformReleaseVersionDto].
extension ChangelogPlatformReleaseVersionDtoPatterns on ChangelogPlatformReleaseVersionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogPlatformReleaseVersionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogPlatformReleaseVersionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogPlatformReleaseVersionDto value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogPlatformReleaseVersionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogPlatformReleaseVersionDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogPlatformReleaseVersionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  String version, @JsonKey(required: true, disallowNullValue: true)  DateTime preparedAt, @JsonKey(required: true, disallowNullValue: true)  String baseCommitHash, @JsonKey(required: true, disallowNullValue: true)  String endCommitHash, @JsonKey(required: true, disallowNullValue: true)  List<ConventionalChangeDto> changes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogPlatformReleaseVersionDto() when $default != null:
return $default(_that.version,_that.preparedAt,_that.baseCommitHash,_that.endCommitHash,_that.changes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  String version, @JsonKey(required: true, disallowNullValue: true)  DateTime preparedAt, @JsonKey(required: true, disallowNullValue: true)  String baseCommitHash, @JsonKey(required: true, disallowNullValue: true)  String endCommitHash, @JsonKey(required: true, disallowNullValue: true)  List<ConventionalChangeDto> changes)  $default,) {final _that = this;
switch (_that) {
case _ChangelogPlatformReleaseVersionDto():
return $default(_that.version,_that.preparedAt,_that.baseCommitHash,_that.endCommitHash,_that.changes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  String version, @JsonKey(required: true, disallowNullValue: true)  DateTime preparedAt, @JsonKey(required: true, disallowNullValue: true)  String baseCommitHash, @JsonKey(required: true, disallowNullValue: true)  String endCommitHash, @JsonKey(required: true, disallowNullValue: true)  List<ConventionalChangeDto> changes)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogPlatformReleaseVersionDto() when $default != null:
return $default(_that.version,_that.preparedAt,_that.baseCommitHash,_that.endCommitHash,_that.changes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, dateTimeUtc: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ChangelogPlatformReleaseVersionDto implements ChangelogPlatformReleaseVersionDto {
  const _ChangelogPlatformReleaseVersionDto({@JsonKey(required: true, disallowNullValue: true) required this.version, @JsonKey(required: true, disallowNullValue: true) required this.preparedAt, @JsonKey(required: true, disallowNullValue: true) required this.baseCommitHash, @JsonKey(required: true, disallowNullValue: true) required this.endCommitHash, @JsonKey(required: true, disallowNullValue: true) required final  List<ConventionalChangeDto> changes}): _changes = changes;
  factory _ChangelogPlatformReleaseVersionDto.fromJson(Map<String, dynamic> json) => _$ChangelogPlatformReleaseVersionDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  String version;
@override@JsonKey(required: true, disallowNullValue: true) final  DateTime preparedAt;
@override@JsonKey(required: true, disallowNullValue: true) final  String baseCommitHash;
@override@JsonKey(required: true, disallowNullValue: true) final  String endCommitHash;
 final  List<ConventionalChangeDto> _changes;
@override@JsonKey(required: true, disallowNullValue: true) List<ConventionalChangeDto> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}


/// Create a copy of ChangelogPlatformReleaseVersionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogPlatformReleaseVersionDtoCopyWith<_ChangelogPlatformReleaseVersionDto> get copyWith => __$ChangelogPlatformReleaseVersionDtoCopyWithImpl<_ChangelogPlatformReleaseVersionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogPlatformReleaseVersionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogPlatformReleaseVersionDto&&(identical(other.version, version) || other.version == version)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.baseCommitHash, baseCommitHash) || other.baseCommitHash == baseCommitHash)&&(identical(other.endCommitHash, endCommitHash) || other.endCommitHash == endCommitHash)&&const DeepCollectionEquality().equals(other._changes, _changes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,preparedAt,baseCommitHash,endCommitHash,const DeepCollectionEquality().hash(_changes));

@override
String toString() {
  return 'ChangelogPlatformReleaseVersionDto(version: $version, preparedAt: $preparedAt, baseCommitHash: $baseCommitHash, endCommitHash: $endCommitHash, changes: $changes)';
}


}

/// @nodoc
abstract mixin class _$ChangelogPlatformReleaseVersionDtoCopyWith<$Res> implements $ChangelogPlatformReleaseVersionDtoCopyWith<$Res> {
  factory _$ChangelogPlatformReleaseVersionDtoCopyWith(_ChangelogPlatformReleaseVersionDto value, $Res Function(_ChangelogPlatformReleaseVersionDto) _then) = __$ChangelogPlatformReleaseVersionDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String version,@JsonKey(required: true, disallowNullValue: true) DateTime preparedAt,@JsonKey(required: true, disallowNullValue: true) String baseCommitHash,@JsonKey(required: true, disallowNullValue: true) String endCommitHash,@JsonKey(required: true, disallowNullValue: true) List<ConventionalChangeDto> changes
});




}
/// @nodoc
class __$ChangelogPlatformReleaseVersionDtoCopyWithImpl<$Res>
    implements _$ChangelogPlatformReleaseVersionDtoCopyWith<$Res> {
  __$ChangelogPlatformReleaseVersionDtoCopyWithImpl(this._self, this._then);

  final _ChangelogPlatformReleaseVersionDto _self;
  final $Res Function(_ChangelogPlatformReleaseVersionDto) _then;

/// Create a copy of ChangelogPlatformReleaseVersionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? preparedAt = null,Object? baseCommitHash = null,Object? endCommitHash = null,Object? changes = null,}) {
  return _then(_ChangelogPlatformReleaseVersionDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,preparedAt: null == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime,baseCommitHash: null == baseCommitHash ? _self.baseCommitHash : baseCommitHash // ignore: cast_nullable_to_non_nullable
as String,endCommitHash: null == endCommitHash ? _self.endCommitHash : endCommitHash // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<ConventionalChangeDto>,
  ));
}


}

// dart format on
