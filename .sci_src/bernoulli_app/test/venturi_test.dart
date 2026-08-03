import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:bernoulli_venturi/logic/quiz_controller.dart';
import 'package:bernoulli_venturi/models/content.dart';
import 'package:bernoulli_venturi/physics/venturi.dart';

void main() {
  group('continuity', () {
    test('the same volume passes the wide section and the throat', () {
      const m = VenturiModel();
      expect(m.wideArea * m.wideSpeed, closeTo(m.flow, 1e-12));
      expect(m.throatArea * m.throatSpeed, closeTo(m.flow, 1e-12));
    });

    test('speed ratio equals the area ratio and ignores the flow rate', () {
      const a = VenturiModel(flow: 0.004);
      const b = VenturiModel(flow: 0.011);
      expect(a.speedRatio, closeTo(b.speedRatio, 1e-12));
      expect(a.speedRatio, closeTo(a.wideArea / a.throatArea, 1e-12));
    });

    test('halving the throat diameter quadruples the throat speed', () {
      const wide = VenturiModel(throatDiameter: 0.08);
      const half = VenturiModel(throatDiameter: 0.04);
      expect(half.throatSpeed / wide.throatSpeed, closeTo(4.0, 1e-9));
    });
  });

  group("Bernoulli's equation", () {
    test('static + dynamic is the same at both stations', () {
      const m = VenturiModel();
      final wideTotal = m.widePressure + m.wideDynamic;
      final throatTotal = m.throatPressure + m.throatDynamic;
      expect(wideTotal, closeTo(m.totalPressure, 1e-9));
      expect(throatTotal, closeTo(m.totalPressure, 1e-9));
      expect(wideTotal, closeTo(throatTotal, 1e-9));
    });

    test('the figure it is meant to show: faster water, lower pressure', () {
      const m = VenturiModel();
      expect(m.throatSpeed, greaterThan(m.wideSpeed));
      expect(m.throatPressure, lessThan(m.widePressure));
      expect(m.throatHead, lessThan(m.wideHead));
    });

    test('that relationship holds right across the slider range', () {
      for (var i = 0; i <= 10; i++) {
        for (var j = 0; j <= 10; j++) {
          final m = VenturiModel(
            flow: VenturiModel.minFlow +
                (VenturiModel.maxFlow - VenturiModel.minFlow) * i / 10,
            throatDiameter: VenturiModel.minThroat +
                (VenturiModel.maxThroat - VenturiModel.minThroat) * j / 10,
          );
          expect(m.throatSpeed, greaterThanOrEqualTo(m.wideSpeed));
          expect(m.throatPressure, lessThanOrEqualTo(m.widePressure));
          expect(m.widePressure + m.wideDynamic,
              closeTo(m.throatPressure + m.throatDynamic, 1e-6));
        }
      }
    });

    test('no constriction means no pressure drop', () {
      const m = VenturiModel(throatDiameter: 0.10, wideDiameter: 0.10);
      expect(m.speedRatio, closeTo(1.0, 1e-12));
      expect(m.throatPressure, closeTo(m.widePressure, 1e-9));
    });

    test('a column height is the static pressure written as head', () {
      const m = VenturiModel();
      expect(m.wideHead * VenturiModel.rho * VenturiModel.g,
          closeTo(m.widePressure, 1e-9));
    });

    test('enough flow through a tight throat predicts cavitation', () {
      const calm = VenturiModel(flow: 0.003, throatDiameter: 0.08);
      const fierce = VenturiModel(flow: 0.012, throatDiameter: 0.040);
      expect(calm.cavitates, isFalse);
      expect(fierce.cavitates, isTrue);
      expect(fierce.throatPressure, lessThan(0));
    });
  });

  group('pipe geometry', () {
    test('the drawn pipe is narrowest across the throat', () {
      const m = VenturiModel();
      final wide = VenturiGeometry.diameterAt(120, m);
      final throat = VenturiGeometry.diameterAt(450, m);
      expect(wide, closeTo(m.wideDiameter, 1e-9));
      expect(throat, closeTo(m.throatDiameter, 1e-9));
      expect(throat, lessThan(wide));
    });

    test('the profile is smooth and never leaves the two diameters', () {
      const m = VenturiModel();
      double? previous;
      for (var x = VenturiGeometry.pipeLeft;
          x <= VenturiGeometry.pipeRight;
          x += 2) {
        final d = VenturiGeometry.diameterAt(x, m);
        expect(d, lessThanOrEqualTo(m.wideDiameter + 1e-9));
        expect(d, greaterThanOrEqualTo(m.throatDiameter - 1e-9));
        if (previous != null) {
          expect((d - previous).abs(), lessThan(0.002)); // no sudden steps
        }
        previous = d;
      }
    });

    test('local speed is highest in the throat and matches the model', () {
      const m = VenturiModel();
      expect(VenturiGeometry.speedAt(450, m), closeTo(m.throatSpeed, 1e-9));
      expect(VenturiGeometry.speedAt(100, m), closeTo(m.wideSpeed, 1e-9));
      final speeds = [
        for (var x = VenturiGeometry.pipeLeft;
            x <= VenturiGeometry.pipeRight;
            x += 5)
          VenturiGeometry.speedAt(x, m)
      ];
      expect(speeds.reduce(math.max), closeTo(m.throatSpeed, 1e-9));
    });

    test('every standpipe sits over the section it measures', () {
      expect(VenturiGeometry.standX.length, 3);
      final middle = VenturiGeometry.standX[1];
      expect(middle, greaterThanOrEqualTo(VenturiGeometry.throatStart));
      expect(middle, lessThanOrEqualTo(VenturiGeometry.throatEnd));
      for (final i in [0, 2]) {
        final x = VenturiGeometry.standX[i];
        expect(VenturiGeometry.narrowness(x), 0,
            reason: 'outer standpipes must sit over full-width pipe');
      }
    });
  });

  group('quiz', () {
    test('every question has a valid answer index', () {
      for (final q in kQuizQuestions) {
        expect(q.options.length, 3);
        expect(q.answerIndex, greaterThanOrEqualTo(0));
        expect(q.answerIndex, lessThan(q.options.length));
        expect(q.explanation, isNotEmpty);
      }
    });

    test('a correct choice scores and locks the question', () {
      final c = QuizController(kQuizQuestions);
      c.select(0, kQuizQuestions[0].answerIndex);
      expect(c.isCorrect(0), isTrue);
      expect(c.score, 1);
      c.select(0, (kQuizQuestions[0].answerIndex + 1) % 3);
      expect(c.selectionFor(0), kQuizQuestions[0].answerIndex);
    });

    test('answering everything finishes, and reset clears it', () {
      final c = QuizController(kQuizQuestions);
      for (var i = 0; i < c.total; i++) {
        c.select(i, kQuizQuestions[i].answerIndex);
      }
      expect(c.isFinished, isTrue);
      expect(c.score, c.total);
      c.reset();
      expect(c.answeredCount, 0);
      expect(c.score, 0);
    });
  });
}
