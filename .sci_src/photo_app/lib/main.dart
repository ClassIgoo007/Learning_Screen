import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'widgets/common.dart';

void main() => runApp(const PhotosynthesisApp());

class PhotosynthesisApp extends StatelessWidget {
  const PhotosynthesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photosynthesis Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: kGreen,
        useMaterial3: true,
        scaffoldBackgroundColor: kPaper,
      ),
      home: const HomeScreen(),
    );
  }
}
