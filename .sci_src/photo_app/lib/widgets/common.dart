import 'package:flutter/material.dart';

import '../models/content.dart';

// Palette taken from the photosynthesis diagram: leaf greens, sun yellow,
// water blue, soil brown.
const kGreen = Color(0xFF43A047);
const kGreenDark = Color(0xFF2E7D32);
const kGreenLight = Color(0xFFE3F2E1);
const kSun = Color(0xFFFBC02D);
const kWater = Color(0xFF29B6F6);
const kSoil = Color(0xFF8D6E63);
const kPaper = Color(0xFFF6FBF4);

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

/// An original, code-drawn summary of the reaction:
/// sunlight + CO₂ + H₂O  →  sugar + O₂
/// Wraps to two lines on narrow screens instead of overflowing.
class EquationBanner extends StatelessWidget {
  const EquationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kGreenLight, Color(0xFFFFF8E1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGreen.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The photosynthesis reaction',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kGreenDark,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Token('light', Icons.wb_sunny_rounded, kSun),
              const _Plus(),
              _Token('CO₂', Icons.cloud_outlined, Colors.blueGrey),
              const _Plus(),
              _Token('H₂O', Icons.water_drop_rounded, kWater),
              const Icon(Icons.arrow_forward_rounded, color: kGreenDark),
              _Token('sugar', Icons.bakery_dining_rounded, kSoil),
              const _Plus(),
              _Token('O₂', Icons.air_rounded, kGreen),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Inputs enter the leaf; the chloroplast turns them into food and '
            'releases oxygen.',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _Token extends StatelessWidget {
  const _Token(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      );
}

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) =>
      const Text('+', style: TextStyle(fontSize: 18, color: kGreenDark));
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
        color: kGreenLight,
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
                    size: 18, color: kGreenDark),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Word bank',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: kGreenDark)),
                ),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: kGreenDark),
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
                      border: Border.all(color: kGreen.withOpacity(0.4)),
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
        border: Border.all(color: kGreen.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kGreenDark)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: kGreenLight,
              valueColor: const AlwaysStoppedAnimation(kGreen),
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
