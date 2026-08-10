/// A short explainer shown above the questions.
class Passage {
  const Passage({required this.title, required this.text});
  final String title;
  final String text;
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  String get answer => options[answerIndex];
}

const Passage kBernoulliPassage = Passage(
  title: "Bernoulli's principle",
  text:
      'Water flowing through a pipe of varying diameter has to obey two rules '
      'at once. The first is continuity: the same amount of water must pass '
      'every point each second, so where the pipe narrows the water is forced '
      'to speed up. The second is Bernoulli\'s principle: along a horizontal '
      'pipe the static pressure plus the pressure of motion stays constant, '
      'written p + ½ρv² = constant. The moving water can only gain speed by '
      'giving up pressure, so the fast water in the narrow throat pushes less '
      'hard on the walls than the slow water in the wide sections. Standpipes '
      'rising from the pipe make this visible: the water climbs high where the '
      'pressure is high, and sinks where the pressure is low. That is why the '
      'column above the throat is the shortest of the three.',
);

/// Ten questions on Bernoulli's principle, all answerable from the passage
/// and from playing with the simulation.
const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    question: 'In the narrow part of the tube, the water moves…',
    options: ['Faster', 'Slower', 'At the same speed'],
    answerIndex: 0,
    explanation:
        'The same volume must get through every second, so squeezing the pipe '
        'forces the water to speed up.',
  ),
  QuizQuestion(
    question: 'Where is the pressure lowest?',
    options: [
      'In the wide sections',
      'In the narrow throat',
      'It is the same everywhere',
    ],
    answerIndex: 1,
    explanation:
        'Pressure is lowest exactly where the speed is highest — which is why '
        'the middle standpipe holds the shortest column.',
  ),
  QuizQuestion(
    question: 'Why must the water speed up as the pipe narrows?',
    options: [
      'Gravity pulls it through',
      'The walls push it forward',
      'The same volume must pass each point every second',
    ],
    answerIndex: 2,
    explanation:
        'This is the continuity rule, A₁v₁ = A₂v₂. A smaller opening can only '
        'pass the same flow if the water moves through it faster.',
  ),
  QuizQuestion(
    question: 'What quantity stays constant along the horizontal pipe?',
    options: [
      'The speed of the water',
      'The static pressure',
      'Static pressure plus ½ρv²',
    ],
    answerIndex: 2,
    explanation:
        "That sum is Bernoulli's constant. In the simulation the two stacked "
        'bars always add up to the same total, however you move the sliders.',
  ),
  QuizQuestion(
    question:
        'The throat is 4 times faster than the wide pipe. Halve the flow. '
        'What happens to that ratio?',
    options: [
      'It stays 4 times',
      'It halves to 2 times',
      'It doubles to 8 times',
    ],
    answerIndex: 0,
    explanation:
        'The speed ratio equals the area ratio, so it depends only on the '
        "shape of the pipe. Both speeds halve, but their ratio doesn't move.",
  ),
  QuizQuestion(
    question:
        'If the throat diameter is halved, how many times faster does the '
        'water move through it?',
    options: ['2 times', '4 times', '8 times'],
    answerIndex: 1,
    explanation:
        'Area depends on diameter squared, so half the diameter is a quarter '
        'of the area — and a quarter of the area means four times the speed.',
  ),
  QuizQuestion(
    question: 'What does the height of water in a standpipe measure?',
    options: [
      'The static pressure at that point',
      'The speed of the water at that point',
      'The depth of the pipe',
    ],
    answerIndex: 0,
    explanation:
        'A standpipe is a manometer: the column height h is the static '
        'pressure written as h = p / ρg.',
  ),
  QuizQuestion(
    question:
        'In an ideal pipe, how do the two wide-section columns compare?',
    options: [
      'The upstream one is higher',
      'They are equal',
      'The downstream one is higher',
    ],
    answerIndex: 1,
    explanation:
        'Both wide sections have the same diameter, so the same speed and the '
        'same pressure. In a real pipe friction makes the downstream column a '
        'little lower.',
  ),
  QuizQuestion(
    question:
        'Push the flow high enough and the throat pressure falls to zero. '
        'What happens in a real pipe?',
    options: [
      'The water flows faster still, with no ill effect',
      'The pipe bursts outwards at the throat',
      'The water boils into vapour bubbles — cavitation',
    ],
    answerIndex: 2,
    explanation:
        'Once the pressure drops far enough the water vaporises, forming '
        'bubbles that collapse violently and pit the pipe. The simulation '
        'warns you when it reaches this point.',
  ),
  QuizQuestion(
    question: 'How does the same principle help lift an aircraft wing?',
    options: [
      'Air travels faster over the curved top, so pressure there is lower',
      'Air is warmer above the wing, so it rises',
      'The wing pushes air downwards only at the tips',
    ],
    answerIndex: 0,
    explanation:
        'Faster flow over the upper surface means lower pressure above the '
        'wing than below it, and that pressure difference contributes lift.',
  ),
];
