import 'package:flutter/painting.dart';

/// The scene is composed on a fixed "design canvas" and then scaled to fit the
/// available space with a [FittedBox]. Everything below is expressed in design
/// pixels, so the composition is identical on a phone, a tablet and a 4K TV.
abstract final class SceneMetrics {
  static const Size canvas = Size(1000, 1300);

  /// Where the apple hangs before it lets go.
  static const Offset appleStart = Offset(232, 690);

  /// Where the apple comes to rest — on Newton's head, not the grass. Chosen
  /// to sit just above his eyes and fringe, nestled into the top of his wig.
  static const Offset appleEnd = Offset(668, 764);

  static const double appleRadius = 44;

  /// Newton's local drawing box inside the canvas.
  static const Rect newtonBox = Rect.fromLTWH(270, 700, 660, 580);

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
