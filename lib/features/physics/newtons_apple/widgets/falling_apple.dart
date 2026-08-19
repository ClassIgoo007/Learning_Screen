import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animation/scene_metrics.dart';
import '../animation/scene_timeline.dart';
import '../painting/apple_shape.dart';
import '../theme/palette.dart';

/// The apple that actually falls, plus its speed lines and the impact puff
/// where it lands on Newton's head.
///
/// It is positioned by [SceneMetrics.appleX] and [SceneMetrics.appleY] rather
/// than by a widget animation, so its position at any moment is a pure
/// function of the timeline — the same value the narration and the physics
/// notes are derived from.
class FallingApple extends StatelessWidget {
  const FallingApple({required this.state, super.key});

  final SceneState state;

  static const double _boxRadius = SceneMetrics.appleRadius * 2.2;

  @override
  Widget build(BuildContext context) {
    final double x = SceneMetrics.appleX(state.appleDrop);
    final double y = SceneMetrics.appleY(state.appleDrop);

    return Stack(
      children: <Widget>[
        if (state.trailOpacity > 0.01)
          Positioned(
            left: x - 70,
            top: y - 320,
            width: 140,
            height: 320,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TrailPainter(opacity: state.trailOpacity),
              ),
            ),
          ),
        if (state.impactProgress > 0.001 && state.impactProgress < 0.999)
          Positioned(
            left: SceneMetrics.appleEnd.dx - 120,
            top: SceneMetrics.appleEnd.dy - 100,
            width: 240,
            height: 180,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DustPainter(progress: state.impactProgress),
              ),
            ),
          ),
        Positioned(
          left: x - _boxRadius,
          top: y - _boxRadius,
          width: _boxRadius * 2,
          height: _boxRadius * 2,
          child: Semantics(
            label: 'A red apple falling from the tree',
            child: CustomPaint(
              painter: _ApplePainter(
                scaleX: state.appleScaleX,
                scaleY: state.appleScaleY,
                stem: state.stemAttached,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplePainter extends CustomPainter {
  const _ApplePainter({
    required this.scaleX,
    required this.scaleY,
    required this.stem,
  });

  final double scaleX;
  final double scaleY;
  final bool stem;

  @override
  void paint(Canvas canvas, Size size) {
    // Squash happens around the contact point, so the anchor sits at the base
    // of the fruit rather than at its centre.
    final Offset centre = Offset(
      size.width / 2,
      size.height / 2 + SceneMetrics.appleRadius * (1 - scaleY),
    );
    drawApple(
      canvas,
      centre,
      SceneMetrics.appleRadius,
      scaleX: scaleX,
      scaleY: scaleY,
      stem: stem,
    );
  }

  @override
  bool shouldRepaint(_ApplePainter oldDelegate) =>
      oldDelegate.scaleX != scaleX ||
      oldDelegate.scaleY != scaleY ||
      oldDelegate.stem != stem;
}

class _TrailPainter extends CustomPainter {
  const _TrailPainter({required this.opacity});

  final double opacity;

  static const List<double> _offsets = <double>[-46, -18, 14, 44];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < _offsets.length; i++) {
      final double x = size.width / 2 + _offsets[i];
      final double length = size.height * (i.isEven ? 0.62 : 0.44);
      paint
        ..color = Palette.trail.withValues(alpha: opacity * 0.55)
        ..strokeWidth = i.isEven ? 6 : 4;
      canvas.drawLine(
        Offset(x, size.height - length),
        Offset(x, size.height - 14),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _DustPainter extends CustomPainter {
  const _DustPainter({required this.progress});

  final double progress;

  // angle (radians), distance, radius — mostly lateral / upward for a head bonk
  static const List<List<double>> _motes = <List<double>>[
    <double>[3.6, 90, 11],
    <double>[3.2, 118, 9],
    <double>[2.9, 86, 7],
    <double>[5.9, 100, 10],
    <double>[6.3, 120, 8],
    <double>[5.6, 78, 6],
    <double>[4.5, 52, 8],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double eased = Curves.easeOutCubic.transform(progress);
    final double fade = (1.0 - progress).clamp(0.0, 1.0);
    // Impact is on a head, not the grass: puff outward and slightly upward.
    final Offset origin = Offset(size.width / 2, size.height * 0.55);

    final Paint paint = Paint()
      ..color = Palette.dust.withValues(alpha: 0.7 * fade);

    for (final List<double> m in _motes) {
      final double d = m[1] * eased;
      final Offset p = origin +
          Offset(math.cos(m[0]) * d, math.sin(m[0]) * d * 0.35 - 28 * eased);
      canvas.drawCircle(p, m[2] * (0.4 + 0.6 * fade), paint);
    }

    // Soft radial shock around the crown — not a ground splash.
    canvas.drawCircle(
      origin,
      28 + 70 * eased,
      Paint()
        ..color = Palette.spark.withValues(alpha: 0.35 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_DustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
