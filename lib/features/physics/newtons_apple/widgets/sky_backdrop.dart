import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Static gradient sky with soft cumulus clouds.
class SkyBackdrop extends StatelessWidget {
  const SkyBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Palette.skyTop, Palette.skyBottom],
          stops: <double>[0.0, 0.82],
        ),
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CloudPainter(),
          isComplex: false,
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  static const List<_Cloud> _clouds = <_Cloud>[
    _Cloud(70, 150, 1.15),
    _Cloud(120, 470, 0.80),
    _Cloud(900, 620, 1.00),
    _Cloud(860, 990, 0.85),
    _Cloud(180, 1010, 0.70),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Palette.cloud.withValues(alpha: 0.92);
    for (final _Cloud cloud in _clouds) {
      canvas.save();
      canvas.translate(cloud.x, cloud.y);
      canvas.scale(cloud.scale);
      final Path path = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: 58))
        ..addOval(Rect.fromCircle(center: const Offset(64, 12), radius: 44))
        ..addOval(Rect.fromCircle(center: const Offset(-62, 16), radius: 40))
        ..addOval(Rect.fromCircle(center: const Offset(16, -34), radius: 40))
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(-92, 12, 96, 62),
            const Radius.circular(32),
          ),
        );
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) => false;
}

@immutable
class _Cloud {
  const _Cloud(this.x, this.y, this.scale);
  final double x;
  final double y;
  final double scale;
}
