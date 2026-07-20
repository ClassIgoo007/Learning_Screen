/// A single worksheet item: a phonetic spelling, three candidate words,
/// and the word the phonetic spelling actually represents.
class PhoneticQuestion {
  final String phonetic; // e.g. "(bā´kən)"
  final List<String> choices; // exactly three words
  final String answer; // must be one of [choices]

  const PhoneticQuestion({
    required this.phonetic,
    required this.choices,
    required this.answer,
  });

  factory PhoneticQuestion.fromJson(Map<String, dynamic> json) {
    final choices =
        (json['choices'] as List).map((e) => e.toString()).toList();
    final answer = json['answer'].toString();
    if (choices.length != 3 || !choices.contains(answer)) {
      throw const FormatException('Invalid question payload');
    }
    return PhoneticQuestion(
      phonetic: json['phonetic'].toString(),
      choices: choices,
      answer: answer,
    );
  }

  Map<String, dynamic> toJson() =>
      {'phonetic': phonetic, 'choices': choices, 'answer': answer};
}

class Worksheet {
  final String title;
  final List<PhoneticQuestion> questions;

  const Worksheet({required this.title, required this.questions});

  factory Worksheet.fromJson(Map<String, dynamic> json) {
    return Worksheet(
      title: json['title']?.toString() ?? 'Phonetic Spelling Practice',
      questions: (json['questions'] as List)
          .map((q) => PhoneticQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Built-in worksheet used on first launch and as an offline fallback.
/// (Original content written in the standard dictionary-key notation.)
const Worksheet kDefaultWorksheet = Worksheet(
  title: 'Phonetic Spelling Practice',
  questions: [
    PhoneticQuestion(
        phonetic: '(bā´kən)',
        choices: ['basin', 'bacon', 'beckon'],
        answer: 'bacon'),
    PhoneticQuestion(
        phonetic: '(kak´təs)',
        choices: ['cactus', 'casket', 'cadet'],
        answer: 'cactus'),
    PhoneticQuestion(
        phonetic: '(mel´ən)',
        choices: ['million', 'mellow', 'melon'],
        answer: 'melon'),
    PhoneticQuestion(
        phonetic: '(pī´lət)',
        choices: ['pallet', 'pilot', 'pellet'],
        answer: 'pilot'),
    PhoneticQuestion(
        phonetic: '(tûr´nip)',
        choices: ['turnip', 'tuning', 'torrent'],
        answer: 'turnip'),
    PhoneticQuestion(
        phonetic: '(drag´ən)',
        choices: ['dragging', 'dragon', 'dragoon'],
        answer: 'dragon'),
    PhoneticQuestion(
        phonetic: '(rō´bot)',
        choices: ['rabbit', 'robust', 'robot'],
        answer: 'robot'),
    PhoneticQuestion(
        phonetic: '(mag´pī)',
        choices: ['magpie', 'magma', 'maypole'],
        answer: 'magpie'),
  ],
);

/// The pronunciation key shown at the top of the screen —
/// standard dictionary diacritic notation.
const List<List<String>> kPronunciationKey = [
  ['a', 'add'], ['ā', 'ace'], ['â', 'care'], ['ä', 'palm'],
  ['e', 'end'], ['ē', 'equal'], ['i', 'it'], ['ī', 'ice'],
  ['o', 'odd'], ['ō', 'open'], ['ô', 'order'], ['o͝o', 'took'],
  ['o͞o', 'pool'], ['u', 'up'], ['û', 'burn'], ['yo͞o', 'fuse'],
  ['oi', 'oil'],
];

const List<List<String>> kSchwaExamples = [
  ['a', 'above'], ['e', 'sicken'], ['i', 'possible'],
  ['o', 'melon'], ['u', 'circus'],
];
