import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/services/openai_service.dart';

void main() {
  group('parseCrosswordCluesResponse', () {
    test('accepts indexed objects even when one is missing', () {
      final parsed = OpenAIService.parseCrosswordCluesResponse(
        [
          {'index': 1, 'answer': 'PAINT', 'clue': 'Use a brush with this'},
          {'index': 2, 'answer': 'NAME', 'clue': 'What people call you'},
          // skip 3
          {'index': 4, 'answer': 'TRAIL', 'clue': 'A path through woods'},
        ],
        4,
      );
      expect(parsed, [
        'Use a brush with this',
        'What people call you',
        '',
        'A path through woods',
      ]);
    });

    test('accepts legacy string arrays shorter than expected', () {
      final parsed = OpenAIService.parseCrosswordCluesResponse(
        ['a', 'b', 'c'],
        5,
      );
      expect(parsed, ['a', 'b', 'c', '', '']);
    });

    test('fills gaps sequentially when indexes are absent', () {
      final parsed = OpenAIService.parseCrosswordCluesResponse(
        [
          {'clue': 'one'},
          {'clue': 'two'},
          {'clue': 'three'},
        ],
        4,
      );
      expect(parsed[0], 'one');
      expect(parsed[1], 'two');
      expect(parsed[2], 'three');
      expect(parsed[3], '');
    });
  });

  group('mergeCrosswordClues', () {
    test('keeps originals for missing AI clues so count always matches', () {
      final merged = OpenAIService.mergeCrosswordClues(
        original: [
          'old1',
          'old2',
          'old3',
          'old4',
          'old5',
          'old6',
          'old7',
          'old8',
          'old9',
        ],
        generated: [
          'new1',
          'new2',
          'new3',
          'new4',
          'new5',
          'new6',
          'new7',
          'new8',
          '', // AI returned only 8
        ],
      );
      expect(merged.length, 9);
      expect(merged[7], 'new8');
      expect(merged[8], 'old9');
    });
  });
}
