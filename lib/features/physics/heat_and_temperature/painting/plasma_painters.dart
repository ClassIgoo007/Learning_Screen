import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animation/cryo_timeline.dart';
import '../theme/palette.dart';
import 'flow.dart';

/// Fig. 4-8 — a plasma jet, produced by blowing a stream of noble gas through
/// a high-current electric arc. The plume is drawn as streaks of ionised gas
/// leaving the nozzle, and a scale beside it reads the temperature against
/// two familiar marks.
class PlasmaPainter extends CustomPainter {
  const PlasmaPainter(this.state, {required this.labelColor});

  final PlasmaState state;
  final Color labelColor;

  static const _metal = Color(0xFF6B7A87);
  static const _outline = Color(0xFF3E4750);
  static const _core = Color(0xFFFFF2D4);
  static const _flame = Palette.accent;
  static const _hot = Palette.hot;

  @override
  void paint(Canvas canvas, Size size) {
    _paintTorch(canvas);
    _paintArc(canvas);
    _paintJet(canvas);
    _paintScale(canvas);
    _paintLabels(canvas);
  }

  void _paintTorch(Canvas canvas) {
    final body = Paint()..color = _metal;
    final edge = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Gas inlet on top, then the barrel, then the nozzle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(214, 150, 268, 244),
        const Radius.circular(8),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(198, 128, 284, 158),
        const Radius.circular(8),
      ),
      body,
    );
    final barrel = RRect.fromRectAndRadius(
        PlasmaMetrics.bodyRect, const Radius.circular(16));
    canvas.drawRRect(barrel, body);
    canvas.drawRRect(barrel, edge);

    // Cooling fins.
    for (var i = 0; i < 4; i++) {
      final x = 196.0 + i * 30;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 224, 14, 172),
          const Radius.circular(5),
        ),
        Paint()..color = _metal.withValues(alpha: 0.75),
      );
    }

    // Nozzle: a truncated cone narrowing to the throat.
    canvas.drawPath(
      Path()
        ..moveTo(380, 262)
        ..lineTo(452, 292)
        ..lineTo(452, 328)
        ..lineTo(380, 358)
        ..close(),
      body,
    );
    canvas.drawCircle(const Offset(452, 310), 15, Paint()..color = _outline);

    // Electrode running down the axis to its tip.
    canvas.drawRect(const Rect.fromLTRB(206, 302, 300, 318),
        Paint()..color = _outline);

    // Supply cables.
    final cable = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(150, 300)
        ..cubicTo(96, 300, 84, 360, 60, 396),
      cable,
    );
    canvas.drawPath(
      Path()
        ..moveTo(150, 340)
        ..cubicTo(104, 344, 92, 400, 66, 436),
      cable,
    );
  }

  /// The arc itself: a jagged discharge from the electrode tip to the throat,
  /// redrawn on a fast flicker so it never looks static.
  void _paintArc(Canvas canvas) {
    final seed = (state.t * 24).floor();
    final rng = math.Random(seed);
    final path = Path()
      ..moveTo(PlasmaMetrics.electrodeTip.dx, PlasmaMetrics.electrodeTip.dy);
    const steps = 6;
    for (var i = 1; i <= steps; i++) {
      final u = i / steps;
      final x = PlasmaMetrics.electrodeTip.dx +
          (PlasmaMetrics.nozzleTip.dx - PlasmaMetrics.electrodeTip.dx) * u;
      final y = 310 + (i == steps ? 0.0 : (rng.nextDouble() - 0.5) * 34);
      path.lineTo(x, y);
    }

    final glow = Paint()
      ..color = _core.withValues(alpha: 0.55 * state.flicker)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(path, glow);
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(_flame, _core, state.intensity)!
            .withValues(alpha: state.flicker)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  /// The plume: a soft cone plus individual streaks of ionised gas, each
  /// fading as it travels and cools.
  void _paintJet(Canvas canvas) {
    const start = PlasmaMetrics.jetStart;
    final span = (PlasmaMetrics.jetEnd.dx - start.dx) * state.reach;

    // The cone, brightest at the throat.
    final cone = Path()
      ..moveTo(start.dx, start.dy - 16)
      ..quadraticBezierTo(
          start.dx + span * 0.6, start.dy - 52, start.dx + span, start.dy)
      ..quadraticBezierTo(
          start.dx + span * 0.6, start.dy + 52, start.dx, start.dy + 16)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _core.withValues(alpha: 0.95),
            _flame.withValues(alpha: 0.55),
            _hot.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
            Rect.fromLTWH(start.dx, start.dy - 60, span, 120))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Streaks of gas, drawn on top of the cone.
    for (final s in PlasmaMetrics.stream) {
      final u = state.streakProgress(s);
      final x = start.dx + u * span;
      final y = start.dy + s.spread * (10 + u * 44);
      final fade = (u < 0.1 ? u / 0.1 : (1 - u) / 0.55).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 26 + 14 * s.speed, y),
        Paint()
          ..color = Color.lerp(_core, _hot, u)!
              .withValues(alpha: fade * (0.45 + 0.55 * state.intensity))
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// A ruler beneath the torch with the kitchen flame and the sun's surface
  /// marked, so 15,000° means something. It runs horizontally so nothing has
  /// to compete with the torch for space.
  void _paintScale(Canvas canvas) {
    const left = 80.0;
    const right = 920.0;
    const y = 546.0;
    const span = right - left;

    double xFor(double celsius) =>
        left + span * (celsius / PlasmaMetrics.scaleMax).clamp(0.0, 1.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(left, y, right, y + 16),
        const Radius.circular(8),
      ),
      Paint()..color = _outline.withValues(alpha: 0.12),
    );

    final fillTo = xFor(state.temperature);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, y, fillTo, y + 16),
        const Radius.circular(8),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Palette.accent, Palette.hot],
        ).createShader(Rect.fromLTRB(left, y, fillTo, y + 16)),
    );

    for (final mark in PlasmaMetrics.scale) {
      final x = xFor(mark.celsius);
      canvas.drawLine(
        Offset(x, y - 12),
        Offset(x, y + 28),
        Paint()
          ..color = labelColor.withValues(alpha: 0.55)
          ..strokeWidth = 1.4,
      );
      paintLabel(canvas, '${_thousands(mark.celsius)}°C\n${mark.label}',
          Offset(x.clamp(left + 60, right - 60), y + 34),
          color: labelColor,
          fontSize: 17,
          maxWidth: 180,
          align: TextAlign.center,
          centredHorizontally: true);
    }

    paintLabel(canvas, '${_thousands(state.temperature)}°C',
        const Offset(left, y - 52),
        color: _hot, fontSize: 28, maxWidth: 240);
  }

  static String _thousands(double v) {
    final n = v.round();
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  void _paintLabels(Canvas canvas) {
    paintLabel(canvas, 'Noble gas in', const Offset(196, 92),
        color: labelColor, fontSize: 19, maxWidth: 200);
    paintLabel(canvas, 'High-current\narc discharge', const Offset(212, 424),
        color: labelColor, fontSize: 19, maxWidth: 220);
    paintLabel(canvas, 'Plasma jet: positive ions and free electrons',
        const Offset(520, 430),
        color: labelColor, fontSize: 19, maxWidth: 420);
  }

  @override
  bool shouldRepaint(PlasmaPainter old) =>
      old.state != state || old.labelColor != labelColor;
}
