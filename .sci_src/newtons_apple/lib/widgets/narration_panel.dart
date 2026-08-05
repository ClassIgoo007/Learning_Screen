import 'package:flutter/material.dart';

import '../animation/scene_timeline.dart';
import '../theme/palette.dart';

/// Explains, in words, what the animation is showing at this instant.
class NarrationPanel extends StatelessWidget {
  const NarrationPanel({required this.stage, this.compact = false, super.key});

  final SceneStage stage;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: Palette.uiSurfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final SceneStage s in SceneStage.values)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: s.index <= stage.index
                          ? Palette.uiAccent
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            child: Column(
              key: ValueKey<SceneStage>(stage),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${stage.index + 1}. ${stage.title}',
                  style: TextStyle(
                    color: Palette.uiOnSurface,
                    fontSize: compact ? 17 : 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stage.description,
                  style: TextStyle(
                    color: Palette.uiMuted,
                    fontSize: compact ? 13.5 : 15,
                    height: 1.45,
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
