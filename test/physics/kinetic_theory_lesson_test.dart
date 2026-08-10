import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/physics/kinetic_theory/data/lesson_data.dart';

void main() {
  group('kinetic theory lesson data', () {
    test('exposes a complete multiple-choice set', () {
      expect(kKineticLesson.choiceQuestions, isNotEmpty);
      expect(kKineticLesson.choiceQuestions.length, 4);
      expect(
        kKineticLesson.choiceQuestions
            .every((question) => question.choices.length >= 2),
        isTrue,
      );
      expect(
        kKineticLesson.choiceQuestions.every(
            (question) => question.choices.contains(question.answer)),
        isTrue,
      );
    });

    test('provides cloze items for the second passage', () {
      expect(kKineticLesson.clozeSentences, isNotEmpty);
      expect(kKineticLesson.clozeSentences.length, 6);
    });

    test('beats 1-3 belong to the vessel and 4-5 to the apparatus', () {
      final beats =
          kKineticLesson.choiceQuestions.map((q) => q.beat).toSet();
      expect(beats, {1, 2, 3, 5});
    });

    test('every cloze answer is accepted case-insensitively with trailing punctuation', () {
      for (final item in kKineticLesson.clozeSentences) {
        expect(item.isCorrect('${item.answer.toUpperCase()}.'), isTrue);
      }
    });
  });
}
