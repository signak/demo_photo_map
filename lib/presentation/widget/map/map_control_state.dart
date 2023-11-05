import 'package:flutter/foundation.dart'; // ignore: unused_import
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../generated/presentation/widget/map/map_control_state.freezed.dart';

@freezed
class MapControlState with _$MapControlState {
  const factory MapControlState({
    @Default(FollowOnLocationUpdate.always)
        FollowOnLocationUpdate locationUpdating,
    @Default(false) bool isItemEditing,
    @Default(false) bool isItemMoving,
    @Default(false) bool isItemAdding,
  }) = _MapControlState;

  const MapControlState._();

  String get mode {
    if (isFollowing()) {
      return 'Following';
    } else if (isItemEditing) {
      return 'ItemEditing';
    } else if (isItemMoving) {
      return 'ItemMoving';
    } else if (isItemAdding) {
      return 'ItemAdding';
    }
    return 'view (default)';
  }

  bool isFollowing() {
    return locationUpdating == FollowOnLocationUpdate.always;
  }
}
