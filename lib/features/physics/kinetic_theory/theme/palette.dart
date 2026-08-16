import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Instrument-lab palette for the kinetic-theory worksheet.
///
/// Cool lilac paper and a single violet accent — denser, sharper corners than
/// Cloud Formation's misty sky chrome or Heat and Temperature's warm dual-tone
/// thermal UI.
class Palette {
  const Palette._();

  static const paper = Color(0xFFF3F0F8);
  static const surface = Color(0xFFFAF8FD);
  static const passageTint = Color(0xFFECE8F4);

  static const ink = Color(0xFF221F2A);
  static const inkSoft = Color(0xFF5C5668);
  static const hairline = Color(0xFFD4CFE0);

  static const slate = AppColors.violet;
  static const slateTint = AppColors.violetSoft;

  static const updraft = slate;
  static const updraftTint = slateTint;

  static const correct = Color(0xFF2F7A52);
  static const correctTint = Color(0xFFE4F1E9);
  static const wrong = Color(0xFFB03A2E);
  static const wrongTint = Color(0xFFFAE7E4);
}

class Sizes {
  const Sizes._();

  static const maxContentWidth = 720.0;
  static const gutter = 18.0;
  static const cardRadius = 12.0;
}
