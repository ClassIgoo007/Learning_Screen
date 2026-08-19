import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import 'modern_kit.dart';

/// Bottom action bar for physics worksheet screens — check, reset, and the
/// same "New AI …" control used in Biology and Language Arts modules.
class LessonActionBar extends StatelessWidget {
  const LessonActionBar({
    super.key,
    required this.accent,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.aiLabel,
    this.onAi,
    this.generating = false,
  });

  final Color accent;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final String? aiLabel;
  final VoidCallback? onAi;
  final bool generating;

  @override
  Widget build(BuildContext context) {
    final showAi = aiLabel != null && onAi != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AccentButton(
                          label: secondaryLabel,
                          accent: accent,
                          filled: false,
                          icon: Icons.refresh_rounded,
                          onPressed: generating ? null : onSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AccentButton(
                          label: primaryLabel,
                          accent: accent,
                          icon: Icons.checklist_rtl_rounded,
                          onPressed: generating ? null : onPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (showAi) ...[
                    const SizedBox(height: 10),
                    AppButton(
                      label: generating ? 'Generating…' : aiLabel!,
                      icon: Icons.auto_awesome_rounded,
                      color: accent,
                      enabled: !generating,
                      onTap: onAi!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
