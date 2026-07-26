// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiResource<T> {

 String get type; String get id; T get attributes;
/// Create a copy of ApiResource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResourceCopyWith<T, ApiResource<T>> get copyWith => _$ApiResourceCopyWithImpl<T, ApiResource<T>>(this as ApiResource<T>, _$identity);

  /// Serializes this ApiResource to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResource<T>&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.attributes, attributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(attributes));

@override
String toString() {
  return 'ApiResource<$T>(type: $type, id: $id, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class $ApiResourceCopyWith<T,$Res>  {
  factory $ApiResourceCopyWith(ApiResource<T> value, $Res Function(ApiResource<T>) _then) = _$ApiResourceCopyWithImpl;
@useResult
$Res call({
 String type, String id, T attributes
});




}
/// @nodoc
class _$ApiResourceCopyWithImpl<T,$Res>
    implements $ApiResourceCopyWith<T, $Res> {
  _$ApiResourceCopyWithImpl(this._self, this._then);

  final ApiResource<T> _self;
  final $Res Function(ApiResource<T>) _then;

/// Create a copy of ApiResource
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


/// Adds pattern-matching-related methods to [ApiResource].
extension ApiResourcePatterns<T> on ApiResource<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResource<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResource<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiResource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResource<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResource() when $default != null:
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
case _ApiResource() when $default != null:
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
case _ApiResource():
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
case _ApiResource() when $default != null:
return $default(_that.type,_that.id,_that.attributes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true, genericArgumentFactories: true)
class _ApiResource<T> implements ApiResource<T> {
  const _ApiResource({required this.type, required this.id, required this.attributes});
  factory _ApiResource.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiResourceFromJson(json,fromJsonT);

@override final  String type;
@override final  String id;
@override final  T attributes;

/// Create a copy of ApiResource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResourceCopyWith<T, _ApiResource<T>> get copyWith => __$ApiResourceCopyWithImpl<T, _ApiResource<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiResourceToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResource<T>&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.attributes, attributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(attributes));

@override
String toString() {
  return 'ApiResource<$T>(type: $type, id: $id, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class _$ApiResourceCopyWith<T,$Res> implements $ApiResourceCopyWith<T, $Res> {
  factory _$ApiResourceCopyWith(_ApiResource<T> value, $Res Function(_ApiResource<T>) _then) = __$ApiResourceCopyWithImpl;
@override @useResult
$Res call({
 String type, String id, T attributes
});




}
/// @nodoc
class __$ApiResourceCopyWithImpl<T,$Res>
    implements _$ApiResourceCopyWith<T, $Res> {
  __$ApiResourceCopyWithImpl(this._self, this._then);

  final _ApiResource<T> _self;
  final $Res Function(_ApiResource<T>) _then;

/// Create a copy of ApiResource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? attributes = freezed,}) {
  return _then(_ApiResource<T>(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attributes: freezed == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
