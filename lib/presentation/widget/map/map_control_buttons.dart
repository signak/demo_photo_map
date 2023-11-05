import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/dimension_info.dart';
import '../util/component_util.dart';
import 'animated_map_controller.dart';
import 'map_control_state_provider.dart';
import 'selected_marker_notifier_provider.dart';

/// 地図操作UI<br>
/// 地図の拡大縮小ボタンおよび現在地追従開始ボタンを提供する。
class MapControlButtons extends HookConsumerWidget {
  /// required [appBarHeight] if use [AppBar.extendBodyBehindAppBar].
  const MapControlButtons(
    this.mapController,
    this.followLocationZoomLevelStream, {
    required this.dimensionInfo,
    super.key,
    this.appBarHeight = 0,
  });

  final AnimatedMapController mapController;

  // ZoomLevel設定用Stream
  final StreamController<double?> followLocationZoomLevelStream;

  /// AppBarの高さ。
  /// extendBodyBehindAppBar=trueの場合は、AppBarの背後部分もレイアウト領域になるためレイアウトの算出に必要となる。
  final double appBarHeight;

  final DimensionInfo dimensionInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;

    bool shouldUseHorizontalLayout() {
      final breakPoint =
          dimensionInfo.mapControlUI.breakPointHeightForUseHorizontal;
      if (breakPoint <= 0) {
        return false;
      }
      return size.height < breakPoint;
    }

    final mapControlStateNotifier = ref.watch(mapControlStateProvider.notifier);
    final selectedMarkerNotifier =
        ref.watch(selectedMarkerStateProvider.notifier);

    Widget buildButton({
      required String key,
      Function()? onPressed,
      Color? backgroundColor,
      required IconData iconData,
      Color? iconColor,
      required double buttonSize,
      required double iconSize,
    }) {
      return ComponentUtil.buildSizedFloatingActionButton(
        key: key,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        iconData: iconData,
        iconColor: iconColor,
        buttonSize: buttonSize,
        iconSize: iconSize,
      );
    }

    Widget getZoomInButton() {
      return buildButton(
        key: 'zoom-in',
        onPressed: () {
          mapController.moveWithAnimation(
              mapController.center, mapController.zoom + 1);
        },
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(180),
        iconData: Icons.add_circle_outline,
        iconColor: Theme.of(context).colorScheme.onSurface,
        buttonSize: dimensionInfo.mapControlUI.scaleButtonSize,
        iconSize: dimensionInfo.mapControlUI.scaleButtonIconSize,
      );
    }

    Widget getZoomOutButton() {
      return buildButton(
        key: 'zoom-out',
        onPressed: () {
          mapController.moveWithAnimation(
              mapController.center, mapController.zoom - 1);
        },
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(180),
        iconData: Icons.remove_circle_outline,
        iconColor: Theme.of(context).colorScheme.onSurface,
        buttonSize: dimensionInfo.mapControlUI.scaleButtonSize,
        iconSize: dimensionInfo.mapControlUI.scaleButtonIconSize,
      );
    }

    Widget getFollowCurrentLocationButton() {
      return buildButton(
        key: 'follow-current-location',
        onPressed: () {
          selectedMarkerNotifier.unselect();
          mapControlStateNotifier.followCurrentLocation();
          followLocationZoomLevelStream.add(mapController.zoom);
        },
        iconData: Icons.my_location,
        buttonSize: dimensionInfo.mapControlUI.currentLocationButtonSize,
        iconSize: dimensionInfo.mapControlUI.currentLocationButtonIconSize,
      );
    }

    Widget getButtons() {
      final buttons = <Widget>[
        // Zoom-In Button
        getZoomInButton(),
        const Gap(16),

        // Zoom-Out Button
        getZoomOutButton(),
        const Gap(24),

        // Move to current location And Start current location following.
        getFollowCurrentLocationButton(),
      ];

      if (shouldUseHorizontalLayout()) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        );
      }
    }

    // Build MapControl UI Buttons. Zoom-In/Out, Follow current location.
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: EdgeInsets.only(
          bottom: dimensionInfo.largeGap,
          right: dimensionInfo.largeGap,
        ),
        child: getButtons(),
      ),
    );
  }
}
