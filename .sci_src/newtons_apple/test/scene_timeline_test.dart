import 'package:flutter_test/flutter_test.dart';
import 'package:newtons_apple/animation/scene_timeline.dart';

void main() {
  group('SceneState.fromProgress', () {
    test('clamps out-of-range progress', () {
      expect(SceneState.fromProgress(-3).progress, 0.0);
      expect(SceneState.fromProgress(7).progress, 1.0);
    });

    test('the apple stays on the branch until the fall begins', () {
      expect(SceneState.fromProgress(0.0).appleDrop, 0.0);
      expect(SceneState.fromProgress(SceneTiming.hangEnd - 0.01).appleDrop, 0.0);
    });

    test('the apple accelerates: later intervals cover more ground', () {
      const double span = SceneTiming.fallEnd - SceneTiming.hangEnd;
      final double firstThird =
          SceneState.fromProgress(SceneTiming.hangEnd + span / 3).appleDrop;
      final double secondThird =
          SceneState.fromProgress(SceneTiming.hangEnd + 2 * span / 3)
              .appleDrop -
              firstThird;

      expect(secondThird, greaterThan(firstThird));
    });

    test('the apple has landed by the end of the fall segment', () {
      expect(
        SceneState.fromProgress(SceneTiming.fallEnd).appleDrop,
        closeTo(1.0, 0.001),
      );
    });

    test('the apple squashes on impact and recovers', () {
      final SceneState onImpact =
          SceneState.fromProgress(SceneTiming.fallEnd + 0.001);
      final SceneState settled =
          SceneState.fromProgress(SceneTiming.settleEnd - 0.001);

      expect(onImpact.appleScaleY, lessThan(0.85));
      expect(onImpact.appleScaleX, greaterThan(1.15));
      expect(settled.appleScaleY, closeTo(1.0, 0.05));
    });

    test('the equation is fully revealed at the end', () {
      final SceneState end = SceneState.fromProgress(1.0);
      expect(end.bubbleReveal, 1.0);
      expect(end.formulaReveal, 1.0);
      expect(end.surprise, 1.0);
      expect(end.stage, SceneStage.revelation);
    });

    test('stages advance in order and never skip', () {
      int previous = -1;
      for (double t = 0; t <= 1.0; t += 0.005) {
        final int index = SceneState.fromProgress(t).stage.index;
        expect(index, greaterThanOrEqualTo(previous));
        expect(index - previous, lessThanOrEqualTo(1));
        previous = index;
      }
      expect(previous, SceneStage.values.length - 1);
    });

    test('equal progress produces equal state (frames are reproducible)', () {
      expect(
        SceneState.fromProgress(0.37),
        equals(SceneState.fromProgress(0.37)),
      );
    });

    test('every stage carries narration text', () {
      for (final SceneStage stage in SceneStage.values) {
        expect(stage.title, isNotEmpty);
        expect(stage.description.length, greaterThan(30));
      }
    });
  });
}
