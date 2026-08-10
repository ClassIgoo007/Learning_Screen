import 'package:flutter_test/flutter_test.dart';
import 'package:heat_and_temperature/animation/cryo_timeline.dart';
import 'package:heat_and_temperature/app.dart';
import 'package:heat_and_temperature/data/lesson_data.dart';
import 'package:heat_and_temperature/data/reference_data.dart';
import 'package:heat_and_temperature/models/lesson.dart';
import 'package:heat_and_temperature/models/reference_table.dart';

void main() {
  group('cloze marking', () {
    const item = ClozeSentence(
      beat: 1,
      before: 'It reaches almost',
      after: '°C.',
      answer: '15,000',
      alsoAccept: ['15000'],
    );

    test('accepts the exact answer', () {
      expect(item.isCorrect('15,000'), isTrue);
    });

    test('accepts a listed alternative and ignores surrounding space', () {
      expect(item.isCorrect('  15000 '), isTrue);
    });

    test('ignores case and a trailing full stop', () {
      const word = ClozeSentence(
        beat: 1,
        before: 'a stream of',
        after: 'gas',
        answer: 'noble',
      );
      expect(word.isCorrect('Noble.'), isTrue);
    });

    test('rejects an empty answer and a wrong one', () {
      expect(item.isCorrect(''), isFalse);
      expect(item.isCorrect('1500'), isFalse);
    });
  });

  group('lesson data', () {
    test('every question names a beat that exists', () {
      for (final q in kCryogenicsLesson.choiceQuestions) {
        expect(CryoStage.fromBeat(q.beat).beat, q.beat);
      }
      for (final c in kCryogenicsLesson.clozeSentences) {
        expect(CryoStage.fromBeat(c.beat).beat, c.beat);
      }
    });

    test('every question answer is one of its own choices', () {
      for (final q in kCryogenicsLesson.choiceQuestions) {
        expect(q.choices, contains(q.answer));
      }
    });

    test('reference rows survive a JSON round trip', () {
      for (final row in kGasTable.rows) {
        final copy = SubstanceReading.fromJson(row.toJson());
        expect(copy.substance, row.substance);
        expect(copy.first, row.first);
        expect(copy.second, row.second);
      }
    });

    test('a gas always freezes below the point at which it liquefies', () {
      for (final row in kGasTable.rows) {
        expect(row.second, lessThan(row.first));
      }
    });
  });

  group('scene state', () {
    test('the valve is shut on beat 1 and open from beat 2', () {
      expect(const CryoState(t: 0.0, stage: 1.0).valveOpen, 0);
      expect(const CryoState(t: 0.0, stage: 2.0).valveOpen, 1);
      expect(const CryoState(t: 0.0, stage: 3.0).valveOpen, 1);
    });

    test('heat leaves the hot chamber on beat 1 and enters the cold one on '
        'beat 2', () {
      const compressing = CryoState(t: 0.0, stage: 1.0);
      const expanding = CryoState(t: 0.0, stage: 2.0);
      expect(compressing.heatOutStrength,
          greaterThan(compressing.heatInStrength));
      expect(expanding.heatInStrength, greaterThan(expanding.heatOutStrength));
    });

    test('the plasma reading climbs with the discharge', () {
      const struck = PlasmaState(t: 0.0, intensity: 0.0);
      const full = PlasmaState(t: 0.0, intensity: 1.0);
      expect(full.temperature, greaterThan(struck.temperature));
      expect(full.temperature.round(), 15000);
    });

    test('streak progress always stays inside the plume', () {
      const s = Streak(0.4, 1.1, 0.2);
      for (final t in [0.0, 0.25, 0.5, 0.99]) {
        final u = PlasmaState(t: t, intensity: 1.0).streakProgress(s);
        expect(u, inInclusiveRange(0, 1));
      }
    });
  });

  group('shell', () {
    testWidgets('opens on the animation tab and can reach every screen',
        (tester) async {
      await tester.pumpWidget(const HeatAndTemperatureApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Heat and temperature'), findsOneWidget);

      await tester.tap(find.text('Questions'));
      await tester.pumpAndSettle();
      expect(find.text('The principle of cryogenics'), findsOneWidget);

      await tester.tap(find.text('Blanks'));
      await tester.pumpAndSettle();
      expect(find.text('Very hot and very cold'), findsOneWidget);

      await tester.tap(find.text('Tables'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Liquefying and freezing points'),
          findsOneWidget);
      expect(find.text('Helium'), findsOneWidget);
    });

    testWidgets('marking refuses an incomplete question set', (tester) async {
      await tester.pumpWidget(const HeatAndTemperatureApp());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Questions'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check answers'));
      await tester.pump();
      expect(find.text('Answer every question first.'), findsOneWidget);
    });
  });
}
