import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/lesson_shell.dart';
import 'theme/palette.dart';

class HeatAndTemperatureApp extends StatelessWidget {
  const HeatAndTemperatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
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
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );

    return MaterialApp(
      title: 'Heat and temperature',
      debugShowCheckedModeBanner: false,
      theme: theme,
      builder: (context, child) {
        // Clamp the system text scale so the worksheet layout survives very
        // large accessibility settings without clipping.
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
