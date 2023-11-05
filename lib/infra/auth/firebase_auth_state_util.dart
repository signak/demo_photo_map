import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/auth/auth_state.dart';
import 'firebase_auth_state.dart';

class FirebaseAuthStateUtil {
  static bool valueEquals(AuthState? a, AuthState? b) {
    if (a == null && b == null) return true;

    if (a == null || b == null) {
      return false;
    }

    return (a.isSignedIn == b.isSignedIn &&
        a.uid == b.uid &&
        a.displayName == b.displayName &&
        a.email == b.email &&
        a.emailVerified == b.emailVerified &&
        a.provider == b.provider &&
        a.authorizationInfo?.isSystemAdmin ==
            b.authorizationInfo?.isSystemAdmin &&
        a.authorizationInfo?.isAuthorizationAdmin ==
            b.authorizationInfo?.isAuthorizationAdmin &&
        a.authorizationInfo?.isObservationPointMaintainer ==
            b.authorizationInfo?.isObservationPointMaintainer &&
        a.authorizationInfo?.canRead == b.authorizationInfo?.canRead &&
        a.authorizationInfo?.canWrite == b.authorizationInfo?.canWrite &&
        a.createdAt == b.createdAt &&
        a.lastSignedInAt == b.lastSignedInAt);
  }

  static FirebaseAuthState buildFrom(User? user) {
    return FirebaseAuthState(
      isSignedIn: user != null,
      uid: user?.uid,
      displayName: user?.displayName,
      email: user?.email,
      emailVerified: user?.emailVerified,
      provider: _getProviderType(user),
      createdAt: user?.metadata.creationTime,
      lastSignedInAt: user?.metadata.lastSignInTime,
      rawUser: user,
    );
  }

  static AuthProviderType? _getProviderType(User? user) {
    final data = user?.providerData;
    if (data != null && data.isNotEmpty) {
      final providerId = data[0].providerId;
      switch (providerId) {
        case 'password':
          return AuthProviderType.password;
        case 'phone':
          return AuthProviderType.phone;
        case 'google':
          return AuthProviderType.google;
        case 'facebook':
          return AuthProviderType.facebook;
        case 'twitter':
          return AuthProviderType.twitter;
        case 'github':
          return AuthProviderType.github;
        default:
          return AuthProviderType.unknown;
      }
    }
    return null;
  }
}
