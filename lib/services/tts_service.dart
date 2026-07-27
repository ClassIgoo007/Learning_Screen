import 'package:flutter_tts/flutter_tts.dart';

/// Speaks worksheet words aloud so students can hear a choice and match it
/// to the phonetic spelling. Uses the platform text-to-speech engine
/// (Google on Android, Apple on iOS, the browser's speech synthesis on web).
class TtsService {
  TtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('en-US');
    // Slower than default so young learners can follow along.
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _configured = true;
  }

  /// Speak [text], interrupting anything currently being spoken.
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _ensureConfigured();
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  Future<void> stop() => _tts.stop();

  void dispose() {
    _tts.stop();
  }
}
