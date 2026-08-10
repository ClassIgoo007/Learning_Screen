import 'dart:math' show Point;

import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/crossword/logic/crossword_controller.dart';
import 'package:phonics_worksheets/features/crossword/models/crossword.dart';

void main() {
  final puzzles = <String, CrosswordPuzzle>{
    'Long o': kLongOPuzzle,
    'Long i': kLongIPuzzle,
    'oi & oy': kOiOyPuzzle,
  };

  puzzles.forEach((label, puzzle) {
    group(label, () {
      test('intersecting entries agree on shared letters', () {
        final cells = <Point<int>, String>{};
        for (final e in puzzle.entries) {
          for (var i = 0; i < e.length; i++) {
            final pos = e.cells[i];
            expect(cells[pos] ?? e.answer[i], e.answer[i],
                reason: 'conflict at $pos');
            cells[pos] = e.answer[i];
          }
        }
      });

      test('every cell stays inside the grid bounds', () {
        for (final e in puzzle.entries) {
          for (final pos in e.cells) {
            expect(pos.x, inInclusiveRange(0, puzzle.rows - 1));
            expect(pos.y, inInclusiveRange(0, puzzle.cols - 1));
          }
        }
      });

      test('puzzle solves when every entry is revealed', () {
        final c = CrosswordController(puzzle);
        for (final e in puzzle.entries) {
          c.selectEntry(e);
          c.revealSelectedWord();
        }
        expect(c.isPuzzleSolved, isTrue);
      });
    });
  });
}
