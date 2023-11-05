import 'package:flutter/material.dart';

import '../../core/util/result.dart';

abstract class ImageCacheManager {
  /// メモリをストレージに保存する（または一度閉じて開き直す。実装に依存）
  Future<bool> flush();

  Future<bool> open({bool skipDeleteExpired = false});

  /// Connectionを利用しているインスタンス数が0になる場合にDBを閉じてTrueを返す。
  Future<bool> close({bool force = false});

  Future<int> updateOrInsert(String name, MemoryImage image);

  Future<MemoryImage?> get(int recordId, String name);

  Future<bool> delete(String name);

  Future<bool> clearCache();

  /// store images in cache storage for debugging.
  /// this method functions on only debug mode.<br>
  /// Usage example:
  /// ```dart
  /// const String file = 'assets/images/large_image.jpg';
  /// final data = (await rootBundle.load(file)).buffer.asUint8List();
  /// final image = MemoryImage(data);
  ///
  /// await imageCacheManager.filledBy(image: image, length: 20).then(
  ///   (result) => result.when(
  ///     ok: (v) => print('stored $v images in cache storage.'),
  ///     err: (e) => print('failed to store images in cache storage. - $e'),
  ///   ),
  /// );
  /// ```
  Future<Result<int, String>> filledBy(
      {required MemoryImage image, required int length});
}
