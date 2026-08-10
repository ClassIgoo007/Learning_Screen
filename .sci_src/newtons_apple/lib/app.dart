import 'package:flutter/material.dart';

import 'screens/newton_scene_screen.dart';
import 'theme/palette.dart';

/// Root widget. Kept separate from `main.dart` so tests can pump the app
/// without going through platform bootstrapping.
class NewtonsAppleApp extends StatelessWidget {
  const NewtonsAppleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Newton’s Apple',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Palette.uiSurface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.uiAccent,
          brightness: Brightness.dark,
          surface: Palette.uiSurface,
        ),
        tooltipTheme: const TooltipThemeData(preferBelow: false),
      ),
      // Guard against very large system font scales breaking the layout while
      // still honouring the user's accessibility preference.
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.4,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const NewtonSceneScreen(),
    );
  }
}
