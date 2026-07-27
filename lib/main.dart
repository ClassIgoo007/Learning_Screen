import 'package:flutter/material.dart';

import 'models/quiz_session.dart';
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

class PhonicsApp extends StatefulWidget {
  const PhonicsApp({super.key});

  @override
  State<PhonicsApp> createState() => _PhonicsAppState();
}

class _PhonicsAppState extends State<PhonicsApp> {
  late final OpenAIService _openAI = OpenAIService(apiKey: _openAiKey);
  late final TtsService _tts = TtsService();
  final SessionStore _store = SessionStore();

  @override
  void dispose() {
    _openAI.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonics Worksheets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: WelcomeScreen(openAI: _openAI, tts: _tts, store: _store),
    );
  }
}
