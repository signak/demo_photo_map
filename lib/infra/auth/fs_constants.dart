/// 認可情報ドキュメント属性名
class FsAuthorizations {
  /// コレクション名
  static const collectionName = 'user_authorizations';

  /// UID
  static const uid = 'uid';

  /// ID (email)
  static const id = 'id';

  /// システム管理者
  static const systemAdmin = 'system_admin';

  /// 認可情報管理者
  static const authorizationAdmin = 'authorization_admin';

  /// 観測点マスターデータ編集者
  static const observationPointMaintainer = 'observation_point_maintainer';

  /// 観測データ読み取り許可
  static const allowReadObservationData = 'allow_read_observation_data';

  /// 観測データ書き込み許可
  static const allowWriteObservationData = 'allow_write_observation_data';

  /// 作成日
  static const createdAt = 'created_at';

  /// 更新日
  static const updatedAt = 'updated_at';

  /// 更新者UID
  static const updatedBy = 'updated_by';
}
