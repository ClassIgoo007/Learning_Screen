import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Newton, seated against the trunk with his book.
///
/// [surprise] drives the whole reaction: the head lifts, the eyes widen, the
/// brows rise, the smile opens and an exclamation mark pops in. One parameter
/// keeps the pose coherent instead of animating five things independently.
class NewtonFigure extends StatelessWidget {
  const NewtonFigure({required this.surprise, super.key});

  final double surprise;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Isaac Newton sitting under an apple tree, reading',
      child: CustomPaint(
        painter: _NewtonPainter(surprise: surprise.clamp(0.0, 1.0)),
        isComplex: true,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NewtonPainter extends CustomPainter {
  const _NewtonPainter({required this.surprise});

  final double surprise;

  /// Local design box for the figure.
  static const Size _design = Size(660, 580);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw in design coordinates whatever the widget size is.
    canvas.save();
    canvas.scale(size.width / _design.width, size.height / _design.height);

    _paintFarLeg(canvas);
    _paintNearLeg(canvas);
    _paintCoat(canvas);
    _paintBookArm(canvas);
    _paintCravat(canvas);
    _paintHead(canvas);
    _paintChinArm(canvas);
    if (surprise > 0.02) {
      _paintExclamation(canvas);
    }

    canvas.restore();
  }

  // --- Legs ------------------------------------------------------------

  void _paintFarLeg(Canvas canvas) {
    final Paint cloth = Paint()
      ..color = Palette.breeches
      ..style = PaintingStyle.stroke
      ..strokeWidth = 74
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(392, 404)
        ..quadraticBezierTo(300, 452, 236, 462),
      cloth,
    );

    _paintStockingAndShoe(
      canvas,
      from: const Offset(236, 462),
      to: const Offset(112, 486),
      shoeAt: const Offset(74, 496),
      shoeAngle: -0.10,
      shade: 0.20,
    );
  }

  void _paintNearLeg(Canvas canvas) {
    final Paint cloth = Paint()
      ..color = Palette.breeches
      ..style = PaintingStyle.stroke
      ..strokeWidth = 82
      ..strokeCap = StrokeCap.round;
    // Thigh up to the raised knee, then the shin back down.
    canvas.drawPath(
      Path()
        ..moveTo(400, 396)
        ..quadraticBezierTo(320, 336, 258, 344),
      cloth,
    );
    canvas.drawPath(
      Path()
        ..moveTo(258, 344)
        ..quadraticBezierTo(232, 404, 224, 430),
      cloth,
    );

    _paintStockingAndShoe(
      canvas,
      from: const Offset(224, 432),
      to: const Offset(196, 520),
      shoeAt: const Offset(176, 534),
      shoeAngle: 0.18,
      shade: 0.0,
    );
  }

  void _paintStockingAndShoe(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required Offset shoeAt,
    required double shoeAngle,
    required double shade,
  }) {
    canvas.drawPath(
      Path()
        ..moveTo(from.dx, from.dy)
        ..lineTo(to.dx, to.dy),
      Paint()
        ..color = Color.lerp(Palette.stocking, Palette.skinShade, shade)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 46
        ..strokeCap = StrokeCap.round,
    );

    canvas.save();
    canvas.translate(shoeAt.dx, shoeAt.dy);
    canvas.rotate(shoeAngle);
    final Rect shoe = Rect.fromCenter(
      center: Offset.zero,
      width: 116,
      height: 52,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        shoe,
        topLeft: const Radius.circular(26),
        bottomLeft: const Radius.circular(26),
        topRight: const Radius.circular(10),
        bottomRight: const Radius.circular(10),
      ),
      Paint()..color = Color.lerp(Palette.shoe, Palette.shoeDark, shade)!,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(4, -6), width: 26, height: 20),
        const Radius.circular(4),
      ),
      Paint()..color = Palette.buckle,
    );
    canvas.restore();
  }

  // --- Body ------------------------------------------------------------

  void _paintCoat(Canvas canvas) {
    final Path coat = Path()
      ..moveTo(352, 214)
      ..cubicTo(316, 268, 306, 352, 318, 434)
      ..cubicTo(330, 480, 372, 496, 448, 492)
      ..cubicTo(506, 488, 528, 452, 522, 386)
      ..cubicTo(516, 300, 498, 240, 464, 206)
      ..close();
    canvas.drawPath(coat, Paint()..color = Palette.coat);

    // Shaded back and the coat skirt behind the hip.
    canvas.save();
    canvas.clipPath(coat);
    canvas.drawPath(
      Path()
        ..moveTo(470, 190)
        ..cubicTo(506, 260, 524, 380, 520, 500)
        ..lineTo(560, 500)
        ..lineTo(560, 190)
        ..close(),
      Paint()..color = Palette.coatDark.withValues(alpha: 0.6),
    );
    canvas.restore();

    // Lapel.
    canvas.drawPath(
      Path()
        ..moveTo(372, 226)
        ..quadraticBezierTo(392, 320, 386, 404)
        ..quadraticBezierTo(410, 330, 404, 224)
        ..close(),
      Paint()..color = Palette.coatDark.withValues(alpha: 0.5),
    );
  }

  void _paintBookArm(Canvas canvas) {
    // Sleeve reaching down to the hand that holds the book.
    canvas.drawPath(
      Path()
        ..moveTo(360, 244)
        ..quadraticBezierTo(316, 300, 292, 344),
      Paint()
        ..color = Palette.coat
        ..style = PaintingStyle.stroke
        ..strokeWidth = 62
        ..strokeCap = StrokeCap.round,
    );
    // Cuff.
    canvas.drawCircle(
      const Offset(292, 344),
      33,
      Paint()..color = Palette.stocking,
    );

    // Open book, tilted towards him.
    canvas.save();
    canvas.translate(228, 336);
    canvas.rotate(-0.22);

    canvas.drawPath(
      Path()
        ..moveTo(-96, -66)
        ..quadraticBezierTo(-48, -84, 0, -62)
        ..quadraticBezierTo(48, -84, 96, -66)
        ..lineTo(96, 58)
        ..quadraticBezierTo(48, 40, 0, 62)
        ..quadraticBezierTo(-48, 40, -96, 58)
        ..close(),
      Paint()..color = Palette.bookPage,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -62)
        ..lineTo(0, 62)
        ..lineTo(104, 74)
        ..lineTo(104, -54)
        ..close(),
      Paint()..color = Palette.book,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 62)
        ..lineTo(104, 74)
        ..lineTo(104, 88)
        ..lineTo(0, 76)
        ..close(),
      Paint()..color = Palette.bookDark,
    );

    // Hand over the spine.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(62, 44), width: 66, height: 46),
      Paint()..color = Palette.skin,
    );
    canvas.restore();
  }

  void _paintCravat(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(378, 176)
        ..quadraticBezierTo(360, 246, 372, 300)
        ..quadraticBezierTo(402, 316, 428, 296)
        ..quadraticBezierTo(438, 236, 428, 176)
        ..close(),
      Paint()..color = Palette.stocking,
    );
  }

  // --- Head ------------------------------------------------------------

  void _paintHead(Canvas canvas) {
    canvas.save();
    // Looking up towards the tree as the surprise builds.
    const Offset pivot = Offset(398, 200);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(-0.11 * surprise);
    canvas.translate(-pivot.dx, -pivot.dy);

    final Paint hair = Paint()..color = Palette.hair;
    final Paint hairDark = Paint()..color = Palette.hairDark;

    // Wig: mass behind the head plus shoulder-length curls.
    canvas.drawCircle(const Offset(398, 108), 82, hairDark);
    canvas.drawCircle(const Offset(322, 168), 48, hairDark);
    canvas.drawCircle(const Offset(474, 168), 48, hairDark);
    canvas.drawCircle(const Offset(318, 214), 40, hairDark);
    canvas.drawCircle(const Offset(478, 214), 40, hairDark);
    canvas.drawCircle(const Offset(398, 104), 78, hair);
    canvas.drawCircle(const Offset(326, 162), 44, hair);
    canvas.drawCircle(const Offset(470, 162), 44, hair);

    // Face.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(398, 128), width: 112, height: 128),
      Paint()..color = Palette.skin,
    );

    // Fringe over the forehead.
    canvas.drawPath(
      Path()
        ..moveTo(340, 118)
        ..cubicTo(346, 50, 452, 50, 458, 116)
        ..cubicTo(438, 90, 420, 98, 398, 94)
        ..cubicTo(372, 90, 356, 88, 340, 118)
        ..close(),
      hair,
    );

    _paintFace(canvas);
    canvas.restore();
  }

  void _paintFace(Canvas canvas) {
    final double s = surprise;
    final Paint ink = Paint()..color = Palette.ink;

    // Eyes: sclera widens vertically with the surprise.
    for (final double x in <double>[374, 420]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, 128),
          width: 24 + 4 * s,
          height: 22 + 14 * s,
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(Offset(x + 2, 130 - 2 * s), 8 + 2 * s, ink);
      canvas.drawCircle(
        Offset(x + 5, 126 - 2 * s),
        3,
        Paint()..color = Colors.white,
      );
    }

    // Brows lift as he looks up.
    final Paint brow = Paint()
      ..color = Palette.hairDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final double browY = 104 - 12 * s;
    canvas.drawPath(
      Path()
        ..moveTo(358, browY + 6)
        ..quadraticBezierTo(374, browY - 8 - 4 * s, 390, browY + 4),
      brow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(408, browY + 4)
        ..quadraticBezierTo(424, browY - 8 - 4 * s, 440, browY + 6),
      brow,
    );

    // Nose.
    canvas.drawPath(
      Path()
        ..moveTo(400, 142)
        ..quadraticBezierTo(410, 156, 398, 160),
      Paint()
        ..color = Palette.skinShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Mouth: a calm smile that opens into an "oh".
    if (s < 0.98) {
      canvas.drawPath(
        Path()
          ..moveTo(376, 174)
          ..quadraticBezierTo(398, 190, 420, 172),
        Paint()
          ..color = Palette.ink.withValues(alpha: 1.0 - s)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
    if (s > 0.02) {
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(398, 180),
          width: 26 * s,
          height: 32 * s,
        ),
        Paint()..color = Palette.ink.withValues(alpha: s),
      );
    }

    // Cheek colour warms up with the reaction.
    final Paint blush = Paint()
      ..color = Palette.appleRed.withValues(alpha: 0.10 + 0.14 * s);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(352, 156), width: 30, height: 18),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(444, 156), width: 30, height: 18),
      blush,
    );
  }

  void _paintChinArm(Canvas canvas) {
    // Forearm coming up to rest the hand under the chin.
    canvas.drawPath(
      Path()
        ..moveTo(486, 336)
        ..quadraticBezierTo(492, 262, 452, 214),
      Paint()
        ..color = Palette.coat
        ..style = PaintingStyle.stroke
        ..strokeWidth = 58
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      const Offset(452, 212),
      30,
      Paint()..color = Palette.stocking,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(438, 186), width: 54, height: 46),
      Paint()..color = Palette.skin,
    );
  }

  void _paintExclamation(Canvas canvas) {
    final double s = Curves.elasticOut.transform(surprise.clamp(0.0, 1.0));
    canvas.save();
    canvas.translate(276, 96);
    canvas.scale(s.clamp(0.0, 1.4));
    canvas.rotate(-0.18);

    final Paint fill = Paint()..color = Palette.spark;
    final Paint outline = Paint()
      ..color = Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round;

    final Path bar = Path()
      ..moveTo(-12, -46)
      ..lineTo(12, -46)
      ..lineTo(7, 12)
      ..lineTo(-7, 12)
      ..close();
    canvas.drawPath(bar, fill);
    canvas.drawPath(bar, outline);
    canvas.drawCircle(const Offset(0, 32), 11, fill);
    canvas.drawCircle(const Offset(0, 32), 11, outline);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_NewtonPainter oldDelegate) =>
      oldDelegate.surprise != surprise;
}
