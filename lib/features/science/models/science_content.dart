import 'package:flutter/widgets.dart';

/// One multiple-choice question for the Q&A activity.
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

  /// Case-, space-, punctuation- and subscript-insensitive check, so "CO2",
  /// "co₂" and "carbon dioxide" can each be accepted where they mean the same.
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

/// The reading context for one activity: an optional passage plus a diagram
/// that can be zoomed. Topics with a single shared diagram (e.g. photosynthesis)
/// leave the passage fields null and rely on the topic intro instead.
class ReadingActivity {
  final String? passageTitle;
  final String? passageText;
  final String diagram; // asset path
  final String diagramCaption;

  const ReadingActivity({
    this.passageTitle,
    this.passageText,
    required this.diagram,
    required this.diagramCaption,
  });

  bool get hasPassage => passageText != null && passageText!.isNotEmpty;
}

/// A complete science reading-comprehension topic: an intro, two activities
/// (a multiple-choice quiz and a fill-in-the-blanks), and a vocabulary bank.
class ScienceTopic {
  final String id;
  final String title;
  final String tagline;
  final String intro;
  final String heroImage; // asset used on catalog cards + topic intro
  final Color accent;
  final ReadingActivity quiz;
  final ReadingActivity blanks;
  final List<QuizQuestion> questions;
  final List<BlankItem> blankItems;
  final List<String> wordBank;

  const ScienceTopic({
    required this.id,
    required this.title,
    required this.tagline,
    required this.intro,
    required this.heroImage,
    required this.accent,
    required this.quiz,
    required this.blanks,
    required this.questions,
    required this.blankItems,
    required this.wordBank,
  });
}
