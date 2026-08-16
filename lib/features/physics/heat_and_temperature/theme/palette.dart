import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Thermal dual-tone palette for Heat and Temperature.
///
/// Warm peach paper with a golden accent for chrome, plus dedicated [hot] and
/// [cold] ends for the temperature scale — distinct from Cloud Formation's
/// cool mist and Kinetic Theory's violet lab panel.
class Palette {
  const Palette._();

  static const paper = Color(0xFFFFF4EB);
  static const surface = Color(0xFFFFFBF7);
  static const passageTint = Color(0xFFFFEDE0);

  static const ink = Color(0xFF2A2420);
  static const inkSoft = Color(0xFF6B5E54);
  static const hairline = Color(0xFFE8D9CC);

  static const slate = AppColors.yellow;
  static const slateTint = AppColors.yellowSoft;

  static const accent = slate;
  static const accentTint = slateTint;

  static const hot = AppColors.red;
  static const hotTint = AppColors.redSoft;
  static const cold = AppColors.blue;
  static const coldTint = AppColors.blueSoft;

  static const correct = Color(0xFF2F7A52);
  static const correctTint = Color(0xFFE4F1E9);
  static const wrong = Color(0xFFB03A2E);
  static const wrongTint = Color(0xFFFAE7E4);
}

class Sizes {
  const Sizes._();

  static const maxContentWidth = 720.0;
  static const gutter = 20.0;
  static const cardRadius = 18.0;
}
