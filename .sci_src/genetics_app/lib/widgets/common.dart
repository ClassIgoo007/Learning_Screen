import 'package:flutter/material.dart';

import '../models/content.dart';

// Palette taken from the diagram: the teal protein, the blue-grey DNA
// backbone and the coloured base pairs.
const kTeal = Color(0xFF00897B);
const kTealDark = Color(0xFF00695C);
const kTealLight = Color(0xFFE0F2F1);
const kAccent = Color(0xFF5C6BC0); // indigo, for the second activity
const kPaper = Color(0xFFF4FAF9);

/// Keeps content readable on very wide windows.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 820});

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

/// Reference strip of the key vocabulary, collapsible so it never
/// crowds the activity on a small phone.
class WordBankStrip extends StatefulWidget {
  const WordBankStrip({super.key});

  @override
  State<WordBankStrip> createState() => _WordBankStripState();
}

class _WordBankStripState extends State<WordBankStrip> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: BoxDecoration(
        color: kTealLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 18, color: kTealDark),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Word bank',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: kTealDark)),
                ),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: kTealDark),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final word in kWordBank)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kTeal.withOpacity(0.4)),
                    ),
                    child: Text(word, style: const TextStyle(fontSize: 13)),
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
  });

  final int score;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : score / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kTeal.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kTealDark)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: kTealLight,
              valueColor: const AlwaysStoppedAnimation(kTeal),
            ),
          ),
          const SizedBox(height: 8),
          Text('$score of $total correct',
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
