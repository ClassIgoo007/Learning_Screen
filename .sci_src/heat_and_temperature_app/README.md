# Heat and temperature

A four-screen Flutter worksheet built from the textbook pages on very hot and
very cold: Fig. 4-9, the principle of cryogenics, Fig. 4-8, a plasma jet, and
Tables 4-2 and 4-3, the temperatures at which common substances change state.

## Screens

| Tab | Screen | Content |
|---|---|---|
| Animation | `AnimationScreen` | Both figures behind a segmented control, five beats between them. |
| Questions | `ChoiceScreen` | Passage 1 — *The principle of cryogenics* — then four multiple-choice questions. **Check answers** marks each card, turning the correct option green in place and a wrong selection red beside it. |
| Blanks | `BlankScreen` | Passage 2 — *Very hot and very cold* — then six sentences with an inline blank to type into. Marking ignores case, trims whitespace, drops a trailing full stop and accepts listed alternatives, so `15000` passes where the key reads `15,000`. |
| Tables | `TableScreen` | Table 4-3 (liquefying and freezing points of gases) and Table 4-2 (melting and boiling points of metals), each row carrying a bar that spans its two readings on a common scale. Sortable by temperature. |

Answers survive tab switches, and screens that are off stage sit inside a muted
`TickerMode` so nothing animates unseen.

## The beats

| Beat | Figure | What changes |
|---|---|---|
| 1 Compression | 4-9 | The valve is shut, gas moves only along the charge leg, the upper chamber fills, and wavy-tailed arrows carry heat out to the surroundings. |
| 2 Expansion | 4-9 | The valve swings open, gas passes into the lower chamber, and the arrows reverse: heat is drawn in from the surroundings. |
| 3 Thermal pump | 4-9 | Both chambers work together and both sets of arrows run — heat taken from the expander, pumped into the compressor. |
| 4 Arc struck | 4-8 | Noble gas flows and the arc jumps between electrode and nozzle; the plume is short and the ruler reads low. |
| 5 Plasma jet | 4-8 | Full current: the plume reaches across the canvas and the ruler reads 15,000°C, against a kitchen flame at 1,700 and the sun's surface at 6,000. |

## Running

```bash
flutter pub get
flutter test
flutter run
```

No plugins, no network calls, no assets — every shape is drawn at runtime, so
the app works entirely offline and stays sharp at any zoom.

## How the animations work

One `AnimationController` supplies a looping clock. `CryoState` and
`PlasmaState` are pure functions of that clock and of a beat position, so any
frame is exactly reproducible and pausing costs nothing. Separate controllers
hold the beat position — `_cycle` running from 1.0 to 3.0 for the apparatus and
`_intensity` from 0 to 1 for the torch — which makes every beat change a
cross-fade rather than a switch: at 1.5 the valve is half open and the heat
arrows are halfway through reversing.

The apparatus draws gas as dashes travelling along two pipe paths. The charge
leg, compressor to compression chamber, always runs; the return leg only
carries gas in proportion to how far the valve has opened, which is the
mechanical fact the figure is making. Heat flow uses the book's own notation —
wavy-tailed arrows — with the tail a travelling sine wave so the direction is
unmistakable. Arrows leaving a chamber start at the wall; arrows arriving start
outside it and point in.

Both figures are composed on their own fixed design canvas and scaled with a
`FittedBox` (`ScaledCanvas`), so a phone, a tablet and a projector show the
identical picture.

## Production notes

- **Tests.** `flutter test` covers the marking rules, the integrity of the
  lesson data (every answer is one of its own choices; every beat referenced
  exists), the state functions, and a widget test that walks all four tabs.
- **Accessibility.** Both animated figures carry a `Semantics` description,
  every table row announces its readings, the system text scale is honoured up
  to 1.4×, and the platform's reduce-motion setting holds the clock on a single
  frame and hides the play control.
- **No dead pixels.** Every screen is width-constrained to a readable measure
  and centred on wide displays; the app runs in any orientation.
- **Determinism.** No `Random` outside the arc flicker, which is seeded from
  the clock, so screenshots and golden tests are stable.

## Project layout

```
lib/
  main.dart                     entrypoint
  app.dart                      MaterialApp, theme, clamped text scaling
  theme/palette.dart            every colour and layout constant
  models/lesson.dart            Passage, ChoiceQuestion, ClozeSentence, Lesson
  models/reference_table.dart   SubstanceReading, ReferenceTable
  data/lesson_data.dart         both passages and both question sets
  data/reference_data.dart      Tables 4-2 and 4-3
  animation/cryo_timeline.dart  CryoStage, CryoState, PlasmaState, geometry
  painting/flow.dart            dash, arrowhead and caption helpers
  painting/cryo_painters.dart   the cryogenic apparatus
  painting/plasma_painters.dart the torch, its arc, its plume and the ruler
  screens/lesson_shell.dart     tabs and LessonNavigator
  screens/animation_screen.dart both figures and their controls
  screens/choice_screen.dart    part 1
  screens/blank_screen.dart     part 2
  screens/table_screen.dart     the reference tables
  widgets/common.dart           shared cards, pills, canvas and action bar
test/
  worksheet_test.dart
```

## Swapping the content

`Lesson`, `Passage`, `ChoiceQuestion`, `ClozeSentence`, `SubstanceReading` and
`ReferenceTable` all carry `fromJson`/`toJson` or plain const data, so the
worksheet and the tables can be fetched rather than compiled in without
touching a widget. Each item's `beat` names the stage it tests, and after
marking every card shows a **Watch beat N** link that opens the animation tab
at that beat — which also selects the right figure.

## Reference document

`Heat_and_Temperature_Worksheet_UI.docx` is a page-for-page replica of all four
screens, with stills of every beat, both tables, and an answer key.
