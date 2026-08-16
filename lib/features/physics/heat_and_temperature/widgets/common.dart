import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
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

/// The reading passage as an article card with a glyph header.
///
/// Collapsible — tap the header to show or hide the body — the same
/// interaction the Biology reading cards already use. Starts collapsed by
/// default here, so the worksheet opens on the questions rather than a wall
/// of text; Cloud Formation's passage stays permanently expanded.
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
    return EntranceFade(
      child: ElevatedCard(
        color: Palette.surface,
        padding: EdgeInsets.fromLTRB(16, 16, 16, _open ? 18 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  const AccentGlyph(
                    icon: Icons.thermostat_outlined,
                    accent: Palette.slate,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reading',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Palette.slate,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          passage.title,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Palette.ink,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _open ? 'Hide' : 'Read',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Palette.slate,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: Palette.slate,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: !_open
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (passage.figureCaption.isNotEmpty) ...[
                          const SizedBox(height: 12),
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

/// Pill button used by both animation screens for play/pause and beats. The
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
    this.onTap,
  });

  final Size size;
  final Listenable animation;
  final CustomPainter Function() painterBuilder;

  /// Called with the tap position in canvas units (the same space as
  /// [size]), regardless of how far the figure has been scaled on screen.
  /// Most figures aren't interactive, so this is optional.
  final void Function(Offset canvasPosition)? onTap;

  @override
  Widget build(BuildContext context) {
    Widget canvas = SizedBox(
      width: size.width,
      height: size.height,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) =>
            CustomPaint(painter: painterBuilder(), size: size),
      ),
    );
    final onTap = this.onTap;
    if (onTap != null) {
      canvas = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => onTap(details.localPosition),
        child: canvas,
      );
    }
    return AspectRatio(
      aspectRatio: size.width / size.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: canvas,
      ),
    );
  }
}

/// Two-way segmented control choosing which figure — or which table — is on
/// screen.
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? Palette.slate : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow:
                    selected ? accentGlow(Palette.slate, strength: 0.35) : null,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? onAccent(Palette.slate) : Palette.inkSoft,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Palette.slateTint,
        borderRadius: BorderRadius.circular(18),
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
