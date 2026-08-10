import 'package:flutter/material.dart';

import '../animation/scene_metrics.dart';
import '../animation/scene_timeline.dart';
import 'apple_tree.dart';
import 'falling_apple.dart';
import 'formula_bubble.dart';
import 'ground_layer.dart';
import 'newton_figure.dart';
import 'sky_backdrop.dart';

/// The illustration itself.
///
/// Everything is laid out on a fixed 1000×1300 design canvas and scaled with a
/// [FittedBox], so the composition never reflows or clips — it just gets bigger
/// or smaller. Static layers sit behind [RepaintBoundary]s so that only the
/// apple, Newton's face and the bubble repaint each frame.
class SceneStageView extends StatelessWidget {
  const SceneStageView({required this.state, super.key});

  final SceneState state;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: SceneMetrics.canvas.width,
        height: SceneMetrics.canvas.height,
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              const Positioned.fill(child: SkyBackdrop()),
              const Positioned.fill(child: AppleTree()),
              const Positioned.fill(child: GroundLayer()),
              Positioned.fromRect(
                rect: SceneMetrics.newtonBox,
                child: RepaintBoundary(
                  child: NewtonFigure(surprise: state.surprise),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(child: FallingApple(state: state)),
              ),
              Positioned.fromRect(
                rect: SceneMetrics.bubbleBox,
                child: RepaintBoundary(
                  child: FormulaBubble(
                    reveal: state.bubbleReveal,
                    formulaReveal: state.formulaReveal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
