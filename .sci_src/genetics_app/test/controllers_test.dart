import 'package:flutter_test/flutter_test.dart';
import 'package:dna_reading_activities/logic/controllers.dart';
import 'package:dna_reading_activities/models/content.dart';

void main() {
  group('content integrity', () {
    test('every quiz question has a valid answer index', () {
      for (final q in kQuizQuestions) {
        expect(q.answerIndex, greaterThanOrEqualTo(0));
        expect(q.answerIndex, lessThan(q.options.length));
        expect(q.options.length, 3);
      }
    });

    test('every blank accepts its own canonical answer', () {
      for (final b in kBlankItems) {
        expect(b.accepted, isNotEmpty);
        expect(b.accepts(b.answer), isTrue);
      }
    });

    test('each passage carries text and a diagram asset', () {
      for (final p in [kPassageOne, kPassageTwo]) {
        expect(p.text.length, greaterThan(200));
        expect(p.asset, startsWith('assets/'));
      }
    });

    test('every blank answer appears in its passage', () {
      // The exercise is comprehension, so each answer must be findable in
      // the text the learner just read.
      final passage = kPassageTwo.text.toLowerCase();
      for (final b in kBlankItems) {
        final found = b.accepted
            .any((a) => passage.contains(a.toLowerCase()));
        expect(found, isTrue,
            reason: '"${b.answer}" is not present in Passage 2');
      }
    });
  });

  group('QuizController', () {
    test('scores a correct choice and locks the question', () {
      final c = QuizController(kQuizQuestions);
      c.select(0, kQuizQuestions[0].answerIndex); // 0 = double helix
      expect(c.isCorrect(0), isTrue);
      expect(c.score, 1);

      // A second tap must not overwrite the locked answer.
      final wrong = (kQuizQuestions[0].answerIndex + 1) % 3;
      c.select(0, wrong);
      expect(c.selectionFor(0), kQuizQuestions[0].answerIndex);
    });

    test('finishes when every question is answered, and resets', () {
      final c = QuizController(kQuizQuestions);
      for (var i = 0; i < c.total; i++) {
        c.select(i, kQuizQuestions[i].answerIndex);
      }
      expect(c.isFinished, isTrue);
      expect(c.score, c.total);
      c.reset();
      expect(c.answeredCount, 0);
    });
  });

  group('BlanksController', () {
    test('grading ignores case, spaces and punctuation', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(0, '  Chromosomes! '); // 0 = chromosomes
      expect(c.isCorrect(0), isTrue);
    });

    test('accepts digits or words for the numbers', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(6, '46'); // 6 = 46 chromosomes
      expect(c.isCorrect(6), isTrue);
      c.setAnswer(6, 'forty-six');
      expect(c.isCorrect(6), isTrue);
      c.setAnswer(7, 'twenty three'); // 7 = 23 pairs
      expect(c.isCorrect(7), isTrue);
    });

    test('accepts singular or plural where both read naturally', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(2, 'protein'); // 2 = proteins
      expect(c.isCorrect(2), isTrue);
    });

    test('marks a plausible but wrong word incorrect', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(4, 'gene'); // 4 = centromere
      expect(c.isCorrect(4), isFalse);
    });

    test('typing after checking clears the stale feedback', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(0, 'chromosomes');
      c.check();
      expect(c.checked, isTrue);
      c.setAnswer(0, 'genes');
      expect(c.checked, isFalse);
    });

    test('revealing fills the canonical answer', () {
      final c = BlanksController(kBlankItems);
      c.revealAnswer(10); // 10 = genome
      expect(c.answerFor(10), kBlankItems[10].answer);
      expect(c.isCorrect(10), isTrue);
    });

    test('all answers correct gives a full score', () {
      final c = BlanksController(kBlankItems);
      for (var i = 0; i < c.total; i++) {
        c.setAnswer(i, kBlankItems[i].answer);
      }
      c.check();
      expect(c.allCorrect, isTrue);
      expect(c.score, kBlankItems.length);
    });
  });
}
