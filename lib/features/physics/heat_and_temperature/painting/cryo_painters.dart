import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animation/cryo_timeline.dart';
import '../theme/palette.dart';
import 'flow.dart';

/// Fig. 4-9 — the principle of cryogenics. Gas heated by compression in the
/// upper chamber loses heat to the surroundings; gas cooled by expansion in
/// the lower chamber absorbs heat from them. Heat flow is drawn, as in the
/// figure, with wavy-tailed arrows.
class CryogenicPainter extends CustomPainter {
  const CryogenicPainter(this.state, {required this.labelColor});

  final CryoState state;
  final Color labelColor;

  static const _outline = Color(0xFF3E4750);
  static const _metal = Color(0xFF6B7A87);
  static const _hot = Palette.hot;
  static const _cold = Palette.cold;
  static const _gas = Color(0xFF5D6B78);

  @override
  void paint(Canvas canvas, Size size) {
    _paintRegions(canvas);
    _paintPipes(canvas);
    _paintChambers(canvas);
    _paintMotor(canvas);
    _paintValve(canvas);
    _paintHeatArrows(canvas);
    _paintLabels(canvas);
  }

  /// Tinted bands behind each chamber, naming the two temperature regions.
  void _paintRegions(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(300, 104, 720, 376),
        const Radius.circular(18),
      ),
      Paint()..color = _hot.withOpacity(0.06 + 0.06 * state.heatOutStrength),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(300, 566, 720, 846),
        const Radius.circular(18),
      ),
      Paint()..color = _cold.withOpacity(0.06 + 0.06 * state.heatInStrength),
    );
  }

  void _paintPipes(Canvas canvas) {
    final pipe = Paint()
      ..color = _metal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final bore = Paint()
      ..color = Palette.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final charge = CryoMetrics.chargeLeg();
    final back = CryoMetrics.returnLeg();
    for (final path in [charge, back]) {
      canvas.drawPath(path, pipe);
      canvas.drawPath(path, bore);
    }

    // Gas travelling along the pipes. The charge leg always runs; the return
    // leg only carries gas once the valve has opened.
    void flow(Path path, double opacity, double speed) {
      if (opacity <= 0.01) return;
      final paint = Paint()
        ..color = _gas.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(dashPath(path, 16, 22, state.t * speed), paint);
      drawTravellingHeads(canvas, path, state.t * speed, paint,
          count: 4, size: 9);
    }

    flow(charge, 0.9, 1);
    flow(back, state.returnFlow * 0.9, 1);
  }

  void _paintChambers(Canvas canvas) {
    void chamber(Rect r, double fill, Color tint) {
      // An opaque base first: the return pipe runs behind the lower chamber,
      // and a translucent fill would let it show through.
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        Paint()..color = Palette.paper,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        Paint()..color = tint.withOpacity(0.12),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        Paint()
          ..color = _outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // Speckled gas: the fraction of dots shown is the density of the gas,
      // which is the whole point of the figure.
      final shown = (CryoMetrics.speckles.length * fill).round();
      final dot = Paint()..color = _gas.withOpacity(0.85);
      for (var i = 0; i < shown; i++) {
        final s = CryoMetrics.speckles[i];
        final jitter = math.sin(state.t * 2 * math.pi + i) * 3;
        canvas.drawCircle(
          Offset(r.left + s.dx * r.width, r.top + s.dy * r.height + jitter),
          4,
          dot,
        );
      }
    }

    chamber(CryoMetrics.compressionChamber, state.compressionFill, _hot);
    chamber(CryoMetrics.expansionChamber, state.expansionFill, _cold);
  }

  void _paintMotor(Canvas canvas) {
    final body = Paint()..color = _metal;
    final line = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Electric motor: a drum on a plinth, with its cable.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          CryoMetrics.motorBody, const Radius.circular(10)),
      body,
    );
    for (var i = 1; i < 5; i++) {
      final x = CryoMetrics.motorBody.left +
          CryoMetrics.motorBody.width * i / 5;
      canvas.drawLine(
        Offset(x, CryoMetrics.motorBody.top + 12),
        Offset(x, CryoMetrics.motorBody.bottom - 12),
        Paint()
          ..color = Palette.paper.withOpacity(0.5)
          ..strokeWidth = 3,
      );
    }
    canvas.drawRect(const Rect.fromLTRB(76, 540, 174, 560), body);
    canvas.drawPath(
      Path()
        ..moveTo(60, 566)
        ..cubicTo(46, 596, 96, 604, 78, 634),
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Shaft from the motor to the compressor, and the compressor itself,
    // hatched the way the figure hatches it.
    canvas.drawRect(const Rect.fromLTRB(190, 476, 236, 494), body);
    final c = CryoMetrics.compressorBody;
    canvas.drawRect(c, Paint()..color = _metal.withOpacity(0.25));
    canvas.drawRect(c, line);
    canvas.save();
    canvas.clipRect(c);
    for (var x = c.left - c.height; x < c.right; x += 16) {
      canvas.drawLine(Offset(x, c.bottom), Offset(x + c.height, c.top),
          Paint()..color = _outline.withOpacity(0.5)..strokeWidth = 2);
    }
    canvas.restore();

    // The arrow marking the mechanical work put in.
    final work = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(const Offset(120, 690), const Offset(250, 596), work);
    canvas.drawPath(
      Path()
        ..moveTo(222, 596)
        ..lineTo(252, 594)
        ..lineTo(242, 622),
      work..style = PaintingStyle.fill,
    );
  }

  /// The valve on the pipe joining the two chambers: a bow-tie that opens.
  void _paintValve(Canvas canvas) {
    const c = CryoMetrics.valveCentre;
    final open = state.valveOpen;
    final paint = Paint()..color = _metal;

    canvas.drawCircle(c, 30, Paint()..color = Palette.paper);
    canvas.drawCircle(
      c,
      30,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Closed: the flap lies across the bore. Open: it swings in line with it.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate((1 - open) * math.pi / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-4, -24, 4, 24),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.restore();
    canvas.drawCircle(c, 5, Paint()..color = _outline);
  }

  /// Wavy-tailed arrows, the figure's notation for heat flow. The tail is a
  /// sine wave that travels, so the direction of flow is unmistakable.
  void _paintHeatArrows(Canvas canvas) {
    void wavy(HeatArrow a, Color colour, double strength, bool outward) {
      if (strength <= 0.02) return;
      final paint = Paint()
        ..color = colour.withOpacity(strength)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Heat leaving starts at the wall and travels away from it; heat
      // arriving starts outside and travels toward it. Either way the arrow
      // head ends up pointing the way the heat is going.
      final sign = a.direction.toDouble();
      const length = 62.0;
      final origin = outward
          ? a.at
          : a.at.translate(0, -sign * (length + 12));

      final path = Path()..moveTo(origin.dx, origin.dy);
      for (var i = 0.0; i <= length; i += 4) {
        final wobble =
            math.sin((i / 13) - state.heatPhase * 2 * math.pi) * 5.5;
        path.lineTo(origin.dx + wobble, origin.dy + sign * i);
      }
      canvas.drawPath(path, paint);

      final tip = Offset(origin.dx, origin.dy + sign * (length + 12));
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx - 9, tip.dy - sign * 13)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + 9, tip.dy - sign * 13),
        paint,
      );
    }

    for (final a in CryoMetrics.heatOut) {
      wavy(a, _hot, state.heatOutStrength, true);
    }
    for (final a in CryoMetrics.heatIn) {
      wavy(a, _cold, state.heatInStrength, false);
    }
  }

  void _paintLabels(Canvas canvas) {
    paintLabel(canvas, 'Compression chamber', const Offset(392, 24),
        color: labelColor, fontSize: 22, maxWidth: 300);
    paintLabel(canvas, 'Expansion chamber', const Offset(400, 892),
        color: labelColor, fontSize: 22, maxWidth: 300);
    paintLabel(canvas, 'High-temperature\nregion', const Offset(28, 150),
        color: _hot, fontSize: 21, maxWidth: 240);
    paintLabel(canvas, 'Low-temperature\nregion', const Offset(28, 616),
        color: _cold, fontSize: 21, maxWidth: 240);
    paintLabel(canvas, 'Electric motor', const Offset(46, 392),
        color: labelColor, fontSize: 21, maxWidth: 240);
    paintLabel(canvas, 'Compressor', const Offset(236, 404),
        color: labelColor, fontSize: 21, maxWidth: 240);
    paintLabel(canvas, 'Mechanical\nwork', const Offset(44, 752),
        color: labelColor, fontSize: 21, maxWidth: 200);
    paintLabel(
      canvas,
      state.valveOpen > 0.5 ? 'Valve (opened)' : 'Valve (closed)',
      const Offset(800, 452),
      color: labelColor,
      fontSize: 21,
      maxWidth: 200,
    );
  }

  @override
  bool shouldRepaint(CryogenicPainter old) =>
      old.state != state || old.labelColor != labelColor;
}
