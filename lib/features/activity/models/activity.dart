import 'dart:math' show Point;

/// One fill-in-the-blank sentence. [before] and [after] are the text on each
/// side of the blank; [answer] is the word (uppercase) that completes it.
class SentenceItem {
  final String before;
  final String after;
  final String answer;

  const SentenceItem(this.before, this.answer, this.after);
}

/// Where a word sits in the word search (start cell + direction).
class WordPlacement {
  final String word;
  final List<Point<int>> cells;

  const WordPlacement(this.word, this.cells);
}

class VowelActivity {
  final String title;
  final String subtitle;
  final List<String> words;
  final List<SentenceItem> sentences;
  final List<String> gridRows; // each string is one row of letters

  /// Illustration asset shown on the intro/play screens + celebration dialog.
  final String image;

  /// Short vowel/sound name used in headings, e.g. 'Long e', 'Long u'.
  final String name;

  /// One-line tagline shown under the intro heading.
  final String tagline;

  const VowelActivity({
    required this.title,
    required this.subtitle,
    required this.words,
    required this.sentences,
    required this.gridRows,
    required this.image,
    required this.name,
    required this.tagline,
  });

  /// Keep branding from [seed], swap in a fresh word bank / sentences / grid.
  factory VowelActivity.fromGenerated({
    required VowelActivity seed,
    required List<String> words,
    required List<SentenceItem> sentences,
    required List<String> gridRows,
  }) {
    return VowelActivity(
      title: seed.title,
      subtitle: seed.subtitle,
      words: words,
      sentences: sentences,
      gridRows: gridRows,
      image: seed.image,
      name: seed.name,
      tagline: seed.tagline,
    );
  }

  int get rows => gridRows.length;
  int get cols => gridRows.first.length;

  String letterAt(Point<int> pos) => gridRows[pos.x][pos.y];

  /// Locate every word in the grid (reading right or down). Computed once;
  /// the generator guarantees each word appears exactly once.
  List<WordPlacement> findPlacements() {
    final result = <WordPlacement>[];
    for (final word in words) {
      outer:
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          for (final (dr, dc) in const [(0, 1), (1, 0)]) {
            final er = r + dr * (word.length - 1);
            final ec = c + dc * (word.length - 1);
            if (er >= rows || ec >= cols) continue;
            var match = true;
            for (var i = 0; i < word.length; i++) {
              if (gridRows[r + dr * i][c + dc * i] != word[i]) {
                match = false;
                break;
              }
            }
            if (match) {
              result.add(WordPlacement(
                word,
                List.generate(
                    word.length, (i) => Point(r + dr * i, c + dc * i)),
              ));
              break outer;
            }
          }
        }
      }
    }
    return result;
  }
}

/// Original "Words with Long e" activity. The word-search grid was generated
/// and machine-verified: each word appears exactly once, reading right or down.
const VowelActivity kLongEActivity = VowelActivity(
  title: 'Words with Long e',
  subtitle: 'Long e words may be spelled e, ee, ea, or ey. '
      'Tap a blank, then drag across that word in the puzzle '
      '(or tap it in the Word Bank).',
  image: 'assets/celebration.png',
  name: 'Long e',
  tagline: 'Finish the sentences, then find the words in the puzzle',
  words: [
    'ZEBRA', 'GREEN', 'SLEEP', 'TEAM', 'BEACH',
    'MONKEY', 'HONEY', 'EAGLE', 'STREET', 'LEAF',
  ],
  sentences: [
    SentenceItem('A ', 'ZEBRA', ' has black and white stripes.'),
    SentenceItem('Grass and leaves are usually ', 'GREEN', '.'),
    SentenceItem('We ', 'SLEEP', ' at night to rest our bodies.'),
    SentenceItem('Everyone on the ', 'TEAM', ' wears the same jersey.'),
    SentenceItem('We built a sandcastle at the ', 'BEACH', '.'),
    SentenceItem('A ', 'MONKEY', ' swings from tree to tree.'),
    SentenceItem('Bees make sweet ', 'HONEY', '.'),
    SentenceItem('An ', 'EAGLE', ' is a large bird with sharp eyes.'),
    SentenceItem('Cars and buses drive down the ', 'STREET', '.'),
    SentenceItem('One little green ', 'LEAF', ' fell from the tree.'),
  ],
  gridRows: [
    'CSNZEBRABACG',
    'HQTASRGWUWER',
    'NHOHTSIZASAY',
    'BZFORWNKILGE',
    'EGYNEKDCMELD',
    'ALGEELTIZEEB',
    'CXRYTORDMPCR',
    'HJEUTLSGWCBV',
    'HYEJCHDLEAFM',
    'IONULTEAMFLL',
    'GVIWVUCTUFRX',
    'HFMONKEYOMIU',
  ],
);

/// "Words with Long u" activity. The word-search grid was generated and
/// machine-verified: each word appears exactly once, reading right or down.
const VowelActivity kLongUActivity = VowelActivity(
  title: 'Words with Long u',
  subtitle: 'Long u words may be spelled u, u_e, or ue. '
      'Tap a blank, then drag across that word in the puzzle '
      '(or tap it in the Word Bank).',
  image: 'assets/longu_hero.png',
  name: 'Long u',
  tagline: 'Finish the sentences, then find the words in the puzzle',
  words: [
    'UNIFORM', 'MUSIC', 'CUBE', 'HUGE', 'MULE',
    'RESCUE', 'MENU', 'TUBE', 'UNITE', 'BUGLE',
  ],
  sentences: [
    SentenceItem('An astronaut wears a special white ', 'UNIFORM', '.'),
    SentenceItem('We hummed along to the ', 'MUSIC', '.'),
    SentenceItem('An ice ', 'CUBE', ' melted in my glass.'),
    SentenceItem('The universe is unbelievably ', 'HUGE', '.'),
    SentenceItem('A ', 'MULE', ' looks like a horse with long ears.'),
    SentenceItem('Firefighters ', 'RESCUE', ' people from danger.'),
    SentenceItem('We picked our lunch from the ', 'MENU', '.'),
    SentenceItem('Toothpaste comes in a squeezy ', 'TUBE', '.'),
    SentenceItem('The two teams will ', 'UNITE', ' to play as one.'),
    SentenceItem('A ', 'BUGLE', ' is a horn played in the morning.'),
  ],
  gridRows: [
    'BQGBBCNCUBEN',
    'CHCURNMULEBS',
    'DHUGUSBSSMBH',
    'RBRLEJNERDSJ',
    'ERVEFUNIFORM',
    'SDSSUGLDRWCM',
    'CSBTGPVRUNYE',
    'UHKOSOMLNJHN',
    'EUZFWYUHICSU',
    'JGQPKXSOTJTC',
    'DEQNFYIKEEPN',
    'TUBEBVCCYRSZ',
  ],
);
