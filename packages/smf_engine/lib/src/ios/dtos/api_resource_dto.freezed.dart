// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_resource_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiResourceDto<T> {

 String get type; String get id; T get attributes;
/// Create a copy of ApiResourceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResourceDtoCopyWith<T, ApiResourceDto<T>> get copyWith => _$ApiResourceDtoCopyWithImpl<T, ApiResourceDto<T>>(this as ApiResourceDto<T>, _$identity);

  /// Serializes this ApiResourceDto to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResourceDto<T>&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.attributes, attributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(attributes));

@override
String toString() {
  return 'ApiResourceDto<$T>(type: $type, id: $id, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class $ApiResourceDtoCopyWith<T,$Res>  {
  factory $ApiResourceDtoCopyWith(ApiResourceDto<T> value, $Res Function(ApiResourceDto<T>) _then) = _$ApiResourceDtoCopyWithImpl;
@useResult
$Res call({
 String type, String id, T attributes
});




}
/// @nodoc
class _$ApiResourceDtoCopyWithImpl<T,$Res>
    implements $ApiResourceDtoCopyWith<T, $Res> {
  _$ApiResourceDtoCopyWithImpl(this._self, this._then);

  final ApiResourceDto<T> _self;
  final $Res Function(ApiResourceDto<T>) _then;

/// Create a copy of ApiResourceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,Object? attributes = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attributes: freezed == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as T,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiResourceDto].
extension ApiResourceDtoPatterns<T> on ApiResourceDto<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResourceDto<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResourceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResourceDto<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiResourceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResourceDto<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResourceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String id,  T attributes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiResourceDto() when $default != null:
return $default(_that.type,_that.id,_that.attributes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String id,  T attributes)  $default,) {final _that = this;
switch (_that) {
case _ApiResourceDto():
return $default(_that.type,_that.id,_that.attributes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String id,  T attributes)?  $default,) {final _that = this;
switch (_that) {
case _ApiResourceDto() when $default != null:
return $default(_that.type,_that.id,_that.attributes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true, genericArgumentFactories: true)
class _ApiResourceDto<T> implements ApiResourceDto<T> {
  const _ApiResourceDto({required this.type, required this.id, required this.attributes});
  factory _ApiResourceDto.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiResourceDtoFromJson(json,fromJsonT);

@override final  String type;
@override final  String id;
@override final  T attributes;

/// Create a copy of ApiResourceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResourceDtoCopyWith<T, _ApiResourceDto<T>> get copyWith => __$ApiResourceDtoCopyWithImpl<T, _ApiResourceDto<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiResourceDtoToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResourceDto<T>&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.attributes, attributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(attributes));

@override
String toString() {
  return 'ApiResourceDto<$T>(type: $type, id: $id, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class _$ApiResourceDtoCopyWith<T,$Res> implements $ApiResourceDtoCopyWith<T, $Res> {
  factory _$ApiResourceDtoCopyWith(_ApiResourceDto<T> value, $Res Function(_ApiResourceDto<T>) _then) = __$ApiResourceDtoCopyWithImpl;
@override @useResult
$Res call({
 String type, String id, T attributes
});




}
/// @nodoc
class __$ApiResourceDtoCopyWithImpl<T,$Res>
    implements _$ApiResourceDtoCopyWith<T, $Res> {
  __$ApiResourceDtoCopyWithImpl(this._self, this._then);

  final _ApiResourceDto<T> _self;
  final $Res Function(_ApiResourceDto<T>) _then;

/// Create a copy of ApiResourceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? attributes = freezed,}) {
  return _then(_ApiResourceDto<T>(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attributes: freezed == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
