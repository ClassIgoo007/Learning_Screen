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

    test('DNA quiz accepts one answer per question', () {
      final c = QuizController(kDnaTopic.questions);
      c.select(0, 1); // double helix
      expect(c.isRevealed(0), isTrue);
      expect(c.isCorrect(0), isTrue);
      c.select(0, 0); // locked — should stay correct
      expect(c.selectionFor(0), 1);
    });

    test('photosynthesis blanks accept alternate spellings', () {
      final c = BlanksController(kPhotosynthesisTopic.blankItems);
      c.setAnswer(0, 'carbon dioxide');
      c.check();
      expect(c.isCorrect(0), isTrue);
    });
  });
}
