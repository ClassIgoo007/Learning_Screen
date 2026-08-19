import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Normalised marks (0..1) along the storyboard.
///
/// Keeping them in one place means the whole scene stays in sync: every widget
/// derives what it draws from a single [SceneState], so there is no chance of
/// two animation controllers drifting apart.
abstract final class SceneTiming {
  /// Wall-clock length of one full playthrough at 1x speed.
  static const Duration total = Duration(milliseconds: 9500);

  static const double hangEnd = 0.16;

  /// Last ~400 ms of the hang beat: the apple stays still on the stem before
  /// it lets go (see [SceneState.stemAttached]).
  static const double hangPause = 0.042;

  static const double fallEnd = 0.40;
  static const double settleEnd = 0.54;
  static const double reactEnd = 0.66;
  static const double bubbleEnd = 0.76;
  static const double formulaEnd = 0.94;
}

/// The five beats of the story, each with the physics note shown to the viewer.
enum SceneStage {
  rest(
    'Observation',
    'The apple hangs in equilibrium. The tension in the stem exactly balances '
        'the weight pulling it down, so nothing moves.',
  ),
  falling(
    'Free fall',
    'The stem gives way. Gravity is now the only significant force, so the '
        'apple accelerates at g ≈ 9.81 m/s² and the distance it has fallen '
        'grows with the square of the time: s = ½gt².',
  ),
  impact(
    'Impact',
    'Newton\u2019s head brings the apple to rest in milliseconds, not the '
        'ground. That large change of momentum in so short a time is why the '
        'fruit squashes on contact and gives him a gentle bump as it '
        'rebounds.',
  ),
  realisation(
    'The real question',
    'The insight was not that the apple falls. It was asking whether the same '
        'pull, reaching much further, is what holds the Moon in its orbit.',
  ),
  revelation(
    'Universal gravitation',
    'Any two masses attract each other along the line joining them, in '
        'proportion to their masses and in inverse proportion to the square of '
        'the distance between them.',
  );

  const SceneStage(this.title, this.description);

  /// Short heading shown in the narration panel.
  final String title;

  /// Plain-language physics explanation for this beat.
  final String description;
}

double _segment(double t, double start, double end) {
  assert(end > start, 'A timeline segment must have a positive length.');
  return ((t - start) / (end - start)).clamp(0.0, 1.0);
}

/// An immutable snapshot of everything the painters need for a single frame.
///
/// Derived purely from `progress`, which makes the scene fully scrubbable: any
/// frame can be reproduced from its progress value alone (handy for tests,
/// screenshots and golden files).
@immutable
class SceneState {
  const SceneState({
    required this.progress,
    required this.stage,
    required this.appleDrop,
    required this.appleScaleX,
    required this.appleScaleY,
    required this.stemAttached,
    required this.trailOpacity,
    required this.impactProgress,
    required this.surprise,
    required this.bubbleReveal,
    required this.formulaReveal,
  });

  /// Overall playback position, 0..1.
  final double progress;

  /// Which beat of the story this frame belongs to.
  final SceneStage stage;

  /// 0 = still on the branch, 1 = resting on Newton's head.
  final double appleDrop;

  /// Squash-and-stretch factors applied to the apple.
  final double appleScaleX;
  final double appleScaleY;

  /// True while the apple is still hanging from the branch (stem visible).
  final bool stemAttached;

  /// Opacity of the speed lines behind the falling apple.
  final double trailOpacity;

  /// 0 = no impact yet, 1 = dust fully dispersed.
  final double impactProgress;

  /// How startled Newton looks, 0..1.
  final double surprise;

  /// Speech-bubble entrance, 0..1 (a curve is applied at paint time).
  final double bubbleReveal;

  /// Staggered reveal of the four parts of the equation, 0..1.
  final double formulaReveal;

  /// True once the apple has touched Newton's head.
  bool get hasLanded => progress >= SceneTiming.fallEnd;

  /// Builds the frame for a playback position.
  factory SceneState.fromProgress(double rawProgress) {
    final double t = rawProgress.clamp(0.0, 1.0);

    final double fall = _segment(t, SceneTiming.hangEnd, SceneTiming.fallEnd);
    final double settle =
        _segment(t, SceneTiming.fallEnd, SceneTiming.settleEnd);
    final double react =
        _segment(t, SceneTiming.fallEnd - 0.02, SceneTiming.reactEnd);
    final double bubble =
        _segment(t, SceneTiming.reactEnd, SceneTiming.bubbleEnd);
    final double formula =
        _segment(t, SceneTiming.bubbleEnd, SceneTiming.formulaEnd);

    // Free fall: distance ∝ t², so the apple visibly accelerates.
    // Normalised speed is the derivative of that curve, 2p.
    final double freeFall = fall * fall;
    final double speed = 2.0 * fall;

    double drop = freeFall;
    double scaleX = 1.0;
    double scaleY = 1.0;

    if (settle > 0.0) {
      // Two decaying rebounds after touchdown.
      final double rebound =
          math.sin(settle * math.pi * 2.0).abs() * math.exp(-3.2 * settle);
      drop = 1.0 - rebound * 0.09;

      // Squash on contact, easing back to a round apple.
      final double squash = math.exp(-6.5 * settle);
      scaleX = 1.0 + 0.34 * squash;
      scaleY = 1.0 - 0.30 * squash;
    } else if (fall > 0.0) {
      // Stretch along the direction of travel while accelerating.
      scaleX = 1.0 - 0.10 * speed;
      scaleY = 1.0 + 0.14 * speed;
    }

    final SceneStage stage;
    if (t < SceneTiming.hangEnd) {
      stage = SceneStage.rest;
    } else if (t < SceneTiming.fallEnd) {
      stage = SceneStage.falling;
    } else if (t < SceneTiming.reactEnd) {
      stage = SceneStage.impact;
    } else if (t < SceneTiming.bubbleEnd) {
      stage = SceneStage.realisation;
    } else {
      stage = SceneStage.revelation;
    }

    return SceneState(
      progress: t,
      stage: stage,
      appleDrop: drop,
      appleScaleX: scaleX,
      appleScaleY: scaleY,
      stemAttached: t < SceneTiming.hangEnd,
      trailOpacity: (fall * 3.0).clamp(0.0, 1.0) * (1.0 - settle),
      impactProgress: settle,
      surprise: react,
      bubbleReveal: bubble,
      formulaReveal: formula,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SceneState &&
          other.progress == progress &&
          other.appleDrop == appleDrop &&
          other.appleScaleX == appleScaleX &&
          other.appleScaleY == appleScaleY &&
          other.stemAttached == stemAttached &&
          other.trailOpacity == trailOpacity &&
          other.impactProgress == impactProgress &&
          other.surprise == surprise &&
          other.bubbleReveal == bubbleReveal &&
          other.formulaReveal == formulaReveal;

  @override
  int get hashCode => Object.hash(
        progress,
        appleDrop,
        appleScaleX,
        appleScaleY,
        stemAttached,
        trailOpacity,
        impactProgress,
        surprise,
        bubbleReveal,
        formulaReveal,
      );
}
