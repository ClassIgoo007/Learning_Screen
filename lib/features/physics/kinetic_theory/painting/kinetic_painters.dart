import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animation/kinetic_timeline.dart';
import '../theme/palette.dart';
import 'flow.dart';

/// Fig. 8-8 — a closed vessel drawn in oblique projection, with its molecules
/// rushing about inside. Squeezing the vessel and warming it are two separate
/// controls, so the two gas laws can be shown one at a time.
class VesselPainter extends CustomPainter {
  const VesselPainter(this.state, {required this.labelColor});

  final VesselState state;
  final Color labelColor;

  static const _edge = Color(0xFF4A5560);
  static const _molecule = Palette.slate;
  static const _impact = Palette.updraft;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBox(canvas);
    _paintAreaA(canvas);
    _paintMolecules(canvas);
    _paintGauge(canvas);
  }

  void _paintBox(Canvas canvas) {
    const l = VesselMetrics.left;
    const t = VesselMetrics.top;
    const b = VesselMetrics.bottom;
    const d = VesselMetrics.depth;
    final r = state.right;

    final solid = Paint()
      ..color = _edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    final hidden = Paint()
      ..color = _edge.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Back face and the two hidden edges that reach it, dashed.
    final back = Path()
      ..addRect(Rect.fromLTRB(l + d.dx, t + d.dy, r + d.dx, b + d.dy));
    canvas.drawPath(dashPath(back, 12, 9, 0), hidden);
    for (final corner in [
      [const Offset(l, b), Offset(l + d.dx, b + d.dy)],
      [Offset(r, b), Offset(r + d.dx, b + d.dy)],
    ]) {
      canvas.drawPath(
        dashPath(
            Path()
              ..moveTo(corner[0].dx, corner[0].dy)
              ..lineTo(corner[1].dx, corner[1].dy),
            12,
            9,
            0),
        hidden,
      );
    }

    // The two visible connecting edges and the front face.
    canvas.drawLine(const Offset(l, t), Offset(l + d.dx, t + d.dy), solid);
    canvas.drawLine(Offset(r, t), Offset(r + d.dx, t + d.dy), solid);
    canvas.drawLine(Offset(r, b), Offset(r + d.dx, b + d.dy), solid);
    canvas.drawRect(Rect.fromLTRB(l, t, r, b), solid);
    canvas.drawRect(
      Rect.fromLTRB(l, t, r, b),
      Paint()..color = _edge.withValues(alpha: 0.05),
    );

    // The arrow that marks the wall being driven inward.
    if (state.compression > 0.01) {
      final arrow = Paint()
        ..color = _impact.withValues(alpha: state.compression)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      const y = (t + b) / 2;
      canvas.drawLine(Offset(r + 96, y), Offset(r + 26, y), arrow);
      canvas.drawPath(
        Path()
          ..moveTo(r + 44, y - 13)
          ..lineTo(r + 24, y)
          ..lineTo(r + 44, y + 13),
        arrow,
      );
    }
  }

  /// The patch of wall the text calls a unit area A, hatched so the impacts
  /// landing on it can be counted by eye.
  void _paintAreaA(Canvas canvas) {
    const a = VesselMetrics.areaA;
    canvas.drawRect(a, Paint()..color = _impact.withValues(alpha: 0.22));
    canvas.drawRect(
      a,
      Paint()
        ..color = _impact
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    paintLabel(canvas, 'A', Offset(a.left + 22, a.center.dy - 16),
        color: _impact, fontSize: 26);
  }

  void _paintMolecules(Canvas canvas) {
    final dot = Paint()..color = _molecule;
    final tail = Paint()
      ..color = _molecule.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final m in VesselMetrics.molecules) {
      final p = state.positionOf(m);
      final h = state.headingOf(m);
      // The tail lengthens with speed, so a warmer gas visibly moves faster.
      final len = 26 * state.speed;
      final tip = p + h * 13;
      final base = tip - h * 10;
      final side = _perp(h) * 7;

      canvas.drawLine(p - h * len, p, tail);
      canvas.drawPath(
        Path()
          ..moveTo((base + side).dx, (base + side).dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo((base - side).dx, (base - side).dy),
        tail,
      );
      canvas.drawCircle(p, 6, dot);

      // A starburst wherever a molecule is at the wall — the bombardment the
      // pressure actually consists of.
      _paintImpact(canvas, p);
    }
  }

  /// A hotter gas doesn't just hit the wall more often — each hit lands
  /// harder. [state.speed] (1 at rest, up to 1.85 at full heat) drives the
  /// burst wider, thicker and busier. Compression alone (Beat 2) leaves
  /// impact size unchanged — only the shorter path raises how often they
  /// appear, which is what higher pressure at constant temperature means.
  void _paintImpact(Canvas canvas, Offset p) {
    const margin = 26.0;
    final atWall = p.dx < VesselMetrics.left + margin ||
        p.dx > state.right - margin ||
        p.dy < VesselMetrics.top + margin ||
        p.dy > VesselMetrics.bottom - margin;
    if (!atWall) return;

    final force = (state.speed - 1) / 0.85; // 0 at rest .. 1 at full heat
    final reach = 15.0 + 6.0 * force;
    final rayCount = force > 0.5 ? 8 : 6;
    // Slightly brighter at the wall when the vessel is small — more transits
    // per second, not harder hits from temperature.
    final densityBoost =
        ((1 / state.volumeFraction) - 1).clamp(0.0, 1.0) * 0.25;

    canvas.drawPath(
      dashPath(
        Path()..addOval(Rect.fromCircle(center: p, radius: reach * 0.7)),
        4,
        3,
        0,
      ),
      Paint()
        ..color = _impact.withValues(alpha: 0.5 + densityBoost)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    final ray = Paint()
      ..color = _impact.withValues(alpha: 0.85 + densityBoost)
      ..strokeWidth = 2.5 + 1.5 * force
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < rayCount; i++) {
      final a = i * 2 * math.pi / rayCount;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(p + d * (reach * 0.55), p + d * reach, ray);
    }
  }

  /// A bar reading p = T / V, so the two laws can be watched rather than
  /// taken on trust.
  void _paintGauge(Canvas canvas) {
    const x = 900.0;
    const top = 240.0;
    const height = 300.0;
    final track = Paint()..color = _edge.withValues(alpha: 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(x, top, 26, height),
        const Radius.circular(13),
      ),
      track,
    );

    // Scale tops out at three times the relaxed, cold pressure so Beat 2's
    // isothermal squeeze (p ∝ 1/V) reads clearly on the bar.
    final fill = (state.pressure / 3).clamp(0.0, 1.0) * height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top + height - fill, 26, fill),
        const Radius.circular(13),
      ),
      Paint()..color = _impact,
    );
    paintLabel(canvas, 'Pressure', const Offset(846, top - 42),
        color: labelColor, fontSize: 20);
    paintLabel(canvas, 'on area A', const Offset(846, top - 18),
        color: labelColor, fontSize: 20);
    paintLabel(canvas, 'p = A × T / V', const Offset(838, top + height + 18),
        color: labelColor, fontSize: 20);
  }

  static Offset _perp(Offset v) => Offset(-v.dy, v.dx);

  @override
  bool shouldRepaint(VesselPainter old) =>
      old.state != state || old.labelColor != labelColor;
}

/// Fig. 8-9 — Brown's apparatus: ping-pong balls between two glass plates,
/// kicked by a cogwheel and holding up a movable piston.
class ApparatusPainter extends CustomPainter {
  const ApparatusPainter(this.state, {required this.labelColor});

  final ApparatusState state;
  final Color labelColor;

  static const _frame = Color(0xFF4A5560);
  static const _glass = Color(0xFF9FB4C4);
  static const _ball = Palette.updraft;
  static const _metal = Color(0xFF6B7A87);

  @override
  void paint(Canvas canvas, Size size) {
    _paintEnclosure(canvas);
    _paintBalls(canvas);
    _paintPiston(canvas);
    _paintWheel(canvas);
    _paintLabels(canvas);
  }

  void _paintEnclosure(Canvas canvas) {
    const l = ApparatusMetrics.boxLeft;
    const r = ApparatusMetrics.boxRight;
    const t = ApparatusMetrics.boxTop;
    const f = ApparatusMetrics.floor;

    // The gap between the two glass plates, seen edge on.
    canvas.drawRect(
      const Rect.fromLTRB(l, t, r, f),
      Paint()..color = _glass.withValues(alpha: 0.13),
    );
    final rail = Paint()
      ..color = _frame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(const Offset(l, t), const Offset(l, f), rail);
    canvas.drawLine(const Offset(r, t), const Offset(r, f), rail);

    // Floor, with a gap where the cogwheel reaches through.
    canvas.drawLine(const Offset(l, f), const Offset(430, f), rail);
    canvas.drawLine(const Offset(570, f), const Offset(r, f), rail);

    // Feet.
    final foot = Paint()..color = _metal;
    canvas.drawRect(const Rect.fromLTWH(l - 26, 748, 190, 14), foot);
    canvas.drawRect(const Rect.fromLTWH(r - 164, 748, 190, 14), foot);
  }

  void _paintBalls(Canvas canvas) {
    final fill = Paint()..color = _ball;
    final rim = Paint()
      ..color = _ball.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final b in ApparatusMetrics.balls) {
      final c = state.ballCentre(b);
      canvas.drawCircle(c, ApparatusMetrics.ballRadius, fill);
      canvas.drawCircle(c, ApparatusMetrics.ballRadius + 3, rim);
    }
  }

  void _paintPiston(Canvas canvas) {
    final y = state.pistonY;
    final paint = Paint()..color = _metal;

    // Plate, rod and cross-piece.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(ApparatusMetrics.boxLeft + 8, y,
            ApparatusMetrics.boxRight - 8, y + 22),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRect(
        Rect.fromLTWH(492, ApparatusMetrics.boxTop - 40, 16, y - 56), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(430, ApparatusMetrics.boxTop - 54, 140, 18),
        const Radius.circular(6),
      ),
      paint,
    );

    // How far the bombardment has driven the piston up from its low mark.
    final rise = ApparatusMetrics.pistonLow - y;
    if (rise > 2) {
      final arrow = Paint()
        ..color = _ball
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      const x = ApparatusMetrics.boxRight + 46;
      canvas.drawLine(
          const Offset(x, ApparatusMetrics.pistonLow), Offset(x, y + 6), arrow);
      canvas.drawPath(
        Path()
          ..moveTo(x - 11, y + 22)
          ..lineTo(x, y + 5)
          ..lineTo(x + 11, y + 22),
        arrow,
      );
    }
  }

  void _paintWheel(Canvas canvas) {
    const c = ApparatusMetrics.wheelCentre;
    const r = ApparatusMetrics.wheelRadius;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(state.wheelAngle);

    final paint = Paint()..color = _metal;
    canvas.drawCircle(Offset.zero, r, paint);
    for (var i = 0; i < ApparatusMetrics.teeth; i++) {
      final a = i * 2 * math.pi / ApparatusMetrics.teeth;
      canvas.save();
      canvas.rotate(a);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-9, -r - 17, 18, 22),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(
        Offset.zero, 13, Paint()..color = const Color(0xFFFBF7F0));
    canvas.restore();
  }

  void _paintLabels(Canvas canvas) {
    void tag(String text, Offset anchor, Offset target) {
      final leader = Paint()
        ..color = labelColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.2;
      canvas.drawLine(anchor, target, leader);
      canvas.drawCircle(anchor, 3.5, Paint()..color = labelColor);
      paintLabel(canvas, text, target + const Offset(8, -12),
          color: labelColor, fontSize: 20, maxWidth: 230);
    }

    tag(
        'Movable piston',
        Offset(ApparatusMetrics.boxRight - 60, state.pistonY + 10),
        const Offset(748, 200));
    tag('Ping-pong balls', const Offset(360, 600), const Offset(96, 560));
    tag('Cogwheel driven by a motor', const Offset(452, 700),
        const Offset(96, 700));
    paintLabel(canvas, 'Two glass plates,\njust far enough apart',
        const Offset(48, 120),
        color: labelColor, fontSize: 20, maxWidth: 220);
  }

  @override
  bool shouldRepaint(ApparatusPainter old) =>
      old.state != state || old.labelColor != labelColor;
}
