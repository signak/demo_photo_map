import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_share_capp/core/extension/datetime_extension.dart';

import '../../core/util/logger.dart';
import '../../domain/image_cache/cached_image.dart';

class IdbCacheImages {
  static const String databaseName = 'image_cache.db';
  static const int databaseVersion = 1;

  static const String storeName = 'caches'; // TableName
  static const String primaryKey = id;

  static const String idxName = 'IDX_${IdbCacheImages.name}';
  static const String idxDaysEpochCreatedAt =
      'IDX_${IdbCacheImages.daysEpochCreatedAt}';

  static const String id = 'id';
  static const String name = 'file_name';
  static const String imageBytes = 'image_bytes';
  static const String createdAt = 'created_at';
  static const String daysEpochCreatedAt = 'days_epoch_created_at';
}

class IdbCachedImage extends CachedImage {
  IdbCachedImage();

  int? daysEpochCreatedAt;

  factory IdbCachedImage.of(
      String name, MemoryImage image, DateTime createdAt) {
    return IdbCachedImage()
      ..name = name
      ..data = image
      ..createdAt = createdAt
      ..daysEpochCreatedAt = createdAt.daysEpoch;
  }

  factory IdbCachedImage.fromMap(Map data) {
    final String name = data[IdbCacheImages.name];

    late final MemoryImage? image;
    if (!data.containsKey(IdbCacheImages.imageBytes)) {
      image = null;
    } else {
      final tmp = data[IdbCacheImages.imageBytes];
      if (tmp is Uint8List) {
        image = MemoryImage(tmp);
      } else if (tmp is List<int>) {
        image = MemoryImage(Uint8List.fromList(tmp));
      } else if (tmp is List<dynamic>) {
        image =
            MemoryImage(Uint8List.fromList(tmp.map((e) => e as int).toList()));
      } else {
        logger.e(
            "unknown image data type. can't convert '${tmp.runtimeType}' to List<int>");
        image = null;
      }
    }

    final DateTime createdAt = data[IdbCacheImages.createdAt] as DateTime;

    return IdbCachedImage()
      ..name = name
      ..data = image
      ..createdAt = createdAt;
  }

  Map<String, dynamic> toMap() {
    return {
      IdbCacheImages.id: id,
      IdbCacheImages.name: name,
      IdbCacheImages.imageBytes: bytes,
      IdbCacheImages.createdAt: createdAt,
      IdbCacheImages.daysEpochCreatedAt: daysEpochCreatedAt,
    };
  }
}
