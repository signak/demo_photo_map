import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exception/exception_util.dart';
import '../../domain/auth/auth_exception.dart';

const unknownCode = 'unknown-code';
const signInTimeoutErrorCode = 'sign-in-failed-due-to-timeout';

final _codeTypePairs = <String, AuthErrorType>{
  'account-exists-with-different-credential':
      AuthErrorType.accountExistsWithDifferentCredential,
  'operation-not-allowed': AuthErrorType.operationNotAllowed,
  'user-disabled': AuthErrorType.userDisabled,
  'user-not-found': AuthErrorType.userNotFound,
  'wrong-password': AuthErrorType.wrongPassword,
  'invalid-verification-code': AuthErrorType.invalidVerificationCode,
  'invalid-verification-id': AuthErrorType.invalidVerificationId,
  'network-request-failed': AuthErrorType.networkRequestFailed,

  // mail/pass auth
  'email-already-in-use': AuthErrorType.emailAlreadyInUse,
  'invalid-email': AuthErrorType.invalidEmail,
  'weak-password': AuthErrorType.weakPassword,
  'missing-email': AuthErrorType.missingEmail,
  'expired-action-code': AuthErrorType.expiredActionCode,
  'invalid-action-code': AuthErrorType.invalidActionCode,

  /// An Android package name must be provided if the Android app is required to be installed.
  'missing-android-pkg-name': AuthErrorType.missingAndroidPkgName,

  /// A continue URL must be provided in the request.
  'missing-continue-uri': AuthErrorType.missingContinueUri,

  /// An iOS Bundle ID must be provided if an App Store ID is provided.
  'missing-ios-bundle-id': AuthErrorType.missingIosBundleId,

  /// The continue URL provided in the request is invalid.
  'invalid-continue-uri': AuthErrorType.invalidContinueUri,

  /// The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.
  'unauthorized-continue-uri': AuthErrorType.unauthorizedContinueUri,
};

// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
final _codeOnSignInWithCredentials = <String>[
  'account-exists-with-different-credential',
  'operation-not-allowed',
  'user-disabled',
  'user-not-found',
  'wrong-password',
  'invalid-verification-code',
  'invalid-verification-id',
  'network-request-failed',
];

final _codeOnSignOutWithCredentials = <String>[
  'network-request-failed',
];

final _codeOnSendPasswordResetEmail = <String>[
  /// Thrown if the email address is not valid.
  'invalid-email',

  /// An Android package name must be provided if the Android app is required to be installed.
  'missing-android-pkg-name',

  /// A continue URL must be provided in the request.
  'missing-continue-uri',

  /// An iOS Bundle ID must be provided if an App Store ID is provided.
  'missing-ios-bundle-id',

  /// The continue URL provided in the request is invalid.
  'invalid-continue-uri',

  /// The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.
  'unauthorized-continue-uri',

  /// Thrown if there is no user corresponding to the email address.
  'user-not-found',
];

final _codeOnConfirmPasswordReset = <String>[
  /// Thrown if the action code has expired.
  'expired-action-code',

  /// Thrown if the action code is invalid. This can happen if the code is malformed or has already been used.
  'invalid-action-code',

  /// Thrown if the user corresponding to the given action code has been disabled.
  'user-disabled',

  /// Thrown if there is no user corresponding to the action code. This may have happened if the user was deleted between when the action code was issued and when this method was called.
  'user-not-found',

  /// Thrown if the new password is not strong enough.
  'weak-password',
];

final _codeOnCreateUserWithEmailAndPassword = <String>[
  /// Thrown if there already exists an account with the given email address.
  'email-already-in-use',

  /// Thrown if the email address is not valid.
  'invalid-email',

  /// Thrown if email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.
  'operation-not-allowed',

  /// Thrown if the password is not strong enough.
  'weak-password',

  // THrown if email address is null or empty.
  'missing-email',
];

final _codeOnSignInWithEmailAndPassword = <String>[
  /// Thrown if the email address is not valid.
  'invalid-email',

  /// Thrown if the user corresponding to the given email has been disabled.
  'user-disabled',

  /// Thrown if there is no user corresponding to the given email.
  'user-not-found',

  /// Thrown if the password is invalid for the given email, or the account corresponding to the email does not have a password set.
  'wrong-password',
];

class FbAuthException extends AuthException {
  FbAuthException(AuthErrorType errorType, String code,
      Exception causeException, StackTrace stackTrace)
      : _errorType = errorType,
        _code = code,
        _causeException = causeException,
        _stackTrace = stackTrace,
        super();

  FbAuthException.unknownException(Exception e)
      : this(AuthErrorType.unknown, unknownCode, e,
            ExceptionUtil.getStackTrace(callerName: 'unknownException'));

  factory FbAuthException.onSignInWithCredential(Exception e) {
    return _construct(
        'onSignInWithCredential', _codeOnSignInWithCredentials, e);
  }

  factory FbAuthException.onSignInTimeout(Exception e) {
    return FbAuthException(
        AuthErrorType.signInFailedDueToTimeout,
        signInTimeoutErrorCode,
        e,
        ExceptionUtil.getStackTrace(callerName: 'onSignInTimeout'));
  }

  factory FbAuthException.onSignOutWithCredential(Exception e) {
    return _construct(
        'onSignOutWithCredential', _codeOnSignOutWithCredentials, e);
  }

  factory FbAuthException.onSendPasswordResetEmail(Exception e) {
    return _construct(
        'onSendPasswordResetEmail', _codeOnSendPasswordResetEmail, e);
  }

  factory FbAuthException.onConfirmPasswordReset(Exception e) {
    return _construct('onConfirmPasswordReset', _codeOnConfirmPasswordReset, e);
  }

  factory FbAuthException.onCreateUserWithEmailAndPassword(Exception e) {
    return _construct('onCreateUserWithEmailAndPassword',
        _codeOnCreateUserWithEmailAndPassword, e);
  }

  factory FbAuthException.onSignInWithEmailAndPassword(Exception e) {
    return _construct(
        'onSignInWithEmailAndPassword', _codeOnSignInWithEmailAndPassword, e);
  }

  static FbAuthException _construct(
      String constructorName, List<String> codes, Exception e) {
    final stackTrace = ExceptionUtil.getStackTrace(callerName: constructorName);
    if (e is FirebaseAuthException) {
      if (codes.contains(e.code)) {
        final t = _codeTypePairs[e.code]!;
        return FbAuthException(t, e.code, e, stackTrace);
      }
    }
    return FbAuthException.unknownException(e);
  }

  final AuthErrorType _errorType;
  final String _code;
  final Exception _causeException;
  final StackTrace _stackTrace;

  @override
  bool isUnknown() {
    return errorType == AuthErrorType.unknown;
  }

  @override
  Exception get causeException => _causeException;

  @override
  String get code => _code;

  @override
  AuthErrorType get errorType => _errorType;

  @override
  StackTrace? get stackTrace => _stackTrace;

  @override
  String toString() {
    final String message = (_causeException is FirebaseException)
        ? ': ${(_causeException as FirebaseException).message}'
        : '';
    return '[FbAuthException/$errorType] $_code$message';
  }
}
