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
    test('dragging across a word run marks it found (either direction)', () {
      final c = ActivityController(kLongEActivity);
      final placement = kLongEActivity
          .findPlacements()
          .firstWhere((p) => p.word == 'TEAM');
      c.selectWordRun(placement.cells.last, placement.cells.first);
      expect(c.isWordFound('TEAM'), isTrue);
    });

    test('non-word selection finds nothing', () {
      final c = ActivityController(kLongEActivity);
      c.selectWordRun(const Point(0, 0), const Point(0, 3));
      expect(c.foundWords, isEmpty);
    });

    test('crossing a word fills the matching empty sentence', () {
      final c = ActivityController(kLongEActivity);
      final placement = kLongEActivity
          .findPlacements()
          .firstWhere((p) => p.word == 'TEAM');
      c.selectWordRun(placement.cells.first, placement.cells.last);
      expect(c.isWordFound('TEAM'), isTrue);
      expect(c.answerFor(3), 'TEAM'); // sentence 3 answer is TEAM
    });

    test('crossing fills the selected blank even if it is a different word',
        () {
      final c = ActivityController(kLongEActivity);
      c.tapBlank(0); // expects ZEBRA
      final placement = kLongEActivity
          .findPlacements()
          .firstWhere((p) => p.word == 'TEAM');
      c.selectWordRun(placement.cells.first, placement.cells.last);
      expect(c.answerFor(0), 'TEAM');
      expect(c.isWordFound('TEAM'), isTrue);
    });

    test('completing everything sets isComplete', () {
      final c = ActivityController(kLongEActivity);
      for (final (i, s) in kLongEActivity.sentences.indexed) {
        c.tapBlank(i);
        c.tapBankWord(s.answer);
      }
      for (final p in kLongEActivity.findPlacements()) {
        c.selectWordRun(p.cells.first, p.cells.last);
      }
      expect(c.isComplete, isTrue);
    });
  });
}
