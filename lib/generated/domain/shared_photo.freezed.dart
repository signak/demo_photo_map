// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../domain/shared_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SharedPhoto _$SharedPhotoFromJson(Map<String, dynamic> json) {
  return _SharedPhoto.fromJson(json);
}

/// @nodoc
mixin _$SharedPhoto {
  int get recordId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  LatLng get coordinate => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  @timestampJsonKey
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @timestampJsonKey
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SharedPhotoCopyWith<SharedPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedPhotoCopyWith<$Res> {
  factory $SharedPhotoCopyWith(
          SharedPhoto value, $Res Function(SharedPhoto) then) =
      _$SharedPhotoCopyWithImpl<$Res, SharedPhoto>;
  @useResult
  $Res call(
      {int recordId,
      String name,
      LatLng coordinate,
      String? memo,
      List<String> photos,
      @timestampJsonKey DateTime? createdAt,
      @timestampJsonKey DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class _$SharedPhotoCopyWithImpl<$Res, $Val extends SharedPhoto>
    implements $SharedPhotoCopyWith<$Res> {
  _$SharedPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordId = null,
    Object? name = null,
    Object? coordinate = null,
    Object? memo = freezed,
    Object? photos = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      recordId: null == recordId
          ? _value.recordId
          : recordId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coordinate: null == coordinate
          ? _value.coordinate
          : coordinate // ignore: cast_nullable_to_non_nullable
              as LatLng,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharedPhotoImplCopyWith<$Res>
    implements $SharedPhotoCopyWith<$Res> {
  factory _$$SharedPhotoImplCopyWith(
          _$SharedPhotoImpl value, $Res Function(_$SharedPhotoImpl) then) =
      __$$SharedPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int recordId,
      String name,
      LatLng coordinate,
      String? memo,
      List<String> photos,
      @timestampJsonKey DateTime? createdAt,
      @timestampJsonKey DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class __$$SharedPhotoImplCopyWithImpl<$Res>
    extends _$SharedPhotoCopyWithImpl<$Res, _$SharedPhotoImpl>
    implements _$$SharedPhotoImplCopyWith<$Res> {
  __$$SharedPhotoImplCopyWithImpl(
      _$SharedPhotoImpl _value, $Res Function(_$SharedPhotoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordId = null,
    Object? name = null,
    Object? coordinate = null,
    Object? memo = freezed,
    Object? photos = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$SharedPhotoImpl(
      recordId: null == recordId
          ? _value.recordId
          : recordId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coordinate: null == coordinate
          ? _value.coordinate
          : coordinate // ignore: cast_nullable_to_non_nullable
              as LatLng,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$SharedPhotoImpl extends _SharedPhoto with DiagnosticableTreeMixin {
  const _$SharedPhotoImpl(
      {required this.recordId,
      required this.name,
      required this.coordinate,
      this.memo = null,
      final List<String> photos = const <String>[],
      @timestampJsonKey this.createdAt = null,
      @timestampJsonKey this.updatedAt = null,
      this.updatedBy = null})
      : _photos = photos,
        super._();

  factory _$SharedPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedPhotoImplFromJson(json);

  @override
  final int recordId;
  @override
  final String name;
  @override
  final LatLng coordinate;
  @override
  @JsonKey()
  final String? memo;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  @timestampJsonKey
  final DateTime? createdAt;
  @override
  @timestampJsonKey
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final String? updatedBy;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SharedPhoto(recordId: $recordId, name: $name, coordinate: $coordinate, memo: $memo, photos: $photos, createdAt: $createdAt, updatedAt: $updatedAt, updatedBy: $updatedBy)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SharedPhoto'))
      ..add(DiagnosticsProperty('recordId', recordId))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('coordinate', coordinate))
      ..add(DiagnosticsProperty('memo', memo))
      ..add(DiagnosticsProperty('photos', photos))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updatedBy', updatedBy));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedPhotoImpl &&
            (identical(other.recordId, recordId) ||
                other.recordId == recordId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coordinate, coordinate) ||
                other.coordinate == coordinate) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordId,
      name,
      coordinate,
      memo,
      const DeepCollectionEquality().hash(_photos),
      createdAt,
      updatedAt,
      updatedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedPhotoImplCopyWith<_$SharedPhotoImpl> get copyWith =>
      __$$SharedPhotoImplCopyWithImpl<_$SharedPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedPhotoImplToJson(
      this,
    );
  }
}

abstract class _SharedPhoto extends SharedPhoto {
  const factory _SharedPhoto(
      {required final int recordId,
      required final String name,
      required final LatLng coordinate,
      final String? memo,
      final List<String> photos,
      @timestampJsonKey final DateTime? createdAt,
      @timestampJsonKey final DateTime? updatedAt,
      final String? updatedBy}) = _$SharedPhotoImpl;
  const _SharedPhoto._() : super._();

  factory _SharedPhoto.fromJson(Map<String, dynamic> json) =
      _$SharedPhotoImpl.fromJson;

  @override
  int get recordId;
  @override
  String get name;
  @override
  LatLng get coordinate;
  @override
  String? get memo;
  @override
  List<String> get photos;
  @override
  @timestampJsonKey
  DateTime? get createdAt;
  @override
  @timestampJsonKey
  DateTime? get updatedAt;
  @override
  String? get updatedBy;
  @override
  @JsonKey(ignore: true)
  _$$SharedPhotoImplCopyWith<_$SharedPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
