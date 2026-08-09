import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rebuilds [source] as a dash pattern shifted by [offset] (in periods).
/// Used here for the hidden edges of the vessel; a moving offset would make
/// the dashes travel along the path.
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
  tp.paint(canvas, centred ? at - Offset(tp.width / 2, tp.height / 2) : at);
}
