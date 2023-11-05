import 'package:flutter/material.dart';

/// トランジションの種類
enum ModalOverlayTransition {
  scale,
  slideFromRight,
  slideFromLeft,
  slideFromTop,
  slideFromBottom,
}

/// モーダルオーバーレイ
class ModalOverlay<T> extends ModalRoute<T> {
  ModalOverlay({
    required Widget body,
    this.isAndroidBackEnable = true,
    this.transitionType = ModalOverlayTransition.scale,
    bool barrierDismissible = false,
    Duration transitionDuration = const Duration(milliseconds: 500),
  })  : contents = body,
        _transitionDuration = transitionDuration,
        _barrierDismissible = barrierDismissible,
        super();

  /// ダイアログ内のWidget
  final Widget contents;

  /// Androidのバックボタンを有効にするか
  final bool isAndroidBackEnable;

  /// トランジションの種類
  final ModalOverlayTransition transitionType;

  /// トランジションの実行時間
  final Duration _transitionDuration;

  /// trueの場合はバリア部分をクリックした際にダイアログを閉じる
  final bool _barrierDismissible;

  @override
  Duration get transitionDuration => _transitionDuration;
  @override
  bool get opaque => false;
  @override
  bool get barrierDismissible => _barrierDismissible;
  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);
  @override
  String? get barrierLabel => null;
  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    late final AnimatedWidget animatedChild;
    switch (transitionType) {
      case ModalOverlayTransition.scale:
        animatedChild = ScaleTransition(scale: animation, child: child);
        break;
      default:
        late final Offset slideOffset;
        switch (transitionType) {
          case ModalOverlayTransition.slideFromTop:
            slideOffset = const Offset(0, -1);
            break;
          case ModalOverlayTransition.slideFromRight:
            slideOffset = const Offset(1, 0);
            break;
          case ModalOverlayTransition.slideFromBottom:
            slideOffset = const Offset(0, 1);
            break;
          case ModalOverlayTransition.slideFromLeft:
            slideOffset = const Offset(-1, 0);
            break;
          default:
            throw ArgumentError(
                '[ModalOverlay] unknown type of ModalOverlayTransition.');
        }
        animatedChild = SlideTransition(
          position: Tween<Offset>(
            begin: slideOffset,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
        break;
    }

    return FadeTransition(
      opacity: animation,
      child: animatedChild,
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return WillPopScope(
      child: contents,
      onWillPop: () {
        return Future(() => isAndroidBackEnable);
      },
    );
  }
}
