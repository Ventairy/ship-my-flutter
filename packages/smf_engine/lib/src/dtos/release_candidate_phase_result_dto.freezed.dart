// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_candidate_phase_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseCandidatePhaseResultDto {

 List<ReleaseCandidateReceiptDto> get releaseCandidateReceipts;
/// Create a copy of ReleaseCandidatePhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseCandidatePhaseResultDtoCopyWith<ReleaseCandidatePhaseResultDto> get copyWith => _$ReleaseCandidatePhaseResultDtoCopyWithImpl<ReleaseCandidatePhaseResultDto>(this as ReleaseCandidatePhaseResultDto, _$identity);

  /// Serializes this ReleaseCandidatePhaseResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseCandidatePhaseResultDto&&const DeepCollectionEquality().equals(other.releaseCandidateReceipts, releaseCandidateReceipts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(releaseCandidateReceipts));

@override
String toString() {
  return 'ReleaseCandidatePhaseResultDto(releaseCandidateReceipts: $releaseCandidateReceipts)';
}


}

/// @nodoc
abstract mixin class $ReleaseCandidatePhaseResultDtoCopyWith<$Res>  {
  factory $ReleaseCandidatePhaseResultDtoCopyWith(ReleaseCandidatePhaseResultDto value, $Res Function(ReleaseCandidatePhaseResultDto) _then) = _$ReleaseCandidatePhaseResultDtoCopyWithImpl;
@useResult
$Res call({
 List<ReleaseCandidateReceiptDto> releaseCandidateReceipts
});




}
/// @nodoc
class _$ReleaseCandidatePhaseResultDtoCopyWithImpl<$Res>
    implements $ReleaseCandidatePhaseResultDtoCopyWith<$Res> {
  _$ReleaseCandidatePhaseResultDtoCopyWithImpl(this._self, this._then);

  final ReleaseCandidatePhaseResultDto _self;
  final $Res Function(ReleaseCandidatePhaseResultDto) _then;

/// Create a copy of ReleaseCandidatePhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? releaseCandidateReceipts = null,}) {
  return _then(_self.copyWith(
releaseCandidateReceipts: null == releaseCandidateReceipts ? _self.releaseCandidateReceipts : releaseCandidateReceipts // ignore: cast_nullable_to_non_nullable
as List<ReleaseCandidateReceiptDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseCandidatePhaseResultDto].
extension ReleaseCandidatePhaseResultDtoPatterns on ReleaseCandidatePhaseResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseCandidatePhaseResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseCandidatePhaseResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseCandidatePhaseResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidatePhaseResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseCandidatePhaseResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseCandidatePhaseResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ReleaseCandidateReceiptDto> releaseCandidateReceipts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseCandidatePhaseResultDto() when $default != null:
return $default(_that.releaseCandidateReceipts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ReleaseCandidateReceiptDto> releaseCandidateReceipts)  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidatePhaseResultDto():
return $default(_that.releaseCandidateReceipts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ReleaseCandidateReceiptDto> releaseCandidateReceipts)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseCandidatePhaseResultDto() when $default != null:
return $default(_that.releaseCandidateReceipts);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ReleaseCandidatePhaseResultDto implements ReleaseCandidatePhaseResultDto {
  const _ReleaseCandidatePhaseResultDto({required final  List<ReleaseCandidateReceiptDto> releaseCandidateReceipts}): _releaseCandidateReceipts = releaseCandidateReceipts;
  factory _ReleaseCandidatePhaseResultDto.fromJson(Map<String, dynamic> json) => _$ReleaseCandidatePhaseResultDtoFromJson(json);

 final  List<ReleaseCandidateReceiptDto> _releaseCandidateReceipts;
@override List<ReleaseCandidateReceiptDto> get releaseCandidateReceipts {
  if (_releaseCandidateReceipts is EqualUnmodifiableListView) return _releaseCandidateReceipts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_releaseCandidateReceipts);
}


/// Create a copy of ReleaseCandidatePhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseCandidatePhaseResultDtoCopyWith<_ReleaseCandidatePhaseResultDto> get copyWith => __$ReleaseCandidatePhaseResultDtoCopyWithImpl<_ReleaseCandidatePhaseResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseCandidatePhaseResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseCandidatePhaseResultDto&&const DeepCollectionEquality().equals(other._releaseCandidateReceipts, _releaseCandidateReceipts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_releaseCandidateReceipts));

@override
String toString() {
  return 'ReleaseCandidatePhaseResultDto(releaseCandidateReceipts: $releaseCandidateReceipts)';
}


}

/// @nodoc
abstract mixin class _$ReleaseCandidatePhaseResultDtoCopyWith<$Res> implements $ReleaseCandidatePhaseResultDtoCopyWith<$Res> {
  factory _$ReleaseCandidatePhaseResultDtoCopyWith(_ReleaseCandidatePhaseResultDto value, $Res Function(_ReleaseCandidatePhaseResultDto) _then) = __$ReleaseCandidatePhaseResultDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ReleaseCandidateReceiptDto> releaseCandidateReceipts
});




}
/// @nodoc
class __$ReleaseCandidatePhaseResultDtoCopyWithImpl<$Res>
    implements _$ReleaseCandidatePhaseResultDtoCopyWith<$Res> {
  __$ReleaseCandidatePhaseResultDtoCopyWithImpl(this._self, this._then);

  final _ReleaseCandidatePhaseResultDto _self;
  final $Res Function(_ReleaseCandidatePhaseResultDto) _then;

/// Create a copy of ReleaseCandidatePhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? releaseCandidateReceipts = null,}) {
  return _then(_ReleaseCandidatePhaseResultDto(
releaseCandidateReceipts: null == releaseCandidateReceipts ? _self._releaseCandidateReceipts : releaseCandidateReceipts // ignore: cast_nullable_to_non_nullable
as List<ReleaseCandidateReceiptDto>,
  ));
}


}

// dart format on
