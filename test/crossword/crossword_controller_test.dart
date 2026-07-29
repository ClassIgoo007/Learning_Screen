import 'dart:math' show Point;

import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/crossword/logic/crossword_controller.dart';
import 'package:phonics_worksheets/features/crossword/models/crossword.dart';

void main() {
  group('CrosswordController', () {
    test('typing fills the selected word and advances the cursor', () {
      final c = CrosswordController(kLongAPuzzle);
      final paint = kLongAPuzzle.across.first; // 1-Across PAINT
      c.selectEntry(paint);
      for (final ch in 'PAINT'.split('')) {
        c.typeLetter(ch);
      }
      expect(c.isEntrySolved(paint), isTrue);
    });

    test('tapping a shared start cell toggles across/down', () {
      final c = CrosswordController(kLongAPuzzle);
      const shared = Point(4, 6); // WHALE across / WAVE down both start here
      c.tapCell(shared);
      final first = c.selected!;
      c.tapCell(shared);
      expect(c.selected, isNot(equals(first)));
    });

    test('check marks wrong letters and reset clears everything', () {
      final c = CrosswordController(kLongAPuzzle);
      final paint = kLongAPuzzle.across.first;
      c.selectEntry(paint);
      c.typeLetter('X');
      c.checkAnswers();
      expect(c.statusAt(paint.cells.first), CellStatus.wrong);
      c.reset();
      expect(c.filledCells, 0);
    });

    test('puzzle solves when every entry is revealed', () {
      final c = CrosswordController(kLongAPuzzle);
      for (final e in kLongAPuzzle.entries) {
        c.selectEntry(e);
        c.revealSelectedWord();
      }
      expect(c.isPuzzleSolved, isTrue);
    });
  });
}
