import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'services/openai_service.dart';
import 'services/tts_service.dart';
import 'theme/app_theme.dart';

/// Pass the key at run/build time — never hardcode it:
///   flutter run --dart-define-from-file=env.json
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
      theme: AppTheme.light(),
      home: WelcomeScreen(
        openAI: OpenAIService(apiKey: _openAiKey),
        tts: TtsService(),
      ),
    );
  }
}
