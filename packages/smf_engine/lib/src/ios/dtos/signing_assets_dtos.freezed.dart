// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signing_assets_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppleSigningCertificateDto {

 String get id; String get certificateType; String get displayName; String get serialNumber; String get certificateContent; DateTime get expirationDate; bool get isActivated;
/// Create a copy of AppleSigningCertificateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleSigningCertificateDtoCopyWith<AppleSigningCertificateDto> get copyWith => _$AppleSigningCertificateDtoCopyWithImpl<AppleSigningCertificateDto>(this as AppleSigningCertificateDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleSigningCertificateDto&&(identical(other.id, id) || other.id == id)&&(identical(other.certificateType, certificateType) || other.certificateType == certificateType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.certificateContent, certificateContent) || other.certificateContent == certificateContent)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated));
}


@override
int get hashCode => Object.hash(runtimeType,id,certificateType,displayName,serialNumber,certificateContent,expirationDate,isActivated);

@override
String toString() {
  return 'AppleSigningCertificateDto(id: $id, certificateType: $certificateType, displayName: $displayName, serialNumber: $serialNumber, certificateContent: $certificateContent, expirationDate: $expirationDate, isActivated: $isActivated)';
}


}

/// @nodoc
abstract mixin class $AppleSigningCertificateDtoCopyWith<$Res>  {
  factory $AppleSigningCertificateDtoCopyWith(AppleSigningCertificateDto value, $Res Function(AppleSigningCertificateDto) _then) = _$AppleSigningCertificateDtoCopyWithImpl;
@useResult
$Res call({
 String id, String certificateType, String displayName, String serialNumber, String certificateContent, DateTime expirationDate, bool isActivated
});




}
/// @nodoc
class _$AppleSigningCertificateDtoCopyWithImpl<$Res>
    implements $AppleSigningCertificateDtoCopyWith<$Res> {
  _$AppleSigningCertificateDtoCopyWithImpl(this._self, this._then);

  final AppleSigningCertificateDto _self;
  final $Res Function(AppleSigningCertificateDto) _then;

/// Create a copy of AppleSigningCertificateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? certificateType = null,Object? displayName = null,Object? serialNumber = null,Object? certificateContent = null,Object? expirationDate = null,Object? isActivated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,certificateType: null == certificateType ? _self.certificateType : certificateType // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,certificateContent: null == certificateContent ? _self.certificateContent : certificateContent // ignore: cast_nullable_to_non_nullable
as String,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleSigningCertificateDto].
extension AppleSigningCertificateDtoPatterns on AppleSigningCertificateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleSigningCertificateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleSigningCertificateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleSigningCertificateDto value)  $default,){
final _that = this;
switch (_that) {
case _AppleSigningCertificateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleSigningCertificateDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppleSigningCertificateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String certificateType,  String displayName,  String serialNumber,  String certificateContent,  DateTime expirationDate,  bool isActivated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleSigningCertificateDto() when $default != null:
return $default(_that.id,_that.certificateType,_that.displayName,_that.serialNumber,_that.certificateContent,_that.expirationDate,_that.isActivated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String certificateType,  String displayName,  String serialNumber,  String certificateContent,  DateTime expirationDate,  bool isActivated)  $default,) {final _that = this;
switch (_that) {
case _AppleSigningCertificateDto():
return $default(_that.id,_that.certificateType,_that.displayName,_that.serialNumber,_that.certificateContent,_that.expirationDate,_that.isActivated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String certificateType,  String displayName,  String serialNumber,  String certificateContent,  DateTime expirationDate,  bool isActivated)?  $default,) {final _that = this;
switch (_that) {
case _AppleSigningCertificateDto() when $default != null:
return $default(_that.id,_that.certificateType,_that.displayName,_that.serialNumber,_that.certificateContent,_that.expirationDate,_that.isActivated);case _:
  return null;

}
}

}

/// @nodoc


class _AppleSigningCertificateDto implements AppleSigningCertificateDto {
  const _AppleSigningCertificateDto({required this.id, required this.certificateType, required this.displayName, required this.serialNumber, required this.certificateContent, required this.expirationDate, required this.isActivated});
  

@override final  String id;
@override final  String certificateType;
@override final  String displayName;
@override final  String serialNumber;
@override final  String certificateContent;
@override final  DateTime expirationDate;
@override final  bool isActivated;

/// Create a copy of AppleSigningCertificateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleSigningCertificateDtoCopyWith<_AppleSigningCertificateDto> get copyWith => __$AppleSigningCertificateDtoCopyWithImpl<_AppleSigningCertificateDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleSigningCertificateDto&&(identical(other.id, id) || other.id == id)&&(identical(other.certificateType, certificateType) || other.certificateType == certificateType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.certificateContent, certificateContent) || other.certificateContent == certificateContent)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated));
}


@override
int get hashCode => Object.hash(runtimeType,id,certificateType,displayName,serialNumber,certificateContent,expirationDate,isActivated);

@override
String toString() {
  return 'AppleSigningCertificateDto(id: $id, certificateType: $certificateType, displayName: $displayName, serialNumber: $serialNumber, certificateContent: $certificateContent, expirationDate: $expirationDate, isActivated: $isActivated)';
}


}

/// @nodoc
abstract mixin class _$AppleSigningCertificateDtoCopyWith<$Res> implements $AppleSigningCertificateDtoCopyWith<$Res> {
  factory _$AppleSigningCertificateDtoCopyWith(_AppleSigningCertificateDto value, $Res Function(_AppleSigningCertificateDto) _then) = __$AppleSigningCertificateDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String certificateType, String displayName, String serialNumber, String certificateContent, DateTime expirationDate, bool isActivated
});




}
/// @nodoc
class __$AppleSigningCertificateDtoCopyWithImpl<$Res>
    implements _$AppleSigningCertificateDtoCopyWith<$Res> {
  __$AppleSigningCertificateDtoCopyWithImpl(this._self, this._then);

  final _AppleSigningCertificateDto _self;
  final $Res Function(_AppleSigningCertificateDto) _then;

/// Create a copy of AppleSigningCertificateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? certificateType = null,Object? displayName = null,Object? serialNumber = null,Object? certificateContent = null,Object? expirationDate = null,Object? isActivated = null,}) {
  return _then(_AppleSigningCertificateDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,certificateType: null == certificateType ? _self.certificateType : certificateType // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,certificateContent: null == certificateContent ? _self.certificateContent : certificateContent // ignore: cast_nullable_to_non_nullable
as String,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AppleBundleIdentifierDto {

 String get id; String get identifier; String get platform;
/// Create a copy of AppleBundleIdentifierDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleBundleIdentifierDtoCopyWith<AppleBundleIdentifierDto> get copyWith => _$AppleBundleIdentifierDtoCopyWithImpl<AppleBundleIdentifierDto>(this as AppleBundleIdentifierDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleBundleIdentifierDto&&(identical(other.id, id) || other.id == id)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.platform, platform) || other.platform == platform));
}


@override
int get hashCode => Object.hash(runtimeType,id,identifier,platform);

@override
String toString() {
  return 'AppleBundleIdentifierDto(id: $id, identifier: $identifier, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $AppleBundleIdentifierDtoCopyWith<$Res>  {
  factory $AppleBundleIdentifierDtoCopyWith(AppleBundleIdentifierDto value, $Res Function(AppleBundleIdentifierDto) _then) = _$AppleBundleIdentifierDtoCopyWithImpl;
@useResult
$Res call({
 String id, String identifier, String platform
});




}
/// @nodoc
class _$AppleBundleIdentifierDtoCopyWithImpl<$Res>
    implements $AppleBundleIdentifierDtoCopyWith<$Res> {
  _$AppleBundleIdentifierDtoCopyWithImpl(this._self, this._then);

  final AppleBundleIdentifierDto _self;
  final $Res Function(AppleBundleIdentifierDto) _then;

/// Create a copy of AppleBundleIdentifierDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? identifier = null,Object? platform = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleBundleIdentifierDto].
extension AppleBundleIdentifierDtoPatterns on AppleBundleIdentifierDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleBundleIdentifierDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleBundleIdentifierDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleBundleIdentifierDto value)  $default,){
final _that = this;
switch (_that) {
case _AppleBundleIdentifierDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleBundleIdentifierDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppleBundleIdentifierDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String identifier,  String platform)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleBundleIdentifierDto() when $default != null:
return $default(_that.id,_that.identifier,_that.platform);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String identifier,  String platform)  $default,) {final _that = this;
switch (_that) {
case _AppleBundleIdentifierDto():
return $default(_that.id,_that.identifier,_that.platform);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String identifier,  String platform)?  $default,) {final _that = this;
switch (_that) {
case _AppleBundleIdentifierDto() when $default != null:
return $default(_that.id,_that.identifier,_that.platform);case _:
  return null;

}
}

}

/// @nodoc


class _AppleBundleIdentifierDto implements AppleBundleIdentifierDto {
  const _AppleBundleIdentifierDto({required this.id, required this.identifier, required this.platform});
  

@override final  String id;
@override final  String identifier;
@override final  String platform;

/// Create a copy of AppleBundleIdentifierDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleBundleIdentifierDtoCopyWith<_AppleBundleIdentifierDto> get copyWith => __$AppleBundleIdentifierDtoCopyWithImpl<_AppleBundleIdentifierDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleBundleIdentifierDto&&(identical(other.id, id) || other.id == id)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.platform, platform) || other.platform == platform));
}


@override
int get hashCode => Object.hash(runtimeType,id,identifier,platform);

@override
String toString() {
  return 'AppleBundleIdentifierDto(id: $id, identifier: $identifier, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$AppleBundleIdentifierDtoCopyWith<$Res> implements $AppleBundleIdentifierDtoCopyWith<$Res> {
  factory _$AppleBundleIdentifierDtoCopyWith(_AppleBundleIdentifierDto value, $Res Function(_AppleBundleIdentifierDto) _then) = __$AppleBundleIdentifierDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String identifier, String platform
});




}
/// @nodoc
class __$AppleBundleIdentifierDtoCopyWithImpl<$Res>
    implements _$AppleBundleIdentifierDtoCopyWith<$Res> {
  __$AppleBundleIdentifierDtoCopyWithImpl(this._self, this._then);

  final _AppleBundleIdentifierDto _self;
  final $Res Function(_AppleBundleIdentifierDto) _then;

/// Create a copy of AppleBundleIdentifierDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? identifier = null,Object? platform = null,}) {
  return _then(_AppleBundleIdentifierDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AppleProvisioningProfileDto {

 String get id; String get name; String get profileType; String get profileState; String get profileContent; String get uuid; DateTime get createdDate; DateTime get expirationDate; String get bundleIdId; List<String> get certificateIds;
/// Create a copy of AppleProvisioningProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleProvisioningProfileDtoCopyWith<AppleProvisioningProfileDto> get copyWith => _$AppleProvisioningProfileDtoCopyWithImpl<AppleProvisioningProfileDto>(this as AppleProvisioningProfileDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleProvisioningProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileType, profileType) || other.profileType == profileType)&&(identical(other.profileState, profileState) || other.profileState == profileState)&&(identical(other.profileContent, profileContent) || other.profileContent == profileContent)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.bundleIdId, bundleIdId) || other.bundleIdId == bundleIdId)&&const DeepCollectionEquality().equals(other.certificateIds, certificateIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,profileType,profileState,profileContent,uuid,createdDate,expirationDate,bundleIdId,const DeepCollectionEquality().hash(certificateIds));

@override
String toString() {
  return 'AppleProvisioningProfileDto(id: $id, name: $name, profileType: $profileType, profileState: $profileState, profileContent: $profileContent, uuid: $uuid, createdDate: $createdDate, expirationDate: $expirationDate, bundleIdId: $bundleIdId, certificateIds: $certificateIds)';
}


}

/// @nodoc
abstract mixin class $AppleProvisioningProfileDtoCopyWith<$Res>  {
  factory $AppleProvisioningProfileDtoCopyWith(AppleProvisioningProfileDto value, $Res Function(AppleProvisioningProfileDto) _then) = _$AppleProvisioningProfileDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String profileType, String profileState, String profileContent, String uuid, DateTime createdDate, DateTime expirationDate, String bundleIdId, List<String> certificateIds
});




}
/// @nodoc
class _$AppleProvisioningProfileDtoCopyWithImpl<$Res>
    implements $AppleProvisioningProfileDtoCopyWith<$Res> {
  _$AppleProvisioningProfileDtoCopyWithImpl(this._self, this._then);

  final AppleProvisioningProfileDto _self;
  final $Res Function(AppleProvisioningProfileDto) _then;

/// Create a copy of AppleProvisioningProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? profileType = null,Object? profileState = null,Object? profileContent = null,Object? uuid = null,Object? createdDate = null,Object? expirationDate = null,Object? bundleIdId = null,Object? certificateIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profileType: null == profileType ? _self.profileType : profileType // ignore: cast_nullable_to_non_nullable
as String,profileState: null == profileState ? _self.profileState : profileState // ignore: cast_nullable_to_non_nullable
as String,profileContent: null == profileContent ? _self.profileContent : profileContent // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,bundleIdId: null == bundleIdId ? _self.bundleIdId : bundleIdId // ignore: cast_nullable_to_non_nullable
as String,certificateIds: null == certificateIds ? _self.certificateIds : certificateIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleProvisioningProfileDto].
extension AppleProvisioningProfileDtoPatterns on AppleProvisioningProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleProvisioningProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleProvisioningProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleProvisioningProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _AppleProvisioningProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleProvisioningProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppleProvisioningProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String profileType,  String profileState,  String profileContent,  String uuid,  DateTime createdDate,  DateTime expirationDate,  String bundleIdId,  List<String> certificateIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleProvisioningProfileDto() when $default != null:
return $default(_that.id,_that.name,_that.profileType,_that.profileState,_that.profileContent,_that.uuid,_that.createdDate,_that.expirationDate,_that.bundleIdId,_that.certificateIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String profileType,  String profileState,  String profileContent,  String uuid,  DateTime createdDate,  DateTime expirationDate,  String bundleIdId,  List<String> certificateIds)  $default,) {final _that = this;
switch (_that) {
case _AppleProvisioningProfileDto():
return $default(_that.id,_that.name,_that.profileType,_that.profileState,_that.profileContent,_that.uuid,_that.createdDate,_that.expirationDate,_that.bundleIdId,_that.certificateIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String profileType,  String profileState,  String profileContent,  String uuid,  DateTime createdDate,  DateTime expirationDate,  String bundleIdId,  List<String> certificateIds)?  $default,) {final _that = this;
switch (_that) {
case _AppleProvisioningProfileDto() when $default != null:
return $default(_that.id,_that.name,_that.profileType,_that.profileState,_that.profileContent,_that.uuid,_that.createdDate,_that.expirationDate,_that.bundleIdId,_that.certificateIds);case _:
  return null;

}
}

}

/// @nodoc


class _AppleProvisioningProfileDto implements AppleProvisioningProfileDto {
  const _AppleProvisioningProfileDto({required this.id, required this.name, required this.profileType, required this.profileState, required this.profileContent, required this.uuid, required this.createdDate, required this.expirationDate, required this.bundleIdId, required final  List<String> certificateIds}): _certificateIds = certificateIds;
  

@override final  String id;
@override final  String name;
@override final  String profileType;
@override final  String profileState;
@override final  String profileContent;
@override final  String uuid;
@override final  DateTime createdDate;
@override final  DateTime expirationDate;
@override final  String bundleIdId;
 final  List<String> _certificateIds;
@override List<String> get certificateIds {
  if (_certificateIds is EqualUnmodifiableListView) return _certificateIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certificateIds);
}


/// Create a copy of AppleProvisioningProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleProvisioningProfileDtoCopyWith<_AppleProvisioningProfileDto> get copyWith => __$AppleProvisioningProfileDtoCopyWithImpl<_AppleProvisioningProfileDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleProvisioningProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileType, profileType) || other.profileType == profileType)&&(identical(other.profileState, profileState) || other.profileState == profileState)&&(identical(other.profileContent, profileContent) || other.profileContent == profileContent)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.bundleIdId, bundleIdId) || other.bundleIdId == bundleIdId)&&const DeepCollectionEquality().equals(other._certificateIds, _certificateIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,profileType,profileState,profileContent,uuid,createdDate,expirationDate,bundleIdId,const DeepCollectionEquality().hash(_certificateIds));

@override
String toString() {
  return 'AppleProvisioningProfileDto(id: $id, name: $name, profileType: $profileType, profileState: $profileState, profileContent: $profileContent, uuid: $uuid, createdDate: $createdDate, expirationDate: $expirationDate, bundleIdId: $bundleIdId, certificateIds: $certificateIds)';
}


}

/// @nodoc
abstract mixin class _$AppleProvisioningProfileDtoCopyWith<$Res> implements $AppleProvisioningProfileDtoCopyWith<$Res> {
  factory _$AppleProvisioningProfileDtoCopyWith(_AppleProvisioningProfileDto value, $Res Function(_AppleProvisioningProfileDto) _then) = __$AppleProvisioningProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String profileType, String profileState, String profileContent, String uuid, DateTime createdDate, DateTime expirationDate, String bundleIdId, List<String> certificateIds
});




}
/// @nodoc
class __$AppleProvisioningProfileDtoCopyWithImpl<$Res>
    implements _$AppleProvisioningProfileDtoCopyWith<$Res> {
  __$AppleProvisioningProfileDtoCopyWithImpl(this._self, this._then);

  final _AppleProvisioningProfileDto _self;
  final $Res Function(_AppleProvisioningProfileDto) _then;

/// Create a copy of AppleProvisioningProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? profileType = null,Object? profileState = null,Object? profileContent = null,Object? uuid = null,Object? createdDate = null,Object? expirationDate = null,Object? bundleIdId = null,Object? certificateIds = null,}) {
  return _then(_AppleProvisioningProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profileType: null == profileType ? _self.profileType : profileType // ignore: cast_nullable_to_non_nullable
as String,profileState: null == profileState ? _self.profileState : profileState // ignore: cast_nullable_to_non_nullable
as String,profileContent: null == profileContent ? _self.profileContent : profileContent // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,bundleIdId: null == bundleIdId ? _self.bundleIdId : bundleIdId // ignore: cast_nullable_to_non_nullable
as String,certificateIds: null == certificateIds ? _self._certificateIds : certificateIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
