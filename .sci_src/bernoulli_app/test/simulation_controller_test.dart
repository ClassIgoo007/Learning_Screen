import 'package:flutter_test/flutter_test.dart';

import 'package:bernoulli_venturi/physics/venturi.dart';
import 'package:bernoulli_venturi/state/simulation_controller.dart';

void main() {
  group('SimulationController', () {
    test('clamps the flow into range instead of asserting', () {
      final c = SimulationController();
      c.flow = 99;
      expect(c.model.flow, VenturiModel.maxFlow);
      c.flow = -5;
      expect(c.model.flow, VenturiModel.minFlow);
    });

    test('never lets the throat grow wider than the pipe', () {
      final c = SimulationController(
        model: const VenturiModel(wideDiameter: 0.06, throatDiameter: 0.05),
      );
      c.throatDiameter = 0.5;
      expect(c.model.throatDiameter, lessThanOrEqualTo(0.06));
      expect(c.model.throatDiameter, greaterThan(0));
    });

    test('only notifies when something actually changed', () {
      final c = SimulationController();
      var notifications = 0;
      c.addListener(() => notifications++);

      c.flow = c.model.flow; // same value
      expect(notifications, 0);

      c.flow = c.model.flow + 0.001;
      expect(notifications, 1);
    });

    test('detects a straight pipe', () {
      final c = SimulationController(
        model: const VenturiModel(throatDiameter: 0.10),
      );
      expect(c.isStraightPipe, isTrue);
      c.throatDiameter = 0.05;
      expect(c.isStraightPipe, isFalse);
    });

    test('reset returns every setting to its default', () {
      final c = SimulationController()
        ..flow = VenturiModel.maxFlow
        ..throatDiameter = VenturiModel.minThroat
        ..setShowStreamlines(false)
        ..setRunning(false);

      c.reset();

      expect(c.model, const VenturiModel());
      expect(c.running, isTrue);
      expect(c.showStreamlines, isTrue);
    });

    group('spoken description', () {
      test('names both speeds and both pressures', () {
        final c = SimulationController();
        final text = c.describe();
        expect(text, contains('Venturi tube'));
        expect(text, contains('metres per second'));
        expect(text, contains('kilopascals'));
        expect(text, contains('lower'));
      });

      test('explains a levelled pipe', () {
        final c = SimulationController(
          model: const VenturiModel(throatDiameter: 0.10),
        );
        expect(c.describe(), contains('stand level'));
      });

      test('explains cavitation', () {
        final c = SimulationController(
          model: const VenturiModel(flow: 0.012, throatDiameter: 0.040),
        );
        expect(c.describe(), contains('cavitate'));
      });
    });
  });

  group('VenturiModel.sanitised', () {
    test('repairs out-of-range and non-finite input', () {
      final m = VenturiModel.sanitised(
        flow: double.nan,
        throatDiameter: double.infinity,
      );
      expect(m.flow, VenturiModel.minFlow);
      expect(m.throatDiameter.isFinite, isTrue);
      expect(m.throatDiameter, lessThanOrEqualTo(m.wideDiameter));
    });

    test('never produces a throat wider than the pipe', () {
      final m = VenturiModel.sanitised(
        flow: 0.008,
        throatDiameter: 5.0,
        wideDiameter: 0.07,
      );
      expect(m.throatDiameter, lessThanOrEqualTo(m.wideDiameter));
      expect(m.throatSpeed.isFinite, isTrue);
      expect(m.throatPressure.isFinite, isTrue);
    });
  });
}
