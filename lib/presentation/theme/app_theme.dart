import 'package:flutter/material.dart';

import 'color_schemes.g.dart';
import 'custom_color.g.dart';

/// ThemeDataからLight/Darkモードを判定するためのExtension
class ThemeMode extends ThemeExtension<ThemeMode> {
  const ThemeMode._({required bool darkMode}) : _isDarkMode = darkMode;
  factory ThemeMode.light() {
    return const ThemeMode._(darkMode: false);
  }

  factory ThemeMode.dark() {
    return const ThemeMode._(darkMode: true);
  }

  final bool _isDarkMode;

  bool get isDark => _isDarkMode;

  bool get isLight => !_isDarkMode;

  @override
  ThemeExtension<ThemeMode> copyWith({bool? darkMode}) {
    return ThemeMode._(darkMode: darkMode ?? false);
  }

  @override
  ThemeExtension<ThemeMode> lerp(
      covariant ThemeExtension<ThemeMode>? other, double t) {
    if (other == null) {
      return this;
    }
    return other;
  }
}

class AppTheme {
  static ThemeData defaultTheme(BuildContext context) {
    const colorScheme = lightColorScheme;
    return _getTheme(
      context,
      colorScheme,
      lightCustomColors,
      ThemeMode.light(),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    const colorScheme = darkColorScheme;
    return _getTheme(
      context,
      colorScheme,
      darkCustomColors,
      ThemeMode.dark(),
    );
  }

  static ThemeData _getTheme(BuildContext context, ColorScheme colorScheme,
      CustomColors customColors, ThemeMode mode) {
    return ThemeData(
      fontFamily: "NotoSansJP",
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: <ThemeExtension>[
        customColors,
        mode,
      ],
      appBarTheme: AppBarTheme(
        elevation: 8,
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontFamily: 'PathwayGothicOne',
        ),
        centerTitle: true,
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        actionsIconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(
            // side: BorderSide(
            //   color: Theme.of(context).colorScheme.outline,
            //   width: 2,
            // ),
            ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              MaterialStatePropertyAll<Color?>(colorScheme.primary),
          iconColor: MaterialStatePropertyAll<Color?>(colorScheme.onPrimary),
          foregroundColor:
              MaterialStatePropertyAll<Color?>(colorScheme.onPrimary),
        ),
      ),
      // iconButtonTheme: IconButtonThemeData(
      //   style: ButtonStyle(
      //     backgroundColor: MaterialStatePropertyAll<Color?>(
      //         colorScheme.surface.withAlpha(10)),
      //     iconColor:
      //         MaterialStatePropertyAll<Color?>(colorScheme.onPrimaryContainer),
      //     shadowColor: MaterialStatePropertyAll<Color?>(
      //         colorScheme.onSurfaceVariant.withAlpha(10)),
      //   ),
      // ),
    );
  }
}
