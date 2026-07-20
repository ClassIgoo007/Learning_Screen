import 'package:flutter/material.dart';

import 'screens/worksheet_screen.dart';
import 'services/openai_service.dart';

/// Pass the key at run/build time — never hardcode it:
///   flutter run --dart-define=OPENAI_API_KEY=sk-...
/// In production, replace the direct OpenAI call with a request to your
/// own backend (see OpenAIService docs).
const String _openAiKey = String.fromEnvironment('OPENAI_API_KEY');

void main() => runApp(const PhonicsApp());

class PhonicsApp extends StatelessWidget {
  const PhonicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonics Worksheets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFD6336C),
        useMaterial3: true,
      ),
      home: WorksheetScreen(openAI: OpenAIService(apiKey: _openAiKey)),
    );
  }
}
