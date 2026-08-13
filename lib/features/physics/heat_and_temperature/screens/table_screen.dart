import 'package:flutter/material.dart';

import '../data/reference_data.dart';
import '../models/reference_table.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// The reference tab. Table 4-3 gives the liquefying and freezing points of
/// several common gases; Table 4-2, behind the same control, gives the melting
/// and boiling points of metals. Each row carries a bar showing where the two
/// readings fall on a common scale, so the span between them can be seen as
/// well as read.
class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  bool _gases = true;
  bool _sorted = false;

  ReferenceTable get _table => _gases ? kGasTable : kMetalTable;

  List<SubstanceReading> get _rows {
    final rows = List<SubstanceReading>.of(_table.rows);
    if (_sorted) rows.sort((a, b) => a.lower.compareTo(b.lower));
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final table = _table;
    final accent = _gases ? Palette.cold : Palette.hot;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Sizes.gutter, 16, Sizes.gutter, 28),
      children: [
        ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedPicker(
                left: 'Gases · 4-3',
                right: 'Metals · 4-2',
                leftSelected: _gases,
                onLeft: () => setState(() => _gases = true),
                onRight: () => setState(() => _gases = false),
              ),
              const SizedBox(height: 18),
              Text(
                '${table.number} · ${table.title}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Palette.ink,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              _TableCard(
                table: table,
                rows: _rows,
                accent: accent,
                sorted: _sorted,
                onToggleSort: () => setState(() => _sorted = !_sorted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: Palette.slateTint,
                  borderRadius: BorderRadius.circular(Sizes.cardRadius),
                ),
                child: Text(
                  table.note,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.6,
                    color: Palette.ink,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'The bar on each row spans the two readings on a common scale '
                'from ${table.axisMin.round()}°C to ${table.axisMax.round()}°C.',
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Palette.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.rows,
    required this.accent,
    required this.sorted,
    required this.onToggleSort,
  });

  final ReferenceTable table;
  final List<SubstanceReading> rows;
  final Color accent;
  final bool sorted;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        border: Border.all(color: Palette.hairline),
      ),
      child: Column(
        children: [
          _HeaderRow(
            table: table,
            sorted: sorted,
            onToggleSort: onToggleSort,
          ),
          for (var i = 0; i < rows.length; i++)
            _DataRow(
              reading: rows[i],
              table: table,
              accent: accent,
              last: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.table,
    required this.sorted,
    required this.onToggleSort,
  });

  final ReferenceTable table;
  final bool sorted;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Palette.inkSoft,
      height: 1.3,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Palette.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            flex: 32,
            child: Text('Substance', style: style),
          ),
          Expanded(
            flex: 27,
            child: Text(table.firstColumn, style: style,
                textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 27,
            child: Text(table.secondColumn, style: style,
                textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: onToggleSort,
              visualDensity: VisualDensity.compact,
              tooltip: sorted ? 'Table order' : 'Sort by temperature',
              icon: Icon(
                sorted ? Icons.sort : Icons.sort_outlined,
                size: 18,
                color: sorted ? Palette.slate : Palette.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.reading,
    required this.table,
    required this.accent,
    required this.last,
  });

  final SubstanceReading reading;
  final ReferenceTable table;
  final Color accent;
  final bool last;

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(
      fontSize: 14.5,
      color: Palette.ink,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Semantics(
      label: '${reading.substance}, ${table.firstColumn} '
          '${reading.first} degrees, ${table.secondColumn} '
          '${reading.second} degrees',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: Palette.hairline, width: 0.6)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 32,
                  child: Text(
                    reading.substance,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Palette.ink,
                    ),
                  ),
                ),
                Expanded(
                  flex: 27,
                  child: Text('${reading.first}', style: valueStyle,
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 27,
                  child: Text('${reading.second}', style: valueStyle,
                      textAlign: TextAlign.right),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            _SpanBar(reading: reading, table: table, accent: accent),
          ],
        ),
      ),
    );
  }
}

/// A track showing where this substance's two readings fall on the table's
/// common scale, and the span between them.
class _SpanBar extends StatelessWidget {
  const _SpanBar({
    required this.reading,
    required this.table,
    required this.accent,
  });

  final SubstanceReading reading;
  final ReferenceTable table;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final a = table.fractionOf(reading.first) * width;
        final b = table.fractionOf(reading.second) * width;
        final left = a < b ? a : b;
        final right = a < b ? b : a;

        return SizedBox(
          height: 10,
          child: Stack(
            children: [
              Container(
                height: 4,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: Palette.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Positioned(
                left: left,
                width: (right - left).clamp(3.0, width),
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              for (final x in [a, b])
                Positioned(
                  left: (x - 4).clamp(0.0, width - 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
