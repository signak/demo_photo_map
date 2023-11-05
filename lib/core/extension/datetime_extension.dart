import 'package:cloud_firestore/cloud_firestore.dart';

extension DateTimeEx on DateTime {
  Timestamp toTimestamp() {
    return Timestamp.fromDate(this);
  }

  /// epoch日を取得する
  int get daysEpoch {
    return (millisecondsSinceEpoch / (1000 * 60 * 60 * 24)).round();
  }

  /// epoch秒を取得する
  int get secondsEpoch {
    return (millisecondsSinceEpoch / 1000).round();
  }
}
