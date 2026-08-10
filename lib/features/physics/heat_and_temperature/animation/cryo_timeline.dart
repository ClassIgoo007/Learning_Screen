import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// The five beats of the lesson. Beats 1–3 belong to the cryogenic apparatus
/// of Fig. 4-9, beats 4–5 to the plasma jet of Fig. 4-8 — the cold end of the
/// scale and the hot end of it.
enum CryoStage {
  compression(
    1,
    'Compression',
    'Fig. 4-9',
    'With the valve closed the compressor pumps gas up into the compression '
        'chamber. Compressed, the gas is heated above room temperature and the '
        'excess heat escapes into the surroundings.',
  ),
  expansion(
    2,
    'Expansion',
    'Fig. 4-9',
    'The valve opens and the gas expands into the larger volume below. '
        'Expanding, it cools, and it sucks heat in from the surroundings — the '
        'low-temperature region.',
  ),
  thermalPump(
    3,
    'Thermal pump',
    'Fig. 4-9',
    'Run in sequence, compression and expansion make a thermal pump: heat is '
        'carried away from the expander and pumped into the compressor, which '
        'is why a refrigerator warms the kitchen while it cools the food.',
  ),
  arc(
    4,
    'Arc struck',
    'Fig. 4-8',
    'A stream of noble gas is blown through a high-current electric arc '
        'between the electrode and the nozzle. The gas begins to ionise.',
  ),
  plasmaJet(
    5,
    'Plasma jet',
    'Fig. 4-8',
    'At full current the gas becomes a plasma of positive ions and free '
        'electrons, and the jet reaches about 15,000°C — two and a half times '
        'the temperature of the sun\u2019s surface.',
  );

  const CryoStage(this.beat, this.label, this.figure, this.caption);

  final int beat;
  final String label;
  final String figure;
  final String caption;

  /// Beats 1–3 are the apparatus; 4–5 are the torch.
  bool get isApparatus => beat <= 3;

  static CryoStage fromBeat(int beat) =>
      values.firstWhere((s) => s.beat == beat, orElse: () => compression);
}

/// Linear interpolation across three knots at stage 1, 2 and 3. Lets each
/// quantity of the apparatus be written as simply as "strong, weak, strong".
double atStage(double stage, double v1, double v2, double v3) {
  final s = stage.clamp(1.0, 3.0);
  return s <= 2 ? v1 + (v2 - v1) * (s - 1) : v2 + (v3 - v2) * (s - 2);
}

/// Geometry of the cryogenic apparatus, on a fixed 1000 x 900 canvas.
class CryoMetrics {
  const CryoMetrics._();

  static const canvas = Size(1000, 940);

  static const compressionChamber = Rect.fromLTRB(330, 150, 690, 330);
  static const expansionChamber = Rect.fromLTRB(330, 610, 690, 800);

  static const motorBody = Rect.fromLTRB(60, 430, 190, 540);
  static const compressorBody = Rect.fromLTRB(236, 440, 330, 530);

  static const valveCentre = Offset(760, 470);

  /// Gas pumped from the compressor up into the compression chamber. This leg
  /// runs whether or not the valve is open.
  static Path chargeLeg() => Path()
    ..moveTo(330, 485)
    ..lineTo(300, 485)
    ..cubicTo(276, 485, 276, 470, 276, 440)
    ..lineTo(276, 260)
    ..cubicTo(276, 232, 292, 232, 330, 232);

  /// The return leg: out of the compression chamber, down past the valve,
  /// into the expansion chamber and back to the compressor. Only the gas that
  /// gets past an open valve travels this way.
  static Path returnLeg() => Path()
    ..moveTo(690, 232)
    ..cubicTo(742, 232, 760, 250, 760, 300)
    ..lineTo(760, 640)
    ..cubicTo(760, 690, 742, 706, 690, 706)
    ..lineTo(430, 706)
    ..cubicTo(360, 706, 336, 660, 336, 560)
    ..lineTo(336, 500);

  /// Wavy-tailed arrows: the figure's notation for a flow of heat.
  static const heatOut = <HeatArrow>[
    HeatArrow(Offset(378, 150), -1), HeatArrow(Offset(452, 150), -1),
    HeatArrow(Offset(526, 150), -1), HeatArrow(Offset(600, 150), -1),
    HeatArrow(Offset(378, 330), 1), HeatArrow(Offset(452, 330), 1),
    HeatArrow(Offset(526, 330), 1), HeatArrow(Offset(600, 330), 1),
  ];

  static const heatIn = <HeatArrow>[
    HeatArrow(Offset(378, 610), 1), HeatArrow(Offset(452, 610), 1),
    HeatArrow(Offset(526, 610), 1), HeatArrow(Offset(600, 610), 1),
    HeatArrow(Offset(378, 800), -1), HeatArrow(Offset(452, 800), -1),
    HeatArrow(Offset(526, 800), -1), HeatArrow(Offset(600, 800), -1),
  ];

  /// Speckles standing for the gas inside a chamber, as fractions of the box.
  static const speckles = <Offset>[
    Offset(0.10, 0.22), Offset(0.26, 0.61), Offset(0.41, 0.16),
    Offset(0.55, 0.72), Offset(0.70, 0.31), Offset(0.86, 0.58),
    Offset(0.18, 0.83), Offset(0.34, 0.40), Offset(0.49, 0.90),
    Offset(0.63, 0.12), Offset(0.78, 0.79), Offset(0.92, 0.24),
    Offset(0.06, 0.48), Offset(0.22, 0.07), Offset(0.38, 0.68),
    Offset(0.53, 0.35), Offset(0.68, 0.54), Offset(0.83, 0.10),
    Offset(0.96, 0.66), Offset(0.14, 0.34), Offset(0.30, 0.94),
    Offset(0.45, 0.55), Offset(0.60, 0.85), Offset(0.75, 0.42),
  ];
}

class HeatArrow {
  const HeatArrow(this.at, this.direction);

  final Offset at;

  /// -1 points up (out of the top of a chamber), +1 points down.
  final int direction;
}

/// Everything the apparatus painter needs, from the clock and the beat.
@immutable
class CryoState {
  const CryoState({required this.t, required this.stage});

  /// Looping clock, 0..1.
  final double t;

  /// 1.0 .. 3.0, continuous so the beats cross-fade.
  final double stage;

  /// How far the valve has opened.
  double get valveOpen => ((stage - 1) / 1).clamp(0.0, 1.0);

  /// Heat leaving the hot chamber, and heat drawn into the cold one.
  double get heatOutStrength => atStage(stage, 1, 0.35, 0.9);
  double get heatInStrength => atStage(stage, 0.15, 1, 0.9);

  /// How densely each chamber is filled with gas.
  double get compressionFill => atStage(stage, 1, 0.45, 0.75);
  double get expansionFill => atStage(stage, 0.3, 1, 0.75);

  /// Gas on the return leg only moves once the valve is open.
  double get returnFlow => valveOpen;

  /// Wavy arrows pulse along their own length.
  double get heatPhase => t;

  @override
  bool operator ==(Object other) =>
      other is CryoState && other.t == t && other.stage == stage;

  @override
  int get hashCode => Object.hash(t, stage);
}

/// Geometry of the plasma torch, on a fixed 1000 x 620 canvas.
class PlasmaMetrics {
  const PlasmaMetrics._();

  static const canvas = Size(1000, 660);

  static const bodyRect = Rect.fromLTRB(150, 236, 380, 384);
  static const nozzleTip = Offset(452, 310);
  static const electrodeTip = Offset(300, 310);

  static const jetStart = Offset(456, 310);
  static const jetEnd = Offset(930, 310);

  /// Marks on the temperature scale, in degrees Celsius.
  static const scale = <ScaleMark>[
    ScaleMark(1700, 'Kitchen range flame'),
    ScaleMark(6000, 'Surface of the sun'),
    ScaleMark(15000, 'Plasma jet'),
  ];
  static const scaleMax = 16000.0;

  /// Particles streaming out of the nozzle: phase, speed, vertical spread.
  static const stream = <Streak>[
    Streak(0.00, 1.00, -0.62), Streak(0.13, 0.86, 0.34),
    Streak(0.26, 1.12, -0.18), Streak(0.39, 0.94, 0.70),
    Streak(0.52, 1.05, -0.44), Streak(0.65, 0.90, 0.12),
    Streak(0.78, 1.08, -0.78), Streak(0.91, 0.98, 0.52),
    Streak(0.07, 1.16, 0.02), Streak(0.20, 0.82, -0.30),
    Streak(0.33, 1.02, 0.86), Streak(0.46, 0.92, -0.06),
    Streak(0.59, 1.10, 0.42), Streak(0.72, 0.88, -0.54),
    Streak(0.85, 1.04, 0.24), Streak(0.98, 0.96, -0.86),
  ];
}

class ScaleMark {
  const ScaleMark(this.celsius, this.label);
  final double celsius;
  final String label;
}

class Streak {
  const Streak(this.phase, this.speed, this.spread);
  final double phase, speed, spread;
}

/// Everything the plasma painter needs.
@immutable
class PlasmaState {
  const PlasmaState({required this.t, required this.intensity});

  final double t;

  /// 0 = the arc just struck, 1 = the jet at full temperature.
  final double intensity;

  /// How far along the plume a particle has travelled, 0..1, wrapped.
  double streakProgress(Streak s) =>
      ((t * s.speed * (0.9 + intensity) + s.phase) % 1.0 + 1.0) % 1.0;

  /// The plume grows as the discharge strengthens.
  double get reach => 0.34 + intensity * 0.66;

  /// Reading on the scale, in degrees Celsius. Starts well below the
  /// 1,700°C kitchen-flame mark (Beat 4, arc just struck) and sweeps up
  /// through both reference points to 15,000°C at full intensity (Beat 5) —
  /// the reference app's own formula (`4000 + intensity * 11000`) started
  /// above the kitchen-flame mark even at intensity 0, contradicting both its
  /// own README and the spec this lesson was built from, so this replaces it.
  double get temperature => 800 + intensity * 14200;

  /// The arc flickers a few times a second, independently of the plume.
  double get flicker =>
      0.72 + 0.28 * math.sin(t * 2 * math.pi * 9).abs();

  @override
  bool operator ==(Object other) =>
      other is PlasmaState && other.t == t && other.intensity == intensity;

  @override
  int get hashCode => Object.hash(t, intensity);
}
