import 'dart:math' as math;

/// Steady, incompressible, frictionless flow of water through a horizontal
/// pipe whose diameter varies (a Venturi tube).
///
/// Two laws do all the work:
///
///   continuity   A1 v1 = A2 v2 = Q          (the same water must get through)
///   Bernoulli    p + ½ρv² = constant        (along a horizontal streamline)
///
/// Squeezing the pipe raises v, and Bernoulli then forces p down: that is
/// exactly what Figure 1-10 shows with its standpipes.
class VenturiModel {
  const VenturiModel({
    this.flow = 0.010,
    this.wideDiameter = 0.100,
    this.throatDiameter = 0.055,
    this.supplyPressure = 22000,
  })  : assert(flow > 0, 'flow must be positive'),
        assert(wideDiameter > 0, 'wideDiameter must be positive'),
        assert(throatDiameter > 0, 'throatDiameter must be positive'),
        assert(throatDiameter <= wideDiameter,
            'the throat cannot be wider than the pipe'),
        assert(supplyPressure > 0, 'supplyPressure must be positive');

  /// Builds a model from untrusted numbers (a restored session, a deep link,
  /// a slider that has drifted a hair outside its bounds) by clamping every
  /// value into a physically sensible range instead of asserting.
  factory VenturiModel.sanitised({
    required double flow,
    required double throatDiameter,
    double wideDiameter = 0.100,
    double supplyPressure = 22000,
  }) {
    final wide = wideDiameter.isFinite && wideDiameter > 0
        ? wideDiameter.clamp(0.01, 1.0).toDouble()
        : 0.100;
    return VenturiModel(
      flow: flow.isFinite
          ? flow.clamp(minFlow, maxFlow).toDouble()
          : minFlow,
      wideDiameter: wide,
      throatDiameter: throatDiameter.isFinite
          ? throatDiameter.clamp(minThroat, wide).toDouble()
          : minThroat,
      supplyPressure: supplyPressure.isFinite && supplyPressure > 0
          ? supplyPressure
          : 22000,
    );
  }

  /// Density of water, kg/m³.
  static const double rho = 1000.0;

  /// Acceleration due to gravity, m/s².
  static const double g = 9.81;

  // Slider limits, kept here so the UI and the tests agree on one source.
  static const double minFlow = 0.002;
  static const double maxFlow = 0.012;
  static const double minThroat = 0.040;
  static const double maxThroat = 0.080;

  /// Volumetric flow rate Q, m³/s (the same everywhere along the pipe).
  final double flow;

  /// Diameter of the wide sections, m.
  final double wideDiameter;

  /// Diameter of the narrow throat, m.
  final double throatDiameter;

  /// Total (stagnation) pressure supplied by the tank feeding the pipe, Pa.
  /// This is the constant in Bernoulli's equation, so it is the same at every
  /// station: what changes is how it is split between static and dynamic.
  final double supplyPressure;

  static double areaOf(double diameter) => math.pi * diameter * diameter / 4.0;

  double get wideArea => areaOf(wideDiameter);
  double get throatArea => areaOf(throatDiameter);

  /// v = Q / A.
  double get wideSpeed => flow / wideArea;
  double get throatSpeed => flow / throatArea;

  /// How many times faster the water moves in the throat. Equals A1/A2, so
  /// it depends only on the shape of the pipe, not on how hard you pump.
  double get speedRatio => wideArea / throatArea;

  /// Dynamic pressure ½ρv² — the part of the total carried by motion.
  static double dynamicOf(double speed) => 0.5 * rho * speed * speed;

  double get wideDynamic => dynamicOf(wideSpeed);
  double get throatDynamic => dynamicOf(throatSpeed);

  /// The constant in Bernoulli's equation: static + dynamic.
  double get totalPressure => supplyPressure;

  /// Static pressure in the wide sections — what their standpipes show.
  double get widePressure => totalPressure - wideDynamic;

  /// Static pressure in the throat. Whatever the flow gains in dynamic
  /// pressure it must give up in static pressure.
  double get throatPressure => totalPressure - throatDynamic;

  /// Below zero absolute the water would boil into vapour: real Venturis
  /// cavitate here, and the standpipe would simply empty.
  bool get cavitates => throatPressure < 0;

  /// Height of the water column a standpipe would show, m: h = p / (ρg).
  static double headOf(double pressure) => pressure / (rho * g);

  double get wideHead => headOf(widePressure);
  double get throatHead => headOf(throatPressure);

  /// Column height actually drawn: a cavitating throat empties its standpipe
  /// rather than showing a negative column.
  double get drawnThroatHead => throatHead < 0 ? 0 : throatHead;

  /// How far the middle column sits below its neighbours, metres.
  double get columnDrop => wideHead - drawnThroatHead;

  /// True when the "throat" is the full bore of the pipe, so nothing is
  /// constricted and the three columns stand level.
  bool get isStraightPipe => (wideDiameter - throatDiameter).abs() < 1e-9;

  /// A sentence describing the current state, used as the screen-reader
  /// label for the figure so the diagram is not a blank to assistive tech.
  String describe() {
    final buffer = StringBuffer()
      ..write('Venturi tube. ')
      ..write('Water flows at ${wideSpeed.toStringAsFixed(2)} metres per '
          'second in the wide sections, where the pressure is '
          '${(widePressure / 1000).toStringAsFixed(1)} kilopascals. ')
      ..write('In the narrow throat it speeds up to '
          '${throatSpeed.toStringAsFixed(2)} metres per second, '
          '${speedRatio.toStringAsFixed(1)} times faster, and the pressure '
          'falls to ${(throatPressure / 1000).toStringAsFixed(1)} '
          'kilopascals. ');
    if (cavitates) {
      buffer.write('The throat pressure has dropped below zero, so the middle '
          'standpipe has emptied and a real pipe would cavitate.');
    } else if (isStraightPipe) {
      buffer.write('The throat is as wide as the pipe, so all three columns '
          'stand level.');
    } else {
      buffer.write('The middle column stands '
          '${columnDrop.toStringAsFixed(2)} metres lower than the other two.');
    }
    return buffer.toString();
  }

  /// Speed and static pressure at any point where the pipe has [diameter].
  double speedAt(double diameter) => flow / areaOf(diameter);
  double pressureAt(double diameter) =>
      totalPressure - dynamicOf(speedAt(diameter));

  VenturiModel copyWith({
    double? flow,
    double? wideDiameter,
    double? throatDiameter,
    double? supplyPressure,
  }) {
    return VenturiModel(
      flow: flow ?? this.flow,
      wideDiameter: wideDiameter ?? this.wideDiameter,
      throatDiameter: throatDiameter ?? this.throatDiameter,
      supplyPressure: supplyPressure ?? this.supplyPressure,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VenturiModel &&
      other.flow == flow &&
      other.wideDiameter == wideDiameter &&
      other.throatDiameter == throatDiameter &&
      other.supplyPressure == supplyPressure;

  @override
  int get hashCode =>
      Object.hash(flow, wideDiameter, throatDiameter, supplyPressure);
}

/// The shape of the drawn pipe, in a fixed design space that the painter
/// scales to whatever room it is given.
class VenturiGeometry {
  const VenturiGeometry._();

  static const double designWidth = 900;
  static const double designHeight = 620;

  /// Pipe axis.
  static const double centreY = 500;
  static const double pipeLeft = 60;
  static const double pipeRight = 840;

  /// Where the cones start and end.
  static const double convergeStart = 300;
  static const double throatStart = 380;
  static const double throatEnd = 520;
  static const double divergeEnd = 600;

  /// Pixels per metre for the pipe cross-section and for the water columns.
  static const double pipeScale = 920;
  static const double columnScale = 150;

  /// Standpipe (manometer) positions and size.
  static const double standTop = 110;
  static const double standWidth = 30;
  static const List<double> standX = [180, 450, 720];

  /// 0 where the pipe is full width, 1 in the throat, smoothly in between.
  static double narrowness(double x) {
    if (x <= convergeStart || x >= divergeEnd) return 0;
    if (x >= throatStart && x <= throatEnd) return 1;
    if (x < throatStart) {
      final t = (x - convergeStart) / (throatStart - convergeStart);
      return t * t * (3 - 2 * t); // smoothstep
    }
    final t = (x - throatEnd) / (divergeEnd - throatEnd);
    final s = 1 - t;
    return s * s * (3 - 2 * s);
  }

  /// Pipe diameter in metres at design-space position [x].
  static double diameterAt(double x, VenturiModel m) {
    final n = narrowness(x);
    return m.wideDiameter + (m.throatDiameter - m.wideDiameter) * n;
  }

  /// Half the drawn pipe height at [x], in design pixels.
  static double halfHeightAt(double x, VenturiModel m) =>
      diameterAt(x, m) / 2 * pipeScale;

  /// Flow speed in m/s at design-space position [x].
  static double speedAt(double x, VenturiModel m) =>
      m.speedAt(diameterAt(x, m));
}
