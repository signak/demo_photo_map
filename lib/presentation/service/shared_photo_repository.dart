import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/util/logger.dart';
import '../../domain/marker_param.dart';
import '../../domain/marker_params_container.dart';
import '../../domain/shared_photo.dart';

final sharedPhotoRepositoryProvider = Provider<SharedPhotoRepository>(
  (ref) => throw UnimplementedError(
      'should override sharedPhotoRepositoryProvider.'),
);

abstract class SharedPhotoRepository {
  Stream<MarkerParamsContainer<SharedPhoto>> subscribe();

  // Future<void> update(String uid, int id, Map<String, dynamic> data);

  Future<void> updateTextFields(
      String uid, int recordId, String pointName, String pointMemo);

  Future<void> updateLocation(
      String uid, int recordId, double latitude, double longitude);

  Future<MarkerParam<SharedPhoto>> create(
      String uid, double latitude, double longitude,
      {String? name, DateTime? createdAt});

  Future<void> delete(String uid, int recordId, SharedPhoto data);

  // Future<String> getDownloadUrl(String path);

  // Future<Uint8List?> download(String path);

  Future<MemoryImage?> getImage(int recordId, String name);

  Future<MarkerParam<SharedPhoto>> putPhoto(
      String uid, int recordId, XFile imageFile);

  Future<MarkerParam<SharedPhoto>> removePhoto(
      String uid, int recordId, String fileName);

  Future<bool> clearCache();

  static String getFileNameOnly(String pathOrNameOrUrl) {
    if (pathOrNameOrUrl.startsWith('http')) {
      final decodedUrl = Uri.decodeFull(pathOrNameOrUrl);
      final url =
          (decodedUrl.contains('?')) ? decodedUrl.split('?')[0] : decodedUrl;
      return url.substring(url.lastIndexOf('/') + 1);
    }

    if (pathOrNameOrUrl.contains('\\')) {
      // windows path
      return pathOrNameOrUrl.substring(pathOrNameOrUrl.lastIndexOf('\\') + 1);
    }

    // unix path.
    return pathOrNameOrUrl.substring(pathOrNameOrUrl.lastIndexOf('/') + 1);
  }

  static String getCacheName(String pathOrUrl) {
    return getFileNameOnly(pathOrUrl);
  }

  Stream<MarkerParam<SharedPhoto>> watchRecord(int recordId);
}

class MockSharedPhotoRepository extends SharedPhotoRepository {
  @override
  Future<MarkerParam<SharedPhoto>> create(
      String uid, double latitude, double longitude,
      {String? name, DateTime? createdAt}) async {
    logger.d('create: $uid, $latitude, $longitude');
    const int recordId = -1;
    final String itemName = name ?? 'unnamed';
    final now = DateTime.now();
    return MarkerParam<SharedPhoto>(
        itemName,
        latitude,
        longitude,
        0,
        SharedPhoto(
            recordId: recordId,
            name: itemName,
            coordinate: LatLng(latitude, longitude),
            createdAt: now,
            updatedAt: now,
            updatedBy: uid));
  }

  @override
  Stream<MarkerParamsContainer<SharedPhoto>> subscribe() {
    throw UnimplementedError();
  }

  @override
  Future<MarkerParam<SharedPhoto>> putPhoto(
      String uid, int recordId, XFile imageFile) {
    throw UnimplementedError();
  }

  @override
  Future<MarkerParam<SharedPhoto>> removePhoto(
      String uid, int recordId, String fileName) {
    throw UnimplementedError();
  }

  @override
  Future<MemoryImage?> getImage(int recordId, String name) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateLocation(
      String uid, int recordId, double latitude, double longitude) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String uid, int recordId, SharedPhoto data) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearCache() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTextFields(
      String uid, int recordId, String pointName, String pointMemo) {
    throw UnimplementedError();
  }

  @override
  Stream<MarkerParam<SharedPhoto>> watchRecord(int recordId) {
    throw UnimplementedError();
  }
}
