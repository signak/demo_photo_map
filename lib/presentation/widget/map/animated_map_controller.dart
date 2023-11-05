import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMapController implements MapController {
  AnimatedMapController(this.mapController, this.tickerProvider);

  final MapController mapController;
  final TickerProvider tickerProvider;

  void moveWithAnimation(LatLng destLocation, double destZoom, {String? id}) {
    // Create some tween. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: tickerProvider);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  double get rotation => mapController.rotation;

  @override
  LatLngBounds? get bounds => mapController.bounds;

  @override
  LatLng get center => mapController.center;

  @override
  CenterZoom centerZoomFitBounds(LatLngBounds bounds,
          {FitBoundsOptions? options}) =>
      mapController.centerZoomFitBounds(bounds, options: options);

  @override
  void dispose() => mapController.dispose();

  @override
  void fitBounds(LatLngBounds bounds, {FitBoundsOptions? options}) =>
      mapController.fitBounds(bounds, options: options);

  @override
  CustomPoint<num>? latLngToScreenPoint(LatLng latLng) =>
      mapController.latLngToScreenPoint(latLng);

  @override
  StreamSink<MapEvent> get mapEventSink => mapController.mapEventSink;

  @override
  Stream<MapEvent> get mapEventStream => mapController.mapEventStream;

  @override
  bool move(LatLng center, double zoom, {String? id}) =>
      mapController.move(center, zoom, id: id);

  @override
  MoveAndRotateResult moveAndRotate(LatLng center, double zoom, double degree,
          {String? id}) =>
      mapController.moveAndRotate(center, zoom, degree, id: id);

  @override
  LatLng? pointToLatLng(CustomPoint<num> point) =>
      mapController.pointToLatLng(point);

  @override
  bool rotate(double degree, {String? id}) =>
      mapController.rotate(degree, id: id);

  @override
  double get zoom => mapController.zoom;

  @override
  set state(FlutterMapState state) {
    mapController.state = state;
  }
}
