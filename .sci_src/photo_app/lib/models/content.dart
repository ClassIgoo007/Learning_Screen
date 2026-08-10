/// One multiple-choice question for the Q&A screen.
class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  String get answer => options[answerIndex];
}

/// One fill-in-the-blank sentence. [before] and [after] surround the blank.
/// [accepted] lists every spelling counted as correct (first entry is the
/// canonical answer shown in the answer key).
class BlankItem {
  final String before;
  final String after;
  final List<String> accepted;
  final String hint;

  const BlankItem({
    required this.before,
    required this.after,
    required this.accepted,
    required this.hint,
  });

  String get answer => accepted.first;

  /// Case-, space- and punctuation-insensitive check, so "CO2", "co₂" and
  /// "carbon dioxide" all pass where the science is the same.
  bool accepts(String input) {
    final normalized = _normalize(input);
    if (normalized.isEmpty) return false;
    return accepted.any((a) => _normalize(a) == normalized);
  }

  static String _normalize(String s) {
    final lowered = s
        .toLowerCase()
        .replaceAll('₀', '0')
        .replaceAll('₁', '1')
        .replaceAll('₂', '2')
        .replaceAll('₃', '3')
        .replaceAll('₄', '4');
    final buffer = StringBuffer();
    for (final rune in lowered.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[a-z0-9]').hasMatch(ch)) buffer.write(ch);
    }
    return buffer.toString();
  }
}

/// The photosynthesis word bank, shown as a reference strip on both screens.
const List<String> kWordBank = [
  'sunlight', 'carbon dioxide', 'water', 'oxygen', 'sugar',
  'chloroplast', 'thylakoid', 'grana', 'stroma', 'Calvin cycle',
  'ATP', 'NADPH', 'leaf', 'roots',
];

/// Screen 1 content — ten multiple-choice questions drawn from the
/// photosynthesis diagram: inputs, outputs, structures and processes.
const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    question: 'Which gas does a plant take IN during photosynthesis?',
    options: ['Oxygen (O₂)', 'Carbon dioxide (CO₂)', 'Nitrogen (N₂)'],
    answerIndex: 1,
    explanation:
        'Leaves absorb carbon dioxide from the air. Its carbon atoms end up '
        'in the sugar the plant builds.',
  ),
  QuizQuestion(
    question: 'Which gas does a plant give OFF during photosynthesis?',
    options: ['Oxygen (O₂)', 'Carbon dioxide (CO₂)', 'Water vapour'],
    answerIndex: 0,
    explanation:
        'Splitting water releases oxygen, which leaves the plant through '
        'the leaves — the oxygen we breathe.',
  ),
  QuizQuestion(
    question: 'Which energy source powers photosynthesis?',
    options: ['Heat from the soil', 'Light from the Sun', 'Wind'],
    answerIndex: 1,
    explanation:
        'Light energy from the Sun is captured by the plant and stored as '
        'chemical energy in sugar.',
  ),
  QuizQuestion(
    question: 'What do the roots absorb from the soil?',
    options: [
      'Sugar and oxygen',
      'Water and minerals',
      'Carbon dioxide and light',
    ],
    answerIndex: 1,
    explanation:
        'Roots pull water and dissolved minerals out of the soil and carry '
        'them up to the leaves.',
  ),
  QuizQuestion(
    question: 'Inside which part of a plant cell does photosynthesis happen?',
    options: ['The nucleus', 'The chloroplast', 'The vacuole'],
    answerIndex: 1,
    explanation:
        'Chloroplasts are the green organelles inside leaf cells where the '
        'whole process takes place.',
  ),
  QuizQuestion(
    question: 'Where inside the chloroplast is light energy captured?',
    options: ['In the thylakoids', 'In the stroma', 'In the outer membrane'],
    answerIndex: 0,
    explanation:
        'Thylakoids are flat discs that trap light energy and run the '
        'light-dependent reactions.',
  ),
  QuizQuestion(
    question: 'What is a stack of thylakoids called?',
    options: ['A stroma', 'A granum (grana)', 'A membrane'],
    answerIndex: 1,
    explanation:
        'Thylakoids are stacked like coins; one stack is a granum, and '
        'several stacks are grana.',
  ),
  QuizQuestion(
    question: 'What is the fluid that surrounds the grana called?',
    options: ['The stroma', 'The cytoplasm', 'The intermembrane space'],
    answerIndex: 0,
    explanation:
        'The stroma is the fluid filling the chloroplast, and it is where '
        'the Calvin cycle runs.',
  ),
  QuizQuestion(
    question: 'Which cycle uses carbon dioxide to build sugar?',
    options: ['The water cycle', 'The Calvin cycle', 'The rock cycle'],
    answerIndex: 1,
    explanation:
        'The Calvin cycle takes carbon from CO₂ and assembles it into sugar '
        'using energy from ATP and NADPH.',
  ),
  QuizQuestion(
    question: 'The light reactions change ADP + P into which energy carrier?',
    options: ['NADP⁺', 'ATP', 'O₂'],
    answerIndex: 1,
    explanation:
        'ATP stores the energy that the Calvin cycle spends when it builds '
        'sugar molecules.',
  ),
];

/// Screen 2 content — twelve fill-in-the-blank sentences.
const List<BlankItem> kBlankItems = [
  BlankItem(
    before: 'A plant uses energy from ',
    after: ' to make its own food.',
    accepted: ['sunlight', 'light', 'the sun', 'sun', 'light energy'],
    hint: 'It shines down from the sky.',
  ),
  BlankItem(
    before: 'Leaves take in the gas ',
    after: ' from the air.',
    accepted: ['carbon dioxide', 'co2'],
    hint: 'Its formula is CO₂.',
  ),
  BlankItem(
    before: 'The roots pull ',
    after: ' and minerals out of the soil.',
    accepted: ['water', 'h2o'],
    hint: 'Its formula is H₂O.',
  ),
  BlankItem(
    before: 'The gas released back into the air is ',
    after: '.',
    accepted: ['oxygen', 'o2'],
    hint: 'It is the gas we breathe in.',
  ),
  BlankItem(
    before: 'The food that photosynthesis makes is ',
    after: '.',
    accepted: ['sugar', 'glucose', 'ch2o'],
    hint: 'It is sweet, and it stores energy.',
  ),
  BlankItem(
    before: 'Most photosynthesis happens inside a ',
    after: ' of the plant.',
    accepted: ['leaf', 'leaves'],
    hint: 'It is flat, green and grows on a stem.',
  ),
  BlankItem(
    before: 'Inside the plant cell, the green organelle called the ',
    after: ' does the work.',
    accepted: ['chloroplast', 'chloroplasts'],
    hint: 'Its name starts with "chloro".',
  ),
  BlankItem(
    before: 'Light energy is trapped by flat discs called ',
    after: '.',
    accepted: ['thylakoids', 'thylakoid'],
    hint: 'They look like stacked coins.',
  ),
  BlankItem(
    before: 'A stack of those discs is called a ',
    after: '.',
    accepted: ['granum', 'grana'],
    hint: 'Singular ends in "-um", plural in "-a".',
  ),
  BlankItem(
    before: 'The fluid that fills the chloroplast is the ',
    after: '.',
    accepted: ['stroma'],
    hint: 'It surrounds the grana.',
  ),
  BlankItem(
    before: 'Carbon dioxide is turned into sugar by the ',
    after: ' cycle.',
    accepted: ['calvin', 'calvin cycle'],
    hint: 'It is named after the scientist who found it.',
  ),
  BlankItem(
    before: 'The light reactions store energy in ATP and ',
    after: '.',
    accepted: ['nadph'],
    hint: 'NADP⁺ becomes this when it gains energy.',
  ),
];
