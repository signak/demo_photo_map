import '../exception_util.dart';
import '../known_exception.dart';

class AuthorizationException extends KnownException {
  const AuthorizationException({
    super.code,
    required super.message,
    required super.stackTrace,
    super.plugin,
    super.causeException,
    super.causeStackTrace,
  });

  factory AuthorizationException.build({
    String? code,
    required String message,
    String? plugin,
    Exception? causeException,
    StackTrace? causeStackTrace,
  }) {
    return AuthorizationException(
      code: code,
      message: message,
      plugin: plugin,
      stackTrace: ExceptionUtil.getStackTrace(callerName: 'build'),
      causeException: causeException,
      causeStackTrace: causeStackTrace,
    );
  }
}
