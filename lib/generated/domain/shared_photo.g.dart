// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../domain/shared_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedPhotoImpl _$$SharedPhotoImplFromJson(Map<String, dynamic> json) =>
    _$SharedPhotoImpl(
      recordId: json['record_id'] as int,
      name: json['name'] as String,
      coordinate: LatLng.fromJson(json['coordinate'] as Map<String, dynamic>),
      memo: json['memo'] as String? ?? null,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: json['created_at'] == null
          ? null
          : TimestampUtil.dateFromTimestampValue(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? null
          : TimestampUtil.dateFromTimestampValue(json['updated_at']),
      updatedBy: json['updated_by'] as String? ?? null,
    );

Map<String, dynamic> _$$SharedPhotoImplToJson(_$SharedPhotoImpl instance) =>
    <String, dynamic>{
      'record_id': instance.recordId,
      'name': instance.name,
      'coordinate': instance.coordinate,
      'memo': instance.memo,
      'photos': instance.photos,
      'created_at': TimestampUtil.timestampFromDateValue(instance.createdAt),
      'updated_at': TimestampUtil.timestampFromDateValue(instance.updatedAt),
      'updated_by': instance.updatedBy,
    };
