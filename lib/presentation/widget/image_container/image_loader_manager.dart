import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiver/collection.dart';

import '../../../core/util/logger.dart';
import 'image_loader.dart';
import 'image_state.dart';
import 'image_state_container.dart';

/// 画像の非同期読み込み機能を提供する。
final imageLoaderManagerProvider = StateNotifierProvider.family
    .autoDispose<ImageLoaderManager, ImageStateContainer, InitialParams>(
  (ref, initialParams) {
    ref.onDispose(() {
      ref.notifier.cancel();
      logger.d(
          '[ImageLoaderManagerProvider] on dispose imageLoaderManagerProvider.');
    });
    return ImageLoaderManager.initialize(
      initialParams,
      ImageStateContainerImpl.create(
          initialParams.recordId, initialParams.names),
    );
  },
);

/// [ImageLoaderManager]および[ImageStateContainer]を初期化するためのパラメータ。
@immutable
class InitialParams {
  const InitialParams({
    required this.recordId,
    required this.names,
    required this.targetLocations,
    this.borderColor,
    required this.minImageWidth,
    required this.autoStartOnLoaderCreated,
  });

  final int recordId;

  final List<String> names;
  final Set<String> targetLocations;

  final Color? borderColor;
  final double minImageWidth;

  final bool autoStartOnLoaderCreated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! InitialParams || runtimeType != other.runtimeType) {
      return false;
    }
    return recordId == other.recordId &&
        borderColor == other.borderColor &&
        minImageWidth == other.minImageWidth &&
        autoStartOnLoaderCreated == other.autoStartOnLoaderCreated &&
        setsEqual(names.toSet(), other.names.toSet()) &&
        setsEqual(targetLocations, other.targetLocations);
  }

  @override
  int get hashCode {
    final keys = [...names];
    keys.sort((a, b) => a.compareTo(b));
    return '$recordId/${keys.join("")}'.hashCode;
  }
}

/// 画像情報コンテナの保持・操作、および画像読み込みの制御を行うクラス
class ImageLoaderManager extends StateNotifier<ImageStateContainer>
    implements IImageLoadingCompletionStateReceiver {
  ImageLoaderManager._(InitialParams params, super.state) : _params = params;

  factory ImageLoaderManager.initialize(
      InitialParams params, ImageStateContainer state) {
    final manager = ImageLoaderManager._(params, state);
    // manager._loaders.clear();
    manager.cancel();
    logger.d('[ImageLoaderManager] cancel loaders on initialize manager.');
    return manager;
  }

  final InitialParams _params;
  final List<ImageLoader> _loaders = [];

  Set<String> get targetLocations => _params.targetLocations;

  bool get isLoaded => state.isLoaded;

  Color? get borderColor => _params.borderColor;

  double get minImageWidth => _params.minImageWidth;

  Future<void> start() async {
    for (final loader in _loaders) {
      loader.start();
      final bool meyLoadNextImage = await loader.completed();
      if (!meyLoadNextImage) {
        return;
      }
    }
  }

  void cancel() {
    for (final loader in _loaders.reversed) {
      loader.cancel();
    }
    _loaders.clear();
  }

  @override
  void dispose() {
    cancel();
    state.dispose();
    super.dispose();
  }

  bool isTargetLocation(BuildContext context) {
    final currentLocation = GoRouter.of(context).location;
    return targetLocations.contains(currentLocation);
  }

  bool isLoadedOf(String name) {
    return (state.of(name)?.isLoaded ?? false);
  }

  int indexOf(String name) {
    return state.indexOf(name);
  }

  Image? imageOf(String name) {
    return state.of(name)?.image;
  }

  /// if [startOnCreated] is true, call start method before return loaders.<br>
  /// if that is false, should call start method after createLoaders calling.<br>
  /// ex.
  /// ```dart
  /// Widget build(BuildContext context, WidgetRef ref) {
  ///   ...
  ///   final ImageLoaderManager manager = ...
  ///   WidgetsBinding.instance.addPostFrameCallback((_) {
  ///     manager.start(context, ref);
  ///   });
  ///   ...
  ///   return ...
  /// }
  /// ```
  List<ImageLoader> createLoaders(
    BuildContext context,
    int recordId,
    List<String> resourceIds,
    bool startOnCreated,
  ) {
    if (!isTargetLocation(context)) {
      logger
          .d('[ImageLoaderManager] not target location. return empty loaders.');
      return [];
    }

    if (_loaders.isNotEmpty) {
      cancel();
    }

    for (final id in resourceIds) {
      if (isLoadedOf(id)) {
        _loaders.add(AlreadyLoadedImageLoader(state.of(id)!));
      } else {
        _loaders.add(ImageLoaderImpl(recordId, id, minImageWidth, this));
      }
    }
    logger.d(
        '[ImageLoaderManager] loaders are created. startOnCreated=$startOnCreated');
    // debugPrint();

    if (startOnCreated) {
      start();
    }
    return [..._loaders];
  }

  /// [ImageLoader] が画像を読み込み終わった時に取得完了の通知受信として呼び出され、
  /// [state] で保持している [ImageState] の更新を行う。
  @override
  void loaded(ImageState newState) {
    final name = newState.name;
    if (!state.containsKey(name)) {
      logger.d(
          '[ImageLoaderManager] unknown state notifying. reject state updating. name=${newState.name}');
      return;
    }
    (state as ImageStateContainerImpl).updateState(name, newState);
  }

  // void debugPrint() {
  //   if (!kDebugMode) {
  //     return;
  //   }

  //   final buf = <String>[];
  //   final d = buf.add;
  //   d('[ImageLoaderManager] loaders: [');
  //   for (final loader in _loaders) {
  //     d('\t${loader.runtimeType}: { ${loader.name}, isStarted=${loader.isStarted}, isCompleted=${loader.isCompleted}, isCanceled=${loader.isCanceled} }');
  //   }
  //   d('],');
  //   d('States: [');
  //   for (final s in state.states) {
  //     d('\t${s.toString()}');
  //   }
  //   d(']');
  //   logger.d(buf.join('\n'));
  // }
}
