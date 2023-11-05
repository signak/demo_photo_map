import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:intl/intl.dart';
import 'package:photo_share_capp/core/extension/datetime_extension.dart';
import 'package:photo_share_capp/core/extension/fast_hashable_string.dart';

import '../../core/util/logger.dart';
import '../../core/util/result.dart';
import 'cache_repository_helper_method.dart';
import 'idb_cached_image.dart';
import 'image_cache_manager.dart';

class IdbImageCacheManager extends ImageCacheManager
    with CacheRepositoryHelperMethods {
  static final IdbImageCacheManager _instance = IdbImageCacheManager._();

  factory IdbImageCacheManager() {
    return _instance;
  }

  IdbImageCacheManager._() {
    //
  }

  static const int _defaultExpiredDays = 15;
  static const String _databaseFactoryName = idbFactoryNameBrowser;
  Database? _db;

  @override
  Future<bool> open({bool skipDeleteExpired = false}) async {
    final stopWatch = Stopwatch();
    stopWatch.start();

    // logger.d('idbManager.open called - $openConnections');
    if (!shouldOpenOnNewConnection()) {
      return openCompleter!.future;
    }

    final idbFactory = getIdbFactory(_databaseFactoryName);
    if (idbFactory == null) {
      throw DatabaseError(
          "No idbFactory of type '$_databaseFactoryName' supported on this platform.");
    }
    _db = await idbFactory.open(
      IdbCacheImages.databaseName,
      version: IdbCacheImages.databaseVersion,
      onUpgradeNeeded: (event) {
        Database db = (event.target as OpenDBRequest).result;
        logger.i('idb.currentVersion=${db.version}\n'
            'upgrade idb_image_cache: Ver.${event.oldVersion} to ${event.newVersion}');

        final bool storeExists =
            db.objectStoreNames.contains(IdbCacheImages.storeName);

        if (storeExists && event.oldVersion > 0) {
          event.database.deleteObjectStore(IdbCacheImages.storeName);
        }

        if (!storeExists) {
          logger.i(
              "idb create object store: '${IdbCacheImages.storeName}' ver.${event.newVersion}");
          final store = event.database.createObjectStore(
            IdbCacheImages.storeName,
            keyPath: IdbCacheImages.primaryKey,
            autoIncrement: false,
          );
          store.createIndex(IdbCacheImages.idxName, IdbCacheImages.name,
              unique: true);
          store.createIndex(IdbCacheImages.idxDaysEpochCreatedAt,
              IdbCacheImages.daysEpochCreatedAt);
        }
      },
    );
    stopWatch.stop();
    // logger.d('idb.open: ${stopWatch.elapsedMilliseconds} msec.');

    if (!skipDeleteExpired) {
      await _deleteExpiredCache();
    } else {
      logger.d('idb skip deleteExpiredCache');
    }

    // logger.d('idb.open called - $openConnections');
    return opened();
  }

  Future<int> _deleteExpiredCache(
      {int expireDays = _defaultExpiredDays}) async {
    final borderDate = DateTime.now().add(Duration(days: -expireDays));
    final borderDaysEpoch = borderDate.daysEpoch;
    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadWrite);
    final store = txn
        .objectStore(IdbCacheImages.storeName)
        .index(IdbCacheImages.idxDaysEpochCreatedAt);
    // logger.d('${store.name}, ${store.keyPath}');

    int deleteCount = 0;
    // final buf = <String>[];
    // buf.add('borderDate=$borderDate, epoch=$borderDaysEpoch');

    try {
      // upperBound: レコードを昇順に並べた時に、指定した条件のレコードよりも上に配置されるレコードを対象とする。
      // lowerBound: レコードを昇順に並べた時に、指定した条件のレコードよりも下に配置されるレコードを対象とする。
      final cursor =
          store.openCursor(range: KeyRange.upperBound(borderDaysEpoch));
      final completer = Completer<Object?>();

      cursor.listen(
        (cv) {
          try {
            // final data = cv.value as Map;
            // final id = data[IdbCacheImages.id];
            // final createdAt = data[IdbCacheImages.createdAt] as DateTime;
            // final epoch = data[IdbCacheImages.daysEpochCreatedAt] as int;

            // buf.add('delete: $id, $createdAt, $epoch');
            cv.delete();
            deleteCount++;
            cv.next();
          } catch (e, st) {
            logger.e('idb error on cursor.delete', e, st);
            rethrow;
          }
        },
        onError: (e) {
          logger.e('idb error on cursor.delete: $e');
          if (!completer.isCompleted) {
            completer.complete(e);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            // logger.d('delete expired: ${buf.join("\n")}');
            completer.complete(null);
          }
        },
      );

      final ret = await completer.future;
      if (ret == null) {
        await txn.completed;
        logger.i('idb expired cache cleared. delete $deleteCount records.');
      } else {
        txn.abort();
        logger.e('idb failed clear expired cache. transaction aborting: $ret');
      }
    } catch (err, st) {
      logger.e('idb error on openCursor', err, st);
    }

    return deleteCount;
  }

  @override
  Future<bool> close({bool force = false}) async {
    // logger.d('idbManager.close($force) called - $openConnections');
    if (!shouldClose(force: force)) return false;
    _db!.close();
    // logger.d('idb.close called - $openConnections');
    return true;
  }

  @override
  Future<bool> flush() async {
    final stopWatch = Stopwatch();
    stopWatch.start();

    bool ret = false;
    if (await close(force: true)) {
      ret = await open(skipDeleteExpired: true);
    }
    stopWatch.stop();
    logger.d('idb.flush: ret=$ret, ${stopWatch.elapsedMilliseconds} msec.');
    return ret;
  }

  static int getIdBy(String fileName) {
    return fileName.fastHash();
  }

  Future<int> getRecordCount() async {
    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadOnly);
    final store = txn.objectStore(IdbCacheImages.storeName);
    final ret = await store.count();
    return ret;
  }

  @override
  Future<int> updateOrInsert(String name, MemoryImage image) async {
    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadWrite);
    final store = txn.objectStore(IdbCacheImages.storeName);
    final id = getIdBy(name);
    final data =
        await store.getObject(id) as Map?; // LinkedMap<dynamic, dynamic>

    int ret;
    if (data == null) {
      ret = await _insert(store, name, image);
    } else {
      ret = await _update(store, data, image);
    }
    await txn.completed;
    return ret;
  }

  Future<int> _insert(ObjectStore store, String name, MemoryImage image) async {
    final cachedImage = IdbCachedImage.of(name, image, DateTime.now());
    await store.add(cachedImage.toMap());
    logger.d('idb.insert: $cachedImage');
    return cachedImage.id;
  }

  Future<int> _update(ObjectStore store, Map data, MemoryImage image) async {
    final cachedImage = IdbCachedImage.fromMap(data)
      ..data = image
      ..createdAt = DateTime.now();

    await store.put(cachedImage.toMap());
    logger.d('idb.update: $cachedImage');
    return cachedImage.id;
  }

  @override
  Future<bool> delete(String name) async {
    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadWrite);
    final store = txn.objectStore(IdbCacheImages.storeName);
    final id = getIdBy(name);
    await store.delete(id);
    await txn.completed;
    return true;
  }

  @override
  Future<MemoryImage?> get(int recordId, String name) async {
    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadOnly);
    final store =
        txn.objectStore(IdbCacheImages.storeName).index(IdbCacheImages.idxName);

    IdbCachedImage? cachedImage;
    try {
      final obj = await store.get(name);
      if (obj == null) {
        // logger.d(
        //     'IdbImageCacheManager#get: obj was not found in "${store.name}": $name');
      } else if (obj is! Map) {
        // logger.d(
        //     'IdbImageCacheManager#get: obj found but type is not Map in "${store.name}": $name');
      } else {
        cachedImage = IdbCachedImage.fromMap(obj);
        // logger
        //     .d('IdbImageCacheManager#get: obj found in "${store.name}": $name\ndata=$data');
      }
      // }
      await txn.completed;
    } catch (err, st) {
      logger.e('idb.get: error raised', err, st);
    }
    if (cachedImage == null) {
      return null;
    }
    return cachedImage.data;
  }

  @override
  Future<bool> clearCache() async {
    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadWrite);
    try {
      await txn.objectStore(IdbCacheImages.storeName).clear();
      return true;
    } catch (e, st) {
      logger.e('idb failed image cache clearing.', e, st);
    }
    return false;
  }

  Future<int> _filledBy(
      {required MemoryImage image, required int length}) async {
    final date = DateTime.now();
    final prefix = DateFormat("yMdHms").format(date);
    final rand = math.Random();
    int fillCount = 0;

    final txn = _db!.transaction(IdbCacheImages.storeName, idbModeReadWrite);
    final store = txn.objectStore(IdbCacheImages.storeName);
    const int maxFillIndex = 20;
    try {
      for (int i = 0; i < maxFillIndex; i++) {
        final id = i;
        fillCount++;
        final name = '${prefix}_FILL_$id';
        final duration = Duration(days: rand.nextInt(30) * -1);
        final cachedImage = IdbCachedImage.of(name, image, date.add(duration));
        // logger.d(
        //     'pre filled: $fillCount / $maxFillIndex, ${cachedImage.createdAt}');
        await store.add(cachedImage.toMap());
        // logger.d('filled: $fillCount / $maxFillIndex');
      }
      await txn.completed.then((database) {
        logger.i('idb: complete filling. $maxFillIndex');
        return database;
      });
    } catch (e, st) {
      logger.e(
          'idb fill error at $fillCount times (${((fillCount * 16) / 1000).toStringAsFixed(3)}). '
          'transaction aborting. ${e.runtimeType}: ',
          e,
          st);
      txn.abort();
    }
    return fillCount;
  }

  @override
  Future<Result<int, String>> filledBy(
      {required MemoryImage image, required int length}) async {
    final completer = Completer<Result<int, String>>();
    if (kDebugMode) {
      assert(() {
        _filledBy(image: image, length: length)
            .then((value) => completer.complete(Result.ok(value)))
            .catchError((e) => completer.complete(Result.err(e.toString())));
        return true;
      }());
    } else {
      completer
          .complete(Result.err('filledBy method function on only debug mode. '
              'when another mode, always return error.'));
    }
    return await completer.future;
  }
}
