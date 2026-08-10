import 'package:flutter/material.dart';

import '../physics/venturi.dart';
import '../theme/app_theme.dart';

/// The diagram is always drawn on a light "paper" surface, in both themes:
/// a technical figure reads better on white, and it keeps the painter's
/// palette independent of the app theme.
const Color kFigurePaper = Color(0xFFFFFFFF);

/// Keeps line lengths readable on wide windows.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 900});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}

/// White card that hosts the figure, with a border that follows the theme.
class FigureCard extends StatelessWidget {
  const FigureCard({super.key, required this.child, this.padding = 12});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: kFigurePaper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// Rounded panel used for explainer and passage blocks.
class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    required this.child,
    this.background,
    this.border,
  });

  final Widget child;
  final Color? background;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background ?? context.scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border ?? context.scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// The lesson as a picture: each station's bar splits into static pressure
/// and pressure of motion. The split changes; the totals never do.
class PressureSplitBars extends StatelessWidget {
  const PressureSplitBars({super.key, required this.model});

  final VenturiModel model;

  static const double _maxHeight = 150;

  @override
  Widget build(BuildContext context) {
    final c = context.colours;
    final total = model.totalPressure;

    return Semantics(
      container: true,
      label: 'Pressure budget. In the wide sections '
          '${(model.widePressure / 1000).toStringAsFixed(1)} kilopascals is '
          'static pressure and '
          '${(model.wideDynamic / 1000).toStringAsFixed(1)} is motion. '
          'In the throat the split is '
          '${(model.throatPressure / 1000).toStringAsFixed(1)} static and '
          '${(model.throatDynamic / 1000).toStringAsFixed(1)} motion. Both '
          'add up to ${(total / 1000).toStringAsFixed(1)} kilopascals.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('p + ½ρv²  is the same at every station',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.scheme.primary)),
            const SizedBox(height: 4),
            Text(
              'Blue is the pressure pushing on the walls; orange is the '
              'pressure of motion. The throat trades one for the other.',
              style: TextStyle(
                  fontSize: 13, color: context.scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(context, 'Wide', model.widePressure, model.wideDynamic,
                    total),
                _bar(context, 'Narrow', model.throatPressure,
                    model.throatDynamic, total),
                _bar(context, 'Wide', model.widePressure, model.wideDynamic,
                    total),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _key(context.scheme.primary, 'static pressure p'),
                _key(c.motion, 'motion ½ρv²'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _key(Color colour, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 13, height: 13, color: colour),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12.5)),
        ],
      );

  Widget _bar(BuildContext context, String name, double staticP,
      double dynamicP, double total) {
    final c = context.colours;
    // A negative static pressure (cavitation) is shown as a red deficit
    // rather than silently clipped to nothing.
    final negative = staticP < 0;
    final staticH =
        (staticP.abs() / total * _maxHeight).clamp(0.0, _maxHeight).toDouble();
    final dynamicH =
        (dynamicP / total * _maxHeight).clamp(0.0, _maxHeight * 2).toDouble();
    final narrow = name == 'Narrow';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(total / 1000).toStringAsFixed(1)} kPa total',
                style: TextStyle(
                    fontSize: 11, color: context.scheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: dynamicH,
              decoration: BoxDecoration(
                color: c.motion,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              alignment: Alignment.center,
              child: dynamicH > 22
                  ? Text((dynamicP / 1000).toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: staticH,
              decoration: BoxDecoration(
                color: negative ? c.bad : context.scheme.primary,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
              alignment: Alignment.center,
              child: staticH > 22
                  ? Text((staticP / 1000).toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(height: 6),
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: narrow ? c.bad : c.ok)),
            if (negative)
              Text('below zero', style: TextStyle(fontSize: 11, color: c.bad)),
          ],
        ),
      ),
    );
  }
}

/// A labelled number shown under the figure.
class Readout extends StatelessWidget {
  const Readout({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.scheme.primary;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tint.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: context.scheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: tint)),
          ],
        ),
      ),
    );
  }
}
