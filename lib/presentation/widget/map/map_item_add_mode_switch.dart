import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/custom_color.g.dart';
import '../../theme/dimension_info.dart';
import '../util/component_util.dart';

enum EditMode {
  photo,
  place,
}

final editModeProvider = StateProvider<EditMode>(
  (ref) => EditMode.photo,
);

final _editModeSwitchValueProvider = Provider<bool>(
  (ref) {
    return ref.watch(editModeProvider) == EditMode.place;
  },
);

/// 地物追加モード切替スイッチ
class MapItemAddModeSwitch extends HookConsumerWidget {
  const MapItemAddModeSwitch(
      {super.key, EditMode initialMode = EditMode.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editModeNotifier = ref.read(editModeProvider.notifier);
    final bool editModeIsPlace = ref.watch(_editModeSwitchValueProvider);
    final dimensInfo = DimensionUtil.getInfo(context, ref);

    void switchToPhotoMode() {
      editModeNotifier.state = EditMode.photo;
    }

    void switchToPlaceMode() {
      editModeNotifier.state = EditMode.place;
    }

    void onSwitchChanged(bool toPlaceMode) {
      (toPlaceMode) ? switchToPlaceMode() : switchToPhotoMode();
    }

    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;

    final switchWidth = dimensInfo.mapItemAddUI.modeSwitchWidth;
    final switchHeight = dimensInfo.mapItemAddUI.modeSwitchHeight;
    final switchGap = dimensInfo.smallGap;
    final modeIconSize = dimensInfo.mapItemAddUI.modeSwitchIconSize;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dimensInfo.largeGap),
        color: theme.colorScheme.surface.withAlpha(180),
      ),
      padding: EdgeInsets.symmetric(
          vertical: dimensInfo.smallGap, horizontal: dimensInfo.largeGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: switchToPhotoMode,
            child: Icon(
              Icons.photo_camera,
              color: customColors.camera,
              size: modeIconSize,
            ),
          ),
          Gap(switchGap),
          ComponentUtil.buildSizedSwitch(
            switchWidth: switchWidth,
            switchHeight: switchHeight,
            initialValue: editModeIsPlace,
            onChanged: onSwitchChanged,
            activeTrackColor: customColors.mapMarkerContainer,
            activeColor: customColors.mapMarker,
            inactiveTrackColor: customColors.cameraContainer,
            inactiveThumbColor: customColors.camera,
          ),
          Gap(switchGap),
          GestureDetector(
            onTap: switchToPlaceMode,
            child: Icon(
              Icons.place,
              color: customColors.mapMarker,
              size: modeIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
