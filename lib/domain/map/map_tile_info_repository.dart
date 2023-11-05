import 'map_tile_info.dart';

abstract class MapTileInfoRepository {
  Stream<List<MapTileInfo>> watchTiles({
    bool includeDisabledInfos = false,
  });
}
