import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/util/logger.dart';

class DialogUtil {
  const DialogUtil._();

  static List<Widget> layoutActionButtons({
    required double containerWidth,
    required double buttonWidth,
    required double buttonSpacing,
    required List<Widget> buttons,
  }) {
    final requiredWidth =
        buttonWidth * buttons.length + buttonSpacing * (buttons.length + 1);
    final isHorizontalLayout = containerWidth > requiredWidth;
    final gap = Gap(buttonSpacing);

    logger.d('[DialogUtil] width=$containerWidth, required=$requiredWidth');

    final children = <Widget>[];
    for (final button in buttons) {
      if (children.isNotEmpty) {
        children.add(gap);
      }
      children.add(button);
    }

    late final Widget ret;
    if (isHorizontalLayout) {
      ret = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: children,
      );
    } else {
      ret = Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: children.reversed.toList(),
        ),
      );
    }
    return [ret];
  }
}
