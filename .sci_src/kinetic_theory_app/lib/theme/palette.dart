import 'package:flutter/material.dart';

/// Every colour used by the worksheet, in one place.
///
/// Warm paper, slate blue for the molecules and the interface, amber for the
/// impacts and the ping-pong balls.
class Palette {
  const Palette._();

  static const paper = Color(0xFFFBF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const passageTint = Color(0xFFEFF3F7);

  static const ink = Color(0xFF23282D);
  static const inkSoft = Color(0xFF5B6670);
  static const hairline = Color(0xFFDCD8CF);

  static const slate = Color(0xFF2F5D8C);
  static const slateTint = Color(0xFFE3ECF5);

  static const updraft = Color(0xFFC97A16);
  static const updraftTint = Color(0xFFFBEEDA);

  static const rain = Color(0xFF3B7FC4);

  static const correct = Color(0xFF2F7A52);
  static const correctTint = Color(0xFFE4F1E9);
  static const wrong = Color(0xFFB03A2E);
  static const wrongTint = Color(0xFFFAE7E4);
}

class Sizes {
  const Sizes._();

  /// Content never grows wider than this, so the worksheet keeps a readable
  /// measure on tablets and desktop while filling a phone edge to edge.
  static const maxContentWidth = 720.0;
  static const gutter = 20.0;
  static const cardRadius = 14.0;
}
