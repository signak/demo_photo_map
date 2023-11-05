import '../exception_util.dart';
import '../known_exception.dart';

class AuthenticationException extends KnownException {
  const AuthenticationException({
    super.code,
    required super.message,
    required super.stackTrace,
    super.plugin,
    super.causeException,
    super.causeStackTrace,
  });

  factory AuthenticationException.build({
    String? code,
    required String message,
    String? plugin,
    Exception? causeException,
    StackTrace? causeStackTrace,
  }) {
    return AuthenticationException(
      code: code,
      message: message,
      plugin: plugin,
      stackTrace: ExceptionUtil.getStackTrace(callerName: 'build'),
      causeException: causeException,
      causeStackTrace: causeStackTrace,
    );
  }
}
