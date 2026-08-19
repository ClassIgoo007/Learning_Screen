import 'package:flutter/material.dart';

import '../painting/apple_shape.dart';
import '../theme/palette.dart';

/// The tree is static, so it is painted once and cached behind a
/// [RepaintBoundary] instead of being rebuilt on every animation tick.
class AppleTree extends StatelessWidget {
  const AppleTree({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _AppleTreePainter(),
        isComplex: true,
        willChange: false,
        child: SizedBox.expand(),
      ),
    );
  }
}

class _AppleTreePainter extends CustomPainter {
  const _AppleTreePainter();

  // Canopy blobs: x, y, radius.
  static const List<List<double>> _canopyBack = <List<double>>[
    <double>[210, 250, 175],
    <double>[430, 170, 200],
    <double>[660, 200, 190],
    <double>[850, 300, 165],
    <double>[120, 400, 140],
    <double>[930, 430, 125],
    <double>[560, 350, 200],
    <double>[300, 420, 165],
    <double>[760, 430, 150],
  ];

  static const List<List<double>> _canopyFront = <List<double>>[
    <double>[330, 215, 128],
    <double>[560, 165, 132],
    <double>[770, 250, 120],
    <double>[180, 340, 108],
    <double>[450, 330, 128],
    <double>[680, 370, 112],
    <double>[880, 360, 96],
  ];

  // Apples resting in the canopy: x, y, radius.
  static const List<List<double>> _hangingApples = <List<double>>[
    <double>[188, 200, 34],
    <double>[790, 60, 36],
    <double>[404, 288, 32],
    <double>[742, 240, 30],
    <double>[158, 434, 32],
    <double>[930, 262, 28],
    <double>[598, 118, 30],
  ];

  static const List<List<double>> _leafSpecks = <List<double>>[
    <double>[268, 118, 16],
    <double>[520, 60, 14],
    <double>[640, 300, 15],
    <double>[860, 150, 13],
    <double>[110, 268, 14],
    <double>[420, 430, 13],
    <double>[900, 470, 12],
    <double>[300, 330, 12],
    <double>[700, 470, 14],
    <double>[210, 470, 11],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintTrunk(canvas);
    _paintCanopy(canvas);

    for (final List<double> a in _hangingApples) {
      drawApple(canvas, Offset(a[0], a[1]), a[2]);
    }
  }

  void _paintTrunk(Canvas canvas) {
    final Paint wood = Paint()..color = Palette.bark;

    final Path trunk = Path()
      ..moveTo(536, 1230)
      ..cubicTo(560, 1000, 586, 800, 606, 566)
      ..lineTo(714, 552)
      ..cubicTo(730, 790, 754, 1010, 782, 1230)
      ..close();
    canvas.drawPath(trunk, wood);

    // Bark shading down the right edge.
    canvas.save();
    canvas.clipPath(trunk);
    canvas.drawPath(
      Path()
        ..moveTo(700, 540)
        ..cubicTo(716, 800, 748, 1020, 790, 1240)
        ..lineTo(830, 1240)
        ..lineTo(830, 540)
        ..close(),
      Paint()..color = Palette.barkDark.withValues(alpha: 0.55),
    );
    canvas.restore();

    final Paint limb = Paint()
      ..color = Palette.bark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Upper fork.
    limb.strokeWidth = 46;
    canvas.drawPath(
      Path()
        ..moveTo(626, 590)
        ..quadraticBezierTo(560, 500, 470, 442),
      limb,
    );
    canvas.drawPath(
      Path()
        ..moveTo(700, 580)
        ..quadraticBezierTo(790, 512, 856, 462),
      limb,
    );

    // Low branch that carries the apple which is about to fall.
    // Tip curves toward SceneMetrics.appleStart (centred above Newton's head).
    limb.strokeWidth = 30;
    canvas.drawPath(
      Path()
        ..moveTo(614, 662)
        ..cubicTo(620, 600, 650, 550, 668, 520),
      limb,
    );
    limb.strokeWidth = 18;
    canvas.drawPath(
      Path()
        ..moveTo(580, 620)
        ..quadraticBezierTo(630, 560, 668, 510),
      limb,
    );
  }

  void _paintCanopy(Canvas canvas) {
    final Paint back = Paint()..color = Palette.canopyDark;
    for (final List<double> b in _canopyBack) {
      canvas.drawCircle(Offset(b[0], b[1]), b[2], back);
    }

    final Paint mid = Paint()..color = Palette.canopyMid;
    for (final List<double> b in _canopyFront) {
      canvas.drawCircle(Offset(b[0], b[1]), b[2], mid);
    }

    final Paint light = Paint()..color = Palette.canopyLight;
    canvas.drawCircle(const Offset(470, 200), 96, light);
    canvas.drawCircle(const Offset(250, 300), 70, light);
    canvas.drawCircle(const Offset(720, 300), 74, light);

    final Paint speck = Paint()..color = Palette.leafSpeck;
    for (final List<double> s in _leafSpecks) {
      _drawLeafSpeck(canvas, Offset(s[0], s[1]), s[2], speck);
    }
  }

  void _drawLeafSpeck(Canvas canvas, Offset c, double r, Paint paint) {
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * 1.5708);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -r * 0.8),
          width: r * 0.8,
          height: r * 1.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_AppleTreePainter oldDelegate) => false;
}
