# Cloud formation worksheet

A two-screen Flutter comprehension worksheet built from the textbook page on
cloud formation and the formation of rain in a cumulonimbus cloud
(Fig. 17-11).

## Screens

| Tab | Screen | Content |
|---|---|---|
| Animation | `AnimationScreen` | The four-beat cloud-formation sequence, drawn with `CustomPainter`. Ascending currents flow as dashes along fixed cubic paths, the cloud breathes, droplets condense inside it and rain falls back through the updraft. Pills select a beat; play/pause holds the motion. |
| Questions | `ChoiceScreen` | Passage 1 — *How a cloud is formed* — followed by four multiple-choice questions. Tapping a choice selects it; **Check answers** marks each card green or red and reveals the correct option. |
| Blanks | `BlankScreen` | Passage 2 — *Clouds as indicators of circulation* — followed by six sentences with an inline blank to type into. Marking is case-insensitive, tolerates trailing punctuation, and accepts listed synonyms. |

Answers on both screens survive tab switches: the shell keeps them alive in an
`IndexedStack`.

## Running

```bash
flutter pub get
flutter run
```

No plugins, no network calls, no assets — the lesson is compiled in and the app
works entirely offline.

## Project layout

```
lib/
  main.dart                  entrypoint
  app.dart                   MaterialApp, theme, clamped text scaling
  theme/palette.dart         every colour and layout constant
  models/lesson.dart         Passage, ChoiceQuestion, ClozeSentence, Lesson
  data/lesson_data.dart      the two passages and both question sets
  animation/scene_timeline.dart  SceneStage (the four beats) + SceneState.fromProgress
  animation/scene_metrics.dart   the design canvas and every key coordinate
  painting/scene_painters.dart   ground, cloud, currents and rain painters
  screens/animation_screen.dart  the animation, its controls and caption
  screens/lesson_shell.dart  app bar + bottom navigation, LessonNavigator
  screens/choice_screen.dart part 1
  screens/blank_screen.dart  part 2
  widgets/common.dart        PassageCard, SectionLabel, ScoreBanner, ActionBar
```

## Swapping the content

`Lesson`, `Passage`, `ChoiceQuestion` and `ClozeSentence` all have
`fromJson`/`toJson`, so `kCloudLesson` in `data/lesson_data.dart` can be
replaced by a worksheet loaded from a file or an API without changing a widget.
The `beat` field on every item identifies the stage of the cloud-formation
sequence it tests (1 ascent, 2 cooling, 3 condensation, 4 rain), which is the
join key the animation uses: after marking, every question shows a
**Watch beat N** link that drives the scene to the stage it tests and brings
the animation tab forward.

## How the animation is built

One `AnimationController` produces a number between 0 and 1. A pure function,
`SceneState.fromProgress(t, stage)`, turns that number plus the current beat
position into every quantity the painters need — dash offset, cloud opacity,
droplet opacity, rain opacity, the cloud's vertical bob. Nothing owns a private
timer, so nothing can drift out of sync, and any frame is exactly reproducible
from its two inputs.

A second, shorter controller cross-fades between beats, so `stage` is a
continuous value from 1.0 to 4.0 rather than a switch: at 2.5 the cloud is half
condensed. The scene is composed on a fixed 1000 x 800 canvas and scaled with a
`FittedBox`, so a phone, a tablet and a projector all show the identical
picture. The static ground layer sits behind a `RepaintBoundary` and reports
that it never repaints. Nothing is downloaded — every shape is drawn at
runtime, so the app ships with no assets and stays sharp at any zoom. If the
platform asks for reduced motion, the clock holds a single frame and the
play/pause control is hidden.

## Reference document

`Cloud_Formation_Worksheet_UI.docx` is a page-for-page replica of the two
screens — the same passages, the same question wording, the same numbering and
the same blanks — for printing or for checking the build against.
