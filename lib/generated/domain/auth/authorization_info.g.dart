// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../domain/auth/authorization_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizationInfoImpl _$$AuthorizationInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthorizationInfoImpl(
      uid: json['uid'] as String,
      id: json['id'] as String? ?? null,
      isSystemAdmin: json['is_system_admin'] as bool? ?? false,
      isAuthorizationAdmin: json['is_authorization_admin'] as bool? ?? false,
      isObservationPointMaintainer:
          json['is_observation_point_maintainer'] as bool? ?? false,
      canRead: json['can_read'] as bool? ?? false,
      canWrite: json['can_write'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : TimestampUtil.dateFromTimestampValue(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? null
          : TimestampUtil.dateFromTimestampValue(json['updated_at']),
      updatedBy: json['updated_by'] as String? ?? null,
    );

Map<String, dynamic> _$$AuthorizationInfoImplToJson(
        _$AuthorizationInfoImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'id': instance.id,
      'is_system_admin': instance.isSystemAdmin,
      'is_authorization_admin': instance.isAuthorizationAdmin,
      'is_observation_point_maintainer': instance.isObservationPointMaintainer,
      'can_read': instance.canRead,
      'can_write': instance.canWrite,
      'created_at': TimestampUtil.timestampFromDateValue(instance.createdAt),
      'updated_at': TimestampUtil.timestampFromDateValue(instance.updatedAt),
      'updated_by': instance.updatedBy,
    };
