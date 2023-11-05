import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/util/logger.dart';
import '../../theme/dimension_info.dart';
import '../responsive_grid_view.dart';
import 'image_loader.dart';
import 'image_loader_manager.dart';

/// definition of build each image items for display on [AsyncImageLoadingResponsiveGridList]. <br>
/// <br>
/// Usage example: basic
/// ```dart
/// (...) {
///   return FutureBuilder(
///     future: loader.load(contentsService),
///     builder: (context, snapshot) {
///       if (snapshot.hasData) {
///         final Image image = snapshot.data!;
///         return buildImageContainer(image: image);
///       } else if (snapshot.hasError) {
///         return errorWidget;
///       }
///       return loadingWidget;
///     },
///   );
/// }
/// ```
/// <br>
/// Usage example: intermediate
/// ```dart
/// (...) {
///   final String name = loader.name;
///   if (manager.isLoadedOf(name)) {
///     final Image image = manager.imageOf(name)!;
///     return buildImageContainer(image: image);
///   } else {
///     return FutureBuilder(
///       future: loader.load(contentsService,
///           imageWidth: imageWidth, imageHeight: imageHeight),
///       builder: (context, snapshot) {
///         if (snapshot.hasData) {
///           final Image image = snapshot.data!;
///           return buildImageContainer(image);
///         } else if (snapshot.hasError) {
///           return ErrorWidget(
///             error: snapshot.error,
///             stackTrace: snapshot.stackTrace,
///           );
///         }
///         return loadingWidget;
///       },
///     );
///   }
/// }
/// ```
typedef ImageContainerBuilder = Widget Function(BuildContext context,
    WidgetRef ref, ImageLoaderManager manager, ImageLoader loader);

/// this widget is wrapper of [ResponsiveGridList] that added asynchronous image loading functions.
/// dependent on responsive_grid_list. <br>
/// see document of [AsyncImageLoadingResponsiveGridList.builder], for how to use this.
class AsyncImageLoadingResponsiveGridList extends HookConsumerWidget {
  const AsyncImageLoadingResponsiveGridList._({
    super.key,
    required InitialParams params,
    required ImageContainerBuilder imageContainerBuilder,
    Widget? noDataNotification,
  })  : _params = params,
        _imageContainerBuilder = imageContainerBuilder,
        _noDataNotification = noDataNotification;

  /// factory constructor of AsyncImageLoadingResponsiveGridList. unique way of instantiate this.<br>
  /// see also [ImageContainerBuilder] if build each image items. <br>
  /// <br>
  /// if [borderColor] is null (default), returned image by loader has no border. <br>
  /// default [minImageWidth] is 80. It is used as [AsyncImageLoadingResponsiveGridList.minImageWidth]. <br>
  /// In addition, when [ImageLoader.load] called without [imageWidth], [imageHeight],
  /// or both, used as a substitute for them. <br>
  /// if [autoStartOnLoaderCreated] is true (default), start loading in order on just before return loaders. <br>
  /// if start loading on another timing, set false to [autoStartOnLoaderCreated]. <br>
  /// in that case, should call start method after page building is complete.<br>
  /// <br>
  /// Usage example: on post widgets building.
  /// ```dart
  /// Widget build(BuildContext context, WidgetRef ref) {
  ///   ...
  ///   final grid = AsyncImageLoadingResponsiveGridList.builder(...);
  ///   WidgetsBinding.instance.addPostFrameCallback((_) {
  ///     grid.start(context, ref);
  ///   });
  ///   ...
  ///   return SomeWidget(child: grid);
  /// }
  /// ```
  /// <br>
  /// Usage example: on user interaction.
  /// ```dart
  ///   final grid = AsyncImageLoadingResponsiveGridList.builder(...);
  /// ...
  /// ElevatedButton(
  ///   onPressed: () => grid.start(context, ref),
  ///   child: const Text('Start Loading'),
  /// ),
  /// ```
  factory AsyncImageLoadingResponsiveGridList.builder({
    Key? key,
    required int recordId,
    required List<String> photoNames,
    required Set<String> targetLocations,
    required ImageContainerBuilder imageContainerBuilder,
    Color? borderColor,
    double minImageWidth = _defaultMinImageWidth,
    bool autoStartOnLoaderCreated = true,
    Widget? noDataNotification,
  }) {
    final params = InitialParams(
        recordId: recordId,
        targetLocations: targetLocations,
        names: photoNames,
        borderColor: borderColor,
        minImageWidth: minImageWidth,
        autoStartOnLoaderCreated: autoStartOnLoaderCreated);
    return AsyncImageLoadingResponsiveGridList._(
      key: key,
      noDataNotification: noDataNotification,
      params: params,
      imageContainerBuilder: imageContainerBuilder,
    );
  }

  final InitialParams _params;

  final ImageContainerBuilder _imageContainerBuilder;

  final Widget? _noDataNotification;

  static const double _defaultMinImageWidth = 80;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(imageLoaderManagerProvider(_params).notifier);

    if (!manager.isTargetLocation(context)) {
      return const SizedBox.shrink();
    }
    final size = MediaQuery.of(context).size;
    final dimensInfo = DimensionUtil.getInfo(context, ref);
    final minImageSize = dimensInfo.editDialogUI.minImageSize;

    final performWidth = size.width -
        ((dimensInfo.editDialogUI.horizontalPadding * 2 +
            dimensInfo.largeGap * 2));

    return ResponsiveGridView(
      minImageSize: minImageSize,
      itemSpacing: dimensInfo.editDialogUI.itemGap,
      performWidth: performWidth,
      noDataNotification: _noDataNotification,
      children: _buildItems(context, ref, manager),
    );
    // return ResponsiveGridList(
    //   horizontalGridMargin: 0,
    //   verticalGridMargin: 0,
    //   horizontalGridSpacing: 8,
    //   verticalGridSpacing: 8,
    //   maxItemsPerRow: 6,
    //   minItemsPerRow: 2,
    //   minItemWidth: manager.minImageWidth,
    //   children: _buildItems(context, ref, manager),
    // );
  }

  List<Widget> _buildItems(
      BuildContext context, WidgetRef ref, ImageLoaderManager manager) {
    final recordId = _params.recordId;
    final photoNames = _params.names;

    final children = <Widget>[];
    for (final loader in manager.createLoaders(
      context,
      recordId,
      photoNames,
      _params.autoStartOnLoaderCreated,
    )) {
      children.add(_imageContainerBuilder(context, ref, manager, loader));
    }
    return children;
  }

  /// request loaders to cancel image loading process that executing or waiting for start instruction.
  /// however, do nothing to completed loaders.
  void cancel(BuildContext context, WidgetRef ref) {
    final manager = ref.read(imageLoaderManagerProvider(_params).notifier);
    manager.cancel();
    logger.d('[AsyncILRGridList] cancel all image load preservation');
  }

  /// sequentially request loaders to start loading image.<br>
  /// however, loader don't reload images that already been loaded.
  /// in that case, loader send successful notification to listener immediately.
  void start(BuildContext context, WidgetRef ref) {
    final manager = ref.read(imageLoaderManagerProvider(_params).notifier);
    manager.start();
    logger.d('[AsyncILRGridList] start loading');
  }
}
