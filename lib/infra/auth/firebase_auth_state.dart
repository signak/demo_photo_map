import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/auth/auth_state.dart';
import '../../domain/auth/authorization_info.dart';

part '../../generated/infra/auth/firebase_auth_state.freezed.dart';

@freezed
class FirebaseAuthState extends AuthState with _$FirebaseAuthState {
  const factory FirebaseAuthState({
    required bool isSignedIn,
    @Default(null) String? uid,
    @Default(null) String? displayName,
    @Default(null) String? email,
    @Default(false) bool? emailVerified,
    @Default(null) AuthProviderType? provider,
    @Default(null) AuthorizationInfo? authorizationInfo,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? lastSignedInAt,
    @Default(null) User? rawUser,
    @Default(true) bool isInitialized,
  }) = _FirebaseAuthState;

  factory FirebaseAuthState.unSignedIn() =>
      const FirebaseAuthState(isSignedIn: false);

  factory FirebaseAuthState.initial() =>
      const FirebaseAuthState(isSignedIn: false, isInitialized: false);

  const FirebaseAuthState._();
}
