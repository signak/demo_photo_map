import 'dart:async';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/util/logger.dart';
import '../../core/util/device_util.dart';
import '../../domain/marker_param.dart';
import '../../domain/shared_photo.dart';
import '../../route/routes.dart';
import '../service/auth/auth_state_service.dart';
import '../service/map_marker_service.dart';
import '../theme/dimension_info.dart';
import '../widget/image_container/async_image_loading_responsive_grid_list.dart';
import '../widget/image_container/image_loader.dart';
import '../widget/image_container/image_loader_manager.dart';
import '../widget/loading_progress_indicator.dart';
import '../widget/map/map_control_state_provider.dart';
import '../widget/map/selected_marker_notifier_provider.dart';
import '../widget/util/dialog_util.dart';

final _nameTextControllerProvider =
    Provider.autoDispose.family<TextEditingController, String>(
  (ref, initialValue) => useTextEditingController(text: initialValue),
);

final _memoTextControllerProvider =
    Provider.autoDispose.family<TextEditingController, String>(
  (ref, initialValue) => useTextEditingController(text: initialValue),
);

class _ErrorImageWidget extends StatelessWidget {
  const _ErrorImageWidget(this.imageWidth, this.imageHeight);
  final double imageWidth;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final Widget errImage = Image.asset('image/no_image.jpg');
    return Center(
      child: errImage,
    );
  }
}

class _ImageLoadingWidget extends StatelessWidget {
  const _ImageLoadingWidget(this.imageWidth, this.imageHeight);
  final double imageWidth;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = LoadingAnimationWidget.hexagonDots(
        color: Colors.grey, size: imageWidth * 0.7);
    return Center(
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: loadingWidget,
      ),
    );
  }
}

class _TextFieldsController {
  const _TextFieldsController._(
    this.uid,
    this.recordId,
    this.mapMarkerService,
    String originalTitle,
    String originalMemo,
    this.nameTextController,
    this.memoTextController,
  )   : _originalTitle = originalTitle,
        _originalMemo = originalMemo;

  factory _TextFieldsController.create(
    String uid,
    int recordId,
    MapMarkerService mapMarkerService,
    String originalTitle,
    String originalMemo,
    TextEditingController nameTextController,
    TextEditingController memoTextController,
  ) {
    return _TextFieldsController._(uid, recordId, mapMarkerService,
        originalTitle, originalMemo, nameTextController, memoTextController);
  }

  final String uid;
  final int recordId;

  final MapMarkerService mapMarkerService;

  final String _originalTitle;
  final String _originalMemo;

  final TextEditingController nameTextController;
  final TextEditingController memoTextController;

  bool get isDirty =>
      originalTitle != currentTitle || originalMemo != currentMemo;

  String get originalTitle => _originalTitle;
  String get originalMemo => _originalMemo;
  String get currentTitle => nameTextController.text.trim();
  String get currentMemo => memoTextController.text.trim();

  /// return true if succeed.
  Future<bool> updateFields(BuildContext context) async {
    final name = currentTitle;
    final memo = currentMemo;

    return await mapMarkerService
        .updateTextFields(uid, recordId, name, memo)
        .then<bool>((_) async {
      await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.info),
                  Gap(8),
                  Text('データ保存'),
                ],
              ),
              content: const Text('保存が完了しました。'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('OK'),
                ),
              ]);
        },
      );
      return true;
    }).catchError(
      (error, stackTrace) async {
        logger.e('error on item updating', error, stackTrace);
        await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.error),
                    Gap(8),
                    Text('データ保存'),
                  ],
                ),
                content: const Text('データの保存に失敗しました。'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('OK'),
                  ),
                ]);
          },
        );
        return false;
      },
    );
  }
}

class ItemEditDialog extends HookConsumerWidget {
  ItemEditDialog(String id, {super.key}) : _id = int.parse(id);

  final int _id;

  Widget _buildPhotoItem(BuildContext context, WidgetRef ref,
      ImageLoaderManager manager, ImageLoader loader) {
    final service = ref.read(mapMarkerServiceProvider);
    final notifier = ref.read(selectedMarkerStateProvider.notifier);
    final uid = ref.read(authStateNotifierProvider)!.uid!;

    final name = loader.name;
    final recordId = loader.recordId;
    final imageIndex = manager.indexOf(name);
    final borderColor = manager.borderColor;

    final dimens = DimensionUtil.getInfo(context, ref);
    final imageSize = dimens.editDialogUI.minImageSize;

    final loadingWidget = _ImageLoadingWidget(imageSize, imageSize);
    final errorWidget = _ErrorImageWidget(imageSize, imageSize);

    Future<void> deleteImage() async {
      logger.d('call removePhoto: recordId: $recordId, fileName: $name');
      await service.removePhoto(uid, recordId, name).then((updatedMarkerParam) {
        notifier.select(updatedMarkerParam);
      });
    }

    Future<void> confirmDeleteImage() async {
      final buttonSize = Size(
        dimens.editDialogUI.dialogButtonWidth,
        dimens.editDialogUI.dialogButtonHeight,
      );

      await showDialog(
        context: context,
        builder: (dialogContext) {
          final dialogContextWidth = MediaQuery.of(dialogContext).size.width;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.question_mark_rounded),
                Gap(dimens.normalGap),
                const Text('写真削除'),
              ],
            ),
            content: const Text('写真を削除しますか？'),
            actions: DialogUtil.layoutActionButtons(
              containerWidth: dialogContextWidth * 0.8,
              buttonWidth: buttonSize.width,
              buttonSpacing: dimens.normalGap,
              buttons: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => deleteImage()
                      .whenComplete(() => Navigator.pop(dialogContext)),
                  child: const Text('削除'),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> onTapImage(MemoryImage image) async {
      manager.cancel();
      if (context.mounted) {
        GoRouter.of(context).pushNamed(
          ReleaseRoutes.photoView.name,
          params: {'id': '$recordId', 'imageIndex': '$imageIndex'},
          extra: {'fileName': name, 'memoryImage': image},
        );
      }
    }

    Widget buildImageBox(Image imageWidget) {
      return Container(
        decoration: (borderColor == null)
            ? null
            : BoxDecoration(border: Border.all(color: borderColor)),
        child: GestureDetector(
          onLongPress: () async => await confirmDeleteImage(),
          onTap: () => onTapImage(imageWidget.image as MemoryImage),
          child: imageWidget,
        ),
      );
    }

    if (manager.isLoadedOf(name)) {
      final image = manager.imageOf(name)!;
      return buildImageBox(image);
    } else {
      return FutureBuilder(
        future:
            loader.load(service, imageWidth: imageSize, imageHeight: imageSize),
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final image = snapshot.data!;
            return buildImageBox(image);
          } else if (snapshot.hasError) {
            return errorWidget;
          }
          return loadingWidget;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapMarkerService = ref.read(mapMarkerServiceProvider);
    final selectedMarker = ref.read(selectedMarkerStateProvider);

    final dimensInfo = DimensionUtil.getInfo(context, ref);

    final originalTitle = selectedMarker?.attrs.name ?? '';
    final originalMemo = selectedMarker?.attrs.memo ?? '';

    final nameTextController =
        ref.read(_nameTextControllerProvider(originalTitle));
    final memoTextController =
        ref.read(_memoTextControllerProvider(originalMemo));

    final authState = ref.watch(authStateNotifierProvider)!;

    return StreamBuilder(
      stream: mapMarkerService.watchRecord(_id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          final stackTrace = snapshot.stackTrace;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('$error'),
                const Gap(12),
                Text('$stackTrace'),
              ],
            ),
          );
        }
        if (snapshot.hasData) {
          final data = snapshot.data!;
          final uid = authState.uid!;
          final textFieldsController = _TextFieldsController.create(
            uid,
            _id,
            mapMarkerService,
            originalTitle,
            originalMemo,
            nameTextController,
            memoTextController,
          );
          return _buildContents(
            context,
            ref,
            uid,
            dimensInfo,
            data,
            textFieldsController,
          );
        }
        return const LoadingProgressIndicator();
      },
    );
  }

  Widget _buildContents(
    BuildContext context,
    WidgetRef ref,
    String uid,
    DimensionInfo dimens,
    MarkerParam<SharedPhoto> data,
    _TextFieldsController textFieldsController,
  ) {
    final theme = Theme.of(context);
    final deviceInfo = ref.read(deviceInfoProvider);
    final mapMarkerService = ref.read(mapMarkerServiceProvider);
    final mapControlStateNotifier = ref.watch(mapControlStateProvider.notifier);
    final selectedMarkerNotifier =
        ref.watch(selectedMarkerStateProvider.notifier);

    final photoNames = (data.attrs.photos)
        .map((path) => SharedPhoto.pathToFileName(path))
        .toList();

    final imageBorderColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    final noPhotoNotificationText = Text(
      'no photo data',
      style: TextStyle(
        decoration: TextDecoration.none,
        color: theme.colorScheme.onSurface.withAlpha(100),
        fontSize: dimens.normalFontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    final imageGridWidget = AsyncImageLoadingResponsiveGridList.builder(
      recordId: _id,
      photoNames: photoNames,
      targetLocations: {
        GoRouter.of(context).namedLocation(ReleaseRoutes.edit.name,
            params: {ReleaseRoutes.edit.paramName: '$_id'})
      },
      borderColor: imageBorderColor,
      minImageWidth: dimens.editDialogUI.minImageSize,
      noDataNotification: noPhotoNotificationText,
      imageContainerBuilder: (context, ref, manager, loader) =>
          _buildPhotoItem(context, ref, manager, loader),
    );

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      await picker.pickImage(source: source).then((img) async {
        if (img != null) {
          ProgressDialog pd = ProgressDialog(context: context);
          final completer = Completer<bool>();
          pd.show(msg: '写真を保存しています...', hideValue: true, max: 1);

          unawaited(mapMarkerService.putPhoto(uid, _id, img).then(
              (updatedMarkerParam) {
            completer.complete(true);
            selectedMarkerNotifier.select(updatedMarkerParam);
          }, onError: (e) async {
            completer.complete(false);
          }));

          final ret = await completer.future;
          if (ret) {
            pd.update(value: 1);
            pd.close(delay: 1000);
          } else {
            pd.close();

            if (context.mounted) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Row(
                      children: const [
                        Icon(Icons.info),
                        Gap(8),
                        Text('写真追加'),
                      ],
                    ),
                    content: const Text('エラーが発生したため、写真の追加に失敗しました。'),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      });
    }

    /// return false if nothing changed or discard changes.
    /// return true if should update text fields.
    /// return null if cancel updating and pop preview page.
    Future<bool?> confirmTextUpdating() async {
      if (!textFieldsController.isDirty) {
        return false;
      }

      final buttonSize = Size(
        dimens.editDialogUI.dialogButtonWidth,
        dimens.editDialogUI.dialogButtonHeight,
      );

      return await showDialog<bool?>(
        context: context,
        builder: (dialogContext) {
          final dialogContextWidth = MediaQuery.of(dialogContext).size.width;

          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.question_mark_rounded),
                Gap(8),
                Text('データ更新'),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('名称または備考が変更されています。'),
                Gap(8),
                Text('変更内容を保存しますか？'),
              ],
            ),
            actions: DialogUtil.layoutActionButtons(
              containerWidth: dialogContextWidth * 0.8,
              buttonWidth: buttonSize.width,
              buttonSpacing: dimens.normalGap,
              buttons: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('編集画面に戻る'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(' 破 棄 '),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(' 保 存 '),
                ),
              ],
            ),
          );
        },
      );
    }

    final fieldTextStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: dimens.normalFontSize,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.none,
    );

    final appBarForegroundColor =
        Theme.of(context).colorScheme.onSecondaryContainer;
    final appBarBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;

    return WillPopScope(
      onWillPop: () async {
        imageGridWidget.cancel(context, ref);

        final shouldUpdateText = await confirmTextUpdating();
        if (shouldUpdateText == null) {
          return false;
        } else if (shouldUpdateText) {
          if (context.mounted) {
            final ret = await textFieldsController.updateFields(context);
            if (!ret) {
              return false;
            }
          } else {
            logger.e('failed update text fields because context is unmounted.');
            return false;
          }
        }

        selectedMarkerNotifier.unselect();
        mapControlStateNotifier.completeItemEditing();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false, // キーボード表示切替でリビルドされるのでfalse指定
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('情報編集'),
                titleTextStyle:
                    Theme.of(context).appBarTheme.titleTextStyle!.copyWith(
                          color: appBarForegroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: dimens.appBarFontSize,
                        ),
                elevation: 0,
                // automaticallyImplyLeading: false,
                foregroundColor: appBarForegroundColor,
                backgroundColor: appBarBackgroundColor,
                iconTheme: IconThemeData(color: appBarForegroundColor),
                actions: [
                  Gap(dimens.normalGap),
                  _DropdownMenu(
                    context: context,
                    dimens: dimens,
                    deviceInfo: deviceInfo,
                    recordId: _id,
                    uid: uid,
                    mapMarkerService: mapMarkerService,
                    mapControlStateNotifier: mapControlStateNotifier,
                    selectedMarker: data,
                    selectedMarkerStateNotifier: selectedMarkerNotifier,
                    textFieldsController: textFieldsController,
                  ).build(),
                  Gap(dimens.normalGap),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: dimens.normalGap,
                    horizontal: dimens.editDialogUI.horizontalPadding +
                        dimens.smallGap * 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondaryContainer,
                        theme.colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextField(
                        keyboardType: TextInputType.text,
                        maxLength: 20,
                        controller: textFieldsController.nameTextController,
                        decoration: const InputDecoration(
                          label: Text('名称'),
                          hintText: '撮影対象の名称を入力してください。',
                        ),
                        style: fieldTextStyle,
                      ),
                      Gap(dimens.normalGap),
                      TextField(
                        keyboardType: TextInputType.text,
                        maxLength: 200,
                        controller: textFieldsController.memoTextController,
                        decoration: const InputDecoration(
                          label: Text('備考'),
                          hintText: '補足する事項があれば入力してください。',
                        ),
                        style: fieldTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              SliverGap(dimens.normalGap),
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: PhotoGridHeaderDelegate(
                  dimens: dimens,
                  onTapCamera: () => pickImage(ImageSource.camera),
                  onTapGallery: () => pickImage(ImageSource.gallery),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: dimens.largeGap,
                          horizontal: dimens.editDialogUI.horizontalPadding,
                        ).copyWith(top: 0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(dimens.largeGap),
                              bottomRight: Radius.circular(dimens.largeGap)),
                        ),
                        padding:
                            EdgeInsets.all(dimens.largeGap).copyWith(top: 0),
                        child: imageGridWidget,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoGridHeaderDelegate extends SliverPersistentHeaderDelegate {
  const PhotoGridHeaderDelegate({
    required this.dimens,
    required this.onTapGallery,
    required this.onTapCamera,
  });

  final DimensionInfo dimens;
  final Function() onTapGallery;
  final Function() onTapCamera;

  double get containerTopRadius => dimens.largeGap;
  double get horizontalPadding => dimens.editDialogUI.horizontalPadding;

  double get maxHeight => dimens.editDialogUI.headerHeight;
  double get minHeight => dimens.editDialogUI.headerHeight;
  double get titleFontSize => dimens.editDialogUI.headerTitleFontSize;
  double get titlePosTop => dimens.editDialogUI.headerTitlePositionTop;
  double get titlePosLeft => dimens.editDialogUI.headerTitlePositionLeft;
  double get buttonIconSize => dimens.editDialogUI.buttonIconSize;

  double get buttonPosTop => dimens.editDialogUI.buttonPositionTop;
  double get buttonPosRight => dimens.editDialogUI.buttonPositionRight;
  double get buttonGap => dimens.editDialogUI.buttonGap;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final size = MediaQuery.of(context).size;
    final titleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final containerColor = Theme.of(context).colorScheme.surfaceVariant;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return SizedBox(
      height: math.max(maxExtent - shrinkOffset, minExtent),
      width: size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size.width,
              color: surfaceColor,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: horizontalPadding,
              ).copyWith(top: buttonIconSize * 0.75),
              child: Container(
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(containerTopRadius),
                    topRight: Radius.circular(containerTopRadius),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: titlePosTop,
            left: titlePosLeft,
            child: Text(
              'Photos',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
          ),
          Positioned(
            right: buttonPosRight,
            top: buttonPosTop,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _IconButton(
                  iconData: Icons.add_photo_alternate_outlined,
                  iconSize: buttonIconSize,
                  onTap: onTapGallery,
                ),
                Gap(buttonGap),
                _IconButton(
                  iconData: Icons.add_a_photo_outlined,
                  iconSize: buttonIconSize,
                  onTap: onTapCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownMenu {
  const _DropdownMenu({
    required this.context,
    required this.dimens,
    required this.deviceInfo,
    required this.recordId,
    required this.uid,
    required this.mapMarkerService,
    required this.mapControlStateNotifier,
    required this.selectedMarker,
    required this.selectedMarkerStateNotifier,
    required this.textFieldsController,
  });

  final BuildContext context;
  final DimensionInfo dimens;
  final DeviceInfo deviceInfo;

  final int recordId;

  final String uid;

  final MapMarkerService mapMarkerService;
  final MapControlStateNotifier mapControlStateNotifier;
  final MarkerParam<SharedPhoto>? selectedMarker;
  final SelectedMarkerStateNotifier selectedMarkerStateNotifier;

  final _TextFieldsController textFieldsController;

  /// return true if select delete. return false if select cancel.
  /// return null if close dialog otherwise button pushing.
  Future<bool?> confirmDelete() async {
    final buttonSize = Size(
      dimens.editDialogUI.dialogButtonWidth,
      dimens.editDialogUI.dialogButtonHeight,
    );

    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogContextWidth = MediaQuery.of(dialogContext).size.width;

        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.error),
              Gap(8),
              Text('データ削除'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('このマーカー（位置情報、テキスト情報および写真）をシステムから完全に削除します。'),
              Gap(4),
              Text('データを削除した場合、元に戻すことはできません。'),
              Gap(20),
              Text('削除を実行してもよろしいですか？'),
            ],
          ),
          actions: DialogUtil.layoutActionButtons(
            containerWidth: dialogContextWidth * 0.8,
            buttonWidth: buttonSize.width,
            buttonSpacing: dimens.normalGap,
            buttons: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: buttonSize),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('削除する'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> delete(MarkerParam<SharedPhoto> marker) async {
    return await mapMarkerService
        .delete(uid, recordId, marker.attrs)
        .then<bool>((_) async {
      await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.error),
                  Gap(8),
                  Text('データ削除'),
                ],
              ),
              content: const Text('データの削除が完了しました。'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('OK'),
                ),
              ]);
        },
      );
      return true;
    }).catchError((error) async {
      logger.e('error on item deleting', error);
      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.error),
                  Gap(8),
                  Text('データ削除'),
                ],
              ),
              content: const Text('エラーが発生したため、データの削除に失敗しました。'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    selectedMarkerStateNotifier.unselect();
                    Navigator.pop(context, false);
                  },
                  child: const Text('OK'),
                ),
              ]);
        },
      );
      return false;
    });
  }

  /// return true if succeed deleting (need leave the page).
  Future<bool> deleteRecord() async {
    if (selectedMarker == null) {
      return false;
    }

    final shouldDelete = (await confirmDelete()) ?? false;
    if (shouldDelete) {
      return await delete(selectedMarker!);
    } else {
      return false;
    }
  }

  Future<void> openMap() async {
    final lat = selectedMarker!.latitude;
    final lng = selectedMarker!.longitude;
    const int zoom = 17;
    final String url =
        '//maps.google.co.jp/maps?ll=$lat,$lng&z=$zoom&q=$lat,$lng';
    late final String scheme;
    if (deviceInfo.isIOS) {
      scheme = 'comgooglemapsurl:';
    } else {
      scheme = 'https:';
    }

    await launchUrlString(scheme + url).then((value) {
      logger.d('openMap: ($value) $scheme$url');
    });
  }

  Future<void> onChanged(BuildContext context, _MenuItem item) async {
    switch (item) {
      case _MenuItems.openMap:
        await openMap();
        break;
      case _MenuItems.delete:
        final isDeleted = await deleteRecord();
        if (isDeleted) {
          selectedMarkerStateNotifier.unselect();
          mapControlStateNotifier.completeItemEditing();
          if (context.mounted) {
            GoRouter.of(context).pop();
          } else {
            logger.w(
                "[ItemEditDialog] failed dialog closing (can't call context#pop),"
                ' because context is unmounted.');
          }
        }
        break;
      case _MenuItems.save:
        if (textFieldsController.isDirty) {
          await textFieldsController.updateFields(context);
        }
        break;
    }
  }

  Widget build() {
    final colorScheme = Theme.of(context).colorScheme;
    final menuIconColor = colorScheme.onSecondaryContainer;
    final backgroundColor = colorScheme.surface;
    final itemColor = colorScheme.onSurface;
    final TextStyle itemTextStyle = TextStyle(
      color: itemColor,
      fontSize: dimens.dropdownMenu.itemFontSize,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.none,
    );
    final itemIconSize = dimens.dropdownMenu.itemIconSize;
    final itemHeight = dimens.dropdownMenu.itemHeight;
    final spacing = dimens.normalGap;

    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Padding(
          padding:
              EdgeInsets.all(dimens.smallGap).copyWith(right: dimens.normalGap),
          child: Icon(
            Icons.list,
            size: dimens.dropdownMenu.iconSize,
            color: menuIconColor,
          ),
        ),
        items: [
          ..._MenuItems.firstItems.map(
            (item) => DropdownMenuItem<_MenuItem>(
              value: item,
              child: _MenuItems.buildItem(
                item,
                spacing,
                itemIconSize,
                itemColor,
                itemTextStyle,
              ),
            ),
          ),
          const DropdownMenuItem<Divider>(enabled: false, child: Divider()),
          ..._MenuItems.secondItems.map(
            (item) => DropdownMenuItem<_MenuItem>(
              value: item,
              child: _MenuItems.buildItem(
                item,
                spacing,
                itemIconSize,
                itemColor,
                itemTextStyle,
              ),
            ),
          ),
        ],
        onChanged: (value) async {
          await onChanged(context, value as _MenuItem);
        },
        dropdownStyleData: DropdownStyleData(
          width: dimens.dropdownMenu.width,
          padding: EdgeInsets.all(dimens.normalGap),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dimens.dropdownMenu.radius),
            color: backgroundColor,
          ),
          elevation: 8,
          offset: const Offset(0, 8),
        ),
        menuItemStyleData: MenuItemStyleData(
          customHeights: [
            ...List<double>.filled(_MenuItems.firstItems.length, itemHeight),
            8,
            ...List<double>.filled(_MenuItems.secondItems.length, itemHeight),
          ],
          padding: EdgeInsets.symmetric(horizontal: dimens.normalGap),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String text;
  final IconData icon;

  const _MenuItem({
    required this.text,
    required this.icon,
  });
}

class _MenuItems {
  static const List<_MenuItem> firstItems = [save, openMap];
  static const List<_MenuItem> secondItems = [delete];

  static const openMap = _MenuItem(text: '地図アプリで開く', icon: Icons.map_outlined);
  static const delete = _MenuItem(text: 'マーカー削除', icon: Icons.delete_forever);
  static const save =
      _MenuItem(text: 'サーバーに保存', icon: Icons.cloud_done_outlined);

  static Widget buildItem(
    _MenuItem item,
    double spacing,
    double iconSize,
    Color iconColor,
    TextStyle textStyle,
  ) {
    return Row(
      children: [
        Gap(spacing * 2),
        Icon(
          item.icon,
          size: iconSize,
          color: iconColor,
        ),
        Gap(spacing),
        Text(
          item.text,
          style: textStyle,
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.iconData,
    required this.iconSize,
    required this.onTap,
  });

  final IconData iconData;
  final double iconSize;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final foregroundColor = theme.colorScheme.outline;
    final backgroundColor = theme.colorScheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: foregroundColor, width: 4),
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
            shape: BoxShape.rectangle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onTap(),
            child: Icon(
              iconData,
              size: iconSize,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
