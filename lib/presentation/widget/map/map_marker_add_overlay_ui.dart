import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../route/routes.dart';
import '../../service/auth/auth_state_service.dart';
import '../../service/map_marker_service.dart';
import '../../theme/dimension_info.dart';
import '../util/component_util.dart';
import 'map_control_state_provider.dart';
import 'selected_marker_notifier_provider.dart';

/// マーカー追加操作中にオーバーレイ表示するUI Widget
class MapMarkerAddOverlayUI extends HookConsumerWidget {
  const MapMarkerAddOverlayUI(this.mapController, {super.key});

  final MapController mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensionInfo = DimensionUtil.getInfo(context, ref);
    final mapControlStateNotifier = ref.watch(mapControlStateProvider.notifier);
    final selectedMarkerNotifier =
        ref.watch(selectedMarkerStateProvider.notifier);
    final mapMarkerService = ref.read(mapMarkerServiceProvider);
    final authState = ref.watch(authStateNotifierProvider)!;

    void cancelMarkerAdding() {
      selectedMarkerNotifier.unselect();
      mapControlStateNotifier.completeItemAdding();
    }

    void applyMarkerAdding() {
      final postLocation = mapController.center;
      mapMarkerService
          .create(authState.uid!, postLocation.latitude, postLocation.longitude)
          .then((value) {
        selectedMarkerNotifier.select(value);
        GoRouter.of(context).pushNamed(ReleaseRoutes.edit.name,
            params: {'id': '${value.attrs.recordId}'});
      });
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Icon(
            Icons.add,
            size: dimensionInfo.markerEditUI.crossHairSize,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ComponentUtil.buildMarkerEditApplyButton(
                key: 'exit-marker-adding-mode',
                theme: theme,
                dimensionInfo: dimensionInfo,
                onPressed: cancelMarkerAdding,
                buttonText: '終　了',
                iconData: Icons.close,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
              ),
              Gap(dimensionInfo.markerEditUI.centerGapSize),
              ComponentUtil.buildMarkerEditApplyButton(
                key: 'create-new-marker',
                theme: theme,
                dimensionInfo: dimensionInfo,
                onPressed: applyMarkerAdding,
                buttonText: '作　成',
                iconData: Icons.add_location_alt,
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
