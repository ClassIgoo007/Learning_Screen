import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../physics/venturi.dart';

/// How much slower than real time the animation runs, so the throat jet is
/// followable by eye instead of a blur.
const double kTimeScale = 0.25;

/// Physical length of the drawn pipe span, metres. Sets how far a particle
/// travels on screen for a given speed.
const double kPipeLengthMetres = 1.2;

double get _axialScale =>
    (VenturiGeometry.pipeRight - VenturiGeometry.pipeLeft) / kPipeLengthMetres;

class _Particle {
  _Particle(this.x, this.lane);
  double x;
  final int lane;
}

/// Figure 1-10, alive: water flows through a pipe of varying diameter while
/// three standpipes show the static pressure at each station.
class VenturiFigure extends StatefulWidget {
  const VenturiFigure({
    super.key,
    required this.model,
    this.running = true,
    this.showStreamlines = true,
    this.semanticsLabel,
  });

  final VenturiModel model;
  final bool running;
  final bool showStreamlines;

  /// Spoken description of the figure. Without it the diagram is invisible
  /// to screen readers.
  final String? semanticsLabel;

  @override
  State<VenturiFigure> createState() => _VenturiFigureState();
}

class _VenturiFigureState extends State<VenturiFigure>
    with SingleTickerProviderStateMixin {
  static const List<double> _lanes = [-0.74, -0.37, 0, 0.37, 0.74];
  static const int _perLane = 14;

  late final Ticker _ticker;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  final List<_Particle> _particles = [];

  Duration _last = Duration.zero;
  bool _awake = false;

  // Column heights are eased towards their target so a slider drag looks
  // like water sloshing to a new level rather than snapping.
  late double _leftHead;
  late double _throatHead;
  late double _rightHead;

  @override
  void initState() {
    super.initState();
    _leftHead = widget.model.wideHead;
    _rightHead = widget.model.wideHead;
    _throatHead = widget.model.drawnThroatHead;
    _seedParticles();
    _ticker = createTicker(_onTick);
    _wake();
  }

  /// Start ticking (if not already) because something needs to move.
  void _wake() {
    if (_awake) return;
    _awake = true;
    _last = Duration.zero;
    _ticker.start();
  }

  /// Stop ticking so a paused, settled figure costs no frames or battery.
  void _sleep() {
    if (!_awake) return;
    _awake = false;
    _ticker.stop();
  }

  @override
  void didUpdateWidget(covariant VenturiFigure old) {
    super.didUpdateWidget(old);
    // Deliberately no reseeding here. Dragging the throat slider changes the
    // geometry on every frame, and reseeding then would teleport every
    // particle 60 times a second. The flow self-corrects to the new steady
    // state within a second or so, which also looks like real water.
    if (old.model != widget.model || old.running != widget.running) {
      _wake();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  /// True once the three columns have arrived at the heights the model asks
  /// for, to within half a millimetre of water.
  bool get _columnsSettled {
    final m = widget.model;
    const tol = 0.0005;
    return (m.wideHead - _leftHead).abs() < tol &&
        (m.wideHead - _rightHead).abs() < tol &&
        (m.drawnThroatHead - _throatHead).abs() < tol;
  }

  /// Place particles evenly in *travel time* rather than evenly in distance,
  /// so the pattern starts in its steady state: sparse where the water is
  /// fast, crowded where it is slow.
  void _seedParticles() {
    _particles.clear();
    const steps = 400;
    const dx =
        (VenturiGeometry.pipeRight - VenturiGeometry.pipeLeft) / steps;
    final xs = <double>[];
    final ts = <double>[];
    double t = 0;
    for (var i = 0; i <= steps; i++) {
      final x = VenturiGeometry.pipeLeft + i * dx;
      xs.add(x);
      ts.add(t);
      if (i < steps) {
        final v = VenturiGeometry.speedAt(x + dx / 2, widget.model);
        t += dx / (v * _axialScale);
      }
    }
    final total = ts.last;
    for (var lane = 0; lane < _lanes.length; lane++) {
      for (var k = 0; k < _perLane; k++) {
        final want = total * (k + lane / _lanes.length) / _perLane;
        var i = 0;
        while (i < ts.length - 1 && ts[i + 1] < want) {
          i++;
        }
        _particles.add(_Particle(xs[i], lane));
      }
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.25) return; // ignore first frame and long stalls

    final m = widget.model;

    // Ease the columns towards the pressures the model asks for.
    const tau = 0.35;
    final k = 1 - math.exp(-dt / tau);
    _leftHead += (m.wideHead - _leftHead) * k;
    _rightHead += (m.wideHead - _rightHead) * k;
    _throatHead += (m.drawnThroatHead - _throatHead) * k;

    if (widget.running) {
      for (final p in _particles) {
        p.x += VenturiGeometry.speedAt(p.x, m) * _axialScale * kTimeScale * dt;
        if (p.x > VenturiGeometry.pipeRight) {
          p.x = VenturiGeometry.pipeLeft +
              (p.x - VenturiGeometry.pipeRight);
        }
      }
    }
    _frame.value++;

    // Nothing moving and nothing settling: stop burning frames.
    if (!widget.running && _columnsSettled) _sleep();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      image: true,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio:
            VenturiGeometry.designWidth / VenturiGeometry.designHeight,
        // The figure repaints every frame; the boundary keeps that damage
        // from forcing the rest of the screen to repaint with it.
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _VenturiPainter(
              model: widget.model,
              particles: _particles,
              lanes: _lanes,
              showStreamlines: widget.showStreamlines,
              heads: () => [_leftHead, _throatHead, _rightHead],
              repaint: _frame,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _VenturiPainter extends CustomPainter {
  _VenturiPainter({
    required this.model,
    required this.particles,
    required this.lanes,
    required this.showStreamlines,
    required this.heads,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final VenturiModel model;
  final List<_Particle> particles;
  final List<double> lanes;
  final bool showStreamlines;
  final List<double> Function() heads;

  static const Color pipeStroke = Color(0xFF37474F);
  static const Color water = Color(0xFF29B6F6);
  static const Color waterDeep = Color(0xFF0277BD);
  static const Color hi = Color(0xFF2E7D32);
  static const Color lo = Color(0xFFC62828);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / VenturiGeometry.designWidth;
    canvas.save();
    canvas.scale(scale);

    final h = heads();
    _drawStandpipes(canvas, h);
    _drawPipe(canvas);
    if (showStreamlines) _drawFlow(canvas);
    _drawArrows(canvas);
    _drawReferenceLine(canvas, h);
    _drawLabels(canvas, h);

    canvas.restore();
  }

  // ---------------------------------------------------------------- pipe

  Path _pipePath() {
    final path = Path();
    const step = 4.0;
    path.moveTo(VenturiGeometry.pipeLeft,
        VenturiGeometry.centreY - VenturiGeometry.halfHeightAt(VenturiGeometry.pipeLeft, model));
    for (var x = VenturiGeometry.pipeLeft; x <= VenturiGeometry.pipeRight; x += step) {
      path.lineTo(x, VenturiGeometry.centreY - VenturiGeometry.halfHeightAt(x, model));
    }
    for (var x = VenturiGeometry.pipeRight; x >= VenturiGeometry.pipeLeft; x -= step) {
      path.lineTo(x, VenturiGeometry.centreY + VenturiGeometry.halfHeightAt(x, model));
    }
    path.close();
    return path;
  }

  void _drawPipe(Canvas canvas) {
    final path = _pipePath();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFF29B6F6)],
        ).createShader(const Rect.fromLTWH(
            VenturiGeometry.pipeLeft,
            VenturiGeometry.centreY - 60,
            VenturiGeometry.pipeRight - VenturiGeometry.pipeLeft,
            120)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = pipeStroke,
    );

    // dashed centreline, as in the original figure
    final dash = Paint()
      ..color = pipeStroke.withValues(alpha: 0.55)
      ..strokeWidth = 1.6;
    for (var x = VenturiGeometry.pipeLeft - 30;
        x < VenturiGeometry.pipeRight + 30;
        x += 22) {
      canvas.drawLine(Offset(x, VenturiGeometry.centreY),
          Offset(x + 12, VenturiGeometry.centreY), dash);
    }
  }

  // --------------------------------------------------------- standpipes

  void _drawStandpipes(Canvas canvas, List<double> h) {
    for (var i = 0; i < VenturiGeometry.standX.length; i++) {
      final cx = VenturiGeometry.standX[i];
      const w = VenturiGeometry.standWidth;
      final rect = Rect.fromLTRB(cx - w / 2, VenturiGeometry.standTop,
          cx + w / 2, VenturiGeometry.centreY);

      canvas.drawRect(rect, Paint()..color = const Color(0xFFF5F7FA));

      // water inside the standpipe, up to the pressure head
      final level = VenturiGeometry.centreY - h[i] * VenturiGeometry.columnScale;
      final top = level
          .clamp(VenturiGeometry.standTop, VenturiGeometry.centreY)
          .toDouble();
      if (top < VenturiGeometry.centreY - 1) {
        canvas.drawRect(
          Rect.fromLTRB(cx - w / 2 + 2, top, cx + w / 2 - 2,
              VenturiGeometry.centreY),
          Paint()..color = water,
        );
        // meniscus
        canvas.drawLine(Offset(cx - w / 2 + 2, top),
            Offset(cx + w / 2 - 2, top), Paint()
              ..color = waterDeep
              ..strokeWidth = 3);
      }

      // tube walls (left and right only — open at the top, like a manometer)
      final wall = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = pipeStroke;
      canvas.drawLine(Offset(cx - w / 2, VenturiGeometry.standTop),
          Offset(cx - w / 2, VenturiGeometry.centreY), wall);
      canvas.drawLine(Offset(cx + w / 2, VenturiGeometry.standTop),
          Offset(cx + w / 2, VenturiGeometry.centreY), wall);
    }
  }

  /// A dashed line across the figure at the level of the wide-section
  /// columns, so the dip over the throat is unmistakable.
  void _drawReferenceLine(Canvas canvas, List<double> h) {
    final y = VenturiGeometry.centreY - h[0] * VenturiGeometry.columnScale;
    final paint = Paint()
      ..color = hi.withValues(alpha: 0.75)
      ..strokeWidth = 1.8;
    for (var x = 120.0; x < 800; x += 16) {
      canvas.drawLine(Offset(x, y), Offset(x + 8, y), paint);
    }
  }

  // ---------------------------------------------------------------- flow

  void _drawFlow(Canvas canvas) {
    canvas.save();
    canvas.clipPath(_pipePath());
    for (final p in particles) {
      final half = VenturiGeometry.halfHeightAt(p.x, model);
      final y = VenturiGeometry.centreY + lanes[p.lane] * half;
      final vPx = VenturiGeometry.speedAt(p.x, model) *
          _axialScale *
          kTimeScale;
      // A faster particle is drawn as a longer streak — motion blur as data.
      final len = (vPx * 0.045).clamp(7.0, 46.0).toDouble();
      canvas.drawLine(
        Offset(p.x - len / 2, y),
        Offset(p.x + len / 2, y),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.92)
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  void _drawArrows(Canvas canvas) {
    for (final x in [175.0, 450.0, 725.0]) {
      final v = VenturiGeometry.speedAt(x, model);
      final s = (6.0 + v * 1.6).clamp(7.0, 15.0).toDouble();
      final path = Path()
        ..moveTo(x - s, VenturiGeometry.centreY - s * 0.62)
        ..lineTo(x + s, VenturiGeometry.centreY)
        ..lineTo(x - s, VenturiGeometry.centreY + s * 0.62)
        ..close();
      canvas.drawPath(path, Paint()..color = waterDeep);
    }
  }

  // -------------------------------------------------------------- labels

  void _text(Canvas canvas, String s, Offset at,
      {double size = 17,
      Color color = const Color(0xFF263238),
      FontWeight weight = FontWeight.normal,
      TextAlign align = TextAlign.left}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              fontSize: size,
              color: color,
              fontWeight: weight)),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = at.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, at.dy));
  }

  void _drawLabels(Canvas canvas, List<double> h) {
    final stations = [
      (VenturiGeometry.standX[0], model.wideSpeed, model.widePressure, 'WIDE'),
      (VenturiGeometry.standX[1], model.throatSpeed, model.throatPressure,
          'NARROW'),
      (VenturiGeometry.standX[2], model.wideSpeed, model.widePressure, 'WIDE'),
    ];

    for (var i = 0; i < stations.length; i++) {
      final (cx, v, p, name) = stations[i];
      final level = (VenturiGeometry.centreY -
              h[i] * VenturiGeometry.columnScale)
          .clamp(VenturiGeometry.standTop, VenturiGeometry.centreY)
          .toDouble();

      // pressure and head beside the column
      final empty = model.cavitates && i == 1;
      _text(canvas, empty ? 'column empties' : '${(p / 1000).toStringAsFixed(1)} kPa',
          Offset(cx + 24, level - 12),
          size: 17, weight: FontWeight.bold, color: empty ? lo : waterDeep);
      if (!empty) {
        _text(canvas, '${h[i].toStringAsFixed(2)} m of water',
            Offset(cx + 24, level + 8),
            size: 14, color: const Color(0xFF546E7A));
      }

      // station name and speed under the pipe
      _text(canvas, name, Offset(cx, 552),
          size: 18, weight: FontWeight.bold, align: TextAlign.center,
          color: i == 1 ? lo : hi);
      _text(canvas, '${v.toStringAsFixed(2)} m/s', Offset(cx, 576),
          size: 16, align: TextAlign.center);
    }

    _text(canvas, 'pressure here is LOWER', const Offset(450, 84),
        size: 16, weight: FontWeight.bold, align: TextAlign.center, color: lo);
    _text(canvas, 'water moves FASTER', const Offset(450, 600),
        size: 15, align: TextAlign.center, color: lo);
    _text(canvas, 'same level: equal pressure', const Offset(838, 128),
        size: 13, align: TextAlign.right, color: hi);
  }

  @override
  bool shouldRepaint(covariant _VenturiPainter old) =>
      old.model != model || old.showStreamlines != showStreamlines;
}
