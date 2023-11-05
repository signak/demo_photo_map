import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/map/map_tile_info.dart';

final mapTileInfoServiceProvider = Provider<MapTileInfoService>(
  (ref) =>
      throw UnimplementedError('should override mapTileInfoServiceProvider.'),
);

class MapTileInfoService {
  MapTileInfoService(List<MapTileInfo> tiles) : _tiles = tiles;

  final List<MapTileInfo> _tiles;

  List<MapTileInfo> get tiles => _tiles;
}
