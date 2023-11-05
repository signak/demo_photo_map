import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/extension/datetime_extension.dart';
import '../../core/util/logger.dart';

const timestampJsonKey = JsonKey(
  toJson: TimestampUtil.timestampFromDateValue,
  fromJson: TimestampUtil.dateFromTimestampValue,
);

class TimestampUtil {
  const TimestampUtil._();

  static DateTime? convertToDate(dynamic value, {DateTime? defaultValue}) {
    if (value != null) {
      try {
        return (value as Timestamp).toDate();
      } on Exception catch (e, st) {
        logger.e("error on timestamp.toDate: '$value'", e, st);
      }
    }

    return defaultValue;
  }

  static DateTime? dateFromTimestampValue(dynamic value) =>
      (value == null || value is! Timestamp) ? null : value.toDate();

  static Timestamp? timestampFromDateValue(dynamic value) =>
      (value == null || value is! DateTime) ? null : value.toTimestamp();
}
