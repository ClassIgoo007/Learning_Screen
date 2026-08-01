import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../features/activity/logic/word_search_builder.dart';
import '../features/activity/models/activity.dart';
import '../features/crossword/models/crossword.dart';
import '../features/science/models/science_content.dart';
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

  static const _scienceQuizPrompt = '''
You write grade 5–8 science reading-comprehension multiple-choice questions.
Respond with ONLY a JSON object, no markdown fences, in exactly this shape:

{
  "questions": [
    {
      "question": "string",
      "options": ["choice A", "choice B", "choice C"],
      "answerIndex": 0,
      "explanation": "short reason using the passage"
    }
  ]
}

Rules:
- Exactly 10 questions.
- Every question must be answerable from the passage alone.
- Exactly 3 options per question; answerIndex is 0, 1, or 2.
- Vary which option is correct.
- Keep vocabulary age-appropriate; explanations one sentence.
''';

  static const _scienceBlanksPrompt = '''
You write grade 5–8 science fill-in-the-blank sentences from a reading passage.
Respond with ONLY a JSON object, no markdown fences, in exactly this shape:

{
  "blankItems": [
    {
      "before": "text before the blank",
      "after": "text after the blank",
      "accepted": ["canonical answer", "optional synonym"],
      "hint": "short helpful hint"
    }
  ]
}

Rules:
- Exactly 12 items.
- Each blank is one word or a short phrase found in / supported by the passage.
- "accepted" lists every spelling counted correct; first entry is canonical.
- Do not put the answer inside before/after.
''';

  static const _crosswordCluesPrompt = '''
You write fresh crossword clues for elementary phonics puzzles.
Respond with ONLY a JSON object, no markdown fences, in exactly this shape:

{
  "clues": [
    {"index": 1, "answer": "PAINT", "clue": "short kid-friendly clue"},
    {"index": 2, "answer": "NAME", "clue": "short kid-friendly clue"}
  ]
}

Rules:
- The "clues" array MUST contain exactly one object for every word listed.
- "index" is the 1-based position in the word list (1, 2, 3, ...).
- "answer" must match the given answer word exactly.
- Clues must point clearly to that exact answer word.
- Keep clues short (under 12 words), kid-friendly, grades 3–5.
- Do not include the answer word in the clue.
- Across and Down entries with the same number are DIFFERENT words — each needs its own clue.
''';

  static const _vowelActivityPrompt = '''
You write fresh elementary phonics sentence + word-bank activities.
Respond with ONLY a JSON object, no markdown fences, in exactly this shape:

{
  "words": ["WORD1", "WORD2"],
  "sentences": [
    {"before": "text before ", "answer": "WORD1", "after": " text after."},
    {"before": "text before ", "answer": "WORD2", "after": " text after."}
  ]
}

Rules:
- "words" must contain exactly the requested count of UNIQUE uppercase words.
- Every word must clearly teach the requested vowel sound / spelling patterns.
- Prefer common grade 3–5 vocabulary; each word 3–10 letters (A–Z only).
- Do NOT reuse any word from the "avoid" list.
- "sentences" must contain exactly one sentence per word.
- Each sentence "answer" must match one word from "words" exactly (same spelling).
- Every word from "words" must appear as exactly one sentence answer.
- before/after must not contain the answer word.
- Keep sentences short and kid-friendly.
''';

  /// Ask the model for a brand-new worksheet. Throws on failure —
  /// callers should catch and fall back to [kDefaultWorksheet].
  Future<Worksheet> generateWorksheet({String? theme}) async {
    final userPrompt = theme == null || theme.trim().isEmpty
        ? 'Generate a new worksheet with different words than before.'
        : 'Generate a new worksheet themed around: $theme';

    final map = await _chatJson(
      system: _systemPrompt,
      user: userPrompt,
      temperature: 0.9,
    );
    return Worksheet.fromJson(map);
  }

  /// New multiple-choice questions grounded in a science topic's reading.
  Future<List<QuizQuestion>> generateScienceQuiz({
    required ScienceTopic topic,
  }) async {
    final passage = topic.quiz.passageText ?? topic.intro;
    final map = await _chatJson(
      system: _scienceQuizPrompt,
      user: 'Topic: ${topic.title}\n'
          'Word bank: ${topic.wordBank.join(', ')}\n'
          'Passage:\n$passage\n\n'
          'Generate 10 new multiple-choice questions different from typical '
          'worksheet copies.',
      temperature: 0.85,
    );
    final list = map['questions'] as List? ?? const [];
    final questions = list
        .whereType<Map>()
        .map((e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e)))
        .where((q) => q.question.isNotEmpty && q.options.length >= 2)
        .toList();
    if (questions.length < 5) {
      throw HttpException('AI returned too few valid science questions.');
    }
    return questions;
  }

  /// New fill-in-the-blank sentences grounded in a science topic's reading.
  Future<List<BlankItem>> generateScienceBlanks({
    required ScienceTopic topic,
  }) async {
    final passage = topic.blanks.passageText ?? topic.intro;
    final map = await _chatJson(
      system: _scienceBlanksPrompt,
      user: 'Topic: ${topic.title}\n'
          'Word bank: ${topic.wordBank.join(', ')}\n'
          'Passage:\n$passage\n\n'
          'Generate 12 new fill-in-the-blank sentences different from typical '
          'worksheet copies.',
      temperature: 0.85,
    );
    final list = map['blankItems'] as List? ?? const [];
    final items = list
        .whereType<Map>()
        .map((e) => BlankItem.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.before.isNotEmpty && b.accepted.first.isNotEmpty)
        .toList();
    if (items.length < 6) {
      throw HttpException('AI returned too few valid blank sentences.');
    }
    return items;
  }

  /// Brand-new vowel activity: new word bank, new sentences, rebuilt grid.
  Future<VowelActivity> generateVowelActivity({
    required VowelActivity seed,
    WordSearchBuilder? gridBuilder,
  }) async {
    final expected = seed.words.length;
    final builder = gridBuilder ?? WordSearchBuilder();

    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final map = await _chatJson(
          system: _vowelActivityPrompt,
          user: _vowelActivityUserPrompt(seed, expected, attempt: attempt),
          temperature: attempt == 0 ? 0.9 : 0.7,
        );
        final parsed = parseVowelActivityResponse(map, expected: expected);
        final gridRows = builder.build(parsed.words, size: seed.cols);
        final activity = VowelActivity.fromGenerated(
          seed: seed,
          words: parsed.words,
          sentences: parsed.sentences,
          gridRows: gridRows,
        );
        final placements = activity.findPlacements();
        if (placements.length != activity.words.length) {
          throw HttpException(
              'Generated word search is missing some words. Please try again.');
        }
        return activity;
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError is HttpException) throw lastError;
    throw HttpException(
        'Could not generate a new activity: ${lastError ?? 'unknown error'}');
  }

  String _vowelActivityUserPrompt(
    VowelActivity seed,
    int expected, {
    required int attempt,
  }) {
    final spelling = _spellingHintFor(seed);
    final avoid = seed.words.join(', ');
    final retry = attempt == 0
        ? ''
        : '\nIMPORTANT: Previous reply was invalid. Return exactly $expected '
            'unique words and $expected matching sentences.\n';
    return 'Theme: ${seed.name}\n'
        'Spelling patterns: $spelling\n'
        'Generate exactly $expected new words and $expected sentences.\n'
        'Avoid reusing these words: $avoid\n'
        '$retry';
  }

  static String _spellingHintFor(VowelActivity seed) {
    final key = seed.name.toLowerCase();
    if (key.contains('long e')) {
      return 'long e sound spelled e, ee, ea, or ey';
    }
    if (key.contains('long u')) {
      return 'long u sound spelled u, u_e (silent e), or ue';
    }
    return '${seed.name} phonics patterns for grades 3–5';
  }

  /// Validate / normalize model JSON into words + sentences.
  @visibleForTesting
  static ({List<String> words, List<SentenceItem> sentences})
      parseVowelActivityResponse(
    Map<String, dynamic> map, {
    required int expected,
  }) {
    final rawWords = map['words'];
    if (rawWords is! List) {
      throw HttpException('AI response missing words list.');
    }

    final words = <String>[];
    final seen = <String>{};
    for (final item in rawWords) {
      final w = '$item'.trim().toUpperCase();
      if (w.isEmpty || !RegExp(r'^[A-Z]+$').hasMatch(w)) continue;
      if (w.length < 3 || w.length > 10) continue;
      if (!seen.add(w)) continue;
      words.add(w);
      if (words.length == expected) break;
    }
    if (words.length != expected) {
      throw HttpException(
          'AI returned ${words.length} usable words; expected $expected.');
    }

    final wordSet = words.toSet();
    final rawSentences = map['sentences'];
    if (rawSentences is! List) {
      throw HttpException('AI response missing sentences list.');
    }

    final byAnswer = <String, SentenceItem>{};
    for (final item in rawSentences) {
      if (item is! Map) continue;
      final answer = '${item['answer'] ?? ''}'.trim().toUpperCase();
      if (!wordSet.contains(answer) || byAnswer.containsKey(answer)) continue;
      final before = '${item['before'] ?? ''}';
      final after = '${item['after'] ?? ''}';
      if (before.trim().isEmpty && after.trim().isEmpty) continue;
      byAnswer[answer] = SentenceItem(before, answer, after);
    }

    if (byAnswer.length != expected) {
      throw HttpException(
          'AI returned ${byAnswer.length} usable sentences; expected $expected.');
    }

    // Keep sentence order aligned with the word bank.
    final sentences = [for (final w in words) byAnswer[w]!];
    return (words: words, sentences: sentences);
  }

  /// Fresh clue text for an existing crossword grid (answers stay the same).
  /// Always returns a full set of clues: retries once, then fills any gaps
  /// with the original clue text so the learner is never blocked.
  Future<CrosswordPuzzle> generateCrosswordClues({
    required CrosswordPuzzle puzzle,
  }) async {
    final expected = puzzle.entries.length;
    final words = [
      for (var i = 0; i < puzzle.entries.length; i++)
        '${i + 1}. ${puzzle.entries[i].number}-'
        '${puzzle.entries[i].direction.name.toUpperCase()}: '
        '${puzzle.entries[i].answer}',
    ];

    var parsed = await _requestCrosswordClues(
      puzzleName: puzzle.name,
      expected: expected,
      wordsBlock: words.join('\n'),
    );

    final filled = parsed.where((c) => c.trim().isNotEmpty).length;
    if (filled < expected) {
      parsed = await _requestCrosswordClues(
        puzzleName: puzzle.name,
        expected: expected,
        wordsBlock: words.join('\n'),
        extra:
            'IMPORTANT: Your previous reply was incomplete. Return ALL $expected '
            'clue objects with indexes 1 through $expected.',
      );
    }

    final merged = mergeCrosswordClues(
      original: [for (final e in puzzle.entries) e.clue],
      generated: parsed,
    );

    final changed = [
      for (var i = 0; i < expected; i++)
        if (merged[i] != puzzle.entries[i].clue) i,
    ];
    if (changed.isEmpty) {
      throw HttpException(
          'AI did not return usable new clues. Please try again.');
    }

    return puzzle.withClues(merged);
  }

  /// Prefer generated clues; fall back to originals for any blank slots.
  @visibleForTesting
  static List<String> mergeCrosswordClues({
    required List<String> original,
    required List<String> generated,
  }) {
    return [
      for (var i = 0; i < original.length; i++)
        (i < generated.length && generated[i].trim().isNotEmpty)
            ? generated[i].trim()
            : original[i],
    ];
  }

  Future<List<String>> _requestCrosswordClues({
    required String puzzleName,
    required int expected,
    required String wordsBlock,
    String? extra,
  }) async {
    final map = await _chatJson(
      system: _crosswordCluesPrompt,
      user: 'Theme: $puzzleName\n'
          'You must return exactly $expected clues.\n'
          '${extra == null ? '' : '$extra\n'}'
          'Write a new clue for each crossword answer below:\n'
          '$wordsBlock',
      temperature: 0.7,
    );

    return parseCrosswordCluesResponse(map['clues'], expected);
  }

  /// Normalize model output into a fixed-length list (empty string = missing).
  @visibleForTesting
  static List<String> parseCrosswordCluesResponse(
    Object? raw,
    int expected,
  ) {
    final result = List<String>.filled(expected, '');
    if (raw is! List || raw.isEmpty) return result;

    if (raw.first is Map) {
      // Prefer explicit 1-based indexes.
      for (final item in raw) {
        if (item is! Map) continue;
        final clue = '${item['clue'] ?? ''}'.trim();
        if (clue.isEmpty) continue;
        final index = item['index'];
        final i = index is int
            ? index
            : int.tryParse('$index');
        if (i != null && i >= 1 && i <= expected) {
          result[i - 1] = clue;
        }
      }
      // Fill any remaining gaps in list order.
      if (result.any((c) => c.isEmpty)) {
        var slot = 0;
        for (final item in raw) {
          while (slot < expected && result[slot].isNotEmpty) {
            slot++;
          }
          if (slot >= expected) break;
          if (item is! Map) continue;
          final clue = '${item['clue'] ?? ''}'.trim();
          if (clue.isEmpty) continue;
          if (result.contains(clue)) continue;
          result[slot] = clue;
        }
      }
      return result;
    }

    // Legacy: ["clue1", "clue2", ...]
    for (var i = 0; i < expected && i < raw.length; i++) {
      result[i] = '${raw[i]}'.trim();
    }
    return result;
  }

  Future<Map<String, dynamic>> _chatJson({
    required String system,
    required String user,
    double temperature = 0.8,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw HttpException(
          'OpenAI API key missing. Run with --dart-define-from-file=env.json');
    }

    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'temperature': temperature,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': system},
              {'role': 'user', 'content': user},
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw HttpException(
          'OpenAI API error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final content = body['choices'][0]['message']['content'] as String;
    final clean = content.replaceAll(RegExp(r'```(?:json)?'), '').trim();
    return jsonDecode(clean) as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
