import 'package:flutter/material.dart';

import '../models/science_content.dart';

/// "Genetic Code & DNA" reading-comprehension topic.
const ScienceTopic kGeneticCodeTopic = ScienceTopic(
  id: 'genetic_code',
  title: 'Genetic Code & DNA',
  tagline: 'Reading comprehension in molecular biology',
  intro:
      'Each activity begins with a short passage and its diagram. Read the '
      'passage, then answer the questions that follow — every answer can be '
      'found in what you have just read.',
  heroImage: 'assets/genetic_code.png',
  accent: Color(0xFF1565C0),
  quiz: ReadingActivity(
    passageTitle: 'Passage 1: The Genetic Code',
    passageText:
        'The genetic code is the set of rules a cell follows when it assembles '
        'amino acids into proteins, and it appears to be universal for all '
        'living forms. Because there are 20 naturally occurring amino acids, '
        'the code needs at least 20 different signals. Each signal is a codon, '
        'a unit of three bases read along the mRNA. Taking three bases at a '
        'time from four possible letters gives 4 to the power of 3, or 64, '
        'different arrangements, which is far more than the minimum needed. '
        'The code is therefore described as degenerate, meaning that several '
        'different codons can stand for the same amino acid. A few codons name '
        'no amino acid at all: AUG is the chain-initiation signal that starts '
        'the synthesis of a protein, while UAA, UAG and UGA are '
        'chain-termination signals that stop it.',
    diagram: 'assets/genetic_code.png',
    diagramCaption: 'Table 1 — The genetic code',
  ),
  blanks: ReadingActivity(
    passageTitle: 'Passage 2: DNA Structure',
    passageText:
        'DNA is a repeating polymer made from four nucleotides: adenine, '
        'guanine, cytosine and thymine. Using X-ray diffraction photographs of '
        'DNA taken by Rosalind Franklin, together with the findings of many '
        'other investigators, James Watson and Francis Crick developed a '
        'double helical model for the structure of DNA in 1953. Hydrogen '
        'bonding between the bases holds the two strands together. Adenine is '
        'always crosslinked with thymine by two hydrogen bonds, and cytosine '
        'is always linked with guanine by three hydrogen bonds, so these pairs '
        'are called complementary bases. Each sugar in the backbone of a '
        'strand is joined by a phosphate molecule at C5 to the sugar above it, '
        'and a phosphate at C3 joins it to the sugar below. One end of a '
        'strand is called the 5 prime end and the other is called the 3 prime '
        'end.',
    diagram: 'assets/genetic_dna_structure.png',
    diagramCaption: 'Figure 1 — Structure of DNA',
  ),
  wordBank: [
    'codon', 'degenerate', 'universal', 'chain initiation',
    'chain termination', 'mRNA', 'nucleotide', 'polymer', 'double helix',
    'hydrogen bond', 'complementary bases', 'sugar-phosphate backbone',
  ],
  questions: [
    QuizQuestion(
      question: 'How many naturally occurring amino acids must the code cover?',
      options: ['4', '20', '64'],
      answerIndex: 1,
      explanation:
          'There are 20 naturally occurring amino acids, so the code needs at '
          'least 20 different signals.',
    ),
    QuizQuestion(
      question: 'How many bases make up one codon?',
      options: ['Two', 'Three', 'Four'],
      answerIndex: 1,
      explanation: 'A codon is a unit of three bases read along the mRNA.',
    ),
    QuizQuestion(
      question: 'How many different codons are possible?',
      options: ['20', '48', '64'],
      answerIndex: 2,
      explanation:
          'Three bases chosen from four letters give 4 to the power of 3, '
          'which is 64 arrangements.',
    ),
    QuizQuestion(
      question: 'Where does the number 64 come from?',
      options: [
        'Four bases taken three at a time',
        'Three bases taken four at a time',
        'Twenty amino acids plus stop signals',
      ],
      answerIndex: 0,
      explanation:
          'Four possible letters in each of three positions gives 4 x 4 x 4 = '
          '64.',
    ),
    QuizQuestion(
      question: 'What does it mean that the code is degenerate?',
      options: [
        'Several codons can stand for the same amino acid',
        'The code breaks down over time',
        'Each amino acid has exactly one codon',
      ],
      answerIndex: 0,
      explanation:
          'Degenerate means a number of different codons may represent the '
          'same amino acid.',
    ),
    QuizQuestion(
      question: 'Which codon is the chain-initiation signal?',
      options: ['AUG', 'UAA', 'UGA'],
      answerIndex: 0,
      explanation:
          'AUG starts protein synthesis; the passage calls it the '
          'chain-initiation signal.',
    ),
    QuizQuestion(
      question: 'Which of these is a chain-termination signal?',
      options: ['AUG', 'UAG', 'CGA'],
      answerIndex: 1,
      explanation:
          'UAA, UAG and UGA are the three chain-termination signals that stop '
          'synthesis.',
    ),
    QuizQuestion(
      question: 'How many chain-termination codons are named in the passage?',
      options: ['One', 'Two', 'Three'],
      answerIndex: 2,
      explanation: 'Three are listed: UAA, UAG and UGA.',
    ),
    QuizQuestion(
      question: 'The genetic code appears to be what, for all living forms?',
      options: ['Universal', 'Unique to each species', 'Still unknown'],
      answerIndex: 0,
      explanation:
          'The passage says the code appears to be universal for all living '
          'forms.',
    ),
    QuizQuestion(
      question: 'Codons are read along which molecule?',
      options: ['mRNA', 'A protein', 'A ribosome'],
      answerIndex: 0,
      explanation: 'Each codon is a unit of three bases read along the mRNA.',
    ),
  ],
  blankItems: [
    BlankItem(
      before: 'DNA is a repeating ',
      after: ' made from four nucleotides.',
      accepted: ['polymer'],
      hint: 'A long chain built from repeating units.',
    ),
    BlankItem(
      before: 'Those four nucleotides are adenine, guanine, cytosine and ',
      after: '.',
      accepted: ['thymine'],
      hint: 'The one that pairs with adenine.',
    ),
    BlankItem(
      before: 'The X-ray diffraction photographs of DNA were taken by Rosalind ',
      after: '.',
      accepted: ['Franklin'],
      hint: 'Her surname begins with F.',
    ),
    BlankItem(
      before: 'James Watson and Francis ',
      after: ' developed the double helical model.',
      accepted: ['Crick'],
      hint: 'Watson and ______.',
    ),
    BlankItem(
      before: 'They published that model in the year ',
      after: '.',
      accepted: ['1953'],
      hint: 'A year in the 1950s.',
    ),
    BlankItem(
      before: 'The two strands are held together by ',
      after: ' bonding between the bases.',
      accepted: ['hydrogen'],
      hint: 'Its chemical symbol is H.',
    ),
    BlankItem(
      before: 'Adenine is always crosslinked with ',
      after: '.',
      accepted: ['thymine'],
      hint: 'A pairs with this base.',
    ),
    BlankItem(
      before: 'Adenine and thymine are joined by ',
      after: ' hydrogen bonds.',
      accepted: ['two', '2'],
      hint: 'One fewer than the G–C pair has.',
    ),
    BlankItem(
      before: 'Cytosine is always linked with ',
      after: '.',
      accepted: ['guanine'],
      hint: 'C pairs with this base.',
    ),
    BlankItem(
      before: 'Cytosine and guanine are joined by ',
      after: ' hydrogen bonds.',
      accepted: ['three', '3'],
      hint: 'One more than the A–T pair has.',
    ),
    BlankItem(
      before: 'Pairs that always join in this way are called ',
      after: ' bases.',
      accepted: ['complementary'],
      hint: 'It begins with "comple".',
    ),
    BlankItem(
      before: 'One end of a strand is the 5 prime end; the other is the ',
      after: ' prime end.',
      accepted: ['3', 'three'],
      hint: 'A single digit.',
    ),
  ],
);
