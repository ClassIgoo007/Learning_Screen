import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Full-width rounded action button used for primary/secondary CTAs.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.green,
    this.textColor = Colors.white,
    this.outlined = false,
    this.icon,
    this.enabled = true,
    this.shadow = true,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final bool outlined;
  final IconData? icon;
  final bool enabled;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.white : color;
    final fg = outlined ? AppColors.ink : textColor;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: outlined
              ? Border.all(color: AppColors.hairline, width: 1.6)
              : null,
          boxShadow: (!outlined && shadow && enabled)
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: fg, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A white circular back button used in screen headers.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: kCardShadow,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppColors.ink, size: 20),
        ),
      ),
    );
  }
}

/// A round icon button (e.g. speaker, hint).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.blue,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

/// A row of hearts showing remaining lives.
class HeartsBar extends StatelessWidget {
  const HeartsBar({super.key, required this.lives, this.max = 5});

  final int lives;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: kCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.red, size: 18),
          const SizedBox(width: 6),
          Text(
            '$lives',
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
