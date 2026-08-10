import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/crossword/logic/crossword_builder.dart';
import 'package:phonics_worksheets/features/crossword/models/crossword.dart';
import 'package:phonics_worksheets/services/openai_service.dart';

void main() {
  group('CrosswordBuilder', () {
    test('places every word and keeps seed branding', () {
      final words = [
        'PAINT',
        'NAME',
        'TRAIL',
        'WHALE',
        'WAVE',
        'PLACE',
        'PLAIN',
        'BRAIN',
        'RAIL',
      ];
      final clues = [for (final w in words) 'clue for $w'];
      final puzzle = CrosswordBuilder(random: Random(42)).build(
        seed: kLongAPuzzle,
        words: words,
        clues: clues,
      );

      expect(puzzle.name, kLongAPuzzle.name);
      expect(puzzle.image, kLongAPuzzle.image);
      expect(puzzle.entries.length, words.length);
      expect(
        puzzle.entries.map((e) => e.answer).toSet(),
        words.toSet(),
      );
      // Every cell letter matches the solution map.
      for (final e in puzzle.entries) {
        for (var i = 0; i < e.length; i++) {
          expect(puzzle.solutionAt(e.cells[i]), e.answer[i]);
        }
      }
    });
  });

  group('parseCrosswordPuzzleResponse', () {
    test('normalizes answers and clues', () {
      final parsed = OpenAIService.parseCrosswordPuzzleResponse(
        {
          'words': [
            {'answer': 'paint', 'clue': 'use with a brush'},
            {'answer': 'NAME', 'clue': 'what people call you'},
            {'answer': 'RAIL', 'clue': 'train track metal'},
          ],
        },
        expected: 3,
      );
      expect(parsed.words, ['PAINT', 'NAME', 'RAIL']);
      expect(parsed.clues.length, 3);
    });
  });
}
