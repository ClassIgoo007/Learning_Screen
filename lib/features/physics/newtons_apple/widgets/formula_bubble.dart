import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// The thought bubble carrying F = G·m₁m₂/r².
///
/// The equation is real text rather than a painted path, so it stays crisp at
/// any zoom level and is readable by screen readers and by text selection.
class FormulaBubble extends StatelessWidget {
  const FormulaBubble({
    required this.reveal,
    required this.formulaReveal,
    super.key,
  });

  /// Bubble entrance, 0..1.
  final double reveal;

  /// Staggered entrance of the four parts of the equation, 0..1.
  final double formulaReveal;

  static const String _spokenLabel =
      'F equals big G times m one m two, divided by r squared: the law of '
      'universal gravitation.';

  double _part(int index) =>
      ((formulaReveal * 4.0) - index).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    if (reveal <= 0.001) {
      return const SizedBox.shrink();
    }

    final double scale = Curves.elasticOut.transform(reveal.clamp(0.0, 1.0));
    final double opacity = Curves.easeOut.transform(
      (reveal * 2.2).clamp(0.0, 1.0),
    );

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale.clamp(0.0, 1.12),
          alignment: Alignment.bottomRight,
          child: Semantics(
            label: _spokenLabel,
            excludeSemantics: true,
            child: CustomPaint(
              painter: const _BubblePainter(),
              child: Align(
                alignment: const Alignment(0, -0.34),
                child: _Equation(
                  fOpacity: _part(0),
                  gOpacity: _part(1),
                  numeratorOpacity: _part(2),
                  denominatorOpacity: _part(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Equation extends StatelessWidget {
  const _Equation({
    required this.fOpacity,
    required this.gOpacity,
    required this.numeratorOpacity,
    required this.denominatorOpacity,
  });

  final double fOpacity;
  final double gOpacity;
  final double numeratorOpacity;
  final double denominatorOpacity;

  static const TextStyle _base = TextStyle(
    color: Palette.ink,
    fontSize: 64,
    fontWeight: FontWeight.w900,
    height: 1.05,
    letterSpacing: 1,
  );

  static const TextStyle _sub = TextStyle(
    color: Palette.ink,
    fontSize: 34,
    fontWeight: FontWeight.w900,
  );

  Widget _term(String base, String subscript) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(base, style: _base),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(subscript, style: _sub),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Opacity(opacity: fOpacity, child: const Text('F', style: _base)),
        const SizedBox(width: 14),
        Opacity(opacity: gOpacity, child: const Text('= G', style: _base)),
        const SizedBox(width: 18),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Opacity(
              opacity: numeratorOpacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _term('m', '1'),
                  const SizedBox(width: 10),
                  _term('m', '2'),
                ],
              ),
            ),
            Opacity(
              opacity: denominatorOpacity,
              child: Container(
                width: 180,
                height: 8,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Palette.ink,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            Opacity(
              opacity: denominatorOpacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('r', style: _base),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('2', style: _sub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect body = Rect.fromLTWH(0, 0, size.width, size.height * 0.72);

    final Path bubble = Path()..addOval(body);

    // Tail pointing down-right towards Newton.
    final Path tail = Path()
      ..moveTo(size.width * 0.60, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.74,
        size.height * 0.86,
        size.width * 0.86,
        size.height * 0.99,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.94,
        size.width * 0.50,
        size.height * 0.70,
      )
      ..close();

    final Path shape = Path.combine(PathOperation.union, bubble, tail);

    canvas.drawPath(
      shape,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(shape, Paint()..color = Palette.bubble);
    canvas.drawPath(
      shape,
      Paint()
        ..color = Palette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;
}
