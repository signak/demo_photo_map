import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../service/auth/auth_state_service.dart';
import '../../service/map_marker_service.dart';
import '../../theme/dimension_info.dart';
import '../util/component_util.dart';
import 'map_control_state_provider.dart';
import 'selected_marker_notifier_provider.dart';

/// マーカー移動操作中にオーバーレイ表示するUI Widget
class MapMarkerMoveOverlayUI extends HookConsumerWidget {
  const MapMarkerMoveOverlayUI(this.mapController, {super.key});

  final MapController mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensionInfo = DimensionUtil.getInfo(context, ref);

    final mapControlStateNotifier = ref.watch(mapControlStateProvider.notifier);
    final selectedMarker = ref.watch(selectedMarkerStateProvider);
    final mapMarkerService = ref.read(mapMarkerServiceProvider);
    final authState = ref.watch(authStateNotifierProvider)!;

    void cancelMarkerMoving() {
      mapControlStateNotifier.completeItemMoving();
    }

    void applyMarkerMoving() {
      final postLocation = mapController.center;
      mapMarkerService.updateLocation(
        authState.uid!,
        selectedMarker!.attrs.recordId,
        postLocation.latitude,
        postLocation.longitude,
      );
      mapControlStateNotifier.completeItemMoving();
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
                key: 'cancel-marker-moving',
                theme: theme,
                dimensionInfo: dimensionInfo,
                onPressed: cancelMarkerMoving,
                buttonText: 'Cancel',
                iconData: Icons.close,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
              ),
              Gap(dimensionInfo.markerEditUI.centerGapSize),
              ComponentUtil.buildMarkerEditApplyButton(
                key: 'apply-marker-moving',
                theme: theme,
                dimensionInfo: dimensionInfo,
                onPressed: applyMarkerMoving,
                buttonText: 'O K',
                iconData: Icons.done,
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
