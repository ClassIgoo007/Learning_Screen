# Photosynthesis Learning App

A Flutter learning app built around the photosynthesis diagram.

* **Screen 1 — Question & Answer:** 10 multiple-choice questions with
  instant feedback and a short explanation for every answer.
* **Screen 2 — Fill in the Blanks:** 12 sentences completed by typing the
  missing word. Grading ignores case, spacing and punctuation, and accepts
  alternatives (CO2 / carbon dioxide, O2 / oxygen, grana / granum).

## Run
    flutter pub get
    flutter run

## Test
    flutter test

The photosynthesis diagram is bundled as an asset and appears on the home
screen, with a collapsible reference copy on both activity screens; tapping
it opens a full-screen pinch-to-zoom viewer.

Responsive: single column on phones,
capped content width on tablets and desktop. No third-party runtime
dependencies; works fully offline.
