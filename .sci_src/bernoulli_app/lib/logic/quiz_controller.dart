import 'package:flutter/foundation.dart';

import '../models/content.dart';

/// State for the question screen. Pure Dart, so it is unit tested headlessly.
class QuizController extends ChangeNotifier {
  QuizController(this.questions);

  final List<QuizQuestion> questions;

  final Map<int, int> _selections = {}; // question index -> option index
  final Set<int> _revealed = {};

  int get total => questions.length;
  int get answeredCount => _revealed.length;
  bool get isFinished => _revealed.length == questions.length;

  int? selectionFor(int i) => _selections[i];
  bool isRevealed(int i) => _revealed.contains(i);
  bool isCorrect(int i) => _selections[i] == questions[i].answerIndex;
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
}
