import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
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

/// The reading passage as an article card with a glyph header. Stays
/// permanently expanded — unlike Kinetic Theory and Heat and Temperature's
/// collapsible version — and fades in once on first build.
class PassageCard extends StatelessWidget {
  const PassageCard({super.key, required this.passage});

  final Passage passage;

  @override
  Widget build(BuildContext context) {
    return EntranceFade(
      child: ElevatedCard(
        color: Palette.surface,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                AccentGlyph(icon: Icons.cloud_outlined, accent: Palette.slate),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reading',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Palette.slate,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              passage.title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Palette.ink,
                height: 1.25,
                letterSpacing: -0.3,
              ),
            ),
            if (passage.figureCaption.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                passage.figureCaption,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Palette.inkSoft,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              passage.body,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.7,
                color: Palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Answered-count progress header: a compact elevated strip with a bold
/// "X of Y" readout over a thick, animated bar.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.label,
    required this.answered,
    required this.total,
  });

  final String label;
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : answered / total;
    return ElevatedCard(
      color: Palette.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Palette.ink,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Palette.slateTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$answered / $total',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Palette.slate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ModernProgressBar(value: ratio, accent: Palette.slate),
        ],
      ),
    );
  }
}

/// Result summary shown after marking — an elevated card that scales and
/// fades in, with the score itself counting up rather than snapping in.
class ScoreBanner extends StatelessWidget {
  const ScoreBanner({super.key, required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final perfect = score == total;
    final color = perfect ? Palette.correct : Palette.slate;
    final tint = perfect ? Palette.correctTint : Palette.slateTint;

    return ScaleFadeIn(
      child: ElevatedCard(
        color: tint,
        glow: perfect ? color : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Palette.surface,
                shape: BoxShape.circle,
                boxShadow: elevationShadow(strength: 0.5),
              ),
              child: CountUpNumber(
                value: score,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'out of $total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    perfect
                        ? 'Every item correct.'
                        : 'Correct answers are shown beneath the misses.',
                    style: const TextStyle(fontSize: 13, height: 1.35, color: Palette.inkSoft),
                  ),
                ],
              ),
            ),
            Icon(
              perfect ? Icons.verified_rounded : Icons.insights_rounded,
              color: color,
              size: 26,
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: Palette.surface,
        boxShadow: [
          BoxShadow(
            color: Palette.ink.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Sizes.gutter, 14, Sizes.gutter, 14),
          child: ContentFrame(
            child: Row(
              children: [
                Expanded(
                  child: AccentButton(
                    label: secondaryLabel,
                    accent: Palette.slate,
                    filled: false,
                    icon: Icons.refresh_rounded,
                    onPressed: onSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AccentButton(
                    label: primaryLabel,
                    accent: Palette.slate,
                    icon: Icons.checklist_rtl_rounded,
                    onPressed: onPrimary,
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

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: WatchChip(
        beat: beat,
        accent: Palette.slate,
        onTap: () => navigator.showBeat(beat),
      ),
    );
  }
}

/// Pill button used by the animation screen for play/pause and beats. The
/// selected state fills with the lesson accent rather than an outlined tint.
class ControlPill extends StatelessWidget {
  const ControlPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? onAccent(Palette.slate) : Palette.inkSoft;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Palette.slate : Palette.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: selected
                ? accentGlow(Palette.slate, strength: 0.4)
                : elevationShadow(strength: 0.45),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The caption beneath an animation, naming the beat and explaining it. The
/// title and body crossfade to the new beat's copy instead of jump-cutting,
/// matching the diagram's own smooth transition.
class CaptionPanel extends StatelessWidget {
  const CaptionPanel({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      color: Palette.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: CaptionCrossfade(
        keyValue: title,
        child: Column(
          key: ValueKey(title),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopicChip(
              label: title,
              accent: Palette.slate,
              tint: Palette.slateTint,
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.55,
                color: Palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
