import '../../core/exception/exception_util.dart';
import '../../core/exception/known_exception.dart';

class MapTileDbException extends KnownException {
  const MapTileDbException({
    super.code,
    required super.message,
    required super.stackTrace,
    super.plugin,
    super.causeException,
    super.causeStackTrace,
  });

  factory MapTileDbException.build({
    String? code,
    required String message,
    String? plugin,
    Exception? causeException,
    StackTrace? causeStackTrace,
  }) {
    return MapTileDbException(
      code: code,
      message: message,
      plugin: plugin,
      stackTrace: ExceptionUtil.getStackTrace(callerName: 'build'),
      causeException: causeException,
      causeStackTrace: causeStackTrace,
    );
  }
}
