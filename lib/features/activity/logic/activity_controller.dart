import 'dart:math' show Point;

import 'package:flutter/foundation.dart';

import '../models/activity.dart';

enum BlankStatus { empty, filled, correct, wrong }

/// Game state for a vowel activity: which blanks hold which words,
/// which puzzle words have been found, and the in-progress grid selection.
class ActivityController extends ChangeNotifier {
  ActivityController(VowelActivity activity)
      : _activity = activity,
        _placements = activity.findPlacements();

  VowelActivity _activity;
  List<WordPlacement> _placements;

  final Map<int, String> _answers = {}; // sentence index -> chosen word
  final Set<String> _found = {}; // found puzzle words
  int? _activeSentence;
  Point<int>? _selectionAnchor;
  Point<int>? _selectionEnd;
  bool _checked = false;

  // ---------- getters ----------

  VowelActivity get activity => _activity;
  int? get activeSentence => _activeSentence;
  bool get checked => _checked;
  Set<String> get foundWords => Set.unmodifiable(_found);

  /// Live drag path (row/column only). Empty when not selecting.
  List<Point<int>> get selectionCells {
    final a = _selectionAnchor;
    final b = _selectionEnd;
    if (a == null) return const [];
    if (b == null) return [a];
    return _lineBetween(a, b);
  }

  /// Placements for words already found — used to draw continuous highlights.
  List<WordPlacement> get foundPlacements => [
        for (final p in _placements)
          if (_found.contains(p.word)) p,
      ];

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
        for (final p in foundPlacements) ...p.cells,
      };

  bool get sentencesComplete => activity.sentences.indexed
      .every((e) => _answers[e.$1] == e.$2.answer);
  bool get allWordsFound => _found.length == activity.words.length;
  bool get isComplete => sentencesComplete && allWordsFound;

  int get filledBlankCount => _answers.length;
  int get emptyBlankCount => activity.sentences.length - _answers.length;

  int get correctBlankCount {
    var n = 0;
    for (var i = 0; i < activity.sentences.length; i++) {
      if (_answers[i] == activity.sentences[i].answer) n++;
    }
    return n;
  }

  int get wrongBlankCount {
    var n = 0;
    for (var i = 0; i < activity.sentences.length; i++) {
      final a = _answers[i];
      if (a != null && a != activity.sentences[i].answer) n++;
    }
    return n;
  }

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

  /// Start a drag (or tap) on [pos].
  void beginGridSelect(Point<int> pos) {
    _selectionAnchor = pos;
    _selectionEnd = pos;
    notifyListeners();
  }

  /// Extend the selection toward [pos] (snaps to the same row or column).
  void updateGridSelect(Point<int> pos) {
    if (_selectionAnchor == null) return;
    _selectionEnd = pos;
    notifyListeners();
  }

  /// Finish the gesture: mark a matching word found, then clear the drag.
  void endGridSelect() {
    final cells = selectionCells;
    _selectionAnchor = null;
    _selectionEnd = null;
    if (cells.length >= 2) {
      _tryFindWord(cells);
    }
    notifyListeners();
  }

  void cancelGridSelect() {
    _selectionAnchor = null;
    _selectionEnd = null;
    notifyListeners();
  }

  /// Test helper: select the straight run from [a] to [b] in one shot.
  void selectWordRun(Point<int> a, Point<int> b) {
    beginGridSelect(a);
    updateGridSelect(b);
    endGridSelect();
  }

  void _tryFindWord(List<Point<int>> cells) {
    final text = cells.map(activity.letterAt).join();
    final reversed = text.split('').reversed.join();
    String? matched;
    for (final w in activity.words) {
      if (w == text || w == reversed) {
        matched = w;
        break;
      }
    }
    if (matched == null) return;

    _found.add(matched);
    _fillSentenceWithWord(matched);
  }

  /// Prefer the selected blank; otherwise fill the sentence that expects [word].
  void _fillSentenceWithWord(String word) {
    final active = _activeSentence;
    if (active != null) {
      _checked = false;
      _answers.removeWhere((_, v) => v == word);
      _answers[active] = word;
      _activeSentence = _nextEmptyBlank(from: active);
      return;
    }

    final matching = activity.sentences.indexWhere((s) => s.answer == word);
    if (matching >= 0 && !_answers.containsKey(matching)) {
      _checked = false;
      _answers[matching] = word;
    }
  }

  /// Cells from a to b on a shared row or column (diagonal drags snap).
  List<Point<int>> _lineBetween(Point<int> a, Point<int> b) {
    var end = b;
    if (a.x != b.x && a.y != b.y) {
      final rowSpan = (b.y - a.y).abs();
      final colSpan = (b.x - a.x).abs();
      if (rowSpan >= colSpan) {
        end = Point(a.x, b.y); // stay on start row
      } else {
        end = Point(b.x, a.y); // stay on start column
      }
    }
    final dr = (end.x - a.x).sign;
    final dc = (end.y - a.y).sign;
    final len = (end.x - a.x).abs() + (end.y - a.y).abs() + 1;
    return List.generate(len, (i) => Point(a.x + dr * i, a.y + dc * i));
  }

  // ---------- actions ----------

  /// Swap in a freshly generated activity (new words + sentences + grid).
  void replaceActivity(VowelActivity next) {
    _activity = next;
    _placements = next.findPlacements();
    reset();
  }

  void reset() {
    _answers.clear();
    _found.clear();
    _activeSentence = null;
    _selectionAnchor = null;
    _selectionEnd = null;
    _checked = false;
    notifyListeners();
  }
}
