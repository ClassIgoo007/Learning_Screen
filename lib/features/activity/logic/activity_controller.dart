import 'dart:math' show Point;

import 'package:flutter/foundation.dart';

import '../models/activity.dart';

enum BlankStatus { empty, filled, correct, wrong }

/// Game state for a vowel activity: which blanks hold which words,
/// which puzzle words have been found, and the in-progress grid selection.
class ActivityController extends ChangeNotifier {
  ActivityController(this.activity)
      : _placements = activity.findPlacements();

  final VowelActivity activity;
  final List<WordPlacement> _placements;

  final Map<int, String> _answers = {}; // sentence index -> chosen word
  final Set<String> _found = {}; // found puzzle words
  int? _activeSentence;
  Point<int>? _selectionStart;
  bool _checked = false;

  // ---------- getters ----------

  int? get activeSentence => _activeSentence;
  Point<int>? get selectionStart => _selectionStart;
  bool get checked => _checked;
  Set<String> get foundWords => Set.unmodifiable(_found);

  String? answerFor(int index) => _answers[index];

  bool isWordUsedInSentence(String word) => _answers.containsValue(word);
  bool isWordFound(String word) => _found.contains(word);

  BlankStatus blankStatus(int index) {
    final a = _answers[index];
    if (a == null) return BlankStatus.empty;
    if (!_checked) return BlankStatus.filled;
    return a == activity.sentences[index].answer
        ? BlankStatus.correct
        : BlankStatus.wrong;
  }

  /// Cells belonging to already-found words, for persistent highlighting.
  Set<Point<int>> get foundCells => {
        for (final p in _placements)
          if (_found.contains(p.word)) ...p.cells,
      };

  bool get sentencesComplete => activity.sentences.indexed
      .every((e) => _answers[e.$1] == e.$2.answer);
  bool get allWordsFound => _found.length == activity.words.length;
  bool get isComplete => sentencesComplete && allWordsFound;

  // ---------- sentences ----------

  void tapBlank(int index) {
    _activeSentence = _activeSentence == index ? null : index;
    notifyListeners();
  }

  /// Tap a word in the bank: fills the active blank (replacing any word).
  void tapBankWord(String word) {
    final i = _activeSentence;
    if (i == null) return;
    _checked = false;
    _answers.removeWhere((_, v) => v == word); // a word fits one blank
    _answers[i] = word;
    // Convenience: advance to the next empty blank.
    _activeSentence = _nextEmptyBlank(from: i);
    notifyListeners();
  }

  int? _nextEmptyBlank({required int from}) {
    final n = activity.sentences.length;
    for (var step = 1; step <= n; step++) {
      final i = (from + step) % n;
      if (!_answers.containsKey(i)) return i;
    }
    return null;
  }

  void clearBlank(int index) {
    _checked = false;
    _answers.remove(index);
    _activeSentence = index;
    notifyListeners();
  }

  void checkSentences() {
    _checked = true;
    notifyListeners();
  }

  // ---------- word search ----------

  /// Two-tap selection: first tap sets the start, second tap the end.
  /// If the straight-line run between them spells an unfound word
  /// (forwards or backwards), that word is marked found.
  void tapGridCell(Point<int> pos) {
    final start = _selectionStart;
    if (start == null) {
      _selectionStart = pos;
      notifyListeners();
      return;
    }
    if (start == pos) {
      _selectionStart = null; // tap again to cancel
      notifyListeners();
      return;
    }

    final cells = _lineBetween(start, pos);
    _selectionStart = null;
    if (cells != null) {
      final text = cells.map(activity.letterAt).join();
      final reversed = text.split('').reversed.join();
      for (final w in activity.words) {
        if (!_found.contains(w) && (w == text || w == reversed)) {
          _found.add(w);
          break;
        }
      }
    }
    notifyListeners();
  }

  /// Cells from a to b when they share a row or column; otherwise null.
  List<Point<int>>? _lineBetween(Point<int> a, Point<int> b) {
    if (a.x != b.x && a.y != b.y) return null;
    final dr = (b.x - a.x).sign;
    final dc = (b.y - a.y).sign;
    final len = (b.x - a.x).abs() + (b.y - a.y).abs() + 1;
    return List.generate(len, (i) => Point(a.x + dr * i, a.y + dc * i));
  }

  // ---------- actions ----------

  void reset() {
    _answers.clear();
    _found.clear();
    _activeSentence = null;
    _selectionStart = null;
    _checked = false;
    notifyListeners();
  }
}
