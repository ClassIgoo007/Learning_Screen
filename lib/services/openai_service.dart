import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/worksheet.dart';

/// Generates new phonetic-spelling worksheets with the OpenAI API.
///
/// SECURITY NOTE: never ship a real API key inside a client app binary —
/// it can be extracted. In production, route this call through your own
/// backend (e.g. a Cloud Function on classigoo.com) that holds the key
/// and forwards the request. The direct call below is for development.
class OpenAIService {
  OpenAIService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  static const _systemPrompt = '''
You generate elementary-school phonics worksheets. Respond with ONLY a JSON
object, no markdown fences, in exactly this shape:

{
  "title": "string",
  "questions": [
    {
      "phonetic": "(fə net´ik)",
      "choices": ["word1", "word2", "word3"],
      "answer": "word2"
    }
  ]
}

Rules:
- Exactly 8 questions.
- "phonetic" is the dictionary respelling of the answer word using this key:
  a add, ā ace, â care, ä palm, e end, ē equal, i it, ī ice, o odd, ō open,
  ô order, o͝o took, o͞o pool, u up, û burn, yo͞o fuse, oi oil,
  ə (schwa) as in above/sicken/possible/melon/circus.
  Mark the stressed syllable with ´ after it.
- "choices" contains exactly 3 real English words that look or sound similar
  (same first letters where possible); "answer" must be one of them.
- Words appropriate for grades 3-5. Vary the choice position of the answer.
''';

  /// Ask the model for a brand-new worksheet. Throws on failure —
  /// callers should catch and fall back to [kDefaultWorksheet].
  Future<Worksheet> generateWorksheet({String? theme}) async {
    final userPrompt = theme == null || theme.trim().isEmpty
        ? 'Generate a new worksheet with different words than before.'
        : 'Generate a new worksheet themed around: $theme';

    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'temperature': 0.9, // variety between worksheets
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw HttpException(
          'OpenAI API error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final content = body['choices'][0]['message']['content'] as String;

    // Defensive: strip accidental code fences before parsing.
    final clean =
        content.replaceAll(RegExp(r'```(?:json)?'), '').trim();

    return Worksheet.fromJson(jsonDecode(clean) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
