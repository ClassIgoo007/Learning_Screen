# Bernoulli's Principle — an animated Figure 1-10

A Flutter app that recreates the Venturi-tube figure from the textbook and
brings it to life: water flows through a pipe of varying diameter while three
standpipes show the static pressure at each station. **The pressure is lower
in the narrow part where the water moves faster, and higher in the wide parts
where it moves slower.**

---

## Getting started

This repository contains the Dart source only; the generated platform folders
are not committed (see `.gitignore`). Create them for the platforms you need:

```bash
flutter create --platforms=android,ios,web \
               --org com.example --project-name bernoulli_venturi .
flutter pub get
flutter run
```

Then quality gates:

```bash
dart format .            # own the layout with the formatter
flutter analyze          # must be clean before merging
flutter test             # unit + widget suites
flutter test --coverage  # writes coverage/lcov.info
```

Release builds:

```bash
flutter build apk --release        # Android
flutter build appbundle --release  # Play Store
flutter build ipa --release        # iOS (requires Xcode signing)
flutter build web --release
```

**Requirements:** Flutter 3.19 or newer (Dart 3.3+). Android minSdk 21,
iOS 13+. No third-party runtime dependencies and no bundled assets — the
figure is drawn entirely with a `CustomPainter`, so the app is small and works
fully offline.

---

## Screens

| Screen | What it does |
| --- | --- |
| **Home** | A still of the figure and the two entry points. The preview does not animate — an idle ticker on a landing screen is wasted battery. |
| **Run the experiment** | The animated figure plus flow-rate and throat-diameter sliders, live readouts, the pressure-budget bars and a running explanation. |
| **Questions & answers** | A short explainer and ten multiple-choice questions, each with an explanation tied back to the simulation. |

## The physics is real, not a cartoon

`lib/physics/venturi.dart` is pure Dart with no Flutter imports, so it is unit
tested headlessly. It solves the two governing equations:

```
continuity   A₁v₁ = A₂v₂ = Q
Bernoulli    p + ½ρv²  = constant
```

and converts pressure to the column height a manometer would show, `h = p/ρg`.
The tests assert continuity, that Bernoulli's constant really is constant, and
that "faster ⇒ lower pressure" holds at 121 points across the whole slider
range — not just at the default setting.

Consequences that fall out of the model rather than being faked:

- The speed ratio equals the **area** ratio, so halving the throat diameter
  quadruples the throat speed, and changing the pump does not alter the ratio.
- Widen the throat to the full pipe bore and the three columns level out.
- Open the flow wide through a tight throat and the throat pressure goes
  negative: the app warns about **cavitation** and empties the middle column,
  which is what a real pipe would do.
- Flow streaks are seeded evenly in *travel time*, so they settle into the
  correct steady state — sparser and longer where the water is fast.

## Architecture

```
lib/
  main.dart                       entry point + global error handling
  app.dart                        MaterialApp: themes, routes, text-scale policy
  physics/venturi.dart            pure model: the equations and the pipe profile
  state/simulation_controller.dart mutable screen state, independent of widgets
  logic/quiz_controller.dart      quiz scoring and locking
  models/content.dart             passage and questions as data
  theme/app_theme.dart            light/dark themes + semantic colour extension
  widgets/venturi_figure.dart     the animated figure (CustomPainter + Ticker)
  widgets/common.dart             shared, theme-aware building blocks
  screens/                        home, simulation, questions
```

Physics, state and presentation are separate layers: nothing in `physics/` or
`state/` imports Flutter widgets, which is why most of the behaviour is tested
without pumping a frame.

## Production considerations

**Performance.** The figure is wrapped in a `RepaintBoundary` and repaints via
a `Listenable` rather than `setState`, so animating it does not rebuild the
surrounding page. The ticker **stops itself** when the flow is paused and the
columns have settled, so a static figure costs no frames. Animation also stops
when the app is backgrounded.

**Accessibility.** The figure carries a generated spoken description of the
current state, so the diagram is not a blank to a screen reader. Sliders have
semantic value formatters, quiz options are announced as buttons with their
position and outcome, and results are announced when chosen. Touch targets are
at least 48 dp, and feedback uses icons and text as well as colour. The OS
"reduce motion" setting pauses the animation and says so. System font scaling
is honoured but clamped at 1.5× to protect the figure labels.

**Theming.** Light and dark themes are generated from one seed. Semantic
colours (correct / warning / low-pressure) live in an `AppColors`
`ThemeExtension` rather than being hardcoded per widget. The diagram itself
always renders on a light "paper" surface in both themes, which is a
deliberate choice: a technical figure reads better on white.

**Robustness.** `VenturiModel` asserts its invariants in debug, and
`VenturiModel.sanitised()` clamps untrusted input (a restored session, a deep
link) instead of throwing. `SimulationController` will not let the throat
exceed the pipe bore. Uncaught errors are funnelled through one reporting hook
in `main.dart`, ready for Crashlytics or Sentry.

**CI.** `.github/workflows/ci.yaml` runs formatting, `flutter analyze
--fatal-warnings`, the full test suite with coverage, and a release Android
build. The formatting step is advisory on first adoption — run `dart format .`
once, then make it blocking.

## Known limitations

- The model is the ideal, frictionless case, so both wide sections read the
  same pressure. A real pipe loses a little to friction, which would make the
  downstream column slightly lower. This is called out in the app.
- Flow is treated as steady and incompressible, and the pipe as horizontal, so
  the gravity term of Bernoulli's equation is omitted.
- Below zero absolute pressure the model reports cavitation but does not
  simulate two-phase flow; the standpipe simply empties.

## Licence

MIT — see [LICENSE](LICENSE).
