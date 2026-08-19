import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// The five beats of the lesson. Beats 1–3 belong to the closed vessel of
/// Fig. 8-8, beats 4–5 to Brown's ping-pong apparatus of Fig. 8-9.
enum KineticStage {
  bombardment(
    1,
    'Bombardment',
    'Fig. 8-8',
    'The molecules rush ceaselessly in all directions, bouncing off the walls. '
        'Pressure is nothing but the continuous bombardment of a unit area A.',
  ),
  reducedVolume(
    2,
    'Volume reduced',
    'Fig. 8-8',
    'Hold the velocity of the molecules constant and squeeze the vessel: the '
        'same molecules strike A more often, so pressure rises in inverse '
        'proportion to the volume.',
  ),
  raisedTemperature(
    3,
    'Temperature raised',
    'Fig. 8-8',
    'Warm the gas and the molecules move faster. They hit the wall both more '
        'often and harder, so at a given volume pressure follows the absolute '
        'temperature.',
  ),
  slowWheel(
    4,
    'Wheel turning slowly',
    'Fig. 8-9',
    'In Brown\u2019s model a cogwheel kicks ping-pong balls between two glass '
        'plates. Turning slowly, most balls stay near the floor and only a few '
        'are thrown high — a liquid evaporating.',
  ),
  fastWheel(
    5,
    'Wheel turning fast',
    'Fig. 8-9',
    'Speed the wheel up and the kinetic energy of the balls rises, as raising '
        'the temperature does. Their bombardment lifts the piston and holds it '
        'there: the balls are behaving as a gas.',
  );

  const KineticStage(this.beat, this.label, this.figure, this.caption);

  final int beat;
  final String label;
  final String figure;
  final String caption;

  /// Beats 1–3 are the vessel; 4–5 are the apparatus.
  bool get isVessel => beat <= 3;

  static KineticStage fromBeat(int beat) =>
      values.firstWhere((s) => s.beat == beat, orElse: () => bombardment);
}

/// Reflects [value] back and forth between [min] and [max] instead of wrapping
/// it, which is exactly what a molecule does between two walls — and keeps the
/// whole simulation a pure function of the clock.
double foldBetween(double value, double min, double max) {
  final span = max - min;
  if (span <= 0) return min;
  final period = span * 2;
  var u = (value - min) % period;
  if (u < 0) u += period;
  return min + (u <= span ? u : period - u);
}

/// True while [value] is on the outward leg, used to point the arrow the way
/// the molecule is actually travelling.
bool foldRising(double value, double min, double max) {
  final span = max - min;
  if (span <= 0) return true;
  final period = span * 2;
  var u = (value - min) % period;
  if (u < 0) u += period;
  return u <= span;
}

/// Geometry of the closed vessel, on a fixed 1000 x 760 canvas.
class VesselMetrics {
  const VesselMetrics._();

  static const canvas = Size(1000, 760);

  static const left = 140.0;
  static const top = 200.0;
  static const bottom = 640.0;

  /// The right wall travels inward as the vessel is compressed.
  static const rightRelaxed = 620.0;
  static const rightSqueezed = 470.0;

  /// Offset to the back face of the box in the oblique projection.
  static const depth = Offset(150, -112);

  /// The unit area the text calls A.
  static const areaA = Rect.fromLTWH(140, 268, 14, 96);

  /// One molecule: where it starts, how fast it goes, and how far it strays.
  static const molecules = <Molecule>[
    Molecule(0.12, 0.62, 0.41, 0.29),
    Molecule(0.55, 0.18, -0.34, 0.46),
    Molecule(0.78, 0.83, -0.52, -0.23),
    Molecule(0.31, 0.44, 0.27, -0.51),
    Molecule(0.66, 0.35, 0.48, 0.33),
    Molecule(0.20, 0.90, 0.36, -0.44),
    Molecule(0.88, 0.55, -0.29, 0.52),
    Molecule(0.44, 0.72, -0.46, -0.31),
    Molecule(0.05, 0.28, 0.53, 0.24),
    Molecule(0.72, 0.10, -0.38, 0.49),
    Molecule(0.37, 0.16, 0.44, 0.36),
    Molecule(0.94, 0.68, -0.25, -0.47),
    Molecule(0.60, 0.95, 0.32, -0.28),
    Molecule(0.16, 0.48, -0.49, 0.41),
  ];
}

class Molecule {
  const Molecule(this.x0, this.y0, this.vx, this.vy);

  /// Start position as a fraction of the box, and velocity in box-widths per
  /// second at unit temperature.
  final double x0, y0, vx, vy;
}

/// Everything the vessel painter needs.
@immutable
class VesselState {
  const VesselState({
    required this.t,
    required this.compression,
    required this.heat,
  });

  /// Seconds since the animation began, so molecules keep travelling instead
  /// of resetting each loop.
  final double t;

  /// 0 = full vessel, 1 = squeezed.
  final double compression;

  /// 0 = the original temperature, 1 = hot.
  final double heat;

  double get right => VesselMetrics.rightRelaxed +
      (VesselMetrics.rightSqueezed - VesselMetrics.rightRelaxed) * compression;

  double get width => right - VesselMetrics.left;
  double get height => VesselMetrics.bottom - VesselMetrics.top;

  /// Interior span at full volume — used for laying out motion so squeezing
  /// the right wall in does not slow or rescale the molecules.
  double _relaxedInnerWidth(double inset) =>
      VesselMetrics.rightRelaxed - VesselMetrics.left - inset * 2;

  double _innerHeight(double inset) =>
      VesselMetrics.bottom - VesselMetrics.top - inset * 2;

  /// Pixels per second at unit temperature (heat = 0).
  static const _motionScale = 120.0;

  /// Molecular speed multiplier. Temperature is the velocity of the molecules,
  /// so [heat] is the only control that changes speed — not [compression].
  double get speed => 1 + heat * 0.85;

  /// Volume as a fraction of the relaxed vessel, and the pressure that
  /// follows from it: p ∝ T / V, the relation the figure is explaining.
  double get volumeFraction =>
      width / (VesselMetrics.rightRelaxed - VesselMetrics.left);
  double get temperatureFraction => speed * speed;
  double get pressure => temperatureFraction / volumeFraction;

  Offset positionOf(Molecule m, {double inset = 18}) {
    final innerLeft = VesselMetrics.left + inset;
    final innerRight = right - inset;
    final innerTop = VesselMetrics.top + inset;
    final innerBottom = VesselMetrics.bottom - inset;

    final motion = _motionScale * speed * t;

    // Positions integrate at constant canvas speed; only the folding walls
    // move inward when the vessel is compressed, so collision rate rises
    // naturally in a smaller box.
    final x = foldBetween(
      innerLeft + m.x0 * _relaxedInnerWidth(inset) + m.vx * motion,
      innerLeft,
      innerRight,
    );
    final y = foldBetween(
      innerTop + m.y0 * _innerHeight(inset) + m.vy * motion,
      innerTop,
      innerBottom,
    );
    return Offset(x, y);
  }

  /// Unit vector of travel, for the arrow on each molecule.
  Offset headingOf(Molecule m, {double inset = 18}) {
    final innerLeft = VesselMetrics.left + inset;
    final innerRight = right - inset;
    final innerTop = VesselMetrics.top + inset;
    final innerBottom = VesselMetrics.bottom - inset;

    final motion = _motionScale * speed * t;

    final rawX =
        innerLeft + m.x0 * _relaxedInnerWidth(inset) + m.vx * motion;
    final rawY = innerTop + m.y0 * _innerHeight(inset) + m.vy * motion;

    final sx = foldRising(rawX, innerLeft, innerRight) ? 1.0 : -1.0;
    final sy = foldRising(rawY, innerTop, innerBottom) ? 1.0 : -1.0;
    final v = Offset(m.vx * sx, m.vy * sy);
    final d = v.distance;
    return d == 0 ? const Offset(1, 0) : v / d;
  }

  @override
  bool operator ==(Object other) =>
      other is VesselState &&
      other.t == t &&
      other.compression == compression &&
      other.heat == heat;

  @override
  int get hashCode => Object.hash(t, compression, heat);
}

/// Geometry of Brown's apparatus, on a fixed 1000 x 800 canvas.
class ApparatusMetrics {
  const ApparatusMetrics._();

  static const canvas = Size(1000, 800);

  static const boxLeft = 300.0;
  static const boxRight = 700.0;
  static const boxTop = 96.0;
  static const floor = 636.0;

  static const wheelCentre = Offset(500, 690);
  static const wheelRadius = 58.0;
  static const teeth = 10;

  /// Piston height at a slow wheel and at a fast one.
  static const pistonLow = 470.0;
  static const pistonHigh = 264.0;

  static const ballRadius = 15.0;

  /// Each ball's phase, speed and how high it can be thrown. Most stay low;
  /// two are occasionally kicked right up, as the photographs show.
  static const balls = <Ball>[
    Ball(0.05, 0.62, 0.9, 96), Ball(0.22, 0.31, 1.1, 128),
    Ball(0.38, 0.77, 0.8, 84), Ball(0.51, 0.12, 1.3, 300),
    Ball(0.64, 0.55, 1.0, 110), Ball(0.77, 0.88, 0.9, 92),
    Ball(0.90, 0.24, 1.2, 150), Ball(0.14, 0.44, 1.0, 104),
    Ball(0.30, 0.95, 0.85, 78), Ball(0.46, 0.68, 1.15, 340),
    Ball(0.58, 0.05, 0.95, 118), Ball(0.71, 0.36, 1.05, 88),
    Ball(0.84, 0.81, 0.9, 132), Ball(0.96, 0.50, 1.25, 100),
  ];
}

class Ball {
  const Ball(this.x, this.phase, this.rate, this.reach);

  /// Resting position across the floor, 0..1.
  final double x;
  final double phase;
  final double rate;

  /// How high this ball is thrown at full agitation, in canvas pixels.
  final double reach;
}

/// Everything the apparatus painter needs.
@immutable
class ApparatusState {
  const ApparatusState({required this.t, required this.agitation});

  final double t;

  /// 0 = the wheel turning slowly, 1 = turning fast.
  final double agitation;

  double get wheelAngle => t * (1.6 + agitation * 3.4);

  double get pistonY =>
      ApparatusMetrics.pistonLow +
      (ApparatusMetrics.pistonHigh - ApparatusMetrics.pistonLow) * agitation;

  /// A ball's centre. Its ceiling is its own reach, scaled by how hard the
  /// wheel is kicking, and never above the piston resting on top of them.
  Offset ballCentre(Ball b) {
    final x = ApparatusMetrics.boxLeft +
        28 +
        b.x * (ApparatusMetrics.boxRight - ApparatusMetrics.boxLeft - 56);
    final reach = b.reach * (0.35 + agitation * 0.65);
    final ceiling = math.max(
      pistonY + ApparatusMetrics.ballRadius + 4,
      ApparatusMetrics.floor - reach,
    );
    final y = foldBetween(
      ApparatusMetrics.floor -
          b.phase * reach -
          b.rate * t * (110 + agitation * 190),
      ceiling,
      ApparatusMetrics.floor,
    );
    return Offset(x, y);
  }

  @override
  bool operator ==(Object other) =>
      other is ApparatusState && other.t == t && other.agitation == agitation;

  @override
  int get hashCode => Object.hash(t, agitation);
}
