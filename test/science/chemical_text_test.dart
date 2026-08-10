import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phonics_worksheets/features/science/widgets/chemical_text.dart';

void main() {
  test('subscripts digits in chemical formulas', () {
    const base = TextStyle(fontSize: 16);
    final spans = chemicalSpans('Glucose is C6H12O6 and CO2.', base);
    final texts = spans.map((s) => (s as TextSpan).text ?? '').join();
    expect(texts, 'Glucose is C6H12O6 and CO2.');

    // Digits after letters should use subscript styling.
    final subscripts = spans
        .whereType<TextSpan>()
        .where((s) =>
            s.style?.fontFeatures
                ?.any((f) => f.feature == 'subs') ==
            true)
        .map((s) => s.text)
        .join();
    expect(subscripts, contains('6'));
    expect(subscripts, contains('12'));
    expect(subscripts, contains('2'));
  });

  test('keeps ordinary numbers unsubscripted', () {
    const base = TextStyle(fontSize: 16);
    final spans = chemicalSpans('Humans have 46 chromosomes.', base);
    final subscripts = spans
        .whereType<TextSpan>()
        .where((s) =>
            s.style?.fontFeatures
                ?.any((f) => f.feature == 'subs') ==
            true)
        .toList();
    expect(subscripts, isEmpty);
  });
}
