import 'package:flutter/material.dart';
import 'package:photo_share_capp/domain/map/map_tile_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../theme/custom_color.g.dart';
import '../../theme/dimension_info.dart';

class MapLicenseLinkedText extends StatelessWidget {
  const MapLicenseLinkedText(
    this.dimensionInfo,
    this.tileInfo, {
    super.key,
  });

  final DimensionInfo dimensionInfo;
  final MapTileInfo tileInfo;

  static const String _copyrightMark = '© ';

  @override
  Widget build(BuildContext context) {
    void onSourceTapped() {
      launchUrlString(tileInfo.licensePageUrl);
    }

    final linkedTextColor =
        Theme.of(context).extension<CustomColors>()?.linkedText;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final containerColor = Theme.of(context).colorScheme.surface.withAlpha(180);

    return Padding(
      padding: EdgeInsets.only(
        bottom: dimensionInfo.smallGap,
        left: dimensionInfo.smallGap,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(dimensionInfo.normalGap),
          ),
          child: GestureDetector(
            onTap: onSourceTapped,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: dimensionInfo.smallGap,
                horizontal: dimensionInfo.normalGap,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: textColor,
                  fontSize: dimensionInfo.smallFontSize,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(_copyrightMark),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        tileInfo.creditText,
                        style: TextStyle(color: linkedTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
