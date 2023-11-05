import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/marker_param.dart';
import '../../domain/marker_params_container.dart';
import '../../domain/shared_photo.dart';
import '../widget/image_container/image_loader.dart';
import 'shared_photo_repository.dart';

final mapMarkerServiceProvider =
    Provider<MapMarkerService>((ref) => MapMarkerService(ref));

class MapMarkerService implements IContentsService {
  MapMarkerService(Ref ref)
      : _repository = ref.read(sharedPhotoRepositoryProvider);

  final SharedPhotoRepository _repository;

  Stream<MarkerParamsContainer<SharedPhoto>> get stream {
    return _repository.subscribe();
  }

  Stream<MarkerParam<SharedPhoto>> watchRecord(int recordId) {
    return _repository.watchRecord(recordId);
  }

  Future<void> updateTextFields(
      String uid, int recordId, String pointName, String pointMemo) async {
    await _repository.updateTextFields(uid, recordId, pointName, pointMemo);
  }

  Future<void> updateLocation(
      String uid, int recordId, double latitude, double longitude) async {
    await _repository.updateLocation(uid, recordId, latitude, longitude);
  }

  Future<MarkerParam<SharedPhoto>> create(
      String uid, double latitude, double longitude) async {
    return await _repository.create(uid, latitude, longitude);
  }

  Future<void> delete(String uid, int recordId, SharedPhoto data) async {
    return await _repository.delete(uid, recordId, data);
  }

  @override
  Future<MemoryImage?> getImage(int recordId, String name) async {
    return await _repository.getImage(recordId, name);
  }

  Future<MarkerParam<SharedPhoto>> putPhoto(
      String uid, int recordId, XFile img) async {
    return await _repository.putPhoto(uid, recordId, img);
  }

  Future<MarkerParam<SharedPhoto>> removePhoto(
      String uid, int recordId, String fileNameOrPath) async {
    final fileName = SharedPhotoRepository.getFileNameOnly(fileNameOrPath);
    return await _repository.removePhoto(uid, recordId, fileName);
  }

  Future<MarkerParam<SharedPhoto>> createWithPhoto(String uid, String name,
      double latitude, double longitude, DateTime createdAt, XFile img) async {
    return await _repository
        .create(uid, latitude, longitude, name: name, createdAt: createdAt)
        .then((data) async {
      return await _repository.putPhoto(uid, data.attrs.recordId, img);
    });
  }

  Future<bool> clearImageCache() async {
    return await _repository.clearCache();
  }

  /// return file name with extension.
  static String getCacheName(String pathOrUrl) {
    return SharedPhotoRepository.getCacheName(pathOrUrl);
  }
}
