import 'package:flutter/material.dart';

import 'screens/lesson_shell.dart';
import 'theme/palette.dart';

class KineticTheoryApp extends StatelessWidget {
  const KineticTheoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.slate,
        primary: Palette.slate,
        surface: Palette.surface,
      ),
      scaffoldBackgroundColor: Palette.paper,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Palette.ink,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );

    return MaterialApp(
      title: 'Kinetic theory of gases',
      debugShowCheckedModeBanner: false,
      theme: base,
      builder: (context, child) {
        // Clamp the system text scale so the worksheet layout stays intact
        // at very large accessibility settings.
        final scale =
            MediaQuery.textScalerOf(context).scale(1).clamp(0.9, 1.4).toDouble();
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LessonShell(),
    );
  }
}
