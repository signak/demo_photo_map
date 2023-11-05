import 'dart:math' as math;

import 'package:photo_share_capp/core/exception/known_exception.dart';

class ExceptionUtil {
  const ExceptionUtil._();
  static const _methodNameOfGetStackTraceString = 'getStackTraceString\n';
  static const _methodNameLengthOfGetStackTraceString =
      _methodNameOfGetStackTraceString.length;

  static String getStackTraceString({required String callerName}) {
    final st = StackTrace.current.toString();

    // print('/--- origin head 10');
    // print(st.split("\n").getRange(0, 10).join("\n"));
    // print('---/');

    final caller = '$callerName\n';
    final startIndex = st.indexOf(
            caller,
            (st.indexOf(_methodNameOfGetStackTraceString) +
                _methodNameLengthOfGetStackTraceString)) +
        caller.length;
    return st.substring(startIndex).trimLeft();
  }

  static StackTrace getStackTrace({required String callerName}) {
    return StackTrace.fromString(getStackTraceString(callerName: callerName));
  }

  static StackTrace mergeStackTrace({
    required StackTrace current,
    Exception? causeException,
    StackTrace? causeStackTrace,
    int currentLimit = 10,
  }) {
    return StackTrace.fromString(
      getMergedStackTraceString(
          current: current,
          causeException: causeException,
          causeStackTrace: causeStackTrace,
          currentLimit: currentLimit),
    );
  }

  static String getMergedStackTraceString({
    required StackTrace current,
    Exception? causeException,
    StackTrace? causeStackTrace,
    int currentLimit = 10,
  }) {
    final ret = <String>[];
    final currentStack = current.toString().split('\n');
    final limit = math.min(currentLimit, currentStack.length);
    ret.addAll(currentStack.getRange(0, limit));
    if (limit < currentStack.length) {
      ret.add('... (${currentStack.length - limit} lines omitted.)');
    }
    if (causeException != null) {
      ret.add('---- cause: ${causeException.runtimeType} ----');
    }

    if (causeStackTrace != null) {
      if (causeException == null) {
        ret.add(
            '---- cause: (runtime type is unknown because cause exception is null) ----');
      }
      ret.add(causeStackTrace.toString());
    }

    return ret.join('\n').trim();
  }

  static String getString(dynamic error, [String? stackTrace]) {
    if (stackTrace == null) {
      return _getStringWithoutStackTrace(error);
    } else {
      return _getStringWithStackTrace(error, stackTrace);
    }
  }

  static String _getStringWithStackTrace(dynamic error, String stackTrace) {
    if (error is KnownException) {
      return '${error.runtimeType}: ${error.message}\n'
          '${stackTrace.split("\n").map((e) => '\t$e').join("\n")}';
    } else {
      return '${error.runtimeType}: ${error.toString()}\n'
          '${stackTrace.split("\n").map((e) => '\t$e').join("\n")}';
    }
  }

  static String _getStringWithoutStackTrace(dynamic error) {
    if (error is KnownException) {
      if (error.hasCauseException) {
        return ('${error.runtimeType}: ${error.message}\n\t'
            'cause ${error.causeException.runtimeType}');
      } else {
        return '${error.runtimeType}: ${error.message}';
      }
    } else {
      return '${error.runtimeType}: ${error.toString()}';
    }
  }
}
