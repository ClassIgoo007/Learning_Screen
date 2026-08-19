import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/physics/kinetic_theory/animation/kinetic_timeline.dart';

void main() {
  group('VesselState', () {
    test('compression alone does not change molecular speed', () {
      const cold = VesselState(t: 5, compression: 0, heat: 0);
      const squeezed = VesselState(t: 5, compression: 1, heat: 0);
      expect(squeezed.speed, cold.speed);
    });

    test('heat alone raises molecular speed', () {
      const cold = VesselState(t: 5, compression: 0, heat: 0);
      const hot = VesselState(t: 5, compression: 0, heat: 1);
      expect(hot.speed, greaterThan(cold.speed));
    });

    test('reducing volume at constant temperature raises pressure', () {
      const relaxed = VesselState(t: 0, compression: 0, heat: 0);
      const squeezed = VesselState(t: 0, compression: 1, heat: 0);
      expect(squeezed.pressure, greaterThan(relaxed.pressure));
      expect(squeezed.volumeFraction, lessThan(relaxed.volumeFraction));
    });

    test('raising temperature at full volume raises pressure and speed', () {
      const cold = VesselState(t: 0, compression: 0, heat: 0);
      const hot = VesselState(t: 0, compression: 0, heat: 1);
      expect(hot.speed, greaterThan(cold.speed));
      expect(hot.pressure, greaterThan(cold.pressure));
    });

    test('motion uses constant canvas speed when only volume shrinks', () {
      final m = VesselMetrics.molecules.first;
      const t0 = 2.0;
      const dt = 0.05;

      final relaxed0 = VesselState(t: t0, compression: 0, heat: 0);
      final relaxed1 = VesselState(t: t0 + dt, compression: 0, heat: 0);
      final squeezed0 = VesselState(t: t0, compression: 1, heat: 0);
      final squeezed1 = VesselState(t: t0 + dt, compression: 1, heat: 0);

      final relaxedSpeed =
          (relaxed1.positionOf(m) - relaxed0.positionOf(m)).distance / dt;
      final squeezedSpeed =
          (squeezed1.positionOf(m) - squeezed0.positionOf(m)).distance / dt;

      expect(squeezedSpeed, closeTo(relaxedSpeed, relaxedSpeed * 0.15));
    });
  });
}
