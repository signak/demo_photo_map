import 'package:freezed_annotation/freezed_annotation.dart';

@Immutable()
class MarkerParam<T> {
  MarkerParam(
    this.label,
    this.latitude,
    this.longitude,
    this.altitude,
    this.attrs,
  );

  final T attrs;
  final double latitude;
  final double longitude;
  final double altitude;
  final String label;
}
