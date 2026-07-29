import 'dart:math' show Point;

import 'package:flutter/foundation.dart';

import '../models/crossword.dart';

enum CellStatus { empty, filled, correct, wrong }

/// All interactive state for one puzzle: user letters, current selection,
/// cursor position, and check-answers results. Pure Dart — easily unit tested.
class CrosswordController extends ChangeNotifier {
  CrosswordController(this.puzzle);

  final CrosswordPuzzle puzzle;

  final Map<Point<int>, String> _letters = {};
  CrosswordEntry? _selected;
  int _cursor = 0; // index within the selected entry
  bool _checked = false;

  // ---------- getters ----------

  CrosswordEntry? get selected => _selected;
  bool get checked => _checked;

  Point<int>? get cursorCell =>
      _selected == null ? null : _selected!.cells[_cursor];

  String letterAt(Point<int> pos) => _letters[pos] ?? '';

  bool isInSelectedWord(Point<int> pos) =>
      _selected != null && _selected!.contains(pos);

  CellStatus statusAt(Point<int> pos) {
    final letter = _letters[pos];
    if (letter == null || letter.isEmpty) return CellStatus.empty;
    if (!_checked) return CellStatus.filled;
    return letter == puzzle.solutionAt(pos)
        ? CellStatus.correct
        : CellStatus.wrong;
  }

  /// True once every cell of [entry] is filled with the right letter.
  bool isEntrySolved(CrosswordEntry entry) {
    for (var i = 0; i < entry.length; i++) {
      if (_letters[entry.cells[i]] != entry.answer[i]) return false;
    }
    return true;
  }

  bool get isPuzzleSolved => puzzle.entries.every(isEntrySolved);

  int get filledCells =>
      _letters.values.where((l) => l.isNotEmpty).length;

  int get totalCells {
    final cells = <Point<int>>{};
    for (final e in puzzle.entries) {
      cells.addAll(e.cells);
    }
    return cells.length;
  }

  // ---------- selection ----------

  /// Tap a cell: select the entry through it. Tapping again toggles
  /// between the across and down entries when the cell is shared.
  void tapCell(Point<int> pos) {
    final candidates = puzzle.entriesAt(pos);
    if (candidates.isEmpty) return;

    CrosswordEntry next;
    if (candidates.length > 1 &&
        _selected != null &&
        candidates.contains(_selected)) {
      next = candidates[
          (candidates.indexOf(_selected!) + 1) % candidates.length];
    } else {
      next = candidates.first;
    }
    _selected = next;
    _cursor = next.cells.indexOf(pos);
    notifyListeners();
  }

  void selectEntry(CrosswordEntry entry) {
    _selected = entry;
    // Jump to first empty cell of the word (or its start when full).
    _cursor = entry.cells
        .indexWhere((c) => (_letters[c] ?? '').isEmpty)
        .clamp(0, entry.length - 1);
    if (_cursor < 0) _cursor = 0;
    notifyListeners();
  }

  // ---------- input ----------

  void typeLetter(String letter) {
    final entry = _selected;
    if (entry == null) return;
    _checked = false;
    _letters[entry.cells[_cursor]] = letter.toUpperCase();
    if (_cursor < entry.length - 1) _cursor++;
    notifyListeners();
  }

  void backspace() {
    final entry = _selected;
    if (entry == null) return;
    _checked = false;
    final pos = entry.cells[_cursor];
    if ((_letters[pos] ?? '').isNotEmpty) {
      _letters.remove(pos);
    } else if (_cursor > 0) {
      _cursor--;
      _letters.remove(entry.cells[_cursor]);
    }
    notifyListeners();
  }

  // ---------- actions ----------

  void checkAnswers() {
    _checked = true;
    notifyListeners();
  }

  void revealSelectedWord() {
    final entry = _selected;
    if (entry == null) return;
    for (var i = 0; i < entry.length; i++) {
      _letters[entry.cells[i]] = entry.answer[i];
    }
    notifyListeners();
  }

  void reset() {
    _letters.clear();
    _selected = null;
    _cursor = 0;
    _checked = false;
    notifyListeners();
  }
}
