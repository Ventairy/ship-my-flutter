// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pull_request_phase_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
PullRequestPhaseResultDto _$PullRequestPhaseResultDtoFromJson(
  Map<String, dynamic> json
) {
        switch (json['nextPhase']) {
                  case 'noop':
          return PullRequestNoopResultDto.fromJson(
            json
          );
                case 'release-candidate':
          return PullRequestReleaseCandidateResultDto.fromJson(
            json
          );
                case 'ship':
          return PullRequestShipResultDto.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'nextPhase',
  'PullRequestPhaseResultDto',
  'Invalid union type "${json['nextPhase']}"!'
);
        }
      
}

/// @nodoc
mixin _$PullRequestPhaseResultDto {



  /// Serializes this PullRequestPhaseResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestPhaseResultDto);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestPhaseResultDto()';
}


}

/// @nodoc
class $PullRequestPhaseResultDtoCopyWith<$Res>  {
$PullRequestPhaseResultDtoCopyWith(PullRequestPhaseResultDto _, $Res Function(PullRequestPhaseResultDto) __);
}


/// Adds pattern-matching-related methods to [PullRequestPhaseResultDto].
extension PullRequestPhaseResultDtoPatterns on PullRequestPhaseResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PullRequestNoopResultDto value)?  noop,TResult Function( PullRequestReleaseCandidateResultDto value)?  releaseCandidate,TResult Function( PullRequestShipResultDto value)?  ship,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PullRequestNoopResultDto() when noop != null:
return noop(_that);case PullRequestReleaseCandidateResultDto() when releaseCandidate != null:
return releaseCandidate(_that);case PullRequestShipResultDto() when ship != null:
return ship(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PullRequestNoopResultDto value)  noop,required TResult Function( PullRequestReleaseCandidateResultDto value)  releaseCandidate,required TResult Function( PullRequestShipResultDto value)  ship,}){
final _that = this;
switch (_that) {
case PullRequestNoopResultDto():
return noop(_that);case PullRequestReleaseCandidateResultDto():
return releaseCandidate(_that);case PullRequestShipResultDto():
return ship(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PullRequestNoopResultDto value)?  noop,TResult? Function( PullRequestReleaseCandidateResultDto value)?  releaseCandidate,TResult? Function( PullRequestShipResultDto value)?  ship,}){
final _that = this;
switch (_that) {
case PullRequestNoopResultDto() when noop != null:
return noop(_that);case PullRequestReleaseCandidateResultDto() when releaseCandidate != null:
return releaseCandidate(_that);case PullRequestShipResultDto() when ship != null:
return ship(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  noop,TResult Function( List<ReleaseTargetDto> targets,  String releaseBranch,  int? pullRequestNumber)?  releaseCandidate,TResult Function( List<ReleaseTargetDto> targets)?  ship,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PullRequestNoopResultDto() when noop != null:
return noop();case PullRequestReleaseCandidateResultDto() when releaseCandidate != null:
return releaseCandidate(_that.targets,_that.releaseBranch,_that.pullRequestNumber);case PullRequestShipResultDto() when ship != null:
return ship(_that.targets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  noop,required TResult Function( List<ReleaseTargetDto> targets,  String releaseBranch,  int? pullRequestNumber)  releaseCandidate,required TResult Function( List<ReleaseTargetDto> targets)  ship,}) {final _that = this;
switch (_that) {
case PullRequestNoopResultDto():
return noop();case PullRequestReleaseCandidateResultDto():
return releaseCandidate(_that.targets,_that.releaseBranch,_that.pullRequestNumber);case PullRequestShipResultDto():
return ship(_that.targets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  noop,TResult? Function( List<ReleaseTargetDto> targets,  String releaseBranch,  int? pullRequestNumber)?  releaseCandidate,TResult? Function( List<ReleaseTargetDto> targets)?  ship,}) {final _that = this;
switch (_that) {
case PullRequestNoopResultDto() when noop != null:
return noop();case PullRequestReleaseCandidateResultDto() when releaseCandidate != null:
return releaseCandidate(_that.targets,_that.releaseBranch,_that.pullRequestNumber);case PullRequestShipResultDto() when ship != null:
return ship(_that.targets);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, includeIfNull: false, explicitToJson: true)
class PullRequestNoopResultDto implements PullRequestPhaseResultDto {
  const PullRequestNoopResultDto({final  String? $type}): $type = $type ?? 'noop';
  factory PullRequestNoopResultDto.fromJson(Map<String, dynamic> json) => _$PullRequestNoopResultDtoFromJson(json);



@JsonKey(name: 'nextPhase')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$PullRequestNoopResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestNoopResultDto);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestPhaseResultDto.noop()';
}


}




/// @nodoc

@JsonSerializable(checked: true, includeIfNull: false, explicitToJson: true)
class PullRequestReleaseCandidateResultDto implements PullRequestPhaseResultDto {
  const PullRequestReleaseCandidateResultDto({required final  List<ReleaseTargetDto> targets, required this.releaseBranch, this.pullRequestNumber, final  String? $type}): _targets = targets,$type = $type ?? 'release-candidate';
  factory PullRequestReleaseCandidateResultDto.fromJson(Map<String, dynamic> json) => _$PullRequestReleaseCandidateResultDtoFromJson(json);

 final  List<ReleaseTargetDto> _targets;
 List<ReleaseTargetDto> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}

 final  String releaseBranch;
 final  int? pullRequestNumber;

@JsonKey(name: 'nextPhase')
final String $type;


/// Create a copy of PullRequestPhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestReleaseCandidateResultDtoCopyWith<PullRequestReleaseCandidateResultDto> get copyWith => _$PullRequestReleaseCandidateResultDtoCopyWithImpl<PullRequestReleaseCandidateResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PullRequestReleaseCandidateResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestReleaseCandidateResultDto&&const DeepCollectionEquality().equals(other._targets, _targets)&&(identical(other.releaseBranch, releaseBranch) || other.releaseBranch == releaseBranch)&&(identical(other.pullRequestNumber, pullRequestNumber) || other.pullRequestNumber == pullRequestNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets),releaseBranch,pullRequestNumber);

@override
String toString() {
  return 'PullRequestPhaseResultDto.releaseCandidate(targets: $targets, releaseBranch: $releaseBranch, pullRequestNumber: $pullRequestNumber)';
}


}

/// @nodoc
abstract mixin class $PullRequestReleaseCandidateResultDtoCopyWith<$Res> implements $PullRequestPhaseResultDtoCopyWith<$Res> {
  factory $PullRequestReleaseCandidateResultDtoCopyWith(PullRequestReleaseCandidateResultDto value, $Res Function(PullRequestReleaseCandidateResultDto) _then) = _$PullRequestReleaseCandidateResultDtoCopyWithImpl;
@useResult
$Res call({
 List<ReleaseTargetDto> targets, String releaseBranch, int? pullRequestNumber
});




}
/// @nodoc
class _$PullRequestReleaseCandidateResultDtoCopyWithImpl<$Res>
    implements $PullRequestReleaseCandidateResultDtoCopyWith<$Res> {
  _$PullRequestReleaseCandidateResultDtoCopyWithImpl(this._self, this._then);

  final PullRequestReleaseCandidateResultDto _self;
  final $Res Function(PullRequestReleaseCandidateResultDto) _then;

/// Create a copy of PullRequestPhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targets = null,Object? releaseBranch = null,Object? pullRequestNumber = freezed,}) {
  return _then(PullRequestReleaseCandidateResultDto(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<ReleaseTargetDto>,releaseBranch: null == releaseBranch ? _self.releaseBranch : releaseBranch // ignore: cast_nullable_to_non_nullable
as String,pullRequestNumber: freezed == pullRequestNumber ? _self.pullRequestNumber : pullRequestNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc

@JsonSerializable(checked: true, includeIfNull: false, explicitToJson: true)
class PullRequestShipResultDto implements PullRequestPhaseResultDto {
  const PullRequestShipResultDto({required final  List<ReleaseTargetDto> targets, final  String? $type}): _targets = targets,$type = $type ?? 'ship';
  factory PullRequestShipResultDto.fromJson(Map<String, dynamic> json) => _$PullRequestShipResultDtoFromJson(json);

 final  List<ReleaseTargetDto> _targets;
 List<ReleaseTargetDto> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}


@JsonKey(name: 'nextPhase')
final String $type;


/// Create a copy of PullRequestPhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestShipResultDtoCopyWith<PullRequestShipResultDto> get copyWith => _$PullRequestShipResultDtoCopyWithImpl<PullRequestShipResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PullRequestShipResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestShipResultDto&&const DeepCollectionEquality().equals(other._targets, _targets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets));

@override
String toString() {
  return 'PullRequestPhaseResultDto.ship(targets: $targets)';
}


}

/// @nodoc
abstract mixin class $PullRequestShipResultDtoCopyWith<$Res> implements $PullRequestPhaseResultDtoCopyWith<$Res> {
  factory $PullRequestShipResultDtoCopyWith(PullRequestShipResultDto value, $Res Function(PullRequestShipResultDto) _then) = _$PullRequestShipResultDtoCopyWithImpl;
@useResult
$Res call({
 List<ReleaseTargetDto> targets
});




}
/// @nodoc
class _$PullRequestShipResultDtoCopyWithImpl<$Res>
    implements $PullRequestShipResultDtoCopyWith<$Res> {
  _$PullRequestShipResultDtoCopyWithImpl(this._self, this._then);

  final PullRequestShipResultDto _self;
  final $Res Function(PullRequestShipResultDto) _then;

/// Create a copy of PullRequestPhaseResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targets = null,}) {
  return _then(PullRequestShipResultDto(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<ReleaseTargetDto>,
  ));
}


}

// dart format on
