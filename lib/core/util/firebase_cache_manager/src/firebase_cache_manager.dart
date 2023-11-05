// ignore_for_file: implementation_imports

import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/storage/cache_object.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system_web.dart';

import '../../logger.dart';
import 'firebase_http_file_service.dart';

/// Use [FirebaseCacheManager] if you want to download files from firebase storage
/// and store them in your local cache.
class FirebaseCacheManager extends CacheManager {
  factory FirebaseCacheManager() {
    return _instance;
  }

  FirebaseCacheManager._()
      : super(Config(key,
            repo: NonStoringObjectProviderWrapper(),
            fileSystem: MemoryCacheSystemWrapper(),
            fileService: FirebaseHttpFileService())) {
    logger.d('called CacheManager private constructor.');
  }

  static const key = 'firebaseCache';

  static final FirebaseCacheManager _instance = FirebaseCacheManager._();
}

class NonStoringObjectProviderWrapper extends NonStoringObjectProvider {
  @override
  Future<bool> close() async {
    logger.d('called CacheManager.Repo.close');
    return true;
  }

  @override
  Future<int> delete(int id) {
    logger.d('called CacheManager.Repo.delete(id: $id)');
    return Future.value(1);
  }

  @override
  Future<int> deleteAll(Iterable<int> ids) {
    logger.d('called CacheManager.Repo.deleteAll(ids: $ids)');
    return Future.value(ids.length);
  }

  @override
  Future<CacheObject?> get(String url) {
    logger.d('called CacheManager.Repo.get(url: $url)');
    return Future.value(null);
  }

  @override
  Future<List<CacheObject>> getAllObjects() {
    logger.d('called CacheManager.Repo.getAllObjects()');
    return Future.value([]);
  }

  @override
  Future<List<CacheObject>> getObjectsOverCapacity(int capacity) {
    logger.d(
        'called CacheManager.Repo.getObjectsOverCapacity(capacity: $capacity)');
    return Future.value([]);
  }

  @override
  Future<List<CacheObject>> getOldObjects(Duration maxAge) {
    logger.d('called CacheManager.Repo.getOldObjects(maxAge: $maxAge)');
    return Future.value([]);
  }

  @override
  Future<CacheObject> insert(
    CacheObject cacheObject, {
    bool setTouchedToNow = true,
  }) {
    logger.d(
        'called CacheManager.Repo.insert(cacheObject: $cacheObject, setTouchedToNow: $setTouchedToNow)');
    return Future.value(cacheObject);
  }

  @override
  Future<bool> open() async {
    logger.d('called CacheManager.Repo.open()');
    return true;
  }

  @override
  Future<int> update(
    CacheObject cacheObject, {
    bool setTouchedToNow = true,
  }) {
    logger.d(
        'called CacheManager.Repo.update(cacheObject: $cacheObject, setTouchedToNow: $setTouchedToNow)');
    return Future.value(0);
  }

  @override
  Future updateOrInsert(CacheObject cacheObject) {
    logger.d(
        'called CacheManager.Repo.updateOrInsert(cacheObject: $cacheObject)');
    return Future.value();
  }

  @override
  Future<void> deleteDataFile() async {
    logger.d('called CacheManager.Repo.deleteDataFile()');
    return;
  }

  @override
  Future<bool> exists() async {
    logger.d('called CacheManager.Repo.exists()');
    return false;
  }
}

class MemoryCacheSystemWrapper extends MemoryCacheSystem {
  @override
  Future<File> createFile(String name) async {
    logger.d('called CacheManager.FS.createFile(name: $name)');
    return (await directory).childFile(name);
  }
}
