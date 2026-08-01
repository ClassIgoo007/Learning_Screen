import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/science/data/biology_topics.dart';
import 'package:phonics_worksheets/features/science/data/dna_topic.dart';
import 'package:phonics_worksheets/features/science/data/photosynthesis_topic.dart';
import 'package:phonics_worksheets/features/science/logic/controllers.dart';

void main() {
  group('biology topics', () {
    test('each topic has questions and blank items', () {
      for (final topic in kBiologyTopics) {
        expect(topic.questions, isNotEmpty);
        expect(topic.blankItems, isNotEmpty);
        expect(topic.wordBank, isNotEmpty);
      }
    });

    test('quiz selects without grading until check', () {
      final c = QuizController(kDnaTopic.questions);
      c.select(0, 1); // double helix
      expect(c.isRevealed(0), isFalse);
      expect(c.selectionFor(0), 1);
      c.select(0, 0); // can change before check
      expect(c.selectionFor(0), 0);
      c.select(0, 1);
      c.check();
      expect(c.isRevealed(0), isTrue);
      expect(c.isCorrect(0), isTrue);
      expect(c.wrongCount, 0);
    });

    test('quiz reports wrong answers after check', () {
      final c = QuizController(kDnaTopic.questions);
      c.select(0, 0); // wrong for DNA shape
      c.check();
      expect(c.isCorrect(0), isFalse);
      expect(c.wrongCount, 1);
    });

    test('photosynthesis blanks accept alternate spellings', () {
      final c = BlanksController(kPhotosynthesisTopic.blankItems);
      c.setAnswer(0, 'carbon dioxide');
      c.check();
      expect(c.isCorrect(0), isTrue);
    });

    test('blanks report wrong answers after check', () {
      final c = BlanksController(kPhotosynthesisTopic.blankItems);
      c.setAnswer(0, 'not-the-answer');
      c.check();
      expect(c.isCorrect(0), isFalse);
      expect(c.wrongCount, 1);
    });
  });
}
