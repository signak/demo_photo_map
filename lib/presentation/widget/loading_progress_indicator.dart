import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingProgressIndicator extends StatelessWidget {
  const LoadingProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _LoadingWidget(200, 200),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget(this.indicatorWidth, this.indicatorHeight);
  final double indicatorWidth;
  final double indicatorHeight;

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget =
        LoadingAnimationWidget.threeArchedCircle(color: Colors.grey, size: 160);
    return Center(
      child: SizedBox(
        width: indicatorWidth,
        height: indicatorHeight,
        child: loadingWidget,
      ),
    );
  }
}
