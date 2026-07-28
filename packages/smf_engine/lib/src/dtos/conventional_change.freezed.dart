// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conventional_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConventionalChange {

 String get sha; String get type; String? get scope; String get description; String? get body; bool get breaking; VersionBump? get versionBump; List<Platform> get platforms;
/// Create a copy of ConventionalChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConventionalChangeCopyWith<ConventionalChange> get copyWith => _$ConventionalChangeCopyWithImpl<ConventionalChange>(this as ConventionalChange, _$identity);

  /// Serializes this ConventionalChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConventionalChange&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.description, description) || other.description == description)&&(identical(other.body, body) || other.body == body)&&(identical(other.breaking, breaking) || other.breaking == breaking)&&(identical(other.versionBump, versionBump) || other.versionBump == versionBump)&&const DeepCollectionEquality().equals(other.platforms, platforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sha,type,scope,description,body,breaking,versionBump,const DeepCollectionEquality().hash(platforms));

@override
String toString() {
  return 'ConventionalChange(sha: $sha, type: $type, scope: $scope, description: $description, body: $body, breaking: $breaking, versionBump: $versionBump, platforms: $platforms)';
}


}

/// @nodoc
abstract mixin class $ConventionalChangeCopyWith<$Res>  {
  factory $ConventionalChangeCopyWith(ConventionalChange value, $Res Function(ConventionalChange) _then) = _$ConventionalChangeCopyWithImpl;
@useResult
$Res call({
 String sha, String type, String? scope, String description, String? body, bool breaking, VersionBump? versionBump, List<Platform> platforms
});




}
/// @nodoc
class _$ConventionalChangeCopyWithImpl<$Res>
    implements $ConventionalChangeCopyWith<$Res> {
  _$ConventionalChangeCopyWithImpl(this._self, this._then);

  final ConventionalChange _self;
  final $Res Function(ConventionalChange) _then;

/// Create a copy of ConventionalChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? type = null,Object? scope = freezed,Object? description = null,Object? body = freezed,Object? breaking = null,Object? versionBump = freezed,Object? platforms = null,}) {
  return _then(_self.copyWith(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,breaking: null == breaking ? _self.breaking : breaking // ignore: cast_nullable_to_non_nullable
as bool,versionBump: freezed == versionBump ? _self.versionBump : versionBump // ignore: cast_nullable_to_non_nullable
as VersionBump?,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<Platform>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConventionalChange].
extension ConventionalChangePatterns on ConventionalChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConventionalChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConventionalChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConventionalChange value)  $default,){
final _that = this;
switch (_that) {
case _ConventionalChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConventionalChange value)?  $default,){
final _that = this;
switch (_that) {
case _ConventionalChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sha,  String type,  String? scope,  String description,  String? body,  bool breaking,  VersionBump? versionBump,  List<Platform> platforms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConventionalChange() when $default != null:
return $default(_that.sha,_that.type,_that.scope,_that.description,_that.body,_that.breaking,_that.versionBump,_that.platforms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sha,  String type,  String? scope,  String description,  String? body,  bool breaking,  VersionBump? versionBump,  List<Platform> platforms)  $default,) {final _that = this;
switch (_that) {
case _ConventionalChange():
return $default(_that.sha,_that.type,_that.scope,_that.description,_that.body,_that.breaking,_that.versionBump,_that.platforms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sha,  String type,  String? scope,  String description,  String? body,  bool breaking,  VersionBump? versionBump,  List<Platform> platforms)?  $default,) {final _that = this;
switch (_that) {
case _ConventionalChange() when $default != null:
return $default(_that.sha,_that.type,_that.scope,_that.description,_that.body,_that.breaking,_that.versionBump,_that.platforms);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ConventionalChange implements ConventionalChange {
  const _ConventionalChange({required this.sha, required this.type, required this.scope, required this.description, required this.body, required this.breaking, required this.versionBump, required final  List<Platform> platforms}): _platforms = platforms;
  factory _ConventionalChange.fromJson(Map<String, dynamic> json) => _$ConventionalChangeFromJson(json);

@override final  String sha;
@override final  String type;
@override final  String? scope;
@override final  String description;
@override final  String? body;
@override final  bool breaking;
@override final  VersionBump? versionBump;
 final  List<Platform> _platforms;
@override List<Platform> get platforms {
  if (_platforms is EqualUnmodifiableListView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platforms);
}


/// Create a copy of ConventionalChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConventionalChangeCopyWith<_ConventionalChange> get copyWith => __$ConventionalChangeCopyWithImpl<_ConventionalChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConventionalChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConventionalChange&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.type, type) || other.type == type)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.description, description) || other.description == description)&&(identical(other.body, body) || other.body == body)&&(identical(other.breaking, breaking) || other.breaking == breaking)&&(identical(other.versionBump, versionBump) || other.versionBump == versionBump)&&const DeepCollectionEquality().equals(other._platforms, _platforms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sha,type,scope,description,body,breaking,versionBump,const DeepCollectionEquality().hash(_platforms));

@override
String toString() {
  return 'ConventionalChange(sha: $sha, type: $type, scope: $scope, description: $description, body: $body, breaking: $breaking, versionBump: $versionBump, platforms: $platforms)';
}


}

/// @nodoc
abstract mixin class _$ConventionalChangeCopyWith<$Res> implements $ConventionalChangeCopyWith<$Res> {
  factory _$ConventionalChangeCopyWith(_ConventionalChange value, $Res Function(_ConventionalChange) _then) = __$ConventionalChangeCopyWithImpl;
@override @useResult
$Res call({
 String sha, String type, String? scope, String description, String? body, bool breaking, VersionBump? versionBump, List<Platform> platforms
});




}
/// @nodoc
class __$ConventionalChangeCopyWithImpl<$Res>
    implements _$ConventionalChangeCopyWith<$Res> {
  __$ConventionalChangeCopyWithImpl(this._self, this._then);

  final _ConventionalChange _self;
  final $Res Function(_ConventionalChange) _then;

/// Create a copy of ConventionalChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? type = null,Object? scope = freezed,Object? description = null,Object? body = freezed,Object? breaking = null,Object? versionBump = freezed,Object? platforms = null,}) {
  return _then(_ConventionalChange(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,breaking: null == breaking ? _self.breaking : breaking // ignore: cast_nullable_to_non_nullable
as bool,versionBump: freezed == versionBump ? _self.versionBump : versionBump // ignore: cast_nullable_to_non_nullable
as VersionBump?,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<Platform>,
  ));
}


}

// dart format on
