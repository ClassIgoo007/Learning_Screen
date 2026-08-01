import 'dart:math';

/// Builds a square word-search grid with each word placed exactly once,
/// reading right or down. Filler letters fill unused cells.
class WordSearchBuilder {
  WordSearchBuilder({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Place [words] in a [size]×[size] grid. Throws if placement fails.
  List<String> build(List<String> words, {int size = 12, int attempts = 80}) {
    final normalized = [
      for (final w in words) w.trim().toUpperCase(),
    ];
    if (normalized.isEmpty) {
      throw ArgumentError('Need at least one word to build a word search.');
    }
    for (final w in normalized) {
      if (w.isEmpty || w.length > size) {
        throw ArgumentError(
            'Word "$w" must be 1–$size letters to fit a ${size}x$size grid.');
      }
      if (!RegExp(r'^[A-Z]+$').hasMatch(w)) {
        throw ArgumentError('Word "$w" must contain only A–Z letters.');
      }
    }

    for (var attempt = 0; attempt < attempts; attempt++) {
      final grid = List.generate(size, (_) => List.filled(size, ''));
      final ordered = [...normalized]
        ..sort((a, b) => b.length.compareTo(a.length));
      var ok = true;
      for (final word in ordered) {
        if (!_placeWord(grid, word)) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;

      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          if (grid[r][c].isEmpty) {
            grid[r][c] = String.fromCharCode(65 + _random.nextInt(26));
          }
        }
      }
      return [for (final row in grid) row.join()];
    }

    throw StateError(
        'Could not place ${normalized.length} words in a ${size}x$size grid.');
  }

  bool _placeWord(List<List<String>> grid, String word) {
    final size = grid.length;
    final dirs = <(int, int)>[(0, 1), (1, 0)]..shuffle(_random);
    final starts = <(int, int)>[
      for (var r = 0; r < size; r++)
        for (var c = 0; c < size; c++) (r, c),
    ]..shuffle(_random);

    for (final (dr, dc) in dirs) {
      for (final (r, c) in starts) {
        final er = r + dr * (word.length - 1);
        final ec = c + dc * (word.length - 1);
        if (er >= size || ec >= size) continue;
        if (!_fits(grid, word, r, c, dr, dc)) continue;
        for (var i = 0; i < word.length; i++) {
          grid[r + dr * i][c + dc * i] = word[i];
        }
        return true;
      }
    }
    return false;
  }

  bool _fits(
    List<List<String>> grid,
    String word,
    int r,
    int c,
    int dr,
    int dc,
  ) {
    for (var i = 0; i < word.length; i++) {
      final cell = grid[r + dr * i][c + dc * i];
      if (cell.isNotEmpty && cell != word[i]) return false;
    }
    return true;
  }
}
