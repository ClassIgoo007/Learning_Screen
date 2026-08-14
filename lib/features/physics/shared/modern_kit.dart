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
const Color _hairline = Color(0xFFDCD8CF);
const Color _correct = Color(0xFF2F7A52);
const Color _correctTint = Color(0xFFE4F1E9);
const Color _wrong = Color(0xFFB03A2E);
const Color _wrongTint = Color(0xFFFAE7E4);

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
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 1,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: shadows.isEmpty ? null : shadows,
      ),
      child: child,
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
    final fg = widget.filled ? Colors.white : accent;

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
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: widget.filled
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent, darker],
                        )
                      : null,
                  color: widget.filled ? null : Colors.white,
                  border:
                      widget.filled ? null : Border.all(color: _hairline),
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
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: fg,
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
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
        fill = Colors.white;
        border = _hairline;
      case TileFeedback.selected:
        fill = accent.withValues(alpha: 0.10);
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
              width: feedback == TileFeedback.neutral ? 1 : 1.6,
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
          correct ? Icons.check_circle : Icons.cancel,
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
