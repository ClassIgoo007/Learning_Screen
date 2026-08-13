import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rebuilds [source] as a dash pattern shifted by [offset] (in periods).
/// A moving offset makes the dashes travel along the path — how the gas in
/// the refrigerant lines is drawn as flowing rather than static.
Path dashPath(Path source, double dash, double gap, double offset) {
  final out = Path();
  final period = dash + gap;
  final shift = ((offset % 1.0) + 1.0) % 1.0;
  for (final metric in source.computeMetrics()) {
    var start = -period + shift * period;
    while (start < metric.length) {
      final s = math.max(start, 0.0);
      final e = math.min(start + dash, metric.length);
      if (e > s) out.addPath(metric.extractPath(s, e), Offset.zero);
      start += period;
    }
  }
  return out;
}

/// Draws [count] small triangular arrowheads travelling along [path], evenly
/// spaced and advancing with [progress] (in path-length periods) — the
/// direction-carrying companion to [dashPath]'s dashes, so a glance at the
/// pipe shows which way the gas is moving, not just that it's moving.
///
/// The reference implementation this lesson is ported from calls this
/// function (in its `cryo_painters.dart`) but never defines it anywhere in
/// its own source — a gap in the reference, not a deliberate omission — so
/// this is a new implementation of the evidently intended behaviour, filled
/// in to make the flow direction on the charge and return legs legible.
void drawTravellingHeads(
  Canvas canvas,
  Path path,
  double progress,
  Paint paint, {
  required int count,
  required double size,
}) {
  final head = Paint()
    ..color = paint.color
    ..style = PaintingStyle.fill;

  for (final metric in path.computeMetrics()) {
    final period = metric.length / count;
    if (period <= 0) continue;
    final shift = ((progress * period) % period + period) % period;
    for (var i = 0; i < count; i++) {
      final distance = (i * period + shift) % metric.length;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;
      final pos = tangent.position;
      final dir = tangent.vector;
      final normal = Offset(-dir.dy, dir.dx);
      final tip = pos + dir * size;
      final base = pos - dir * (size * 0.6);
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo((base + normal * size * 0.5).dx, (base + normal * size * 0.5).dy)
          ..lineTo((base - normal * size * 0.5).dx, (base - normal * size * 0.5).dy)
          ..close(),
        head,
      );
    }
  }
}

/// Lays out a short caption and paints it with its left edge at [at].
void paintLabel(
  Canvas canvas,
  String text,
  Offset at, {
  required Color color,
  double fontSize = 20,
  TextAlign align = TextAlign.left,
  double maxWidth = 260,
  bool centred = false,
  bool centredHorizontally = false,
  FontStyle style = FontStyle.normal,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        height: 1.2,
        fontStyle: style,
      ),
    ),
    textAlign: align,
    textDirection: ui.TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  final origin = centred
      ? at - Offset(tp.width / 2, tp.height / 2)
      : centredHorizontally
          ? at - Offset(tp.width / 2, 0)
          : at;
  tp.paint(canvas, origin);
}
