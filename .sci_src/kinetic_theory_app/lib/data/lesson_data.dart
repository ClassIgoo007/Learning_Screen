import '../models/lesson.dart';

/// The worksheet content, built from Fig. 8-8 (molecules reflected from the
/// walls of a closed vessel) and Fig. 8-9 (Thomas B. Brown's ping-pong
/// apparatus, a mechanical model of a gas).
///
/// Everything the two question screens render comes from here, so the lesson
/// could later be fetched or generated without touching a single widget.
const Lesson kKineticLesson = Lesson(
  passageOne: Passage(
    title: 'Why a gas presses on its walls',
    figureCaption: 'Fig. 8-8 — molecules are reflected from the wall and '
        'thereby exert a pressure',
    body:
        'The kinetic theory explains the gas laws by treating a gas as a swarm '
        'of molecules rushing ceaselessly in all directions, bouncing off the '
        'walls of the vessel and colliding with one another. The pressure on '
        'those walls is nothing more than the continuous bombardment they '
        'receive, and since it is proportional to the total number of impacts '
        'per unit time, everything follows from counting impacts. Keep the '
        'temperature — that is, the velocity of the molecules — constant and '
        'reduce the volume, and the number striking a unit area A each second '
        'rises in inverse proportion: pressure is inversely proportional to '
        'volume. Warm the gas instead and the molecules move faster, so they '
        'strike the wall both more often and more violently, and at a given '
        'volume the pressure follows the absolute temperature.',
  ),
  choiceQuestions: [
    ChoiceQuestion(
      beat: 1,
      topic: 'Bombardment',
      prompt: 'On this theory, the pressure of a gas is —',
      choices: [
        'the weight of the gas resting on the wall',
        'the continuous bombardment of the wall by the molecules',
        'the friction of the molecules against one another',
      ],
      answer: 'the continuous bombardment of the wall by the molecules',
    ),
    ChoiceQuestion(
      beat: 2,
      topic: 'Volume',
      prompt:
          'The volume is reduced while the velocity of the molecules is kept '
          'constant. What happens at a unit area A of the wall?',
      choices: [
        'Fewer molecules reach it, so the pressure falls',
        'More molecules reach it each second, so the pressure rises',
        'The same number reach it, but each strikes harder',
      ],
      answer: 'More molecules reach it each second, so the pressure rises',
    ),
    ChoiceQuestion(
      beat: 3,
      topic: 'Temperature',
      prompt: 'Raising the temperature of a gas raises the pressure because —',
      choices: [
        'the molecules become larger and crowd the vessel',
        'the molecules move faster, so impacts are both more frequent and '
            'more violent',
        'new molecules are created inside the vessel',
      ],
      answer: 'the molecules move faster, so impacts are both more frequent '
          'and more violent',
    ),
    ChoiceQuestion(
      beat: 5,
      topic: 'The model',
      prompt: 'In Brown\u2019s apparatus, what stands for the temperature of '
          'the gas?',
      choices: [
        'The number of ping-pong balls in the container',
        'The distance between the two glass plates',
        'The speed of the cogwheel agitating the balls',
      ],
      answer: 'The speed of the cogwheel agitating the balls',
    ),
  ],
  passageTwo: Passage(
    title: 'A mechanical model of a gas',
    figureCaption:
        'Fig. 8-9 — an apparatus originally designed by T. B. Brown for '
        'demonstrating the kinetic theory of gases',
    body:
        'The characteristic features of this thermal motion can be '
        'demonstrated by a gadget designed by Thomas B. Brown. Ping-pong balls '
        'take the part of the molecules in a flat aquarium formed by two glass '
        'plates placed just far enough apart to let the balls move between '
        'them. At the bottom of the container a cogwheel driven by an electric '
        'motor kicks the balls upward. When the wheel rotates slowly most of '
        'the balls remain near the floor and only a few are thrown high, which '
        'is the model of a liquid with some molecules evaporating. Increasing '
        'the speed of the wheel increases the kinetic energy of the balls, as '
        'raising the temperature does, and if the container were open the '
        'fastest balls would escape it altogether. A movable piston resting on '
        'top of them is lifted and held up by their bombardment, so the balls '
        'now behave as a gas: the faster they move, the higher the piston '
        'stands.',
  ),
  clozeSentences: [
    ClozeSentence(
      beat: 1,
      before: 'The pressure of a gas is proportional to the total number of',
      after: 'the wall receives per unit time.',
      answer: 'impacts',
      alsoAccept: ['collisions'],
    ),
    ClozeSentence(
      beat: 4,
      before: 'In Brown\u2019s apparatus the ping-pong balls take the part of '
          'the',
      after: '.',
      answer: 'molecules',
    ),
    ClozeSentence(
      beat: 4,
      before: 'The balls move in a flat aquarium formed by two',
      after: 'plates.',
      answer: 'glass',
    ),
    ClozeSentence(
      beat: 4,
      before: 'They are kicked upward by a',
      after: 'driven by an electric motor.',
      answer: 'cogwheel',
      hint: 'A toothed wheel at the bottom of the container',
    ),
    ClozeSentence(
      beat: 4,
      before: 'While the wheel turns slowly most of the balls remain near the',
      after: 'of the container.',
      answer: 'bottom',
      alsoAccept: ['floor'],
    ),
    ClozeSentence(
      beat: 5,
      before: 'Increasing the speed of the wheel increases the kinetic',
      after: 'of the balls.',
      answer: 'energy',
      hint: 'What a faster molecule has more of',
    ),
  ],
);
