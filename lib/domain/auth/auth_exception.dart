enum AuthErrorType {
  accountExistsWithDifferentCredential,
  operationNotAllowed,
  userDisabled,
  userNotFound,
  wrongPassword,
  invalidVerificationCode,
  invalidVerificationId,

  requiresRecentLogin,
  emailAlreadyInUse,
  invalidEmail,
  tooManyRequests,
  expiredActionCode,

  networkRequestFailed,

  signInFailedDueToTimeout,
  unknown,

  unimplementedMethod,

  weakPassword,
  missingEmail,
  invalidActionCode,
  missingAndroidPkgName,
  missingContinueUri,
  missingIosBundleId,
  invalidContinueUri,
  unauthorizedContinueUri,
}

abstract class AuthException implements Exception {
  AuthErrorType get errorType;
  String get code;
  Exception get causeException;
  StackTrace? get stackTrace;

  bool isUnknown();
}
