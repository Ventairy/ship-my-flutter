// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conventional_change_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConventionalChangeDto {

@JsonKey(required: true, disallowNullValue: true) String get commitHash;@JsonKey(required: true, disallowNullValue: true) String get type;@JsonKey(required: true) String? get scope;@JsonKey(required: true, disallowNullValue: true) String get description;@JsonKey(required: true) String? get body;@JsonKey(required: true, disallowNullValue: true) bool get isBreaking;@JsonKey(required: true) VersionBumpType? get versionBumpType;@JsonKey(required: true, disallowNullValue: true) List<ReleasePlatform> get platforms;
/// Create a copy of ConventionalChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConventionalChangeDtoCopyWith<ConventionalChangeDto> get copyWith => _$ConventionalChangeDtoCopyWithImpl<ConventionalChangeDto>(this as ConventionalChangeDto, _$identity);

  /// Serializes this ConventionalChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConventionalChangeDto&&(identical(other.commitHash, commitHash) || other.commitHash == commitHash)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.description, description) || other.description == description)&&(identical(other.body, body) || other.body == body)&&(identical(other.isBreaking, isBreaking) || other.isBreaking == isBreaking)&&(identical(other.versionBumpType, versionBumpType) || other.versionBumpType == versionBumpType)&&const DeepCollectionEquality().equals(other.platforms, platforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commitHash,type,scope,description,body,isBreaking,versionBumpType,const DeepCollectionEquality().hash(platforms));

@override
String toString() {
  return 'ConventionalChangeDto(commitHash: $commitHash, type: $type, scope: $scope, description: $description, body: $body, isBreaking: $isBreaking, versionBumpType: $versionBumpType, platforms: $platforms)';
}


}

/// @nodoc
abstract mixin class $ConventionalChangeDtoCopyWith<$Res>  {
  factory $ConventionalChangeDtoCopyWith(ConventionalChangeDto value, $Res Function(ConventionalChangeDto) _then) = _$ConventionalChangeDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String commitHash,@JsonKey(required: true, disallowNullValue: true) String type,@JsonKey(required: true) String? scope,@JsonKey(required: true, disallowNullValue: true) String description,@JsonKey(required: true) String? body,@JsonKey(required: true, disallowNullValue: true) bool isBreaking,@JsonKey(required: true) VersionBumpType? versionBumpType,@JsonKey(required: true, disallowNullValue: true) List<ReleasePlatform> platforms
});




}
/// @nodoc
class _$ConventionalChangeDtoCopyWithImpl<$Res>
    implements $ConventionalChangeDtoCopyWith<$Res> {
  _$ConventionalChangeDtoCopyWithImpl(this._self, this._then);

  final ConventionalChangeDto _self;
  final $Res Function(ConventionalChangeDto) _then;

/// Create a copy of ConventionalChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commitHash = null,Object? type = null,Object? scope = freezed,Object? description = null,Object? body = freezed,Object? isBreaking = null,Object? versionBumpType = freezed,Object? platforms = null,}) {
  return _then(_self.copyWith(
commitHash: null == commitHash ? _self.commitHash : commitHash // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,isBreaking: null == isBreaking ? _self.isBreaking : isBreaking // ignore: cast_nullable_to_non_nullable
as bool,versionBumpType: freezed == versionBumpType ? _self.versionBumpType : versionBumpType // ignore: cast_nullable_to_non_nullable
as VersionBumpType?,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<ReleasePlatform>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConventionalChangeDto].
extension ConventionalChangeDtoPatterns on ConventionalChangeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConventionalChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConventionalChangeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConventionalChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _ConventionalChangeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConventionalChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConventionalChangeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  String commitHash, @JsonKey(required: true, disallowNullValue: true)  String type, @JsonKey(required: true)  String? scope, @JsonKey(required: true, disallowNullValue: true)  String description, @JsonKey(required: true)  String? body, @JsonKey(required: true, disallowNullValue: true)  bool isBreaking, @JsonKey(required: true)  VersionBumpType? versionBumpType, @JsonKey(required: true, disallowNullValue: true)  List<ReleasePlatform> platforms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConventionalChangeDto() when $default != null:
return $default(_that.commitHash,_that.type,_that.scope,_that.description,_that.body,_that.isBreaking,_that.versionBumpType,_that.platforms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(required: true, disallowNullValue: true)  String commitHash, @JsonKey(required: true, disallowNullValue: true)  String type, @JsonKey(required: true)  String? scope, @JsonKey(required: true, disallowNullValue: true)  String description, @JsonKey(required: true)  String? body, @JsonKey(required: true, disallowNullValue: true)  bool isBreaking, @JsonKey(required: true)  VersionBumpType? versionBumpType, @JsonKey(required: true, disallowNullValue: true)  List<ReleasePlatform> platforms)  $default,) {final _that = this;
switch (_that) {
case _ConventionalChangeDto():
return $default(_that.commitHash,_that.type,_that.scope,_that.description,_that.body,_that.isBreaking,_that.versionBumpType,_that.platforms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(required: true, disallowNullValue: true)  String commitHash, @JsonKey(required: true, disallowNullValue: true)  String type, @JsonKey(required: true)  String? scope, @JsonKey(required: true, disallowNullValue: true)  String description, @JsonKey(required: true)  String? body, @JsonKey(required: true, disallowNullValue: true)  bool isBreaking, @JsonKey(required: true)  VersionBumpType? versionBumpType, @JsonKey(required: true, disallowNullValue: true)  List<ReleasePlatform> platforms)?  $default,) {final _that = this;
switch (_that) {
case _ConventionalChangeDto() when $default != null:
return $default(_that.commitHash,_that.type,_that.scope,_that.description,_that.body,_that.isBreaking,_that.versionBumpType,_that.platforms);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true, explicitToJson: true)
class _ConventionalChangeDto implements ConventionalChangeDto {
  const _ConventionalChangeDto({@JsonKey(required: true, disallowNullValue: true) required this.commitHash, @JsonKey(required: true, disallowNullValue: true) required this.type, @JsonKey(required: true) required this.scope, @JsonKey(required: true, disallowNullValue: true) required this.description, @JsonKey(required: true) required this.body, @JsonKey(required: true, disallowNullValue: true) required this.isBreaking, @JsonKey(required: true) required this.versionBumpType, @JsonKey(required: true, disallowNullValue: true) required final  List<ReleasePlatform> platforms}): _platforms = platforms;
  factory _ConventionalChangeDto.fromJson(Map<String, dynamic> json) => _$ConventionalChangeDtoFromJson(json);

@override@JsonKey(required: true, disallowNullValue: true) final  String commitHash;
@override@JsonKey(required: true, disallowNullValue: true) final  String type;
@override@JsonKey(required: true) final  String? scope;
@override@JsonKey(required: true, disallowNullValue: true) final  String description;
@override@JsonKey(required: true) final  String? body;
@override@JsonKey(required: true, disallowNullValue: true) final  bool isBreaking;
@override@JsonKey(required: true) final  VersionBumpType? versionBumpType;
 final  List<ReleasePlatform> _platforms;
@override@JsonKey(required: true, disallowNullValue: true) List<ReleasePlatform> get platforms {
  if (_platforms is EqualUnmodifiableListView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platforms);
}


/// Create a copy of ConventionalChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConventionalChangeDtoCopyWith<_ConventionalChangeDto> get copyWith => __$ConventionalChangeDtoCopyWithImpl<_ConventionalChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConventionalChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConventionalChangeDto&&(identical(other.commitHash, commitHash) || other.commitHash == commitHash)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.description, description) || other.description == description)&&(identical(other.body, body) || other.body == body)&&(identical(other.isBreaking, isBreaking) || other.isBreaking == isBreaking)&&(identical(other.versionBumpType, versionBumpType) || other.versionBumpType == versionBumpType)&&const DeepCollectionEquality().equals(other._platforms, _platforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commitHash,type,scope,description,body,isBreaking,versionBumpType,const DeepCollectionEquality().hash(_platforms));

@override
String toString() {
  return 'ConventionalChangeDto(commitHash: $commitHash, type: $type, scope: $scope, description: $description, body: $body, isBreaking: $isBreaking, versionBumpType: $versionBumpType, platforms: $platforms)';
}


}

/// @nodoc
abstract mixin class _$ConventionalChangeDtoCopyWith<$Res> implements $ConventionalChangeDtoCopyWith<$Res> {
  factory _$ConventionalChangeDtoCopyWith(_ConventionalChangeDto value, $Res Function(_ConventionalChangeDto) _then) = __$ConventionalChangeDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String commitHash,@JsonKey(required: true, disallowNullValue: true) String type,@JsonKey(required: true) String? scope,@JsonKey(required: true, disallowNullValue: true) String description,@JsonKey(required: true) String? body,@JsonKey(required: true, disallowNullValue: true) bool isBreaking,@JsonKey(required: true) VersionBumpType? versionBumpType,@JsonKey(required: true, disallowNullValue: true) List<ReleasePlatform> platforms
});




}
/// @nodoc
class __$ConventionalChangeDtoCopyWithImpl<$Res>
    implements _$ConventionalChangeDtoCopyWith<$Res> {
  __$ConventionalChangeDtoCopyWithImpl(this._self, this._then);

  final _ConventionalChangeDto _self;
  final $Res Function(_ConventionalChangeDto) _then;

/// Create a copy of ConventionalChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commitHash = null,Object? type = null,Object? scope = freezed,Object? description = null,Object? body = freezed,Object? isBreaking = null,Object? versionBumpType = freezed,Object? platforms = null,}) {
  return _then(_ConventionalChangeDto(
commitHash: null == commitHash ? _self.commitHash : commitHash // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,isBreaking: null == isBreaking ? _self.isBreaking : isBreaking // ignore: cast_nullable_to_non_nullable
as bool,versionBumpType: freezed == versionBumpType ? _self.versionBumpType : versionBumpType // ignore: cast_nullable_to_non_nullable
as VersionBumpType?,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<ReleasePlatform>,
  ));
}


}

// dart format on
