import 'package:flutter/foundation.dart';

import '../models/content.dart';

/// State for the question screen. Pure Dart, so it is unit tested headlessly.
class QuizController extends ChangeNotifier {
  QuizController(List<QuizQuestion> questions)
      : _questions = List<QuizQuestion>.from(questions);

  List<QuizQuestion> _questions;

  List<QuizQuestion> get questions => _questions;

  final Map<int, int> _selections = {}; // question index -> option index
  final Set<int> _revealed = {};

  int get total => _questions.length;
  int get answeredCount => _revealed.length;
  bool get isFinished => _revealed.length == _questions.length;

  int? selectionFor(int i) => _selections[i];
  bool isRevealed(int i) => _revealed.contains(i);
  bool isCorrect(int i) => _selections[i] == _questions[i].answerIndex;
  int get score => _revealed.where(isCorrect).length;

  /// Choosing an option locks that question in and reveals the explanation.
  void select(int question, int option) {
    if (_revealed.contains(question)) return; // one attempt each
    _selections[question] = option;
    _revealed.add(question);
    notifyListeners();
  }

  void reset() {
    _selections.clear();
    _revealed.clear();
    notifyListeners();
  }

  /// Swap in a new AI-generated question set and clear progress.
  void replaceQuestions(List<QuizQuestion> questions) {
    _questions = List<QuizQuestion>.from(questions);
    reset();
  }
}
