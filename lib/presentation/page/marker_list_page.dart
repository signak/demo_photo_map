import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/extension/sliver_list_ex.dart';
import '../../domain/shared_photo.dart';
import '../service/map_marker_service.dart';
import '../theme/dimension_info.dart';

class MarkerListWidget extends HookConsumerWidget {
  const MarkerListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final dimensInfo = DimensionUtil.getInfo(context, ref);

    final appBarForegroundColor =
        Theme.of(context).colorScheme.onSecondaryContainer;
    final appBarBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final subtitleTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final appBar = AppBar(
      title: const Text('Marker List'),
      titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(
            color: appBarForegroundColor,
            fontWeight: FontWeight.bold,
            fontSize: dimensInfo.appBarFontSize,
          ),
      // elevation: 0,
      // automaticallyImplyLeading: false,
      foregroundColor: appBarForegroundColor,
      backgroundColor: appBarBackgroundColor.withOpacity(0.5),
      iconTheme: IconThemeData(color: appBarForegroundColor),
    );

    final appBarHeight = appBar.preferredSize.height;

    final presentYearFormat = DateFormat('MM月dd日').format;
    final otherYearFormat = DateFormat('yyyy年MM月dd日').format;
    String formatUpdatedAt(DateTime updatedAt) {
      final currentYear = DateTime.now().year;
      if (updatedAt.year == currentYear) {
        return presentYearFormat(updatedAt);
      }
      return otherYearFormat(updatedAt);
    }

    void back(BuildContext context, {LatLng? result}) {
      Navigator.pop(context, result);
    }

    Widget buildItem(BuildContext context, int index, SharedPhoto attrs) {
      final memo = (attrs.memo ?? '').trim();
      final additionalInfos = <Widget>[];
      if (memo.isNotEmpty) {
        additionalInfos.add(Text(memo));
        additionalInfos.add(Gap(dimensInfo.largeGap));
      }
      additionalInfos.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '写真: ${(attrs.photos.isEmpty) ? "なし" : "${attrs.photos.length}枚"}',
            ),
            Gap(dimensInfo.largeGap),
            Expanded(
              child: Text(
                '更新日: ${formatUpdatedAt(attrs.updatedAt!)}',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );

      return InkWell(
        key: Key('markers[${attrs.recordId}]'),
        onTap: () {
          back(context, result: attrs.coordinate);
        },
        child: ListTile(
          leading: (attrs.photos.isEmpty)
              ? const Icon(Icons.location_pin)
              : const Icon(Icons.photo_library_outlined),
          title: Text(attrs.name,
              style: TextStyle(
                fontSize: dimensInfo.normalFontSize,
              )),
          subtitle: Padding(
            padding: EdgeInsets.all(dimensInfo.normalGap).copyWith(left: 0),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: dimensInfo.smallFontSize,
                color: subtitleTextColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: additionalInfos,
              ),
            ),
          ),
        ),
      );
    }

    Widget buildMarkerList() {
      final snapshot = useStream(ref.read(mapMarkerServiceProvider).stream);
      if (snapshot.hasData) {
        final markers = snapshot.data!.params;
        return SliverListEx.separated(
          itemCount: markers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final marker = markers[index];
            return buildItem(context, index, marker.attrs);
          },
        );
      }
      return const SliverToBoxAdapter(child: Center(child: Text('no marker')));
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(screenSize.width, DimensionInfo.breakPoint),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            appBar: appBar,
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 背景グラデーション
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
                // マーカーリスト
                Align(
                    alignment: Alignment.topCenter,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                            padding: EdgeInsets.all(dimensInfo.largeGap)
                                .copyWith(
                                    top: appBarHeight + dimensInfo.largeGap),
                            sliver: buildMarkerList())
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
