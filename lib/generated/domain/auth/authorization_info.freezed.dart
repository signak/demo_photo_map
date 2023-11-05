// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../domain/auth/authorization_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AuthorizationInfo _$AuthorizationInfoFromJson(Map<String, dynamic> json) {
  return _AuthorizationInfo.fromJson(json);
}

/// @nodoc
mixin _$AuthorizationInfo {
  String get uid => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  bool get isSystemAdmin => throw _privateConstructorUsedError;
  bool get isAuthorizationAdmin => throw _privateConstructorUsedError;
  bool get isObservationPointMaintainer => throw _privateConstructorUsedError;
  bool get canRead => throw _privateConstructorUsedError;
  bool get canWrite => throw _privateConstructorUsedError;
  @timestampJsonKey
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @timestampJsonKey
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthorizationInfoCopyWith<AuthorizationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizationInfoCopyWith<$Res> {
  factory $AuthorizationInfoCopyWith(
          AuthorizationInfo value, $Res Function(AuthorizationInfo) then) =
      _$AuthorizationInfoCopyWithImpl<$Res, AuthorizationInfo>;
  @useResult
  $Res call(
      {String uid,
      String? id,
      bool isSystemAdmin,
      bool isAuthorizationAdmin,
      bool isObservationPointMaintainer,
      bool canRead,
      bool canWrite,
      @timestampJsonKey DateTime? createdAt,
      @timestampJsonKey DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class _$AuthorizationInfoCopyWithImpl<$Res, $Val extends AuthorizationInfo>
    implements $AuthorizationInfoCopyWith<$Res> {
  _$AuthorizationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? id = freezed,
    Object? isSystemAdmin = null,
    Object? isAuthorizationAdmin = null,
    Object? isObservationPointMaintainer = null,
    Object? canRead = null,
    Object? canWrite = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      isSystemAdmin: null == isSystemAdmin
          ? _value.isSystemAdmin
          : isSystemAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      isAuthorizationAdmin: null == isAuthorizationAdmin
          ? _value.isAuthorizationAdmin
          : isAuthorizationAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      isObservationPointMaintainer: null == isObservationPointMaintainer
          ? _value.isObservationPointMaintainer
          : isObservationPointMaintainer // ignore: cast_nullable_to_non_nullable
              as bool,
      canRead: null == canRead
          ? _value.canRead
          : canRead // ignore: cast_nullable_to_non_nullable
              as bool,
      canWrite: null == canWrite
          ? _value.canWrite
          : canWrite // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$AuthorizationInfoImplCopyWith<$Res>
    implements $AuthorizationInfoCopyWith<$Res> {
  factory _$$AuthorizationInfoImplCopyWith(_$AuthorizationInfoImpl value,
          $Res Function(_$AuthorizationInfoImpl) then) =
      __$$AuthorizationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String? id,
      bool isSystemAdmin,
      bool isAuthorizationAdmin,
      bool isObservationPointMaintainer,
      bool canRead,
      bool canWrite,
      @timestampJsonKey DateTime? createdAt,
      @timestampJsonKey DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class __$$AuthorizationInfoImplCopyWithImpl<$Res>
    extends _$AuthorizationInfoCopyWithImpl<$Res, _$AuthorizationInfoImpl>
    implements _$$AuthorizationInfoImplCopyWith<$Res> {
  __$$AuthorizationInfoImplCopyWithImpl(_$AuthorizationInfoImpl _value,
      $Res Function(_$AuthorizationInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? id = freezed,
    Object? isSystemAdmin = null,
    Object? isAuthorizationAdmin = null,
    Object? isObservationPointMaintainer = null,
    Object? canRead = null,
    Object? canWrite = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$AuthorizationInfoImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      isSystemAdmin: null == isSystemAdmin
          ? _value.isSystemAdmin
          : isSystemAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      isAuthorizationAdmin: null == isAuthorizationAdmin
          ? _value.isAuthorizationAdmin
          : isAuthorizationAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      isObservationPointMaintainer: null == isObservationPointMaintainer
          ? _value.isObservationPointMaintainer
          : isObservationPointMaintainer // ignore: cast_nullable_to_non_nullable
              as bool,
      canRead: null == canRead
          ? _value.canRead
          : canRead // ignore: cast_nullable_to_non_nullable
              as bool,
      canWrite: null == canWrite
          ? _value.canWrite
          : canWrite // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$AuthorizationInfoImpl extends _AuthorizationInfo
    with DiagnosticableTreeMixin {
  const _$AuthorizationInfoImpl(
      {required this.uid,
      this.id = null,
      this.isSystemAdmin = false,
      this.isAuthorizationAdmin = false,
      this.isObservationPointMaintainer = false,
      this.canRead = false,
      this.canWrite = false,
      @timestampJsonKey this.createdAt = null,
      @timestampJsonKey this.updatedAt = null,
      this.updatedBy = null})
      : super._();

  factory _$AuthorizationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizationInfoImplFromJson(json);

  @override
  final String uid;
  @override
  @JsonKey()
  final String? id;
  @override
  @JsonKey()
  final bool isSystemAdmin;
  @override
  @JsonKey()
  final bool isAuthorizationAdmin;
  @override
  @JsonKey()
  final bool isObservationPointMaintainer;
  @override
  @JsonKey()
  final bool canRead;
  @override
  @JsonKey()
  final bool canWrite;
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
    return 'AuthorizationInfo(uid: $uid, id: $id, isSystemAdmin: $isSystemAdmin, isAuthorizationAdmin: $isAuthorizationAdmin, isObservationPointMaintainer: $isObservationPointMaintainer, canRead: $canRead, canWrite: $canWrite, createdAt: $createdAt, updatedAt: $updatedAt, updatedBy: $updatedBy)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AuthorizationInfo'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('isSystemAdmin', isSystemAdmin))
      ..add(DiagnosticsProperty('isAuthorizationAdmin', isAuthorizationAdmin))
      ..add(DiagnosticsProperty(
          'isObservationPointMaintainer', isObservationPointMaintainer))
      ..add(DiagnosticsProperty('canRead', canRead))
      ..add(DiagnosticsProperty('canWrite', canWrite))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updatedBy', updatedBy));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationInfoImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isSystemAdmin, isSystemAdmin) ||
                other.isSystemAdmin == isSystemAdmin) &&
            (identical(other.isAuthorizationAdmin, isAuthorizationAdmin) ||
                other.isAuthorizationAdmin == isAuthorizationAdmin) &&
            (identical(other.isObservationPointMaintainer,
                    isObservationPointMaintainer) ||
                other.isObservationPointMaintainer ==
                    isObservationPointMaintainer) &&
            (identical(other.canRead, canRead) || other.canRead == canRead) &&
            (identical(other.canWrite, canWrite) ||
                other.canWrite == canWrite) &&
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
      uid,
      id,
      isSystemAdmin,
      isAuthorizationAdmin,
      isObservationPointMaintainer,
      canRead,
      canWrite,
      createdAt,
      updatedAt,
      updatedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationInfoImplCopyWith<_$AuthorizationInfoImpl> get copyWith =>
      __$$AuthorizationInfoImplCopyWithImpl<_$AuthorizationInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizationInfoImplToJson(
      this,
    );
  }
}

abstract class _AuthorizationInfo extends AuthorizationInfo {
  const factory _AuthorizationInfo(
      {required final String uid,
      final String? id,
      final bool isSystemAdmin,
      final bool isAuthorizationAdmin,
      final bool isObservationPointMaintainer,
      final bool canRead,
      final bool canWrite,
      @timestampJsonKey final DateTime? createdAt,
      @timestampJsonKey final DateTime? updatedAt,
      final String? updatedBy}) = _$AuthorizationInfoImpl;
  const _AuthorizationInfo._() : super._();

  factory _AuthorizationInfo.fromJson(Map<String, dynamic> json) =
      _$AuthorizationInfoImpl.fromJson;

  @override
  String get uid;
  @override
  String? get id;
  @override
  bool get isSystemAdmin;
  @override
  bool get isAuthorizationAdmin;
  @override
  bool get isObservationPointMaintainer;
  @override
  bool get canRead;
  @override
  bool get canWrite;
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
  _$$AuthorizationInfoImplCopyWith<_$AuthorizationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
