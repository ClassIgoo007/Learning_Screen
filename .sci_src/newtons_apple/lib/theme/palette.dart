import 'package:flutter/material.dart';

/// Every colour used by the scene painters lives here so the illustration can
/// be re-skinned (night mode, print mode, high contrast) from one place.
abstract final class Palette {
  // Sky and clouds
  static const Color skyTop = Color(0xFF8FD3F4);
  static const Color skyBottom = Color(0xFFDFF3FC);
  static const Color cloud = Color(0xFFFFFFFF);

  // Foliage
  static const Color canopyDark = Color(0xFF6BA337);
  static const Color canopyMid = Color(0xFF80BC44);
  static const Color canopyLight = Color(0xFF97CE55);
  static const Color leafSpeck = Color(0xFFB9DE7C);

  // Wood
  static const Color bark = Color(0xFF8C5C34);
  static const Color barkDark = Color(0xFF6E4524);

  // Ground
  static const Color grassBack = Color(0xFF9BD250);
  static const Color grassFront = Color(0xFF7FC03C);
  static const Color grassBlade = Color(0xFF6BAB2E);
  static const Color daisy = Color(0xFFFFFFFF);
  static const Color daisyHeart = Color(0xFFF6C445);

  // Apple
  static const Color appleRed = Color(0xFFE23B2E);
  static const Color appleShade = Color(0xFFBB2A20);
  static const Color appleLeaf = Color(0xFF4E9A2F);
  static const Color stem = Color(0xFF7A4A22);

  // Newton
  static const Color coat = Color(0xFF6E7F96);
  static const Color coatDark = Color(0xFF57687E);
  static const Color breeches = Color(0xFF2D3853);
  static const Color stocking = Color(0xFFF6F2E8);
  static const Color shoe = Color(0xFF7A4A2A);
  static const Color shoeDark = Color(0xFF5E3820);
  static const Color buckle = Color(0xFFE8C24A);
  static const Color skin = Color(0xFFF7D0A9);
  static const Color skinShade = Color(0xFFE4B98D);
  static const Color hair = Color(0xFFCBA46D);
  static const Color hairDark = Color(0xFFB08A55);
  static const Color book = Color(0xFFD1662B);
  static const Color bookDark = Color(0xFFB4531F);
  static const Color bookPage = Color(0xFFFDF6E7);

  // Effects and UI
  static const Color ink = Color(0xFF161D29);
  static const Color bubble = Color(0xFFFFFFFF);
  static const Color trail = Color(0xFF7E8DA0);
  static const Color dust = Color(0xFFD3B189);
  static const Color spark = Color(0xFFF6C445);

  static const Color uiSurface = Color(0xFF121823);
  static const Color uiSurfaceHigh = Color(0xFF1C2533);
  static const Color uiAccent = Color(0xFFE23B2E);
  static const Color uiOnSurface = Color(0xFFE8EDF5);
  static const Color uiMuted = Color(0xFF93A2B6);
}
