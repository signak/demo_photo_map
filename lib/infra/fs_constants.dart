/// 地点情報ドキュメント属性名
class FsSharedPhotos {
  /// コレクション名
  static const collectionName = 'shared_photos';

  /// レコードID
  static const id = 'id';

  /// 名称
  static const name = 'name';

  /// 備考
  static const memo = 'memo';

  /// 座標
  static const coordinate = 'coordinate';

  /// 写真パスリスト
  static const images = 'images';

  /// 作成日
  static const createdAt = 'created_at';

  /// 更新日
  static const updatedAt = 'updated_at';

  /// 更新者UID
  static const updatedBy = 'updated_by';
}

/// 地点情報サマリードキュメント属性名
class FsSharedPhotoSummary {
  /// コレクション名
  static const collectionName = 'shared_photo_summary';

  /// ドキュメント名（1ドキュメントしか存在しない）
  static const documentName = 'summary';

  /// レコードID（※1レコードしか存在しないので常に1）
  static const id = 'id';

  /// データ定義バージョン
  static const structuralVersion = 'structural_version';

  /// 最終共有写真レコードID
  static const lastRecordId = 'last_shared_photo_id';

  /// 作成日
  static const createdAt = 'created_at';

  /// 更新日
  static const updatedAt = 'updated_at';

  /// 更新者UID
  static const updatedBy = 'updated_by';
}

class FsSharedPhotoStorage {
  /// ルートフォルダ名
  static const rootFolderName = 'shared_photos';
}

/// MapTile情報ドキュメント属性名
class FsMapTiles {
  /// コレクション名
  static const collectionName = 'map_tiles';

  /// レコードID
  static const id = 'id';

  /// 当システム上での表示順
  static const tileIndex = 'tile_index';

  /// 名称
  static const name = 'name';

  /// Tile URI
  static const tileUri = 'tile_uri';

  /// クレジット表記名
  static const creditText = 'credit_text';

  /// ライセンスページURL
  static const licensePageUrl = 'license_page_url';

  /// 当システム上での利用可否
  static const enabled = 'enabled';

  /// 当システム上でのシステム初期表示タイルか否か
  static const defaultTile = 'default_tile';

  /// 作成日
  static const createdAt = 'created_at';

  /// 更新日
  static const updatedAt = 'updated_at';

  /// 更新者UID
  static const updatedBy = 'updated_by';
}
