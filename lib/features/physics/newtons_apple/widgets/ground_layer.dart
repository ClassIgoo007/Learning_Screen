import 'package:flutter/material.dart';

import '../painting/apple_shape.dart';
import '../theme/palette.dart';

/// Grass, wild flowers and the apples that fell before this one.
class GroundLayer extends StatelessWidget {
  const GroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _GroundPainter(),
        isComplex: true,
        willChange: false,
        child: SizedBox.expand(),
      ),
    );
  }
}

class _GroundPainter extends CustomPainter {
  const _GroundPainter();

  // Apples already on the grass: x, y, radius, rotation.
  static const List<List<double>> _fallenApples = <List<double>>[
    <double>[120, 1252, 38, -0.4],
    <double>[352, 1204, 30, 0.35],
    <double>[430, 1274, 36, 0.2],
    <double>[610, 1268, 34, -0.25],
    <double>[880, 1198, 36, 0.45],
    <double>[956, 1266, 32, -0.15],
    <double>[742, 1216, 30, 0.6],
  ];

  static const List<List<double>> _daisies = <List<double>>[
    <double>[190, 1290],
    <double>[520, 1224],
    <double>[820, 1284],
    <double>[366, 1188],
  ];

  static const List<List<double>> _tufts = <List<double>>[
    <double>[70, 1196],
    <double>[300, 1226],
    <double>[560, 1176],
    <double>[900, 1150],
    <double>[680, 1290],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Back hill.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.855)
        ..quadraticBezierTo(w * 0.28, h * 0.800, w * 0.56, h * 0.833)
        ..quadraticBezierTo(w * 0.82, h * 0.862, w, h * 0.820)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Palette.grassBack,
    );

    // Front hill.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.905)
        ..quadraticBezierTo(w * 0.32, h * 0.868, w * 0.64, h * 0.900)
        ..quadraticBezierTo(w * 0.86, h * 0.922, w, h * 0.896)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Palette.grassFront,
    );

    for (final List<double> t in _tufts) {
      _drawTuft(canvas, Offset(t[0], t[1]));
    }

    for (final List<double> a in _fallenApples) {
      drawApple(canvas, Offset(a[0], a[1]), a[2], rotation: a[3]);
    }

    for (final List<double> d in _daisies) {
      _drawDaisy(canvas, Offset(d[0], d[1]));
    }
  }

  void _drawTuft(Canvas canvas, Offset c) {
    final Paint paint = Paint()
      ..color = Palette.grassBlade
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(c.dx - 14, c.dy - 22, c.dx - 24, c.dy - 34),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + 4, c.dy)
        ..quadraticBezierTo(c.dx + 6, c.dy - 26, c.dx + 4, c.dy - 44),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + 8, c.dy)
        ..quadraticBezierTo(c.dx + 24, c.dy - 20, c.dx + 34, c.dy - 30),
      paint,
    );
  }

  void _drawDaisy(Canvas canvas, Offset c) {
    final Paint petal = Paint()..color = Palette.daisy;
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * 1.2566);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0, -11),
          width: 9,
          height: 18,
        ),
        petal,
      );
      canvas.restore();
    }
    canvas.drawCircle(c, 6, Paint()..color = Palette.daisyHeart);
  }

  @override
  bool shouldRepaint(_GroundPainter oldDelegate) => false;
}
