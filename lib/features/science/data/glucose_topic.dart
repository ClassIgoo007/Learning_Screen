import 'package:flutter/material.dart';

import '../models/science_content.dart';

/// "Glucose & Proteins" reading-comprehension topic.
const ScienceTopic kGlucoseTopic = ScienceTopic(
  id: 'glucose',
  title: 'Glucose & Proteins',
  tagline: 'Reading comprehension in biochemistry',
  intro:
      'Each activity begins with a short passage and its diagram. Read the '
      'passage, then answer the questions that follow — every answer can be '
      'found in what you have just read.',
  heroImage: 'assets/glucose.png',
  accent: Color(0xFF6A1B9A),
  quiz: ReadingActivity(
    passageTitle: 'Passage 1: Glucose',
    passageText:
        'Glucose is a simple sugar with the formula C6H12O6, and it is the '
        'main fuel that cells break down for energy. Its six carbon atoms are '
        'numbered 1 to 6. Glucose can take two different forms that change '
        'back and forth into each other. In the open-chain form the carbons '
        'make a straight backbone: carbon 1 carries a double-bonded oxygen, '
        'which makes it an aldehyde group, while the other carbons carry '
        'hydroxyl groups, each written as OH. In water, the oxygen on carbon '
        '5 swings round and bonds to carbon 1, closing the chain into a '
        'six-sided ring. That ring is built from five carbon atoms and one '
        'oxygen atom, and this ring form of a sugar is called a pyranose. The '
        'double arrow drawn between the two structures means that the open '
        'chain and the ring exist together in equilibrium.',
    diagram: 'assets/glucose.png',
    diagramCaption: 'Figure 1 — Glucose: the open chain and the ring form',
  ),
  blanks: ReadingActivity(
    passageTitle: 'Passage 2: Proteins and Amino Acids',
    passageText:
        'Proteins are a class of organic compounds made almost entirely of '
        'four elements: carbon, hydrogen, oxygen and nitrogen. A protein is a '
        'polymer, which means it is a long chain built from many repeating '
        'subunits joined together. The subunits of a protein are amino acids. '
        'Every amino acid is built on the same plan: a central carbon atom '
        'holds an amino group, written NH2, a carboxyl group, written COOH, a '
        'hydrogen atom, and a side chain that chemists write as R. The R '
        'group is the only part that changes from one amino acid to the next, '
        'so it is what gives each amino acid its own character. When amino '
        'acids join, the amino group of one reacts with the carboxyl group of '
        'the next, and the long chain that forms folds up into a working '
        'protein.',
    diagram: 'assets/amino_acid.png',
    diagramCaption: 'Figure 2 — The general structure of an amino acid',
  ),
  wordBank: [
    'glucose', 'aldehyde', 'hydroxyl', 'pyranose', 'equilibrium',
    'protein', 'polymer', 'subunit', 'amino acid', 'amino group',
    'carboxyl group', 'side chain (R)',
  ],
  questions: [
    QuizQuestion(
      question: 'What is the chemical formula of glucose?',
      options: ['C6H12O6', 'CO2', 'C12H22O11'],
      answerIndex: 0,
      explanation:
          'The passage opens by giving glucose the formula C6H12O6 — six '
          'carbons, twelve hydrogens and six oxygens.',
    ),
    QuizQuestion(
      question: 'How many carbon atoms does a glucose molecule have?',
      options: ['Five', 'Six', 'Twelve'],
      answerIndex: 1,
      explanation: 'Its six carbon atoms are numbered 1 to 6.',
    ),
    QuizQuestion(
      question: 'What do cells mainly use glucose for?',
      options: [
        'Building cell walls',
        'Storing genetic information',
        'Fuel that is broken down for energy',
      ],
      answerIndex: 2,
      explanation:
          'Glucose is described as the main fuel that cells break down for '
          'energy.',
    ),
    QuizQuestion(
      question: 'In the open-chain form, what group is on carbon 1?',
      options: ['An aldehyde group', 'A hydroxyl group', 'An amino group'],
      answerIndex: 0,
      explanation:
          'Carbon 1 carries a double-bonded oxygen, which makes it an '
          'aldehyde group.',
    ),
    QuizQuestion(
      question: 'What is a group written as OH called?',
      options: ['A carboxyl group', 'A hydroxyl group', 'A carbonyl group'],
      answerIndex: 1,
      explanation:
          'The passage calls the OH groups on the other carbons hydroxyl '
          'groups.',
    ),
    QuizQuestion(
      question: 'The oxygen on which carbon swings round to close the ring?',
      options: ['Carbon 1', 'Carbon 5', 'Carbon 6'],
      answerIndex: 1,
      explanation:
          'In water the oxygen on carbon 5 reaches round and bonds to carbon '
          '1, closing the ring.',
    ),
    QuizQuestion(
      question: 'Which carbon does that oxygen bond to?',
      options: ['Carbon 1', 'Carbon 3', 'Carbon 6'],
      answerIndex: 0,
      explanation: 'It bonds to carbon 1, joining the two ends of the chain.',
    ),
    QuizQuestion(
      question: 'What is the ring built from?',
      options: [
        'Six carbon atoms',
        'Five carbon atoms and one oxygen atom',
        'Four carbon atoms and two oxygen atoms',
      ],
      answerIndex: 1,
      explanation:
          'Five carbons plus the oxygen from carbon 5 make the six-sided '
          'ring.',
    ),
    QuizQuestion(
      question: 'What is the ring form of a sugar called?',
      options: ['A pyranose', 'An aldehyde', 'A polymer'],
      answerIndex: 0,
      explanation:
          'A six-sided sugar ring like this one is called a pyranose.',
    ),
    QuizQuestion(
      question: 'What does the double arrow between the two structures mean?',
      options: [
        'The ring form is the only real one',
        'The two forms exist together in equilibrium',
        'The chain turns into a different sugar',
      ],
      answerIndex: 1,
      explanation:
          'The double arrow shows the open chain and the ring existing '
          'together in equilibrium, converting back and forth.',
    ),
  ],
  blankItems: [
    BlankItem(
      before: 'Proteins are a class of ',
      after: ' compounds.',
      accepted: ['organic'],
      hint: 'The opposite of inorganic.',
    ),
    BlankItem(
      before: 'They are made almost entirely of carbon, hydrogen, oxygen '
          'and ',
      after: '.',
      accepted: ['nitrogen', 'N'],
      hint: 'Its chemical symbol is N.',
    ),
    BlankItem(
      before: 'A protein is a ',
      after: ', a long chain built from repeating units.',
      accepted: ['polymer'],
      hint: 'Plastics are made of these long chains too.',
    ),
    BlankItem(
      before: 'A polymer is built from many repeating ',
      after: ' joined together.',
      accepted: ['subunits', 'subunit'],
      hint: 'Sub- means "under" or "smaller part".',
    ),
    BlankItem(
      before: 'The subunits of a protein are ',
      after: '.',
      accepted: ['amino acids', 'amino acid'],
      hint: 'Two words — the second one is "acids".',
    ),
    BlankItem(
      before: 'Every amino acid is built around a central ',
      after: ' atom.',
      accepted: ['carbon', 'C'],
      hint: 'Its chemical symbol is C.',
    ),
    BlankItem(
      before: 'The group written NH2 is called the ',
      after: ' group.',
      accepted: ['amino'],
      hint: 'It gives amino acids the first half of their name.',
    ),
    BlankItem(
      before: 'The group written COOH is called the ',
      after: ' group.',
      accepted: ['carboxyl'],
      hint: 'It starts with "carb" and ends in "-yl".',
    ),
    BlankItem(
      before: 'As well as those two groups and a side chain, the central '
          'carbon also holds a ',
      after: ' atom.',
      accepted: ['hydrogen', 'H'],
      hint: 'Its chemical symbol is H.',
    ),
    BlankItem(
      before: 'Chemists write the side chain as the letter ',
      after: '.',
      accepted: ['R'],
      hint: 'A single capital letter.',
    ),
    BlankItem(
      before: 'The R group gives each amino acid its own ',
      after: '.',
      accepted: ['character'],
      hint: 'It means what makes something different from the others.',
    ),
    BlankItem(
      before: 'The long chain that forms ',
      after: ' up into a working protein.',
      accepted: ['folds', 'fold'],
      hint: 'What you do to a piece of paper to make it compact.',
    ),
  ],
);
