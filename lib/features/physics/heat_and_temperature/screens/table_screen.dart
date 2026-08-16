import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
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
              const SizedBox(height: 16),
              Text(
                '${table.number} · ${table.title}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Palette.ink,
                  height: 1.25,
                  letterSpacing: -0.3,
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
              ElevatedCard(
                color: Palette.surface,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
    return ElevatedCard(
      color: Palette.surface,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
      fontWeight: FontWeight.w700,
      color: Palette.inkSoft,
      height: 1.3,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${table.firstColumn}  ·  ${table.secondColumn}',
              style: style,
            ),
          ),
          IconButton(
            onPressed: onToggleSort,
            visualDensity: VisualDensity.compact,
            tooltip: sorted ? 'Table order' : 'Sort by temperature',
            icon: Icon(
              sorted ? Icons.sort_rounded : Icons.sort_outlined,
              size: 20,
              color: sorted ? Palette.slate : Palette.inkSoft,
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
  });

  final SubstanceReading reading;
  final ReferenceTable table;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${reading.substance}, ${table.firstColumn} '
          '${reading.first} degrees, ${table.secondColumn} '
          '${reading.second} degrees',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reading.substance,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Palette.ink,
                    ),
                  ),
                ),
                _ValueChip(value: reading.first, accent: accent),
                const SizedBox(width: 6),
                _ValueChip(value: reading.second, accent: accent),
              ],
            ),
            const SizedBox(height: 10),
            _SpanBar(reading: reading, table: table, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.value, required this.accent});

  final num value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$value',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: accent,
          fontFeatures: const [FontFeature.tabularFigures()],
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
          height: 12,
          child: Stack(
            children: [
              Container(
                height: 6,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: Palette.surface,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Positioned(
                left: left,
                width: (right - left).clamp(4.0, width),
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              for (final x in [a, b])
                Positioned(
                  left: (x - 5).clamp(0.0, width - 10),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: accentGlow(accent, strength: 0.3),
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
