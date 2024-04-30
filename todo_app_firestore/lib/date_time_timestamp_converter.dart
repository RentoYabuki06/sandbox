import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// ! ここで export を書いておくと、自動生成したファイル側で import しなくても
// Timestamp を利用できる
export 'package:cloud_firestore/cloud_firestore.dart';

class DateTimeTimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeTimestampConverter();

  @override
  DateTime fromJson(Timestamp json) {
    return json.toDate();
  }

  @override
  Timestamp toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}
