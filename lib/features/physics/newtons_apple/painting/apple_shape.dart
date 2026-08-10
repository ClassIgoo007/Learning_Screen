import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Draws one cartoon apple centred on [center] with radius [radius].
///
/// Shared by the canopy, the grass and the falling apple so that every apple in
/// the scene is literally the same shape — no drift between layers.
void drawApple(
  Canvas canvas,
  Offset center,
  double radius, {
  double scaleX = 1.0,
  double scaleY = 1.0,
  double rotation = 0.0,
  bool leaf = true,
  Color body = Palette.appleRed,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  canvas.scale(scaleX, scaleY);

  final double r = radius;

  final Path fruit = Path()
    ..moveTo(0, -r * 0.62)
    ..cubicTo(-r * 0.24, -r * 1.06, -r * 1.04, -r * 0.86, -r, -r * 0.02)
    ..cubicTo(-r * 0.96, r * 0.92, -r * 0.34, r * 1.04, 0, r * 0.80)
    ..cubicTo(r * 0.34, r * 1.04, r * 0.96, r * 0.92, r, -r * 0.02)
    ..cubicTo(r * 1.04, -r * 0.86, r * 0.24, -r * 1.06, 0, -r * 0.62)
    ..close();

  canvas.drawPath(fruit, Paint()..color = body);

  // Shaded right-hand side, clipped to the fruit outline.
  canvas.save();
  canvas.clipPath(fruit);
  canvas.drawCircle(
    Offset(r * 0.72, r * 0.18),
    r * 0.86,
    Paint()..color = Palette.appleShade.withValues(alpha: 0.45),
  );
  canvas.restore();

  // Specular highlight.
  canvas.save();
  canvas.translate(-r * 0.42, -r * 0.36);
  canvas.rotate(-math.pi / 5);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 0.46, height: r * 0.24),
    Paint()..color = Colors.white.withValues(alpha: 0.42),
  );
  canvas.restore();

  // Stem.
  canvas.drawPath(
    Path()
      ..moveTo(0, -r * 0.66)
      ..quadraticBezierTo(r * 0.10, -r * 1.02, r * 0.20, -r * 1.24),
    Paint()
      ..color = Palette.stem
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.14
      ..strokeCap = StrokeCap.round,
  );

  if (leaf) {
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.02, -r * 0.92)
        ..quadraticBezierTo(-r * 0.62, -r * 1.34, -r * 0.86, -r * 0.96)
        ..quadraticBezierTo(-r * 0.48, -r * 0.74, -r * 0.02, -r * 0.92)
        ..close(),
      Paint()..color = Palette.appleLeaf,
    );
  }

  canvas.restore();
}
