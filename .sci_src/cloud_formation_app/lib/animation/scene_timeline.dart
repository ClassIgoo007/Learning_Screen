import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The four beats of the sequence. The index matches the `beat` field carried
/// by every question in the worksheet, so a question can jump the animation to
/// the stage it tests.
enum SceneStage {
  ascent(
    1,
    'Air rises',
    'Sun-warmed air over the ground picks up water vapour and rises in '
        'convective currents.',
  ),
  cooling(
    2,
    'Cooling',
    'As the current climbs it cools; the same absolute humidity now means a '
        'higher relative humidity.',
  ),
  condensation(
    3,
    'Condensation',
    'At saturation the vapour can no longer stay a gas and condenses into '
        'microscopic droplets — the cloud.',
  ),
  rain(
    4,
    'Rain',
    'Drops grow too heavy for the updraft and fall through it as rain, while '
        'fresh moist air keeps feeding the cloud from below.',
  );

  const SceneStage(this.beat, this.label, this.caption);

  final int beat;
  final String label;
  final String caption;

  static SceneStage fromBeat(int beat) =>
      values.firstWhere((s) => s.beat == beat, orElse: () => ascent);

  SceneStage get next => values[(index + 1) % values.length];
}

/// Every quantity the painters need, derived from two numbers: the looping
/// clock [t] and the continuous stage position [stage].
///
/// Because the state is a pure function of its inputs, any frame is exactly
/// reproducible — which is what makes pausing, stepping and testing fall out
/// for free rather than needing separate machinery.
@immutable
class SceneState {
  const SceneState({
    required this.t,
    required this.stage,
    required this.cloudOpacity,
    required this.condensationOpacity,
    required this.rainOpacity,
    required this.breathe,
    required this.dashOffset,
  });

  /// Looping clock, 0..1.
  final double t;

  /// Where we are between the beats, 1.0 .. 4.0. Fractional values are the
  /// cross-fade between two beats.
  final double stage;

  final double cloudOpacity;
  final double condensationOpacity;
  final double rainOpacity;

  /// Vertical bob applied to the cloud puffs, in design pixels.
  final double breathe;

  /// How far the dashes along the ascending currents have travelled, 0..1.
  final double dashOffset;

  factory SceneState.fromProgress(double t, double stage) {
    final s = stage.clamp(1.0, 4.0).toDouble();
    return SceneState(
      t: t,
      stage: s,
      // The cloud appears faintly during cooling and fills in at condensation.
      cloudOpacity: _ramp(s, 1.0, 2.0) * 0.35 + _ramp(s, 2.0, 3.0) * 0.65,
      condensationOpacity: _ramp(s, 2.0, 3.0),
      rainOpacity: _ramp(s, 3.0, 4.0),
      breathe: math.sin(t * 2 * math.pi) * 5,
      dashOffset: t,
    );
  }

  /// Linear 0..1 ramp of [x] between [a] and [b].
  static double _ramp(double x, double a, double b) =>
      ((x - a) / (b - a)).clamp(0.0, 1.0);

  /// Position of one rain drop along its fall, 0..1, wrapped.
  double dropProgress(double phase, double speed) =>
      (t * speed + phase) % 1.0;

  @override
  bool operator ==(Object other) =>
      other is SceneState &&
      other.t == t &&
      other.stage == stage;

  @override
  int get hashCode => Object.hash(t, stage);
}
