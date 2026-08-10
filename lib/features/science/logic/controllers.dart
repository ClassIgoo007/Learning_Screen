import 'package:flutter/foundation.dart';

import '../models/science_content.dart';

/// State for the multiple-choice Q&A screen.
/// Learners select options first, then press Check to grade.
class QuizController extends ChangeNotifier {
  QuizController(List<QuizQuestion> questions)
      : _questions = List<QuizQuestion>.from(questions);

  List<QuizQuestion> _questions;
  final Map<int, int> _selections = {}; // question index -> option index
  bool _checked = false;

  List<QuizQuestion> get questions => _questions;
  int get total => _questions.length;
  bool get checked => _checked;

  int get selectedCount => _selections.length;
  bool get isFinished => _checked;

  int? selectionFor(int index) => _selections[index];
  bool isSelected(int index) => _selections.containsKey(index);

  /// Feedback is only shown after Check.
  bool isRevealed(int index) => _checked && _selections.containsKey(index);

  bool isCorrect(int index) =>
      _selections[index] == _questions[index].answerIndex;

  int get score => _checked
      ? List.generate(total, (i) => i)
          .where((i) => isSelected(i) && isCorrect(i))
          .length
      : 0;

  int get wrongCount => _checked
      ? List.generate(total, (i) => i)
          .where((i) => isSelected(i) && !isCorrect(i))
          .length
      : 0;

  /// Choosing an option does not grade yet — just records the pick.
  /// Changing a pick after Check clears the graded state.
  void select(int questionIndex, int optionIndex) {
    if (_checked) _checked = false;
    _selections[questionIndex] = optionIndex;
    notifyListeners();
  }

  void check() {
    _checked = true;
    notifyListeners();
  }

  /// Swap in a new AI-generated question set and clear progress.
  void replaceQuestions(List<QuizQuestion> questions) {
    _questions = List<QuizQuestion>.from(questions);
    reset();
  }

  void reset() {
    _selections.clear();
    _checked = false;
    notifyListeners();
  }
}

/// State for the fill-in-the-blank screen. Answers are typed, so the
/// controller holds the raw text and grades it against accepted spellings.
class BlanksController extends ChangeNotifier {
  BlanksController(List<BlankItem> items)
      : _items = List<BlankItem>.from(items);

  List<BlankItem> _items;
  final Map<int, String> _answers = {};
  final Set<int> _hintsShown = {};
  bool _checked = false;

  List<BlankItem> get items => _items;
  bool get checked => _checked;
  int get total => _items.length;

  String answerFor(int index) => _answers[index] ?? '';
  bool isHintShown(int index) => _hintsShown.contains(index);

  bool isFilled(int index) => answerFor(index).trim().isNotEmpty;
  int get filledCount =>
      List.generate(items.length, (i) => i).where(isFilled).length;

  bool isCorrect(int index) => items[index].accepts(answerFor(index));
  int get score =>
      List.generate(items.length, (i) => i)
          .where((i) => isFilled(i) && isCorrect(i))
          .length;

  int get wrongCount => _checked
      ? List.generate(items.length, (i) => i)
          .where((i) => isFilled(i) && !isCorrect(i))
          .length
      : 0;

  bool get allCorrect => filledCount == items.length && score == items.length;

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

  /// Swap in a new AI-generated blank set and clear progress.
  void replaceItems(List<BlankItem> items) {
    _items = List<BlankItem>.from(items);
    reset();
  }

  void reset() {
    _answers.clear();
    _hintsShown.clear();
    _checked = false;
    notifyListeners();
  }
}
