import 'package:flutter/material.dart';

/// Colours that carry meaning rather than decoration, resolved per brightness
/// so the app reads correctly in both light and dark mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ok,
    required this.okContainer,
    required this.warn,
    required this.warnContainer,
    required this.bad,
    required this.badContainer,
    required this.motion,
  });

  /// Slow water / correct answer.
  final Color ok;
  final Color okContainer;

  /// Explanation panels and hints.
  final Color warn;
  final Color warnContainer;

  /// Fast water, low pressure, wrong answer, cavitation.
  final Color bad;
  final Color badContainer;

  /// The ½ρv² share of the pressure bars.
  final Color motion;

  static const light = AppColors(
    ok: Color(0xFF2E7D32),
    okContainer: Color(0xFFE8F5E9),
    warn: Color(0xFFEF6C00),
    warnContainer: Color(0xFFFFF3E0),
    bad: Color(0xFFC62828),
    badContainer: Color(0xFFFFEBEE),
    motion: Color(0xFFEF6C00),
  );

  static const dark = AppColors(
    ok: Color(0xFF81C784),
    okContainer: Color(0xFF1B3620),
    warn: Color(0xFFFFB74D),
    warnContainer: Color(0xFF3A2A12),
    bad: Color(0xFFEF9A9A),
    badContainer: Color(0xFF3B1F20),
    motion: Color(0xFFFFA726),
  );

  @override
  AppColors copyWith({
    Color? ok,
    Color? okContainer,
    Color? warn,
    Color? warnContainer,
    Color? bad,
    Color? badContainer,
    Color? motion,
  }) {
    return AppColors(
      ok: ok ?? this.ok,
      okContainer: okContainer ?? this.okContainer,
      warn: warn ?? this.warn,
      warnContainer: warnContainer ?? this.warnContainer,
      bad: bad ?? this.bad,
      badContainer: badContainer ?? this.badContainer,
      motion: motion ?? this.motion,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      ok: Color.lerp(ok, other.ok, t)!,
      okContainer: Color.lerp(okContainer, other.okContainer, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnContainer: Color.lerp(warnContainer, other.warnContainer, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      badContainer: Color.lerp(badContainer, other.badContainer, t)!,
      motion: Color.lerp(motion, other.motion, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  /// Semantic colours for the current theme.
  AppColors get colours =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  ColorScheme get scheme => Theme.of(this).colorScheme;
}

/// Light and dark themes built from one seed.
class AppTheme {
  const AppTheme._();

  static const Color seed = Color(0xFF0277BD);

  static ThemeData light() => _base(Brightness.light, AppColors.light);
  static ThemeData dark() => _base(Brightness.dark, AppColors.dark);

  static ThemeData _base(Brightness brightness, AppColors colours) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[colours],
      // Card and slider theming moved between classes across Flutter
      // versions, so those are styled at the call site to stay portable.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
