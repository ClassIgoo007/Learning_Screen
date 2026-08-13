import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../animation/scene_metrics.dart';
import '../animation/scene_timeline.dart';
import '../theme/palette.dart';

/// Colours of the scene itself. These are physical-scene colours — sky, cloud
/// shadow, grass — so they stay fixed rather than following the UI palette.
class SceneColors {
  const SceneColors._();

  static const cloudLight = Color(0xFFC4CED8);
  static const cloudMid = Color(0xFFAAB6C2);
  static const cloudDark = Color(0xFF93A1AF);
  static const droplet = Color(0xFF5F7183);
  static const current = Palette.updraft;
  static const rain = Palette.rain;
  static const ground = Color(0xFF6F7A63);
}

/// The layers that never change: horizon, house, bushes. Sits behind a
/// RepaintBoundary and reports that it never needs repainting.
class GroundPainter extends CustomPainter {
  const GroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const y = SceneMetrics.groundY;
    final line = Paint()
      ..color = SceneColors.ground
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(60, y), const Offset(940, y), line);

    final solid = Paint()..color = SceneColors.ground;

    // House: body, then roof.
    canvas.drawRect(const Rect.fromLTWH(126, y - 46, 62, 46), solid);
    final roof = Path()
      ..moveTo(114, y - 46)
      ..lineTo(157, y - 76)
      ..lineTo(200, y - 46)
      ..close();
    canvas.drawPath(roof, solid);

    // Bushes.
    for (final b in const [
      [232.0, 688.0, 30.0, 16.0],
      [820.0, 686.0, 36.0, 18.0],
      [878.0, 690.0, 24.0, 14.0],
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(b[0], b[1]), width: b[2] * 2, height: b[3] * 2),
        solid,
      );
    }
  }

  @override
  bool shouldRepaint(GroundPainter oldDelegate) => false;
}

/// Cloud body and the droplets condensing inside it.
class CloudPainter extends CustomPainter {
  const CloudPainter(this.state);

  final SceneState state;

  static const _shades = [
    SceneColors.cloudLight,
    SceneColors.cloudMid,
    SceneColors.cloudDark,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (state.cloudOpacity <= 0.001) return;
    final o = state.cloudOpacity;

    void puff(Puff p) {
      // Each shade band bobs on its own phase, so the cloud breathes rather
      // than sliding as one block.
      final bob = state.breathe *
          math.cos(p.shade * 0.9) *
          (p.shade == 2 ? 0.4 : 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: p.center.translate(0, bob),
          width: p.rx * 2,
          height: p.ry * 2,
        ),
        Paint()..color = _shades[p.shade].withValues(alpha: o),
      );
    }

    for (final p in SceneMetrics.puffs) {
      puff(p);
    }

    // Flat base: two lobes plus a slab, so the cloud sits on a level bottom
    // the way a cumulonimbus does.
    for (final p in SceneMetrics.baseLobes) {
      canvas.drawOval(
        Rect.fromCenter(
            center: p.center, width: p.rx * 2, height: p.ry * 2),
        Paint()..color = SceneColors.cloudDark.withValues(alpha: o),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(268, 336, 742, 420),
        const Radius.circular(38),
      ),
      Paint()..color = SceneColors.cloudDark.withValues(alpha: o),
    );

    if (state.condensationOpacity > 0.001) {
      final drop = Paint()
        ..color = SceneColors.droplet.withValues(alpha: state.condensationOpacity);
      for (var i = 0; i < SceneMetrics.condensation.length; i++) {
        final c = SceneMetrics.condensation[i];
        final wobble = math.sin((state.t * 2 * math.pi) + i) * 3;
        canvas.drawCircle(c.translate(0, wobble), 5.5, drop);
      }
    }
  }

  @override
  bool shouldRepaint(CloudPainter old) => old.state != state;
}

/// The ascending currents — dashed strokes flowing upward along fixed paths,
/// each with a chevron at its head.
class CurrentsPainter extends CustomPainter {
  const CurrentsPainter(this.state, {required this.labelColor});

  final SceneState state;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in SceneMetrics.currents) {
      final path = Path()
        ..moveTo(c.start.dx, c.start.dy)
        ..cubicTo(c.c1.dx, c.c1.dy, c.c2.dx, c.c2.dy, c.end.dx, c.end.dy);

      final paint = Paint()
        ..color = SceneColors.current.withValues(alpha: c.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(_dashed(path, 22, 18, state.dashOffset), paint);

      // Chevron head, pointing along the tangent at the top of the path.
      final metric = path.computeMetrics().first;
      final tan = metric.getTangentForOffset(metric.length)!;
      final angle = math.atan2(tan.vector.dy, tan.vector.dx);
      canvas.save();
      canvas.translate(c.end.dx, c.end.dy);
      canvas.rotate(angle + math.pi / 2);
      final head = Path()
        ..moveTo(-9, 15)
        ..lineTo(0, 0)
        ..lineTo(9, 15);
      canvas.drawPath(head, paint..strokeJoin = StrokeJoin.round);
      canvas.restore();
    }

    _drawLabel(canvas, 'Ascending air currents',
        anchor: const Offset(700, 596),
        target: const Offset(788, 560),
        color: labelColor);
  }

  /// Rebuilds [source] as a dash pattern shifted by [offset] (0..1 of one
  /// period), which is what makes the current appear to flow.
  static Path _dashed(Path source, double dash, double gap, double offset) {
    final out = Path();
    final period = dash + gap;
    for (final metric in source.computeMetrics()) {
      var start = -period + (offset % 1.0) * period;
      while (start < metric.length) {
        final s = math.max(start, 0.0);
        final e = math.min(start + dash, metric.length);
        if (e > s) out.addPath(metric.extractPath(s, e), Offset.zero);
        start += period;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(CurrentsPainter old) =>
      old.state != state || old.labelColor != labelColor;
}

/// Rain drops falling from the cloud base, through the rising current.
class RainPainter extends CustomPainter {
  const RainPainter(this.state, {required this.labelColor});

  final SceneState state;
  final Color labelColor;

  static const _from = SceneMetrics.cloudBaseY;
  static const _distance = 250.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (state.rainOpacity <= 0.001) return;

    final paint = Paint()
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;

    for (final d in SceneMetrics.drops) {
      final p = state.dropProgress(d.phase, d.speed);
      // Fade in as the drop leaves the cloud, out as it reaches the ground.
      final fade = (p < 0.12 ? p / 0.12 : (p > 0.85 ? (1 - p) / 0.15 : 1.0))
          .clamp(0.0, 1.0);
      final y = _from + p * _distance;
      paint.color =
          SceneColors.rain.withValues(alpha: fade * state.rainOpacity * 0.95);
      canvas.drawLine(Offset(d.x, y), Offset(d.x, y + 20), paint);
    }

    _drawLabel(canvas, 'Rain drops',
        anchor: const Offset(716, 500),
        target: const Offset(788, 470),
        color: labelColor.withValues(alpha: state.rainOpacity));
  }

  @override
  bool shouldRepaint(RainPainter old) =>
      old.state != state || old.labelColor != labelColor;
}

/// Dashed leader line plus caption, shared by the two annotated layers.
void _drawLabel(
  Canvas canvas,
  String text, {
  required Offset anchor,
  required Offset target,
  required Color color,
}) {
  final leader = Paint()
    ..color = color.withValues(alpha: color.a * 0.5)
    ..strokeWidth = 1.2;
  const dash = 7.0;
  final delta = target - anchor;
  final length = delta.distance;
  final step = delta / length;
  for (var i = 0.0; i < length; i += dash * 2) {
    canvas.drawLine(
      anchor + step * i,
      anchor + step * math.min(i + dash, length),
      leader,
    );
  }
  canvas.drawCircle(anchor, 3.5, Paint()..color = color);

  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 21, height: 1.2),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout(maxWidth: 200);
  tp.paint(canvas, target + const Offset(8, -10));
}
