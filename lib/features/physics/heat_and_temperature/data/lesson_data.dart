import '../models/lesson.dart';

/// The worksheet content, built from Fig. 4-9 (the principle of cryogenics)
/// and Fig. 4-8 (a plasma jet), with Table 4-3 behind the reference tab.
///
/// Everything the question screens render comes from here, so the lesson could
/// later be fetched or generated without touching a single widget.
const Lesson kCryogenicsLesson = Lesson(
  passageOne: Passage(
    title: 'The principle of cryogenics',
    figureCaption: 'Fig. 4-9 — the principle of cryogenics',
    body:
        'To produce very low temperatures, we use cryogenic equipment, which '
        'is similar to the mechanism of a refrigerator or a room air '
        'conditioner and is based on the fact that compressed air escaping '
        'through a small opening gets cooler when it expands into a larger '
        'volume.\n\n'
        'The principle of cryogenic apparatus is shown in Figure 4-9. The '
        'apparatus consists of an electrically driven compressor that pumps '
        'the gas from the expansion chamber up into the compression chamber '
        'when the valve on the right connecting the two chambers is closed. '
        'The compressed gas is heated above room temperature, and the excess '
        'heat escapes into the surroundings — be it into the kitchen in '
        'which the refrigerator stands, or into the air outside the windows '
        'in which the air conditioner is installed. When the valve '
        'separating the compression chamber is opened, the gas expands '
        'again and sucks in heat from the surroundings.',
  ),
  choiceQuestions: [
    ChoiceQuestion(
      beat: 1,
      topic: 'Compression',
      prompt: 'While the valve between the chambers is closed, the gas in the '
          'compression chamber —',
      choices: [
        'cools below room temperature and draws heat in',
        'is heated above room temperature and loses heat to the surroundings',
        'stays at room temperature because it cannot move',
      ],
      answer:
          'is heated above room temperature and loses heat to the surroundings',
    ),
    ChoiceQuestion(
      beat: 2,
      topic: 'Expansion',
      prompt: 'What happens when the valve is opened?',
      choices: [
        'The gas expands into the larger volume, cools, and absorbs heat from '
            'the surroundings',
        'The gas is compressed further and gives up more heat',
        'The gas escapes from the apparatus altogether',
      ],
      answer: 'The gas expands into the larger volume, cools, and absorbs heat '
          'from the surroundings',
    ),
    ChoiceQuestion(
      beat: 3,
      topic: 'Thermal pump',
      prompt: 'The sequence of successive compressions and expansions acts as '
          'a thermal pump that —',
      choices: [
        'destroys the heat taken from the expander',
        'carries heat from the expander and pumps it into the compressor',
        'moves heat from the compressor down into the expander',
      ],
      answer: 'carries heat from the expander and pumps it into the compressor',
    ),
    ChoiceQuestion(
      beat: 5,
      topic: 'Plasma jet',
      prompt: 'A plasma jet reaches a temperature of about —',
      choices: [
        '1,700°C, the temperature of a kitchen range flame',
        '6,000°C, the temperature of the surface of the sun',
        '15,000°C, some two and a half times the temperature of the '
            'sun\u2019s surface',
      ],
      answer: '15,000°C, some two and a half times the temperature of the '
          'sun\u2019s surface',
    ),
  ],
  passageTwo: Passage(
    title: 'Very hot and very cold',
    figureCaption: 'Fig. 4-8 — a plasma jet, and Table 4-3',
    body:
        'Human beings are sensitive to a narrow band of temperature, but life '
        'endures far wider variations: algae in hot springs stand water close '
        'to boiling, while plant seeds are not killed by temperatures '
        'approaching absolute zero. The lowest temperature we meet in everyday '
        'life is that of dry ice, frozen carbon dioxide, at about −80°C, and '
        'the highest is the kitchen range flame at about 1,700°C. Engineering '
        'goes well beyond both. A plasma jet, produced by blowing a stream of '
        'noble gas through a high-current electric arc and consisting of '
        'positive ions and free electrons, reaches almost 15,000°C. At the '
        'other end of the scale, cryogenic equipment can first liquefy air and '
        'then freeze it into a solid block, and every other gas can be '
        'liquefied and frozen at lower temperatures still.',
  ),
  clozeSentences: [
    ClozeSentence(
      beat: 4,
      before: 'A plasma jet is produced by blowing a stream of',
      after: 'gas through a high-current electric arc.',
      answer: 'noble',
      hint: 'Argon and helium are two of them',
    ),
    ClozeSentence(
      beat: 5,
      before: 'The jet consists of positive ions and free',
      after: '.',
      answer: 'electrons',
    ),
    ClozeSentence(
      beat: 5,
      before: 'It reaches a temperature of almost',
      after: '°C.',
      answer: '15,000',
      alsoAccept: ['15000', '15 000'],
    ),
    ClozeSentence(
      beat: 1,
      before: 'The lowest temperature of everyday life is that of dry',
      after: ', frozen carbon dioxide.',
      answer: 'ice',
    ),
    ClozeSentence(
      beat: 2,
      before: 'Cryogenic equipment can first',
      after: 'air and then freeze it into a solid block.',
      answer: 'liquefy',
      alsoAccept: ['liquify'],
    ),
    ClozeSentence(
      beat: 3,
      before: 'Plant seeds are not killed by temperatures approaching absolute',
      after: '.',
      answer: 'zero',
      hint: 'The bottom of the temperature scale',
    ),
  ],
);
