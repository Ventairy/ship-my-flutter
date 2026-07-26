// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommandResult {

 String get phase; Platform? get platform; String? get version; String? get branch; int? get pullRequestNumber;
/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandResultCopyWith<CommandResult> get copyWith => _$CommandResultCopyWithImpl<CommandResult>(this as CommandResult, _$identity);

  /// Serializes this CommandResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandResult&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.pullRequestNumber, pullRequestNumber) || other.pullRequestNumber == pullRequestNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phase,platform,version,branch,pullRequestNumber);

@override
String toString() {
  return 'CommandResult(phase: $phase, platform: $platform, version: $version, branch: $branch, pullRequestNumber: $pullRequestNumber)';
}


}

/// @nodoc
abstract mixin class $CommandResultCopyWith<$Res>  {
  factory $CommandResultCopyWith(CommandResult value, $Res Function(CommandResult) _then) = _$CommandResultCopyWithImpl;
@useResult
$Res call({
 String phase, Platform? platform, String? version, String? branch, int? pullRequestNumber
});




}
/// @nodoc
class _$CommandResultCopyWithImpl<$Res>
    implements $CommandResultCopyWith<$Res> {
  _$CommandResultCopyWithImpl(this._self, this._then);

  final CommandResult _self;
  final $Res Function(CommandResult) _then;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? platform = freezed,Object? version = freezed,Object? branch = freezed,Object? pullRequestNumber = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,pullRequestNumber: freezed == pullRequestNumber ? _self.pullRequestNumber : pullRequestNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommandResult].
extension CommandResultPatterns on CommandResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommandResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommandResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommandResult value)  $default,){
final _that = this;
switch (_that) {
case _CommandResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommandResult value)?  $default,){
final _that = this;
switch (_that) {
case _CommandResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phase,  Platform? platform,  String? version,  String? branch,  int? pullRequestNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommandResult() when $default != null:
return $default(_that.phase,_that.platform,_that.version,_that.branch,_that.pullRequestNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phase,  Platform? platform,  String? version,  String? branch,  int? pullRequestNumber)  $default,) {final _that = this;
switch (_that) {
case _CommandResult():
return $default(_that.phase,_that.platform,_that.version,_that.branch,_that.pullRequestNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phase,  Platform? platform,  String? version,  String? branch,  int? pullRequestNumber)?  $default,) {final _that = this;
switch (_that) {
case _CommandResult() when $default != null:
return $default(_that.phase,_that.platform,_that.version,_that.branch,_that.pullRequestNumber);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, includeIfNull: false)
class _CommandResult implements CommandResult {
  const _CommandResult({required this.phase, this.platform, this.version, this.branch, this.pullRequestNumber});
  factory _CommandResult.fromJson(Map<String, dynamic> json) => _$CommandResultFromJson(json);

@override final  String phase;
@override final  Platform? platform;
@override final  String? version;
@override final  String? branch;
@override final  int? pullRequestNumber;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandResultCopyWith<_CommandResult> get copyWith => __$CommandResultCopyWithImpl<_CommandResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommandResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommandResult&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.version, version) || other.version == version)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.pullRequestNumber, pullRequestNumber) || other.pullRequestNumber == pullRequestNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phase,platform,version,branch,pullRequestNumber);

@override
String toString() {
  return 'CommandResult(phase: $phase, platform: $platform, version: $version, branch: $branch, pullRequestNumber: $pullRequestNumber)';
}


}

/// @nodoc
abstract mixin class _$CommandResultCopyWith<$Res> implements $CommandResultCopyWith<$Res> {
  factory _$CommandResultCopyWith(_CommandResult value, $Res Function(_CommandResult) _then) = __$CommandResultCopyWithImpl;
@override @useResult
$Res call({
 String phase, Platform? platform, String? version, String? branch, int? pullRequestNumber
});




}
/// @nodoc
class __$CommandResultCopyWithImpl<$Res>
    implements _$CommandResultCopyWith<$Res> {
  __$CommandResultCopyWithImpl(this._self, this._then);

  final _CommandResult _self;
  final $Res Function(_CommandResult) _then;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? platform = freezed,Object? version = freezed,Object? branch = freezed,Object? pullRequestNumber = freezed,}) {
  return _then(_CommandResult(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as Platform?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,pullRequestNumber: freezed == pullRequestNumber ? _self.pullRequestNumber : pullRequestNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
