import 'package:flutter_test/flutter_test.dart';
import 'package:photosynthesis_learning/logic/controllers.dart';
import 'package:photosynthesis_learning/models/content.dart';

void main() {
  group('content integrity', () {
    test('every quiz question has a valid answer index', () {
      for (final q in kQuizQuestions) {
        expect(q.answerIndex, greaterThanOrEqualTo(0));
        expect(q.answerIndex, lessThan(q.options.length));
        expect(q.options.length, 3);
      }
    });

    test('every blank has at least one accepted spelling', () {
      for (final b in kBlankItems) {
        expect(b.accepted, isNotEmpty);
        expect(b.accepts(b.answer), isTrue);
      }
    });
  });

  group('QuizController', () {
    test('scores a correct choice and locks the question', () {
      final c = QuizController(kQuizQuestions);
      c.select(0, kQuizQuestions[0].answerIndex);
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
      c.setAnswer(1, '  Carbon-Dioxide! ');
      expect(c.isCorrect(1), isTrue);
    });

    test('accepts alternative spellings such as the formula', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(1, 'CO2');
      expect(c.isCorrect(1), isTrue);
      c.setAnswer(3, 'O₂');
      expect(c.isCorrect(3), isTrue);
    });

    test('marks a wrong word incorrect', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(1, 'oxygen');
      expect(c.isCorrect(1), isFalse);
    });

    test('typing after checking clears the stale feedback', () {
      final c = BlanksController(kBlankItems);
      c.setAnswer(0, 'sunlight');
      c.check();
      expect(c.checked, isTrue);
      c.setAnswer(0, 'sun');
      expect(c.checked, isFalse);
    });

    test('revealing fills the canonical answer', () {
      final c = BlanksController(kBlankItems);
      c.revealAnswer(5);
      expect(c.answerFor(5), kBlankItems[5].answer);
      expect(c.isCorrect(5), isTrue);
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
