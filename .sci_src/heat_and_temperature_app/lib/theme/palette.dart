import 'package:flutter/material.dart';

/// Every colour used by the worksheet, in one place.
///
/// Warm paper and slate blue for the interface; red for the high-temperature
/// region and the plasma jet, blue for the low-temperature region and the
/// liquefied gases.
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

  static const accent = Color(0xFFC97A16);
  static const accentTint = Color(0xFFFBEEDA);

  /// The two ends of the temperature scale this lesson is about.
  static const hot = Color(0xFFC0492B);
  static const hotTint = Color(0xFFFAE8E3);
  static const cold = Color(0xFF2E7FA8);
  static const coldTint = Color(0xFFE2F0F7);

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
