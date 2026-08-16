import 'package:flutter/material.dart';

/// Atmospheric mist palette for the cloud-formation worksheet.
///
/// Cool paper and slate cloud shadow, with amber updraft and rain-blue accents
/// — deliberately misty and sky-like so it does not read like Kinetic Theory's
/// violet lab panel or Heat and Temperature's warm thermal paper.
class Palette {
  const Palette._();

  static const paper = Color(0xFFEEF4FA);
  static const surface = Color(0xFFF7FBFF);
  static const passageTint = Color(0xFFE4EEF7);

  static const ink = Color(0xFF1E2A36);
  static const inkSoft = Color(0xFF5A6B7A);
  static const hairline = Color(0xFFC9D6E3);

  static const slate = Color(0xFF2F5D8C);
  static const slateTint = Color(0xFFD9E6F3);

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

  static const maxContentWidth = 720.0;
  static const gutter = 20.0;
  static const cardRadius = 26.0;
}
