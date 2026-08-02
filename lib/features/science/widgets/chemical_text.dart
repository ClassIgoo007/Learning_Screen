import 'package:flutter/material.dart';

/// Renders educational text with chemical formulas typeset properly:
/// digits after element symbols become subscripts (C6H12O6 → C₆H₁₂O₆),
/// and trailing + / - charges become superscripts (NADP+ → NADP⁺).
class ChemicalText extends StatelessWidget {
  const ChemicalText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.selectable = false,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final span = TextSpan(style: base, children: chemicalSpans(text, base));
    if (selectable) {
      return SelectableText.rich(
        span,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    }
    return Text.rich(
      span,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Split [text] into spans with subscript digits / superscript charges.
List<InlineSpan> chemicalSpans(String text, TextStyle base) {
  if (text.isEmpty) return const [];

  final subStyle = base.copyWith(
    fontSize: (base.fontSize ?? 14) * 0.72,
    height: 1,
    fontFeatures: const [FontFeature.subscripts()],
  );
  final superStyle = base.copyWith(
    fontSize: (base.fontSize ?? 14) * 0.72,
    height: 1,
    fontFeatures: const [FontFeature.superscripts()],
  );

  final spans = <InlineSpan>[];
  final buf = StringBuffer();
  var afterSymbol = false;

  void flush() {
    if (buf.isEmpty) return;
    spans.add(TextSpan(text: buf.toString(), style: base));
    buf.clear();
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    final code = ch.codeUnitAt(0);

    // Already-encoded Unicode subscripts / superscripts — keep as-is but
    // style them so sizing matches ASCII conversions.
    if (_isUnicodeSubscript(code)) {
      flush();
      spans.add(TextSpan(text: ch, style: subStyle));
      afterSymbol = true;
      continue;
    }
    if (_isUnicodeSuperscript(code)) {
      flush();
      spans.add(TextSpan(text: ch, style: superStyle));
      afterSymbol = true;
      continue;
    }

    final isLetter = _isAsciiLetter(code);
    final isDigit = code >= 0x30 && code <= 0x39;

    if (isDigit && afterSymbol) {
      flush();
      spans.add(TextSpan(text: ch, style: subStyle));
      continue;
    }

    if ((ch == '+' || ch == '-') && afterSymbol) {
      // Charge at end of a formula token (NADP+, Fe3+, CO3-).
      final nextIsLetter = i + 1 < text.length &&
          _isAsciiLetter(text.codeUnitAt(i + 1));
      if (!nextIsLetter) {
        flush();
        spans.add(TextSpan(text: ch, style: superStyle));
        afterSymbol = false;
        continue;
      }
    }

    buf.write(ch);
    if (isLetter) {
      afterSymbol = true;
    } else if (!isDigit) {
      afterSymbol = false;
    }
  }
  flush();
  return spans;
}

bool _isAsciiLetter(int code) =>
    (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);

bool _isUnicodeSubscript(int code) =>
    code == 0x2080 || // ₀
    code == 0x2081 ||
    code == 0x2082 ||
    code == 0x2083 ||
    code == 0x2084 ||
    code == 0x2085 ||
    code == 0x2086 ||
    code == 0x2087 ||
    code == 0x2088 ||
    code == 0x2089;

bool _isUnicodeSuperscript(int code) =>
    code == 0x207A || // ⁺
    code == 0x207B || // ⁻
    code == 0x00B2 || // ²
    code == 0x00B3 || // ³
    code == 0x00B9; // ¹
