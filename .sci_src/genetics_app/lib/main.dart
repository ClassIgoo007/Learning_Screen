import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'widgets/common.dart';

void main() => runApp(const GeneticsReadingApp());

class GeneticsReadingApp extends StatelessWidget {
  const GeneticsReadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DNA & Chromosomes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: kTeal,
        useMaterial3: true,
        scaffoldBackgroundColor: kPaper,
      ),
      home: const HomeScreen(),
    );
  }
}
