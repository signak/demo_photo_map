import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/marker_param.dart';
import '../../../domain/shared_photo.dart';

final selectedMarkerStateProvider = StateNotifierProvider<
    SelectedMarkerStateNotifier, MarkerParam<SharedPhoto>?>(
  (ref) => SelectedMarkerStateNotifier(null),
);

class SelectedMarkerStateNotifier
    extends StateNotifier<MarkerParam<SharedPhoto>?> {
  SelectedMarkerStateNotifier(super.state);

  void select(MarkerParam<SharedPhoto> item) {
    state = item;
  }

  void unselect() {
    if (state != null) state = null;
  }
}
