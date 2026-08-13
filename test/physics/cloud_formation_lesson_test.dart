import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/physics/cloud_formation/data/lesson_data.dart';

void main() {
  group('cloud formation lesson data', () {
    test('exposes a complete multiple-choice set', () {
      expect(kCloudLesson.choiceQuestions, isNotEmpty);
      expect(kCloudLesson.choiceQuestions.length, 4);
      expect(
        kCloudLesson.choiceQuestions.every((question) => question.choices.length >= 2),
        isTrue,
      );
      expect(
        kCloudLesson.choiceQuestions.every((question) => question.choices.contains(question.answer)),
        isTrue,
      );
    });

    test('provides cloze items for the second passage', () {
      expect(kCloudLesson.clozeSentences, isNotEmpty);
      expect(kCloudLesson.clozeSentences.length, 6);
    });
  });
}
