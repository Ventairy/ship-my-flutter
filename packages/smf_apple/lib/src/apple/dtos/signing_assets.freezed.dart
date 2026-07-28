// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signing_assets.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppleSigningCertificate {

 String get id; String get certificateType; String get displayName; String get serialNumber; String get certificateContent; DateTime get expirationDate; bool get activated;
/// Create a copy of AppleSigningCertificate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleSigningCertificateCopyWith<AppleSigningCertificate> get copyWith => _$AppleSigningCertificateCopyWithImpl<AppleSigningCertificate>(this as AppleSigningCertificate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleSigningCertificate&&(identical(other.id, id) || other.id == id)&&(identical(other.certificateType, certificateType) || other.certificateType == certificateType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.certificateContent, certificateContent) || other.certificateContent == certificateContent)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.activated, activated) || other.activated == activated));
}


@override
int get hashCode => Object.hash(runtimeType,id,certificateType,displayName,serialNumber,certificateContent,expirationDate,activated);

@override
String toString() {
  return 'AppleSigningCertificate(id: $id, certificateType: $certificateType, displayName: $displayName, serialNumber: $serialNumber, certificateContent: $certificateContent, expirationDate: $expirationDate, activated: $activated)';
}


}

/// @nodoc
abstract mixin class $AppleSigningCertificateCopyWith<$Res>  {
  factory $AppleSigningCertificateCopyWith(AppleSigningCertificate value, $Res Function(AppleSigningCertificate) _then) = _$AppleSigningCertificateCopyWithImpl;
@useResult
$Res call({
 String id, String certificateType, String displayName, String serialNumber, String certificateContent, DateTime expirationDate, bool activated
});




}
/// @nodoc
class _$AppleSigningCertificateCopyWithImpl<$Res>
    implements $AppleSigningCertificateCopyWith<$Res> {
  _$AppleSigningCertificateCopyWithImpl(this._self, this._then);

  final AppleSigningCertificate _self;
  final $Res Function(AppleSigningCertificate) _then;

/// Create a copy of AppleSigningCertificate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? certificateType = null,Object? displayName = null,Object? serialNumber = null,Object? certificateContent = null,Object? expirationDate = null,Object? activated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,certificateType: null == certificateType ? _self.certificateType : certificateType // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,certificateContent: null == certificateContent ? _self.certificateContent : certificateContent // ignore: cast_nullable_to_non_nullable
as String,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,activated: null == activated ? _self.activated : activated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppleSigningCertificate].
extension AppleSigningCertificatePatterns on AppleSigningCertificate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleSigningCertificate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleSigningCertificate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleSigningCertificate value)  $default,){
final _that = this;
switch (_that) {
case _AppleSigningCertificate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleSigningCertificate value)?  $default,){
final _that = this;
switch (_that) {
case _AppleSigningCertificate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String certificateType,  String displayName,  String serialNumber,  String certificateContent,  DateTime expirationDate,  bool activated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppleSigningCertificate() when $default != null:
return $default(_that.id,_that.certificateType,_that.displayName,_that.serialNumber,_that.certificateContent,_that.expirationDate,_that.activated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String certificateType,  String displayName,  String serialNumber,  String certificateContent,  DateTime expirationDate,  bool activated)  $default,) {final _that = this;
switch (_that) {
case _AppleSigningCertificate():
return $default(_that.id,_that.certificateType,_that.displayName,_that.serialNumber,_that.certificateContent,_that.expirationDate,_that.activated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String certificateType,  String displayName,  String serialNumber,  String certificateContent,  DateTime expirationDate,  bool activated)?  $default,) {final _that = this;
switch (_that) {
case _AppleSigningCertificate() when $default != null:
return $default(_that.id,_that.certificateType,_that.displayName,_that.serialNumber,_that.certificateContent,_that.expirationDate,_that.activated);case _:
  return null;

}
}

}

/// @nodoc


class _AppleSigningCertificate implements AppleSigningCertificate {
  const _AppleSigningCertificate({required this.id, required this.certificateType, required this.displayName, required this.serialNumber, required this.certificateContent, required this.expirationDate, required this.activated});
  

@override final  String id;
@override final  String certificateType;
@override final  String displayName;
@override final  String serialNumber;
@override final  String certificateContent;
@override final  DateTime expirationDate;
@override final  bool activated;

/// Create a copy of AppleSigningCertificate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleSigningCertificateCopyWith<_AppleSigningCertificate> get copyWith => __$AppleSigningCertificateCopyWithImpl<_AppleSigningCertificate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleSigningCertificate&&(identical(other.id, id) || other.id == id)&&(identical(other.certificateType, certificateType) || other.certificateType == certificateType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.certificateContent, certificateContent) || other.certificateContent == certificateContent)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.activated, activated) || other.activated == activated));
}


@override
int get hashCode => Object.hash(runtimeType,id,certificateType,displayName,serialNumber,certificateContent,expirationDate,activated);

@override
String toString() {
  return 'AppleSigningCertificate(id: $id, certificateType: $certificateType, displayName: $displayName, serialNumber: $serialNumber, certificateContent: $certificateContent, expirationDate: $expirationDate, activated: $activated)';
}


}

/// @nodoc
abstract mixin class _$AppleSigningCertificateCopyWith<$Res> implements $AppleSigningCertificateCopyWith<$Res> {
  factory _$AppleSigningCertificateCopyWith(_AppleSigningCertificate value, $Res Function(_AppleSigningCertificate) _then) = __$AppleSigningCertificateCopyWithImpl;
@override @useResult
$Res call({
 String id, String certificateType, String displayName, String serialNumber, String certificateContent, DateTime expirationDate, bool activated
});




}
/// @nodoc
class __$AppleSigningCertificateCopyWithImpl<$Res>
    implements _$AppleSigningCertificateCopyWith<$Res> {
  __$AppleSigningCertificateCopyWithImpl(this._self, this._then);

  final _AppleSigningCertificate _self;
  final $Res Function(_AppleSigningCertificate) _then;

/// Create a copy of AppleSigningCertificate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? certificateType = null,Object? displayName = null,Object? serialNumber = null,Object? certificateContent = null,Object? expirationDate = null,Object? activated = null,}) {
  return _then(_AppleSigningCertificate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,certificateType: null == certificateType ? _self.certificateType : certificateType // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,certificateContent: null == certificateContent ? _self.certificateContent : certificateContent // ignore: cast_nullable_to_non_nullable
as String,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,activated: null == activated ? _self.activated : activated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AppleBundleIdentifier {

 String get id; String get identifier; String get platform;
/// Create a copy of AppleBundleIdentifier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleBundleIdentifierCopyWith<AppleBundleIdentifier> get copyWith => _$AppleBundleIdentifierCopyWithImpl<AppleBundleIdentifier>(this as AppleBundleIdentifier, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleBundleIdentifier&&(identical(other.id, id) || other.id == id)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.platform, platform) || other.platform == platform));
}


@override
int get hashCode => Object.hash(runtimeType,id,identifier,platform);

@override
String toString() {
  return 'AppleBundleIdentifier(id: $id, identifier: $identifier, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $AppleBundleIdentifierCopyWith<$Res>  {
  factory $AppleBundleIdentifierCopyWith(AppleBundleIdentifier value, $Res Function(AppleBundleIdentifier) _then) = _$AppleBundleIdentifierCopyWithImpl;
@useResult
$Res call({
 String id, String identifier, String platform
});




}
/// @nodoc
class _$AppleBundleIdentifierCopyWithImpl<$Res>
    implements $AppleBundleIdentifierCopyWith<$Res> {
  _$AppleBundleIdentifierCopyWithImpl(this._self, this._then);

  final AppleBundleIdentifier _self;
  final $Res Function(AppleBundleIdentifier) _then;

/// Create a copy of AppleBundleIdentifier
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


/// Adds pattern-matching-related methods to [AppleBundleIdentifier].
extension AppleBundleIdentifierPatterns on AppleBundleIdentifier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleBundleIdentifier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleBundleIdentifier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleBundleIdentifier value)  $default,){
final _that = this;
switch (_that) {
case _AppleBundleIdentifier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleBundleIdentifier value)?  $default,){
final _that = this;
switch (_that) {
case _AppleBundleIdentifier() when $default != null:
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
case _AppleBundleIdentifier() when $default != null:
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
case _AppleBundleIdentifier():
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
case _AppleBundleIdentifier() when $default != null:
return $default(_that.id,_that.identifier,_that.platform);case _:
  return null;

}
}

}

/// @nodoc


class _AppleBundleIdentifier implements AppleBundleIdentifier {
  const _AppleBundleIdentifier({required this.id, required this.identifier, required this.platform});
  

@override final  String id;
@override final  String identifier;
@override final  String platform;

/// Create a copy of AppleBundleIdentifier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleBundleIdentifierCopyWith<_AppleBundleIdentifier> get copyWith => __$AppleBundleIdentifierCopyWithImpl<_AppleBundleIdentifier>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleBundleIdentifier&&(identical(other.id, id) || other.id == id)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.platform, platform) || other.platform == platform));
}


@override
int get hashCode => Object.hash(runtimeType,id,identifier,platform);

@override
String toString() {
  return 'AppleBundleIdentifier(id: $id, identifier: $identifier, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$AppleBundleIdentifierCopyWith<$Res> implements $AppleBundleIdentifierCopyWith<$Res> {
  factory _$AppleBundleIdentifierCopyWith(_AppleBundleIdentifier value, $Res Function(_AppleBundleIdentifier) _then) = __$AppleBundleIdentifierCopyWithImpl;
@override @useResult
$Res call({
 String id, String identifier, String platform
});




}
/// @nodoc
class __$AppleBundleIdentifierCopyWithImpl<$Res>
    implements _$AppleBundleIdentifierCopyWith<$Res> {
  __$AppleBundleIdentifierCopyWithImpl(this._self, this._then);

  final _AppleBundleIdentifier _self;
  final $Res Function(_AppleBundleIdentifier) _then;

/// Create a copy of AppleBundleIdentifier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? identifier = null,Object? platform = null,}) {
  return _then(_AppleBundleIdentifier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AppleProvisioningProfile {

 String get id; String get name; String get profileType; String get profileState; String get profileContent; String get uuid; DateTime get createdDate; DateTime get expirationDate; String get bundleIdId; List<String> get certificateIds;
/// Create a copy of AppleProvisioningProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppleProvisioningProfileCopyWith<AppleProvisioningProfile> get copyWith => _$AppleProvisioningProfileCopyWithImpl<AppleProvisioningProfile>(this as AppleProvisioningProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppleProvisioningProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileType, profileType) || other.profileType == profileType)&&(identical(other.profileState, profileState) || other.profileState == profileState)&&(identical(other.profileContent, profileContent) || other.profileContent == profileContent)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.bundleIdId, bundleIdId) || other.bundleIdId == bundleIdId)&&const DeepCollectionEquality().equals(other.certificateIds, certificateIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,profileType,profileState,profileContent,uuid,createdDate,expirationDate,bundleIdId,const DeepCollectionEquality().hash(certificateIds));

@override
String toString() {
  return 'AppleProvisioningProfile(id: $id, name: $name, profileType: $profileType, profileState: $profileState, profileContent: $profileContent, uuid: $uuid, createdDate: $createdDate, expirationDate: $expirationDate, bundleIdId: $bundleIdId, certificateIds: $certificateIds)';
}


}

/// @nodoc
abstract mixin class $AppleProvisioningProfileCopyWith<$Res>  {
  factory $AppleProvisioningProfileCopyWith(AppleProvisioningProfile value, $Res Function(AppleProvisioningProfile) _then) = _$AppleProvisioningProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String profileType, String profileState, String profileContent, String uuid, DateTime createdDate, DateTime expirationDate, String bundleIdId, List<String> certificateIds
});




}
/// @nodoc
class _$AppleProvisioningProfileCopyWithImpl<$Res>
    implements $AppleProvisioningProfileCopyWith<$Res> {
  _$AppleProvisioningProfileCopyWithImpl(this._self, this._then);

  final AppleProvisioningProfile _self;
  final $Res Function(AppleProvisioningProfile) _then;

/// Create a copy of AppleProvisioningProfile
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


/// Adds pattern-matching-related methods to [AppleProvisioningProfile].
extension AppleProvisioningProfilePatterns on AppleProvisioningProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppleProvisioningProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppleProvisioningProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppleProvisioningProfile value)  $default,){
final _that = this;
switch (_that) {
case _AppleProvisioningProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppleProvisioningProfile value)?  $default,){
final _that = this;
switch (_that) {
case _AppleProvisioningProfile() when $default != null:
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
case _AppleProvisioningProfile() when $default != null:
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
case _AppleProvisioningProfile():
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
case _AppleProvisioningProfile() when $default != null:
return $default(_that.id,_that.name,_that.profileType,_that.profileState,_that.profileContent,_that.uuid,_that.createdDate,_that.expirationDate,_that.bundleIdId,_that.certificateIds);case _:
  return null;

}
}

}

/// @nodoc


class _AppleProvisioningProfile implements AppleProvisioningProfile {
  const _AppleProvisioningProfile({required this.id, required this.name, required this.profileType, required this.profileState, required this.profileContent, required this.uuid, required this.createdDate, required this.expirationDate, required this.bundleIdId, required final  List<String> certificateIds}): _certificateIds = certificateIds;
  

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


/// Create a copy of AppleProvisioningProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppleProvisioningProfileCopyWith<_AppleProvisioningProfile> get copyWith => __$AppleProvisioningProfileCopyWithImpl<_AppleProvisioningProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppleProvisioningProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileType, profileType) || other.profileType == profileType)&&(identical(other.profileState, profileState) || other.profileState == profileState)&&(identical(other.profileContent, profileContent) || other.profileContent == profileContent)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.bundleIdId, bundleIdId) || other.bundleIdId == bundleIdId)&&const DeepCollectionEquality().equals(other._certificateIds, _certificateIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,profileType,profileState,profileContent,uuid,createdDate,expirationDate,bundleIdId,const DeepCollectionEquality().hash(_certificateIds));

@override
String toString() {
  return 'AppleProvisioningProfile(id: $id, name: $name, profileType: $profileType, profileState: $profileState, profileContent: $profileContent, uuid: $uuid, createdDate: $createdDate, expirationDate: $expirationDate, bundleIdId: $bundleIdId, certificateIds: $certificateIds)';
}


}

/// @nodoc
abstract mixin class _$AppleProvisioningProfileCopyWith<$Res> implements $AppleProvisioningProfileCopyWith<$Res> {
  factory _$AppleProvisioningProfileCopyWith(_AppleProvisioningProfile value, $Res Function(_AppleProvisioningProfile) _then) = __$AppleProvisioningProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String profileType, String profileState, String profileContent, String uuid, DateTime createdDate, DateTime expirationDate, String bundleIdId, List<String> certificateIds
});




}
/// @nodoc
class __$AppleProvisioningProfileCopyWithImpl<$Res>
    implements _$AppleProvisioningProfileCopyWith<$Res> {
  __$AppleProvisioningProfileCopyWithImpl(this._self, this._then);

  final _AppleProvisioningProfile _self;
  final $Res Function(_AppleProvisioningProfile) _then;

/// Create a copy of AppleProvisioningProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? profileType = null,Object? profileState = null,Object? profileContent = null,Object? uuid = null,Object? createdDate = null,Object? expirationDate = null,Object? bundleIdId = null,Object? certificateIds = null,}) {
  return _then(_AppleProvisioningProfile(
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
