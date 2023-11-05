import 'package:flutter/foundation.dart'; // ignore: unused_import
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../infra/util/timestamp_util.dart';

part '../../generated/domain/map/map_tile_info.freezed.dart';
part '../../generated/domain/map/map_tile_info.g.dart';

// TODO [低] infraに依存してるのをなおす
@freezed
class MapTileInfo with _$MapTileInfo {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MapTileInfo({
    required int id,
    required int tileIndex,
    required String name,
    required String tileUri,
    required String creditText,
    required String licensePageUrl,
    required bool enabled,
    required bool defaultTile,
    @Default(null) @timestampJsonKey DateTime? createdAt,
    @Default(null) @timestampJsonKey DateTime? updatedAt,
    @Default(null) String? updatedBy,
  }) = _MapTileInfo;

  const MapTileInfo._();

  factory MapTileInfo.fromJson(Map<String, dynamic> json) =>
      _$MapTileInfoFromJson(json);

  bool get isEnabled => enabled;
  bool get isDisabled => !enabled;

  bool get isDefaultTile => defaultTile;
}
