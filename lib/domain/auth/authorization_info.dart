import 'package:flutter/foundation.dart'; // ignore: unused_import
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../infra/util/timestamp_util.dart';

part '../../generated/domain/auth/authorization_info.freezed.dart';
part '../../generated/domain/auth/authorization_info.g.dart';

@freezed
class AuthorizationInfo with _$AuthorizationInfo {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AuthorizationInfo({
    required String uid,
    @Default(null) String? id,
    @Default(false) bool isSystemAdmin,
    @Default(false) bool isAuthorizationAdmin,
    @Default(false) bool isObservationPointMaintainer,
    @Default(false) bool canRead,
    @Default(false) bool canWrite,
    @Default(null) @timestampJsonKey DateTime? createdAt,
    @Default(null) @timestampJsonKey DateTime? updatedAt,
    @Default(null) String? updatedBy,
  }) = _AuthorizationInfo;

  const AuthorizationInfo._();

  factory AuthorizationInfo.nodata(String uid) => AuthorizationInfo(uid: uid);

  factory AuthorizationInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationInfoFromJson(json);

  bool get exists => (id != null);
}
