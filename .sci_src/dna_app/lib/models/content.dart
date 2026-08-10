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

  /// Case-, space- and punctuation-insensitive check, so "mRNA", "m-RNA"
  /// and "messenger RNA" are all treated alike where the biology is.
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

/// Key vocabulary, shown as a reference strip on the screens.
const List<String> kWordBank = [
  'DNA', 'RNA', 'protein', 'transcription', 'translation',
  'replication', 'reverse transcription', 'double helix', 'uracil',
  'codon', 'amino acids', 'central dogma',
];

/// Screen 1 content - ten multiple-choice questions drawn from the
/// transcription and translation diagram.
const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    question: 'Which process copies DNA into RNA?',
    options: ['Replication', 'Transcription', 'Translation'],
    answerIndex: 1,
    explanation:
        'Transcription reads a stretch of DNA and builds a matching RNA '
        'copy - the arrow running from DNA across to RNA.',
  ),
  QuizQuestion(
    question: 'Which process uses RNA to build a protein?',
    options: ['Translation', 'Transcription', 'Reverse transcription'],
    answerIndex: 0,
    explanation:
        'Translation reads the RNA message and joins amino acids into a '
        'protein - the arrow from RNA to the protein.',
  ),
  QuizQuestion(
    question: 'Which process copies DNA to make more DNA?',
    options: ['Translation', 'Transcription', 'Replication'],
    answerIndex: 2,
    explanation:
        'Replication is the looping arrow on the left: DNA is copied so a '
        'dividing cell can give each new cell a full set.',
  ),
  QuizQuestion(
    question: 'Which process builds DNA from an RNA template?',
    options: ['Reverse transcription', 'Replication', 'Translation'],
    answerIndex: 0,
    explanation:
        'Reverse transcription runs backwards along the middle arrow, from '
        'RNA to DNA. Retroviruses such as HIV use it.',
  ),
  QuizQuestion(
    question: 'Which molecule in the diagram is a double helix?',
    options: ['RNA', 'DNA', 'The protein'],
    answerIndex: 1,
    explanation:
        'DNA is drawn as two strands twisted together; the RNA beside it '
        'has only a single strand.',
  ),
  QuizQuestion(
    question: 'Which molecule carries the message to be translated?',
    options: ['DNA', 'RNA', 'The protein'],
    answerIndex: 1,
    explanation:
        'RNA is the working copy. It carries the instructions from the gene '
        'to the place where the protein is built.',
  ),
  QuizQuestion(
    question: 'What is the end product shown on the right of the diagram?',
    options: ['A protein', 'A chromosome', 'A new cell'],
    answerIndex: 0,
    explanation:
        'The tangled teal shape is a folded protein - the finished product '
        'of translation.',
  ),
  QuizQuestion(
    question: 'What is the usual direction of genetic information flow?',
    options: [
      'Protein to RNA to DNA',
      'DNA to RNA to protein',
      'RNA to DNA to protein',
    ],
    answerIndex: 1,
    explanation:
        'DNA is transcribed to RNA, and RNA is translated to protein. This '
        'is often called the central dogma of molecular biology.',
  ),
  QuizQuestion(
    question: 'Which base does RNA use in place of thymine?',
    options: ['Uracil', 'Cytosine', 'Guanine'],
    answerIndex: 0,
    explanation:
        'RNA uses uracil (U) where DNA uses thymine (T). The other three '
        'bases - A, C and G - are shared.',
  ),
  QuizQuestion(
    question: 'How many RNA bases code for one amino acid?',
    options: ['One', 'Two', 'Three'],
    answerIndex: 2,
    explanation:
        'Three bases form a codon, and each codon tells the cell which '
        'amino acid to add next during translation.',
  ),
];

/// Screen 2 content - twelve fill-in-the-blank sentences.
const List<BlankItem> kBlankItems = [
  BlankItem(
    before: 'The double-stranded molecule that stores genetic information is ',
    after: '.',
    accepted: ['DNA', 'deoxyribonucleic acid'],
    hint: 'Three letters, drawn as a twisted ladder.',
  ),
  BlankItem(
    before: 'Making an RNA copy of a gene is called ',
    after: '.',
    accepted: ['transcription'],
    hint: 'The arrow pointing from DNA towards RNA.',
  ),
  BlankItem(
    before: 'Building a protein from an RNA message is called ',
    after: '.',
    accepted: ['translation'],
    hint: 'The arrow pointing from RNA towards the protein.',
  ),
  BlankItem(
    before: 'Copying DNA to make an identical DNA molecule is called ',
    after: '.',
    accepted: ['replication', 'DNA replication'],
    hint: 'The looping arrow on the left of the diagram.',
  ),
  BlankItem(
    before: 'Building DNA from an RNA template is called reverse ',
    after: '.',
    accepted: ['transcription'],
    hint: 'The middle arrow, running the other way.',
  ),
  BlankItem(
    before: 'The single-stranded molecule in the middle of the diagram is ',
    after: '.',
    accepted: ['RNA', 'ribonucleic acid', 'mRNA', 'messenger RNA'],
    hint: 'It is the working copy of a gene.',
  ),
  BlankItem(
    before: 'The finished product of translation is a ',
    after: '.',
    accepted: ['protein'],
    hint: 'The tangled teal shape on the right.',
  ),
  BlankItem(
    before: 'The twisted shape of the DNA molecule is called a double ',
    after: '.',
    accepted: ['helix'],
    hint: 'It rhymes with "Felix".',
  ),
  BlankItem(
    before: 'In RNA, the base ',
    after: ' takes the place of thymine.',
    accepted: ['uracil', 'U'],
    hint: 'Its letter is U.',
  ),
  BlankItem(
    before: 'A group of three RNA bases that codes for one amino acid is a ',
    after: '.',
    accepted: ['codon'],
    hint: 'It sounds like the word "code".',
  ),
  BlankItem(
    before: 'Proteins are long chains built from ',
    after: '.',
    accepted: ['amino acids', 'amino acid'],
    hint: 'Two words: "amino" and something acidic.',
  ),
  BlankItem(
    before: 'The overall flow DNA to RNA to protein is known as the central ',
    after: '.',
    accepted: ['dogma'],
    hint: 'Crick called it the central _____ of molecular biology.',
  ),
];
