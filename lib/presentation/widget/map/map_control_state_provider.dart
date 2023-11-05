import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'map_control_state.dart';

final mapControlStateProvider =
    StateNotifierProvider<MapControlStateNotifier, MapControlState>(
  (ref) => MapControlStateNotifier(const MapControlState()),
);

class MapControlStateNotifier extends StateNotifier<MapControlState> {
  MapControlStateNotifier(super.state);

  void followCurrentLocation() {
    state = state.copyWith(
      locationUpdating: FollowOnLocationUpdate.always,
      isItemEditing: false,
      isItemMoving: false,
      isItemAdding: false,
    );
  }

  void stopCurrentLocationFollowing() {
    state = state.copyWith(locationUpdating: FollowOnLocationUpdate.never);
  }

  void startItemEditing() {
    state = state.copyWith(
      locationUpdating: FollowOnLocationUpdate.never,
      isItemEditing: true,
      isItemMoving: false,
      isItemAdding: false,
    );
  }

  void completeItemEditing() {
    state = state.copyWith(
      isItemEditing: false,
    );
  }

  void startItemMoving() {
    state = state.copyWith(
      locationUpdating: FollowOnLocationUpdate.never,
      isItemEditing: false,
      isItemMoving: true,
      isItemAdding: false,
    );
  }

  void completeItemMoving() {
    state = state.copyWith(
      isItemMoving: false,
    );
  }

  void startItemAdding() {
    state = state.copyWith(
      locationUpdating: FollowOnLocationUpdate.never,
      isItemEditing: false,
      isItemMoving: false,
      isItemAdding: true,
    );
  }

  void completeItemAdding() {
    state = state.copyWith(
      isItemAdding: false,
    );
  }
}
