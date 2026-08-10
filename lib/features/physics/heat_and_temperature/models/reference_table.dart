import 'package:flutter/foundation.dart';

/// One row of a reference table: a substance and its two characteristic
/// temperatures, in degrees Celsius.
@immutable
class SubstanceReading {
  const SubstanceReading({
    required this.substance,
    required this.first,
    required this.second,
  });

  final String substance;

  /// Liquefying point for a gas, melting point for a metal.
  final int first;

  /// Freezing point for a gas, boiling point for a metal.
  final int second;

  /// The reading used when the rows are sorted or plotted.
  int get lower => first < second ? first : second;

  factory SubstanceReading.fromJson(Map<String, dynamic> json) =>
      SubstanceReading(
        substance: json['substance'] as String,
        first: json['first'] as int,
        second: json['second'] as int,
      );

  Map<String, dynamic> toJson() =>
      {'substance': substance, 'first': first, 'second': second};
}

/// A whole table, with the wording of its own column headings.
@immutable
class ReferenceTable {
  const ReferenceTable({
    required this.number,
    required this.title,
    required this.firstColumn,
    required this.secondColumn,
    required this.rows,
    required this.axisMin,
    required this.axisMax,
    required this.note,
  });

  final String number;
  final String title;
  final String firstColumn;
  final String secondColumn;
  final List<SubstanceReading> rows;

  /// Bounds of the bar drawn beside each row, in degrees Celsius.
  final double axisMin;
  final double axisMax;

  final String note;

  /// Where a reading sits between [axisMin] and [axisMax], 0..1.
  double fractionOf(num celsius) =>
      ((celsius - axisMin) / (axisMax - axisMin)).clamp(0.0, 1.0);
}
