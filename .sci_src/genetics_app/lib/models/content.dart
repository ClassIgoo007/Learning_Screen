/// A reading passage that a set of questions is based on.
class Passage {
  final String title;
  final String text;
  final String asset;
  final String imageCaption;

  const Passage({
    required this.title,
    required this.text,
    required this.asset,
    required this.imageCaption,
  });
}

/// One multiple-choice question.
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

  /// Case-, space- and punctuation-insensitive check, so "23", "23 pairs"
  /// and "twenty-three" can each be accepted where they mean the same.
  bool accepts(String input) {
    final normalized = _normalize(input);
    if (normalized.isEmpty) return false;
    return accepted.any((a) => _normalize(a) == normalized);
  }

  static String _normalize(String s) {
    final buffer = StringBuffer();
    for (final rune in s.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[a-z0-9]').hasMatch(ch)) buffer.write(ch);
    }
    return buffer.toString();
  }
}

// ---------------------------------------------------------------- passages

/// Passage 1 — the basis for the Question & Answer screen.
const Passage kPassageOne = Passage(
  title: 'Passage 1: The Structure of DNA',
  asset: 'assets/dna_structure.jpg',
  imageCaption: 'DNA structure and the four bases',
  text:
      'DNA is shaped like a twisted ladder, a shape known as a double helix. '
      'Two long strands wind around each other, and the rungs between them '
      'are made from pairs of chemicals called bases. DNA uses four bases: '
      'adenine, guanine, thymine and cytosine. In the diagram each one has '
      'its own colour — adenine is blue, guanine is green, thymine is '
      'yellow and cytosine is pink — and its own chemical structure drawn '
      'beside it. The bases always join in the same way: adenine pairs with '
      'thymine, and guanine pairs with cytosine. Because of this rule the '
      'two strands carry matching information, and the order of the four '
      'bases along a strand spells out the instructions a cell needs to '
      'build and run a living thing.',
);

/// Passage 2 — the basis for the Fill in the Blanks screen.
const Passage kPassageTwo = Passage(
  title: 'Passage 2: Chromosomes and the Genome',
  asset: 'assets/chromosomes.jpg',
  imageCaption: 'Chromosomes and DNA molecules',
  text:
      'Inside almost every cell, DNA is packed into structures called '
      'chromosomes. Each chromosome is one very long DNA molecule wound '
      'tightly around proteins, which is why it can be drawn as an X shape '
      'with two arms joined at a narrow waist called the centromere. The '
      'coloured bands along the arms mark different regions of the DNA. '
      'Human body cells carry 46 chromosomes arranged in 23 pairs, with one '
      'chromosome of each pair inherited from each parent. A section of DNA '
      'that carries the instructions for one trait is called a gene, and all '
      'of an organism\'s DNA taken together is called its genome.',
);

/// Vocabulary strip shown on the screens.
const List<String> kWordBank = [
  'double helix', 'base', 'adenine', 'guanine', 'thymine', 'cytosine',
  'chromosome', 'centromere', 'gene', 'genome', 'protein', 'trait',
];

// ---------------------------------------------------------------- screen 1

/// Ten multiple-choice questions, all answerable from Passage 1.
const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    question: 'What shape is the DNA molecule?',
    options: ['A single straight line', 'A double helix', 'A flat circle'],
    answerIndex: 1,
    explanation:
        'The passage describes DNA as a twisted ladder, a shape known as a '
        'double helix.',
  ),
  QuizQuestion(
    question: 'How many strands wind around each other in DNA?',
    options: ['One', 'Two', 'Four'],
    answerIndex: 1,
    explanation: 'Two long strands wind around each other to form the helix.',
  ),
  QuizQuestion(
    question: 'What are the rungs of the ladder made from?',
    options: [
      'Pairs of bases',
      'Twists of protein',
      'Single strands of sugar',
    ],
    answerIndex: 0,
    explanation:
        'The rungs between the two strands are made from pairs of chemicals '
        'called bases.',
  ),
  QuizQuestion(
    question: 'How many different bases does DNA use?',
    options: ['Two', 'Three', 'Four'],
    answerIndex: 2,
    explanation:
        'DNA uses four bases: adenine, guanine, thymine and cytosine.',
  ),
  QuizQuestion(
    question: 'Which base pairs with adenine?',
    options: ['Guanine', 'Thymine', 'Cytosine'],
    answerIndex: 1,
    explanation:
        'The passage gives the pairing rule: adenine pairs with thymine.',
  ),
  QuizQuestion(
    question: 'Which base pairs with cytosine?',
    options: ['Guanine', 'Adenine', 'Thymine'],
    answerIndex: 0,
    explanation: 'The second half of the rule: guanine pairs with cytosine.',
  ),
  QuizQuestion(
    question: 'In the diagram, which colour marks adenine?',
    options: ['Green', 'Blue', 'Pink'],
    answerIndex: 1,
    explanation:
        'The colour key gives adenine blue, guanine green, thymine yellow '
        'and cytosine pink.',
  ),
  QuizQuestion(
    question: 'Which base is shown in green?',
    options: ['Guanine', 'Thymine', 'Cytosine'],
    answerIndex: 0,
    explanation: 'Guanine is the green base in the diagram.',
  ),
  QuizQuestion(
    question: 'Why do the two strands carry matching information?',
    options: [
      'Because the bases always join by the same rule',
      'Because both strands are exactly the same length',
      'Because each strand has only one base',
    ],
    answerIndex: 0,
    explanation:
        'Since A always joins T and G always joins C, one strand determines '
        'what the other must be.',
  ),
  QuizQuestion(
    question: 'What does the order of the bases along a strand spell out?',
    options: [
      'The colour of the molecule',
      'The instructions a cell needs',
      'The number of chromosomes',
    ],
    answerIndex: 1,
    explanation:
        'The order of the four bases spells out the instructions a cell '
        'needs to build and run a living thing.',
  ),
];

// ---------------------------------------------------------------- screen 2

/// Twelve fill-in-the-blank sentences, all answerable from Passage 2.
const List<BlankItem> kBlankItems = [
  BlankItem(
    before: 'Inside almost every cell, DNA is packed into structures called ',
    after: '.',
    accepted: ['chromosomes', 'chromosome'],
    hint: 'They are the X shapes at the top of the picture.',
  ),
  BlankItem(
    before: 'Each chromosome is one very long ',
    after: ' molecule.',
    accepted: ['DNA', 'deoxyribonucleic acid'],
    hint: 'Three letters.',
  ),
  BlankItem(
    before: 'The DNA in a chromosome is wound tightly around ',
    after: '.',
    accepted: ['proteins', 'protein'],
    hint: 'The passage says DNA is wound around these to pack it up.',
  ),
  BlankItem(
    before: 'A chromosome is often drawn as an ',
    after: ' shape.',
    accepted: ['X'],
    hint: 'A single letter of the alphabet.',
  ),
  BlankItem(
    before: 'The narrow waist where the two arms join is called the ',
    after: '.',
    accepted: ['centromere'],
    hint: 'It starts with "centro", meaning centre.',
  ),
  BlankItem(
    before: 'The coloured ',
    after: ' along the arms mark different regions of the DNA.',
    accepted: ['bands', 'band'],
    hint: 'They look like stripes.',
  ),
  BlankItem(
    before: 'Human body cells carry ',
    after: ' chromosomes in total.',
    accepted: ['46', 'forty-six'],
    hint: 'It is double the number of pairs.',
  ),
  BlankItem(
    before: 'Those chromosomes are arranged in ',
    after: ' pairs.',
    accepted: ['23', 'twenty-three'],
    hint: 'It is half of forty-six.',
  ),
  BlankItem(
    before: 'One chromosome of each pair is inherited from each ',
    after: '.',
    accepted: ['parent'],
    hint: 'A mother or a father.',
  ),
  BlankItem(
    before: 'A section of DNA carrying the instructions for one trait is '
        'called a ',
    after: '.',
    accepted: ['gene'],
    hint: 'Four letters, and it gives us the word "genetics".',
  ),
  BlankItem(
    before: 'All of an organism\'s DNA taken together is called its ',
    after: '.',
    accepted: ['genome'],
    hint: 'It is like "gene" with an ending added.',
  ),
  BlankItem(
    before: 'A feature such as eye colour, controlled by a gene, is called '
        'a ',
    after: '.',
    accepted: ['trait'],
    hint: 'The passage uses this word for what one gene carries '
        'instructions for.',
  ),
];
