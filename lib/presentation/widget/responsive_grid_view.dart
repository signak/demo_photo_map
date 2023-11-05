import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/util/logger.dart';

class ResponsiveGridView extends HookConsumerWidget {
  const ResponsiveGridView({
    super.key,
    required this.minImageSize,
    required this.itemSpacing,
    required this.children,
    required this.performWidth,
    this.noDataNotification,
  });

  final double performWidth;
  final double minImageSize;
  final double itemSpacing;
  final List<Widget> children;
  final Widget? noDataNotification;

  int _calcCrossAxisCount() {
    return (performWidth / minImageSize).round();
  }

  double _calcItemSize(int crossAxisCount) {
    return ((performWidth - ((crossAxisCount - 1) * itemSpacing)) /
            crossAxisCount)
        .floorToDouble();
  }

  List<Widget> _buildRowItems(
    BuildContext context,
    double itemSize,
    int start,
    int crossAxisCount,
  ) {
    final ret = <Widget>[];
    final range = List<int>.generate(crossAxisCount, (index) => start + index);

    for (final i in range) {
      if (i >= children.length) {
        logger.d('[ResponsiveGridView] break: $i is out of range.');
        break;
      }

      if (i > start) {
        ret.add(Gap(itemSpacing));
      }

      final child = children[i];
      ret.add(SizedBox.square(
        dimension: itemSize,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ));
    }
    return ret;
  }

  List<Widget> _buildEmptyRows(BuildContext context) {
    final List<Widget> children = [
      (noDataNotification == null)
          ? SizedBox.square(dimension: itemSpacing)
          : noDataNotification!,
    ];
    return [
      SizedBox.square(dimension: itemSpacing),
      Padding(
        padding: EdgeInsets.only(bottom: itemSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
      SizedBox.square(dimension: itemSpacing),
    ];
  }

  List<Widget> _buildRows(BuildContext context) {
    if (children.isEmpty) {
      return _buildEmptyRows(context);
    }

    final int crossAxisCount = _calcCrossAxisCount();
    final double performItemSize = _calcItemSize(crossAxisCount);
    final int rowCount = (children.length / crossAxisCount).ceil();

    final ret = <Widget>[];

    for (final r in List<int>.generate(rowCount, (index) => index)) {
      final int start = r * crossAxisCount;
      final row = Padding(
        padding: EdgeInsets.only(bottom: itemSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildRowItems(
            context,
            performItemSize,
            start,
            crossAxisCount,
          ),
        ),
      );
      ret.add(row);
    }

    return ret;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _buildRows(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}
