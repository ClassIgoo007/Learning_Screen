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

/// The reading passage, set in a tinted, elevated card with a rule down the
/// left edge so it reads as quoted material rather than instruction. Stays
/// permanently expanded — unlike Kinetic Theory and Heat and Temperature's
/// collapsible version — and fades and slides in once on first build, like
/// every other card on this tab.
class PassageCard extends StatelessWidget {
  const PassageCard({super.key, required this.passage});

  final Passage passage;

  @override
  Widget build(BuildContext context) {
    return EntranceFade(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        decoration: BoxDecoration(
          color: Palette.passageTint,
          borderRadius: BorderRadius.circular(16),
          border: const Border(left: BorderSide(color: Palette.slate, width: 4)),
          boxShadow: elevationShadow(strength: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              passage.title,
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w700,
                color: Palette.ink,
                height: 1.3,
                letterSpacing: -0.2,
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
            const SizedBox(height: 14),
            Text(
              passage.body,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.7,
                letterSpacing: 0.1,
                color: Palette.ink,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
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

/// Answered-count progress header: a bold "X of Y" readout over a thick,
/// animated, accent-glowing bar — brought over from Kinetic Theory and Heat
/// and Temperature so all three lessons show progress as first-class UI
/// rather than Cloud Formation's previous plain item-count label.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
                color: Palette.inkSoft,
              ),
            ),
            Text(
              '$answered of $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Palette.slate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ModernProgressBar(value: ratio, accent: Palette.slate),
      ],
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
        borderColor: color.withValues(alpha: 0.35),
        radius: Sizes.cardRadius + 4,
        glow: perfect ? color : null,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(perfect ? Icons.verified_outlined : Icons.insights_outlined,
                color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CountUpNumber(
                        value: score,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        ' out of $total',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
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
                  child: AccentButton(
                    label: secondaryLabel,
                    accent: Palette.slate,
                    filled: false,
                    icon: Icons.refresh,
                    onPressed: onSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AccentButton(
                    label: primaryLabel,
                    accent: Palette.slate,
                    icon: Icons.checklist_rtl,
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

/// Pill button used by the animation screen for play/pause and beats. The
/// selected state now carries a soft accent shadow and animates in, instead
/// of snapping straight to a flat tint. Replaces the private `_ControlPill`
/// the animation screen used to define for itself.
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
    final fg = selected ? Palette.slate : Palette.inkSoft;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Palette.slateTint : Palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Palette.slate : Palette.hairline,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: selected ? accentGlow(Palette.slate, strength: 0.3) : null,
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
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
/// matching the diagram's own smooth transition. Replaces the inline
/// caption `Container` the animation screen used to build for itself.
class CaptionPanel extends StatelessWidget {
  const CaptionPanel({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      color: Palette.slateTint,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: CaptionCrossfade(
        keyValue: title,
        child: Column(
          key: ValueKey(title),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: Palette.slate,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
