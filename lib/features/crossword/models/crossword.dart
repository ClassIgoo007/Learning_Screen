import 'dart:math' show Point;

enum Direction { across, down }

/// One word in the puzzle: its number, direction, start cell, answer and clue.
class CrosswordEntry {
  final int number;
  final Direction direction;
  final int row;
  final int col;
  final String answer; // uppercase A-Z
  final String clue;

  const CrosswordEntry({
    required this.number,
    required this.direction,
    required this.row,
    required this.col,
    required this.answer,
    required this.clue,
  });

  int get length => answer.length;

  /// All grid cells this entry occupies, in order.
  List<Point<int>> get cells => List.generate(
        length,
        (i) => direction == Direction.across
            ? Point(row, col + i)
            : Point(row + i, col),
      );

  bool contains(Point<int> pos) => cells.contains(pos);
}

class CrosswordPuzzle {
  final String title;
  final String subtitle;
  final int rows;
  final int cols;
  final List<CrosswordEntry> entries;

  /// Hero illustration asset shown on the intro + play screens.
  final String image;

  /// Short vowel/sound name used in headings, e.g. 'Long a', 'oi & oy'.
  final String name;

  /// One-line tagline shown under the intro heading.
  final String tagline;

  const CrosswordPuzzle({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.cols,
    required this.entries,
    required this.image,
    required this.name,
    required this.tagline,
  });

  /// Number of words to solve.
  int get wordCount => entries.length;

  /// Solution letter for a cell, or null if the cell is not part of any word.
  String? solutionAt(Point<int> pos) {
    for (final e in entries) {
      final i = e.cells.indexOf(pos);
      if (i != -1) return e.answer[i];
    }
    return null;
  }

  /// Number label to draw in a cell, if any entry starts there.
  int? numberAt(Point<int> pos) {
    for (final e in entries) {
      if (e.row == pos.x && e.col == pos.y) return e.number;
    }
    return null;
  }

  List<CrosswordEntry> entriesAt(Point<int> pos) =>
      entries.where((e) => e.contains(pos)).toList();

  List<CrosswordEntry> get across =>
      entries.where((e) => e.direction == Direction.across).toList();
  List<CrosswordEntry> get down =>
      entries.where((e) => e.direction == Direction.down).toList();

  /// Word bank, alphabetized.
  List<String> get wordBank =>
      (entries.map((e) => e.answer).toList()..sort());
}

/// Original "Words with Long a" puzzle (grid design validated: every
/// contiguous run of letters spells exactly one intended word).
const CrosswordPuzzle kLongAPuzzle = CrosswordPuzzle(
  title: 'Words with Long a',
  subtitle: 'Long a words may be spelled a_e, ai, or ay. '
      'Tap a clue, then type the word into the puzzle.',
  image: 'assets/cat_birds.png',
  name: 'Long a',
  tagline: 'Read the clues and fill the grid with long-a words',
  rows: 12,
  cols: 12,
  entries: [
    CrosswordEntry(
        number: 1, direction: Direction.across, row: 0, col: 2,
        answer: 'PAINT', clue: 'colored liquid used with a brush'),
    CrosswordEntry(
        number: 2, direction: Direction.down, row: 0, col: 5,
        answer: 'NAME', clue: 'what people call you'),
    CrosswordEntry(
        number: 3, direction: Direction.across, row: 2, col: 5,
        answer: 'MISTAKE', clue: 'an error'),
    CrosswordEntry(
        number: 4, direction: Direction.down, row: 2, col: 8,
        answer: 'TRAIL', clue: 'a path through the woods'),
    CrosswordEntry(
        number: 5, direction: Direction.across, row: 4, col: 6,
        answer: 'WHALE', clue: 'the largest animal in the ocean'),
    CrosswordEntry(
        number: 5, direction: Direction.down, row: 4, col: 6,
        answer: 'WAVE', clue: 'moving water, or a hand hello'),
    CrosswordEntry(
        number: 6, direction: Direction.across, row: 7, col: 2,
        answer: 'PLACE', clue: 'a spot or location'),
    CrosswordEntry(
        number: 6, direction: Direction.down, row: 7, col: 2,
        answer: 'PLAIN', clue: 'simple, not fancy'),
    CrosswordEntry(
        number: 7, direction: Direction.across, row: 9, col: 0,
        answer: 'BRAIN', clue: 'the organ you think with'),
  ],
);

/// "Words with Long o" puzzle (grid design machine-validated).
const CrosswordPuzzle kLongOPuzzle = CrosswordPuzzle(
  title: 'Words with Long o',
  subtitle: 'Long o words may be spelled o, o_e, or oa. '
      'Tap a clue, then type the word into the puzzle. '
      'Float through it like an astronaut!',
  image: 'assets/astronaut.png',
  name: 'Long o',
  tagline: 'Read the clues and float the long-o words into the grid',
  rows: 11,
  cols: 8,
  entries: [
    CrosswordEntry(
        number: 1, direction: Direction.across, row: 0, col: 2,
        answer: 'ROBOT', clue: 'a machine that can move and work'),
    CrosswordEntry(
        number: 1, direction: Direction.down, row: 0, col: 2,
        answer: 'ROAD', clue: 'cars and trucks drive on it'),
    CrosswordEntry(
        number: 2, direction: Direction.down, row: 0, col: 5,
        answer: 'OBEY', clue: 'to follow the rules'),
    CrosswordEntry(
        number: 3, direction: Direction.across, row: 2, col: 0,
        answer: 'BOAT', clue: 'it carries people across water'),
    CrosswordEntry(
        number: 3, direction: Direction.down, row: 2, col: 0,
        answer: 'BONE', clue: 'one part of your skeleton'),
    CrosswordEntry(
        number: 4, direction: Direction.across, row: 5, col: 0,
        answer: 'ECHO', clue: 'a sound that bounces back to you'),
    CrosswordEntry(
        number: 5, direction: Direction.down, row: 5, col: 3,
        answer: 'OCEAN', clue: 'salty water that covers most of Earth'),
    CrosswordEntry(
        number: 6, direction: Direction.across, row: 6, col: 3,
        answer: 'COAST', clue: 'land right beside the sea'),
    CrosswordEntry(
        number: 7, direction: Direction.down, row: 6, col: 6,
        answer: 'STONE', clue: 'a small piece of rock'),
    CrosswordEntry(
        number: 8, direction: Direction.across, row: 8, col: 0,
        answer: 'FLOAT', clue: 'to drift in air or water, like an astronaut'),
  ],
);

/// "Words with Long i" puzzle. Clues are fill-in-the-blank sentences.
const CrosswordPuzzle kLongIPuzzle = CrosswordPuzzle(
  title: 'Words with Long i',
  subtitle: 'Long i words may be spelled i, i_e, or y. '
      'Read each sentence, then type the missing word into the puzzle.',
  image: 'assets/longi_hero.png',
  name: 'Long i',
  tagline: 'Finish each sentence, then write the word in the grid',
  rows: 11,
  cols: 10,
  entries: [
    CrosswordEntry(
        number: 1, direction: Direction.across, row: 0, col: 0,
        answer: 'PILOT',
        clue: 'The ___ flew our plane above the clouds.'),
    CrosswordEntry(
        number: 1, direction: Direction.down, row: 0, col: 0,
        answer: 'PRIZE',
        clue: 'The contest winner took home a shiny ___.'),
    CrosswordEntry(
        number: 2, direction: Direction.down, row: 0, col: 4,
        answer: 'TIGER',
        clue: 'A ___ has orange fur and black stripes.'),
    CrosswordEntry(
        number: 3, direction: Direction.across, row: 2, col: 0,
        answer: 'ICY',
        clue: 'The sidewalk was ___ after the winter storm.'),
    CrosswordEntry(
        number: 4, direction: Direction.across, row: 2, col: 4,
        answer: 'GIANT',
        clue: 'A ___ redwood tree towers over the forest.'),
    CrosswordEntry(
        number: 5, direction: Direction.down, row: 2, col: 8,
        answer: 'TIME',
        clue: 'A clock tells us the ___.'),
    CrosswordEntry(
        number: 6, direction: Direction.across, row: 5, col: 5,
        answer: 'NINE',
        clue: 'The number that comes after eight is ___.'),
    CrosswordEntry(
        number: 6, direction: Direction.down, row: 5, col: 5,
        answer: 'NICE',
        clue: 'It is ___ to share your toys with friends.'),
    CrosswordEntry(
        number: 7, direction: Direction.across, row: 7, col: 5,
        answer: 'CHILD',
        clue: 'Every ___ in class got a new pencil.'),
    CrosswordEntry(
        number: 8, direction: Direction.down, row: 7, col: 9,
        answer: 'DIVE',
        clue: 'Penguins ___ into the sea to catch fish.'),
    CrosswordEntry(
        number: 9, direction: Direction.across, row: 10, col: 5,
        answer: 'WHITE',
        clue: "An astronaut's space suit is bright ___."),
  ],
);

/// "Words with oi and oy" puzzle. Clues are fill-in-the-blank sentences.
const CrosswordPuzzle kOiOyPuzzle = CrosswordPuzzle(
  title: 'Words with oi and oy',
  subtitle: "These words all share the vowel sound in 'boy'. "
      'That sound may be spelled oi or oy. '
      'Read each sentence, then type the missing word into the puzzle.',
  image: 'assets/oioy_hero.png',
  name: 'oi & oy',
  tagline: "Finish each sentence with an 'oi' or 'oy' word",
  rows: 13,
  cols: 11,
  entries: [
    CrosswordEntry(
        number: 1, direction: Direction.across, row: 0, col: 0,
        answer: 'VOYAGE',
        clue: "The ship's ___ across the sea took nine days."),
    CrosswordEntry(
        number: 1, direction: Direction.down, row: 0, col: 0,
        answer: 'VOICE',
        clue: 'The singer has a beautiful ___.'),
    CrosswordEntry(
        number: 2, direction: Direction.down, row: 0, col: 5,
        answer: 'ENJOY',
        clue: 'Did you ___ the fireworks show?'),
    CrosswordEntry(
        number: 3, direction: Direction.across, row: 2, col: 5,
        answer: 'JOY',
        clue: 'The puppy jumped for ___ when we came home.'),
    CrosswordEntry(
        number: 4, direction: Direction.across, row: 3, col: 0,
        answer: 'COIN',
        clue: 'I found a shiny ___ under the couch.'),
    CrosswordEntry(
        number: 5, direction: Direction.down, row: 3, col: 3,
        answer: 'NOISE',
        clue: 'A loud ___ came from the busy street.'),
    CrosswordEntry(
        number: 6, direction: Direction.across, row: 6, col: 3,
        answer: 'SOIL',
        clue: 'Plant the seeds in soft, dark ___.'),
    CrosswordEntry(
        number: 7, direction: Direction.down, row: 6, col: 6,
        answer: 'LOYAL',
        clue: 'A dog is a ___ friend who stays by your side.'),
    CrosswordEntry(
        number: 8, direction: Direction.across, row: 8, col: 5,
        answer: 'OYSTER',
        clue: 'An ___ can make a pearl inside its shell.'),
    CrosswordEntry(
        number: 9, direction: Direction.down, row: 8, col: 8,
        answer: 'TOY',
        clue: "The baby's favorite ___ is a soft bear."),
    CrosswordEntry(
        number: 10, direction: Direction.down, row: 8, col: 10,
        answer: 'ROYAL',
        clue: 'A king and queen live in the ___ palace.'),
  ],
);
