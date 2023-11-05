import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/dimension_info.dart';
import 'map_control_state_provider.dart';

/// マーカーの追加・移動操作中にオーバーレイ表示する操作説明テキストWidget
class MapMarkerEditTipsOverlayText extends HookConsumerWidget {
  /// required [appBarHeight] if use [AppBar.extendBodyBehindAppBar].
  const MapMarkerEditTipsOverlayText({super.key, this.appBarHeight = 0});

  final double appBarHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(mapControlStateProvider);
    final dimensionInfo = DimensionUtil.getInfo(context, ref);

    if (!mode.isItemAdding && !mode.isItemMoving) {
      return const SizedBox.shrink();
    }

    WidgetSpan inlineIcon(IconData icon) {
      return WidgetSpan(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dimensionInfo.smallestGap),
          child: Icon(
            icon,
            size: dimensionInfo.markerEditUI.tipsIconSize,
          ),
        ),
      );
    }

    final String lineFeed = (dimensionInfo.isPhoneLayout) ? '\n' : '';
    String? title;
    TextSpan? text;
    if (mode.isItemAdding) {
      title = 'マーカーを新たに追加します。';
      text = TextSpan(
        children: [
          const TextSpan(text: '新規追加する場所に'),
          inlineIcon(Icons.add),
          TextSpan(text: 'を移動して、$lineFeed'),
          inlineIcon(Icons.add_location_alt),
          const TextSpan(text: 'ボタンを押してください。'),
        ],
      );
    } else if (mode.isItemMoving) {
      title = '選択したマーカーを移動します。';
      text = TextSpan(
        children: [
          const TextSpan(text: 'マーカーの移動先に'),
          inlineIcon(Icons.add),
          TextSpan(text: 'を移動して、$lineFeed'),
          inlineIcon(Icons.done),
          const TextSpan(text: 'ボタンを押してください。'),
        ],
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.primaryContainer;
    final textColor = colorScheme.onPrimaryContainer;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.all(dimensionInfo.smallGap).copyWith(
            top: dimensionInfo.markerEditUI.tipsTopMargin + appBarHeight),
        padding: EdgeInsets.symmetric(
          vertical: dimensionInfo.normalGap,
          horizontal: dimensionInfo.largeGap,
        ),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(dimensionInfo.normalGap),
          border: Border.all(color: textColor),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dimensionInfo.largeGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? '',
                style: DefaultTextStyle.of(context).style.copyWith(
                      color: textColor,
                      fontSize: dimensionInfo.markerEditUI.tipsFontSize,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Gap(dimensionInfo.normalGap),
              Text.rich(
                text ?? const TextSpan(text: ''),
                style: DefaultTextStyle.of(context).style.copyWith(
                      color: textColor,
                      fontSize: dimensionInfo.markerEditUI.tipsFontSize,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
