import 'package:flutter/foundation.dart';

import '../models/content.dart';

/// State for the multiple-choice Q&A screen. Pure Dart, easily unit tested.
class QuizController extends ChangeNotifier {
  QuizController(this.questions);

  final List<QuizQuestion> questions;

  final Map<int, int> _selections = {}; // question index -> option index
  final Set<int> _revealed = {}; // questions already answered

  int get total => questions.length;
  int get answeredCount => _revealed.length;
  bool get isFinished => _revealed.length == questions.length;

  int? selectionFor(int index) => _selections[index];
  bool isRevealed(int index) => _revealed.contains(index);

  bool isCorrect(int index) =>
      _selections[index] == questions[index].answerIndex;

  int get score => _revealed.where(isCorrect).length;

  /// Choosing an option locks that question in and reveals the feedback.
  void select(int questionIndex, int optionIndex) {
    if (_revealed.contains(questionIndex)) return; // one attempt per question
    _selections[questionIndex] = optionIndex;
    _revealed.add(questionIndex);
    notifyListeners();
  }

  void reset() {
    _selections.clear();
    _revealed.clear();
    notifyListeners();
  }
}

/// State for the fill-in-the-blank screen. Answers are typed, so the
/// controller holds the raw text and grades it against accepted spellings.
class BlanksController extends ChangeNotifier {
  BlanksController(this.items);

  final List<BlankItem> items;

  final Map<int, String> _answers = {};
  final Set<int> _hintsShown = {};
  bool _checked = false;

  bool get checked => _checked;
  int get total => items.length;

  String answerFor(int index) => _answers[index] ?? '';
  bool isHintShown(int index) => _hintsShown.contains(index);

  bool isFilled(int index) => answerFor(index).trim().isNotEmpty;
  int get filledCount =>
      List.generate(items.length, (i) => i).where(isFilled).length;

  bool isCorrect(int index) => items[index].accepts(answerFor(index));
  int get score =>
      List.generate(items.length, (i) => i).where(isCorrect).length;

  bool get allCorrect => score == items.length;

  /// Typing clears the checked state so feedback never goes stale.
  void setAnswer(int index, String value) {
    _answers[index] = value;
    if (_checked) _checked = false;
    notifyListeners();
  }

  void toggleHint(int index) {
    if (!_hintsShown.remove(index)) _hintsShown.add(index);
    notifyListeners();
  }

  void check() {
    _checked = true;
    notifyListeners();
  }

  void revealAnswer(int index) {
    _answers[index] = items[index].answer;
    notifyListeners();
  }

  void reset() {
    _answers.clear();
    _hintsShown.clear();
    _checked = false;
    notifyListeners();
  }
}
