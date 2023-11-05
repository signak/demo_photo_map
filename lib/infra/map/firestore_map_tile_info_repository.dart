import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/util/logger.dart';
import '../../domain/map/map_tile_db_exception.dart';
import '../../domain/map/map_tile_info.dart';
import '../../domain/map/map_tile_info_repository.dart';
import '../fs_constants.dart';

class FirestoreMapTileInfoRepository extends MapTileInfoRepository {
  FirestoreMapTileInfoRepository();

  final _db = FirebaseFirestore.instance;

  static MapTileInfo getInfoForFailSafe() {
    return MapTileInfo(
      id: 0,
      tileIndex: 0,
      name: 'OpenStreetMap(JP)',
      tileUri: 'https://tile.openstreetmap.jp/{z}/{x}/{y}.png',
      creditText: 'OpenStreetMap contributors',
      licensePageUrl: 'https://www.openstreetmap.org/copyright',
      enabled: true,
      defaultTile: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      updatedBy: 'FAIL_SAFE',
    );
  }

  List<Map<String, dynamic>> get _initialRecords {
    final List<Map<String, dynamic>> records = [
      {
        FsMapTiles.id: 0,
        FsMapTiles.tileIndex: 0,
        FsMapTiles.name: 'OpenStreetMap(JP)',
        FsMapTiles.tileUri: 'https://tile.openstreetmap.jp/{z}/{x}/{y}.png',
        FsMapTiles.creditText: 'OpenStreetMap contributors',
        FsMapTiles.licensePageUrl: 'https://www.openstreetmap.org/copyright',
        FsMapTiles.enabled: true,
        FsMapTiles.defaultTile: true,
        FsMapTiles.createdAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedBy: 'SYSTEM',
      },
      {
        FsMapTiles.id: 1,
        FsMapTiles.tileIndex: 1,
        FsMapTiles.name: 'OpenStreetMap',
        FsMapTiles.tileUri:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        FsMapTiles.creditText: 'OpenStreetMap contributors',
        FsMapTiles.licensePageUrl: 'https://www.openstreetmap.org/copyright',
        FsMapTiles.enabled: true,
        FsMapTiles.defaultTile: false,
        FsMapTiles.createdAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedBy: 'SYSTEM',
      },
      {
        FsMapTiles.id: 2,
        FsMapTiles.tileIndex: 2,
        FsMapTiles.name: '国土地理院（標準）',
        FsMapTiles.tileUri:
            'https://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png',
        FsMapTiles.creditText: '国土地理院',
        FsMapTiles.licensePageUrl:
            'http://maps.gsi.go.jp/development/ichiran.html',
        FsMapTiles.enabled: true,
        FsMapTiles.defaultTile: false,
        FsMapTiles.createdAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedBy: 'SYSTEM',
      },
      {
        FsMapTiles.id: 3,
        FsMapTiles.tileIndex: 3,
        FsMapTiles.name: '国土地理院（淡色）',
        FsMapTiles.tileUri:
            'https://cyberjapandata.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png',
        FsMapTiles.creditText: '国土地理院',
        FsMapTiles.licensePageUrl:
            'http://maps.gsi.go.jp/development/ichiran.html',
        FsMapTiles.enabled: true,
        FsMapTiles.defaultTile: false,
        FsMapTiles.createdAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedAt: FieldValue.serverTimestamp(),
        FsMapTiles.updatedBy: 'SYSTEM',
      },
    ];
    return records;
  }

  CollectionReference _getCollection() {
    return _db.collection(FsMapTiles.collectionName);
  }

  Future<void> _initialize() async {
    final colRef = _getCollection();
    final alreadyInitialized = await colRef.get().then((snapshot) {
      return snapshot.size > 0;
    });

    if (alreadyInitialized) {
      logger.d('[FsMapTileInfoRepo] already initialized.');
      return;
    }

    logger.d('[FsMapTileInfoRepo] initializing...');
    final records = _initialRecords;

    final collectionRef = _getCollection();
    final batch = _db.batch();
    for (final record in records) {
      final id = record[FsMapTiles.id];
      final docRef = collectionRef.doc('$id');
      batch.set(docRef, record);
    }

    await batch.commit();
    logger.d('[FsMapTileInfoRepo] initialized');
  }

  @override
  Stream<List<MapTileInfo>> watchTiles({
    bool includeDisabledInfos = false,
  }) {
    _initialize();

    var query =
        _getCollection().orderBy(FsMapTiles.tileIndex, descending: false);

    if (!includeDisabledInfos) {
      query = query.where(
        FsMapTiles.enabled,
        isEqualTo: true,
      );
    }

    final queryWithConverter = query.withConverter<MapTileInfo>(
      fromFirestore: (snapshot, _) => MapTileInfo.fromJson(snapshot.data()!),
      toFirestore: (value, options) => value.toJson(),
    );

    return queryWithConverter.snapshots().transform<List<MapTileInfo>>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              logger.d('[FsMapTileInfoRepo] handleData size=${data.size}');
              final ret = <MapTileInfo>[];
              for (final snapshot in data.docs) {
                ret.add(snapshot.data());
              }
              logger
                  .d('[FsMapTileInfoRepo] handled. sinkDataSize=${ret.length}');
              sink.add(ret);
            },
            handleError: (error, stackTrace, sink) {
              const String message = 'MapTile情報の取得時に予期しないエラーが発生しました。';
              _handleError(message, error, stackTrace, sink);
            },
          ),
        );
  }

  void _handleError(
      String message, Object error, StackTrace stackTrace, EventSink sink) {
    late final Exception? causeException;
    late final String? code;
    late final String? plugin;
    if (error is FirebaseException) {
      code = error.code;
      plugin = error.plugin;
      causeException = error;
    } else {
      code = null;
      plugin = null;
      causeException = (error is Exception)
          ? error
          : Exception("the error object didn't implement of Exception class: "
              "${error.runtimeType} - $error");
    }

    final ex = MapTileDbException.build(
      message: message,
      code: code,
      plugin: plugin,
      causeException: causeException,
      causeStackTrace: stackTrace,
    );

    logger.e('[FsMapTileInfoRepo] handleError', ex, ex.mergedStackTrace);
    sink.addError(ex);
  }
}
