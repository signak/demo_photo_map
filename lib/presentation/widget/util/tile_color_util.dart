import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class TileColorUtil {
  const TileColorUtil._();

  static Widget grayScale(
    BuildContext context,
    Widget tileWidget,
    Tile tile,
  ) {
    const ColorFilter grayScale = ColorFilter.matrix(<double>[
      // gray scale filter
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]);
    return ColorFiltered(
      colorFilter: grayScale,
      child: tileWidget,
    );
  }

  static Widget invert(
    BuildContext context,
    Widget tileWidget,
    Tile tile,
  ) {
    const ColorFilter invertFilter = ColorFilter.matrix(<double>[
      // invert filter
      -1.0, 0.0, 0.0, 0.0, 255.0,
      0.0, -1.0, 0.0, 0.0, 255.0,
      0.0, 0.0, -1.0, 0.0, 255.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]);
    return ColorFiltered(
      colorFilter: invertFilter,
      child: tileWidget,
    );
  }
}
