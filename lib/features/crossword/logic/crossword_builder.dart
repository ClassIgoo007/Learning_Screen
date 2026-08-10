import 'dart:math';

import '../models/crossword.dart';

/// Places phonics words into a sparse crossword with letter intersections.
class CrosswordBuilder {
  CrosswordBuilder({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Build a puzzle from [words] + matching [clues] (same order).
  /// Keeps branding from [seed]. Throws if placement fails.
  CrosswordPuzzle build({
    required CrosswordPuzzle seed,
    required List<String> words,
    required List<String> clues,
    int attempts = 80,
  }) {
    if (words.length != clues.length || words.isEmpty) {
      throw ArgumentError('Need matching non-empty words and clues.');
    }

    final clueByWord = <String, String>{};
    final normalized = <String>[];
    for (var i = 0; i < words.length; i++) {
      final w = words[i].trim().toUpperCase();
      if (w.length < 3 || w.length > 10 || !RegExp(r'^[A-Z]+$').hasMatch(w)) {
        throw ArgumentError('Invalid crossword word: $w');
      }
      if (clueByWord.containsKey(w)) {
        throw ArgumentError('Duplicate crossword word: $w');
      }
      clueByWord[w] = clues[i].trim().isEmpty ? 'A $w word' : clues[i].trim();
      normalized.add(w);
    }

    Object? lastError;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        final placed = _placeAll(normalized);
        final entries = _toNumberedEntries(placed, clueByWord);
        final bounds = _bounds(entries);
        final shifted = [
          for (final e in entries)
            CrosswordEntry(
              number: e.number,
              direction: e.direction,
              row: e.row - bounds.minRow,
              col: e.col - bounds.minCol,
              answer: e.answer,
              clue: e.clue,
            ),
        ];
        return CrosswordPuzzle.fromGenerated(
          seed: seed,
          rows: bounds.maxRow - bounds.minRow + 1,
          cols: bounds.maxCol - bounds.minCol + 1,
          entries: shifted,
        );
      } catch (e) {
        lastError = e;
      }
    }
    throw StateError(
        'Could not build a crossword from ${normalized.length} words: '
        '${lastError ?? 'unknown'}');
  }

  List<_PlacedWord> _placeAll(List<String> words) {
    final ordered = [...words]..sort((a, b) => b.length.compareTo(a.length));
    // Light shuffle among equal lengths.
    ordered.shuffle(_random);

    final grid = <Point<int>, String>{};
    final placed = <_PlacedWord>[];

    final first = ordered.first;
    _commit(grid, placed, _PlacedWord(first, 0, 0, Direction.across));

    for (final word in ordered.skip(1)) {
      final options = _candidatePlacements(grid, placed, word);
      if (options.isEmpty) throw StateError('No placement for $word');
      options.sort((a, b) => b.score.compareTo(a.score));
      final top = options.take(min(16, options.length)).toList()
        ..shuffle(_random);
      var ok = false;
      for (final opt in top) {
        if (_fits(grid, opt.word, opt.row, opt.col, opt.direction)) {
          _commit(grid, placed, opt);
          ok = true;
          break;
        }
      }
      if (!ok) throw StateError('Could not fit $word');
    }

    if (placed.length > 1 && _intersectionCount(placed) < 1) {
      throw StateError('Not enough intersections');
    }
    return placed;
  }

  List<_PlacedWord> _candidatePlacements(
    Map<Point<int>, String> grid,
    List<_PlacedWord> placed,
    String word,
  ) {
    final options = <_PlacedWord>[];
    for (final existing in placed) {
      for (var i = 0; i < existing.word.length; i++) {
        final letter = existing.word[i];
        for (var j = 0; j < word.length; j++) {
          if (word[j] != letter) continue;
          if (existing.direction == Direction.across) {
            final row = existing.row - j;
            final col = existing.col + i;
            if (_fits(grid, word, row, col, Direction.down)) {
              options.add(_PlacedWord(
                word,
                row,
                col,
                Direction.down,
                score: _scoreFit(grid, word, row, col, Direction.down),
              ));
            }
          } else {
            final row = existing.row + i;
            final col = existing.col - j;
            if (_fits(grid, word, row, col, Direction.across)) {
              options.add(_PlacedWord(
                word,
                row,
                col,
                Direction.across,
                score: _scoreFit(grid, word, row, col, Direction.across),
              ));
            }
          }
        }
      }
    }
    return options;
  }

  bool _fits(
    Map<Point<int>, String> grid,
    String word,
    int row,
    int col,
    Direction dir,
  ) {
    var intersections = 0;
    for (var i = 0; i < word.length; i++) {
      final r = dir == Direction.across ? row : row + i;
      final c = dir == Direction.across ? col + i : col;
      final existing = grid[Point(r, c)];
      if (existing != null) {
        if (existing != word[i]) return false;
        intersections++;
      }
    }

    // Open ends must not continue into another letter.
    if (dir == Direction.across) {
      if (grid[Point(row, col - 1)] != null) return false;
      if (grid[Point(row, col + word.length)] != null) return false;
    } else {
      if (grid[Point(row - 1, col)] != null) return false;
      if (grid[Point(row + word.length, col)] != null) return false;
    }

    if (grid.isNotEmpty && intersections == 0) return false;
    return true;
  }

  int _scoreFit(
    Map<Point<int>, String> grid,
    String word,
    int row,
    int col,
    Direction dir,
  ) {
    var score = 0;
    for (var i = 0; i < word.length; i++) {
      final r = dir == Direction.across ? row : row + i;
      final c = dir == Direction.across ? col + i : col;
      if (grid[Point(r, c)] == word[i]) score += 3;
    }
    return score;
  }

  void _commit(
    Map<Point<int>, String> grid,
    List<_PlacedWord> placed,
    _PlacedWord word,
  ) {
    for (var i = 0; i < word.word.length; i++) {
      final r = word.direction == Direction.across ? word.row : word.row + i;
      final c = word.direction == Direction.across ? word.col + i : word.col;
      grid[Point(r, c)] = word.word[i];
    }
    placed.add(word);
  }

  int _intersectionCount(List<_PlacedWord> placed) {
    final cells = <Point<int>, int>{};
    for (final w in placed) {
      for (var i = 0; i < w.word.length; i++) {
        final r = w.direction == Direction.across ? w.row : w.row + i;
        final c = w.direction == Direction.across ? w.col + i : w.col;
        final p = Point(r, c);
        cells[p] = (cells[p] ?? 0) + 1;
      }
    }
    return cells.values.where((n) => n > 1).length;
  }

  List<CrosswordEntry> _toNumberedEntries(
    List<_PlacedWord> placed,
    Map<String, String> clueByWord,
  ) {
    final starts = <Point<int>, int>{};
    var nextNumber = 1;

    // Number starts top-to-bottom, left-to-right.
    final sorted = [...placed]..sort((a, b) {
        final row = a.row.compareTo(b.row);
        if (row != 0) return row;
        return a.col.compareTo(b.col);
      });

    final entries = <CrosswordEntry>[];
    for (final w in sorted) {
      final start = Point(w.row, w.col);
      final number = starts.putIfAbsent(start, () => nextNumber++);
      entries.add(CrosswordEntry(
        number: number,
        direction: w.direction,
        row: w.row,
        col: w.col,
        answer: w.word,
        clue: clueByWord[w.word] ?? w.word,
      ));
    }
    return entries;
  }

  ({int minRow, int minCol, int maxRow, int maxCol}) _bounds(
    List<CrosswordEntry> entries,
  ) {
    var minRow = entries.first.row;
    var minCol = entries.first.col;
    var maxRow = entries.first.row;
    var maxCol = entries.first.col;
    for (final e in entries) {
      for (final p in e.cells) {
        if (p.x < minRow) minRow = p.x;
        if (p.y < minCol) minCol = p.y;
        if (p.x > maxRow) maxRow = p.x;
        if (p.y > maxCol) maxCol = p.y;
      }
    }
    return (
      minRow: minRow,
      minCol: minCol,
      maxRow: maxRow,
      maxCol: maxCol,
    );
  }
}

class _PlacedWord {
  _PlacedWord(this.word, this.row, this.col, this.direction, {this.score = 0});

  final String word;
  final int row;
  final int col;
  final Direction direction;
  final int score;
}
