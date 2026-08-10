import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/activity/logic/activity_controller.dart';
import 'package:phonics_worksheets/features/activity/logic/word_search_builder.dart';
import 'package:phonics_worksheets/features/activity/models/activity.dart';
import 'package:phonics_worksheets/services/openai_service.dart';

void main() {
  group('WordSearchBuilder', () {
    test('places every word exactly once (right or down)', () {
      final words = [
        'ZEBRA',
        'GREEN',
        'SLEEP',
        'TEAM',
        'BEACH',
        'MONKEY',
        'HONEY',
        'EAGLE',
        'STREET',
        'LEAF',
      ];
      final builder = WordSearchBuilder(random: Random(42));
      final rows = builder.build(words, size: 12);
      final activity = VowelActivity.fromGenerated(
        seed: kLongEActivity,
        words: words,
        sentences: kLongEActivity.sentences,
        gridRows: rows,
      );
      final placements = activity.findPlacements();
      expect(placements.length, words.length);
      expect(placements.map((p) => p.word).toSet(), words.toSet());
    });
  });

  group('parseVowelActivityResponse', () {
    test('normalizes words and aligns sentences to the bank', () {
      final parsed = OpenAIService.parseVowelActivityResponse(
        {
          'words': ['bee', 'TREE', 'seat'],
          'sentences': [
            {
              'before': 'Sit in your ',
              'answer': 'seat',
              'after': '.',
            },
            {
              'before': 'A ',
              'answer': 'BEE',
              'after': ' makes honey.',
            },
            {
              'before': 'Climb the ',
              'answer': 'TREE',
              'after': '.',
            },
          ],
        },
        expected: 3,
      );
      expect(parsed.words, ['BEE', 'TREE', 'SEAT']);
      expect(parsed.sentences.map((s) => s.answer).toList(),
          ['BEE', 'TREE', 'SEAT']);
    });

    test('rejects too few usable words', () {
      expect(
        () => OpenAIService.parseVowelActivityResponse(
          {
            'words': ['BEE', 'TREE'],
            'sentences': [],
          },
          expected: 3,
        ),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('ActivityController.replaceActivity', () {
    test('swaps content and clears progress', () {
      final c = ActivityController(kLongEActivity);
      c.tapBlank(0);
      c.tapBankWord('ZEBRA');

      final nextWords = [
        'MEET',
        'SEAT',
        'FEET',
        'HEAT',
        'NEED',
        'KEEP',
        'WEEK',
        'DEEP',
        'SEED',
        'FREE',
      ];
      final nextSentences = [
        for (final w in nextWords) SentenceItem('The word is ', w, '.'),
      ];
      final rows = WordSearchBuilder(random: Random(7)).build(nextWords);
      final next = VowelActivity.fromGenerated(
        seed: kLongEActivity,
        words: nextWords,
        sentences: nextSentences,
        gridRows: rows,
      );

      c.replaceActivity(next);
      expect(c.activity.words, nextWords);
      expect(c.answerFor(0), isNull);
      expect(c.foundWords, isEmpty);
      expect(c.activity.findPlacements().length, nextWords.length);
    });
  });
}
