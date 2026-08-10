# Kinetic theory of gases

A three-screen Flutter worksheet built from the textbook pages on the kinetic
theory of gases: Fig. 8-8, where molecules are reflected from the wall of a
closed vessel and thereby exert a pressure, and Fig. 8-9, Thomas B. Brown's
ping-pong apparatus for demonstrating that motion mechanically.

## Screens

| Tab | Screen | Content |
|---|---|---|
| Animation | `AnimationScreen` | Both figures, behind a segmented control, with five beats between them. |
| Questions | `ChoiceScreen` | Passage 1 — *Why a gas presses on its walls* — then four multiple-choice questions. **Check answers** marks each card, turning the correct option green in place and a wrong selection red beside it. |
| Blanks | `BlankScreen` | Passage 2 — *A mechanical model of a gas* — then six sentences with an inline blank to type into. Marking ignores case, trims whitespace, drops a trailing full stop and accepts listed synonyms. |

Answers on both question screens survive tab switches, and the screens that are
off screen sit inside a muted `TickerMode`, so nothing animates unseen.

## The beats

| Beat | Figure | What changes |
|---|---|---|
| 1 Bombardment | 8-8 | Molecules travel and reflect; every wall strike is drawn as a starburst on the unit area A. |
| 2 Volume reduced | 8-8 | The right wall is driven inward at constant molecular velocity, so impacts on A come more often. |
| 3 Temperature raised | 8-8 | Full volume again, but every molecule moves faster and trails a longer tail. |
| 4 Wheel turning slowly | 8-9 | Most balls stay near the floor, a few are thrown high — a liquid with some molecules evaporating. |
| 5 Wheel turning fast | 8-9 | More kinetic energy per ball, and their bombardment lifts the piston and holds it up. |

Beats 2 and 3 are deliberately exclusive: the text changes one thing at a time,
so the animation does too. A gauge beside the vessel reads `A × T / V`, and both
beats move it — for two quite different reasons.

## Running

```bash
flutter pub get
flutter run
```

No plugins, no network calls, no assets. Every shape is drawn at runtime, so the
app works offline and stays sharp at any zoom.

## How the animation works

One `AnimationController` repeating over a long period supplies an elapsed-
seconds value. Molecule and ball positions come from `foldBetween`, which
reflects a coordinate back and forth between two walls — a bounce with no state
to keep. Any frame is therefore an exact function of the clock, which is what
makes pausing, scrubbing and the cross-fades work without a physics step
anywhere.

Shorter controllers hold `compression`, `heat` and `agitation`, each animating
between 0 and 1, so squeezing the vessel or speeding up the wheel is a smooth
transition rather than a switch. Both figures are composed on their own fixed
design canvas and scaled with a `FittedBox` (`ScaledCanvas`), so a phone, a
tablet and a projector show the identical picture. If the platform asks for
reduced motion the clock holds one frame and the play control disappears.

## Project layout

```
lib/
  main.dart                     entrypoint
  app.dart                      MaterialApp, theme, clamped text scaling
  theme/palette.dart            every colour and layout constant
  models/lesson.dart            Passage, ChoiceQuestion, ClozeSentence, Lesson
  data/lesson_data.dart         both passages and both question sets
  animation/kinetic_timeline.dart  KineticStage, VesselState, ApparatusState,
                                   the fold helpers and both geometries
  painting/flow.dart            dash and caption helpers
  painting/kinetic_painters.dart   the vessel and Brown's apparatus
  screens/lesson_shell.dart     tabs and LessonNavigator
  screens/animation_screen.dart both figures and their controls
  screens/choice_screen.dart    part 1
  screens/blank_screen.dart     part 2
  widgets/common.dart           shared cards, pills, canvas and action bar
```

## Swapping the content

`Lesson`, `Passage`, `ChoiceQuestion` and `ClozeSentence` all have
`fromJson`/`toJson`, so `kKineticLesson` can be replaced by a worksheet loaded
from a file or an API without changing a widget. Each item's `beat` field names
the stage it tests, and after marking every card shows a **Watch beat N** link
that opens the animation tab at that beat — which also selects the right figure.

## Reference document

`Kinetic_Theory_Worksheet_UI.docx` is a page-for-page replica of the three
screens — the same passages, the same wording, the same numbering and blanks —
for printing or for checking the build against.
