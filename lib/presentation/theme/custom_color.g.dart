import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

const mapMarker = Color(0xFFBA1A1A);
const camera = Color(0xFF292C33);
const linkedText = Color(0xFF0087F4);

CustomColors lightCustomColors = const CustomColors(
  sourceMapMarker: Color(0xFFBA1A1A),
  mapMarker: Color(0xFFBA1A1A),
  onMapMarker: Color(0xFFFFFFFF),
  mapMarkerContainer: Color(0xFFFFDAD5),
  onMapMarkerContainer: Color(0xFF410002),
  sourceCamera: Color(0xFF292C33),
  camera: Color(0xFF2B5EA7),
  onCamera: Color(0xFFFFFFFF),
  cameraContainer: Color(0xFFD7E3FF),
  onCameraContainer: Color(0xFF001B3E),
  sourceLinkedText: Color(0xFF0087F4),
  linkedText: Color(0xFF005FAE),
  onLinkedText: Color(0xFFFFFFFF),
  linkedTextContainer: Color(0xFFD4E3FF),
  onLinkedTextContainer: Color(0xFF001C3A),
);

CustomColors darkCustomColors = const CustomColors(
  sourceMapMarker: Color(0xFFBA1A1A),
  mapMarker: Color(0xFFFFB4AB),
  onMapMarker: Color(0xFF690004),
  mapMarkerContainer: Color(0xFF930009),
  onMapMarkerContainer: Color(0xFFFFDAD5),
  sourceCamera: Color(0xFF292C33),
  camera: Color(0xFFAAC7FF),
  onCamera: Color(0xFF002F65),
  cameraContainer: Color(0xFF00458E),
  onCameraContainer: Color(0xFFD7E3FF),
  sourceLinkedText: Color(0xFF0087F4),
  linkedText: Color(0xFFA5C8FF),
  onLinkedText: Color(0xFF00315E),
  linkedTextContainer: Color(0xFF004785),
  onLinkedTextContainer: Color(0xFFD4E3FF),
);

/// Defines a set of custom colors, each comprised of 4 complementary tones.
///
/// See also:
///   * <https://m3.material.io/styles/color/the-color-system/custom-colors>
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceMapMarker,
    required this.mapMarker,
    required this.onMapMarker,
    required this.mapMarkerContainer,
    required this.onMapMarkerContainer,
    required this.sourceCamera,
    required this.camera,
    required this.onCamera,
    required this.cameraContainer,
    required this.onCameraContainer,
    required this.sourceLinkedText,
    required this.linkedText,
    required this.onLinkedText,
    required this.linkedTextContainer,
    required this.onLinkedTextContainer,
  });

  final Color? sourceMapMarker;
  final Color? mapMarker;
  final Color? onMapMarker;
  final Color? mapMarkerContainer;
  final Color? onMapMarkerContainer;
  final Color? sourceCamera;
  final Color? camera;
  final Color? onCamera;
  final Color? cameraContainer;
  final Color? onCameraContainer;
  final Color? sourceLinkedText;
  final Color? linkedText;
  final Color? onLinkedText;
  final Color? linkedTextContainer;
  final Color? onLinkedTextContainer;

  @override
  CustomColors copyWith({
    Color? sourceMapMarker,
    Color? mapMarker,
    Color? onMapMarker,
    Color? mapMarkerContainer,
    Color? onMapMarkerContainer,
    Color? sourceCamera,
    Color? camera,
    Color? onCamera,
    Color? cameraContainer,
    Color? onCameraContainer,
    Color? sourceLinkedText,
    Color? linkedText,
    Color? onLinkedText,
    Color? linkedTextContainer,
    Color? onLinkedTextContainer,
  }) {
    return CustomColors(
      sourceMapMarker: sourceMapMarker ?? this.sourceMapMarker,
      mapMarker: mapMarker ?? this.mapMarker,
      onMapMarker: onMapMarker ?? this.onMapMarker,
      mapMarkerContainer: mapMarkerContainer ?? this.mapMarkerContainer,
      onMapMarkerContainer: onMapMarkerContainer ?? this.onMapMarkerContainer,
      sourceCamera: sourceCamera ?? this.sourceCamera,
      camera: camera ?? this.camera,
      onCamera: onCamera ?? this.onCamera,
      cameraContainer: cameraContainer ?? this.cameraContainer,
      onCameraContainer: onCameraContainer ?? this.onCameraContainer,
      sourceLinkedText: sourceLinkedText ?? this.sourceLinkedText,
      linkedText: linkedText ?? this.linkedText,
      onLinkedText: onLinkedText ?? this.onLinkedText,
      linkedTextContainer: linkedTextContainer ?? this.linkedTextContainer,
      onLinkedTextContainer:
          onLinkedTextContainer ?? this.onLinkedTextContainer,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceMapMarker: Color.lerp(sourceMapMarker, other.sourceMapMarker, t),
      mapMarker: Color.lerp(mapMarker, other.mapMarker, t),
      onMapMarker: Color.lerp(onMapMarker, other.onMapMarker, t),
      mapMarkerContainer:
          Color.lerp(mapMarkerContainer, other.mapMarkerContainer, t),
      onMapMarkerContainer:
          Color.lerp(onMapMarkerContainer, other.onMapMarkerContainer, t),
      sourceCamera: Color.lerp(sourceCamera, other.sourceCamera, t),
      camera: Color.lerp(camera, other.camera, t),
      onCamera: Color.lerp(onCamera, other.onCamera, t),
      cameraContainer: Color.lerp(cameraContainer, other.cameraContainer, t),
      onCameraContainer:
          Color.lerp(onCameraContainer, other.onCameraContainer, t),
      sourceLinkedText: Color.lerp(sourceLinkedText, other.sourceLinkedText, t),
      linkedText: Color.lerp(linkedText, other.linkedText, t),
      onLinkedText: Color.lerp(onLinkedText, other.onLinkedText, t),
      linkedTextContainer:
          Color.lerp(linkedTextContainer, other.linkedTextContainer, t),
      onLinkedTextContainer:
          Color.lerp(onLinkedTextContainer, other.onLinkedTextContainer, t),
    );
  }

  /// Returns an instance of [CustomColors] in which the following custom
  /// colors are harmonized with [dynamic]'s [ColorScheme.primary].
  ///   * [CustomColors.sourceLinkedText]
  ///   * [CustomColors.linkedText]
  ///   * [CustomColors.onLinkedText]
  ///   * [CustomColors.linkedTextContainer]
  ///   * [CustomColors.onLinkedTextContainer]
  ///
  /// See also:
  ///   * <https://m3.material.io/styles/color/the-color-system/custom-colors#harmonization>
  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
      sourceLinkedText: sourceLinkedText!.harmonizeWith(dynamic.primary),
      linkedText: linkedText!.harmonizeWith(dynamic.primary),
      onLinkedText: onLinkedText!.harmonizeWith(dynamic.primary),
      linkedTextContainer: linkedTextContainer!.harmonizeWith(dynamic.primary),
      onLinkedTextContainer:
          onLinkedTextContainer!.harmonizeWith(dynamic.primary),
    );
  }
}
