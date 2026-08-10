# Newton’s Apple — animated Flutter scene

An apple lets go of the branch, accelerates under gravity, thumps into the
grass, and the law of universal gravitation resolves in a thought bubble above a
startled Isaac Newton.

Every element — sky, tree, grass, Newton, apples, bubble — is original vector
art drawn at runtime with `CustomPainter`. There are **no image assets**, so the
app is a few hundred kilobytes and stays sharp at any resolution.

## Run it

```bash
flutter --version          # needs Flutter 3.27+ / Dart 3.6+
flutter create . --platforms=android,ios,web,macos,windows,linux  # once, to add runners
flutter pub get
flutter run                # -d chrome, -d macos, or a device id
```

Quality gates:

```bash
flutter analyze
flutter test
flutter build apk --release      # or: appbundle / ipa / web / macos
```

## Controls

| Action | Control |
|---|---|
| Play / pause | Button, or <kbd>Space</kbd> |
| Replay | Replay button, or <kbd>R</kbd> |
| Scrub to any frame | Slider |
| Speed | 0.5× · 1× · 1.5× · 2× |
| Loop | Repeat toggle |

## How it is put together

```
lib/
├── main.dart                    entrypoint: error handling, orientation, chrome
├── app.dart                     MaterialApp, theme, text-scale clamp
├── animation/
│   ├── scene_timeline.dart      SceneStage + SceneState.fromProgress(t)
│   └── scene_metrics.dart       the fixed 1000×1300 design canvas
├── painting/apple_shape.dart    one apple routine, shared by every layer
├── theme/palette.dart           every colour in the illustration
├── screens/newton_scene_screen.dart   the single AnimationController
└── widgets/
    ├── scene_stage_view.dart    stacks the layers, scales with FittedBox
    ├── sky_backdrop.dart        static
    ├── apple_tree.dart          static
    ├── ground_layer.dart        static
    ├── newton_figure.dart       animated by `surprise`
    ├── falling_apple.dart       apple + speed lines + impact dust
    ├── formula_bubble.dart      staggered reveal of F = G·m₁m₂/r²
    ├── narration_panel.dart     physics caption for the current beat
    └── control_bar.dart         transport controls
```

**One clock.** A single `AnimationController` produces a value in `0..1`.
`SceneState.fromProgress(t)` turns it into every quantity the painters need. No
element owns its own timer, so nothing can drift out of sync, any frame can be
reproduced from its progress value, and scrubbing works for free.

**Fixed design canvas.** The illustration is composed at 1000×1300 and scaled
with `FittedBox`, so the composition is identical on every screen — it only gets
bigger or smaller, never reflows or clips.

**Only what moves repaints.** Sky, tree and grass are behind `RepaintBoundary`
with `shouldRepaint => false`; each animated painter compares its own inputs.

## The physics on screen

| Beat | What it shows |
|---|---|
| Observation | Stem tension balances weight — equilibrium |
| Free fall | `s = ½gt²`; the drop is `p²`, so the apple visibly accelerates |
| Impact | Large momentum change in a short time — squash and rebound |
| The real question | Does the same pull reach the Moon? |
| Universal gravitation | `F = G·m₁m₂/r²` |

`G ≈ 6.674 × 10⁻¹¹ N·m²·kg⁻²`.

## Production checklist

- Strict analyzer (`strict-casts`, `strict-inference`, `strict-raw-types`) + `flutter_lints`
- Unit tests for the timeline, widget tests for playback, narration and semantics
- Zone-guarded `main` with a friendly `ErrorWidget` instead of the red screen
- Controllers and focus nodes disposed; `mounted` checked before `setState`
- Honours the OS *reduce motion* setting; system text scale clamped to 0.8–1.4×
- Semantics labels on the apple, Newton and the equation
- Responsive: side panel on wide screens, stacked on phones
- Zero network calls, zero assets, zero third-party runtime dependencies
