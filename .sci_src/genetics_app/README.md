# DNA & Chromosomes — Reading Comprehension

A Flutter learning app with two passage-based activities.

* **Screen 1 — Passage 1 + Questions:** a short passage on the structure of
  DNA with its diagram, followed by 10 multiple-choice comprehension
  questions with instant feedback and explanations.
* **Screen 2 — Passage 2 + Fill in the Blanks:** a passage on chromosomes
  and the genome, followed by 12 sentences completed by typing. Grading
  ignores case, spacing and punctuation, and accepts singular/plural and
  digits or number words (46 / forty-six, 23 / twenty-three).

Every answer is findable in the passage above it — a unit test enforces this
for the fill-in-the-blank items.

## Run
    flutter pub get
    flutter run

## Test
    flutter test

Each passage panel can be collapsed once read and reopened while working,
its text is selectable, and tapping either diagram opens a full-screen
pinch-to-zoom viewer.

Responsive: single column on phones, side-by-side activity cards and a
capped content width on tablets and desktop. No third-party runtime
dependencies; works fully offline.
