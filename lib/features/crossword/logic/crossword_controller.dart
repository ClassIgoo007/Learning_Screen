import 'dart:math' show Point;

import 'package:flutter/foundation.dart';

import '../models/crossword.dart';

enum CellStatus { empty, filled, correct, wrong }

/// All interactive state for one puzzle: user letters, current selection,
/// cursor position, and sticky check-answer marks.
class CrosswordController extends ChangeNotifier {
  CrosswordController(this._puzzle);

  CrosswordPuzzle _puzzle;
  CrosswordPuzzle get puzzle => _puzzle;

  final Map<Point<int>, String> _letters = {};
  /// Sticky grades from the last Check. Cleared per-cell only when that
  /// cell's letter is edited — so wrong marks stay until the learner fixes them.
  final Map<Point<int>, CellStatus> _marks = {};
  CrosswordEntry? _selected;
  int _cursor = 0;
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
    return _marks[pos] ?? CellStatus.filled;
  }

  /// True once every cell of [entry] is filled with the right letter.
  bool isEntrySolved(CrosswordEntry entry) {
    for (var i = 0; i < entry.length; i++) {
      if (_letters[entry.cells[i]] != entry.answer[i]) return false;
    }
    return true;
  }

  /// Entry was checked and still has at least one wrong letter marked.
  bool isEntryWrong(CrosswordEntry entry) {
    if (isEntrySolved(entry)) return false;
    return entry.cells.any((c) => _marks[c] == CellStatus.wrong);
  }

  bool get isPuzzleSolved => puzzle.entries.every(isEntrySolved);

  int get filledCells =>
      _letters.values.where((l) => l.isNotEmpty).length;

  int get wrongFilledCells =>
      _marks.values.where((s) => s == CellStatus.wrong).length;

  int get correctFilledCells =>
      _marks.values.where((s) => s == CellStatus.correct).length;

  int get wrongEntryCount =>
      puzzle.entries.where(isEntryWrong).length;

  int get totalCells {
    final cells = <Point<int>>{};
    for (final e in puzzle.entries) {
      cells.addAll(e.cells);
    }
    return cells.length;
  }

  // ---------- selection ----------

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
    final pos = entry.cells[_cursor];
    _marks.remove(pos); // only this cell loses its wrong/correct mark
    _letters[pos] = letter.toUpperCase();
    if (_cursor < entry.length - 1) _cursor++;
    notifyListeners();
  }

  void backspace() {
    final entry = _selected;
    if (entry == null) return;
    final pos = entry.cells[_cursor];
    if ((_letters[pos] ?? '').isNotEmpty) {
      _letters.remove(pos);
      _marks.remove(pos);
    } else if (_cursor > 0) {
      _cursor--;
      final prev = entry.cells[_cursor];
      _letters.remove(prev);
      _marks.remove(prev);
    }
    notifyListeners();
  }

  // ---------- actions ----------

  void checkAnswers() {
    _marks.clear();
    for (final entry in _letters.entries) {
      if (entry.value.isEmpty) continue;
      final solution = puzzle.solutionAt(entry.key);
      _marks[entry.key] = entry.value == solution
          ? CellStatus.correct
          : CellStatus.wrong;
    }
    _checked = true;
    notifyListeners();
  }

  void revealSelectedWord() {
    final entry = _selected;
    if (entry == null) return;
    for (var i = 0; i < entry.length; i++) {
      final pos = entry.cells[i];
      _letters[pos] = entry.answer[i];
      _marks[pos] = CellStatus.correct;
    }
    notifyListeners();
  }

  /// Swap in a new puzzle (new words/grid or clue-only refresh).
  void replacePuzzle(CrosswordPuzzle next, {bool keepProgress = false}) {
    _puzzle = next;
    if (!keepProgress) {
      _letters.clear();
      _marks.clear();
      _selected = null;
      _cursor = 0;
      _checked = false;
    } else {
      // Remap selection to the matching entry in the new puzzle.
      final prev = _selected;
      if (prev != null) {
        _selected = next.entries.cast<CrosswordEntry?>().firstWhere(
              (e) =>
                  e!.number == prev.number &&
                  e.direction == prev.direction &&
                  e.row == prev.row &&
                  e.col == prev.col,
              orElse: () => null,
            );
      }
    }
    notifyListeners();
  }

  void reset() {
    _letters.clear();
    _marks.clear();
    _selected = null;
    _cursor = 0;
    _checked = false;
    notifyListeners();
  }
}
