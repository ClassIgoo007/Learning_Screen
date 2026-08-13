import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Every colour used by the worksheet, in one place.
///
/// Warm paper with a single violet accent (`AppColors.violet`, the app's
/// shared lesson-accent token) running through the molecules, the gauge, the
/// balls, the impacts and every interactive control — deliberately one
/// colour rather than Cloud Formation's blue-and-amber pairing, so the two
/// worksheets stay in the same family without reading as the same lesson.
///
/// [slate]/[slateTint] and [updraft]/[updraftTint] are kept as separate
/// names — rather than renamed throughout every widget and painter that
/// reference them — but now resolve to the same violet accent, so the whole
/// lesson shares one identity even though the call sites still read like
/// two roles (interface vs. diagram highlight).
class Palette {
  const Palette._();

  static const paper = Color(0xFFFBF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const passageTint = Color(0xFFEFF3F7);

  static const ink = Color(0xFF23282D);
  static const inkSoft = Color(0xFF5B6670);
  static const hairline = Color(0xFFDCD8CF);

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

  /// Content never grows wider than this, so the worksheet keeps a readable
  /// measure on tablets and desktop while filling a phone edge to edge.
  static const maxContentWidth = 720.0;
  static const gutter = 20.0;
  static const cardRadius = 14.0;
}
