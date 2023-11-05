import 'package:flutter/foundation.dart'; // ignore: unused_import
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../infra/util/timestamp_util.dart';

part '../generated/domain/shared_photo.freezed.dart';
part '../generated/domain/shared_photo.g.dart';

// TODO [低] infraに依存してるのをなおす
@freezed
class SharedPhoto with _$SharedPhoto {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SharedPhoto({
    required int recordId,
    required String name,
    required LatLng coordinate,
    @Default(null) String? memo,
    @Default(<String>[]) List<String> photos,
    @Default(null) @timestampJsonKey DateTime? createdAt,
    @Default(null) @timestampJsonKey DateTime? updatedAt,
    @Default(null) String? updatedBy,
  }) = _SharedPhoto;

  factory SharedPhoto.fromJson(Map<String, dynamic> json) =>
      _$SharedPhotoFromJson(json);

  const SharedPhoto._();

  static String pathToFileName(String path) {
    final buf = path.split('/');
    return buf[buf.length - 1];
  }
}
