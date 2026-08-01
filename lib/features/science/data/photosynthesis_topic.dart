import 'package:flutter/material.dart';

import '../models/science_content.dart';

/// "Photosynthesis" reading-comprehension topic. Both activities share one
/// diagram; the topic intro provides the reading context.
const ScienceTopic kPhotosynthesisTopic = ScienceTopic(
  id: 'photosynthesis',
  title: 'Photosynthesis',
  tagline: 'How a plant makes its own food',
  intro:
      'A leaf takes in carbon dioxide from the air while the roots pull up '
      'water and minerals. Inside the chloroplasts, light energy runs the '
      'reactions that build sugar and release oxygen. Choose an activity to '
      'practise what you know.',
  heroImage: 'assets/photosynthesis_diagram.jpg',
  accent: Color(0xFF2E9E5B),
  quiz: ReadingActivity(
    diagram: 'assets/photosynthesis_diagram.jpg',
    diagramCaption: 'The photosynthesis reaction',
  ),
  blanks: ReadingActivity(
    diagram: 'assets/photosynthesis_diagram.jpg',
    diagramCaption: 'The photosynthesis reaction',
  ),
  wordBank: [
    'sunlight', 'carbon dioxide', 'water', 'oxygen', 'sugar',
    'chloroplast', 'thylakoid', 'grana', 'stroma', 'Calvin cycle',
    'ATP', 'NADPH', 'leaf', 'roots',
  ],
  questions: [
    QuizQuestion(
      question: 'Which gas does a plant take IN during photosynthesis?',
      options: ['Oxygen (O₂)', 'Carbon dioxide (CO₂)', 'Nitrogen (N₂)'],
      answerIndex: 1,
      explanation:
          'Leaves absorb carbon dioxide from the air. Its carbon atoms end up '
          'in the sugar the plant builds.',
    ),
    QuizQuestion(
      question: 'Which gas does a plant give OFF during photosynthesis?',
      options: ['Oxygen (O₂)', 'Carbon dioxide (CO₂)', 'Water vapour'],
      answerIndex: 0,
      explanation:
          'Splitting water releases oxygen, which leaves the plant through '
          'the leaves — the oxygen we breathe.',
    ),
    QuizQuestion(
      question: 'Which energy source powers photosynthesis?',
      options: ['Heat from the soil', 'Light from the Sun', 'Wind'],
      answerIndex: 1,
      explanation:
          'Light energy from the Sun is captured by the plant and stored as '
          'chemical energy in sugar.',
    ),
    QuizQuestion(
      question: 'What do the roots absorb from the soil?',
      options: [
        'Sugar and oxygen',
        'Water and minerals',
        'Carbon dioxide and light',
      ],
      answerIndex: 1,
      explanation:
          'Roots pull water and dissolved minerals out of the soil and carry '
          'them up to the leaves.',
    ),
    QuizQuestion(
      question:
          'Inside which part of a plant cell does photosynthesis happen?',
      options: ['The nucleus', 'The chloroplast', 'The vacuole'],
      answerIndex: 1,
      explanation:
          'Chloroplasts are the green organelles inside leaf cells where the '
          'whole process takes place.',
    ),
    QuizQuestion(
      question: 'Where inside the chloroplast is light energy captured?',
      options: [
        'In the thylakoids',
        'In the stroma',
        'In the outer membrane',
      ],
      answerIndex: 0,
      explanation:
          'Thylakoids are flat discs that trap light energy and run the '
          'light-dependent reactions.',
    ),
    QuizQuestion(
      question: 'What is a stack of thylakoids called?',
      options: ['A stroma', 'A granum (grana)', 'A membrane'],
      answerIndex: 1,
      explanation:
          'Thylakoids are stacked like coins; one stack is a granum, and '
          'several stacks are grana.',
    ),
    QuizQuestion(
      question: 'What is the fluid that surrounds the grana called?',
      options: ['The stroma', 'The cytoplasm', 'The intermembrane space'],
      answerIndex: 0,
      explanation:
          'The stroma is the fluid filling the chloroplast, and it is where '
          'the Calvin cycle runs.',
    ),
    QuizQuestion(
      question: 'Which cycle uses carbon dioxide to build sugar?',
      options: ['The water cycle', 'The Calvin cycle', 'The rock cycle'],
      answerIndex: 1,
      explanation:
          'The Calvin cycle takes carbon from CO₂ and assembles it into sugar '
          'using energy from ATP and NADPH.',
    ),
    QuizQuestion(
      question:
          'The light reactions change ADP + P into which energy carrier?',
      options: ['NADP⁺', 'ATP', 'O₂'],
      answerIndex: 1,
      explanation:
          'ATP stores the energy that the Calvin cycle spends when it builds '
          'sugar molecules.',
    ),
  ],
  blankItems: [
    BlankItem(
      before: 'A plant uses energy from ',
      after: ' to make its own food.',
      accepted: ['sunlight', 'light', 'the sun', 'sun', 'light energy'],
      hint: 'It shines down from the sky.',
    ),
    BlankItem(
      before: 'Leaves take in the gas ',
      after: ' from the air.',
      accepted: ['carbon dioxide', 'co2'],
      hint: 'Its formula is CO₂.',
    ),
    BlankItem(
      before: 'The roots pull ',
      after: ' and minerals out of the soil.',
      accepted: ['water', 'h2o'],
      hint: 'Its formula is H₂O.',
    ),
    BlankItem(
      before: 'The gas released back into the air is ',
      after: '.',
      accepted: ['oxygen', 'o2'],
      hint: 'It is the gas we breathe in.',
    ),
    BlankItem(
      before: 'The food that photosynthesis makes is ',
      after: '.',
      accepted: ['sugar', 'glucose', 'ch2o'],
      hint: 'It is sweet, and it stores energy.',
    ),
    BlankItem(
      before: 'Most photosynthesis happens inside a ',
      after: ' of the plant.',
      accepted: ['leaf', 'leaves'],
      hint: 'It is flat, green and grows on a stem.',
    ),
    BlankItem(
      before: 'Inside the plant cell, the green organelle called the ',
      after: ' does the work.',
      accepted: ['chloroplast', 'chloroplasts'],
      hint: 'Its name starts with "chloro".',
    ),
    BlankItem(
      before: 'Light energy is trapped by flat discs called ',
      after: '.',
      accepted: ['thylakoids', 'thylakoid'],
      hint: 'They look like stacked coins.',
    ),
    BlankItem(
      before: 'A stack of those discs is called a ',
      after: '.',
      accepted: ['granum', 'grana'],
      hint: 'Singular ends in "-um", plural in "-a".',
    ),
    BlankItem(
      before: 'The fluid that fills the chloroplast is the ',
      after: '.',
      accepted: ['stroma'],
      hint: 'It surrounds the grana.',
    ),
    BlankItem(
      before: 'Carbon dioxide is turned into sugar by the ',
      after: ' cycle.',
      accepted: ['calvin', 'calvin cycle'],
      hint: 'It is named after the scientist who found it.',
    ),
    BlankItem(
      before: 'The light reactions store energy in ATP and ',
      after: '.',
      accepted: ['nadph'],
      hint: 'NADP⁺ becomes this when it gains energy.',
    ),
  ],
);
