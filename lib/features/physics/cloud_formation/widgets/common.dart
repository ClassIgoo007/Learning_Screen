import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../screens/cloud_formation_shell.dart';
import '../theme/palette.dart';

/// Constrains the worksheet to a comfortable measure and centres it on wide
/// screens. Every scrolling body is wrapped in this.
class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Sizes.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// The reading passage, set in a tinted card with a rule down the left edge so
/// it reads as quoted material rather than instruction.
class PassageCard extends StatelessWidget {
  const PassageCard({super.key, required this.passage});

  final Passage passage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: const BoxDecoration(
        color: Palette.passageTint,
        border: Border(left: BorderSide(color: Palette.slate, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            passage.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Palette.ink,
              height: 1.3,
            ),
          ),
          if (passage.figureCaption.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              passage.figureCaption,
              style: const TextStyle(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                color: Palette.inkSoft,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            passage.body,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.65,
              color: Palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase rule used to separate the passage from the questions.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
              color: Palette.inkSoft,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: Palette.hairline, height: 1)),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            Text(
              trailing!,
              style: const TextStyle(fontSize: 12, color: Palette.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

/// Result summary shown after marking.
class ScoreBanner extends StatelessWidget {
  const ScoreBanner({super.key, required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final perfect = score == total;
    final color = perfect ? Palette.correct : Palette.slate;
    final tint = perfect ? Palette.correctTint : Palette.slateTint;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(perfect ? Icons.verified_outlined : Icons.insights_outlined,
              color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$score out of $total',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perfect
                      ? 'Every item correct.'
                      : 'Correct answers are shown beneath the misses.',
                  style: const TextStyle(fontSize: 13, color: Palette.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The bar pinned to the bottom of both screens.
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.surface,
        border: Border(top: BorderSide(color: Palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Sizes.gutter, 12, Sizes.gutter, 12),
          child: ContentFrame(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Palette.slate,
                      side: const BorderSide(color: Palette.hairline),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(secondaryLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: Palette.slate,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(primaryLabel),
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

/// Sends the student to the animation tab, at the beat this item tests.
/// Rendered only after marking, so it reads as an explanation rather than a
/// hint. Silently disappears if no [LessonNavigator] is above it, which keeps
/// the question cards usable in isolation (tests, previews).
class WatchBeatLink extends StatelessWidget {
  const WatchBeatLink({super.key, required this.beat});

  final int beat;

  @override
  Widget build(BuildContext context) {
    final navigator = LessonNavigator.maybeOf(context);
    if (navigator == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => navigator.showBeat(beat),
        icon: const Icon(Icons.play_circle_outline, size: 17),
        label: Text('Watch beat $beat'),
        style: TextButton.styleFrom(
          foregroundColor: Palette.slate,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
