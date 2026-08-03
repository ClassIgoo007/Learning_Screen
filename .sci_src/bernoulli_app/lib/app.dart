import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/simulation_screen.dart';
import 'theme/app_theme.dart';

/// The application shell: themes, routes and global text-scaling policy.
class BernoulliApp extends StatelessWidget {
  const BernoulliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bernoulli's Principle",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        SimulationScreen.routeName: (_) => const SimulationScreen(),
        QuizScreen.routeName: (_) => const QuizScreen(),
      },
      // Very large system font settings would overflow the readouts and the
      // figure labels, so scaling is honoured but capped.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.5,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
