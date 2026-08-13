import 'dart:ui';

/// The fixed design canvas the scene is composed on. Everything is authored in
/// these coordinates and then scaled to the available space with a FittedBox,
/// so the composition never reflows or clips — it only grows and shrinks.
class SceneMetrics {
  const SceneMetrics._();

  static const canvas = Size(1000, 800);

  static const groundY = 700.0;
  static const cloudBaseY = 425.0;

  /// The ascending currents, drawn bottom to top so dashes flow upward.
  /// Each entry is (start, control1, control2, end, opacity).
  static const currents = <CurrentPath>[
    CurrentPath(Offset(310, 700), Offset(292, 605), Offset(318, 512),
        Offset(342, 430), 1),
    CurrentPath(Offset(420, 700), Offset(414, 600), Offset(412, 508),
        Offset(424, 424), 1),
    CurrentPath(Offset(540, 700), Offset(552, 600), Offset(548, 506),
        Offset(532, 424), 1),
    CurrentPath(Offset(650, 700), Offset(676, 606), Offset(664, 512),
        Offset(622, 434), 1),
    CurrentPath(Offset(200, 700), Offset(172, 640), Offset(178, 572),
        Offset(216, 520), 0.55),
    CurrentPath(Offset(790, 700), Offset(826, 640), Offset(820, 572),
        Offset(772, 520), 0.55),
  ];

  /// Cloud body: the light puffs on top, then the darker base.
  static const puffs = <Puff>[
    Puff(Offset(450, 152), 150, 70, 0),
    Puff(Offset(612, 132), 104, 58, 0),
    Puff(Offset(330, 216), 112, 66, 1),
    Puff(Offset(682, 226), 108, 66, 1),
    Puff(Offset(432, 276), 156, 84, 2),
    Puff(Offset(598, 292), 130, 78, 2),
  ];

  static const baseLobes = <Puff>[
    Puff(Offset(382, 360), 146, 70, 2),
    Puff(Offset(592, 366), 138, 66, 1),
  ];

  /// Droplets condensing inside the cloud.
  static const condensation = <Offset>[
    Offset(392, 214), Offset(468, 176), Offset(556, 222), Offset(348, 282),
    Offset(618, 296), Offset(512, 292), Offset(440, 330), Offset(586, 172),
    Offset(300, 236), Offset(660, 244),
  ];

  /// Rain drops: x position, phase offset (0..1) and fall speed multiplier.
  static const drops = <Drop>[
    Drop(352, 0.00, 1.00), Drop(398, 0.42, 0.86), Drop(444, 0.18, 1.12),
    Drop(490, 0.67, 0.94), Drop(536, 0.30, 1.05), Drop(582, 0.83, 0.90),
    Drop(628, 0.11, 1.08), Drop(674, 0.55, 0.98), Drop(320, 0.74, 0.92),
    Drop(706, 0.26, 1.02),
  ];
}

class CurrentPath {
  const CurrentPath(this.start, this.c1, this.c2, this.end, this.opacity);
  final Offset start, c1, c2, end;
  final double opacity;
}

class Puff {
  const Puff(this.center, this.rx, this.ry, this.shade);
  final Offset center;
  final double rx, ry;

  /// 0 = lightest, 2 = darkest. Also selects the breathing phase.
  final int shade;
}

class Drop {
  const Drop(this.x, this.phase, this.speed);
  final double x, phase, speed;
}
