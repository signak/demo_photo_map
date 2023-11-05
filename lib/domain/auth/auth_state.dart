import 'authorization_info.dart';

enum AuthProviderType {
  password,
  phone,
  google,
  facebook,
  twitter,
  github,
  unknown,
}

abstract class AuthState {
  const AuthState();

  bool get isSignedIn;
  String? get uid;
  String? get displayName;
  String? get email;
  bool? get emailVerified;
  AuthProviderType? get provider;
  AuthorizationInfo? get authorizationInfo;
  DateTime? get createdAt;
  DateTime? get lastSignedInAt;
  bool get isInitialized;

  bool get isSignedOut => !isSignedIn;

  @Deprecated('rename to isSystemAdmin.')
  bool get isAdmin => isSystemAdmin;

  bool get canRead =>
      (authorizationInfo == null) ? false : authorizationInfo!.canRead;

  bool get canWrite =>
      (authorizationInfo == null) ? false : authorizationInfo!.canWrite;

  bool get isSystemAdmin =>
      (authorizationInfo == null) ? false : authorizationInfo!.isSystemAdmin;

  bool get isAuthorizationAdmin => (authorizationInfo == null)
      ? false
      : authorizationInfo!.isAuthorizationAdmin;

  bool get isObservationPointMaintainer => (authorizationInfo == null)
      ? false
      : authorizationInfo!.isObservationPointMaintainer;
}
