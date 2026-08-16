import 'package:flutter/painting.dart';

/// The scene is composed on a fixed "design canvas" and then scaled to fit the
/// available space with a [FittedBox]. Everything below is expressed in design
/// pixels, so the composition is identical on a phone, a tablet and a 4K TV.
abstract final class SceneMetrics {
  static const Size canvas = Size(1000, 1300);

  /// Newton's local drawing box inside the canvas.
  static const Rect newtonBox = Rect.fromLTWH(270, 700, 660, 580);

  /// Head centre inside [newtonBox] local design space (see newton_figure.dart).
  static const Offset _headLocal = Offset(398, 104);

  /// Approximate crown radius of the painted wig.
  static const double _crownRadius = 78;

  static const double appleRadius = 44;

  /// Canvas position of the top of Newton's wig.
  static Offset get crownTop {
    final Offset centre = Offset(
      newtonBox.left + _headLocal.dx,
      newtonBox.top + _headLocal.dy,
    );
    return Offset(centre.dx, centre.dy - _crownRadius);
  }

  /// Where the apple hangs before it lets go — high enough above Newton that
  /// the drop onto his head reads as a real fall, not a sideways slide.
  /// Sits under the mid-section of the low branch in apple_tree.dart.
  static const Offset appleStart = Offset(360, 520);

  /// Where the apple comes to rest: perched on Newton's crown (bottom of the
  /// fruit nestles a few pixels into the hair), never on the grass.
  static Offset get appleEnd {
    // Bottom of the apple ≈ crown top + slight sink into the wig.
    const double nestle = 10;
    return Offset(
      crownTop.dx,
      crownTop.dy - appleRadius + nestle,
    );
  }

  /// Speech-bubble box (the tail is drawn inside the lower part of the box).
  static const Rect bubbleBox = Rect.fromLTWH(170, 250, 520, 560);

  /// Point the bubble tail aims at — roughly Newton's temple.
  static const Offset bubbleTarget = Offset(668, 828);

  static double appleY(double drop) =>
      appleStart.dy + (appleEnd.dy - appleStart.dy) * drop;

  /// The apple travels sideways from the branch to Newton's head as it
  /// falls, using the same [drop] progress as [appleY] so the path traced is
  /// a straight line between the two points.
  static double appleX(double drop) =>
      appleStart.dx + (appleEnd.dx - appleStart.dx) * drop;
}
