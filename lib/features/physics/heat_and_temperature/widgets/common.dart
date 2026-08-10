import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../screens/heat_and_temperature_shell.dart';
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
///
/// Collapsible — tap the header to show or hide the body — the same
/// interaction the Biology reading cards and the Kinetic Theory lesson's
/// `PassageCard` already use (icon + title + Hide/Read + chevron). Starts
/// collapsed by default, so the worksheet opens on the questions rather than
/// a wall of text; Cloud Formation's passage stays permanently expanded.
class PassageCard extends StatefulWidget {
  const PassageCard({super.key, required this.passage, this.initiallyOpen = false});

  final Passage passage;
  final bool initiallyOpen;

  @override
  State<PassageCard> createState() => _PassageCardState();
}

class _PassageCardState extends State<PassageCard> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final passage = widget.passage;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, _open ? 18 : 14),
      decoration: const BoxDecoration(
        color: Palette.passageTint,
        border: Border(left: BorderSide(color: Palette.slate, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    passage.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Palette.ink,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _open ? 'Hide' : 'Read',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Palette.slate,
                  ),
                ),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  color: Palette.slate,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_open) ...[
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

/// Answered-count progress bar, shown in place of [SectionLabel]'s plain
/// trailing count — the same `LinearProgressIndicator` treatment already used
/// by the Biology reading quiz, the Bernoulli lab, and Kinetic Theory (rounded
/// track, accent fill, "answered X of Y" readout) rather than a new control
/// style.
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
                fontSize: 11.5,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600,
                color: Palette.inkSoft,
              ),
            ),
            Text(
              '$answered of $total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Palette.slate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Palette.slateTint,
            valueColor: const AlwaysStoppedAnimation(Palette.slate),
          ),
        ),
      ],
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
        border: Border.all(color: color.withOpacity(0.35)),
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

/// Pill button used by both animation screens for play/pause and beats.
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
      color: selected ? Palette.slateTint : Palette.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Palette.slate : Palette.hairline,
            ),
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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The caption beneath an animation, naming the beat and explaining it.
class CaptionPanel extends StatelessWidget {
  const CaptionPanel({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Palette.slateTint,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Palette.slate,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}


/// Scales a fixed design canvas into the available width and repaints it on
/// every tick of the supplied animation. Every animated figure in the app is
/// authored on its own canvas and shown through this, so a phone, a tablet and
/// a projector all get the identical picture.
class ScaledCanvas extends StatelessWidget {
  const ScaledCanvas({
    super.key,
    required this.size,
    required this.animation,
    required this.painterBuilder,
  });

  final Size size;
  final Listenable animation;
  final CustomPainter Function() painterBuilder;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: size.width / size.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) =>
                CustomPaint(painter: painterBuilder(), size: size),
          ),
        ),
      ),
    );
  }
}

/// Two-way segmented control choosing which figure — or which table — is on
/// screen. Reused by both the Animation tab (cryogenic cycle vs. plasma jet)
/// and the Tables tab (gases vs. metals).
class SegmentedPicker extends StatelessWidget {
  const SegmentedPicker({
    super.key,
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, bool selected, VoidCallback onTap) {
      return Expanded(
        child: Material(
          color: selected ? Palette.slate : Palette.surface,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : Palette.inkSoft,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.hairline),
      ),
      child: Row(
        children: [
          segment(left, leftSelected, onLeft),
          const SizedBox(width: 4),
          segment(right, !leftSelected, onRight),
        ],
      ),
    );
  }
}
