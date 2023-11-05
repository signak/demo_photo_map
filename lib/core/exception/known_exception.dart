import 'exception_util.dart';

abstract class KnownException implements Exception {
  const KnownException({
    this.code,
    required this.message,
    required this.stackTrace,
    this.plugin,
    this.causeException,
    this.causeStackTrace,
  });

  final String? code;
  final String message;
  final String? plugin;
  final StackTrace stackTrace;
  final Exception? causeException;
  final StackTrace? causeStackTrace;

  bool get hasCode => code != null;
  bool get hasPlugin => plugin != null;
  bool get hasCauseException => causeException != null;
  bool get hasCauseStackTrace => causeStackTrace != null;

  String get mergedStackTraceString {
    if (hasCauseException && hasCauseStackTrace) {
      return ExceptionUtil.getMergedStackTraceString(
          current: stackTrace,
          causeException: causeException!,
          causeStackTrace: causeStackTrace!);
    } else {
      return stackTrace.toString();
    }
  }

  StackTrace get mergedStackTrace {
    return StackTrace.fromString(mergedStackTraceString);
  }

  @override
  String toString() {
    return ExceptionUtil.getString(this, mergedStackTraceString);
  }

  String toStringWithoutStackTrace() {
    return ExceptionUtil.getString(this);
  }
}
