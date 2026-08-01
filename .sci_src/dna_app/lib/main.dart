import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'widgets/common.dart';

void main() => runApp(const CentralDogmaApp());

class CentralDogmaApp extends StatelessWidget {
  const CentralDogmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transcription & Translation',
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
