import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/util/logger.dart';
import 'image_state.dart';

/// 画像読み込みの抽象クラス
abstract class ImageLoader {
  /// Loaderの処理が完了している場合はtrue。
  /// 画像が取得できたか否かについては関与しない。
  bool get isCompleted;

  /// レコードID
  int get recordId;

  /// 画像ファイル名
  String get name;

  /// 画像の取得処理が実行中または実行済みの場合はtrue。
  /// 画像が取得できたか否かについては関与しない。
  bool get isStarted;

  /// 画像の取得処理がキャンセルされた場合はtrue。
  bool get isCanceled;

  /// 画像の取得処理を非同期で実行する。<br>
  /// [imageWidth], [imageHeight] を指定しなかった場合は、
  /// 辺長 [ImageLoaderManager.minImageWidth] の [Image] として読み込まれる。
  Future<Image?> load(IContentsService service,
      {double? imageWidth, double? imageHeight});

  /// 画像の取得完了を待機する。
  /// 画像の取得処理がキャンセルされた場合はfalse。そうでない場合はtrue。
  /// ただし、trueの場合も処理がキャンセルされずに実行されただけで、
  /// 画像取得の成否には関与しない。
  Future<bool> completed();

  /// 画像の読み込み処理の実行を許可する。
  /// 読み込み自体はこれ以降に非同期に実行される。
  void start();

  /// 画像の読み込み処理を中断する。
  /// 実装としては実行待機中の処理をキャンセルするだけで、
  /// 既に取得処理が実行中のものについては中断されない。
  void cancel();
}

/// 画像の読み込み完了通知を受けるリスナー用インターフェース
abstract class IImageLoadingCompletionStateReceiver {
  void loaded(ImageState newState);
}

/// 画像を提供するサービスのインターフェース
abstract class IContentsService {
  Future<MemoryImage?> getImage(int recordId, String name);
}

/// 作成時点で既に読み込み済みの場合のLoaderStub
class AlreadyLoadedImageLoader implements ImageLoader {
  AlreadyLoadedImageLoader(ImageState loadedImageState)
      : state = loadedImageState;

  final ImageState state;

  @override
  void cancel() {
    // nop
  }

  @override
  Future<bool> completed() async {
    return true;
  }

  @override
  bool get isCanceled => false;

  @override
  bool get isCompleted => true;

  @override
  bool get isStarted => true;

  @override
  Future<Image?> load(IContentsService service,
      {double? imageWidth, double? imageHeight}) async {
    return state.image;
  }

  @override
  String get name => state.name;

  @override
  void start() {
    // nop
  }

  @override
  int get recordId => state.recordId;
}

/// 画像読み込みの実務クラス
class ImageLoaderImpl implements ImageLoader {
  ImageLoaderImpl(int recordId, String name, double defaultImageSize,
      IImageLoadingCompletionStateReceiver notifier)
      : _recordId = recordId,
        _name = name,
        _defaultImageSize = defaultImageSize,
        _notifier = notifier;

  final int _recordId;
  final String _name;
  final double _defaultImageSize;
  final IImageLoadingCompletionStateReceiver _notifier;

  final _mayProcessExecuting = Completer<bool>();
  final _result = Completer<bool>();

  @override
  int get recordId => _recordId;

  @override
  String get name => _name;

  @override
  bool get isStarted => _mayProcessExecuting.isCompleted;

  @override
  bool get isCompleted => _result.isCompleted;

  bool _isCanceled = false;

  @override
  bool get isCanceled => _isCanceled;

  @override
  void start() {
    if (_mayProcessExecuting.isCompleted) {
      logger.d('[ImageLoaderImpl] load process is already started. $name');
      return;
    }
    logger.d('[ImageLoaderImpl] start loading. $name');
    _mayProcessExecuting.complete(true);
  }

  @override
  void cancel() {
    _isCanceled = true;
    if (!_result.isCompleted) {
      _result.complete(false);
    }
    if (!_mayProcessExecuting.isCompleted) {
      _mayProcessExecuting.complete(false);
    }
  }

  void dispose() {
    cancel();
  }

  Future<ImageState> _load(
      IContentsService service, double imageWidth, double imageHeight) async {
    final data = await service.getImage(recordId, name);
    if (data == null) {
      logger.d(
          '[ImageLoaderImpl] failed loading new image. contents service returned null. $name');
      return ImageState.createNewState(recordId, name);
    }

    final image = Image(
      image: data,
      key: Key(name),
      width: imageWidth,
      height: imageHeight,
      fit: BoxFit.cover,
    );
    logger.d('[ImageLoaderImpl] new image is loaded. $name');
    return ImageState(recordId, name, true, image);
  }

  @override
  Future<Image?> load(IContentsService service,
      {double? imageWidth, double? imageHeight}) async {
    if (isCompleted) {
      logger.d(
          "[ImageLoaderImpl] failed loading because this loader is already completed. "
          "loader can't re-use. $name");
      return null;
    }

    logger.d(
        '[ImageLoaderImpl] loader is not completed. wait for loading process started. $name');
    if (!(await _mayProcessExecuting.future)) {
      logger.d('[ImageLoaderImpl] loading process is canceled. $name');
      return null;
    }

    final newState = await _load(
      service,
      imageWidth ?? _defaultImageSize,
      imageHeight ?? _defaultImageSize,
    );
    if (_isCanceled) {
      return null;
    } else {
      _result.complete(true);
      _notifier.loaded(newState);
      return newState.image;
    }
  }

  @override
  Future<bool> completed() async {
    return await _result.future;
  }
}
