// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../presentation/widget/map/map_control_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$MapControlState {
  FollowOnLocationUpdate get locationUpdating =>
      throw _privateConstructorUsedError;
  bool get isItemEditing => throw _privateConstructorUsedError;
  bool get isItemMoving => throw _privateConstructorUsedError;
  bool get isItemAdding => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MapControlStateCopyWith<MapControlState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapControlStateCopyWith<$Res> {
  factory $MapControlStateCopyWith(
          MapControlState value, $Res Function(MapControlState) then) =
      _$MapControlStateCopyWithImpl<$Res, MapControlState>;
  @useResult
  $Res call(
      {FollowOnLocationUpdate locationUpdating,
      bool isItemEditing,
      bool isItemMoving,
      bool isItemAdding});
}

/// @nodoc
class _$MapControlStateCopyWithImpl<$Res, $Val extends MapControlState>
    implements $MapControlStateCopyWith<$Res> {
  _$MapControlStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationUpdating = null,
    Object? isItemEditing = null,
    Object? isItemMoving = null,
    Object? isItemAdding = null,
  }) {
    return _then(_value.copyWith(
      locationUpdating: null == locationUpdating
          ? _value.locationUpdating
          : locationUpdating // ignore: cast_nullable_to_non_nullable
              as FollowOnLocationUpdate,
      isItemEditing: null == isItemEditing
          ? _value.isItemEditing
          : isItemEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      isItemMoving: null == isItemMoving
          ? _value.isItemMoving
          : isItemMoving // ignore: cast_nullable_to_non_nullable
              as bool,
      isItemAdding: null == isItemAdding
          ? _value.isItemAdding
          : isItemAdding // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MapControlStateImplCopyWith<$Res>
    implements $MapControlStateCopyWith<$Res> {
  factory _$$MapControlStateImplCopyWith(_$MapControlStateImpl value,
          $Res Function(_$MapControlStateImpl) then) =
      __$$MapControlStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FollowOnLocationUpdate locationUpdating,
      bool isItemEditing,
      bool isItemMoving,
      bool isItemAdding});
}

/// @nodoc
class __$$MapControlStateImplCopyWithImpl<$Res>
    extends _$MapControlStateCopyWithImpl<$Res, _$MapControlStateImpl>
    implements _$$MapControlStateImplCopyWith<$Res> {
  __$$MapControlStateImplCopyWithImpl(
      _$MapControlStateImpl _value, $Res Function(_$MapControlStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationUpdating = null,
    Object? isItemEditing = null,
    Object? isItemMoving = null,
    Object? isItemAdding = null,
  }) {
    return _then(_$MapControlStateImpl(
      locationUpdating: null == locationUpdating
          ? _value.locationUpdating
          : locationUpdating // ignore: cast_nullable_to_non_nullable
              as FollowOnLocationUpdate,
      isItemEditing: null == isItemEditing
          ? _value.isItemEditing
          : isItemEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      isItemMoving: null == isItemMoving
          ? _value.isItemMoving
          : isItemMoving // ignore: cast_nullable_to_non_nullable
              as bool,
      isItemAdding: null == isItemAdding
          ? _value.isItemAdding
          : isItemAdding // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MapControlStateImpl extends _MapControlState
    with DiagnosticableTreeMixin {
  const _$MapControlStateImpl(
      {this.locationUpdating = FollowOnLocationUpdate.always,
      this.isItemEditing = false,
      this.isItemMoving = false,
      this.isItemAdding = false})
      : super._();

  @override
  @JsonKey()
  final FollowOnLocationUpdate locationUpdating;
  @override
  @JsonKey()
  final bool isItemEditing;
  @override
  @JsonKey()
  final bool isItemMoving;
  @override
  @JsonKey()
  final bool isItemAdding;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MapControlState(locationUpdating: $locationUpdating, isItemEditing: $isItemEditing, isItemMoving: $isItemMoving, isItemAdding: $isItemAdding)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MapControlState'))
      ..add(DiagnosticsProperty('locationUpdating', locationUpdating))
      ..add(DiagnosticsProperty('isItemEditing', isItemEditing))
      ..add(DiagnosticsProperty('isItemMoving', isItemMoving))
      ..add(DiagnosticsProperty('isItemAdding', isItemAdding));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapControlStateImpl &&
            (identical(other.locationUpdating, locationUpdating) ||
                other.locationUpdating == locationUpdating) &&
            (identical(other.isItemEditing, isItemEditing) ||
                other.isItemEditing == isItemEditing) &&
            (identical(other.isItemMoving, isItemMoving) ||
                other.isItemMoving == isItemMoving) &&
            (identical(other.isItemAdding, isItemAdding) ||
                other.isItemAdding == isItemAdding));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, locationUpdating, isItemEditing, isItemMoving, isItemAdding);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MapControlStateImplCopyWith<_$MapControlStateImpl> get copyWith =>
      __$$MapControlStateImplCopyWithImpl<_$MapControlStateImpl>(
          this, _$identity);
}

abstract class _MapControlState extends MapControlState {
  const factory _MapControlState(
      {final FollowOnLocationUpdate locationUpdating,
      final bool isItemEditing,
      final bool isItemMoving,
      final bool isItemAdding}) = _$MapControlStateImpl;
  const _MapControlState._() : super._();

  @override
  FollowOnLocationUpdate get locationUpdating;
  @override
  bool get isItemEditing;
  @override
  bool get isItemMoving;
  @override
  bool get isItemAdding;
  @override
  @JsonKey(ignore: true)
  _$$MapControlStateImplCopyWith<_$MapControlStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
