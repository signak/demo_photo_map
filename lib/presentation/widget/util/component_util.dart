import 'package:flutter/material.dart';

import '../../theme/dimension_info.dart';

class ComponentUtil {
  const ComponentUtil._();

  /// マーカーの追加・移動中に表示する決定・キャンセルボタンを構築する。
  static Widget buildMarkerEditApplyButton({
    required String key,
    required ThemeData theme,
    required DimensionInfo dimensionInfo,
    required String buttonText,
    Function()? onPressed,
    required IconData iconData,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final fontSize = dimensionInfo.markerEditUI.buttonFontSize;
    final iconSize = dimensionInfo.markerEditUI.buttonIconSize;

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(dimensionInfo.normalGap),
      side: BorderSide(color: foregroundColor),
    );

    final icon = Icon(
      iconData,
      color: foregroundColor,
      size: iconSize,
    );

    final fixedButtonSize = Size(
      dimensionInfo.markerEditUI.buttonWidth,
      dimensionInfo.markerEditUI.buttonHeight,
    );

    if (dimensionInfo.markerEditUI.isIconOnly) {
      final iconButtonStyle = IconButton.styleFrom(
        shape: buttonShape,
        backgroundColor: backgroundColor,
        fixedSize: fixedButtonSize,
        iconSize: iconSize,
        alignment: Alignment.center,
      );
      return IconButton(
        onPressed: onPressed,
        icon: icon,
        style: iconButtonStyle,
      );
    } else {
      final elevatedButtonStyle = ElevatedButton.styleFrom(
        shape: buttonShape,
        backgroundColor: backgroundColor,
        fixedSize: fixedButtonSize,
        alignment: Alignment.center,
      );
      return ElevatedButton.icon(
        key: Key(key),
        onPressed: onPressed,
        style: elevatedButtonStyle,
        icon: icon,
        label: Padding(
          padding: EdgeInsets.all(dimensionInfo.largeGap)
              .copyWith(left: dimensionInfo.smallGap),
          child: Text(
            buttonText,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontSize: fontSize,
                ) ??
                TextStyle(
                  color: foregroundColor,
                  fontSize: fontSize,
                ),
          ),
        ),
      );
    }
  }

  /// サイズを指定してFloatingActionButtonを作成する。<br>
  /// [roundedBorderRadius]に数値を指定した場合はその数値で角を丸めた四角ボタン、
  /// 省略した場合は丸ボタンになる。
  static Widget buildSizedFloatingActionButton({
    required String key,
    Function()? onPressed,
    Color? backgroundColor,
    required IconData iconData,
    Color? iconColor,
    double? roundedBorderRadius,
    required double buttonSize,
    required double iconSize,
  }) {
    final ShapeBorder? shape = (roundedBorderRadius == null)
        ? null
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundedBorderRadius),
          );

    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: FittedBox(
        fit: BoxFit.fill,
        // アイコンとボタン枠のPaddingがThemeでしか制御できないので、
        // _FloatingActionButtonType.small を指定して、
        // ボタン枠のBoxConstraintsの方を小さくする
        child: FloatingActionButton.small(
          heroTag: key,
          onPressed: onPressed,
          shape: shape,
          backgroundColor: backgroundColor,
          child: Icon(
            iconData,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  /// サイズを指定してSwitchを作成する。
  static Widget buildSizedSwitch({
    bool initialValue = false,
    Function(bool)? onChanged,
    required double switchWidth,
    required double switchHeight,
    Color? activeTrackColor,
    Color? activeColor,
    Color? inactiveTrackColor,
    Color? inactiveThumbColor,
  }) {
    return SizedBox(
      width: switchWidth,
      height: switchHeight,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch(
          value: initialValue,
          onChanged: onChanged,
          activeTrackColor: activeTrackColor,
          activeColor: activeColor,
          inactiveTrackColor: inactiveTrackColor,
          inactiveThumbColor: inactiveThumbColor,
        ),
      ),
    );
  }
}
