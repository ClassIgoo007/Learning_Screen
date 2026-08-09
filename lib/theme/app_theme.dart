import 'package:flutter/material.dart';

/// Central design tokens + theme.
/// Bright, playful "kids learning" look: sky-blue backgrounds with clouds,
/// clean white cards, and green primary actions.
class AppColors {
  const AppColors._();

  static const Color blue = Color(0xFF4DA6F0); // primary sky blue
  static const Color blueDark = Color(0xFF2E86DE);
  static const Color green = Color(0xFF37B24D); // primary action / correct
  static const Color greenDark = Color(0xFF2F9E44);
  static const Color yellow = Color(0xFFFFC93C);
  static const Color red = Color(0xFFE9584B);
  static const Color violet = Color(0xFFAB47BC); // lesson-accent brand color

  static const Color skyTop = Color(0xFFCDEBFF); // light sky
  static const Color skyBottom = Color(0xFFF3FAFF); // near white

  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF243B53); // deep slate-navy
  static const Color inkSoft = Color(0xFF7A8CA0);
  static const Color hairline = Color(0xFFE4EDF5);

  static const Color greenSoft = Color(0xFFE9F8ED);
  static const Color redSoft = Color(0xFFFDECEA);
  static const Color blueSoft = Color(0xFFE7F3FE);
  static const Color violetSoft = Color(0xFFF5E9FA);

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyBottom],
  );
}

/// Soft shadow shared by elevated cards.
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x12203A5C),
    blurRadius: 22,
    offset: Offset(0, 10),
  ),
];

const List<BoxShadow> kButtonShadow = [
  BoxShadow(
    color: Color(0x3337B24D),
    blurRadius: 16,
    offset: Offset(0, 8),
  ),
];

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: AppColors.green,
      brightness: Brightness.light,
    ).copyWith(surface: AppColors.surface);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
