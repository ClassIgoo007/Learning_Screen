import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Every colour used by the worksheet, in one place.
///
/// Warm paper with a golden-yellow accent (`AppColors.yellow`) running through
/// the interface — tab indicator, buttons, watch-beat links, question
/// numbering — deliberately distinct from Kinetic Theory's violet and Cloud
/// Formation's slate-blue, so the three worksheets stay in the same family
/// without reading as the same lesson.
///
/// The animation figures and the Tables tab additionally use a dedicated
/// warm/cool pair, [hot] and [cold], for the two ends of the temperature
/// scale this lesson is actually about (the compression chamber vs. the
/// expansion chamber, the plasma jet vs. liquefied gases). Rather than invent
/// new semantic colours for that, both are pulled from tokens the app already
/// has — `AppColors.red`/`AppColors.blue` — reused here for a diagram-tinting
/// role distinct from their usual brand/semantic one.
class Palette {
  const Palette._();

  static const paper = Color(0xFFFBF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const passageTint = Color(0xFFEFF3F7);

  static const ink = Color(0xFF23282D);
  static const inkSoft = Color(0xFF5B6670);
  static const hairline = Color(0xFFDCD8CF);

  static const slate = AppColors.yellow;
  static const slateTint = AppColors.yellowSoft;

  static const accent = slate;
  static const accentTint = slateTint;

  /// The two ends of the temperature scale this lesson is about.
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

  /// Content never grows wider than this, so the worksheet keeps a readable
  /// measure on tablets and desktop while filling a phone edge to edge.
  static const maxContentWidth = 720.0;
  static const gutter = 20.0;
  static const cardRadius = 14.0;
}
