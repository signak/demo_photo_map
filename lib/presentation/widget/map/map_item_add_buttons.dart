import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/util/device_util.dart';
import '../../../core/util/exif_util.dart';
import '../../../core/util/logger.dart';
import '../../service/auth/auth_state_service.dart';
import '../../service/map_marker_service.dart';
import '../../theme/dimension_info.dart';
import '../util/component_util.dart';
import 'animated_map_controller.dart';
import 'map_control_state_provider.dart';
import 'map_item_add_mode_switch.dart';
import 'selected_marker_notifier_provider.dart';

/// 地物追加UI。<br>
/// 写真撮影・画像選択による地物追加ボタン、または通常手順の地物追加ボタンを
/// 追加モードにしたがって提供する。
class MapItemAddButtons extends HookConsumerWidget {
  /// required [appBarHeight] if use [AppBar.extendBodyBehindAppBar].
  const MapItemAddButtons(
    AnimatedMapController mapController, {
    required DimensionInfo dimensionInfo,
    this.appBarHeight = 0,
    super.key,
  })  : _mapController = mapController,
        _dimensionInfo = dimensionInfo;

  final AnimatedMapController _mapController;
  final DimensionInfo _dimensionInfo;

  final double appBarHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final deviceInfo = ref.read(deviceInfoProvider);

    final editMode = ref.watch(editModeProvider);
    final mapControlStateNotifier = ref.watch(mapControlStateProvider.notifier);
    final mapMarkerService = ref.read(mapMarkerServiceProvider);
    final authState = ref.watch(authStateNotifierProvider)!;
    final selectedMarkerNotifier =
        ref.watch(selectedMarkerStateProvider.notifier);

    final photoItemNameFormat = DateFormat('yy/MM/dd HH:mm');

    bool shouldAvoidShrink() {
      final breakPoint =
          _dimensionInfo.mapItemAddUI.breakPointHeightForAvoidShrink;

      if (breakPoint <= 0) {
        return false;
      }
      return size.height < breakPoint;
    }

    bool shouldUseHorizontalLayout() {
      final breakPoint =
          _dimensionInfo.mapItemAddUI.breakPointHeightForUseHorizontal;
      if (breakPoint <= 0) {
        return false;
      }
      return size.height < breakPoint;
    }

    // TODO [中] アップロード中にその旨表示できた方が良いので直す
    Future<void> addNewPhotoItem(ImageSource source) async {
      final picker = ImagePicker();
      await picker.pickImage(source: source).then((pickedImageFile) async {
        if (pickedImageFile == null) {
          return;
        }

        final now = DateTime.now();
        final Position gpsLocation = await Geolocator.getCurrentPosition();
        final exifInfo = await ExifUtil.getExifInfoFromXFile(pickedImageFile);

        final double latitude =
            exifInfo.coordinate?.latitude ?? gpsLocation.latitude;
        final double longitude =
            exifInfo.coordinate?.longitude ?? gpsLocation.longitude;
        final DateTime createdAt = exifInfo.createdAt ?? now;
        final name = photoItemNameFormat.format(createdAt);

        // 新規作成
        await mapMarkerService
            .createWithPhoto(authState.uid!, name, latitude, longitude,
                createdAt, pickedImageFile)
            .then((newMarker) {
          selectedMarkerNotifier.unselect();
          _mapController.moveWithAnimation(
              newMarker.attrs.coordinate, _mapController.zoom);
        });
      });
    }

    void addPhotoByCamera() {
      logger.d('add photo by camera.');
      addNewPhotoItem(ImageSource.camera);
    }

    void addPhotoFromGallery() {
      logger.d('add photo from gallery.');
      addNewPhotoItem(ImageSource.gallery);
    }

    void addPlace() {
      logger.d('add place. (start item addition mode.)');
      mapControlStateNotifier.startItemAdding();
    }

    Widget getButtonsPanel(List<Widget> buttons) {
      if (shouldUseHorizontalLayout()) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        );
      }
    }

    Widget buildButton({
      required String key,
      Function()? onPressed,
      Color? backgroundColor,
      required IconData iconData,
      Color? iconColor,
    }) {
      return ComponentUtil.buildSizedFloatingActionButton(
        key: key,
        onPressed: onPressed,
        roundedBorderRadius: _dimensionInfo.smallGap,
        iconData: iconData,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        buttonSize: _dimensionInfo.mapItemAddUI.buttonSize,
        iconSize: _dimensionInfo.mapItemAddUI.buttonIconSize,
      );
    }

    late final List<Widget> buttons;
    if (editMode == EditMode.photo) {
      buttons = [
        buildButton(
          key: 'add-by-camera',
          onPressed: (deviceInfo.isMobile) ? addPhotoByCamera : null,
          backgroundColor: (deviceInfo.isMobile)
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Theme.of(context).disabledColor,
          iconData: Icons.add_a_photo_outlined,
          iconColor: Colors.white,
        ),
        Gap(_dimensionInfo.normalGap),
        buildButton(
          key: 'add-from-album',
          onPressed: addPhotoFromGallery,
          iconData: Icons.add_photo_alternate_outlined,
        ),
      ];
    } else {
      buttons = [
        buildButton(
          key: 'add-place',
          onPressed: addPlace,
          iconData: Icons.add_location_alt_outlined,
        ),
      ];
    }

    if (shouldAvoidShrink()) {
      final double rightMargin = _dimensionInfo.mapItemAddUI.modeSwitchWidth +
          _dimensionInfo.normalGap * 2 +
          (_dimensionInfo.mapItemAddUI.modeSwitchIconSize +
                  _dimensionInfo.normalGap * 2) *
              2 +
          _dimensionInfo.normalGap;
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(_dimensionInfo.largeGap).copyWith(
            top: _dimensionInfo.normalGap + appBarHeight,
            right: rightMargin,
          ),
          child: getButtonsPanel(buttons),
        ),
      );
    } else {
      final topMargin = _dimensionInfo.mapItemAddUI.modeSwitchHeight +
          _dimensionInfo.normalGap * 2 +
          _dimensionInfo.largeGap +
          appBarHeight;
      final double bottomMargin =
          _dimensionInfo.mapControlUI.currentLocationButtonSize +
              _dimensionInfo.mapControlUI.currentLocationButtonGap +
              _dimensionInfo.mapControlUI.scaleButtonSize * 2 +
              _dimensionInfo.mapControlUI.scaleButtonGap +
              _dimensionInfo.largeGap * 2;
      return Positioned(
        top: topMargin,
        bottom: bottomMargin,
        right: _dimensionInfo.largeGap,
        child: getButtonsPanel(buttons),
      );
    }
  }
}
