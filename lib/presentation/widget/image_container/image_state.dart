import 'package:flutter/material.dart';

/// 自身の取得状況を保有する画像情報
@immutable
class ImageState {
  const ImageState(this.recordId, this.name, this.isLoaded, this.image);
  factory ImageState.empty() => const ImageState(-1, '', false, null);
  factory ImageState.createNewState(int recordId, String name) =>
      ImageState(recordId, name, false, null);

  /// レコードID
  final int recordId;

  /// 画像ファイル名
  final String name;

  /// 画像が読み込み済みの場合はtrue
  /// 読み込み処理の実行完了状況ではなく、画像が取得完了している場合にtrueになる。
  /// trueの場合は必ず、image != null。逆も然り。
  final bool isLoaded;

  /// 画像
  final Image? image;

  /// 画像ファイルパス
  /// bucketからの相対パス
  String get path => '$recordId/$name';

  ImageState copyWith({bool isLoaded = false, Image? image}) {
    return ImageState(recordId, name, isLoaded, image);
  }

  @override
  String toString() {
    return ('ImageState { recordId: $recordId, name: $name, isLoaded: $isLoaded, '
        'image: ${(image == null) ? "null" : "${image.runtimeType}"}, }');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageState &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          recordId == other.recordId &&
          isLoaded == other.isLoaded);

  @override
  int get hashCode {
    return '$recordId/$name/$isLoaded'.hashCode;
  }
}
