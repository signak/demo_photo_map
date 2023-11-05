import 'dart:async';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/extension/disposable_extension.dart';
import '../../../core/util/logger.dart';
import '../../../domain/map/map_tile_info.dart';
import '../../../domain/marker_param.dart';
import '../../../domain/shared_photo.dart';
import '../../../route/routes.dart';
import '../../service/auth/auth_state_service.dart';
import '../../service/map_marker_service.dart';
import '../../service/map_tile_info_service.dart';
import '../../theme/custom_color.g.dart';
import '../../theme/dimension_info.dart';
import 'animated_map_controller.dart';
import 'map_control_buttons.dart';
import 'map_control_state.dart';
import 'map_control_state_provider.dart';
import 'map_item_add_buttons.dart';
import 'map_item_add_mode_switch.dart';
import 'map_license_linked_text.dart';
import 'map_marker_add_overlay_ui.dart';
import 'map_marker_edit_tips_overlay_text.dart';
import 'map_marker_move_overlay_ui.dart';
import 'selected_marker_notifier_provider.dart';

class JapanBounds {
  static const double east = 153.9866667;
  static const double west = 122.9325;
  static const double north = 45.5572222;
  static const double south = 20.4252778;

  static LatLngBounds getBounds() {
    return LatLngBounds(
      LatLng(north, west),
      LatLng(south, east),
    );
  }
}

final _japanBoundsProvider = Provider<LatLngBounds>(
  (ref) => JapanBounds.getBounds(),
);

final _followZoomLevelStreamProvider =
    Provider<StreamController<double?>>((ref) => BehaviorSubject<double?>());

final moveCenterLocationStreamProvider =
    Provider<StreamController<LatLng?>>((ref) => BehaviorSubject<LatLng?>());

class MapViewWidget extends ConsumerStatefulWidget {
  /// required [appBarHeight] if use [AppBar.extendBodyBehindAppBar].
  const MapViewWidget(this.mapHeight, {super.key, this.appBarHeight = 0});
  final double appBarHeight;
  final double mapHeight;

  @override
  ConsumerState<MapViewWidget> createState() {
    return _MapViewState();
  }
}

class _MapViewState extends ConsumerState<MapViewWidget>
    with TickerProviderStateMixin, DisposableWidget {
  late final AnimatedMapController _animatedMapController;
  late final StreamController<LatLng?> _moveCenterLocationController;

  static const double _initialLatitude = 36.370888159377344;
  static const double _initialLongitude = 140.47618386701245;
  static const double _defaultZoomLevel = 16;
  static const double _defaultZoomLevelOfSelectByMarkerList = 17;

  @override
  void initState() {
    super.initState();

    _animatedMapController = AnimatedMapController(MapController(), this);
    _moveCenterLocationController = ref.read(moveCenterLocationStreamProvider);
    _moveCenterLocationController.stream.listen(
      (point) {
        if (point == null) {
          return;
        }

        final mapControlStateNotifier =
            ref.read(mapControlStateProvider.notifier);
        mapControlStateNotifier.stopCurrentLocationFollowing();
        _animatedMapController.moveWithAnimation(
            point, _defaultZoomLevelOfSelectByMarkerList);
      },
    ).disposedBy(this);
  }

  @override
  void dispose() {
    disposeManagedObjects();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapTileInfoService = ref.read(mapTileInfoServiceProvider);
    final tile = mapTileInfoService.tiles.first;

    // TODO [低] ユーザー設定を元にどのタイルか選択する。authState.currentTileIndexとか。

    return _build(context, tile);
  }

  Widget _build(BuildContext context, MapTileInfo tileInfo) {
    final mapControlState = ref.watch(mapControlStateProvider);
    final mapControlStateNotifier = ref.watch(mapControlStateProvider.notifier);
    final selectedMarkerStateNotifier =
        ref.watch(selectedMarkerStateProvider.notifier);
    final mapMarkerService = ref.read(mapMarkerServiceProvider);
    final japanBounds = ref.read(_japanBoundsProvider);
    final followZoomLevelStream = ref.read(_followZoomLevelStreamProvider);
    final bool isSystemAdmin =
        ref.read(authStateNotifierProvider)?.isSystemAdmin ?? false;
    final dimensionInfo = DimensionUtil.getInfo(context, ref);

    /// マップ表示完了時に初期表示位置に表示範囲を移動する
    void onMapReadyCallback() {
      _animatedMapController.moveWithAnimation(
          LatLng(_initialLatitude, _initialLongitude), _defaultZoomLevel);
    }

    /// マップのなにもない場所をロングタップした時の処理を行う。
    /// 地物の新規追加モードではない時に限り、新規追加モードに移行する。
    void onMapLongPress(TapPosition tapPosition, LatLng point) {
      if (!mapControlState.isItemAdding) {
        _animatedMapController.moveWithAnimation(
            point, _animatedMapController.zoom);
        mapControlStateNotifier.startItemAdding();
      }
    }

    /// 表示位置が変わった場合の処理を行う。
    /// ユーザーの操作で表示位置が変わった場合に限り、現在地追従を止める。
    void onPositionChanged(MapPosition position, bool hasGesture) {
      if (hasGesture) {
        if (mapControlState.isFollowing()) {
          mapControlStateNotifier.stopCurrentLocationFollowing();
        }
      }
    }

    /// マップのマーカーがない場所をタップしたら編集モードを終了する。
    void onTap(TapPosition tapPos, LatLng location) {
      if (mapControlState.isItemEditing) {
        mapControlStateNotifier.completeItemEditing();
      }
    }

    List<Marker> createMarkers(
        WidgetRef ref, List<MarkerParam<SharedPhoto>>? markerParams) {
      if (markerParams == null) return [];

      final theme = Theme.of(context);
      final customColors = theme.extension<CustomColors>()!;

      return markerParams.map<Marker>((p) {
        final id = p.attrs.recordId;
        final point = LatLng(p.latitude, p.longitude);
        return Marker(
          key: Key('$id'),
          point: point,
          width: dimensionInfo.mapMarker.width,
          height: dimensionInfo.mapMarker.height,
          builder: (context) {
            return _MapMarkerWidget(
              key: Key('MapMarkerWidget_$id'),
              animatedMapController: _animatedMapController,
              mapControlState: mapControlState,
              mapControlStateNotifier: mapControlStateNotifier,
              selectedMarkerStateNotifier: selectedMarkerStateNotifier,
              item: p,
              point: point,
              textBorderColor: theme.colorScheme.surface,
              textColor: theme.colorScheme.onSurface,
              markerColor: customColors.sourceMapMarker!,
              dimensionInfo: dimensionInfo,
            );
          },
        );
      }).toList();
    }

    Widget? getAddModeSwitch() {
      if (mapControlState.isItemAdding ||
          mapControlState.isItemEditing ||
          mapControlState.isItemMoving) {
        return null;
      }
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(dimensionInfo.normalGap).copyWith(
            top: dimensionInfo.normalGap + widget.appBarHeight,
          ),
          child: const MapItemAddModeSwitch(),
        ),
      );
    }

    Widget? getAddMarkerUI() {
      if (mapControlState.isItemAdding ||
          mapControlState.isItemEditing ||
          mapControlState.isItemMoving) {
        return null;
      }
      return MapItemAddButtons(
        _animatedMapController,
        dimensionInfo: dimensionInfo,
        appBarHeight: widget.appBarHeight,
      );
    }

    List<Widget> getOverlayUI() {
      if (mapControlState.isItemAdding || mapControlState.isItemMoving) {
        return <Widget>[
          MapMarkerEditTipsOverlayText(appBarHeight: widget.appBarHeight),
          (mapControlState.isItemAdding)
              ? MapMarkerAddOverlayUI(_animatedMapController)
              : MapMarkerMoveOverlayUI(_animatedMapController),
        ];
      } else {
        return [
          MapControlButtons(
            _animatedMapController,
            followZoomLevelStream,
            dimensionInfo: dimensionInfo,
            appBarHeight: widget.appBarHeight,
          )
        ];
      }
    }

    final nonRotatedWidgets = <Widget>[
      ...getOverlayUI(),
      MapLicenseLinkedText(dimensionInfo, tileInfo),
    ];

    if (isSystemAdmin || kDebugMode) {
      nonRotatedWidgets.add(const _DebugInfoWidget());
    }

    final markerAddUI = getAddMarkerUI();
    if (markerAddUI != null) {
      nonRotatedWidgets.insert(0, markerAddUI);
    }

    final modeSwitch = getAddModeSwitch();
    if (modeSwitch != null) {
      nonRotatedWidgets.insert(0, modeSwitch);
    }

    TileBuilder? getTileBuilder() {
      // TODO [中] ユーザーの色設定に従って変更する。
      // ThemeのLight/Darkにも依存するかは検討。依存するなら、reversedDarkも必要
      // final themeMode = Theme.of(context).extension<app_theme.ThemeMode>()!;
      // switch (mapTileColorMode) {
      //   case MapTileColorMode.grayScale:
      //     return TileUtil.toGrayScale;
      //   case MapTileColorMode.reversed:
      //     return TileUtil.toReversedColor;
      //   default: //
      //     return null;
      // }
      return null;
    }

    return StreamBuilder(
        stream: mapMarkerService.stream,
        builder: (context, snapshot) {
          final markers = createMarkers(ref, snapshot.data?.params);

          final markerLayer = MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              markers: markers,
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          dimensionInfo.mapMarker.clusterSize),
                      color: Theme.of(context).colorScheme.tertiary),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                  ),
                );
              },
            ),
          );

          return SizedBox(
            height: widget.mapHeight,
            child: FlutterMap(
              mapController: _animatedMapController,
              options: MapOptions(
                center: LatLng(_initialLatitude, _initialLongitude),
                keepAlive: true,
                maxBounds: japanBounds,
                zoom: 10,
                minZoom: 6,
                maxZoom: 19,
                interactiveFlags: InteractiveFlag.all &
                    ~InteractiveFlag.rotate &
                    ~InteractiveFlag.pinchMove,
                onMapReady: onMapReadyCallback,
                onTap: onTap,
                onLongPress: onMapLongPress,
                onPositionChanged: onPositionChanged,
              ),
              nonRotatedChildren: nonRotatedWidgets,
              children: [
                TileLayer(
                  urlTemplate: tileInfo.tileUri,
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'app.web.photo-share-capp',
                  maxZoom: 19,
                  tileBounds: japanBounds,
                  tileBuilder: getTileBuilder(),
                ),
                CurrentLocationLayer(
                  followOnLocationUpdate: mapControlState.locationUpdating,
                  followCurrentLocationStream: followZoomLevelStream.stream,
                ),
                markerLayer,
              ],
            ),
          );
        });
  }
}

class _MapMarkerWidget extends StatelessWidget {
  const _MapMarkerWidget({
    super.key,
    required AnimatedMapController animatedMapController,
    required MapControlState mapControlState,
    required MapControlStateNotifier mapControlStateNotifier,
    required SelectedMarkerStateNotifier selectedMarkerStateNotifier,
    required MarkerParam<SharedPhoto> item,
    required LatLng point,
    required Color textBorderColor,
    required Color textColor,
    required Color markerColor,
    required DimensionInfo dimensionInfo,
  })  : _animatedMapController = animatedMapController,
        _mapControlState = mapControlState,
        _mapControlStateNotifier = mapControlStateNotifier,
        _selectedMarkerStateNotifier = selectedMarkerStateNotifier,
        _item = item,
        _point = point,
        _textBorderColor = textBorderColor,
        _textColor = textColor,
        _markerColor = markerColor,
        _dimensionInfo = dimensionInfo;

  final AnimatedMapController _animatedMapController;
  final MapControlState _mapControlState;
  final MapControlStateNotifier _mapControlStateNotifier;
  final SelectedMarkerStateNotifier _selectedMarkerStateNotifier;

  final MarkerParam<SharedPhoto> _item;
  final LatLng _point;

  final Color _textBorderColor;
  final Color _textColor;
  final Color _markerColor;

  final DimensionInfo _dimensionInfo;

  int get _id => _item.attrs.recordId;

  @override
  Widget build(BuildContext context) {
    // Iconを画像にする場合はキャッシュして使う
    // https://www.coletiv.com/blog/use-network-images-as-marker-icons-flutter-google-maps/
    return GestureDetector(
      onTap: () {
        logger.d("onTapItem: index=$_id");
        if (_mapControlState.isItemAdding || _mapControlState.isItemMoving) {
          return;
        }

        _animatedMapController.moveWithAnimation(
            _point, _animatedMapController.zoom);
        _selectedMarkerStateNotifier.select(_item);
        _mapControlStateNotifier.startItemEditing();
        GoRouter.of(context)
            .pushNamed(ReleaseRoutes.edit.name, params: {'id': '$_id'});
      },
      onLongPress: () {
        logger.d("onLongPressItem: index=$_id");
        if (_mapControlState.isItemAdding || _mapControlState.isItemMoving) {
          return;
        }

        _animatedMapController.moveWithAnimation(
            _point, _animatedMapController.zoom);
        _selectedMarkerStateNotifier.select(_item);
        _mapControlStateNotifier.startItemMoving();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          BorderedText(
            strokeWidth: _dimensionInfo.mapMarker.textBorderWidth,
            strokeColor: _textBorderColor,
            child: Text(
              _item.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textColor,
                fontSize: _dimensionInfo.mapMarker.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Gap(_dimensionInfo.mapMarker.gap),
          Icon(
            Icons.location_pin,
            color: _markerColor,
            size: _dimensionInfo.mapMarker.iconSize,
          ),
        ],
      ),
    );
  }
}

class _DebugInfoWidget extends HookConsumerWidget {
  const _DebugInfoWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(mapControlStateProvider);
    final Size screenSize = MediaQuery.of(context).size;
    final dimensionInfo = DimensionUtil.getInfo(context, ref);
    final typeName = dimensionInfo.type.name;
    final bool isSystemAdmin =
        ref.watch(authStateNotifierProvider)?.isSystemAdmin ?? false;

    if (!kDebugMode && !isSystemAdmin) {
      return const SizedBox.shrink();
    }

    final String text = '[Information for development]\n'
        'ui_mode: ${mode.mode}, layout=$typeName,\n'
        'sw=${screenSize.width}, sh=${screenSize.height},';

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.primaryContainer;
    final textColor = colorScheme.onPrimaryContainer;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.all(dimensionInfo.smallGap)
            .copyWith(bottom: 40, right: 80),
        padding: EdgeInsets.symmetric(
          vertical: dimensionInfo.normalGap,
          horizontal: dimensionInfo.largeGap,
        ),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(dimensionInfo.normalGap),
          border: Border.all(color: textColor),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dimensionInfo.largeGap),
          child: Text(
            text,
            style: DefaultTextStyle.of(context).style.copyWith(
                  color: textColor,
                  fontSize: dimensionInfo.smallFontSize,
                ),
          ),
        ),
      ),
    );
  }
}
