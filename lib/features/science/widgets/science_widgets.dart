import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/science_content.dart';
import 'chemical_text.dart';

/// A diagram shown as a tappable card. Tapping opens a full-screen viewer with
/// pinch-to-zoom, because the labels in these figures are small on a phone.
class DiagramCard extends StatelessWidget {
  const DiagramCard({
    super.key,
    required this.asset,
    required this.label,
    this.accent = AppColors.blue,
    this.maxHeight = 320,
  });

  final String asset;
  final String label;
  final Color accent;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label. Double tap to open and zoom.',
      image: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openDiagram(context, asset, label),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Image.asset(
                    asset,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    cacheWidth: 1200,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in_rounded,
                            size: 16, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Tap to zoom',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen, pinch-zoomable view of a diagram.
Future<void> openDiagram(BuildContext context, String asset, String label) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _DiagramViewer(asset: asset, label: label),
    ),
  );
}

class _DiagramViewer extends StatelessWidget {
  const _DiagramViewer({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(label),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// A reading passage with its diagram, collapsible once read but always one
/// tap away while answering. Shown only for topics that have passage text.
class PassageCard extends StatefulWidget {
  const PassageCard({
    super.key,
    required this.activity,
    this.accent = AppColors.blue,
    this.initiallyOpen = true,
  });

  final ReadingActivity activity;
  final Color accent;
  final bool initiallyOpen;

  @override
  State<PassageCard> createState() => _PassageCardState();
}

class _PassageCardState extends State<PassageCard> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                Icon(Icons.article_rounded, size: 20, color: widget.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    a.passageTitle ?? 'Reading',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: AppColors.ink),
                  ),
                ),
                Text(_open ? 'Hide' : 'Read',
                    style: TextStyle(
                        color: widget.accent, fontWeight: FontWeight.w700)),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: widget.accent),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 12),
            DiagramCard(
              asset: a.diagram,
              label: a.diagramCaption,
              accent: widget.accent,
            ),
            const SizedBox(height: 6),
            Text(
              a.diagramCaption,
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 12),
            ChemicalText(
              a.passageText ?? '',
              selectable: true,
              style: const TextStyle(
                  fontSize: 15.5, height: 1.5, color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }
}

/// Collapsible reference strip of the key vocabulary.
class WordBankStrip extends StatefulWidget {
  const WordBankStrip({super.key, required this.words, this.accent = AppColors.blue});

  final List<String> words;
  final Color accent;

  @override
  State<WordBankStrip> createState() => _WordBankStripState();
}

class _WordBankStripState extends State<WordBankStrip> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 18, color: widget.accent),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Word bank',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: AppColors.ink)),
                ),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: widget.accent),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final word in widget.words)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: widget.accent.withValues(alpha: 0.35)),
                    ),
                    child: ChemicalText(word,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Score summary card shared by both activity screens.
class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.score,
    required this.total,
    required this.label,
    this.accent = AppColors.blue,
  });

  final int score;
  final int total;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : score / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: accent.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text('$score of $total correct',
              style: const TextStyle(fontSize: 15, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}
