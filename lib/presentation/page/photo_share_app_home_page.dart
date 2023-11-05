import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:pwa_update_listener/pwa_update_listener.dart';

import '../../core/util/logger.dart';
import '../../core/util/version_util.dart';
import '../../core/widget/modal_overlay.dart';
import '../../domain/auth/auth_state.dart';
import '../../route/routes.dart';
import '../service/auth/auth_state_service.dart';
import '../service/auth/authentication_service.dart';
import '../service/map_marker_service.dart';
import '../theme/dimension_info.dart';
import '../widget/map/map_view_widget.dart';
import '../widget/util/component_util.dart';
import '../widget/util/dialog_util.dart';
import 'marker_list_page.dart';

final systemUpdateReadyStateProvider = StateProvider<bool>((ref) => false);

// TODO [中] 更新通知アイコンの表示調整（モバイルだとIconDataが中心に表示されてない）
class PhotoShareAppHomePage extends HookConsumerWidget {
  const PhotoShareAppHomePage({super.key});

  List<Widget> _getLogMenuItem(
      BuildContext context, DimensionInfo dimens, AuthState? authState) {
    if (authState?.isSystemAdmin ?? false) {
      final menuItem = InkWell(
        onTap: () {
          context.pushNamed(ReleaseRoutes.logView.name);
        },
        child: Padding(
          padding: EdgeInsets.all(dimens.normalGap),
          child: ListTile(
            leading: Icon(
              Icons.event_note,
              size: dimens.dropdownMenu.itemIconSize,
            ),
            title: Text(
              'ログ表示',
              style: TextStyle(
                fontSize: dimens.dropdownMenu.itemFontSize,
              ),
            ),
          ),
        ),
      );

      return [menuItem];
    }
    return [];
  }

  List<Widget> _getAuthorizationMenuItem(
      BuildContext context, DimensionInfo dimens, AuthState? authState) {
    if (authState?.isAuthorizationAdmin ?? false) {
      final authMenu = InkWell(
        onTap: () {
          context.pushNamed(ReleaseRoutes.authorization.name);
        },
        child: Padding(
          padding: EdgeInsets.all(dimens.normalGap),
          child: ListTile(
            leading: Icon(
              Icons.account_box,
              size: dimens.dropdownMenu.itemIconSize,
            ),
            title: Text(
              'アカウント管理',
              style: TextStyle(
                fontSize: dimens.dropdownMenu.itemFontSize,
              ),
            ),
          ),
        ),
      );

      return [authMenu];
    }
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dimens = DimensionUtil.getInfo(context, ref);
    final authState = ref.read(authStateNotifierProvider);

    final appBarForegroundColor = theme.colorScheme.onPrimary;
    final appBarBackgroundColor = theme.colorScheme.primary;

    TextStyle getAppBarTextStyle() {
      final customTextStyle = TextStyle(
        color: appBarForegroundColor.withOpacity(0.5),
        fontWeight: FontWeight.w200,
        decoration: TextDecoration.none,
        fontSize: dimens.appBarFontSize,
      );
      return theme.appBarTheme.titleTextStyle?.merge(customTextStyle) ??
          customTextStyle;
    }

    final appBar = AppBar(
      title: const Text('Photo Sharing Web App [DEMO]'),
      titleTextStyle: getAppBarTextStyle(),
      elevation: 0,
      foregroundColor: appBarForegroundColor,
      backgroundColor: appBarBackgroundColor.withOpacity(0.75),
      iconTheme: IconThemeData(
        color: appBarForegroundColor,
        size: dimens.appBarIconSize,
      ),
    );
    final appBarHeight = appBar.preferredSize.height;

    final drawerHeader = DrawerHeader(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(dimens.largeGap).copyWith(
            left: dimens.largeGap * 2,
            right: dimens.smallGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Menu',
                  style: TextStyle(
                    fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
                    fontSize: dimens.dropdownMenu.titleFontSize,
                  )),
              Gap(dimens.normalGap),
              Flexible(
                child: Text(
                  authState?.email ?? 'unknown email address',
                  style: TextStyle(
                    fontFamily: theme.primaryTextTheme.bodyMedium?.fontFamily,
                    fontSize: dimens.dropdownMenu.userFontSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final markersMenuItem = InkWell(
      onTap: () async {
        final markerListScreen = ModalOverlay<LatLng>(
          body: const MarkerListWidget(),
          barrierDismissible: true,
          transitionType: ModalOverlayTransition.slideFromRight,
          transitionDuration: const Duration(microseconds: 300),
        );

        await Navigator.of(context).push(markerListScreen).then((point) {
          if (point == null) {
            return;
          }
          final controller = ref.read(moveCenterLocationStreamProvider);
          controller.add(point);

          Navigator.pop(context);
        });
      },
      child: SizedBox(
        height: dimens.dropdownMenu.itemHeight,
        child: Padding(
          padding: EdgeInsets.all(dimens.normalGap),
          child: ListTile(
            leading: Icon(
              Icons.list_alt,
              size: dimens.dropdownMenu.itemIconSize,
            ),
            title: Text(
              'マーカーリスト',
              style: TextStyle(
                fontSize: dimens.dropdownMenu.itemFontSize,
              ),
            ),
          ),
        ),
      ),
    );

    Widget? getSystemUpdateNotifyButton() {
      final hasSystemUpdate = ref.watch(systemUpdateReadyStateProvider);
      if (!hasSystemUpdate) {
        return null;
      }

      final colorScheme = Theme.of(context).colorScheme;
      final iconColor = colorScheme.onSecondary;
      final colors = [colorScheme.secondary, colorScheme.secondaryContainer];

      return SystemUpdateNotificationButton(
        dimens: dimens,
        appBarHeight: appBarHeight,
        iconColor: iconColor,
        backgroundColors: colors,
      );
    }

    final systemUpdateReadyNotifier =
        ref.watch(systemUpdateReadyStateProvider.notifier);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: getSystemUpdateNotifyButton(),
        appBar: appBar,
        endDrawer: Drawer(
          width: dimens.dropdownMenu.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              drawerHeader,
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    markersMenuItem,
                    const Divider(),
                    ImageCacheClearItem(dimens),
                    ..._getAuthorizationMenuItem(context, dimens, authState),
                    ..._getLogMenuItem(context, dimens, authState),
                    const Divider(),
                    ReloadMenuItem(dimens),
                    SignOutMenuItem(dimens),
                  ],
                ),
              ),
              const Divider(),
              DrawerFooter(dimens, isSystemAdmin: authState!.isSystemAdmin),
            ],
          ),
        ),
        body: PwaUpdateListener(
          onReady: () {
            logger.i('[HOME_PAGE] update notify to new system ready.');
            systemUpdateReadyNotifier.update((state) => true);
          },
          child: DefaultTextStyle(
              style: TextStyle(fontSize: dimens.normalFontSize),
              child: MapViewWidget(1.0.sh,
                  appBarHeight: appBar.preferredSize.height)),
        ),
      ),
    );
  }
}

class SystemUpdateNotificationButton extends HookConsumerWidget {
  const SystemUpdateNotificationButton({
    super.key,
    required this.dimens,
    required this.appBarHeight,
    this.iconData = FontAwesomeIcons.bell,
    required this.iconColor,
    required this.backgroundColors,
    this.durationSecs,
  });

  final DimensionInfo dimens;
  final double appBarHeight;

  final IconData iconData;

  final Color iconColor;
  final List<Color> backgroundColors;

  final int? durationSecs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endIndex = backgroundColors.length - 1;
    final tween = IntTween(begin: 0, end: endIndex);

    final animationController = useAnimationController(
        duration: Duration(seconds: durationSecs ?? backgroundColors.length));
    final animation = useAnimation(tween.animate(animationController));

    final color = backgroundColors[animation];

    final buttonDimens = dimens.systemUpdateNotificationButton;

    final buttonSize = buttonDimens.buttonSize;
    final buttonIconSize = buttonDimens.buttonIconSize;

    final paddingLeft = buttonDimens.paddingLeft;
    final paddingTop = appBarHeight + buttonDimens.paddingTop;

    final dialogButtonSize = Size(
      dimens.systemUpdateNotificationButton.dialogButtonWidth,
      dimens.systemUpdateNotificationButton.dialogButtonHeight,
    );
    final button = Padding(
      padding: EdgeInsets.only(left: paddingLeft, top: paddingTop),
      child: ComponentUtil.buildSizedFloatingActionButton(
        key: 'system-update-notification-button',
        buttonSize: buttonSize,
        iconSize: buttonIconSize,
        iconData: iconData,
        iconColor: iconColor,
        backgroundColor: color,
        onPressed: () async {
          await showDialog<bool?>(
            context: context,
            builder: (dialogContext) {
              final dialogContextWidth =
                  MediaQuery.of(dialogContext).size.width;

              return AlertDialog(
                title: Row(
                  children: [
                    Icon(iconData),
                    Gap(dimens.normalGap),
                    const Text('システム更新'),
                  ],
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('新しいバージョンのシステムがあります。'),
                    Gap(dimens.smallGap),
                    const Text('リロードしてシステムを更新しますか？'),
                  ],
                ),
                actions: DialogUtil.layoutActionButtons(
                  containerWidth: dialogContextWidth * 0.8,
                  buttonWidth: dialogButtonSize.width,
                  buttonSpacing: dimens.normalGap,
                  buttons: [
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(fixedSize: dialogButtonSize),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(fixedSize: dialogButtonSize),
                      onPressed: reloadPwa,
                      child: const Text('リロードして更新'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    animationController.repeat();
    return button;
  }
}

class DrawerFooter extends HookConsumerWidget {
  const DrawerFooter(this.dimens, {super.key, this.isSystemAdmin = false});

  final DimensionInfo dimens;
  final bool isSystemAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ver = ref.read(versionInfoProvider);
    final String versionText = (kDebugMode || isSystemAdmin)
        ? 'Ver.${ver.version}+${ver.buildNumber}'
        : 'Ver.${ver.version}';
    return Center(
        child: Padding(
            padding: EdgeInsets.all(dimens.normalGap),
            child: Text(
              versionText,
              style: TextStyle(fontSize: dimens.dropdownMenu.versionFontSize),
            )));
  }
}

class ReloadMenuItem extends StatelessWidget {
  const ReloadMenuItem(this.dimens, {super.key});

  final DimensionInfo dimens;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: Icon(
        Icons.sync,
        size: dimens.dropdownMenu.itemIconSize,
      ),
      title: Text('App再読込',
          style: TextStyle(
            fontSize: dimens.dropdownMenu.itemFontSize,
          )),
    );

    return InkWell(
      onTap: reloadPwa,
      child: Padding(
        padding: EdgeInsets.all(dimens.normalGap),
        child: tile,
      ),
    );
  }
}

class SignOutMenuItem extends HookConsumerWidget {
  const SignOutMenuItem(this.dimens, {super.key});

  final DimensionInfo dimens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> signOut() async {
      final authState = ref.read(authStateNotifierProvider);
      final authenticationService = ref.read(authenticationServiceProvider);
      await authenticationService.signOut(authState);
    }

    final tile = ListTile(
      leading: Icon(
        Icons.logout,
        size: dimens.dropdownMenu.itemIconSize,
      ),
      title: Text('サインアウト',
          style: TextStyle(
            fontSize: dimens.dropdownMenu.itemFontSize,
          )),
    );

    return InkWell(
      onTap: () => signOut(),
      child: Padding(
        padding: EdgeInsets.all(dimens.normalGap),
        child: tile,
      ),
    );
  }
}

class ImageCacheClearItem extends HookConsumerWidget {
  const ImageCacheClearItem(this.dimens, {super.key});

  final DimensionInfo dimens;

  static const title = 'キャッシュクリア';

  static const dialogTitle = 'キャッシュ';
  static const succeedMessage = '画像キャッシュをクリアしました。';
  static const failedMessage = '画像キャッシュのクリアに失敗しました。';
  static const errorMessage = '画像キャッシュのクリア処理中に予期しないエラーが発生しました。';

  Future<void> _showMessageDialog(
    BuildContext context,
    DimensionInfo dimens, {
    required String title,
    required String message,
    bool hasError = false,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon((hasError) ? Icons.error : Icons.error),
              Gap(dimens.normalGap),
              Text(
                dialogTitle,
                style: TextStyle(
                  fontSize: dimens.normalFontSize,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> clearImageCache() async {
      final mapMarkerService = ref.read(mapMarkerServiceProvider);
      await mapMarkerService.clearImageCache().then((ret) async {
        final message = (ret) ? succeedMessage : failedMessage;
        await _showMessageDialog(
          context,
          dimens,
          title: title,
          message: message,
        );
      }).catchError((_) async {
        await _showMessageDialog(
          context,
          dimens,
          title: title,
          message: errorMessage,
        );
      });
    }

    final tile = ListTile(
      leading: Icon(
        Icons.recycling,
        size: dimens.dropdownMenu.itemIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: dimens.dropdownMenu.itemFontSize,
        ),
      ),
    );

    return InkWell(
      onTap: () async => await clearImageCache(),
      child: Padding(
        padding: EdgeInsets.all(dimens.normalGap),
        child: tile,
      ),
    );
  }
}
