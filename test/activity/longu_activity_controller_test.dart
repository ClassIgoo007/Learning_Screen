import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/activity/logic/activity_controller.dart';
import 'package:phonics_worksheets/features/activity/models/activity.dart';

void main() {
  group('long-u activity data', () {
    test('every word has exactly one placement in the grid', () {
      final placements = kLongUActivity.findPlacements();
      expect(placements.length, kLongUActivity.words.length);
      expect(placements.map((p) => p.word).toSet(),
          kLongUActivity.words.toSet());
    });
  });

  group('sentences', () {
    test('tapping bank word fills the active blank and advances', () {
      final c = ActivityController(kLongUActivity);
      c.tapBlank(0);
      c.tapBankWord('UNIFORM');
      expect(c.answerFor(0), 'UNIFORM');
      expect(c.activeSentence, 1); // auto-advanced to next empty blank
    });

    test('check marks wrong answers', () {
      final c = ActivityController(kLongUActivity);
      c.tapBlank(0);
      c.tapBankWord('BUGLE'); // wrong for sentence 0
      c.checkSentences();
      expect(c.blankStatus(0), BlankStatus.wrong);
    });
  });

  group('word search', () {
    test('dragging across a word run marks it found (either direction)', () {
      final c = ActivityController(kLongUActivity);
      final placement = kLongUActivity
          .findPlacements()
          .firstWhere((p) => p.word == 'MENU');
      c.selectWordRun(placement.cells.last, placement.cells.first);
      expect(c.isWordFound('MENU'), isTrue);
    });

    test('completing everything sets isComplete', () {
      final c = ActivityController(kLongUActivity);
      for (final (i, s) in kLongUActivity.sentences.indexed) {
        c.tapBlank(i);
        c.tapBankWord(s.answer);
      }
      for (final p in kLongUActivity.findPlacements()) {
        c.selectWordRun(p.cells.first, p.cells.last);
      }
      expect(c.isComplete, isTrue);
    });
  });
}
