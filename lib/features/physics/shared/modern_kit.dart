/// The modern visual system shared by Cloud Formation, Kinetic Theory and
/// Heat and Temperature. Every widget here takes its colour from the call
/// site — each lesson's own accent — rather than owning a palette of its
/// own, so the three lessons stay visually consistent without collapsing
/// into looking like the same lesson.
///
/// Every one of the three lessons already shares identical neutral tokens
/// (paper, surface, ink, inkSoft, hairline, correct/wrong) even though each
/// keeps its own `Palette` class — confirmed by comparing all three — so
/// those are safe to hard-code here rather than threaded through as params.
library;

import 'package:flutter/material.dart';

const Color _ink = Color(0xFF23282D);
const Color _inkSoft = Color(0xFF5B6670);
const Color _hairline = Color(0xFFDCD8CF);
const Color _correct = Color(0xFF2F7A52);
const Color _correctTint = Color(0xFFE4F1E9);
const Color _wrong = Color(0xFFB03A2E);
const Color _wrongTint = Color(0xFFFAE7E4);

/// White (or ink, on a light accent such as Heat and Temperature's yellow)
/// so filled controls stay readable against whichever lesson colour they sit
/// on.
Color onAccent(Color accent) =>
    accent.computeLuminance() > 0.55 ? _ink : Colors.white;

/// Neutral elevation shadow, tuned from the app's existing `kCardShadow`
/// token (theme/app_theme.dart) rather than a new colour.
List<BoxShadow> elevationShadow({double strength = 1}) => [
      BoxShadow(
        color: _ink.withValues(alpha: 0.07 * strength),
        blurRadius: 22 * strength,
        offset: Offset(0, 10 * strength),
      ),
      const BoxShadow(
        color: Color(0x08000000),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ];

/// An accent-tinted glow, the same shape as the app's `kButtonShadow` token
/// but built from whichever accent the call site passes in.
List<BoxShadow> accentGlow(Color accent, {double strength = 1}) => [
      BoxShadow(
        color: accent.withValues(alpha: 0.32 * strength),
        blurRadius: 20 * strength,
        offset: Offset(0, 8 * strength),
      ),
    ];

/// A surface with soft elevation and generous rounded corners — the base
/// replacement for the flat, shadowless bordered `Container` used for every
/// card in these three lessons before this.
class ElevatedCard extends StatelessWidget {
  const ElevatedCard({
    super.key,
    required this.child,
    required this.color,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.margin,
    this.radius = 22,
    this.borderColor,
    this.borderWidth = 1.5,
    this.elevated = true,
    this.glow,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final bool elevated;

  /// Optional accent-tinted glow behind the card, layered under the neutral
  /// elevation shadow — used sparingly (the canvas frame, the score card).
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final shadows = <BoxShadow>[
      if (glow != null) ...accentGlow(glow!, strength: 0.55),
      if (elevated) ...elevationShadow(),
    ];
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows.isEmpty ? null : shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A primary or secondary action button: accent gradient (primary) or
/// outlined (secondary), with an icon slot and a press-down scale — the
/// replacement for the plain `FilledButton`/`OutlinedButton` pair in
/// `ActionBar`.
class AccentButton extends StatefulWidget {
  const AccentButton({
    super.key,
    required this.label,
    required this.accent,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;
  final Color accent;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  State<AccentButton> createState() => _AccentButtonState();
}

class _AccentButtonState extends State<AccentButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final accent = widget.accent;
    final darker = Color.lerp(accent, Colors.black, 0.18)!;
    final fg = widget.filled ? onAccent(accent) : accent;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 160),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.filled
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent, darker],
                        )
                      : null,
                  color: widget.filled ? null : Colors.white,
                  border: widget.filled
                      ? null
                      : Border.all(color: _hairline, width: 1.4),
                  boxShadow: widget.filled && enabled
                      ? accentGlow(accent, strength: 0.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The feedback a selectable tile (a choice option, a filled-in blank) is
/// currently showing.
enum TileFeedback { neutral, selected, correct, incorrect }

/// A tappable option tile whose border/fill transition smoothly between
/// feedback states, instead of snapping instantly — the replacement for the
/// plain `Container` swap every choice/cloze tile used before this.
class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.child,
    required this.feedback,
    required this.accent,
    this.onTap,
    this.radius = 16,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 14, 12),
  });

  final Widget child;
  final TileFeedback feedback;
  final Color accent;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    switch (feedback) {
      case TileFeedback.neutral:
        fill = const Color(0xFFF7F5F1);
        border = Colors.transparent;
      case TileFeedback.selected:
        fill = accent.withValues(alpha: 0.12);
        border = accent;
      case TileFeedback.correct:
        fill = _correctTint;
        border = _correct;
      case TileFeedback.incorrect:
        fill = _wrongTint;
        border = _wrong;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: border,
              width: feedback == TileFeedback.neutral ? 0 : 1.6,
            ),
            boxShadow: feedback == TileFeedback.neutral
                ? null
                : elevationShadow(strength: 0.35),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A check/cross icon that pops in with a small overshoot instead of
/// appearing statically.
class AnimatedFeedbackIcon extends StatelessWidget {
  const AnimatedFeedbackIcon({
    super.key,
    required this.correct,
    required this.visible,
    this.size = 22,
  });

  final bool correct;
  final bool visible;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 140),
        child: Icon(
          correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: size,
          color: correct ? _correct : _wrong,
        ),
      ),
    );
  }
}

/// A thicker, animated-fill progress bar with an accent glow — the
/// replacement for the stock `LinearProgressIndicator` used for question and
/// blank progress before this.
class ModernProgressBar extends StatelessWidget {
  const ModernProgressBar({
    super.key,
    required this.value,
    required this.accent,
    this.height = 10,
  });

  /// 0..1.
  final double value;
  final Color accent;
  final double height;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: accent.withValues(alpha: 0.14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  gradient: LinearGradient(
                    colors: [
                      accent,
                      Color.lerp(accent, Colors.white, 0.25)!,
                    ],
                  ),
                  boxShadow: accentGlow(accent, strength: 0.45),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A number that counts up to [value] instead of appearing instantly — used
/// by the score reveal.
class CountUpNumber extends StatelessWidget {
  const CountUpNumber({super.key, required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$v', style: style),
    );
  }
}

/// Fade + gentle scale entrance, one shot — used for the score banner
/// revealing itself after marking.
class ScaleFadeIn extends StatefulWidget {
  const ScaleFadeIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Fade + slide-up entrance, one shot — used to bring passage/question cards
/// in when a tab first loads, optionally staggered with [delay].
class EntranceFade extends StatefulWidget {
  const EntranceFade({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideFraction = 0.06,
  });

  final Widget child;
  final Duration delay;
  final double slideFraction;

  @override
  State<EntranceFade> createState() => _EntranceFadeState();
}

class _EntranceFadeState extends State<EntranceFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, widget.slideFraction),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Crossfades [child] whenever [keyValue] changes — used so the Animation
/// tab's beat title/description transition with the diagram instead of
/// jump-cutting.
class CaptionCrossfade extends StatelessWidget {
  const CaptionCrossfade({
    super.key,
    required this.keyValue,
    required this.child,
  });

  final Object keyValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(keyValue), child: child),
    );
  }
}

/// Question index: a squircle badge. [filled] is Cloud Formation's treatment;
/// Kinetic Theory and Heat and Temperature use the tinted outline so the
/// three lessons share a primitive without looking identical.
class NumberBadge extends StatelessWidget {
  const NumberBadge({
    super.key,
    required this.number,
    required this.accent,
    this.filled = false,
    this.size = 32,
  });

  final int number;
  final Color accent;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? onAccent(accent) : accent;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? accent : accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        boxShadow: filled ? accentGlow(accent, strength: 0.35) : null,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: fg,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// A / B / C / D marker on a multiple-choice tile. Fills with the tile's
/// feedback colour so the letter, not a radio icon, is the state signal.
class LetterBadge extends StatelessWidget {
  const LetterBadge({
    super.key,
    required this.index,
    required this.feedback,
    required this.accent,
  });

  final int index;
  final TileFeedback feedback;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + index);
    final Color fill;
    final Color fg;
    switch (feedback) {
      case TileFeedback.neutral:
        fill = Colors.white;
        fg = _inkSoft;
      case TileFeedback.selected:
        fill = accent;
        fg = onAccent(accent);
      case TileFeedback.correct:
        fill = _correct;
        fg = Colors.white;
      case TileFeedback.incorrect:
        fill = _wrong;
        fg = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
        boxShadow: feedback == TileFeedback.neutral
            ? null
            : elevationShadow(strength: 0.3),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// Small topic tag sitting above a question prompt.
class TopicChip extends StatelessWidget {
  const TopicChip({
    super.key,
    required this.label,
    required this.accent,
    required this.tint,
  });

  final String label;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

/// Elevated frame around an animation canvas, with the figure caption in a
/// footer strip rather than as italic text sitting on the paper.
class FigureFrame extends StatelessWidget {
  const FigureFrame({
    super.key,
    required this.child,
    required this.caption,
    required this.accent,
  });

  final Widget child;
  final String caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      color: Colors.white,
      glow: accent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: child,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FIG',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: onAccent(accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: _inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline cloze input: a rounded chip rather than an underlined TextField.
class BlankChip extends StatelessWidget {
  const BlankChip({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.accent,
    required this.checked,
    required this.correct,
    required this.onSubmitted,
    required this.onChanged,
    this.width = 148,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Color accent;
  final bool checked;
  final bool correct;
  final VoidCallback onSubmitted;
  final VoidCallback onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    final Color text;
    if (!checked) {
      fill = accent.withValues(alpha: 0.10);
      border = accent;
      text = accent;
    } else if (correct) {
      fill = _correctTint;
      border = _correct;
      text = _correct;
    } else {
      fill = _wrongTint;
      border = _wrong;
      text = _wrong;
    }

    return SizedBox(
      width: width,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          final focused = focusNode.hasFocus && !checked;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: border,
                width: focused ? 2 : 1.4,
              ),
              boxShadow: focused ? accentGlow(accent, strength: 0.35) : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !checked,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => onSubmitted(),
              onChanged: (_) => onChanged(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: text,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: '······',
                hintStyle: TextStyle(
                  color: _inkSoft,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Hint under a cloze sentence, before marking.
class HintCallout extends StatelessWidget {
  const HintCallout({super.key, required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: _inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The correct word, shown under a missed cloze item after marking.
class RevealRow extends StatelessWidget {
  const RevealRow({super.key, required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: _wrongTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.subdirectory_arrow_right_rounded,
              size: 16, color: _wrong),
          const SizedBox(width: 8),
          Text(
            'Answer: $answer',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _wrong,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "Watch beat N" chip — a control, not a text link.
class WatchChip extends StatelessWidget {
  const WatchChip({
    super.key,
    required this.beat,
    required this.accent,
    required this.onTap,
  });

  final int beat;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_filled_rounded, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                'Watch beat $beat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One row in the animation tab's beat list.
class TimelineBeat {
  const TimelineBeat({
    required this.kicker,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String kicker;
  final String body;
  final bool selected;
  final VoidCallback onTap;
}

/// Tappable vertical timeline of beats — replaces the plain stacked
/// `RichText` captions Cloud Formation used to list under the figure.
class CaptionTimeline extends StatelessWidget {
  const CaptionTimeline({
    super.key,
    required this.beats,
    required this.accent,
    required this.tint,
  });

  final List<TimelineBeat> beats;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < beats.length; i++) ...[
          _TimelineRow(
            beat: beats[i],
            accent: accent,
            tint: tint,
            last: i == beats.length - 1,
          ),
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.beat,
    required this.accent,
    required this.tint,
    required this.last,
  });

  final TimelineBeat beat;
  final Color accent;
  final Color tint;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: beat.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: beat.selected ? accent : Colors.white,
                          border: Border.all(color: accent, width: 2),
                        ),
                      ),
                      if (!last)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: accent.withValues(alpha: 0.22),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: beat.selected ? tint : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: beat.selected
                          ? accentGlow(accent, strength: 0.25)
                          : elevationShadow(strength: 0.35),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beat.kicker,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          beat.body,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: _ink,
                          ),
                        ),
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

/// Icon tile used in passage headers and score reveals.
class AccentGlyph extends StatelessWidget {
  const AccentGlyph({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 40,
  });

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: accent, size: size * 0.5),
    );
  }
}
