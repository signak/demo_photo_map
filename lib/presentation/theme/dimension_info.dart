import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/util/device_util.dart';

class DimensionUtil {
  const DimensionUtil._();

  /// 画面サイズ・デバイスに即したサイズ情報を取得する。
  static DimensionInfo getInfo(BuildContext context, WidgetRef ref) {
    final param = _DimensionInfoParam.of(context, ref);
    return ref.watch(_dimensionInfoProvider(param));
  }
}

final _dimensionInfoProvider =
    StateProvider.autoDispose.family<DimensionInfo, _DimensionInfoParam>(
  (ref, param) => DimensionInfo._of(param),
);

@immutable
class _DimensionInfoParam {
  const _DimensionInfoParam._(this.type);

  final DimensionType type;

  factory _DimensionInfoParam.phone() {
    return const _DimensionInfoParam._(DimensionType.phone);
  }

  factory _DimensionInfoParam.large() {
    return const _DimensionInfoParam._(DimensionType.large);
  }

  factory _DimensionInfoParam.of(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final deviceInfo = ref.watch(deviceInfoProvider);

    if (deviceInfo.isDesktop) {
      return (screenSize.width < DimensionInfo.breakPointForDesktop)
          ? _DimensionInfoParam.phone()
          : _DimensionInfoParam.large();
    } else {
      final size = math.min(screenSize.width, screenSize.height);
      return (size < DimensionInfo.breakPoint)
          ? _DimensionInfoParam.phone()
          : _DimensionInfoParam.large();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _DimensionInfoParam &&
          runtimeType == other.runtimeType &&
          type == other.type);

  @override
  int get hashCode {
    return type.name.hashCode;
  }
}

enum DimensionType {
  /// smart phone, or small window on pc.
  phone,

  /// tablet or large window on pc.
  large,
}

/// システム更新通知ボタンのサイズ情報
class SystemUpdateNotificationButtonInfo {
  const SystemUpdateNotificationButtonInfo({
    required this.buttonSize,
    required this.buttonIconSize,
    required this.paddingLeft,
    required this.paddingTop,
    required this.dialogButtonWidth,
    required this.dialogButtonHeight,
  });

  /// ボタンサイズ
  final double buttonSize;

  /// ボタンのアイコンサイズ
  final double buttonIconSize;

  /// 左の余白サイズ
  final double paddingLeft;

  /// 上の余白サイズ
  final double paddingTop;

  /// ダイアログのボタン幅
  final double dialogButtonWidth;

  /// ダイアログのボタン高さ
  final double dialogButtonHeight;
}

/// ログイン画面UIのサイズ情報
class LoginUiInfo {
  const LoginUiInfo({
    required this.containerVerticalMargin,
    required this.containerHorizontalMargin,
    required this.versionFontSize,
    required this.maxContainerWidth,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.passwdResetFontSize,
    required this.snackbarIconSize,
  });

  /// UIコンテナの上下マージン
  final double containerVerticalMargin;

  /// UIコンテナの左右マージン
  final double containerHorizontalMargin;

  /// バージョン表示のフォントサイズ
  final double versionFontSize;

  /// UIコンテナの最大幅
  final double maxContainerWidth;

  /// ボタンの幅
  final double buttonWidth;

  /// ボタンの高さ
  final double buttonHeight;

  /// パスワードリセットリンクテキストのフォントサイズ
  final double passwdResetFontSize;

  /// スナックバーメッセージにつけるアイコンのサイズ
  final double snackbarIconSize;
}

/// ドロップダウンメニューのサイズ情報
class DropdownMenuInfo {
  const DropdownMenuInfo._({
    required this.titleFontSize,
    required this.userFontSize,
    required this.versionFontSize,
    required this.iconSize,
    required this.width,
    required this.radius,
    required this.itemIconSize,
    required this.itemFontSize,
  });

  /// メニューのタイトルフォントサイズ
  final double titleFontSize;

  /// メニューに表示されるユーザーIDのフォントサイズ
  final double userFontSize;

  /// メニューに表示されるバージョン情報のフォントサイズ
  final double versionFontSize;

  /// メニューボタンのアイコンサイズ
  final double iconSize;

  /// メニューの幅
  final double width;

  /// メニュー角丸径
  final double radius;

  /// メニュー項目のアイコンサイズ
  final double itemIconSize;

  /// メニュー項目のフォントサイズ
  final double itemFontSize;

  /// メニュー項目の高さ（フォントサイズの2.5倍）
  double get itemHeight => itemIconSize * 2.5;
}

/// 権限管理画面のサイズ情報
class AuthorizationEditUiInfo {
  const AuthorizationEditUiInfo({
    required this.hintFontSize,
    required this.messageFontSize,
    required this.stateIconSize,
    required this.cardHeight,
    required this.regDateFontSize,
    required this.userIdFontSize,
    required this.dialogButtonWidth,
    required this.dialogButtonHeight,
  });

  /// 操作ヒントのフォントサイズ
  final double hintFontSize;

  /// メッセージ表示のフォントサイズ
  final double messageFontSize;

  /// 認可状態アイコンのサイズ
  final double stateIconSize;

  /// ユーザー情報カードの高さ
  final double cardHeight;

  /// ユーザー登録日のフォントサイズ
  final double regDateFontSize;

  /// ユーザーIDのフォントサイズ
  final double userIdFontSize;

  /// ダイアログのボタン幅
  final double dialogButtonWidth;

  /// ダイアログのボタン高さ
  final double dialogButtonHeight;
}

/// 地物情報編集画面のサイズ情報
class ItemEditDialogUiInfo {
  const ItemEditDialogUiInfo._({
    required this.minImageSize,
    required this.itemGap,
    required this.horizontalPadding,
    required this.headerHeight,
    required this.headerTitleFontSize,
    required this.headerTitlePositionTop,
    required this.headerTitlePositionLeft,
    required this.buttonIconSize,
    required this.buttonPositionTop,
    required this.buttonPositionRight,
    required this.buttonGap,
    required this.dialogButtonWidth,
    required this.dialogButtonHeight,
  });

  /// グリッド表示する画像の最小サイズ
  final double minImageSize;

  /// 画像の間隔サイズ
  final double itemGap;

  /// ページ内項目の水平余白サイズ
  final double horizontalPadding;

  /// 写真項目のヘッダ高
  final double headerHeight;

  /// 写真項目のヘッダタイトルフォントサイズ
  final double headerTitleFontSize;

  /// 写真項目のヘッダタイトルTop位置
  final double headerTitlePositionTop;

  /// 写真項目のヘッダタイトル左位置
  final double headerTitlePositionLeft;

  /// 写真追加ボタンのアイコンサイズ
  final double buttonIconSize;

  /// 写真追加ボタンのTop位置
  final double buttonPositionTop;

  /// 写真追加ボタンの右位置
  final double buttonPositionRight;

  /// 写真追加ボタンの間隔サイズ
  final double buttonGap;

  /// ダイアログのボタン幅
  final double dialogButtonWidth;

  /// ダイアログのボタン高さ
  final double dialogButtonHeight;
}

/// 地図の操作（現在地・拡大縮小）UIのサイズ情報
class MapControlUiInfo {
  const MapControlUiInfo._({
    required this.scaleButtonSize,
    required this.scaleButtonIconSize,
    required this.scaleButtonGap,
    required this.currentLocationButtonSize,
    required this.currentLocationButtonIconSize,
    required this.currentLocationButtonGap,
    required this.breakPointHeightForUseHorizontal,
  });

  /// 地図の拡大縮小ボタンのサイズ
  final double scaleButtonSize;

  /// 地図の拡大縮小ボタンのアイコンサイズ
  final double scaleButtonIconSize;

  /// 地図の拡大縮小ボタン間のGapサイズ
  final double scaleButtonGap;

  /// 地図の現在地ボタンのサイズ
  final double currentLocationButtonSize;

  /// 地図の現在地ボタンのアイコンサイズ
  final double currentLocationButtonIconSize;

  /// 地図の現在地ボタンと拡大縮小ボタン間のGapサイズ
  final double currentLocationButtonGap;

  /// ボタンを横レイアウトにするボーダーとなる高さ。
  /// これを下回ると横配置になる。
  final double breakPointHeightForUseHorizontal;
}

/// 地図上のアイテム追加UIのサイズ情報
class MapItemAddUiInfo {
  const MapItemAddUiInfo._({
    required this.modeSwitchWidth,
    required this.modeSwitchHeight,
    required this.modeSwitchIconSize,
    required this.buttonSize,
    required this.buttonIconSize,
    required this.breakPointHeightForAvoidShrink,
    required this.breakPointHeightForUseHorizontal,
  });

  /// 追加モード切替スイッチの幅
  final double modeSwitchWidth;

  /// 追加モード切替スイッチの高さ
  final double modeSwitchHeight;

  /// 追加モード切替スイッチのアイコンサイズ
  final double modeSwitchIconSize;

  /// アイテム追加ボタンのサイズ
  final double buttonSize;

  /// アイテム追加ボタンのアイコンサイズ
  final double buttonIconSize;

  /// ボタンを画面右側から別位置に移動したレイアウトにするボーダーとなる高さ。
  /// これを下回ると別位置に移動する。
  final double breakPointHeightForAvoidShrink;

  /// ボタンを横レイアウトにするボーダーとなる高さ。
  /// これを下回ると横配置になる。
  final double breakPointHeightForUseHorizontal;
}

/// マーカーの追加・移動中にオーバーレイ表示されるUIのサイズ情報
class MarkerEditApplyUiInfo {
  const MarkerEditApplyUiInfo._({
    required this.buttonWidth,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.buttonIconSize,
    required this.centerGapSize,
    required this.crossHairSize,
    required this.tipsFontSize,
    required this.tipsIconSize,
    required this.tipsTopMargin,
  });

  /// ボタン全体の固定幅
  final double buttonWidth;

  /// ボタン全体の固定高
  final double buttonHeight;

  /// ボタンのフォントサイズ
  final double buttonFontSize;

  /// ボタンのアイコンサイズ
  final double buttonIconSize;

  /// ボタン同士の中央Gapサイズ
  final double centerGapSize;

  /// 十字カーソルのサイズ
  final double crossHairSize;

  /// モード説明テキストのフォントサイズ
  final double tipsFontSize;

  /// モード説明テキスト中のアイコンサイズ
  final double tipsIconSize;

  /// tipsの説明テキストの上マージン
  final double tipsTopMargin;

  /// ラベルが必要な場合はTrue
  bool get hasLabel => buttonFontSize > 0;

  /// アイコンのみの表示の場合はTrue
  bool get isIconOnly => buttonFontSize <= 0;
}

/// マーカーのサイズ情報
class MapMarkerInfo {
  const MapMarkerInfo._({
    required this.width,
    required this.height,
    required this.iconSize,
    required this.fontSize,
    required this.textBorderWidth,
    required this.gap,
    required this.clusterSize,
  });

  /// ラベル付きマーカーのボックス幅
  final double width;

  /// ラベル付きマーカーのボックス高
  final double height;

  /// マーカーのアイコンサイズ
  final double iconSize;

  /// マーカーラベルのフォントサイズ
  final double fontSize;

  /// マーカーラベルの縁取り幅
  final double textBorderWidth;

  /// マーカーラベルとアイコンの間のスペースサイズ
  final double gap;

  /// クラスタリングされた際の円のサイズ
  final double clusterSize;
}

@immutable
class DimensionInfo {
  const DimensionInfo._({
    required this.type,
    required this.appBarFontSize,
    required this.appBarIconSize,
    required this.smallFontSize,
    required this.normalFontSize,
    required this.largeFontSize,
    required this.smallestGap,
    required this.smallGap,
    required this.normalGap,
    required this.largeGap,
    required this.dropdownMenu,
    required this.markerEditUI,
    required this.mapMarker,
    required this.mapItemAddUI,
    required this.mapControlUI,
    required this.editDialogUI,
    required this.authEditUI,
    required this.loginUI,
    required this.systemUpdateNotificationButton,
  });

  /// 提供するサイズの種類
  final DimensionType type;

  /// AppBarのタイトルフォントサイズ
  final double appBarFontSize;

  /// AppBarに表示するアイコンのサイズ
  final double appBarIconSize;

  /// フォントの小サイズ
  final double smallFontSize;

  /// フォントの標準サイズ
  final double normalFontSize;

  /// フォントの大サイズ
  final double largeFontSize;

  /// 最小Gapのサイズ
  final double smallestGap;

  /// 小Gapのサイズ
  final double smallGap;

  /// 通常Gapのサイズ
  final double normalGap;

  /// 大Gapのサイズ
  final double largeGap;

  /// Drawer, DropdownMenuのサイズ情報
  final DropdownMenuInfo dropdownMenu;

  /// マーカーの追加・移動中にオーバーレイ表示されるUIのサイズ情報
  final MarkerEditApplyUiInfo markerEditUI;

  /// マーカーのサイズ情報
  final MapMarkerInfo mapMarker;

  /// 地物追加UIのサイズ情報
  final MapItemAddUiInfo mapItemAddUI;

  /// 地図操作UIのサイズ情報
  final MapControlUiInfo mapControlUI;

  /// 地物編集画面UIのサイズ情報
  final ItemEditDialogUiInfo editDialogUI;

  /// 権限編集画面のサイズ情報
  final AuthorizationEditUiInfo authEditUI;

  /// ログイン画面のサイズ情報
  final LoginUiInfo loginUI;

  /// システム更新通知ボタンのサイズ情報
  final SystemUpdateNotificationButtonInfo systemUpdateNotificationButton;

  /// 提供するサイズがスマホ用レイアウトの場合はTrue
  bool get isPhoneLayout => type == DimensionType.phone;

  /// 提供するサイズが大画面用レイアウトの場合はTrue
  bool get isLargeLayout => type == DimensionType.large;

  /// デスクトップ以外の環境での、
  /// スマホレイアウトと大画面レイアウトの切替ボーダーとなるサイズ。
  /// 表示範囲の縦または横のサイズがこれを下回るとスマホ向けレイアウトになる。
  static const double breakPoint = 580;

  /// デスクトップ環境での、
  /// スマホレイアウトと大画面レイアウトの切替ボーダーとなるサイズ。
  /// 表示範囲の縦または横のサイズがこれを下回るとスマホ向けレイアウトになる。
  static const double breakPointForDesktop = 440;

  /// サイズ情報を取得するためのファクトリーコンストラクタ
  factory DimensionInfo._of(_DimensionInfoParam param) {
    if (param.type == DimensionType.phone) {
      return DimensionInfo._phone();
    }
    return DimensionInfo._large();
  }

  factory DimensionInfo._phone() {
    return const DimensionInfo._(
      type: DimensionType.phone,
      appBarFontSize: 24,
      appBarIconSize: 40,
      smallFontSize: 12,
      normalFontSize: 16,
      largeFontSize: 24,
      smallestGap: 2,
      smallGap: 4,
      normalGap: 8,
      largeGap: 12,
      dropdownMenu: DropdownMenuInfo._(
        titleFontSize: 32,
        userFontSize: 12,
        versionFontSize: 12,
        iconSize: 40,
        width: 280,
        radius: 4,
        itemIconSize: 24,
        itemFontSize: 16,
      ),
      markerEditUI: MarkerEditApplyUiInfo._(
        buttonWidth: 80,
        buttonHeight: 56,
        buttonFontSize: -1,
        buttonIconSize: 26,
        centerGapSize: 140,
        crossHairSize: 80,
        tipsFontSize: 18,
        tipsIconSize: 22,
        tipsTopMargin: 20,
      ),
      mapMarker: MapMarkerInfo._(
        width: 110,
        height: 80,
        iconSize: 32,
        fontSize: 16,
        textBorderWidth: 2,
        gap: 2,
        clusterSize: 20,
      ),
      mapItemAddUI: MapItemAddUiInfo._(
        modeSwitchWidth: 64,
        modeSwitchHeight: 52,
        modeSwitchIconSize: 32,
        buttonSize: 52,
        buttonIconSize: 32,
        breakPointHeightForAvoidShrink: 410,
        breakPointHeightForUseHorizontal: 466,
      ),
      mapControlUI: MapControlUiInfo._(
        scaleButtonSize: 42,
        scaleButtonIconSize: 24,
        scaleButtonGap: 16,
        currentLocationButtonSize: 52,
        currentLocationButtonIconSize: 28,
        currentLocationButtonGap: 24,
        breakPointHeightForUseHorizontal: 330,
      ),
      editDialogUI: ItemEditDialogUiInfo._(
        minImageSize: 160,
        itemGap: 8,
        horizontalPadding: 16,
        headerHeight: 80,
        headerTitleFontSize: 20,
        headerTitlePositionTop: 44,
        headerTitlePositionLeft: 36,
        buttonIconSize: 44,
        buttonPositionTop: 4,
        buttonPositionRight: 36,
        buttonGap: 12,
        dialogButtonWidth: 180,
        dialogButtonHeight: 40,
      ),
      authEditUI: AuthorizationEditUiInfo(
        hintFontSize: 12,
        messageFontSize: 12,
        stateIconSize: 32,
        cardHeight: 80,
        regDateFontSize: 10,
        userIdFontSize: 16,
        dialogButtonWidth: 180,
        dialogButtonHeight: 40,
      ),
      loginUI: LoginUiInfo(
        containerVerticalMargin: 16,
        containerHorizontalMargin: 32,
        versionFontSize: 10,
        maxContainerWidth: 400,
        buttonWidth: 180,
        buttonHeight: 40,
        passwdResetFontSize: 12,
        snackbarIconSize: 32,
      ),
      systemUpdateNotificationButton: SystemUpdateNotificationButtonInfo(
        buttonSize: 52,
        buttonIconSize: 20,
        paddingLeft: 0,
        paddingTop: 20,
        dialogButtonWidth: 180,
        dialogButtonHeight: 40,
      ),
    );
  }

  factory DimensionInfo._large() {
    return const DimensionInfo._(
      type: DimensionType.large,
      appBarFontSize: 28,
      appBarIconSize: 44,
      smallFontSize: 16,
      normalFontSize: 20,
      largeFontSize: 32,
      smallestGap: 3,
      smallGap: 6,
      normalGap: 12,
      largeGap: 18,
      dropdownMenu: DropdownMenuInfo._(
        titleFontSize: 40,
        userFontSize: 16,
        versionFontSize: 16,
        iconSize: 44,
        width: 360,
        radius: 6,
        itemIconSize: 32,
        itemFontSize: 20,
      ),
      markerEditUI: MarkerEditApplyUiInfo._(
        buttonWidth: 172,
        buttonHeight: 80,
        buttonFontSize: 22,
        buttonIconSize: 28,
        centerGapSize: 140,
        crossHairSize: 80,
        tipsFontSize: 24,
        tipsIconSize: 28,
        tipsTopMargin: 60,
      ),
      mapMarker: MapMarkerInfo._(
        width: 130,
        height: 100,
        iconSize: 40,
        fontSize: 20,
        textBorderWidth: 3,
        gap: 3,
        clusterSize: 28,
      ),
      mapItemAddUI: MapItemAddUiInfo._(
        modeSwitchWidth: 88,
        modeSwitchHeight: 72,
        modeSwitchIconSize: 40,
        buttonSize: 72,
        buttonIconSize: 32,
        breakPointHeightForAvoidShrink: 540,
        breakPointHeightForUseHorizontal: 610,
      ),
      mapControlUI: MapControlUiInfo._(
        scaleButtonSize: 56,
        scaleButtonIconSize: 24,
        scaleButtonGap: 24,
        currentLocationButtonSize: 72,
        currentLocationButtonIconSize: 28,
        currentLocationButtonGap: 36,
        breakPointHeightForUseHorizontal: 410,
      ),
      editDialogUI: ItemEditDialogUiInfo._(
        minImageSize: 240,
        itemGap: 8,
        horizontalPadding: 20,
        headerHeight: 100,
        headerTitleFontSize: 24,
        headerTitlePositionTop: 56,
        headerTitlePositionLeft: 44,
        buttonIconSize: 56,
        buttonPositionTop: 4,
        buttonPositionRight: 44,
        buttonGap: 16,
        dialogButtonWidth: 200,
        dialogButtonHeight: 52,
      ),
      authEditUI: AuthorizationEditUiInfo(
        hintFontSize: 16,
        messageFontSize: 16,
        stateIconSize: 40,
        cardHeight: 120,
        regDateFontSize: 16,
        userIdFontSize: 20,
        dialogButtonWidth: 200,
        dialogButtonHeight: 52,
      ),
      loginUI: LoginUiInfo(
        containerVerticalMargin: 20,
        containerHorizontalMargin: 40,
        versionFontSize: 16,
        maxContainerWidth: 640,
        buttonWidth: 200,
        buttonHeight: 52,
        passwdResetFontSize: 16,
        snackbarIconSize: 40,
      ),
      systemUpdateNotificationButton: SystemUpdateNotificationButtonInfo(
        buttonSize: 72,
        buttonIconSize: 32,
        paddingLeft: 4,
        paddingTop: 52,
        dialogButtonWidth: 200,
        dialogButtonHeight: 52,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DimensionInfo &&
          runtimeType == other.runtimeType &&
          type == other.type);

  @override
  int get hashCode {
    return type.name.hashCode;
  }
}
