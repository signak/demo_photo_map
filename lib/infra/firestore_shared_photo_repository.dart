import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_share_capp/core/extension/datetime_extension.dart';
import 'package:uuid/uuid.dart';

import '../core/util/image_util/image_util.dart';
import '../core/util/logger.dart';
import '../domain/marker_param.dart';
import '../domain/marker_params_container.dart';
import '../domain/shared_photo.dart';
import '../presentation/service/shared_photo_repository.dart';
import 'fs_constants.dart';
import 'image_cache/image_cache_manager.dart';

// final firestoreSharedPhotoRepositoryProvider =
//     Provider<FirestoreSharedPhotoRepository>(
//   (ref) => FirestoreSharedPhotoRepository(
//     ref.read(isarImageCacheManager),
//   ),
// );

class FirestoreSharedPhotoRepository extends SharedPhotoRepository {
  FirestoreSharedPhotoRepository(this._imageCacheManager);

  final _db = FirebaseFirestore.instance;
  final ImageCacheManager _imageCacheManager;

  DateTime toDateTime(dynamic value) {
    if (value == null || value is FieldValue) {
      return DateTime.now();
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  // Future<List<String>> toImageUrlList(int recordId, dynamic value) async {
  //   logger.d('toImageUrlList called: $recordId, $value');
  //   if (value == null) {
  //     return [];
  //   } else if (value is List) {
  //     final ret = <String>[];
  //     for (var item in value) {
  //       final path = '$recordId/$item';
  //       final url = await getDownloadUrl(path);
  //       ret.add(url);
  //     }
  //     return ret;
  //   }
  //   return [];
  // }

  List<String> toStringList(dynamic value) {
    if (value != null && value is List) {
      return value.map((v) => '$v').toList();
    } else {
      return <String>[];
    }
  }

  List<String> toImagePathList(int recordId, dynamic value) {
    if (value != null && value is List) {
      return value.map((v) => '$recordId/$v').toList();
    } else {
      return <String>[];
    }
  }

  MarkerParam<SharedPhoto> convertFromMap(Map<String, dynamic> data,
      {int? recordId}) {
    recordId ??= data[FsSharedPhotos.id];
    if (recordId == null) {
      throw ArgumentError.notNull(
          '${FsSharedPhotos.collectionName}.${FsSharedPhotos.id}');
    }

    final LatLng coordinate = data[FsSharedPhotos.coordinate] is LatLng
        ? data[FsSharedPhotos.coordinate]
        : LatLng((data[FsSharedPhotos.coordinate] as GeoPoint).latitude,
            (data[FsSharedPhotos.coordinate] as GeoPoint).longitude);

    final photo = SharedPhoto(
      recordId: recordId,
      name: data[FsSharedPhotos.name],
      memo: data.containsKey(FsSharedPhotos.memo)
          ? data[FsSharedPhotos.memo]
          : null,
      coordinate: coordinate,
      photos: toImagePathList(recordId, data[FsSharedPhotos.images]),
      createdAt: toDateTime(data[FsSharedPhotos.createdAt]),
      updatedAt: toDateTime(data[FsSharedPhotos.updatedAt]),
      updatedBy: data[FsSharedPhotos.updatedBy],
    );

    final ret = MarkerParam(data[FsSharedPhotos.name], coordinate.latitude,
        coordinate.longitude, 0, photo);
    return ret;
  }

  @override
  Future<MarkerParam<SharedPhoto>> create(
      String uid, double latitude, double longitude,
      {String? name, DateTime? createdAt}) async {
    // TODO [低] FirestoreにTransactionのRuleを設定する
    // https://zenn.dev/yucatio/articles/7c4ba0d0138ca9
    logger.d('called repository.create');
    final ret =
        await _db.runTransaction<MarkerParam<SharedPhoto>>((transaction) async {
      final summaryDocRef = _db
          .collection(FsSharedPhotoSummary.collectionName)
          .doc(FsSharedPhotoSummary.documentName);

      final summaryDoc = await transaction.get(summaryDocRef);

      if (!summaryDoc.exists) {
        await registerInitialData();
      }

      final int newRecordId =
          summaryDoc.data()![FsSharedPhotoSummary.lastRecordId] + 1;

      final dynamic timestamp =
          createdAt?.toTimestamp() ?? FieldValue.serverTimestamp();

      final data = <String, dynamic>{
        FsSharedPhotos.id: newRecordId,
        FsSharedPhotos.coordinate: GeoPoint(latitude, longitude),
        FsSharedPhotos.name: name ?? '場所 $newRecordId',
        FsSharedPhotos.createdAt: timestamp,
        FsSharedPhotos.updatedAt: timestamp,
        FsSharedPhotos.updatedBy: uid,
      };

      final dataDocRef =
          _db.collection(FsSharedPhotos.collectionName).doc('$newRecordId');

      transaction.update(summaryDocRef, {
        FsSharedPhotoSummary.lastRecordId: FieldValue.increment(1)
      }).set(dataDocRef, data);

      return convertFromMap(data, recordId: newRecordId);
    });
    return ret;
  }

  @override
  Future<void> delete(String uid, int recordId, SharedPhoto data) async {
    final docRef =
        _db.collection(FsSharedPhotos.collectionName).doc('$recordId');
    await docRef.delete().then((_) async {
      //   // delete images from storage.
      await _deletePhotoFolder(recordId);
      for (final path in data.photos) {
        final name = SharedPhotoRepository.getFileNameOnly(path);
        await _imageCacheManager.delete(name);
      }
    });
  }

  Future<void> _deletePhotoFolder(int recordId) async {
    final storage = FirebaseStorage.instance;
    final folderRef =
        storage.ref(FsSharedPhotoStorage.rootFolderName).child('$recordId');
    bool hasError = false;
    await folderRef.listAll().then((res) async {
      for (final itemRef in res.items) {
        await itemRef.delete().onError((e, st) {
          hasError = true;
          logger.e(
              'failed photo deletion in item deletion. file=${itemRef.fullPath}',
              e,
              st);
        });
      }
    }, onError: (e, st) {
      hasError = true;
      logger.e(
          'failed list files in photo folder deletion. path=${folderRef.fullPath}',
          e,
          st);
    });
    if (hasError) {
      final message =
          'failed folder deletion. please remove zombie images and folder: ${folderRef.fullPath}';
      unawaited(_sendMessageToSystemAdmin(message));
    }
  }

  Future<void> _sendMessageToSystemAdmin(String message) async {
    // TODO [低] 管理者宛てのメッセージを登録する機能を作る
  }

  @override
  Stream<MarkerParamsContainer<SharedPhoto>> subscribe() {
    // logger.d('repository.subscribe called');
    final collectionRef = _db.collection(FsSharedPhotos.collectionName);
    final stream = collectionRef.orderBy(FsSharedPhotos.id).snapshots();

    final ret = stream.transform<MarkerParamsContainer<SharedPhoto>>(
        StreamTransformer.fromBind((s) {
      return s.map<MarkerParamsContainer<SharedPhoto>>((snapshot) {
        // logger.d('repo.markerSnapshot.size=${snapshot.size}');
        if (snapshot.size != 0) {
          final now = DateTime.now();
          final params = snapshot.docs
              .map((doc) {
                if (!doc.exists) {
                  return null;
                }
                return convertFromMap(doc.data());
              })
              .whereType<MarkerParam<SharedPhoto>>()
              .toList();
          final ret = MarkerParamsContainer<SharedPhoto>(now, params);
          // logger.d(
          //     'container[${ret.createdAt}]: params.size=${ret.params.length}');
          return ret;
        } else {
          return MarkerParamsContainer<SharedPhoto>.empty();
        }
      });
    }));

    return ret;
  }

  @override
  Stream<MarkerParam<SharedPhoto>> watchRecord(int recordId) {
    final collectionRef = _db.collection(FsSharedPhotos.collectionName);
    final dataDocRef = collectionRef.doc('$recordId');

    return dataDocRef
        .snapshots()
        .transform<MarkerParam<SharedPhoto>>(StreamTransformer.fromHandlers(
      handleData: (snapshot, sink) {
        if (!snapshot.exists) {
          return;
        }
        final marker = convertFromMap(snapshot.data()!);
        sink.add(marker);
      },
    ));
  }

  Future<void> _update(String uid, int id, Map<String, dynamic> data) async {
    final docRef = _db.collection(FsSharedPhotos.collectionName).doc('$id');

    final updateData = data.map((key, value) {
      if (key == FsSharedPhotos.coordinate &&
          data[FsSharedPhotos.coordinate] is LatLng) {
        final coordinate = data[FsSharedPhotos.coordinate];
        return MapEntry<String, dynamic>(
            key, GeoPoint(coordinate.latitude, coordinate.longitude));
      }
      return MapEntry<String, dynamic>(key, value);
    });
    updateData[FsSharedPhotos.createdAt] = FieldValue.serverTimestamp();
    updateData[FsSharedPhotos.updatedAt] = FieldValue.serverTimestamp();
    updateData[FsSharedPhotos.updatedBy] = uid;

    await docRef.update(updateData);
  }

  @override
  Future<void> updateTextFields(
      String uid, int recordId, String pointName, String pointMemo) async {
    var data = <String, dynamic>{
      FsSharedPhotos.name: pointName,
      FsSharedPhotos.memo: pointMemo,
    };
    await _update(uid, recordId, data);
  }

  @override
  Future<void> updateLocation(
      String uid, int recordId, double latitude, double longitude) async {
    return await _update(uid, recordId, <String, dynamic>{
      FsSharedPhotos.coordinate: GeoPoint(latitude, longitude)
    });
  }

  Future<MarkerParam<SharedPhoto>> _addPhotoFileName(
      String uid, int recordId, String newFileName) async {
    return await _db
        .runTransaction<MarkerParam<SharedPhoto>>((transaction) async {
      final dataDocRef =
          _db.collection(FsSharedPhotos.collectionName).doc('$recordId');

      final currentData = await dataDocRef.get();

      final data = convertFromMap(currentData.data()!);
      final images = toStringList(currentData.data()![FsSharedPhotos.images]);
      images.add(newFileName);

      final updateValues = <String, dynamic>{
        FsSharedPhotos.images: images,
        FsSharedPhotos.updatedAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedBy: uid,
      };

      transaction.update(dataDocRef, updateValues);

      final newAttrs = data.attrs.copyWith(
          photos: images.map((fileName) => '$recordId/$fileName').toList(),
          updatedAt: DateTime.now(),
          updatedBy: uid);
      return MarkerParam<SharedPhoto>(
          newAttrs.name,
          newAttrs.coordinate.latitude,
          newAttrs.coordinate.longitude,
          0,
          newAttrs);
    });
  }

  Future<MarkerParam<SharedPhoto>> _deletePhotoFileName(
      String uid, int recordId, String fileName) async {
    return await _db
        .runTransaction<MarkerParam<SharedPhoto>>((transaction) async {
      final dataDocRef =
          _db.collection(FsSharedPhotos.collectionName).doc('$recordId');

      final currentData = await dataDocRef.get();

      final data = convertFromMap(currentData.data()!);
      final images = toStringList(currentData.data()![FsSharedPhotos.images]);
      images.remove(fileName);

      final updateValues = <String, dynamic>{
        FsSharedPhotos.images: images,
        FsSharedPhotos.updatedAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedBy: uid,
      };

      transaction.update(dataDocRef, updateValues);

      final newAttrs = data.attrs.copyWith(
          photos: images.map((fileName) => '$recordId/$fileName').toList(),
          updatedAt: DateTime.now(),
          updatedBy: uid);
      return MarkerParam<SharedPhoto>(
          newAttrs.name,
          newAttrs.coordinate.latitude,
          newAttrs.coordinate.longitude,
          0,
          newAttrs);
    });
  }

  Future<void> registerInitialData() async {
    logger.d('called registerInitialData');
    final records = <Map<String, dynamic>>[
      {
        FsSharedPhotos.id: 0,
        FsSharedPhotos.name: '共有写真 0',
        FsSharedPhotos.memo: null,
        FsSharedPhotos.coordinate:
            const GeoPoint(36.366678159377344, 140.47715386701245),
        FsSharedPhotos.images: <String>[],
        FsSharedPhotos.createdAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedBy: 'SYSTEM',
      },
      {
        FsSharedPhotos.id: 1,
        FsSharedPhotos.name: '共有写真 1',
        FsSharedPhotos.memo: null,
        FsSharedPhotos.coordinate:
            const GeoPoint(36.366078159377345, 140.47690386701245),
        FsSharedPhotos.images: <String>[],
        FsSharedPhotos.createdAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedBy: 'SYSTEM',
      },
      {
        FsSharedPhotos.id: 2,
        FsSharedPhotos.name: '共有写真 2',
        FsSharedPhotos.memo: null,
        FsSharedPhotos.coordinate:
            const GeoPoint(36.37089815937735, 140.47546386701245),
        FsSharedPhotos.images: <String>[],
        FsSharedPhotos.createdAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedAt: FieldValue.serverTimestamp(),
        FsSharedPhotos.updatedBy: 'SYSTEM',
      },
    ];

    final collectionRef = _db.collection(FsSharedPhotos.collectionName);
    final batch = _db.batch();
    for (final record in records) {
      var id = record[FsSharedPhotos.id];
      var docRef = collectionRef.doc('$id');
      batch.set(docRef, record);
    }

    final summaryRef = _db
        .collection(FsSharedPhotoSummary.collectionName)
        .doc(FsSharedPhotoSummary.documentName);
    batch.set(summaryRef, {
      FsSharedPhotoSummary.id: 1,
      FsSharedPhotoSummary.structuralVersion: 1,
      FsSharedPhotoSummary.lastRecordId: 2,
      FsSharedPhotoSummary.createdAt: FieldValue.serverTimestamp(),
      FsSharedPhotoSummary.updatedAt: FieldValue.serverTimestamp(),
      FsSharedPhotoSummary.updatedBy: 'SYSTEM',
    });

    await batch.commit();
  }

  /// get image download url on firebase storage.
  /// [path] argument is relative path from bucket.
  /// ex. '${recordId}/${uuid}.jpg'
  // Future<String> _getDownloadUrl(String path) async {
  //   final storage = FirebaseStorage.instance.ref();
  //   final imageRef =
  //       storage.child(FsSharedPhotoStorage.rootFolderName).child(path);

  //   // logger.d(
  //   //     'imgRef: bucket=${imageRef.bucket}, name=${imageRef.name}, fullPath=${imageRef.fullPath}');

  //   try {
  //     final url = await imageRef.getDownloadURL();
  //     // logger.d('getDLUrl: ${imageRef.fullPath} -> $url');
  //     return url;
  //   } catch (e) {
  //     logger.e('Failed getDLUrl: $path', e);
  //     return '';
  //   }
  // }

  @override
  Future<MemoryImage?> getImage(int recordId, String name) async {
    logger.d('called getImageBytes($recordId, $name)');
    final fileName = SharedPhotoRepository.getFileNameOnly(name);
    final cachedImage = await _imageCacheManager.get(recordId, fileName);
    if (cachedImage != null) {
      logger.d(
          '[FsSharedPhotoRepo] getImage by Cache. [${fileName.hashCode}] $fileName');
      return cachedImage;
    }

    final onlineBytes = await _download(recordId, fileName);
    if (onlineBytes == null) {
      logger.e(
          'no cache and no online resource: recordId=$recordId, name=$fileName');
      return null;
    }
    final imageFromOnlineStorage = MemoryImage(onlineBytes);
    final id = await _imageCacheManager.updateOrInsert(
        fileName, imageFromOnlineStorage);
    logger.d('getImage by Online Storage. image cached id=$id');
    return imageFromOnlineStorage;
  }

  static const int _megaBytes = 1024 * 1024;
  static const int _maxImageSize = 5 * _megaBytes;

  Future<Uint8List?> _download(int recordId, String name) async {
    final storage = FirebaseStorage.instance.ref();
    final imageRef = storage
        .child(FsSharedPhotoStorage.rootFolderName)
        .child('$recordId')
        .child(name);
    final data = await imageRef.getData(_maxImageSize);
    if (data == null) {
      final metadata = await imageRef.getMetadata();
      final message =
          'Download failed due to ${_maxImageSize / (1024 * 1024)}MB size limit exceeded. '
          'image{id:$recordId, name=$name} size is ${metadata.size} bytes,';
      logger.e(message);
      throw Exception(message);
    }
    return data;
  }

  ImageType _getContentType(XFile file) {
    if (file.mimeType != null && file.mimeType!.isNotEmpty) {
      final mimeType = file.mimeType!;
      if (mimeType.contains('jpg') || mimeType.contains('jpeg')) {
        return ImageType('image/jpeg', '.jpg');
      } else if (mimeType.contains('png')) {
        return ImageType('image/png', '.png');
      } else if (mimeType.contains('gif')) {
        return ImageType('image/gif', '.gif');
      } else if (mimeType.contains('tif')) {
        return ImageType('image/tiff', '.tif');
      }
    }
    logger.w('unknown image type: ${file.name}');
    return ImageType('image/jpeg', '.jpg');
  }

  // ignore: unused_element
  String _createNewFileName() {
    const uuid = Uuid();
    final originId = uuid.v4();
    return originId.split('-').join('');
  }

  Future<Reference?> _saveImageToCloudStorage(
      int recordId, ImageType imageType, Uint8List data) async {
    final metadata = SettableMetadata(contentType: imageType.contentType);
    final newFileName = '${_createNewFileName()}${imageType.extWithDot}';

    final storage = FirebaseStorage.instance;
    final itemRef = storage
        .ref(FsSharedPhotoStorage.rootFolderName)
        .child('$recordId')
        .child(newFileName);
    final task = itemRef.putData(data, metadata);

    final imageStoredCompleter = Completer<bool>();
    task.snapshotEvents.listen((event) {
      switch (event.state) {
        case TaskState.canceled:
          imageStoredCompleter.complete(false);
          break;
        case TaskState.error:
          imageStoredCompleter.complete(false);
          break;
        case TaskState.success:
          imageStoredCompleter.complete(true);
          break;
        default:
          break;
      }
    }, onError: (e) {
      logger.e('failed image file uploading to cloud storage.', e);
      throw e;
    });

    if (await imageStoredCompleter.future) {
      return itemRef;
    } else {
      return null;
    }
  }

  @override
  Future<MarkerParam<SharedPhoto>> putPhoto(
      String uid, int recordId, XFile imageFile) async {
    final data = await _resize(imageFile);
    final imageType = _getContentType(imageFile);

    final storedFileRef =
        await _saveImageToCloudStorage(recordId, imageType, data);

    if (storedFileRef != null) {
      final String storedFileName = storedFileRef.name;
      try {
        await _imageCacheManager.updateOrInsert(
            storedFileName, MemoryImage(data));
      } catch (e) {
        // ローカルキャッシュへの保存に失敗しても特になにもしない。
        logger.e(
            '[FsSharedPhotoRepo] failed caching a image file: '
            '$storedFileName (${data.length} bytes)',
            e);
      }

      return await _addPhotoFileName(uid, recordId, storedFileName)
          .onError((error, st) {
        try {
          unawaited(storedFileRef.delete());
        } catch (e, st) {
          logger.e('failed image file deleting on rollback putImage.', e, st);
        }

        if (error is Exception || error is Error) {
          throw error!;
        } else {
          throw Exception('failed image file adding to firestore: $error');
        }
      });
    } else {
      throw Exception(
          'failed image file uploading. but upload task is not raised any error.');
    }
  }

  static const int _quantity = 90;
  static const int _width4k = 3840;
  static const int _height4k = 2160;

  Future<Uint8List> _resize(XFile imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    if (imageBytes.length <= _maxImageSize) {
      return imageBytes;
    }

    final compressedBytes = await ImageUtil.compress(
        CompressorType.htmlCanvas, imageFile,
        maxWidth: _width4k, maxHeight: _height4k, quantity: _quantity);

    if (compressedBytes == null) {
      logger.d('image is not compressed: original.size=${imageBytes.length}');
      return imageBytes;
    } else {
      logger.d('image is compressed: original.size=${imageBytes.length}, '
          'compressed.size=${compressedBytes.length}.');
      return compressedBytes;
    }
  }

  // Future<void> _deletePhotoFile(int recordId, String fileName) async {
  //   final storage = FirebaseStorage.instance;
  //   final itemRef = storage
  //       .ref(FsSharedPhotoStorage.rootFolderName)
  //       .child('$recordId')
  //       .child(fileName);
  //   await itemRef.delete();
  // }

  @override
  Future<MarkerParam<SharedPhoto>> removePhoto(
      String uid, int recordId, String fileName) async {
    final storage = FirebaseStorage.instance;
    final itemRef = storage
        .ref(FsSharedPhotoStorage.rootFolderName)
        .child('$recordId')
        .child(fileName);
    final task = itemRef.delete();

    return await task.then((_) async {
      await _imageCacheManager.delete(fileName);
      return await _deletePhotoFileName(uid, recordId, fileName);
    }, onError: (e, st) {
      logger.e('error on delete photo file.', e, st);
    });
  }

  @override
  Future<bool> clearCache() async {
    return await _imageCacheManager.clearCache();
  }
}

class ImageType {
  ImageType(this.contentType, this.extWithDot);

  final String contentType;
  final String extWithDot;
}
