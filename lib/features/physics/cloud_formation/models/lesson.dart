import 'package:flutter/foundation.dart';

/// A block of reading the questions are drawn from.
@immutable
class Passage {
  const Passage({
    required this.title,
    required this.figureCaption,
    required this.body,
  });

  final String title;
  final String figureCaption;
  final String body;

  factory Passage.fromJson(Map<String, dynamic> json) => Passage(
        title: json['title'] as String,
        figureCaption: json['figure_caption'] as String? ?? '',
        body: json['body'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'figure_caption': figureCaption,
        'body': body,
      };
}

/// One multiple-choice item. [beat] joins the question back to the stage of the
/// cloud-formation sequence it tests, so a future animation screen can jump to
/// the matching frame.
@immutable
class ChoiceQuestion {
  const ChoiceQuestion({
    required this.beat,
    required this.topic,
    required this.prompt,
    required this.choices,
    required this.answer,
  });

  final int beat;
  final String topic;
  final String prompt;
  final List<String> choices;
  final String answer;

  bool isCorrect(String? selected) => selected != null && selected == answer;

  factory ChoiceQuestion.fromJson(Map<String, dynamic> json) => ChoiceQuestion(
        beat: json['beat'] as int,
        topic: json['topic'] as String,
        prompt: json['question'] as String,
        choices: (json['choices'] as List).cast<String>(),
        answer: json['answer'] as String,
      );

  Map<String, dynamic> toJson() => {
        'beat': beat,
        'topic': topic,
        'question': prompt,
        'choices': choices,
        'answer': answer,
      };
}

/// A sentence with one word removed. [before] and [after] are the text either
/// side of the blank the student types into.
@immutable
class ClozeSentence {
  const ClozeSentence({
    required this.beat,
    required this.before,
    required this.after,
    required this.answer,
    this.alsoAccept = const <String>[],
    this.hint,
  });

  final int beat;
  final String before;
  final String after;
  final String answer;
  final List<String> alsoAccept;
  final String? hint;

  /// Marking is case-insensitive and forgiving of surrounding whitespace and a
  /// trailing full stop, so a right answer is never failed on typography.
  bool isCorrect(String input) {
    final cleaned = _normalise(input);
    if (cleaned.isEmpty) return false;
    return cleaned == _normalise(answer) ||
        alsoAccept.any((a) => _normalise(a) == cleaned);
  }

  static String _normalise(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[.,;:!?]+$'), '');

  factory ClozeSentence.fromJson(Map<String, dynamic> json) => ClozeSentence(
        beat: json['beat'] as int,
        before: json['before'] as String,
        after: json['after'] as String,
        answer: json['answer'] as String,
        alsoAccept:
            (json['also_accept'] as List?)?.cast<String>() ?? const <String>[],
        hint: json['hint'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'beat': beat,
        'before': before,
        'after': after,
        'answer': answer,
        'also_accept': alsoAccept,
        'hint': hint,
      };
}

/// The whole worksheet: two passages, one question set each.
@immutable
class Lesson {
  const Lesson({
    required this.passageOne,
    required this.choiceQuestions,
    required this.passageTwo,
    required this.clozeSentences,
  });

  final Passage passageOne;
  final List<ChoiceQuestion> choiceQuestions;
  final Passage passageTwo;
  final List<ClozeSentence> clozeSentences;
}
