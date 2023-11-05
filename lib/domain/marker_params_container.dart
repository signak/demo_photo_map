import 'marker_param.dart';

class MarkerParamsContainer<T> {
  MarkerParamsContainer(this.createdAt, this.params);

  factory MarkerParamsContainer.empty() {
    return MarkerParamsContainer<T>(DateTime.now(), []);
  }

  final DateTime createdAt;
  final List<MarkerParam<T>> params;
}
