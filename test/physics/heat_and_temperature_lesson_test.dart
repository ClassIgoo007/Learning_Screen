import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/physics/heat_and_temperature/data/lesson_data.dart';
import 'package:phonics_worksheets/features/physics/heat_and_temperature/data/reference_data.dart';

void main() {
  group('heat and temperature lesson data', () {
    test('exposes a complete multiple-choice set', () {
      expect(kCryogenicsLesson.choiceQuestions, isNotEmpty);
      expect(kCryogenicsLesson.choiceQuestions.length, 4);
      expect(
        kCryogenicsLesson.choiceQuestions
            .every((question) => question.choices.length >= 2),
        isTrue,
      );
      expect(
        kCryogenicsLesson.choiceQuestions.every(
            (question) => question.choices.contains(question.answer)),
        isTrue,
      );
    });

    test('provides cloze items for the second passage', () {
      expect(kCryogenicsLesson.clozeSentences, isNotEmpty);
      expect(kCryogenicsLesson.clozeSentences.length, 6);
    });

    test('beats span both figures: 1-3 apparatus, 4-5 torch', () {
      final beats =
          kCryogenicsLesson.choiceQuestions.map((q) => q.beat).toSet();
      expect(beats, {1, 2, 3, 5});
      final clozeBeats =
          kCryogenicsLesson.clozeSentences.map((c) => c.beat).toSet();
      expect(clozeBeats, {1, 2, 3, 4, 5});
    });

    test('the 15,000 blank accepts its listed alternatives', () {
      final item = kCryogenicsLesson.clozeSentences
          .firstWhere((c) => c.answer == '15,000');
      expect(item.isCorrect('15000'), isTrue);
      expect(item.isCorrect('15 000'), isTrue);
      expect(item.isCorrect('15,000.'), isTrue);
    });
  });

  group('reference tables', () {
    test('gas table has 5 rows within its own axis bounds', () {
      expect(kGasTable.rows.length, 5);
      for (final row in kGasTable.rows) {
        expect(row.first, greaterThanOrEqualTo(kGasTable.axisMin));
        expect(row.second, greaterThanOrEqualTo(kGasTable.axisMin));
        expect(row.first, lessThanOrEqualTo(kGasTable.axisMax));
        expect(row.second, lessThanOrEqualTo(kGasTable.axisMax));
      }
    });

    test('metal table has 7 rows within its own axis bounds', () {
      expect(kMetalTable.rows.length, 7);
      for (final row in kMetalTable.rows) {
        expect(row.first, greaterThanOrEqualTo(kMetalTable.axisMin));
        expect(row.second, greaterThanOrEqualTo(kMetalTable.axisMin));
        expect(row.first, lessThanOrEqualTo(kMetalTable.axisMax));
        expect(row.second, lessThanOrEqualTo(kMetalTable.axisMax));
      }
    });

    test('fractionOf is clamped to 0..1 even outside the axis', () {
      expect(kGasTable.fractionOf(kGasTable.axisMin - 100), 0.0);
      expect(kGasTable.fractionOf(kGasTable.axisMax + 100), 1.0);
    });
  });
}
