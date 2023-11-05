// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../infra/auth/firebase_auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$FirebaseAuthState {
  bool get isSignedIn => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool? get emailVerified => throw _privateConstructorUsedError;
  AuthProviderType? get provider => throw _privateConstructorUsedError;
  AuthorizationInfo? get authorizationInfo =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastSignedInAt => throw _privateConstructorUsedError;
  User? get rawUser => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FirebaseAuthStateCopyWith<FirebaseAuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseAuthStateCopyWith<$Res> {
  factory $FirebaseAuthStateCopyWith(
          FirebaseAuthState value, $Res Function(FirebaseAuthState) then) =
      _$FirebaseAuthStateCopyWithImpl<$Res, FirebaseAuthState>;
  @useResult
  $Res call(
      {bool isSignedIn,
      String? uid,
      String? displayName,
      String? email,
      bool? emailVerified,
      AuthProviderType? provider,
      AuthorizationInfo? authorizationInfo,
      DateTime? createdAt,
      DateTime? lastSignedInAt,
      User? rawUser,
      bool isInitialized});

  $AuthorizationInfoCopyWith<$Res>? get authorizationInfo;
}

/// @nodoc
class _$FirebaseAuthStateCopyWithImpl<$Res, $Val extends FirebaseAuthState>
    implements $FirebaseAuthStateCopyWith<$Res> {
  _$FirebaseAuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSignedIn = null,
    Object? uid = freezed,
    Object? displayName = freezed,
    Object? email = freezed,
    Object? emailVerified = freezed,
    Object? provider = freezed,
    Object? authorizationInfo = freezed,
    Object? createdAt = freezed,
    Object? lastSignedInAt = freezed,
    Object? rawUser = freezed,
    Object? isInitialized = null,
  }) {
    return _then(_value.copyWith(
      isSignedIn: null == isSignedIn
          ? _value.isSignedIn
          : isSignedIn // ignore: cast_nullable_to_non_nullable
              as bool,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      emailVerified: freezed == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      provider: freezed == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as AuthProviderType?,
      authorizationInfo: freezed == authorizationInfo
          ? _value.authorizationInfo
          : authorizationInfo // ignore: cast_nullable_to_non_nullable
              as AuthorizationInfo?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSignedInAt: freezed == lastSignedInAt
          ? _value.lastSignedInAt
          : lastSignedInAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rawUser: freezed == rawUser
          ? _value.rawUser
          : rawUser // ignore: cast_nullable_to_non_nullable
              as User?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthorizationInfoCopyWith<$Res>? get authorizationInfo {
    if (_value.authorizationInfo == null) {
      return null;
    }

    return $AuthorizationInfoCopyWith<$Res>(_value.authorizationInfo!, (value) {
      return _then(_value.copyWith(authorizationInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FirebaseAuthStateImplCopyWith<$Res>
    implements $FirebaseAuthStateCopyWith<$Res> {
  factory _$$FirebaseAuthStateImplCopyWith(_$FirebaseAuthStateImpl value,
          $Res Function(_$FirebaseAuthStateImpl) then) =
      __$$FirebaseAuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSignedIn,
      String? uid,
      String? displayName,
      String? email,
      bool? emailVerified,
      AuthProviderType? provider,
      AuthorizationInfo? authorizationInfo,
      DateTime? createdAt,
      DateTime? lastSignedInAt,
      User? rawUser,
      bool isInitialized});

  @override
  $AuthorizationInfoCopyWith<$Res>? get authorizationInfo;
}

/// @nodoc
class __$$FirebaseAuthStateImplCopyWithImpl<$Res>
    extends _$FirebaseAuthStateCopyWithImpl<$Res, _$FirebaseAuthStateImpl>
    implements _$$FirebaseAuthStateImplCopyWith<$Res> {
  __$$FirebaseAuthStateImplCopyWithImpl(_$FirebaseAuthStateImpl _value,
      $Res Function(_$FirebaseAuthStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSignedIn = null,
    Object? uid = freezed,
    Object? displayName = freezed,
    Object? email = freezed,
    Object? emailVerified = freezed,
    Object? provider = freezed,
    Object? authorizationInfo = freezed,
    Object? createdAt = freezed,
    Object? lastSignedInAt = freezed,
    Object? rawUser = freezed,
    Object? isInitialized = null,
  }) {
    return _then(_$FirebaseAuthStateImpl(
      isSignedIn: null == isSignedIn
          ? _value.isSignedIn
          : isSignedIn // ignore: cast_nullable_to_non_nullable
              as bool,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      emailVerified: freezed == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      provider: freezed == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as AuthProviderType?,
      authorizationInfo: freezed == authorizationInfo
          ? _value.authorizationInfo
          : authorizationInfo // ignore: cast_nullable_to_non_nullable
              as AuthorizationInfo?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSignedInAt: freezed == lastSignedInAt
          ? _value.lastSignedInAt
          : lastSignedInAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rawUser: freezed == rawUser
          ? _value.rawUser
          : rawUser // ignore: cast_nullable_to_non_nullable
              as User?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FirebaseAuthStateImpl extends _FirebaseAuthState {
  const _$FirebaseAuthStateImpl(
      {required this.isSignedIn,
      this.uid = null,
      this.displayName = null,
      this.email = null,
      this.emailVerified = false,
      this.provider = null,
      this.authorizationInfo = null,
      this.createdAt = null,
      this.lastSignedInAt = null,
      this.rawUser = null,
      this.isInitialized = true})
      : super._();

  @override
  final bool isSignedIn;
  @override
  @JsonKey()
  final String? uid;
  @override
  @JsonKey()
  final String? displayName;
  @override
  @JsonKey()
  final String? email;
  @override
  @JsonKey()
  final bool? emailVerified;
  @override
  @JsonKey()
  final AuthProviderType? provider;
  @override
  @JsonKey()
  final AuthorizationInfo? authorizationInfo;
  @override
  @JsonKey()
  final DateTime? createdAt;
  @override
  @JsonKey()
  final DateTime? lastSignedInAt;
  @override
  @JsonKey()
  final User? rawUser;
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString() {
    return 'FirebaseAuthState(isSignedIn: $isSignedIn, uid: $uid, displayName: $displayName, email: $email, emailVerified: $emailVerified, provider: $provider, authorizationInfo: $authorizationInfo, createdAt: $createdAt, lastSignedInAt: $lastSignedInAt, rawUser: $rawUser, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseAuthStateImpl &&
            (identical(other.isSignedIn, isSignedIn) ||
                other.isSignedIn == isSignedIn) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.authorizationInfo, authorizationInfo) ||
                other.authorizationInfo == authorizationInfo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastSignedInAt, lastSignedInAt) ||
                other.lastSignedInAt == lastSignedInAt) &&
            (identical(other.rawUser, rawUser) || other.rawUser == rawUser) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSignedIn,
      uid,
      displayName,
      email,
      emailVerified,
      provider,
      authorizationInfo,
      createdAt,
      lastSignedInAt,
      rawUser,
      isInitialized);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseAuthStateImplCopyWith<_$FirebaseAuthStateImpl> get copyWith =>
      __$$FirebaseAuthStateImplCopyWithImpl<_$FirebaseAuthStateImpl>(
          this, _$identity);
}

abstract class _FirebaseAuthState extends FirebaseAuthState {
  const factory _FirebaseAuthState(
      {required final bool isSignedIn,
      final String? uid,
      final String? displayName,
      final String? email,
      final bool? emailVerified,
      final AuthProviderType? provider,
      final AuthorizationInfo? authorizationInfo,
      final DateTime? createdAt,
      final DateTime? lastSignedInAt,
      final User? rawUser,
      final bool isInitialized}) = _$FirebaseAuthStateImpl;
  const _FirebaseAuthState._() : super._();

  @override
  bool get isSignedIn;
  @override
  String? get uid;
  @override
  String? get displayName;
  @override
  String? get email;
  @override
  bool? get emailVerified;
  @override
  AuthProviderType? get provider;
  @override
  AuthorizationInfo? get authorizationInfo;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastSignedInAt;
  @override
  User? get rawUser;
  @override
  bool get isInitialized;
  @override
  @JsonKey(ignore: true)
  _$$FirebaseAuthStateImplCopyWith<_$FirebaseAuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
