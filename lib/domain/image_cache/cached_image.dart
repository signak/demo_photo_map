import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_share_capp/core/extension/fast_hashable_string.dart';

abstract class CachedImage {
  String? name;

  DateTime? createdAt;

  MemoryImage? data;

  Uint8List? get bytes => data?.bytes;

  int get id => nameToId(name);

  static int nameToId(String? name) {
    return name?.fastHash() ?? -1;
  }

  @override
  String toString() {
    return ('$runtimeType {id: $id, name: "$name", '
        'createdAt: "$createdAt", image.bytes.length: ${bytes?.length}}');
  }
}
