import 'dart:math' show Point;

import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/activity/logic/activity_controller.dart';
import 'package:phonics_worksheets/features/activity/models/activity.dart';

void main() {
  group('activity data', () {
    test('every word has exactly one placement in the grid', () {
      final placements = kLongEActivity.findPlacements();
      expect(placements.length, kLongEActivity.words.length);
      expect(placements.map((p) => p.word).toSet(),
          kLongEActivity.words.toSet());
    });
  });

  group('sentences', () {
    test('tapping bank word fills the active blank and advances', () {
      final c = ActivityController(kLongEActivity);
      c.tapBlank(0);
      c.tapBankWord('ZEBRA');
      expect(c.answerFor(0), 'ZEBRA');
      expect(c.activeSentence, 1); // auto-advanced to next empty blank
    });

    test('check marks wrong answers', () {
      final c = ActivityController(kLongEActivity);
      c.tapBlank(0);
      c.tapBankWord('HONEY'); // wrong for sentence 0
      c.checkSentences();
      expect(c.blankStatus(0), BlankStatus.wrong);
    });
  });

  group('word search', () {
    test('selecting a word run marks it found (either tap order)', () {
      final c = ActivityController(kLongEActivity);
      final placement = kLongEActivity
          .findPlacements()
          .firstWhere((p) => p.word == 'TEAM');
      c.tapGridCell(placement.cells.last); // backwards on purpose
      c.tapGridCell(placement.cells.first);
      expect(c.isWordFound('TEAM'), isTrue);
    });

    test('non-word selection finds nothing', () {
      final c = ActivityController(kLongEActivity);
      c.tapGridCell(const Point(0, 0));
      c.tapGridCell(const Point(0, 3));
      expect(c.foundWords, isEmpty);
    });

    test('completing everything sets isComplete', () {
      final c = ActivityController(kLongEActivity);
      for (final (i, s) in kLongEActivity.sentences.indexed) {
        c.tapBlank(i);
        c.tapBankWord(s.answer);
      }
      for (final p in kLongEActivity.findPlacements()) {
        c.tapGridCell(p.cells.first);
        c.tapGridCell(p.cells.last);
      }
      expect(c.isComplete, isTrue);
    });
  });
}
