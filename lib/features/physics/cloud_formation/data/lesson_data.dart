import '../models/lesson.dart';

/// The worksheet content. Everything the two screens render comes from here,
/// so the lesson can later be swapped for a downloaded or generated one
/// without touching a single widget.
const Lesson kCloudLesson = Lesson(
  passageOne: Passage(
    title: 'How a cloud is formed',
    figureCaption: 'Fig. 17-11 — the formation of rain in a cumulonimbus cloud',
    body:
        'Air can hold only a limited amount of water vapour, and that limit '
        'falls as the air grows colder. So when warm, moist air is lifted — '
        'carried upward by a convective current over sun-heated ground, or '
        'forced up the slope of a mountain — it cools as it climbs, and its '
        'relative humidity rises even though it has gained no new moisture. At '
        'a certain height the air can no longer hold all the vapour it started '
        'with. The surplus condenses into a multitude of tiny water droplets, '
        'and that visible mass of droplets is what we call a cloud.',
  ),
  choiceQuestions: [
    ChoiceQuestion(
      beat: 1,
      topic: 'Ascent',
      prompt: 'What lifts the moist air that builds a cloud?',
      choices: [
        'A descending current of dry air',
        'An ascending convective current, or a mountain slope',
        'The weight of the water vapour itself',
      ],
      answer: 'An ascending convective current, or a mountain slope',
    ),
    ChoiceQuestion(
      beat: 2,
      topic: 'Cooling',
      prompt:
          'The rising air gains no new moisture, yet its relative humidity '
          'rises. Why?',
      choices: [
        'The maximum vapour the air can hold falls as it cools',
        'The air absorbs vapour from the clouds above it',
        'Pressure squeezes extra vapour into the parcel',
      ],
      answer: 'The maximum vapour the air can hold falls as it cools',
    ),
    ChoiceQuestion(
      beat: 3,
      topic: 'Condensation',
      prompt: 'A cloud is composed of —',
      choices: [
        'invisible water vapour',
        'a multitude of tiny water droplets',
        'dust carried up from the ground',
      ],
      answer: 'a multitude of tiny water droplets',
    ),
    ChoiceQuestion(
      beat: 4,
      topic: 'Saturation',
      prompt: 'Condensation begins at the point where the air —',
      choices: [
        'has cooled to the temperature of the ground',
        'can no longer hold all the vapour it started with',
        'has stopped rising altogether',
      ],
      answer: 'can no longer hold all the vapour it started with',
    ),
  ],
  passageTwo: Passage(
    title: 'Clouds as indicators of circulation',
    figureCaption: 'Fig. 17-11 — ascending currents and falling rain drops',
    body:
        'Cloud formations are among the best indicators of atmospheric '
        'circulation. Their presence or absence does not influence the motion '
        'of air masses, but it makes that motion directly accessible to visual '
        'observation. The cumulus of a hot summer afternoon is the plainest '
        'case: each swelling tower marks a column of moist air ascending over '
        'warm ground. When such a tower grows into a cumulonimbus, the droplets '
        'inside it collide and merge until they are too heavy for the current '
        'that lifted them. They then fall back through the rising air as rain, '
        'so a single cloud shows both directions of the circulation at once.',
  ),
  clozeSentences: [
    ClozeSentence(
      beat: 1,
      before: 'A cloud formation is a good',
      after: 'of atmospheric circulation.',
      answer: 'indicator',
      hint: 'It points something out without causing it',
    ),
    ClozeSentence(
      beat: 1,
      before: 'Clouds do not influence the motion of air masses; they only '
          'make that motion accessible to visual',
      after: '.',
      answer: 'observation',
    ),
    ClozeSentence(
      beat: 2,
      before: 'Each swelling cumulus tower marks a column of moist air',
      after: 'over warm ground.',
      answer: 'ascending',
      alsoAccept: ['rising'],
    ),
    ClozeSentence(
      beat: 3,
      before: 'Inside a cumulonimbus the droplets collide and',
      after: 'with one another.',
      answer: 'merge',
      alsoAccept: ['coalesce', 'combine'],
    ),
    ClozeSentence(
      beat: 4,
      before: 'Rain falls when the drops have grown too',
      after: 'for the current that lifted them.',
      answer: 'heavy',
      hint: 'The updraft can no longer support them',
    ),
    ClozeSentence(
      beat: 4,
      before: 'The drops fall back through the',
      after: 'air, so one cloud shows both directions at once.',
      answer: 'rising',
      alsoAccept: ['ascending'],
    ),
  ],
);
